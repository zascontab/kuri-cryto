import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Enhanced logging service with structured logging
///
/// Features:
/// - Multiple log levels
/// - Structured logging with context
/// - Performance monitoring
/// - Error aggregation
class LoggingService {
  static LoggingService? _instance;
  static LoggingService get instance => _instance ??= LoggingService._();

  LoggingService._();

  final List<LogEntry> _logBuffer = [];
  static const int _maxBufferSize = 1000;

  /// Log with different levels
  void log(
    String message, {
    LogLevel level = LogLevel.info,
    String? tag,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final entry = LogEntry(
      message: message,
      level: level,
      tag: tag ?? 'App',
      context: context,
      error: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
    );

    _addToBuffer(entry);
    _logToConsole(entry);
  }

  /// Convenience methods for different log levels
  void debug(String message, {String? tag, Map<String, dynamic>? context}) {
    log(message, level: LogLevel.debug, tag: tag, context: context);
  }

  void info(String message, {String? tag, Map<String, dynamic>? context}) {
    log(message, level: LogLevel.info, tag: tag, context: context);
  }

  void warning(String message, {String? tag, Map<String, dynamic>? context}) {
    log(message, level: LogLevel.warning, tag: tag, context: context);
  }

  void error(
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      message,
      level: LogLevel.error,
      tag: tag,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log performance metrics
  void performance(
    String operation,
    Duration duration, {
    Map<String, dynamic>? metrics,
  }) {
    log(
      'Performance: $operation took ${duration.inMilliseconds}ms',
      level: LogLevel.info,
      tag: 'Performance',
      context: {
        'operation': operation,
        'duration_ms': duration.inMilliseconds,
        ...?metrics,
      },
    );
  }

  /// Log API calls
  void apiCall(
    String method,
    String endpoint, {
    int? statusCode,
    Duration? duration,
  }) {
    log(
      'API: $method $endpoint ${statusCode != null ? '($statusCode)' : ''}',
      level: statusCode != null && statusCode >= 400
          ? LogLevel.error
          : LogLevel.info,
      tag: 'API',
      context: {
        'method': method,
        'endpoint': endpoint,
        if (statusCode != null) 'status_code': statusCode,
        if (duration != null) 'duration_ms': duration.inMilliseconds,
      },
    );
  }

  /// Get recent logs
  List<LogEntry> getRecentLogs({
    LogLevel? minLevel,
    String? tag,
    int limit = 100,
  }) {
    var filtered = _logBuffer.where((entry) {
      if (minLevel != null && entry.level.index < minLevel.index) {
        return false;
      }
      if (tag != null && entry.tag != tag) {
        return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return filtered.take(limit).toList();
  }

  /// Clear logs
  void clearLogs() {
    _logBuffer.clear();
  }

  /// Private methods
  void _addToBuffer(LogEntry entry) {
    _logBuffer.add(entry);

    if (_logBuffer.length > _maxBufferSize) {
      _logBuffer.removeRange(0, _logBuffer.length - _maxBufferSize);
    }
  }

  void _logToConsole(LogEntry entry) {
    if (kDebugMode) {
      developer.log(
        entry.message,
        name: entry.tag,
        time: entry.timestamp,
        level: _getDeveloperLogLevel(entry.level),
        error: entry.error,
        stackTrace: entry.stackTrace,
      );

      if (entry.context != null && entry.context!.isNotEmpty) {
        developer.log(
          'Context: ${entry.context}',
          name: entry.tag,
          time: entry.timestamp,
        );
      }
    }
  }

  int _getDeveloperLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
}

/// Log entry data class
class LogEntry {
  final String message;
  final LogLevel level;
  final String tag;
  final Map<String, dynamic>? context;
  final Object? error;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  LogEntry({
    required this.message,
    required this.level,
    required this.tag,
    this.context,
    this.error,
    this.stackTrace,
    required this.timestamp,
  });

  @override
  String toString() {
    final buffer = StringBuffer();

    buffer.write('[${timestamp.toIso8601String()}] ');
    buffer.write('[${level.name.toUpperCase()}] ');
    buffer.write('[$tag] ');
    buffer.write(message);

    if (context != null && context!.isNotEmpty) {
      buffer.write(' | Context: $context');
    }

    if (error != null) {
      buffer.write(' | Error: $error');
    }

    return buffer.toString();
  }
}

/// Log levels
enum LogLevel {
  debug,
  info,
  warning,
  error,
}
