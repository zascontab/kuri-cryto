import '../models/mcp_ticker.dart';
import '../models/mcp_orderbook.dart';
import '../models/mcp_rsi_result.dart';
import '../models/mcp_macd_result.dart';
import '../models/mcp_bollinger_bands.dart';
import '../models/mcp_trading_signal.dart';
import 'market_data_service.dart';
import 'technical_indicators_service.dart';

/// Integrated Analysis Service - Análisis completo integrando múltiples fuentes
///
/// Combina datos de:
/// - Market Data (ticker, candles, orderbook)
/// - Technical Indicators (RSI, MACD, Bollinger Bands, EMAs)
/// - Liquidez y spread
///
/// Genera señales de trading basadas en análisis multi-indicador.
///
/// Ejemplo de uso:
/// ```dart
/// final analysisService = IntegratedAnalysisService(
///   marketDataService,
///   technicalIndicatorsService,
/// );
///
/// // Análisis completo de un par
/// final analysis = await analysisService.getCompleteMarketAnalysis(
///   exchange: 'kucoin',
///   pair: 'BTC-USDT',
///   interval: '1h',
/// );
///
/// print('Price: \$${analysis['current_price']}');
/// print('Signal: ${analysis['signal']['type']}');
/// print('RSI: ${analysis['rsi']['value']}');
/// print('MACD Signal: ${analysis['macd']['signal_type']}');
/// ```
class IntegratedAnalysisService {
  final MarketDataService _marketDataService;
  final TechnicalIndicatorsService _technicalIndicatorsService;

  IntegratedAnalysisService(
    this._marketDataService,
    this._technicalIndicatorsService,
  );

  /// Obtiene análisis completo de mercado para un par
  ///
  /// Combina ticker, indicadores técnicos y orderbook
  ///
  /// Parámetros:
  /// - [exchange]: Exchange (ej: 'kucoin')
  /// - [pair]: Par de trading (ej: 'BTC-USDT')
  /// - [interval]: Intervalo para indicadores (default: '1h')
  ///
  /// Retorna: Map con análisis completo y señal de trading
  Future<Map<String, dynamic>> getCompleteMarketAnalysis({
    required String exchange,
    required String pair,
    String interval = '1h',
  }) async {
    // Obtener datos en paralelo
    final results = await Future.wait([
      _marketDataService.getTicker(exchange: exchange, pair: pair),
      _technicalIndicatorsService.calculateRSI(
        exchange: exchange,
        pair: pair,
        interval: interval,
      ),
      _technicalIndicatorsService.calculateMACD(
        exchange: exchange,
        pair: pair,
        interval: interval,
      ),
      _technicalIndicatorsService.calculateBollingerBands(
        exchange: exchange,
        pair: pair,
        interval: interval,
      ),
      _marketDataService.getOrderBook(
        exchange: exchange,
        pair: pair,
        depth: 20,
      ),
    ]);

    final ticker = results[0] as MCPTicker;
    final rsi = results[1] as MCPRSIResult;
    final macd = results[2] as MCPMACDResult;
    final bb = results[3] as MCPBollingerBands;
    final orderbook = results[4] as MCPOrderBook;

    // Generar señal de trading
    final signal = _generateTradingSignal(
      ticker: ticker,
      rsi: rsi,
      macd: macd,
      bb: bb,
      orderbook: orderbook,
    );

    return {
      'exchange': exchange,
      'pair': pair,
      'interval': interval,
      'timestamp': DateTime.now().toIso8601String(),
      // Market Data
      'current_price': ticker.last,
      'ticker': ticker.toJson(),
      // Technical Indicators
      'rsi': rsi.toJson(),
      'macd': macd.toJson(),
      'bollinger_bands': bb.toJson(),
      // Order Book
      'orderbook': {
        'best_bid': orderbook.bestBid?.price,
        'best_ask': orderbook.bestAsk?.price,
        'spread': orderbook.spread,
        'spread_percent': orderbook.spreadPercent,
        'mid_price': orderbook.midPrice,
      },
      // Trading Signal
      'signal': signal.toJson(),
      // Market Conditions
      'market_conditions': _analyzeMarketConditions(
        ticker: ticker,
        rsi: rsi,
        macd: macd,
        bb: bb,
      ),
    };
  }

  /// Genera señal de trading basada en múltiples indicadores
  MCPTradingSignal _generateTradingSignal({
    required MCPTicker ticker,
    required MCPRSIResult rsi,
    required MCPMACDResult macd,
    required MCPBollingerBands bb,
    required MCPOrderBook orderbook,
  }) {
    int buySignals = 0;
    int sellSignals = 0;
    final reasons = <String>[];
    final indicators = <String, String>{};

    // Analizar RSI
    if (rsi.isOversold) {
      buySignals++;
      reasons.add('RSI oversold (${rsi.value.toStringAsFixed(1)})');
      indicators['RSI'] = 'BUY';
    } else if (rsi.isOverbought) {
      sellSignals++;
      reasons.add('RSI overbought (${rsi.value.toStringAsFixed(1)})');
      indicators['RSI'] = 'SELL';
    } else {
      indicators['RSI'] = 'NEUTRAL';
    }

    // Analizar MACD
    if (macd.isBullish && macd.hasPositiveMomentum) {
      buySignals++;
      reasons.add('MACD bullish momentum');
      indicators['MACD'] = 'BUY';
    } else if (macd.isBearish && macd.hasNegativeMomentum) {
      sellSignals++;
      reasons.add('MACD bearish momentum');
      indicators['MACD'] = 'SELL';
    } else {
      indicators['MACD'] = 'NEUTRAL';
    }

    // Analizar Bollinger Bands
    final bbSignal = bb.getSignal(ticker.last);
    if (bbSignal == 'BUY') {
      buySignals++;
      reasons.add('Price near/below lower Bollinger Band');
      indicators['Bollinger'] = 'BUY';
    } else if (bbSignal == 'SELL') {
      sellSignals++;
      reasons.add('Price near/above upper Bollinger Band');
      indicators['Bollinger'] = 'SELL';
    } else {
      indicators['Bollinger'] = 'NEUTRAL';
    }

    // Analizar tendencia de precio
    if (ticker.isRising && ticker.change24hPercent != null && ticker.change24hPercent! > 2) {
      buySignals++;
      reasons.add('Strong uptrend (+${ticker.change24hPercent!.toStringAsFixed(1)}% 24h)');
      indicators['Trend'] = 'BUY';
    } else if (ticker.isFalling && ticker.change24hPercent != null && ticker.change24hPercent! < -2) {
      sellSignals++;
      reasons.add('Strong downtrend (${ticker.change24hPercent!.toStringAsFixed(1)}% 24h)');
      indicators['Trend'] = 'SELL';
    } else {
      indicators['Trend'] = 'NEUTRAL';
    }

    // Determinar tipo de señal
    final totalSignals = buySignals + sellSignals;
    String signalType;
    double strength;

    if (buySignals > sellSignals && buySignals >= 2) {
      signalType = 'BUY';
      strength = (buySignals / totalSignals.clamp(1, 10)) * 100;
    } else if (sellSignals > buySignals && sellSignals >= 2) {
      signalType = 'SELL';
      strength = (sellSignals / totalSignals.clamp(1, 10)) * 100;
    } else {
      signalType = 'HOLD';
      strength = 50.0;
    }

    // Calcular confianza basada en consenso
    final maxSignals = buySignals > sellSignals ? buySignals : sellSignals;
    final confidence = (maxSignals / indicators.length) * 100;

    // Determinar nivel de riesgo
    String risk;
    if (orderbook.spreadPercent > 0.5) {
      risk = 'HIGH';
    } else if (rsi.isExtremelyOverbought || rsi.isExtremelyOversold) {
      risk = 'MEDIUM';
    } else {
      risk = 'LOW';
    }

    // Calcular niveles de SL/TP si es señal de compra/venta
    double? stopLoss;
    double? takeProfit;

    if (signalType == 'BUY') {
      stopLoss = bb.lower * 0.98; // 2% debajo de lower band
      takeProfit = bb.upper; // Upper band como objetivo
    } else if (signalType == 'SELL') {
      stopLoss = bb.upper * 1.02; // 2% arriba de upper band
      takeProfit = bb.lower; // Lower band como objetivo
    }

    return MCPTradingSignal(
      type: signalType,
      strength: strength.clamp(0, 100),
      confidence: confidence.clamp(0, 100),
      reasons: reasons,
      indicators: indicators,
      risk: risk,
      entryPrice: ticker.last,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
    );
  }

  /// Analiza las condiciones generales del mercado
  Map<String, dynamic> _analyzeMarketConditions({
    required MCPTicker ticker,
    required MCPRSIResult rsi,
    required MCPMACDResult macd,
    required MCPBollingerBands bb,
  }) {
    // Determinar volatilidad
    String volatility;
    if (bb.isExtremeSqueeze) {
      volatility = 'VERY_LOW';
    } else if (bb.isExtremeExpansion) {
      volatility = 'VERY_HIGH';
    } else if (bb.bandwidthPercent < 3) {
      volatility = 'LOW';
    } else if (bb.bandwidthPercent > 7) {
      volatility = 'HIGH';
    } else {
      volatility = 'NORMAL';
    }

    // Determinar momentum
    String momentum;
    if (macd.hasPositiveMomentum && macd.histogram > 0) {
      momentum = 'BULLISH';
    } else if (macd.hasNegativeMomentum && macd.histogram < 0) {
      momentum = 'BEARISH';
    } else {
      momentum = 'NEUTRAL';
    }

    // Determinar fuerza del mercado
    String marketStrength;
    if (rsi.value > 60 && ticker.isRising) {
      marketStrength = 'STRONG';
    } else if (rsi.value < 40 && ticker.isFalling) {
      marketStrength = 'WEAK';
    } else {
      marketStrength = 'MODERATE';
    }

    return {
      'volatility': volatility,
      'momentum': momentum,
      'market_strength': marketStrength,
      'is_trending': ticker.change24hPercent != null &&
          (ticker.change24hPercent!.abs() > 2),
      'bandwidth_percent': bb.bandwidthPercent,
    };
  }

  /// Obtiene análisis rápido solo con indicadores clave
  ///
  /// Más rápido que getCompleteMarketAnalysis
  Future<Map<String, dynamic>> getQuickAnalysis({
    required String exchange,
    required String pair,
    String interval = '1h',
  }) async {
    final results = await Future.wait([
      _marketDataService.getTicker(exchange: exchange, pair: pair),
      _technicalIndicatorsService.calculateRSI(
        exchange: exchange,
        pair: pair,
        interval: interval,
      ),
    ]);

    final ticker = results[0] as MCPTicker;
    final rsi = results[1] as MCPRSIResult;

    return {
      'pair': pair,
      'price': ticker.last,
      'change_24h_percent': ticker.change24hPercent,
      'rsi': rsi.value,
      'rsi_signal': rsi.signal,
      'is_rising': ticker.isRising,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Analiza múltiples pares en paralelo
  ///
  /// Útil para escanear múltiples activos
  Future<List<Map<String, dynamic>>> analyzeMultiplePairs({
    required String exchange,
    required List<String> pairs,
    String interval = '1h',
  }) async {
    final futures = pairs.map(
      (pair) => getQuickAnalysis(
        exchange: exchange,
        pair: pair,
        interval: interval,
      ),
    );

    return await Future.wait(futures);
  }

  /// Obtiene pares con señales de compra fuertes
  ///
  /// Filtra pares que tienen señales de compra con alta confianza
  Future<List<Map<String, dynamic>>> findBuyOpportunities({
    required String exchange,
    required List<String> pairs,
    String interval = '1h',
    double minConfidence = 70.0,
  }) async {
    final analyses = <Map<String, dynamic>>[];

    for (final pair in pairs) {
      try {
        final analysis = await getCompleteMarketAnalysis(
          exchange: exchange,
          pair: pair,
          interval: interval,
        );

        final signal = MCPTradingSignal.fromJson(
          analysis['signal'] as Map<String, dynamic>,
        );

        if (signal.isBuy && signal.confidence >= minConfidence) {
          analyses.add(analysis);
        }
      } catch (e) {
        // Ignorar errores y continuar con el siguiente par
        continue;
      }
    }

    // Ordenar por confianza descendente
    analyses.sort((a, b) {
      final confA = (a['signal'] as Map<String, dynamic>)['confidence'] as double;
      final confB = (b['signal'] as Map<String, dynamic>)['confidence'] as double;
      return confB.compareTo(confA);
    });

    return analyses;
  }
}
