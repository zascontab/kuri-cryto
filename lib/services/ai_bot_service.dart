import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/ai_bot_config.dart';
import '../models/ai_bot_status.dart';
import '../models/ai_analysis.dart';
import 'api_exception.dart';

/// Servicio para interactuar con el AI Trading Bot
class AiBotService {
  final Dio _dio;

  AiBotService(this._dio);

  // ============================================================================
  // Status & Info
  // ============================================================================

  /// Obtiene el estado actual del bot
  Future<AiBotStatus> getStatus() async {
    try {
      final response = await _dio.get(
        '${ApiConfig.aiBotBaseUrl}/status',
      );
      return AiBotStatus.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtiene la configuración actual del bot
  Future<AiBotConfig> getConfig() async {
    try {
      final response = await _dio.get(ApiConfig.aiBotConfigUrl);
      return AiBotConfig.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Actualiza la configuración del bot
  /// IMPORTANTE: El bot debe estar detenido para cambiar la configuración
  Future<AiBotConfig> updateConfig(Map<String, dynamic> updates) async {
    try {
      final response = await _dio.post(
        ApiConfig.aiBotConfigUrl,
        data: updates,
      );
      final result = response.data as Map<String, dynamic>;
      return AiBotConfig.fromJson(result['config'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================================================
  // Bot Control
  // ============================================================================

  /// Inicia el bot
  Future<Map<String, dynamic>> start() async {
    try {
      final response = await _dio.post('${ApiConfig.aiBotBaseUrl}/start');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Detiene el bot
  Future<Map<String, dynamic>> stop() async {
    try {
      final response = await _dio.post('${ApiConfig.aiBotBaseUrl}/stop');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Pausa el bot (continúa monitoreando posiciones pero no ejecuta nuevos trades)
  Future<Map<String, dynamic>> pause() async {
    try {
      final response = await _dio.post('${ApiConfig.aiBotBaseUrl}/pause');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Reanuda el bot desde pausa
  Future<Map<String, dynamic>> resume() async {
    try {
      final response = await _dio.post('${ApiConfig.aiBotBaseUrl}/resume');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Parada de emergencia - detiene el bot y cierra todas las posiciones
  /// ⚠️ USAR SOLO EN EMERGENCIAS
  Future<Map<String, dynamic>> emergencyStop() async {
    try {
      final response = await _dio.post('${ApiConfig.aiBotBaseUrl}/emergency-stop');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================================================
  // Analysis
  // ============================================================================

  /// Analiza un par de mercado con AI
  Future<AiAnalysis> analyze({
    required String pair,
    String exchange = 'kucoin',
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.aiBotBaseUrl}/analyze',
        data: {
          'pair': pair,
          'exchange': exchange,
        },
      );
      return AiAnalysis.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================================================
  // Positions
  // ============================================================================

  /// Obtiene las posiciones activas del bot
  Future<List<AiPosition>> getPositions() async {
    try {
      final response = await _dio.get('${ApiConfig.aiBotBaseUrl}/positions');
      final data = response.data as Map<String, dynamic>;
      final positions = data['positions'] as List;
      return positions.map((p) => AiPosition.fromJson(p as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================================================
  // Configuration Helpers
  // ============================================================================

  /// Cambia el bot a modo DRY RUN (simulación)
  Future<AiBotConfig> enableDryRunMode() async {
    return updateConfig({
      'dry_run': true,
      'auto_execute': false,
    });
  }

  /// Cambia el bot a modo LIVE (trading real)
  /// ⚠️ CUIDADO: Esto permite trading con dinero real
  Future<AiBotConfig> enableLiveMode() async {
    return updateConfig({
      'dry_run': false,
      'auto_execute': true,
    });
  }

  /// Actualiza el umbral de confianza
  Future<AiBotConfig> updateConfidenceThreshold(double threshold) async {
    if (threshold < 0.5 || threshold > 1.0) {
      throw ApiException(
        message: 'Confidence threshold must be between 0.5 and 1.0',
        statusCode: 400,
      );
    }
    return updateConfig({'confidence_threshold': threshold});
  }

  /// Actualiza el tamaño de trade
  Future<AiBotConfig> updateTradeSize(double sizeUsd) async {
    if (sizeUsd <= 0) {
      throw ApiException(
        message: 'Trade size must be positive',
        statusCode: 400,
      );
    }
    return updateConfig({'trade_size_usd': sizeUsd});
  }

  /// Actualiza el apalancamiento
  Future<AiBotConfig> updateLeverage(int leverage) async {
    if (leverage < 1 || leverage > 100) {
      throw ApiException(
        message: 'Leverage must be between 1 and 100',
        statusCode: 400,
      );
    }
    return updateConfig({'leverage': leverage});
  }

  /// Actualiza el par de trading
  Future<AiBotConfig> updateTradingPair(String pair) async {
    return updateConfig({'pair': pair});
  }

  /// Actualiza los límites de seguridad
  Future<AiBotConfig> updateSafetyLimits({
    double? maxDailyLoss,
    int? maxDailyTrades,
    int? maxConsecutiveErrors,
    int? maxOpenPositions,
  }) async {
    final updates = <String, dynamic>{};
    if (maxDailyLoss != null) updates['max_daily_loss_usd'] = maxDailyLoss;
    if (maxDailyTrades != null) updates['max_daily_trades'] = maxDailyTrades;
    if (maxConsecutiveErrors != null) updates['max_consecutive_errors'] = maxConsecutiveErrors;
    if (maxOpenPositions != null) updates['max_open_positions'] = maxOpenPositions;
    return updateConfig(updates);
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  ApiException _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      return ApiException(
        message: data['error'] ?? data['message'] ?? 'Unknown error',
        details: data['details'],
        statusCode: e.response!.statusCode,
      );
    }
    return ApiException(
      message: 'Network error: ${e.message}',
      statusCode: null,
    );
  }
}
