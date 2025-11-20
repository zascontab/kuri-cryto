import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/comprehensive_analysis.dart';
import 'api_exception.dart';

/// Servicio para obtener análisis comprehensivo de mercado con AI
class ComprehensiveAnalysisService {
  final Dio _dio;

  ComprehensiveAnalysisService(this._dio);

  /// Obtiene análisis comprehensivo de un símbolo
  ///
  /// Incluye:
  /// - Precio actual y estadísticas 24h
  /// - Análisis técnico (RSI, MACD, Bollinger, EMAs)
  /// - Análisis multi-timeframe (1m, 5m, 15m, 1h)
  /// - Movimiento reciente (últimas 10 velas)
  /// - Niveles clave (soporte/resistencia)
  /// - Recomendación de trading (BUY/SELL/WAIT)
  /// - Escenarios de mercado posibles
  /// - Evaluación de riesgo
  Future<ComprehensiveAnalysis> getAnalysis({
    required String symbol,
    String exchange = 'kucoin',
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.comprehensiveAnalysisUrl,
        data: {
          'symbol': symbol,
          'exchange': exchange,
        },
      );
      return ComprehensiveAnalysis.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtiene análisis para múltiples símbolos
  Future<List<ComprehensiveAnalysis>> getMultipleAnalyses({
    required List<String> symbols,
    String exchange = 'kucoin',
  }) async {
    final results = <ComprehensiveAnalysis>[];
    for (final symbol in symbols) {
      try {
        final analysis = await getAnalysis(symbol: symbol, exchange: exchange);
        results.add(analysis);
      } catch (e) {
        // Continuar con el siguiente símbolo si hay error
        continue;
      }
    }
    return results;
  }

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
