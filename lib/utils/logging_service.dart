import 'package:flutter/foundation.dart';

/// Logging service for trading operations
///
/// ⚠️ CRITICAL: Proper logging is essential for debugging issues in production
///
/// This service provides structured logging with different levels and contexts.
class LoggingService {
  LoggingService._(); // Private constructor

  static bool _enabled = true;
  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// Enable or disable logging
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Set minimum log level
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// Log a debug message
  static void debug(String message, {Map<String, dynamic>? context}) {
    _log(LogLevel.debug, message, context: context);
  }

  /// Log an info message
  static void info(String message, {Map<String, dynamic>? context}) {
    _log(LogLevel.info, message, context: context);
  }

  /// Log a warning message
  static void warning(String message, {Map<String, dynamic>? context}) {
    _log(LogLevel.warning, message, context: context);
  }

  /// Log an error message
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    _log(
      LogLevel.error,
      message,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Log a critical error (for issues that could cause data loss or financial loss)
  static void critical(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    _log(
      LogLevel.critical,
      message,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Log an API request
  static void logRequest(
    String endpoint,
    Map<String, dynamic> data, {
    String? method = 'POST',
  }) {
    if (!_enabled || _minLevel.index > LogLevel.debug.index) return;

    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] [REQUEST] $method $endpoint');
    debugPrint('  Data: ${_sanitizeData(data)}');
  }

  /// Log an API response
  static void logResponse(
    String endpoint,
    int? statusCode, {
    dynamic data,
    Duration? duration,
  }) {
    if (!_enabled || _minLevel.index > LogLevel.debug.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final durationStr =
        duration != null ? ' (${duration.inMilliseconds}ms)' : '';
    debugPrint('[$timestamp] [RESPONSE] $endpoint - $statusCode$durationStr');

    if (data != null && kDebugMode) {
      debugPrint('  Data: ${_sanitizeData(data)}');
    }
  }

  /// Log an API error
  static void logApiError(
    String endpoint,
    Object error, {
    StackTrace? stackTrace,
    int? statusCode,
  }) {
    if (!_enabled) return;

    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] [API ERROR] $endpoint - $statusCode');
    debugPrint('  Error: $error');

    if (stackTrace != null && kDebugMode) {
      debugPrint('  Stack: $stackTrace');
    }
  }

  /// Log a validation error
  static void logValidationError(
    String field,
    String message, {
    dynamic value,
  }) {
    if (!_enabled || _minLevel.index > LogLevel.warning.index) return;

    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] [VALIDATION ERROR] $field: $message');

    if (value != null && kDebugMode) {
      debugPrint('  Value: $value');
    }
  }

  /// Log a parsing error
  static void logParsingError(
    String field,
    Object error, {
    dynamic value,
  }) {
    if (!_enabled || _minLevel.index > LogLevel.error.index) return;

    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] [PARSING ERROR] $field: $error');

    if (value != null && kDebugMode) {
      debugPrint('  Value: $value');
    }
  }

  /// Log a trading operation (buy/sell)
  static void logTradingOperation(
    String operation,
    String symbol,
    double amount, {
    double? price,
    Map<String, dynamic>? context,
  }) {
    if (!_enabled || _minLevel.index > LogLevel.info.index) return;

    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] [TRADING] $operation $symbol');
    debugPrint('  Amount: $amount');

    if (price != null) {
      debugPrint('  Price: $price');
    }

    if (context != null && kDebugMode) {
      debugPrint('  Context: $context');
    }
  }

  /// Internal logging method
  static void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    if (!_enabled || level.index < _minLevel.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase().padRight(8);

    debugPrint('[$timestamp] [$levelStr] $message');

    if (error != null) {
      debugPrint('  Error: $error');
    }

    if (stackTrace != null && kDebugMode) {
      debugPrint('  Stack: $stackTrace');
    }

    if (context != null && context.isNotEmpty && kDebugMode) {
      debugPrint('  Context: ${_sanitizeData(context)}');
    }
  }

  /// Sanitize sensitive data before logging
  static dynamic _sanitizeData(dynamic data) {
    if (data is Map) {
      final sanitized = <String, dynamic>{};
      data.forEach((key, value) {
        final keyStr = key.toString().toLowerCase();

        // Mask sensitive fields
        if (keyStr.contains('password') ||
            keyStr.contains('secret') ||
            keyStr.contains('token') ||
            keyStr.contains('key') ||
            keyStr.contains('api')) {
          sanitized[key] = '***REDACTED***';
        } else {
          sanitized[key] = _sanitizeData(value);
        }
      });
      return sanitized;
    } else if (data is List) {
      return data.map(_sanitizeData).toList();
    } else {
      return data;
    }
  }
}

/// Log levels
enum LogLevel {
  debug, // Detailed information for debugging
  info, // General informational messages
  warning, // Warning messages
  error, // Error messages
  critical, // Critical errors that could cause financial loss
}
