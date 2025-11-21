import 'package:dio/dio.dart';

/// Base API Exception
class ApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final dynamic details;

  ApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ApiException: $message');
    if (code != null) buffer.write(' (Code: $code)');
    if (statusCode != null) buffer.write(' (Status: $statusCode)');
    if (details != null) buffer.write('\nDetails: $details');
    return buffer.toString();
  }

  /// Create ApiException from error response
  factory ApiException.fromResponse(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ApiException(
        message: data['error'] ?? 'Unknown error occurred',
        code: data['code'],
        statusCode: response.statusCode,
        details: data['details'],
      );
    }
    return ApiException(
      message: 'Invalid error response format',
      statusCode: response.statusCode,
    );
  }

  /// Create ApiException from DioException
  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return TimeoutException(
          message: 'Connection timeout',
          originalError: error,
        );
      case DioExceptionType.sendTimeout:
        return TimeoutException(
          message: 'Send timeout',
          originalError: error,
        );
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'Receive timeout',
          originalError: error,
        );
      case DioExceptionType.badResponse:
        if (error.response != null) {
          return ApiException.fromResponse(error.response!);
        }
        return ServerException(
          message: 'Server error: ${error.message}',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return RequestCancelledException(
          message: 'Request was cancelled',
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Network connection failed',
          originalError: error,
        );
      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'SSL certificate error',
          originalError: error,
        );
      case DioExceptionType.unknown:
      default:
        return NetworkException(
          message: error.message ?? 'Unknown network error',
          originalError: error,
        );
    }
  }
}

/// Network-related exceptions
class NetworkException extends ApiException {
  final DioException? originalError;

  NetworkException({
    required super.message,
    super.code = 'NETWORK_ERROR',
    this.originalError,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// Server-related exceptions (5xx errors)
class ServerException extends ApiException {
  ServerException({
    required super.message,
    super.code = 'SERVER_ERROR',
    super.statusCode,
    super.details,
  });

  @override
  String toString() => 'ServerException: $message';
}

/// Timeout exceptions
class TimeoutException extends ApiException {
  final DioException? originalError;

  TimeoutException({
    required super.message,
    super.code = 'TIMEOUT',
    this.originalError,
  });

  @override
  String toString() => 'TimeoutException: $message';
}

/// Request cancelled exception
class RequestCancelledException extends ApiException {
  RequestCancelledException({
    required super.message,
    super.code = 'REQUEST_CANCELLED',
  });

  @override
  String toString() => 'RequestCancelledException: $message';
}

/// Unauthorized exception (401)
class UnauthorizedException extends ApiException {
  UnauthorizedException({
    super.message = 'Unauthorized access',
    super.code = 'UNAUTHORIZED',
    super.statusCode = 401,
  });

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Forbidden exception (403)
class ForbiddenException extends ApiException {
  ForbiddenException({
    super.message = 'Access forbidden',
    super.code = 'FORBIDDEN',
    super.statusCode = 403,
  });

  @override
  String toString() => 'ForbiddenException: $message';
}

/// Not found exception (404)
class NotFoundException extends ApiException {
  NotFoundException({
    super.message = 'Resource not found',
    super.code = 'NOT_FOUND',
    super.statusCode = 404,
  });

  @override
  String toString() => 'NotFoundException: $message';
}

/// Rate limit exception (429)
class RateLimitException extends ApiException {
  final int? retryAfter;

  RateLimitException({
    super.message = 'Rate limit exceeded',
    super.code = 'RATE_LIMIT_EXCEEDED',
    super.statusCode = 429,
    this.retryAfter,
  });

  @override
  String toString() {
    final buffer = StringBuffer('RateLimitException: $message');
    if (retryAfter != null) {
      buffer.write(' (Retry after: ${retryAfter}s)');
    }
    return buffer.toString();
  }
}

/// Trading-specific exceptions
class InsufficientBalanceException extends ApiException {
  final double? required;
  final double? available;

  InsufficientBalanceException({
    super.message = 'Insufficient balance for trade',
    super.code = 'INSUFFICIENT_BALANCE',
    this.required,
    this.available,
  });

  @override
  String toString() {
    final buffer = StringBuffer('InsufficientBalanceException: $message');
    if (required != null && available != null) {
      buffer.write(' (Required: $required, Available: $available)');
    }
    return buffer.toString();
  }
}

/// Risk limit exceeded exception
class RiskLimitExceededException extends ApiException {
  final double? currentValue;
  final double? maxValue;

  RiskLimitExceededException({
    super.message = 'Risk limit exceeded',
    super.code = 'RISK_LIMIT_EXCEEDED',
    this.currentValue,
    this.maxValue,
  });

  @override
  String toString() {
    final buffer = StringBuffer('RiskLimitExceededException: $message');
    if (currentValue != null && maxValue != null) {
      buffer.write(' (Current: $currentValue, Max: $maxValue)');
    }
    return buffer.toString();
  }
}

/// Kill switch active exception
class KillSwitchActiveException extends ApiException {
  final String? reason;
  final DateTime? activatedAt;

  KillSwitchActiveException({
    super.message = 'Trading is disabled - kill switch active',
    super.code = 'KILL_SWITCH_ACTIVE',
    this.reason,
    this.activatedAt,
  });

  @override
  String toString() {
    final buffer = StringBuffer('KillSwitchActiveException: $message');
    if (reason != null) buffer.write('\nReason: $reason');
    if (activatedAt != null) buffer.write('\nActivated at: $activatedAt');
    return buffer.toString();
  }
}

/// Position not found exception
class PositionNotFoundException extends ApiException {
  final String? positionId;

  PositionNotFoundException({
    super.message = 'Position not found',
    super.code = 'POSITION_NOT_FOUND',
    super.statusCode = 404,
    this.positionId,
  });

  @override
  String toString() {
    final buffer = StringBuffer('PositionNotFoundException: $message');
    if (positionId != null) buffer.write(' (Position ID: $positionId)');
    return buffer.toString();
  }
}

/// Strategy not found exception
class StrategyNotFoundException extends ApiException {
  final String? strategyName;

  StrategyNotFoundException({
    super.message = 'Strategy not found',
    super.code = 'STRATEGY_NOT_FOUND',
    super.statusCode = 404,
    this.strategyName,
  });

  @override
  String toString() {
    final buffer = StringBuffer('StrategyNotFoundException: $message');
    if (strategyName != null) buffer.write(' (Strategy: $strategyName)');
    return buffer.toString();
  }
}

/// Engine not running exception
class EngineNotRunningException extends ApiException {
  EngineNotRunningException({
    super.message = 'Scalping engine is not running',
    super.code = 'ENGINE_NOT_RUNNING',
  });

  @override
  String toString() => 'EngineNotRunningException: $message';
}

/// Order execution failed exception
class OrderExecutionException extends ApiException {
  final String? orderId;

  OrderExecutionException({
    super.message = 'Order execution failed',
    super.code = 'ORDER_FAILED',
    this.orderId,
  });

  @override
  String toString() {
    final buffer = StringBuffer('OrderExecutionException: $message');
    if (orderId != null) buffer.write(' (Order ID: $orderId)');
    return buffer.toString();
  }
}

/// Market closed exception
class MarketClosedException extends ApiException {
  final String? market;

  MarketClosedException({
    super.message = 'Market is closed',
    super.code = 'MARKET_CLOSED',
    this.market,
  });

  @override
  String toString() {
    final buffer = StringBuffer('MarketClosedException: $message');
    if (market != null) buffer.write(' (Market: $market)');
    return buffer.toString();
  }
}

/// Validation exception
class ValidationException extends ApiException {
  final Map<String, List<String>>? fieldErrors;

  ValidationException({
    super.message = 'Validation failed',
    super.code = 'VALIDATION_ERROR',
    super.statusCode = 400,
    this.fieldErrors,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ValidationException: $message');
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      buffer.write('\nField errors:');
      fieldErrors!.forEach((field, errors) {
        buffer.write('\n  $field: ${errors.join(", ")}');
      });
    }
    return buffer.toString();
  }
}
