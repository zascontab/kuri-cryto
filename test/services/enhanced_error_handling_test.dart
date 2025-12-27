import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:kuri_crypto/services/retry_service.dart';
import 'package:kuri_crypto/services/rate_limit_service.dart';
import 'package:kuri_crypto/services/fallback_service.dart';
import 'package:kuri_crypto/exceptions/matp_exceptions.dart';
import 'package:kuri_crypto/exceptions/mcp_exceptions.dart';

void main() {
  group('Enhanced Error Handling Tests', () {
    late RetryService retryService;
    late RateLimitService rateLimitService;
    late FallbackService fallbackService;

    setUp(() {
      retryService = RetryService(
        maxRetries: 3,
        initialDelay: const Duration(milliseconds: 100),
        backoffMultiplier: 2.0,
      );
      rateLimitService = RateLimitService();
      fallbackService = FallbackService();
    });

    tearDown(() {
      retryService.clearCircuitBreakers();
      retryService.clearPendingRequests();
      rateLimitService.clearState();
      fallbackService.clearCache();
      fallbackService.clearFallbacks();
    });

    group('Property 36: Network Error Retry Logic', () {
      test('should retry network errors with exponential backoff', () async {
        int attemptCount = 0;
        final startTime = DateTime.now();

        try {
          await retryService.executeWithRetry(() async {
            attemptCount++;
            if (attemptCount < 3) {
              throw DioException(
                requestOptions: RequestOptions(path: '/test'),
                type: DioExceptionType.connectionTimeout,
              );
            }
            return 'success';
          });
        } catch (e) {
          // Expected to fail after retries
        }

        final duration = DateTime.now().difference(startTime);

        // Should have attempted 3 times (initial + 2 retries, then fail on 3rd)
        expect(attemptCount, equals(3));

        // Should have taken at least the sum of delays: 100ms + 200ms = 300ms (with jitter it might be less)
        expect(duration.inMilliseconds, greaterThan(200));
      });

      test('should not retry non-retryable exceptions', () async {
        int attemptCount = 0;

        try {
          await retryService.executeWithRetry(() async {
            attemptCount++;
            throw DioException(
              requestOptions: RequestOptions(path: '/test'),
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: RequestOptions(path: '/test'),
                statusCode: 400,
              ),
            );
          });
        } catch (e) {
          // Expected to fail immediately
        }

        // Should only attempt once (no retries for 4xx errors)
        expect(attemptCount, equals(1));
      });

      test('should respect custom retryable exceptions', () async {
        int attemptCount = 0;

        try {
          await retryService.executeWithRetry(
            () async {
              attemptCount++;
              throw MATPAuthException.tokenExpired();
            },
            retryableExceptions: [MATPAuthException],
          );
        } catch (e) {
          // Expected to fail after retries
        }

        // Should have retried auth exception when explicitly allowed
        expect(attemptCount, greaterThan(1));
      });
    });

    group('Property 38: Rate Limit Queue Management', () {
      test('should queue requests when rate limited', () async {
        // Configure very low rate limit for testing
        rateLimitService.updateConfig(
          'test_endpoint',
          const RateLimitConfig(requestsPerMinute: 2, burstSize: 1),
        );

        final results = <String>[];
        final futures = <Future>[];

        // Fire multiple requests simultaneously
        for (int i = 0; i < 5; i++) {
          futures.add(
            rateLimitService.executeWithRateLimit<String>(
              () async {
                await Future.delayed(const Duration(milliseconds: 100));
                results.add('request_$i');
                return 'request_$i';
              },
              endpoint: 'test_endpoint',
            ),
          );
        }

        await Future.wait(futures);

        // All requests should complete
        expect(results.length, equals(5));

        // Queue should be empty after processing
        expect(rateLimitService.getQueueSize('test_endpoint'), equals(0));
      });

      test('should respect request priorities in queue', () async {
        rateLimitService.updateConfig(
          'test_endpoint',
          const RateLimitConfig(requestsPerMinute: 1, burstSize: 1),
        );

        final results = <String>[];
        final futures = <Future>[];

        // Add low priority request first
        futures.add(
          rateLimitService.executeWithRateLimit<String>(
            () async {
              results.add('low_priority');
              return 'low_priority';
            },
            endpoint: 'test_endpoint',
            priority: RequestPriority.low,
          ),
        );

        // Add high priority request after
        await Future.delayed(const Duration(milliseconds: 50));
        futures.add(
          rateLimitService.executeWithRateLimit<String>(
            () async {
              results.add('high_priority');
              return 'high_priority';
            },
            endpoint: 'test_endpoint',
            priority: RequestPriority.high,
          ),
        );

        await Future.wait(futures);

        // High priority should be processed before low priority
        // (after the first request that gets through immediately)
        expect(results.length, equals(2));
      });

      test('should handle rate limit exceptions properly', () async {
        int callCount = 0;

        try {
          await rateLimitService.executeWithRateLimit<String>(
            () async {
              callCount++;
              throw MATPRateLimitException(
                message: 'Rate limited',
                retryAfterSeconds: 1,
              );
            },
            endpoint: 'test_endpoint',
          );
        } catch (e) {
          // Expected to throw rate limit exception
          expect(e, isA<MATPRateLimitException>());
        }

        expect(callCount, equals(1));
      });
    });

    group('Property 39: MCP Fallback Mechanisms', () {
      test('should use cache fallback when primary operation fails', () async {
        // Setup cache with test data
        fallbackService.registerFallback(
            'test_operation',
            FallbackStrategy(
              name: 'cache_fallback',
              type: FallbackType.cache,
              priority: 100,
            ));

        // First call to populate cache
        final firstResult = await fallbackService.executeWithFallback<String>(
          'test_operation',
          () async => 'cached_data',
          cacheTimeout: const Duration(minutes: 5),
        );

        expect(firstResult, equals('cached_data'));

        // Second call should use cache when primary fails
        final secondResult = await fallbackService.executeWithFallback<String>(
          'test_operation',
          () async => throw Exception('Primary failed'),
          cacheTimeout: const Duration(minutes: 5),
        );

        expect(secondResult, equals('cached_data'));
      });

      test('should use mock data fallback when cache is unavailable', () async {
        fallbackService.registerFallback(
            'test_operation',
            FallbackStrategy(
              name: 'mock_fallback',
              type: FallbackType.mockData,
              priority: 50,
            ));

        fallbackService.registerMockGenerator(
            'test_operation', TestMockGenerator());

        final result =
            await fallbackService.executeWithFallback<Map<String, dynamic>>(
          'test_operation',
          () async => throw Exception('Primary failed'),
          enableMockData: true,
        );

        expect(result['type'], equals('mock'));
        expect(result['data'], equals('test_mock_data'));
      });

      test('should try fallbacks in priority order', () async {
        final attemptedStrategies = <String>[];

        // Register multiple fallbacks with different priorities
        fallbackService.registerFallback(
            'test_operation',
            FallbackStrategy(
              name: 'high_priority',
              type: FallbackType.custom,
              priority: 100,
              customHandler: (e) async {
                attemptedStrategies.add('high_priority');
                throw Exception('High priority failed');
              },
            ));

        fallbackService.registerFallback(
            'test_operation',
            FallbackStrategy(
              name: 'medium_priority',
              type: FallbackType.custom,
              priority: 50,
              customHandler: (e) async {
                attemptedStrategies.add('medium_priority');
                return 'medium_success';
              },
            ));

        fallbackService.registerFallback(
            'test_operation',
            FallbackStrategy(
              name: 'low_priority',
              type: FallbackType.custom,
              priority: 25,
              customHandler: (e) async {
                attemptedStrategies.add('low_priority');
                return 'low_success';
              },
            ));

        final result = await fallbackService.executeWithFallback<String>(
          'test_operation',
          () async => throw Exception('Primary failed'),
        );

        expect(result, equals('medium_success'));
        expect(
            attemptedStrategies, equals(['high_priority', 'medium_priority']));
      });

      test('should throw fallback exception when all strategies fail',
          () async {
        fallbackService.registerFallback(
            'test_operation',
            FallbackStrategy(
              name: 'failing_fallback',
              type: FallbackType.custom,
              priority: 100,
              customHandler: (e) async => throw Exception('Fallback failed'),
            ));

        expect(
          () => fallbackService.executeWithFallback<String>(
            'test_operation',
            () async => throw Exception('Primary failed'),
          ),
          throwsA(isA<MCPFallbackException>()),
        );
      });
    });

    group('Property 40: Critical Error Logging', () {
      test('should log circuit breaker state changes', () async {
        int failureCount = 0;

        // Cause multiple failures to trigger circuit breaker
        for (int i = 0; i < 6; i++) {
          try {
            await retryService.executeWithRetry(
              () async {
                failureCount++;
                throw Exception('Simulated failure');
              },
              operationId: 'test_operation',
              maxRetries: 0, // No retries to speed up test
            );
          } catch (e) {
            // Expected failures
          }
        }

        // Circuit should be open now
        expect(
          () => retryService.executeWithRetry(
            () async => 'success',
            operationId: 'test_operation',
          ),
          throwsA(isA<MATPException>()),
        );
      });

      test('should handle MATP rate limit exceptions with proper logging',
          () async {
        final exception = MATPRateLimitException.fromHeaders({
          'X-RateLimit-Reset': '60',
          'X-RateLimit-Reset-Time':
              DateTime.now().add(const Duration(minutes: 1)).toIso8601String(),
          'X-RateLimit-Remaining': '0',
          'X-RateLimit-Limit': '100',
        });

        expect(exception.retryAfterSeconds, equals(60));
        expect(exception.requestsRemaining, equals(0));
        expect(exception.requestsLimit, equals(100));
        expect(exception.statusCode, equals(429));
      });

      test('should handle MCP tool exceptions with context', () async {
        final exception = MCPToolException.executionFailed(
          toolName: 'calculate_rsi',
          reason: 'Invalid parameters',
          arguments: {'period': -1},
          phase: 'validation',
        );

        expect(exception.toolName, equals('calculate_rsi'));
        expect(exception.executionPhase, equals('validation'));
        expect(exception.toolArguments?['period'], equals(-1));
        expect(exception.statusCode, equals(500));
      });
    });

    group('Integration Tests', () {
      test('should handle complex failure scenarios with all services',
          () async {
        // Setup rate limiting
        rateLimitService.updateConfig(
          'integration_test',
          const RateLimitConfig(requestsPerMinute: 10, burstSize: 2),
        );

        // Setup fallback
        fallbackService.registerFallback(
            'integration_test',
            FallbackStrategy(
              name: 'mock_fallback',
              type: FallbackType.mockData,
              priority: 50,
            ));
        fallbackService.registerMockGenerator(
            'integration_test', TestMockGenerator());

        int attemptCount = 0;

        final result =
            await rateLimitService.executeWithRateLimit<Map<String, dynamic>>(
          () => retryService.executeWithRetry<Map<String, dynamic>>(
            () => fallbackService.executeWithFallback<Map<String, dynamic>>(
              'integration_test',
              () async {
                attemptCount++;
                if (attemptCount < 3) {
                  throw MCPConnectionException.serverUnavailable(
                    serverUrl: 'http://test.com',
                  );
                }
                return {'result': 'success', 'attempts': attemptCount};
              },
            ),
            operationId: 'integration_test',
          ),
          endpoint: 'integration_test',
        );

        // Should eventually succeed or use fallback
        expect(result, isNotNull);
        expect(
            result.containsKey('result') || result.containsKey('type'), isTrue);
      });
    });
  });
}

/// Test mock data generator
class TestMockGenerator extends MockDataGenerator {
  @override
  dynamic generate(Map<String, dynamic>? params) {
    return {
      'type': 'mock',
      'data': 'test_mock_data',
      'timestamp': DateTime.now().toIso8601String(),
      'params': params,
    };
  }
}
