import '../services/api_exception.dart';

/// Comprehensive error hierarchy for MCP (Model Context Protocol) exceptions
///
/// This file provides specialized exception classes for different types
/// of errors that can occur in the MCP system communication.

/// Base class for all MCP-specific exceptions
abstract class MCPException extends ApiException {
  MCPException({
    required super.message,
    super.code,
    super.details,
    super.statusCode,
  });
}

/// JSON-RPC protocol related exceptions
class MCPProtocolException extends MCPException {
  final String? rpcMethod;
  final int? requestId;
  final String? rpcVersion;

  MCPProtocolException({
    required super.message,
    super.code,
    this.rpcMethod,
    this.requestId,
    this.rpcVersion,
    super.details,
    super.statusCode,
  });

  factory MCPProtocolException.invalidRequest({
    String? method,
    int? requestId,
  }) {
    return MCPProtocolException(
      message: 'Invalid JSON-RPC request format',
      code: 'INVALID_REQUEST',
      rpcMethod: method,
      requestId: requestId,
      statusCode: 400,
    );
  }

  factory MCPProtocolException.methodNotFound({
    required String method,
    int? requestId,
  }) {
    return MCPProtocolException(
      message: 'JSON-RPC method not found: $method',
      code: 'METHOD_NOT_FOUND',
      rpcMethod: method,
      requestId: requestId,
      statusCode: 404,
    );
  }

  factory MCPProtocolException.invalidParams({
    required String method,
    required dynamic params,
    int? requestId,
  }) {
    return MCPProtocolException(
      message: 'Invalid parameters for method $method',
      code: 'INVALID_PARAMS',
      rpcMethod: method,
      requestId: requestId,
      details: {
        'method': method,
        'params': params,
      },
      statusCode: 400,
    );
  }

  factory MCPProtocolException.parseError({
    String? rawData,
  }) {
    return MCPProtocolException(
      message: 'JSON-RPC parse error - invalid JSON',
      code: 'PARSE_ERROR',
      details: {
        'raw_data': rawData,
      },
      statusCode: 400,
    );
  }
}

/// MCP tool execution related exceptions
class MCPToolException extends MCPException {
  final String? toolName;
  final Map<String, dynamic>? toolArguments;
  final String? executionPhase;

  MCPToolException({
    required super.message,
    super.code,
    this.toolName,
    this.toolArguments,
    this.executionPhase,
    super.details,
    super.statusCode,
  });

  factory MCPToolException.toolNotFound({
    required String toolName,
  }) {
    return MCPToolException(
      message: 'MCP tool not found: $toolName',
      code: 'TOOL_NOT_FOUND',
      toolName: toolName,
      statusCode: 404,
    );
  }

  factory MCPToolException.executionFailed({
    required String toolName,
    required String reason,
    Map<String, dynamic>? arguments,
    String? phase,
  }) {
    return MCPToolException(
      message: 'Tool execution failed: $toolName - $reason',
      code: 'TOOL_EXECUTION_FAILED',
      toolName: toolName,
      toolArguments: arguments,
      executionPhase: phase,
      details: {
        'tool': toolName,
        'reason': reason,
        'arguments': arguments,
        'phase': phase,
      },
      statusCode: 500,
    );
  }

  factory MCPToolException.invalidArguments({
    required String toolName,
    required Map<String, dynamic> arguments,
    required List<String> errors,
  }) {
    return MCPToolException(
      message: 'Invalid arguments for tool $toolName: ${errors.join(', ')}',
      code: 'INVALID_TOOL_ARGUMENTS',
      toolName: toolName,
      toolArguments: arguments,
      details: {
        'tool': toolName,
        'arguments': arguments,
        'validation_errors': errors,
      },
      statusCode: 400,
    );
  }

  factory MCPToolException.timeout({
    required String toolName,
    required Duration timeout,
    Map<String, dynamic>? arguments,
  }) {
    return MCPToolException(
      message: 'Tool execution timeout: $toolName (${timeout.inSeconds}s)',
      code: 'TOOL_EXECUTION_TIMEOUT',
      toolName: toolName,
      toolArguments: arguments,
      details: {
        'tool': toolName,
        'timeout_seconds': timeout.inSeconds,
        'arguments': arguments,
      },
      statusCode: 408,
    );
  }
}

/// MCP server connection related exceptions
class MCPConnectionException extends MCPException {
  final String? serverUrl;
  final String? connectionPhase;
  final Duration? timeout;

  MCPConnectionException({
    required super.message,
    super.code,
    this.serverUrl,
    this.connectionPhase,
    this.timeout,
    super.details,
    super.statusCode,
  });

  factory MCPConnectionException.serverUnavailable({
    required String serverUrl,
  }) {
    return MCPConnectionException(
      message: 'MCP server unavailable: $serverUrl',
      code: 'SERVER_UNAVAILABLE',
      serverUrl: serverUrl,
      statusCode: 503,
    );
  }

  factory MCPConnectionException.connectionTimeout({
    required String serverUrl,
    required Duration timeout,
  }) {
    return MCPConnectionException(
      message:
          'Connection timeout to MCP server: $serverUrl (${timeout.inSeconds}s)',
      code: 'CONNECTION_TIMEOUT',
      serverUrl: serverUrl,
      timeout: timeout,
      statusCode: 408,
    );
  }

  factory MCPConnectionException.networkError({
    required String serverUrl,
    required String error,
  }) {
    return MCPConnectionException(
      message: 'Network error connecting to MCP server: $error',
      code: 'NETWORK_ERROR',
      serverUrl: serverUrl,
      details: {
        'network_error': error,
      },
      statusCode: 502,
    );
  }

  factory MCPConnectionException.gatewayError({
    required String gatewayUrl,
    required String error,
  }) {
    return MCPConnectionException(
      message: 'MCP gateway error: $error',
      code: 'GATEWAY_ERROR',
      serverUrl: gatewayUrl,
      details: {
        'gateway_error': error,
      },
      statusCode: 502,
    );
  }
}

/// MCP response parsing related exceptions
class MCPResponseException extends MCPException {
  final String? responseData;
  final String? expectedFormat;
  final int? requestId;

  MCPResponseException({
    required super.message,
    String? code,
    this.responseData,
    this.expectedFormat,
    this.requestId,
    super.details,
  }) : super(
          code: code ?? 'RESPONSE_ERROR',
          statusCode: 502,
        );

  factory MCPResponseException.invalidFormat({
    required String responseData,
    String? expectedFormat,
    int? requestId,
  }) {
    return MCPResponseException(
      message:
          'Invalid MCP response format${expectedFormat != null ? ', expected $expectedFormat' : ''}',
      code: 'INVALID_RESPONSE_FORMAT',
      responseData: responseData,
      expectedFormat: expectedFormat,
      requestId: requestId,
      details: {
        'response_data': responseData,
        'expected_format': expectedFormat,
      },
    );
  }

  factory MCPResponseException.emptyResponse({
    int? requestId,
  }) {
    return MCPResponseException(
      message: 'Empty response from MCP server',
      code: 'EMPTY_RESPONSE',
      requestId: requestId,
    );
  }

  factory MCPResponseException.missingResult({
    required String responseData,
    int? requestId,
  }) {
    return MCPResponseException(
      message: 'MCP response missing result field',
      code: 'MISSING_RESULT',
      responseData: responseData,
      requestId: requestId,
      details: {
        'response_data': responseData,
      },
    );
  }
}

/// MCP rate limiting and quota exceptions
class MCPQuotaException extends MCPException {
  final int? requestsRemaining;
  final Duration? resetTime;
  final String? quotaType;

  MCPQuotaException({
    required super.message,
    String? code,
    this.requestsRemaining,
    this.resetTime,
    this.quotaType,
    super.details,
  }) : super(
          code: code ?? 'QUOTA_EXCEEDED',
          statusCode: 429,
        );

  factory MCPQuotaException.dailyLimitExceeded({
    int? remaining,
    Duration? resetTime,
  }) {
    return MCPQuotaException(
      message: 'Daily MCP request limit exceeded',
      code: 'DAILY_LIMIT_EXCEEDED',
      requestsRemaining: remaining,
      resetTime: resetTime,
      quotaType: 'daily',
      details: {
        'requests_remaining': remaining,
        'reset_time': resetTime?.toString(),
        'quota_type': 'daily',
      },
    );
  }

  factory MCPQuotaException.rateLimitExceeded({
    int? remaining,
    Duration? resetTime,
  }) {
    return MCPQuotaException(
      message: 'MCP rate limit exceeded',
      code: 'RATE_LIMIT_EXCEEDED',
      requestsRemaining: remaining,
      resetTime: resetTime,
      quotaType: 'rate',
      details: {
        'requests_remaining': remaining,
        'reset_time': resetTime?.toString(),
        'quota_type': 'rate',
      },
    );
  }
}

/// MCP authentication and authorization exceptions
class MCPAuthException extends MCPException {
  final String? authType;
  final String? requiredPermission;

  MCPAuthException({
    required super.message,
    super.code,
    this.authType,
    this.requiredPermission,
    super.details,
    super.statusCode,
  });

  factory MCPAuthException.unauthorized({
    String? authType,
  }) {
    return MCPAuthException(
      message: 'Unauthorized access to MCP server',
      code: 'UNAUTHORIZED',
      authType: authType,
      statusCode: 401,
    );
  }

  factory MCPAuthException.forbidden({
    String? requiredPermission,
  }) {
    return MCPAuthException(
      message:
          'Forbidden: insufficient permissions for MCP operation${requiredPermission != null ? ' (required: $requiredPermission)' : ''}',
      code: 'FORBIDDEN',
      requiredPermission: requiredPermission,
      statusCode: 403,
    );
  }
}

/// MCP fallback and recovery exceptions
class MCPFallbackException extends MCPException {
  final String? fallbackStrategy;
  final List<String>? attemptedMethods;
  final String? originalError;

  MCPFallbackException({
    required super.message,
    String? code,
    this.fallbackStrategy,
    this.attemptedMethods,
    this.originalError,
    super.details,
  }) : super(
          code: code ?? 'FALLBACK_FAILED',
          statusCode: 503,
        );

  factory MCPFallbackException.allFallbacksFailed({
    required List<String> attemptedMethods,
    required String originalError,
  }) {
    return MCPFallbackException(
      message:
          'All MCP fallback methods failed. Original error: $originalError',
      code: 'ALL_FALLBACKS_FAILED',
      attemptedMethods: attemptedMethods,
      originalError: originalError,
      details: {
        'attempted_methods': attemptedMethods,
        'original_error': originalError,
      },
    );
  }

  factory MCPFallbackException.fallbackUnavailable({
    required String strategy,
    required String reason,
  }) {
    return MCPFallbackException(
      message: 'MCP fallback strategy unavailable: $strategy ($reason)',
      code: 'FALLBACK_UNAVAILABLE',
      fallbackStrategy: strategy,
      details: {
        'strategy': strategy,
        'reason': reason,
      },
    );
  }
}
