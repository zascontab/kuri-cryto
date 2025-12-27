import 'dart:math';
import 'error_handler.dart';

/// Simple retry helper with exponential backoff
class RetryHelper {
  /// Execute operation with retry logic
  static Future<T> execute<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;
    dynamic lastError;

    while (attempt <= maxRetries) {
      try {
        return await operation();
      } catch (error) {
        lastError = error;
        attempt++;

        // Check if we should retry
        final shouldRetryError =
            shouldRetry?.call(error) ?? _defaultShouldRetry(error);

        if (attempt > maxRetries || !shouldRetryError) {
          break;
        }

        // Wait before retry with jitter
        final jitteredDelay = _addJitter(delay);
        await Future.delayed(jitteredDelay);

        // Increase delay for next attempt
        delay = Duration(
          milliseconds: (delay.inMilliseconds * backoffMultiplier).round(),
        );
      }
    }

    throw Exception(
        'Operation failed after $maxRetries retries: ${getErrorMessage(lastError)}');
  }

  static bool _defaultShouldRetry(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    // Don't retry client errors
    if (errorStr.contains('400') ||
        errorStr.contains('401') ||
        errorStr.contains('403') ||
        errorStr.contains('404')) {
      return false;
    }

    // Retry network errors and server errors
    return errorStr.contains('timeout') ||
        errorStr.contains('connection') ||
        errorStr.contains('network') ||
        errorStr.contains('500') ||
        errorStr.contains('502') ||
        errorStr.contains('503') ||
        errorStr.contains('504');
  }

  static Duration _addJitter(Duration baseDelay) {
    final random = Random();
    final jitterMs = random.nextInt(1000); // 0-1000ms jitter
    return Duration(milliseconds: baseDelay.inMilliseconds + jitterMs);
  }
}
