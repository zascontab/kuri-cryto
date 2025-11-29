import 'dart:math';
import 'package:dio/dio.dart';
import 'logging_service.dart';

/// Retry helper for network requests
///
/// ⚠️ CRITICAL: Network failures are common. Always retry with backoff.
///
/// This helper implements exponential backoff with jitter to avoid thundering herd.
class RetryHelper {
  RetryHelper._(); // Private constructor

  /// Retry a request with exponential backoff
  ///
  /// Parameters:
  /// - [request]: The function to retry
  /// - [maxAttempts]: Maximum number of attempts (default: 3)
  /// - [initialDelay]: Initial delay between retries (default: 1 second)
  /// - [maxDelay]: Maximum delay between retries (default: 10 seconds)
  /// - [shouldRetry]: Function to determine if error should be retried
  ///
  /// Returns: Result of the request
  /// Throws: Last error if all attempts fail
  static Future<T> retry<T>(
    Future<T> Function() request, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 10),
    bool Function(Object error)? shouldRetry,
  }) async {
    int attempt = 0;
    Object? lastError;

    while (attempt < maxAttempts) {
      attempt++;

      try {
        LoggingService.debug(
          'Attempting request (attempt $attempt/$maxAttempts)',
        );

        final result = await request();

        if (attempt > 1) {
          LoggingService.info(
            'Request succeeded after $attempt attempts',
          );
        }

        return result;
      } catch (error, stackTrace) {
        lastError = error;

        // Check if we should retry this error
        final retry = shouldRetry?.call(error) ?? _shouldRetryError(error);

        if (!retry) {
          LoggingService.warning(
            'Error is not retryable, failing immediately',
            context: {'error': error.toString()},
          );
          rethrow;
        }

        // If this was the last attempt, rethrow
        if (attempt >= maxAttempts) {
          LoggingService.error(
            'Request failed after $maxAttempts attempts',
            error: error,
            stackTrace: stackTrace,
          );
          rethrow;
        }

        // Calculate delay with exponential backoff and jitter
        final delay = _calculateDelay(
          attempt: attempt,
          initialDelay: initialDelay,
          maxDelay: maxDelay,
        );

        LoggingService.warning(
          'Request failed (attempt $attempt/$maxAttempts), retrying in ${delay.inMilliseconds}ms',
          context: {'error': error.toString()},
        );

        await Future.delayed(delay);
      }
    }

    // This should never be reached, but just in case
    throw lastError ?? Exception('Request failed after $maxAttempts attempts');
  }

  /// Determine if an error should be retried
  static bool _shouldRetryError(Object error) {
    // Retry network errors
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return true;

        case DioExceptionType.badResponse:
          // Retry 5xx errors (server errors)
          final statusCode = error.response?.statusCode;
          if (statusCode != null && statusCode >= 500 && statusCode < 600) {
            return true;
          }
          // Retry 429 (rate limit)
          if (statusCode == 429) {
            return true;
          }
          return false;

        case DioExceptionType.cancel:
          // Don't retry cancelled requests
          return false;

        case DioExceptionType.badCertificate:
        case DioExceptionType.unknown:
          // Retry unknown errors (might be network issues)
          return true;
      }
    }

    // Don't retry other types of errors (validation, parsing, etc.)
    return false;
  }

  /// Calculate delay with exponential backoff and jitter
  ///
  /// Formula: min(maxDelay, initialDelay * 2^(attempt-1) + jitter)
  /// Jitter: random value between 0 and 20% of delay
  static Duration _calculateDelay({
    required int attempt,
    required Duration initialDelay,
    required Duration maxDelay,
  }) {
    // Exponential backoff: 2^(attempt-1)
    final exponentialMs =
        initialDelay.inMilliseconds * pow(2, attempt - 1).toInt();

    // Add jitter (0-20% of delay)
    final jitterMs = Random().nextInt((exponentialMs * 0.2).toInt());
    final delayMs = exponentialMs + jitterMs;

    // Cap at maxDelay
    final cappedMs = min(delayMs, maxDelay.inMilliseconds);

    return Duration(milliseconds: cappedMs);
  }

  /// Retry with custom backoff strategy
  ///
  /// Allows full control over retry behavior
  static Future<T> retryWithStrategy<T>(
    Future<T> Function() request, {
    required RetryStrategy strategy,
  }) async {
    return retry<T>(
      request,
      maxAttempts: strategy.maxAttempts,
      initialDelay: strategy.initialDelay,
      maxDelay: strategy.maxDelay,
      shouldRetry: strategy.shouldRetry,
    );
  }
}

/// Retry strategy configuration
class RetryStrategy {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final bool Function(Object error)? shouldRetry;

  const RetryStrategy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 10),
    this.shouldRetry,
  });

  /// Conservative strategy (fewer retries, longer delays)
  static const conservative = RetryStrategy(
    maxAttempts: 2,
    initialDelay: Duration(seconds: 2),
    maxDelay: Duration(seconds: 15),
  );

  /// Aggressive strategy (more retries, shorter delays)
  static const aggressive = RetryStrategy(
    maxAttempts: 5,
    initialDelay: Duration(milliseconds: 500),
    maxDelay: Duration(seconds: 5),
  );

  /// Critical strategy (for operations that must succeed)
  static const critical = RetryStrategy(
    maxAttempts: 10,
    initialDelay: Duration(seconds: 1),
    maxDelay: Duration(seconds: 30),
  );
}
