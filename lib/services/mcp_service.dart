import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'api_exception.dart';

/// Servicio genérico para llamadas MCP Tools via JSON-RPC 2.0
///
/// Este servicio centraliza todas las llamadas a las 67 herramientas
/// disponibles en el Trading MCP Server.
///
/// Características:
/// - JSON-RPC 2.0 compliant
/// - Manejo de errores robusto
/// - Request ID auto-incremental
/// - Logging en desarrollo
/// - Tipo-safe con genéricos
///
/// Ejemplo de uso:
/// ```dart
/// final mcpService = MCPService(dio);
///
/// // Llamada simple
/// final result = await mcpService.callTool(
///   toolName: 'get_ticker',
///   arguments: {
///     'exchange': 'kucoin',
///     'pair': 'BTC-USDT',
///   },
/// );
///
/// // Llamada con tipado
/// final ticker = await mcpService.callToolTyped<MCPTicker>(
///   toolName: 'get_ticker',
///   arguments: {'exchange': 'kucoin', 'pair': 'BTC-USDT'},
///   fromJson: MCPTicker.fromJson,
/// );
/// ```
class MCPService {
  final Dio _dio;
  int _requestId = 0;

  MCPService(this._dio);

  /// Ejecuta cualquier herramienta MCP usando JSON-RPC 2.0
  ///
  /// [toolName]: Nombre de la herramienta (ej: 'get_ticker', 'calculate_rsi')
  /// [arguments]: Argumentos de la herramienta
  /// [marketType]: Tipo de mercado opcional ('spot', 'futures', 'margin', 'options')
  ///
  /// Returns: Resultado de la herramienta (response.data['result'])
  ///
  /// Throws:
  /// - [ApiException] si la herramienta retorna error
  /// - [ApiException] si hay error de red
  ///
  /// Ejemplo:
  /// ```dart
  /// final result = await callTool(
  ///   toolName: 'get_ticker',
  ///   arguments: {
  ///     'exchange': 'kucoin',
  ///     'pair': 'BTC-USDT',
  ///   },
  ///   marketType: 'futures',  // Opcional
  /// );
  /// print(result['last']); // Precio actual
  /// ```
  Future<Map<String, dynamic>> callTool({
    required String toolName,
    required Map<String, dynamic> arguments,
    String? marketType,
  }) async {
    try {
      _requestId++;

      developer.log(
        'Calling MCP tool: $toolName with args: $arguments',
        name: 'MCPService',
      );

      // Add market_type to arguments if provided
      final finalArguments = Map<String, dynamic>.from(arguments);
      if (marketType != null) {
        finalArguments['market_type'] = marketType;
      }

      final response = await _dio.post(
        ApiConfig.mcpToolsUrl,
        data: {
          'jsonrpc': '2.0',
          'method': 'tools/call',
          'params': {
            'name': toolName,
            'arguments': finalArguments,
          },
          'id': _requestId,
        },
      );

      // Validar respuesta JSON-RPC
      if (response.data == null) {
        throw ApiException(
          message: 'Empty response from MCP server',
          code: 'EMPTY_RESPONSE',
        );
      }

      final data = response.data as Map<String, dynamic>;

      // Verificar si hay error en la respuesta JSON-RPC
      if (data['error'] != null) {
        final error = data['error'] as Map<String, dynamic>;
        throw ApiException(
          message: error['message'] as String? ?? 'MCP Tool error',
          code: error['code']?.toString() ?? 'MCP_ERROR',
          details: error['data'],
        );
      }

      // Verificar que existe result
      if (data['result'] == null) {
        throw ApiException(
          message: 'No result in MCP response',
          code: 'NO_RESULT',
        );
      }

      final result = data['result'] as Map<String, dynamic>;

      developer.log(
        'MCP tool $toolName succeeded',
        name: 'MCPService',
      );

      return result;
    } on DioException catch (e) {
      developer.log(
        'MCP tool $toolName failed: ${e.message}',
        name: 'MCPService',
        error: e,
      );
      throw _handleError(e);
    } on ApiException {
      rethrow;
    } catch (e) {
      developer.log(
        'Unexpected error calling MCP tool $toolName: $e',
        name: 'MCPService',
        error: e,
      );
      throw ApiException(
        message: 'Unexpected error: $e',
        code: 'UNEXPECTED_ERROR',
      );
    }
  }

  /// Llama a una herramienta y retorna un tipo específico
  ///
  /// Usa esta función cuando quieres un objeto tipado en lugar de Map.
  ///
  /// [T]: Tipo del objeto a retornar
  /// [toolName]: Nombre de la herramienta MCP
  /// [arguments]: Argumentos de la herramienta
  /// [marketType]: Tipo de mercado opcional
  /// [fromJson]: Función que convierte Map a T
  ///
  /// Returns: Objeto de tipo T
  ///
  /// Ejemplo:
  /// ```dart
  /// final ticker = await callToolTyped<MCPTicker>(
  ///   toolName: 'get_ticker',
  ///   arguments: {'exchange': 'kucoin', 'pair': 'BTC-USDT'},
  ///   marketType: 'futures',
  ///   fromJson: MCPTicker.fromJson,
  /// );
  /// print(ticker.last); // Type-safe access
  /// ```
  Future<T> callToolTyped<T>({
    required String toolName,
    required Map<String, dynamic> arguments,
    String? marketType,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final result = await callTool(
      toolName: toolName,
      arguments: arguments,
      marketType: marketType,
    );
    return fromJson(result);
  }

  /// Llama a múltiples herramientas en paralelo
  ///
  /// Útil cuando necesitas hacer varias llamadas independientes al mismo tiempo.
  ///
  /// Ejemplo:
  /// ```dart
  /// final results = await callMultipleTools([
  ///   {'tool': 'get_ticker', 'args': {'exchange': 'kucoin', 'pair': 'BTC-USDT'}},
  ///   {'tool': 'get_ticker', 'args': {'exchange': 'kucoin', 'pair': 'ETH-USDT'}},
  ///   {'tool': 'calculate_rsi', 'args': {'exchange': 'kucoin', 'pair': 'BTC-USDT'}},
  /// ]);
  /// ```
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

  /// Obtiene la lista de herramientas disponibles
  ///
  /// NOTA: Este método asume que existe una herramienta 'list_tools'.
  /// Verificar con la documentación del backend si está disponible.
  Future<List<String>> getAvailableTools() async {
    try {
      final result = await callTool(
        toolName: 'list_tools',
        arguments: {},
      );

      return (result['tools'] as List).cast<String>();
    } catch (e) {
      developer.log(
        'Could not fetch available tools: $e',
        name: 'MCPService',
        error: e,
      );
      // Retornar lista vacía si no está disponible
      return [];
    }
  }

  /// Maneja errores de Dio y los convierte a ApiException
  ApiException _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;

      // Si la respuesta es un string (HTML error, etc.)
      if (data is String) {
        return ApiException(
          message: 'Server error: ${e.response!.statusCode}',
          statusCode: e.response!.statusCode,
        );
      }

      // Si es un Map, intentar extraer mensaje de error
      if (data is Map<String, dynamic>) {
        // Formato JSON-RPC error
        if (data['error'] != null) {
          final error = data['error'];
          return ApiException(
            message: error['message'] ?? 'MCP error',
            code: error['code']?.toString(),
            details: error['data'],
            statusCode: e.response!.statusCode,
          );
        }

        // Formato REST error
        return ApiException(
          message: data['message'] ?? data['error'] ?? 'Unknown error',
          code: data['code'],
          details: data['details'],
          statusCode: e.response!.statusCode,
        );
      }
    }

    // Error de red
    if (e.type == DioExceptionType.connectionTimeout) {
      return ApiException(
        message: 'Connection timeout - check network connection',
        code: 'TIMEOUT',
        details: 'Verify server is running at ${ApiConfig.serverIp}',
      );
    }

    if (e.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        message: 'Server response timeout',
        code: 'RECEIVE_TIMEOUT',
        details: 'The server is taking too long to respond. Try again later.',
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'Connection error - server might be down',
        code: 'CONNECTION_ERROR',
        details:
            'Check if MCP Server is running on port 10600 or Gateway on port 9090',
      );
    }

    return ApiException(
      message: 'Network error: ${e.message}',
      code: 'NETWORK_ERROR',
      details: 'Check your internet connection and server availability',
    );
  }

  /// Obtiene el ID del siguiente request (útil para debugging)
  int get nextRequestId => _requestId + 1;

  /// Resetea el contador de request ID (útil para testing)
  void resetRequestId() {
    _requestId = 0;
  }
}
