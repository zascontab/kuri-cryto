import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:developer' as developer;
import '../config/api_config.dart';
import '../models/health_response.dart';
import 'api_exception.dart';

/// Servicio para verificar la salud del servidor
///
/// Endpoints:
/// - GET /health - Health check del MCP Server
class HealthService {
  final Dio _dio;
  Timer? _monitorTimer;
  final _healthController = StreamController<HealthResponse>.broadcast();

  HealthService(this._dio);

  /// Stream de health checks continuos
  Stream<HealthResponse> get healthStream => _healthController.stream;

  /// Verifica la salud del servidor
  ///
  /// Returns: [HealthResponse] con información de salud
  /// Throws: [ApiException] si hay error
  Future<HealthResponse> check() async {
    try {
      developer.log(
        'Checking server health',
        name: 'HealthService',
      );

      final response = await _dio.get(ApiConfig.mcpHealthUrl);

      developer.log(
        'Server health check successful',
        name: 'HealthService',
      );

      return HealthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      developer.log(
        'Error checking server health: ${e.message}',
        name: 'HealthService',
        error: e,
      );
      throw _handleError(e);
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error checking server health',
        name: 'HealthService',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException(
        message: 'Unexpected error: ${e.toString()}',
        statusCode: null,
      );
    }
  }

  /// Inicia el monitoreo continuo de salud
  ///
  /// [interval]: Intervalo entre checks (default: 30 segundos)
  void startMonitoring({Duration interval = const Duration(seconds: 30)}) {
    stopMonitoring(); // Detener monitoreo previo si existe

    developer.log(
      'Starting health monitoring (interval: ${interval.inSeconds}s)',
      name: 'HealthService',
    );

    // Hacer check inmediato
    _performHealthCheck();

    // Programar checks periódicos
    _monitorTimer = Timer.periodic(interval, (_) {
      _performHealthCheck();
    });
  }

  /// Detiene el monitoreo continuo
  void stopMonitoring() {
    if (_monitorTimer != null) {
      developer.log(
        'Stopping health monitoring',
        name: 'HealthService',
      );
      _monitorTimer?.cancel();
      _monitorTimer = null;
    }
  }

  /// Realiza un health check y emite el resultado al stream
  Future<void> _performHealthCheck() async {
    try {
      final health = await check();
      if (!_healthController.isClosed) {
        _healthController.add(health);
      }
    } catch (e) {
      developer.log(
        'Health check failed: $e',
        name: 'HealthService',
        error: e,
      );
      // No emitir error al stream, solo loggear
    }
  }

  /// Verifica si el servidor está disponible (sin lanzar excepción)
  ///
  /// Returns: true si el servidor está saludable, false en caso contrario
  Future<bool> isServerHealthy() async {
    try {
      final health = await check();
      return health.isHealthy;
    } catch (e) {
      return false;
    }
  }

  /// Espera hasta que el servidor esté disponible
  ///
  /// [maxAttempts]: Número máximo de intentos (default: 10)
  /// [delay]: Delay entre intentos (default: 2 segundos)
  /// Returns: true si el servidor está disponible, false si se agotaron los intentos
  Future<bool> waitForServer({
    int maxAttempts = 10,
    Duration delay = const Duration(seconds: 2),
  }) async {
    developer.log(
      'Waiting for server to be available (max attempts: $maxAttempts)',
      name: 'HealthService',
    );

    for (int i = 0; i < maxAttempts; i++) {
      try {
        final health = await check();
        if (health.isHealthy) {
          developer.log(
            'Server is available',
            name: 'HealthService',
          );
          return true;
        }
      } catch (e) {
        developer.log(
          'Attempt ${i + 1}/$maxAttempts failed',
          name: 'HealthService',
        );
      }

      if (i < maxAttempts - 1) {
        await Future.delayed(delay);
      }
    }

    developer.log(
      'Server not available after $maxAttempts attempts',
      name: 'HealthService',
    );
    return false;
  }

  /// Limpia recursos
  void dispose() {
    stopMonitoring();
    _healthController.close();
  }

  /// Maneja errores de Dio y los convierte a ApiException
  ApiException _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      String message = 'Unknown error';

      if (data is Map<String, dynamic>) {
        message = data['error'] ?? data['message'] ?? message;
      } else if (data is String) {
        message = data;
      }

      return ApiException(
        message: message,
        details: data is Map<String, dynamic> ? data['details'] : null,
        statusCode: e.response!.statusCode,
      );
    }

    // Errores de red
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        message: 'Connection timeout. Server may be unavailable.',
        statusCode: null,
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'Cannot connect to server. Please check your connection.',
        statusCode: null,
      );
    }

    return ApiException(
      message: 'Network error: ${e.message}',
      statusCode: null,
    );
  }
}
