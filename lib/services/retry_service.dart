import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../exceptions/matp_exceptions.dart';
import '../exceptions/mcp_exceptions.dart';

/// Enhanced retry service with exponential backoff and intelligent error handling
///
/// This service provides:
/// - Exponential backoff retry logic
/// - Jitter to prevent thundering herd
/// - Circuit breaker pattern
/// - Request deduplication
/// - Intelligent error classification
class RetryService {
  static const int _defaultMaxRetries = 3;
  static const Duration _defaultInitialDelay = Duration(milliseconds: 1000);
  static const double _defaultBackoffMultiplier = 2.0;
  static const double _defaultJitterFactor = 0.1;
  static const Duration _defaultMaxDelay = Duration(seconds: 30);

  final int maxRetries;
  final Duration initialDelay;
  final double backoffMultiplier;
  final double jitterFactor;
  final Duration maxDelay;
  final Random _random = Random();

  // Circuit breaker state
  final Map<String, CircuitBreakerState> _circuitBreakers = {};

  // Request deduplication
  final Map<String, Completer<dynamic>> _pendingRequests = {};

  RetryService({
    this.maxRetries = _defaultMaxRetries,
    this.initialDelay = _defaultInitialDelay,
    this.backoffMultiplier = _defaultBackoffMultiplier,
    this.jitterFactor = _defaultJitterFactor,
    this.maxDelay = _defaultMaxDelay,
  });

  /// Execute a function with retry logic and exponential backoff
  Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    String? operationId,
    int? maxRetries,
    Duration? initialDelay,
    bool enableCircuitBreaker = true,
    bool enableDeduplication = false,
    List<Type>? retryableExceptions,
    List<Type>? nonRetryableExceptions,
  }) async {
    final effectiveMaxRetries = maxRetries ?? this.maxRetries;
    final effectiveInitialDelay = initialDelay ?? this.initialDelay;
    final opId = operationId ?? _generateOperationId();

    // Check circuit breaker
    if (enableCircuitBreaker && _isCircuitOpen(opId)) {
      throw MATPConfigException(
        message: 'Circuit breaker is open for operation: $opId',
        code: 'CIRCUIT_BREAKER_OPEN',
      );
    }

    // Handle request deduplication
    if (enableDeduplication && _pendingRequests.containsKey(opId)) {
      developer.log('Deduplicating request: $opId', name: 'RetryService');
      return await _pendingRequests[opId]!.future as T;
    }

    final completer = Completer<T>();
    if (enableDeduplication) {
      _pendingRequests[opId] = completer as Completer<dynamic>;
    }

    try {
      final result = await _executeWithRetryInternal<T>(
        operation,
        opId,
        effectiveMaxRetries,
        effectiveInitialDelay,
        retryableExceptions,
        nonRetryableExceptions,
      );

      if (enableCircuitBreaker) {
        _recordSuccess(opId);
      }

      if (enableDeduplication) {
        completer.complete(result);
        _pendingRequests.remove(opId);
      }

      return result;
    } catch (e) {
      if (enableCircuitBreaker) {
        _recordFailure(opId);
      }

      if (enableDeduplication) {
        completer.completeError(e);
        _pendingRequests.remove(opId);
      }

      rethrow;
    }
  }

  /// Internal retry implementation
  Future<T> _executeWithRetryInternal<T>(
    Future<T> Function() operation,
    String operationId,
    int maxRetries,
    Duration initialDelay,
    List<Type>? retryableExceptions,
    List<Type>? nonRetryableExceptions,
  ) async {
    Exception? lastException;

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        developer.log(
          'Executing operation: $operationId (attempt ${attempt + 1}/${maxRetries + 1})',
          name: 'RetryService',
        );

        final result = await operation();

        if (attempt > 0) {
          developer.log(
            'Operation succeeded after $attempt retries: $operationId',
            name: 'RetryService',
          );
        }

        return result;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());

        developer.log(
          'Operation failed (attempt ${attempt + 1}): $operationId - $e',
          name: 'RetryService',
          error: e,
        );

        // Check if this is the last attempt
        if (attempt >= maxRetries) {
          developer.log(
            'Max retries exceeded for operation: $operationId',
            name: 'RetryService',
          );
          break;
        }

        // Check if exception is retryable
        if (!_isRetryableException(
            e, retryableExceptions, nonRetryableExceptions)) {
          developer.log(
            'Non-retryable exception for operation: $operationId - ${e.runtimeType}',
            name: 'RetryService',
          );
          break;
        }

        // Calculate delay with exponential backoff and jitter
        final delay = _calculateDelay(attempt, initialDelay);

        developer.log(
          'Retrying operation: $operationId in ${delay.inMilliseconds}ms',
          name: 'RetryService',
        );

        await Future.delayed(delay);
      }
    }

    // If we get here, all retries failed
    throw RetryException(
      message: 'Operation failed after $maxRetries retries: $operationId',
      operationId: operationId,
      attempts: maxRetries + 1,
      lastException: lastException,
    );
  }

  /// Calculate delay with exponential backoff and jitter
  Duration _calculateDelay(int attempt, Duration initialDelay) {
    // Exponential backoff: delay = initialDelay * (backoffMultiplier ^ attempt)
    final exponentialDelay =
        initialDelay.inMilliseconds * pow(backoffMultiplier, attempt);

    // Add jitter to prevent thundering herd
    final jitter =
        exponentialDelay * jitterFactor * (_random.nextDouble() - 0.5);
    final delayWithJitter = exponentialDelay + jitter;

    // Cap at maximum delay
    final cappedDelay =
        min(delayWithJitter, maxDelay.inMilliseconds.toDouble());

    return Duration(milliseconds: cappedDelay.round());
  }

  /// Check if an exception is retryable
  bool _isRetryableException(
    dynamic exception,
    List<Type>? retryableExceptions,
    List<Type>? nonRetryableExceptions,
  ) {
    // If non-retryable exceptions are specified, check those first
    if (nonRetryableExceptions != null) {
      for (final type in nonRetryableExceptions) {
        if (exception.runtimeType == type) {
          return false;
        }
      }
    }

    // If retryable exceptions are specified, only retry those
    if (retryableExceptions != null) {
      for (final type in retryableExceptions) {
        if (exception.runtimeType == type) {
          return true;
        }
      }
      return false;
    }

    // Default retryable exception logic
    if (exception is DioException) {
      switch (exception.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.connectionError:
          return true;
        case DioExceptionType.badResponse:
          // Retry on server errors (5xx) but not client errors (4xx)
          final statusCode = exception.response?.statusCode;
          return statusCode != null && statusCode >= 500;
        default:
          return false;
      }
    }

    // MATP specific exceptions
    if (exception is MATPRateLimitException) {
      return true; // Rate limits are temporary
    }

    if (exception is MATPGatewayException) {
      return exception.statusCode == null || exception.statusCode! >= 500;
    }

    if (exception is MATPAuthException) {
      return false; // Auth errors are not retryable
    }

    // MCP specific exceptions
    if (exception is MCPConnectionException) {
      return true; // Connection issues are retryable
    }

    if (exception is MCPToolException) {
      return exception.code ==
          'TOOL_EXECUTION_TIMEOUT'; // Only timeout is retryable
    }

    if (exception is MCPQuotaException) {
      return true; // Quota limits are temporary
    }

    // Default: don't retry unknown exceptions
    return false;
  }

  /// Generate a unique operation ID
  String _generateOperationId() {
    return 'op_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}';
  }

  /// Circuit breaker implementation
  bool _isCircuitOpen(String operationId) {
    final state = _circuitBreakers[operationId];
    if (state == null) return false;

    final now = DateTime.now();

    // If circuit is open, check if timeout has passed
    if (state.isOpen && now.isAfter(state.nextAttemptTime)) {
      state.isOpen = false;
      state.consecutiveFailures = 0;
      developer.log('Circuit breaker reset for: $operationId',
          name: 'RetryService');
    }

    return state.isOpen;
  }

  void _recordSuccess(String operationId) {
    final state = _circuitBreakers[operationId];
    if (state != null) {
      state.consecutiveFailures = 0;
      state.isOpen = false;
    }
  }

  void _recordFailure(String operationId) {
    final state = _circuitBreakers.putIfAbsent(
      operationId,
      () => CircuitBreakerState(),
    );

    state.consecutiveFailures++;

    // Open circuit if failure threshold is reached
    if (state.consecutiveFailures >= 5) {
      state.isOpen = true;
      state.nextAttemptTime = DateTime.now().add(const Duration(minutes: 1));

      developer.log(
        'Circuit breaker opened for: $operationId (${state.consecutiveFailures} failures)',
        name: 'RetryService',
      );
    }
  }

  /// Clear circuit breaker state (useful for testing)
  void clearCircuitBreakers() {
    _circuitBreakers.clear();
  }

  /// Clear pending requests (useful for testing)
  void clearPendingRequests() {
    _pendingRequests.clear();
  }
}

/// Circuit breaker state
class CircuitBreakerState {
  int consecutiveFailures = 0;
  bool isOpen = false;
  DateTime nextAttemptTime = DateTime.now();
}

/// Exception thrown when all retry attempts fail
class RetryException implements Exception {
  final String message;
  final String operationId;
  final int attempts;
  final Exception? lastException;

  RetryException({
    required this.message,
    required this.operationId,
    required this.attempts,
    this.lastException,
  });

  @override
  String toString() {
    return 'RetryException: $message (operation: $operationId, attempts: $attempts)';
  }
}

/// Retry configuration for specific operations
class RetryConfig {
  final int maxRetries;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;
  final bool enableCircuitBreaker;
  final bool enableDeduplication;
  final List<Type>? retryableExceptions;
  final List<Type>? nonRetryableExceptions;

  const RetryConfig({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 1000),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 30),
    this.enableCircuitBreaker = true,
    this.enableDeduplication = false,
    this.retryableExceptions,
    this.nonRetryableExceptions,
  });

  /// Configuration for MATP API calls
  static const RetryConfig matp = RetryConfig(
    maxRetries: 3,
    initialDelay: Duration(milliseconds: 500),
    backoffMultiplier: 2.0,
    enableCircuitBreaker: true,
    enableDeduplication: true,
  );

  /// Configuration for MCP tool calls
  static const RetryConfig mcp = RetryConfig(
    maxRetries: 2,
    initialDelay: Duration(milliseconds: 1000),
    backoffMultiplier: 1.5,
    enableCircuitBreaker: true,
    enableDeduplication: true,
  );

  /// Configuration for critical operations (no retries)
  static const RetryConfig critical = RetryConfig(
    maxRetries: 0,
    enableCircuitBreaker: false,
    enableDeduplication: false,
  );
}
