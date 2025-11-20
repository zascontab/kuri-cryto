import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/futures_position.dart';
import 'api_exception.dart';

/// Servicio para operar con futuros en KuCoin
class FuturesService {
  final Dio _dio;

  FuturesService(this._dio);

  // ============================================================================
  // Positions
  // ============================================================================

  /// Obtiene todas las posiciones abiertas de futuros
  ///
  /// El endpoint retorna:
  /// - Lista de posiciones con toda la información
  /// - Contador de posiciones
  /// - PnL total no realizado
  Future<FuturesPositionsResponse> getPositions({
    String exchange = 'kucoin',
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.mcpToolsUrl,
        data: {
          'jsonrpc': '2.0',
          'method': 'tools/call',
          'params': {
            'name': 'get_futures_positions',
            'arguments': {
              'exchange': exchange,
            }
          },
          'id': DateTime.now().millisecondsSinceEpoch,
        },
      );

      final result = response.data['result'] as Map<String, dynamic>;
      return FuturesPositionsResponse.fromJson(result);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cierra una posición de futuros COMPLETAMENTE en una sola llamada
  ///
  /// IMPORTANTE:
  /// - Cierra TODA la posición en una sola llamada
  /// - Usa orden de mercado con reduce-only (seguro)
  /// - Retorna PnL final y detalles de ejecución
  /// - El símbolo debe estar en formato futuros: DOGEUSDTM, BTCUSDTM, etc.
  Future<CloseFuturesPositionResponse> closePosition({
    required String symbol,
    String exchange = 'kucoin',
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.mcpToolsUrl,
        data: {
          'jsonrpc': '2.0',
          'method': 'tools/call',
          'params': {
            'name': 'close_futures_position',
            'arguments': {
              'exchange': exchange,
              'symbol': symbol,
            }
          },
          'id': DateTime.now().millisecondsSinceEpoch,
        },
      );

      final result = response.data['result'] as Map<String, dynamic>;
      return CloseFuturesPositionResponse.fromJson(result);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cierra todas las posiciones abiertas
  Future<List<CloseFuturesPositionResponse>> closeAllPositions({
    String exchange = 'kucoin',
  }) async {
    final positionsResponse = await getPositions(exchange: exchange);
    final results = <CloseFuturesPositionResponse>[];

    for (final position in positionsResponse.positions) {
      try {
        final result = await closePosition(
          symbol: position.symbol,
          exchange: exchange,
        );
        results.add(result);
      } catch (e) {
        // Continuar con la siguiente posición si hay error
        continue;
      }
    }

    return results;
  }

  /// Cierra todas las posiciones en pérdida
  Future<List<CloseFuturesPositionResponse>> closeLosingPositions({
    String exchange = 'kucoin',
  }) async {
    final positionsResponse = await getPositions(exchange: exchange);
    final results = <CloseFuturesPositionResponse>[];

    for (final position in positionsResponse.positions) {
      if (position.isLoss) {
        try {
          final result = await closePosition(
            symbol: position.symbol,
            exchange: exchange,
          );
          results.add(result);
        } catch (e) {
          continue;
        }
      }
    }

    return results;
  }

  /// Cierra todas las posiciones en ganancia
  Future<List<CloseFuturesPositionResponse>> closeProfitablePositions({
    String exchange = 'kucoin',
  }) async {
    final positionsResponse = await getPositions(exchange: exchange);
    final results = <CloseFuturesPositionResponse>[];

    for (final position in positionsResponse.positions) {
      if (position.isProfit) {
        try {
          final result = await closePosition(
            symbol: position.symbol,
            exchange: exchange,
          );
          results.add(result);
        } catch (e) {
          continue;
        }
      }
    }

    return results;
  }

  /// Cierra posiciones que alcanzaron un stop loss automático
  ///
  /// [maxLossPercent] - Pérdida máxima en porcentaje (ej: 5.0 = 5%)
  Future<List<CloseFuturesPositionResponse>> applyStopLoss({
    required double maxLossPercent,
    String exchange = 'kucoin',
  }) async {
    final positionsResponse = await getPositions(exchange: exchange);
    final results = <CloseFuturesPositionResponse>[];

    for (final position in positionsResponse.positions) {
      if (position.pnlPercent < -maxLossPercent) {
        try {
          final result = await closePosition(
            symbol: position.symbol,
            exchange: exchange,
          );
          results.add(result);
        } catch (e) {
          continue;
        }
      }
    }

    return results;
  }

  /// Cierra posiciones que alcanzaron un take profit automático
  ///
  /// [minProfitPercent] - Ganancia mínima en porcentaje (ej: 2.0 = 2%)
  Future<List<CloseFuturesPositionResponse>> applyTakeProfit({
    required double minProfitPercent,
    String exchange = 'kucoin',
  }) async {
    final positionsResponse = await getPositions(exchange: exchange);
    final results = <CloseFuturesPositionResponse>[];

    for (final position in positionsResponse.positions) {
      if (position.pnlPercent >= minProfitPercent) {
        try {
          final result = await closePosition(
            symbol: position.symbol,
            exchange: exchange,
          );
          results.add(result);
        } catch (e) {
          continue;
        }
      }
    }

    return results;
  }

  // ============================================================================
  // Price Info
  // ============================================================================

  /// Obtiene el precio mark (precio de marca) para futuros
  Future<double> getMarkPrice({
    required String symbol,
    String exchange = 'kucoin',
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.mcpToolsUrl,
        data: {
          'jsonrpc': '2.0',
          'method': 'tools/call',
          'params': {
            'name': 'get_mark_price',
            'arguments': {
              'exchange': exchange,
              'symbol': symbol,
            }
          },
          'id': DateTime.now().millisecondsSinceEpoch,
        },
      );

      final result = response.data['result'] as Map<String, dynamic>;
      return (result['mark_price'] as num).toDouble();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtiene el precio índice para futuros
  Future<double> getIndexPrice({
    required String symbol,
    String exchange = 'kucoin',
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.mcpToolsUrl,
        data: {
          'jsonrpc': '2.0',
          'method': 'tools/call',
          'params': {
            'name': 'get_index_price',
            'arguments': {
              'exchange': exchange,
              'symbol': symbol,
            }
          },
          'id': DateTime.now().millisecondsSinceEpoch,
        },
      );

      final result = response.data['result'] as Map<String, dynamic>;
      return (result['index_price'] as num).toDouble();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================================================
  // Helpers
  // ============================================================================

  /// Convierte un símbolo spot a formato futuros
  ///
  /// Ejemplo: DOGE-USDT → DOGEUSDTM
  String convertToFuturesSymbol(String spotPair) {
    return spotPair.replaceAll('-', '') + 'M';
  }

  /// Convierte un símbolo futuros a formato spot
  ///
  /// Ejemplo: DOGEUSDTM → DOGE-USDT
  String convertToSpotSymbol(String futuresSymbol) {
    // Remover la 'M' final
    final withoutM = futuresSymbol.endsWith('M')
        ? futuresSymbol.substring(0, futuresSymbol.length - 1)
        : futuresSymbol;

    // Insertar '-' antes de 'USDT'
    if (withoutM.contains('USDT')) {
      return withoutM.replaceFirst('USDT', '-USDT');
    }

    return withoutM;
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
