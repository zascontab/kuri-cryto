import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'api_exception.dart';
import '../exceptions/mcp_exceptions.dart';
import 'retry_service.dart';
import 'rate_limit_service.dart';
import 'fallback_service.dart';

/// Enhanced MCP Client for JSON-RPC 2.0 communication
///
/// This client implements the Model Context Protocol (MCP) for accessing
/// the 29 verified tools available in the Trading MCP Server.
///
/// Features:
/// - JSON-RPC 2.0 compliant protocol
/// - Gateway routing (port 9090 → 10600)
/// - Enhanced error handling and timeout management
/// - Request ID tracking and logging
/// - Type-safe tool execution
///
/// Usage:
/// ```dart
/// final mcpClient = EnhancedMCPClient();
///
/// final result = await mcpClient.callTool(
///   toolName: 'get_candles',
///   arguments: {
///     'exchange': 'kucoin',
///     'pair': 'BTC-USDT',
///     'interval': '1h',
///     'limit': 100,
///   },
/// );
/// ```
class EnhancedMCPClient {
  late final Dio _dio;
  int _requestId = 0;

  // Enhanced error handling and resilience services
  late final RetryService _retryService;
  late final RateLimitService _rateLimitService;
  late final FallbackService _fallbackService;

  EnhancedMCPClient() {
    _retryService = RetryService(
      maxRetries: 2, // MCP tools are more sensitive, fewer retries
      initialDelay: const Duration(milliseconds: 1000),
      backoffMultiplier: 1.5,
    );
    _rateLimitService = RateLimitService();
    _fallbackService = FallbackService();

    // Setup default fallbacks for MCP tools
    _fallbackService.setupDefaultFallbacks();

    _dio = _createDio();
  }

  /// Create and configure Dio instance for MCP communication
  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.getMCPGatewayUrl(),
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Add MCP-specific interceptors
    dio.interceptors.addAll([
      _MCPLoggingInterceptor(),
      _MCPRetryInterceptor(dio: dio),
      _MCPErrorInterceptor(),
    ]);

    developer.log(
      'Enhanced MCP Client configured with gateway: ${ApiConfig.getMCPGatewayUrl()}',
      name: 'EnhancedMCPClient',
    );

    return dio;
  }

  /// Execute any MCP tool using JSON-RPC 2.0 protocol with enhanced error handling
  ///
  /// [toolName]: Name of the MCP tool (e.g., 'get_candles', 'calculate_rsi')
  /// [arguments]: Tool arguments as key-value pairs
  /// [priority]: Request priority for rate limiting
  /// [enableFallback]: Whether to use fallback mechanisms on failure
  /// [cacheTimeout]: Cache timeout for fallback service
  ///
  /// Returns: Tool execution result
  ///
  /// Throws:
  /// - [MCPException] if tool returns error
  /// - [MCPException] if network error occurs
  Future<Map<String, dynamic>> callTool({
    required String toolName,
    required Map<String, dynamic> arguments,
    RequestPriority priority = RequestPriority.normal,
    bool enableFallback = true,
    Duration? cacheTimeout,
  }) async {
    final operationName = toolName;

    if (enableFallback) {
      return await _fallbackService.executeWithFallback<Map<String, dynamic>>(
        operationName,
        () => _executeToolCall(toolName, arguments, priority),
        cacheTimeout: cacheTimeout ?? const Duration(minutes: 5),
        enableMockData: true,
        mockDataParams: arguments,
      );
    } else {
      return await _executeToolCall(toolName, arguments, priority);
    }
  }

  /// Internal tool execution with rate limiting and retry logic
  Future<Map<String, dynamic>> _executeToolCall(
    String toolName,
    Map<String, dynamic> arguments,
    RequestPriority priority,
  ) async {
    return await _rateLimitService.executeWithRateLimit<Map<String, dynamic>>(
      () => _retryService.executeWithRetry<Map<String, dynamic>>(
        () => _performToolCall(toolName, arguments),
        operationId: 'mcp_tool_$toolName',
        enableCircuitBreaker: true,
        enableDeduplication: true,
        retryableExceptions: [
          MCPConnectionException,
          MCPProtocolException,
        ],
        nonRetryableExceptions: [
          MCPToolException,
          MCPAuthException,
        ],
      ),
      endpoint: _getEndpointForTool(toolName),
      priority: priority,
    );
  }

  /// Perform the actual MCP tool call
  Future<Map<String, dynamic>> _performToolCall(
    String toolName,
    Map<String, dynamic> arguments,
  ) async {
    try {
      _requestId++;

      developer.log(
        'Calling MCP tool: $toolName with args: $arguments',
        name: 'EnhancedMCPClient',
      );

      final jsonRpcRequest = _formatJsonRpcRequest(
        method: 'tools/call',
        params: {
          'name': toolName,
          'arguments': arguments,
        },
        id: _requestId,
      );

      final response = await _dio.post(
        '/api/mcp/tools/execute',
        data: jsonRpcRequest,
      );

      return _parseJsonRpcResponse(response.data);
    } on DioException catch (e) {
      developer.log(
        'MCP tool $toolName failed: ${e.message}',
        name: 'EnhancedMCPClient',
        error: e,
      );
      throw _handleError(e, toolName, arguments);
    } catch (e) {
      developer.log(
        'Unexpected error calling MCP tool $toolName: $e',
        name: 'EnhancedMCPClient',
        error: e,
      );
      /*   throw MCPException(
        message: 'Unexpected error: $e',
        code: 'UNEXPECTED_ERROR',
      ); */

      rethrow;
    }
  }

  /// Format request according to JSON-RPC 2.0 specification
  Map<String, dynamic> _formatJsonRpcRequest({
    required String method,
    required Map<String, dynamic> params,
    required int id,
  }) {
    return {
      'jsonrpc': '2.0',
      'method': method,
      'params': params,
      'id': id,
    };
  }

  /// Parse JSON-RPC 2.0 response and extract result
  Map<String, dynamic> _parseJsonRpcResponse(dynamic responseData) {
    if (responseData == null) {
      throw MCPResponseException.emptyResponse(requestId: _requestId);
    }

    if (responseData is! Map<String, dynamic>) {
      throw MCPResponseException.invalidFormat(
        responseData: responseData.toString(),
        expectedFormat: 'JSON object',
        requestId: _requestId,
      );
    }

    final data = responseData;

    // Check for JSON-RPC error
    if (data['error'] != null) {
      final error = data['error'] as Map<String, dynamic>;
      throw MCPProtocolException(
        message: error['message'] as String? ?? 'MCP Tool error',
        code: error['code']?.toString() ?? 'MCP_ERROR',
        requestId: data['id'],
        details: error['data'],
      );
    }

    // Verify result exists
    if (data['result'] == null) {
      throw MCPResponseException.missingResult(
        responseData: data.toString(),
        requestId: data['id'],
      );
    }

    return data['result'] as Map<String, dynamic>;
  }

  /// Call tool with type-safe result parsing
  Future<T> callToolTyped<T>({
    required String toolName,
    required Map<String, dynamic> arguments,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final result = await callTool(
      toolName: toolName,
      arguments: arguments,
    );
    return fromJson(result);
  }

  /// Call multiple tools in parallel
  Future<List<Map<String, dynamic>>> callMultipleTools(
    List<Map<String, dynamic>> calls,
  ) async {
    final futures = calls.map((call) {
      return callTool(
        toolName: call['tool'] as String,
        arguments: call['args'] as Map<String, dynamic>,
      );
    });

    return Future.wait(futures);
  }

  /// Get next request ID (useful for debugging)
  int get nextRequestId => _requestId + 1;

  /// Reset request ID counter (useful for testing)
  void resetRequestId() {
    _requestId = 0;
  }

  /// Handle Dio errors and convert to MCPException
  MCPException _handleError(
    DioException e, [
    String? toolName,
    Map<String, dynamic>? arguments,
  ]) {
    if (e.response != null) {
      final data = e.response!.data;
      final statusCode = e.response!.statusCode!;

      // Handle string responses (HTML errors, etc.)
      if (data is String) {
        return MCPConnectionException.gatewayError(
          gatewayUrl: ApiConfig.getMCPGatewayUrl(),
          error: 'Server returned HTML/text response: $statusCode',
        );
      }

      // Handle JSON-RPC error responses
      if (data is Map<String, dynamic>) {
        if (data['error'] != null) {
          final error = data['error'];
          final errorCode = error['code']?.toString();

          // Classify error types
          if (errorCode == 'TOOL_NOT_FOUND' || statusCode == 404) {
            return MCPToolException.toolNotFound(
                toolName: toolName ?? 'unknown');
          }

          if (errorCode == 'TOOL_EXECUTION_ERROR' || statusCode == 500) {
            return MCPToolException.executionFailed(
              toolName: toolName ?? 'unknown',
              reason: error['message'] ?? 'Unknown execution error',
              arguments: arguments,
            );
          }

          if (statusCode == 429) {
            return MCPQuotaException.rateLimitExceeded();
          }

          return MCPProtocolException(
            message: error['message'] ?? 'MCP protocol error',
            code: errorCode ?? 'PROTOCOL_ERROR',
            rpcMethod: 'tools/call',
            requestId: data['id'],
            details: error['data'],
            statusCode: statusCode,
          );
        }

        // Handle other structured errors
        if (statusCode == 429) {
          return MCPQuotaException.rateLimitExceeded();
        }

        if (statusCode == 401) {
          return MCPAuthException.unauthorized();
        }

        if (statusCode == 403) {
          return MCPAuthException.forbidden();
        }

        return MCPConnectionException(
          message: data['message'] ?? data['error'] ?? 'Unknown MCP error',
          code: data['code'] ?? 'MCP_ERROR',
          serverUrl: ApiConfig.getMCPGatewayUrl(),
          details: data,
          statusCode: statusCode,
        );
      }
    }

    // Network errors
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return MCPConnectionException.connectionTimeout(
          serverUrl: ApiConfig.getMCPGatewayUrl(),
          timeout: ApiConfig.connectTimeout,
        );
      case DioExceptionType.receiveTimeout:
        if (toolName != null) {
          return MCPToolException.timeout(
            toolName: toolName,
            timeout: ApiConfig.receiveTimeout,
            arguments: arguments,
          );
        }
        return MCPConnectionException.connectionTimeout(
          serverUrl: ApiConfig.getMCPGatewayUrl(),
          timeout: ApiConfig.receiveTimeout,
        );
      case DioExceptionType.connectionError:
        return MCPConnectionException.networkError(
          serverUrl: ApiConfig.getMCPGatewayUrl(),
          error: e.message ?? 'Connection failed',
        );
      default:
        return MCPConnectionException.networkError(
          serverUrl: ApiConfig.getMCPGatewayUrl(),
          error: e.message ?? 'Unknown network error',
        );
    }
  }

  /// Get endpoint classification for rate limiting
  String _getEndpointForTool(String toolName) {
    // Classify tools by their computational intensity
    const analysisTools = [
      'llm_analyze_market',
      'backtest_strategy',
      'optimize_parameters',
      'compare_strategies',
    ];

    if (analysisTools.contains(toolName)) {
      return 'mcp_analysis';
    }

    return 'mcp_tools';
  }

  /// Get fallback service status
  Map<String, dynamic> getFallbackStatus() {
    return _fallbackService.getFallbackStatus();
  }

  /// Get rate limit status for debugging
  Map<String, dynamic> getRateLimitStatus() {
    return {
      'mcp_tools': _rateLimitService.getState('mcp_tools'),
      'mcp_analysis': _rateLimitService.getState('mcp_analysis'),
    };
  }

  /// Clear all state (useful for testing)
  void clearState() {
    _retryService.clearCircuitBreakers();
    _retryService.clearPendingRequests();
    _rateLimitService.clearState();
    _fallbackService.clearCache();
  }

  /// Close the client and clean up resources
  void close({bool force = false}) {
    _dio.close(force: force);
  }
}

/// MCP-specific logging interceptor
class _MCPLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (ApiConfig.enableLogging) {
      developer.log(
        '→ MCP ${options.method} ${options.uri}',
        name: 'EnhancedMCPClient',
      );

      if (ApiConfig.logRequestBody && options.data != null) {
        final data = options.data as Map<String, dynamic>;
        final toolName = data['params']?['name'] ?? 'unknown';
        developer.log(
          '  Tool: $toolName, ID: ${data['id']}',
          name: 'EnhancedMCPClient',
        );
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (ApiConfig.enableLogging) {
      developer.log(
        '← MCP ${response.statusCode} ${response.requestOptions.uri}',
        name: 'EnhancedMCPClient',
      );
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (ApiConfig.enableLogging) {
      developer.log(
        '✗ MCP ${err.requestOptions.method} ${err.requestOptions.uri}',
        name: 'EnhancedMCPClient',
        error: err,
      );
    }
    super.onError(err, handler);
  }
}

/// MCP-specific retry interceptor
class _MCPRetryInterceptor extends Interceptor {
  final Dio dio;

  _MCPRetryInterceptor({required this.dio});

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;

    // Don't retry client errors (4xx)
    if (err.response?.statusCode != null &&
        err.response!.statusCode! >= 400 &&
        err.response!.statusCode! < 500) {
      return handler.next(err);
    }

    // Check retry count
    final retriesLeft =
        options.extra['mcp_retries_left'] as int? ?? ApiConfig.maxRetries;
    if (retriesLeft <= 0) {
      return handler.next(err);
    }

    // Calculate delay with exponential backoff
    final attemptNumber = ApiConfig.maxRetries - retriesLeft + 1;
    final delayMs = ApiConfig.retryDelay.inMilliseconds *
        (ApiConfig.retryBackoffMultiplier * attemptNumber);

    developer.log(
      'Retrying MCP request (attempt $attemptNumber/${ApiConfig.maxRetries})...',
      name: 'EnhancedMCPClient',
    );

    await Future.delayed(Duration(milliseconds: delayMs.toInt()));

    // Update retry count
    options.extra['mcp_retries_left'] = retriesLeft - 1;

    try {
      final response = await dio.fetch(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }
}

/// MCP-specific error interceptor
class _MCPErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle MCP-specific error scenarios
    if (err.response != null) {
      final statusCode = err.response!.statusCode;
      final data = err.response!.data;

      switch (statusCode) {
        case 404:
          if (data is Map<String, dynamic> &&
              data['error']?['code'] == 'TOOL_NOT_FOUND') {
            developer.log(
              'MCP Tool not found: ${data['error']['message']}',
              name: 'EnhancedMCPClient',
            );
          }
          break;
        case 500:
          if (data is Map<String, dynamic> &&
              data['error']?['code'] == 'TOOL_EXECUTION_ERROR') {
            developer.log(
              'MCP Tool execution error: ${data['error']['message']}',
              name: 'EnhancedMCPClient',
            );
          }
          break;
      }
    }

    super.onError(err, handler);
  }
}
