import '../models/mcp_rsi_result.dart';
import '../models/mcp_macd_result.dart';
import '../models/mcp_bollinger_bands.dart';
import 'mcp_service.dart';

/// Technical Indicators Service - Wrapper para indicadores técnicos MCP
///
/// Provee acceso tipo-seguro a las herramientas MCP de análisis técnico:
/// - RSI (Relative Strength Index)
/// - MACD (Moving Average Convergence Divergence)
/// - Bollinger Bands
/// - EMA (Exponential Moving Average)
/// - SMA (Simple Moving Average)
/// - ATR (Average True Range)
/// - Stochastic Oscillator
/// - ADX (Average Directional Index)
/// - CCI (Commodity Channel Index)
/// - Williams %R
///
/// Ejemplo de uso:
/// ```dart
/// final indicatorsService = TechnicalIndicatorsService(mcpService);
///
/// // Calcular RSI
/// final rsi = await indicatorsService.calculateRSI(
///   exchange: 'kucoin',
///   pair: 'BTC-USDT',
///   interval: '1h',
///   period: 14,
/// );
/// print('RSI: ${rsi.value} - ${rsi.signal}');
///
/// // Calcular MACD
/// final macd = await indicatorsService.calculateMACD(
///   exchange: 'kucoin',
///   pair: 'BTC-USDT',
///   interval: '1h',
/// );
/// print('MACD Signal: ${macd.signalType}');
///
/// // Calcular Bollinger Bands
/// final bb = await indicatorsService.calculateBollingerBands(
///   exchange: 'kucoin',
///   pair: 'BTC-USDT',
///   interval: '1h',
/// );
/// print('BB: ${bb.lower} - ${bb.middle} - ${bb.upper}');
/// ```
class TechnicalIndicatorsService {
  final MCPService _mcpService;

  TechnicalIndicatorsService(this._mcpService);

  /// Calcula el RSI (Relative Strength Index)
  ///
  /// Parámetros:
  /// - [exchange]: Exchange (ej: 'kucoin', 'binance')
  /// - [pair]: Par de trading (ej: 'BTC-USDT')
  /// - [interval]: Intervalo de tiempo ('1m', '5m', '15m', '1h', '4h', '1d')
  /// - [period]: Período del RSI (default: 14)
  /// - [marketType]: Tipo de mercado opcional ('spot', 'futures', 'margin', 'options')
  ///
  /// Retorna: [MCPRSIResult] con valor RSI (0-100) y señales
  Future<MCPRSIResult> calculateRSI({
    required String exchange,
    required String pair,
    required String interval,
    int period = 14,
    String? marketType,
  }) async {
    final arguments = {
      'exchange': exchange,
      'pair': pair,
      'interval': interval,
      'period': period,
    };

    if (marketType != null) {
      arguments['market_type'] = marketType;
    }

    final result = await _mcpService.callTool(
      toolName: 'calculate_rsi',
      arguments: arguments,
    );

    // Agregar exchange y pair al resultado
    result['exchange'] = exchange;
    result['pair'] = pair;
    result['period'] = period;

    return MCPRSIResult.fromJson(result);
  }

  /// Calcula el MACD (Moving Average Convergence Divergence)
  ///
  /// Parámetros:
  /// - [exchange]: Exchange
  /// - [pair]: Par de trading
  /// - [interval]: Intervalo de tiempo
  /// - [fastPeriod]: Período EMA rápida (default: 12)
  /// - [slowPeriod]: Período EMA lenta (default: 26)
  /// - [signalPeriod]: Período línea de señal (default: 9)
  /// - [marketType]: Tipo de mercado opcional ('spot', 'futures', 'margin', 'options')
  ///
  /// Retorna: [MCPMACDResult] con macd, signal y histogram
  Future<MCPMACDResult> calculateMACD({
    required String exchange,
    required String pair,
    required String interval,
    int fastPeriod = 12,
    int slowPeriod = 26,
    int signalPeriod = 9,
    String? marketType,
  }) async {
    final arguments = {
      'exchange': exchange,
      'pair': pair,
      'interval': interval,
      'fast_period': fastPeriod,
      'slow_period': slowPeriod,
      'signal_period': signalPeriod,
    };

    if (marketType != null) {
      arguments['market_type'] = marketType;
    }

    final result = await _mcpService.callTool(
      toolName: 'calculate_macd',
      arguments: arguments,
    );

    // Agregar metadatos al resultado
    result['exchange'] = exchange;
    result['pair'] = pair;
    result['fast_period'] = fastPeriod;
    result['slow_period'] = slowPeriod;
    result['signal_period'] = signalPeriod;

    return MCPMACDResult.fromJson(result);
  }

  /// Calcula las Bollinger Bands
  ///
  /// Parámetros:
  /// - [exchange]: Exchange
  /// - [pair]: Par de trading
  /// - [interval]: Intervalo de tiempo
  /// - [period]: Período de la SMA (default: 20)
  /// - [stdDev]: Desviación estándar multiplicador (default: 2.0)
  ///
  /// Retorna: [MCPBollingerBands] con upper, middle y lower bands
  Future<MCPBollingerBands> calculateBollingerBands({
    required String exchange,
    required String pair,
    required String interval,
    int period = 20,
    double stdDev = 2.0,
  }) async {
    final result = await _mcpService.callTool(
      toolName: 'calculate_bollinger_bands',
      arguments: {
        'exchange': exchange,
        'pair': pair,
        'interval': interval,
        'period': period,
        'std_dev': stdDev,
      },
    );

    // Agregar metadatos al resultado
    result['exchange'] = exchange;
    result['pair'] = pair;
    result['period'] = period;
    result['std_dev'] = stdDev;

    return MCPBollingerBands.fromJson(result);
  }

  /// Calcula EMA (Exponential Moving Average)
  ///
  /// Parámetros:
  /// - [exchange]: Exchange
  /// - [pair]: Par de trading
  /// - [interval]: Intervalo de tiempo
  /// - [period]: Período de la EMA (ej: 9, 12, 21, 50, 200)
  /// - [limit]: Número de valores a retornar (default: 100)
  ///
  /// Retorna: Lista de valores EMA
  Future<List<double>> calculateEMA({
    required String exchange,
    required String pair,
    required String interval,
    required int period,
    int limit = 100,
  }) async {
    final result = await _mcpService.callTool(
      toolName: 'calculate_ema',
      arguments: {
        'exchange': exchange,
        'pair': pair,
        'interval': interval,
        'period': period,
        'limit': limit,
      },
    );

    // El resultado puede venir como {'ema': [...]} o {'values': [...]}
    final emaList = result['ema'] ?? result['values'] ?? result;

    if (emaList is! List) {
      throw FormatException(
          'Expected list of EMA values, got ${emaList.runtimeType}');
    }

    return emaList.map((value) => (value as num).toDouble()).toList();
  }

  /// Calcula SMA (Simple Moving Average)
  ///
  /// Parámetros:
  /// - [exchange]: Exchange
  /// - [pair]: Par de trading
  /// - [interval]: Intervalo de tiempo
  /// - [period]: Período de la SMA (ej: 20, 50, 100, 200)
  /// - [limit]: Número de valores a retornar (default: 100)
  ///
  /// Retorna: Lista de valores SMA
  Future<List<double>> calculateSMA({
    required String exchange,
    required String pair,
    required String interval,
    required int period,
    int limit = 100,
  }) async {
    final result = await _mcpService.callTool(
      toolName: 'calculate_sma',
      arguments: {
        'exchange': exchange,
        'pair': pair,
        'interval': interval,
        'period': period,
        'limit': limit,
      },
    );

    final smaList = result['sma'] ?? result['values'] ?? result;

    if (smaList is! List) {
      throw FormatException(
          'Expected list of SMA values, got ${smaList.runtimeType}');
    }

    return smaList.map((value) => (value as num).toDouble()).toList();
  }

  /// Calcula ATR (Average True Range) - Indicador de volatilidad
  ///
  /// Parámetros:
  /// - [exchange]: Exchange
  /// - [pair]: Par de trading
  /// - [interval]: Intervalo de tiempo
  /// - [period]: Período del ATR (default: 14)
  ///
  /// Retorna: Map con 'atr' (valor actual) y opcionalmente 'values' (histórico)
  Future<Map<String, dynamic>> calculateATR({
    required String exchange,
    required String pair,
    required String interval,
    int period = 14,
  }) async {
    return await _mcpService.callTool(
      toolName: 'calculate_atr',
      arguments: {
        'exchange': exchange,
        'pair': pair,
        'interval': interval,
        'period': period,
      },
    );
  }

  /// Calcula Stochastic Oscillator
  ///
  /// Parámetros:
  /// - [exchange]: Exchange
  /// - [pair]: Par de trading
  /// - [interval]: Intervalo de tiempo
  /// - [kPeriod]: Período %K (default: 14)
  /// - [dPeriod]: Período %D (default: 3)
  ///
  /// Retorna: Map con 'k' (%K) y 'd' (%D)
  Future<Map<String, dynamic>> calculateStochastic({
    required String exchange,
    required String pair,
    required String interval,
    int kPeriod = 14,
    int dPeriod = 3,
  }) async {
    return await _mcpService.callTool(
      toolName: 'calculate_stochastic',
      arguments: {
        'exchange': exchange,
        'pair': pair,
        'interval': interval,
        'k_period': kPeriod,
        'd_period': dPeriod,
      },
    );
  }

  /// Calcula ADX (Average Directional Index) - Indicador de fuerza de tendencia
  ///
  /// Parámetros:
  /// - [exchange]: Exchange
  /// - [pair]: Par de trading
  /// - [interval]: Intervalo de tiempo
  /// - [period]: Período del ADX (default: 14)
  ///
  /// Retorna: Map con 'adx', 'plus_di' y 'minus_di'
  Future<Map<String, dynamic>> calculateADX({
    required String exchange,
    required String pair,
    required String interval,
    int period = 14,
  }) async {
    return await _mcpService.callTool(
      toolName: 'calculate_adx',
      arguments: {
        'exchange': exchange,
        'pair': pair,
        'interval': interval,
        'period': period,
      },
    );
  }

  /// Calcula CCI (Commodity Channel Index)
  ///
  /// Parámetros:
  /// - [exchange]: Exchange
  /// - [pair]: Par de trading
  /// - [interval]: Intervalo de tiempo
  /// - [period]: Período del CCI (default: 20)
  ///
  /// Retorna: Map con 'cci' (valor actual)
  Future<Map<String, dynamic>> calculateCCI({
    required String exchange,
    required String pair,
    required String interval,
    int period = 20,
  }) async {
    return await _mcpService.callTool(
      toolName: 'calculate_cci',
      arguments: {
        'exchange': exchange,
        'pair': pair,
        'interval': interval,
        'period': period,
      },
    );
  }

  /// Calcula Williams %R
  ///
  /// Parámetros:
  /// - [exchange]: Exchange
  /// - [pair]: Par de trading
  /// - [interval]: Intervalo de tiempo
  /// - [period]: Período del Williams %R (default: 14)
  ///
  /// Retorna: Map con 'williams_r' (valor -100 a 0)
  Future<Map<String, dynamic>> calculateWilliamsR({
    required String exchange,
    required String pair,
    required String interval,
    int period = 14,
  }) async {
    return await _mcpService.callTool(
      toolName: 'calculate_williams_r',
      arguments: {
        'exchange': exchange,
        'pair': pair,
        'interval': interval,
        'period': period,
      },
    );
  }

  /// Calcula múltiples EMAs en paralelo
  ///
  /// Útil para obtener varias EMAs al mismo tiempo (ej: 9, 21, 50, 200)
  ///
  /// Parámetros:
  /// - [exchange]: Exchange
  /// - [pair]: Par de trading
  /// - [interval]: Intervalo de tiempo
  /// - [periods]: Lista de períodos (ej: [9, 21, 50, 200])
  ///
  /// Retorna: Map con período como key y lista de valores como value
  Future<Map<int, List<double>>> calculateMultipleEMAs({
    required String exchange,
    required String pair,
    required String interval,
    required List<int> periods,
  }) async {
    final futures = periods.map(
      (period) => calculateEMA(
        exchange: exchange,
        pair: pair,
        interval: interval,
        period: period,
      ),
    );

    final results = await Future.wait(futures);

    return Map.fromIterables(periods, results);
  }

  /// Obtiene un análisis técnico completo combinando múltiples indicadores
  ///
  /// Calcula RSI, MACD y Bollinger Bands en una sola llamada
  ///
  /// Retorna: Map con 'rsi', 'macd' y 'bollinger_bands'
  Future<Map<String, dynamic>> getCompleteAnalysis({
    required String exchange,
    required String pair,
    required String interval,
  }) async {
    final results = await Future.wait([
      calculateRSI(exchange: exchange, pair: pair, interval: interval),
      calculateMACD(exchange: exchange, pair: pair, interval: interval),
      calculateBollingerBands(
          exchange: exchange, pair: pair, interval: interval),
    ]);

    return {
      'rsi': results[0],
      'macd': results[1],
      'bollinger_bands': results[2],
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
