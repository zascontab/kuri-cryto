import '../services/api_exception.dart';

/// Comprehensive error hierarchy for MATP system exceptions
///
/// This file provides specialized exception classes for different types
/// of errors that can occur in the MATP (Multi-Asset Trading Platform) system.

/// Base class for all MATP-specific exceptions
abstract class MATPException extends ApiException {
  MATPException({
    required super.message,
    super.code,
    super.details,
    super.statusCode,
  });
}

/// Authentication and authorization related exceptions
class MATPAuthException extends MATPException {
  final String? tokenType;
  final DateTime? expiry;

  MATPAuthException({
    required super.message,
    super.code,
    this.tokenType,
    this.expiry,
    super.details,
    super.statusCode,
  });

  factory MATPAuthException.tokenExpired({
    String? tokenType = 'JWT',
    DateTime? expiry,
  }) {
    return MATPAuthException(
      message: 'Authentication token has expired',
      code: 'TOKEN_EXPIRED',
      tokenType: tokenType,
      expiry: expiry,
      statusCode: 401,
    );
  }

  factory MATPAuthException.invalidToken({
    String? tokenType = 'JWT',
  }) {
    return MATPAuthException(
      message: 'Invalid authentication token',
      code: 'INVALID_TOKEN',
      tokenType: tokenType,
      statusCode: 401,
    );
  }

  factory MATPAuthException.insufficientLevel({
    required int currentLevel,
    required int requiredLevel,
  }) {
    return MATPAuthException(
      message:
          'Insufficient access level: required $requiredLevel, current $currentLevel',
      code: 'INSUFFICIENT_ACCESS_LEVEL',
      details: {
        'current_level': currentLevel,
        'required_level': requiredLevel,
      },
      statusCode: 403,
    );
  }

  factory MATPAuthException.noRefreshToken() {
    return MATPAuthException(
      message: 'No refresh token available for token refresh',
      code: 'NO_REFRESH_TOKEN',
      statusCode: 401,
    );
  }

  factory MATPAuthException.invalidRefreshToken() {
    return MATPAuthException(
      message: 'Invalid or expired refresh token',
      code: 'INVALID_REFRESH_TOKEN',
      statusCode: 401,
    );
  }

  factory MATPAuthException.refreshFailed({
    int? statusCode,
    String? message,
  }) {
    return MATPAuthException(
      message: message ?? 'Token refresh failed',
      code: 'REFRESH_FAILED',
      statusCode: statusCode ?? 500,
    );
  }
}

/// Rate limiting related exceptions
class MATPRateLimitException extends MATPException {
  final int? retryAfterSeconds;
  final DateTime? resetTime;
  final int? requestsRemaining;
  final int? requestsLimit;

  MATPRateLimitException({
    required super.message,
    String? code,
    this.retryAfterSeconds,
    this.resetTime,
    this.requestsRemaining,
    this.requestsLimit,
    super.details,
  }) : super(
          code: code ?? 'RATE_LIMIT_EXCEEDED',
          statusCode: 429,
        );

  factory MATPRateLimitException.fromHeaders(Map<String, dynamic> headers) {
    final retryAfter = headers['X-RateLimit-Reset'];
    final resetTime = headers['X-RateLimit-Reset-Time'];
    final remaining = headers['X-RateLimit-Remaining'];
    final limit = headers['X-RateLimit-Limit'];

    return MATPRateLimitException(
      message: 'Rate limit exceeded. Please wait before making more requests.',
      retryAfterSeconds:
          retryAfter != null ? int.tryParse(retryAfter.toString()) : null,
      resetTime:
          resetTime != null ? DateTime.tryParse(resetTime.toString()) : null,
      requestsRemaining:
          remaining != null ? int.tryParse(remaining.toString()) : null,
      requestsLimit: limit != null ? int.tryParse(limit.toString()) : null,
      details: {
        'retry_after': retryAfter,
        'reset_time': resetTime,
        'requests_remaining': remaining,
        'requests_limit': limit,
      },
    );
  }
}

/// Kong Gateway specific exceptions
class MATPGatewayException extends MATPException {
  final String? gatewayError;
  final String? upstreamService;

  MATPGatewayException({
    required super.message,
    super.code,
    this.gatewayError,
    this.upstreamService,
    super.details,
    super.statusCode,
  });

  factory MATPGatewayException.serviceUnavailable({
    String? upstreamService,
  }) {
    return MATPGatewayException(
      message: 'Gateway service unavailable',
      code: 'GATEWAY_SERVICE_UNAVAILABLE',
      upstreamService: upstreamService,
      statusCode: 503,
    );
  }

  factory MATPGatewayException.timeout({
    String? upstreamService,
  }) {
    return MATPGatewayException(
      message: 'Gateway timeout - upstream service not responding',
      code: 'GATEWAY_TIMEOUT',
      upstreamService: upstreamService,
      statusCode: 504,
    );
  }
}

/// Trading operation specific exceptions
class MATPTradingException extends MATPException {
  final String? symbol;
  final String? operation;
  final double? amount;

  MATPTradingException({
    required super.message,
    super.code,
    this.symbol,
    this.operation,
    this.amount,
    super.details,
    super.statusCode,
  });

  factory MATPTradingException.insufficientBalance({
    required String symbol,
    required double requested,
    required double available,
  }) {
    return MATPTradingException(
      message:
          'Insufficient balance for $symbol: requested $requested, available $available',
      code: 'INSUFFICIENT_BALANCE',
      symbol: symbol,
      amount: requested,
      details: {
        'requested': requested,
        'available': available,
      },
      statusCode: 400,
    );
  }

  factory MATPTradingException.invalidOrderSize({
    required String symbol,
    required double size,
    required double minSize,
    required double maxSize,
  }) {
    return MATPTradingException(
      message:
          'Invalid order size for $symbol: $size (min: $minSize, max: $maxSize)',
      code: 'INVALID_ORDER_SIZE',
      symbol: symbol,
      amount: size,
      details: {
        'size': size,
        'min_size': minSize,
        'max_size': maxSize,
      },
      statusCode: 400,
    );
  }

  factory MATPTradingException.marketClosed({
    required String symbol,
  }) {
    return MATPTradingException(
      message: 'Market is closed for $symbol',
      code: 'MARKET_CLOSED',
      symbol: symbol,
      statusCode: 400,
    );
  }
}

/// Risk management related exceptions
class MATPRiskException extends MATPException {
  final double? riskLevel;
  final double? maxRisk;
  final String? riskType;

  MATPRiskException({
    required super.message,
    super.code,
    this.riskLevel,
    this.maxRisk,
    this.riskType,
    super.details,
    super.statusCode,
  });

  factory MATPRiskException.riskLimitExceeded({
    required double currentRisk,
    required double maxRisk,
    String riskType = 'position',
  }) {
    return MATPRiskException(
      message: 'Risk limit exceeded: $currentRisk > $maxRisk ($riskType)',
      code: 'RISK_LIMIT_EXCEEDED',
      riskLevel: currentRisk,
      maxRisk: maxRisk,
      riskType: riskType,
      details: {
        'current_risk': currentRisk,
        'max_risk': maxRisk,
        'risk_type': riskType,
      },
      statusCode: 400,
    );
  }

  factory MATPRiskException.dailyLossLimitReached({
    required double currentLoss,
    required double dailyLimit,
  }) {
    return MATPRiskException(
      message: 'Daily loss limit reached: $currentLoss (limit: $dailyLimit)',
      code: 'DAILY_LOSS_LIMIT_REACHED',
      riskLevel: currentLoss,
      maxRisk: dailyLimit,
      riskType: 'daily_loss',
      statusCode: 400,
    );
  }
}

/// Data validation related exceptions
class MATPValidationException extends MATPException {
  final String? field;
  final dynamic value;
  final List<String>? validationErrors;

  MATPValidationException({
    required super.message,
    String? code,
    this.field,
    this.value,
    this.validationErrors,
    super.details,
  }) : super(
          code: code ?? 'VALIDATION_ERROR',
          statusCode: 400,
        );

  factory MATPValidationException.invalidField({
    required String field,
    required dynamic value,
    String? reason,
  }) {
    return MATPValidationException(
      message:
          'Invalid value for field "$field": $value${reason != null ? ' ($reason)' : ''}',
      code: 'INVALID_FIELD_VALUE',
      field: field,
      value: value,
      details: {
        'field': field,
        'value': value,
        'reason': reason,
      },
    );
  }

  factory MATPValidationException.multipleErrors({
    required List<String> errors,
  }) {
    return MATPValidationException(
      message: 'Multiple validation errors: ${errors.join(', ')}',
      code: 'MULTIPLE_VALIDATION_ERRORS',
      validationErrors: errors,
      details: {
        'errors': errors,
      },
    );
  }
}

/// Configuration related exceptions
class MATPConfigException extends MATPException {
  final String? configKey;
  final String? configSection;

  MATPConfigException({
    required super.message,
    String? code,
    this.configKey,
    this.configSection,
    super.details,
  }) : super(
          code: code ?? 'CONFIG_ERROR',
          statusCode: 500,
        );

  factory MATPConfigException.missingConfig({
    required String key,
    String? section,
  }) {
    return MATPConfigException(
      message:
          'Missing configuration: $key${section != null ? ' in section $section' : ''}',
      code: 'MISSING_CONFIG',
      configKey: key,
      configSection: section,
    );
  }

  factory MATPConfigException.invalidConfig({
    required String key,
    required dynamic value,
    String? expectedType,
  }) {
    return MATPConfigException(
      message:
          'Invalid configuration for $key: $value${expectedType != null ? ' (expected $expectedType)' : ''}',
      code: 'INVALID_CONFIG',
      configKey: key,
      details: {
        'key': key,
        'value': value,
        'expected_type': expectedType,
      },
    );
  }
}
