/// Custom exceptions for Trading API operations
///
/// This file contains all custom exception classes used throughout
/// the Trading MCP Server integration for proper error handling.
library;

/// Base exception class for all Trading API related errors
abstract class TradingApiException implements Exception {
  /// Human-readable error message
  final String message;

  /// Optional additional details about the error
  final String? details;

  /// HTTP status code if applicable
  final int? statusCode;

  /// Original error that caused this exception (if any)
  final Object? originalError;

  /// Stack trace from the original error (if any)
  final StackTrace? originalStackTrace;

  const TradingApiException(
    this.message, {
    this.details,
    this.statusCode,
    this.originalError,
    this.originalStackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('$runtimeType: $message');

    if (statusCode != null) {
      buffer.write(' (Status: $statusCode)');
    }

    if (details != null) {
      buffer.write('\nDetails: $details');
    }

    if (originalError != null) {
      buffer.write('\nCaused by: $originalError');
    }

    return buffer.toString();
  }

  /// Creates a user-friendly error message suitable for display in UI
  String get userFriendlyMessage {
    switch (runtimeType) {
      case NetworkException:
        return 'Error de conexión. Verifica tu conexión a internet.';
      case ServerException:
        return 'Error del servidor. Inténtalo de nuevo más tarde.';
      case ValidationException:
        return 'Datos inválidos. $message';
      case AuthenticationException:
        return 'Error de autenticación. Verifica tus credenciales.';
      case RateLimitException:
        return 'Demasiadas solicitudes. Espera un momento e inténtalo de nuevo.';
      case TimeoutException:
        return 'La operación tardó demasiado. Inténtalo de nuevo.';
      default:
        return message;
    }
  }

  /// Whether this error is recoverable (user can retry)
  bool get isRecoverable {
    switch (runtimeType) {
      case NetworkException:
      case TimeoutException:
      case ServerException:
      case RateLimitException:
        return true;
      case ValidationException:
      case AuthenticationException:
      case ParsingException:
        return false;
      default:
        return false;
    }
  }
}

/// Exception thrown when there are network connectivity issues
class NetworkException extends TradingApiException {
  const NetworkException(
    super.message, {
    super.details,
    super.statusCode,
    super.originalError,
    super.originalStackTrace,
  });

  /// Creates a NetworkException from a DioException
  factory NetworkException.fromDioError(Object error) {
    return NetworkException(
      'Network connection failed',
      details: error.toString(),
      originalError: error,
    );
  }

  /// Creates a NetworkException for connection timeout
  factory NetworkException.timeout() {
    return const NetworkException(
      'Connection timeout',
      details: 'The request took too long to complete',
    );
  }

  /// Creates a NetworkException for no internet connection
  factory NetworkException.noConnection() {
    return const NetworkException(
      'No internet connection',
      details: 'Please check your internet connection and try again',
    );
  }
}

/// Exception thrown when the server returns an error response
class ServerException extends TradingApiException {
  const ServerException(
    super.message, {
    super.details,
    super.statusCode,
    super.originalError,
    super.originalStackTrace,
  });

  /// Creates a ServerException from HTTP response
  factory ServerException.fromResponse(int statusCode, String? body) {
    String message;
    switch (statusCode) {
      case 400:
        message = 'Bad request';
        break;
      case 401:
        message = 'Unauthorized';
        break;
      case 403:
        message = 'Forbidden';
        break;
      case 404:
        message = 'Not found';
        break;
      case 500:
        message = 'Internal server error';
        break;
      case 502:
        message = 'Bad gateway';
        break;
      case 503:
        message = 'Service unavailable';
        break;
      default:
        message = 'Server error';
    }

    return ServerException(
      message,
      details: body,
      statusCode: statusCode,
    );
  }

  /// Whether this is a client error (4xx)
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// Whether this is a server error (5xx)
  bool get isServerError => statusCode != null && statusCode! >= 500;
}

/// Exception thrown when data parsing fails
class ParsingException extends TradingApiException {
  /// The data that failed to parse
  final dynamic failedData;

  /// The expected data type or format
  final String? expectedFormat;

  const ParsingException(
    super.message, {
    this.failedData,
    this.expectedFormat,
    super.details,
    super.originalError,
    super.originalStackTrace,
  });

  /// Creates a ParsingException for JSON parsing failures
  factory ParsingException.json(Object error, {dynamic data}) {
    return ParsingException(
      'Failed to parse JSON response',
      failedData: data,
      expectedFormat: 'Valid JSON',
      details: error.toString(),
      originalError: error,
    );
  }

  /// Creates a ParsingException for model parsing failures
  factory ParsingException.model(String modelName, Object error,
      {dynamic data}) {
    return ParsingException(
      'Failed to parse $modelName from response',
      failedData: data,
      expectedFormat: '$modelName format',
      details: error.toString(),
      originalError: error,
    );
  }

  /// Creates a ParsingException for invalid data format
  factory ParsingException.invalidFormat(
      String field, dynamic value, String expected) {
    return ParsingException(
      'Invalid format for field "$field"',
      failedData: value,
      expectedFormat: expected,
      details: 'Expected $expected but got ${value.runtimeType}',
    );
  }
}

/// Exception thrown when input validation fails
class ValidationException extends TradingApiException {
  /// The field that failed validation
  final String? field;

  /// The invalid value
  final dynamic value;

  /// Validation rules that were violated
  final List<String> violatedRules;

  const ValidationException(
    super.message, {
    this.field,
    this.value,
    this.violatedRules = const [],
    super.details,
  });

  /// Creates a ValidationException for required field
  factory ValidationException.required(String field) {
    return ValidationException(
      'Field "$field" is required',
      field: field,
      violatedRules: ['required'],
    );
  }

  /// Creates a ValidationException for invalid range
  factory ValidationException.range(
      String field, dynamic value, num min, num max) {
    return ValidationException(
      'Field "$field" must be between $min and $max',
      field: field,
      value: value,
      violatedRules: ['range'],
      details: 'Value $value is outside the valid range [$min, $max]',
    );
  }

  /// Creates a ValidationException for invalid format
  factory ValidationException.format(
      String field, dynamic value, String expectedFormat) {
    return ValidationException(
      'Field "$field" has invalid format',
      field: field,
      value: value,
      violatedRules: ['format'],
      details: 'Expected format: $expectedFormat',
    );
  }

  /// Creates a ValidationException for invalid symbol
  factory ValidationException.invalidSymbol(String symbol) {
    return ValidationException(
      'Invalid trading symbol',
      field: 'symbol',
      value: symbol,
      violatedRules: ['format'],
      details: 'Symbol must be in format "BASE-QUOTE" (e.g., "BTC-USDT")',
    );
  }
}

/// Exception thrown when authentication fails
class AuthenticationException extends TradingApiException {
  /// The authentication method that failed
  final String? authMethod;

  const AuthenticationException(
    super.message, {
    this.authMethod,
    super.details,
    super.statusCode,
  });

  /// Creates an AuthenticationException for invalid credentials
  factory AuthenticationException.invalidCredentials() {
    return const AuthenticationException(
      'Invalid credentials',
      details: 'The provided credentials are incorrect',
      statusCode: 401,
    );
  }

  /// Creates an AuthenticationException for expired token
  factory AuthenticationException.tokenExpired() {
    return const AuthenticationException(
      'Authentication token expired',
      details: 'Please log in again',
      statusCode: 401,
    );
  }

  /// Creates an AuthenticationException for missing token
  factory AuthenticationException.missingToken() {
    return const AuthenticationException(
      'Authentication token missing',
      details: 'No authentication token provided',
      statusCode: 401,
    );
  }
}

/// Exception thrown when rate limits are exceeded
class RateLimitException extends TradingApiException {
  /// Number of requests made
  final int? requestCount;

  /// Maximum allowed requests
  final int? maxRequests;

  /// Time window for the rate limit (in seconds)
  final int? windowSeconds;

  /// When the rate limit resets
  final DateTime? resetTime;

  const RateLimitException(
    super.message, {
    this.requestCount,
    this.maxRequests,
    this.windowSeconds,
    this.resetTime,
    super.details,
    super.statusCode,
  });

  /// Creates a RateLimitException from response headers
  factory RateLimitException.fromHeaders(Map<String, dynamic> headers) {
    final requestCount =
        int.tryParse(headers['x-ratelimit-used']?.toString() ?? '');
    final maxRequests =
        int.tryParse(headers['x-ratelimit-limit']?.toString() ?? '');
    final resetTime = headers['x-ratelimit-reset'] != null
        ? DateTime.fromMillisecondsSinceEpoch(
            int.parse(headers['x-ratelimit-reset'].toString()) * 1000,
          )
        : null;

    return RateLimitException(
      'Rate limit exceeded',
      requestCount: requestCount,
      maxRequests: maxRequests,
      resetTime: resetTime,
      details: 'Too many requests. Please wait before making more requests.',
      statusCode: 429,
    );
  }

  /// Time until rate limit resets (in seconds)
  int? get secondsUntilReset {
    if (resetTime == null) return null;
    final diff = resetTime!.difference(DateTime.now());
    return diff.inSeconds > 0 ? diff.inSeconds : 0;
  }
}

/// Exception thrown when operations timeout
class TimeoutException extends TradingApiException {
  /// The timeout duration that was exceeded
  final Duration? timeout;

  /// The operation that timed out
  final String? operation;

  const TimeoutException(
    super.message, {
    this.timeout,
    this.operation,
    super.details,
  });

  /// Creates a TimeoutException for request timeout
  factory TimeoutException.request(Duration timeout) {
    return TimeoutException(
      'Request timeout',
      timeout: timeout,
      operation: 'HTTP request',
      details: 'Request took longer than ${timeout.inSeconds} seconds',
    );
  }

  /// Creates a TimeoutException for connection timeout
  factory TimeoutException.connection(Duration timeout) {
    return TimeoutException(
      'Connection timeout',
      timeout: timeout,
      operation: 'Connection establishment',
      details:
          'Failed to establish connection within ${timeout.inSeconds} seconds',
    );
  }
}

/// Exception thrown for bot-specific errors
class BotException extends TradingApiException {
  /// The bot operation that failed
  final String? operation;

  /// Bot configuration that caused the error
  final Map<String, dynamic>? botConfig;

  const BotException(
    super.message, {
    this.operation,
    this.botConfig,
    super.details,
    super.originalError,
  });

  /// Creates a BotException for bot not running
  factory BotException.notRunning() {
    return const BotException(
      'Bot is not running',
      operation: 'bot_status_check',
      details:
          'The trading bot must be started before performing this operation',
    );
  }

  /// Creates a BotException for invalid configuration
  factory BotException.invalidConfig(String configField, dynamic value) {
    return BotException(
      'Invalid bot configuration',
      operation: 'config_validation',
      details: 'Invalid value for "$configField": $value',
      botConfig: {configField: value},
    );
  }

  /// Creates a BotException for insufficient funds
  factory BotException.insufficientFunds(double required, double available) {
    return BotException(
      'Insufficient funds',
      operation: 'trade_execution',
      details:
          'Required: \$${required.toStringAsFixed(2)}, Available: \$${available.toStringAsFixed(2)}',
    );
  }
}

/// Exception thrown for position-related errors
class PositionException extends TradingApiException {
  /// The position ID that caused the error
  final String? positionId;

  /// The symbol related to the position
  final String? symbol;

  /// The position operation that failed
  final String? operation;

  const PositionException(
    super.message, {
    this.positionId,
    this.symbol,
    this.operation,
    super.details,
  });

  /// Creates a PositionException for position not found
  factory PositionException.notFound(String positionId) {
    return PositionException(
      'Position not found',
      positionId: positionId,
      operation: 'position_lookup',
      details: 'No position found with ID: $positionId',
    );
  }

  /// Creates a PositionException for position already closed
  factory PositionException.alreadyClosed(String positionId) {
    return PositionException(
      'Position already closed',
      positionId: positionId,
      operation: 'position_close',
      details: 'Position $positionId is already closed',
    );
  }

  /// Creates a PositionException for invalid position size
  factory PositionException.invalidSize(double size, String symbol) {
    return PositionException(
      'Invalid position size',
      symbol: symbol,
      operation: 'position_validation',
      details: 'Position size $size is invalid for symbol $symbol',
    );
  }
}

/// Utility class for creating exceptions from common error scenarios
class ExceptionFactory {
  /// Creates appropriate exception from DioException
  static TradingApiException fromDioError(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return TimeoutException.request(const Duration(seconds: 30));
    }

    if (errorString.contains('network') || errorString.contains('connection')) {
      return NetworkException.fromDioError(error);
    }

    return _UnknownException(error.toString(), originalError: error);
  }

  /// Creates appropriate exception from HTTP status code
  static TradingApiException fromStatusCode(int statusCode, String? body) {
    if (statusCode == 429) {
      return RateLimitException.fromHeaders({});
    }

    if (statusCode == 401 || statusCode == 403) {
      return AuthenticationException.invalidCredentials();
    }

    return ServerException.fromResponse(statusCode, body);
  }

  /// Creates exception for parsing errors
  static ParsingException parsing(String context, Object error,
      {dynamic data}) {
    if (context.toLowerCase().contains('json')) {
      return ParsingException.json(error, data: data);
    }

    return ParsingException.model(context, error, data: data);
  }
}



class _UnknownException extends TradingApiException {
  const _UnknownException(super.message, {super.originalError});
}
