import 'market_type.dart';
import 'futures_data.dart';
import 'margin_data.dart';
import 'options_data.dart';
import 'key_levels.dart';
import 'risk_assessment.dart';

/// Comprehensive market analysis model
///
/// Contains complete market analysis including price data, technical indicators
/// across multiple timeframes, scenarios, and AI-powered recommendations.
///
/// Supports market-type specific data:
/// - Futures: funding_rate, mark_price, liquidation_price
/// - Margin: interest_rate, margin_level, borrowed_amount
/// - Options: implied_volatility, greeks
class ComprehensiveAnalysis {
  final String symbol;
  final String exchange;
  final DateTime timestamp;
  final PriceData priceData;
  final Map<String, TechnicalIndicators> technicalIndicators;
  final Map<String, Scenario> scenarios;
  final Recommendation recommendation;

  /// Market type (spot, futures, margin, options)
  final MarketType? marketType;

  /// Futures-specific data (only present for futures market type)
  final FuturesData? futuresData;

  /// Margin-specific data (only present for margin market type)
  final MarginData? marginData;

  /// Options-specific data (only present for options market type)
  final OptionsData? optionsData;

  /// Key price levels (support and resistance)
  final KeyLevels? keyLevels;

  /// Risk assessment
  final RiskAssessment? riskAssessment;

  ComprehensiveAnalysis({
    required this.symbol,
    required this.exchange,
    required this.timestamp,
    required this.priceData,
    required this.technicalIndicators,
    required this.scenarios,
    required this.recommendation,
    this.marketType,
    this.futuresData,
    this.marginData,
    this.optionsData,
    this.keyLevels,
    this.riskAssessment,
  });

  factory ComprehensiveAnalysis.fromJson(Map<String, dynamic> json) {
    return ComprehensiveAnalysis(
      symbol: json['symbol'] as String? ?? '',
      exchange: json['exchange'] as String? ?? 'kucoin',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      priceData: PriceData.fromJson(
        json['current_price'] as Map<String, dynamic>? ??
            json['price_data'] as Map<String, dynamic>? ??
            {},
      ),
      technicalIndicators: _parseTechnicalIndicators(
        json['multi_timeframe'] ??
            json['technical_indicators'] ??
            json['technical_analysis'],
      ),
      scenarios: _parseScenariosFromList(json['scenarios']),
      recommendation: Recommendation.fromJson(
        json['recommendation'] as Map<String, dynamic>? ?? {},
      ),
      // Market type specific fields
      marketType: json['market_type'] != null
          ? MarketType.fromString(json['market_type'] as String)
          : null,
      futuresData: json['futures_data'] != null
          ? FuturesData.fromJson(json['futures_data'] as Map<String, dynamic>)
          : null,
      marginData: json['margin_data'] != null
          ? MarginData.fromJson(json['margin_data'] as Map<String, dynamic>)
          : null,
      optionsData: json['options_data'] != null
          ? OptionsData.fromJson(json['options_data'] as Map<String, dynamic>)
          : null,
      keyLevels: json['key_levels'] != null
          ? KeyLevels.fromJson(json['key_levels'] as Map<String, dynamic>)
          : null,
      riskAssessment: json['risk_assessment'] != null
          ? RiskAssessment.fromJson(
              json['risk_assessment'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'exchange': exchange,
      'timestamp': timestamp.toIso8601String(),
      'price_data': priceData.toJson(),
      'technical_indicators': technicalIndicators.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'scenarios': scenarios.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'recommendation': recommendation.toJson(),
      if (marketType != null) 'market_type': marketType!.value,
      if (futuresData != null) 'futures_data': futuresData!.toJson(),
      if (marginData != null) 'margin_data': marginData!.toJson(),
      if (optionsData != null) 'options_data': optionsData!.toJson(),
      if (keyLevels != null) 'key_levels': keyLevels!.toJson(),
      if (riskAssessment != null) 'risk_assessment': riskAssessment!.toJson(),
    };
  }

  static Map<String, TechnicalIndicators> _parseTechnicalIndicators(
    dynamic data,
  ) {
    if (data == null || data is! Map) return {};

    final Map<String, TechnicalIndicators> indicators = {};
    final dataMap = data as Map<String, dynamic>;

    for (var entry in dataMap.entries) {
      // Skip non-timeframe keys like 'alignment'
      if (entry.key == 'alignment') continue;

      if (entry.value is Map<String, dynamic>) {
        final indicatorData = entry.value as Map<String, dynamic>;
        // Add timeframe to the data if not present
        if (!indicatorData.containsKey('timeframe')) {
          indicatorData['timeframe'] = entry.key;
        }
        indicators[entry.key] = TechnicalIndicators.fromJson(indicatorData);
      }
    }

    return indicators;
  }

  static Map<String, Scenario> _parseScenarios(dynamic data) {
    if (data == null || data is! Map) return {};

    return Map.fromEntries(
      (data as Map<String, dynamic>).entries.map(
            (e) => MapEntry(
              e.key,
              Scenario.fromJson(e.value as Map<String, dynamic>),
            ),
          ),
    );
  }

  static Map<String, Scenario> _parseScenariosFromList(dynamic data) {
    if (data == null) return {};

    // If it's already a Map, use the existing parser
    if (data is Map) return _parseScenarios(data);

    // If it's a List, convert to Map using type as key
    if (data is List) {
      final Map<String, Scenario> scenariosMap = {};
      for (var item in data) {
        if (item is Map<String, dynamic>) {
          final scenario = Scenario.fromJson(item);
          scenariosMap[scenario.type] = scenario;
        }
      }
      return scenariosMap;
    }

    return {};
  }

  // Computed properties
  bool get isStrongBuy =>
      recommendation.action == 'BUY' && recommendation.confidence >= 0.8;

  bool get isStrongSell =>
      recommendation.action == 'SELL' && recommendation.confidence >= 0.8;

  bool get isBullish => (scenarios['bullish']?.probability ?? 0) > 0.6;

  bool get isBearish => (scenarios['bearish']?.probability ?? 0) > 0.6;

  Scenario? get mostLikelyScenario {
    if (scenarios.isEmpty) return null;
    return scenarios.values.reduce(
      (a, b) => a.probability > b.probability ? a : b,
    );
  }
}

/// Price data for a trading pair
class PriceData {
  final double last;
  final double bid;
  final double ask;
  final double volume;
  final double high24h;
  final double low24h;
  final double change24h;
  final double changePercent24h;

  PriceData({
    required this.last,
    required this.bid,
    required this.ask,
    required this.volume,
    required this.high24h,
    required this.low24h,
    required this.change24h,
    required this.changePercent24h,
  });

  factory PriceData.fromJson(Map<String, dynamic> json) {
    return PriceData(
      last: (json['current'] as num?)?.toDouble() ??
          (json['last'] as num?)?.toDouble() ??
          0.0,
      bid: (json['bid'] as num?)?.toDouble() ?? 0.0,
      ask: (json['ask'] as num?)?.toDouble() ?? 0.0,
      volume: (json['volume_24h'] as num?)?.toDouble() ??
          (json['volume'] as num?)?.toDouble() ??
          0.0,
      high24h: (json['high_24h'] as num?)?.toDouble() ?? 0.0,
      low24h: (json['low_24h'] as num?)?.toDouble() ?? 0.0,
      change24h: (json['change_24h'] as num?)?.toDouble() ?? 0.0,
      changePercent24h: (json['change_percent_24h'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'last': last,
      'bid': bid,
      'ask': ask,
      'volume': volume,
      'high_24h': high24h,
      'low_24h': low24h,
      'change_24h': change24h,
      'change_percent_24h': changePercent24h,
    };
  }

  // Computed properties
  double get spread => ask - bid;
  double get spreadPercent => (spread / last) * 100;
  double get midPrice => (bid + ask) / 2;
  bool get isRising => change24h > 0;
}

/// Technical indicators for a specific timeframe
class TechnicalIndicators {
  final String timeframe;
  final RSIData? rsi;
  final MACDData? macd;
  final BollingerBandsData? bollingerBands;
  final EMAData? ema;
  final VolumeData? volume;

  TechnicalIndicators({
    required this.timeframe,
    this.rsi,
    this.macd,
    this.bollingerBands,
    this.ema,
    this.volume,
  });

  factory TechnicalIndicators.fromJson(Map<String, dynamic> json) {
    // Handle simplified API format where rsi is a number directly
    RSIData? rsiData;
    if (json['rsi'] != null) {
      if (json['rsi'] is Map) {
        rsiData = RSIData.fromJson(json['rsi'] as Map<String, dynamic>);
      } else if (json['rsi'] is num) {
        rsiData = RSIData(
          value: (json['rsi'] as num).toDouble(),
          signal: json['signal'] as String? ?? 'neutral',
        );
      }
    }

    return TechnicalIndicators(
      timeframe: json['timeframe'] as String? ?? '',
      rsi: rsiData,
      macd: json['macd'] != null
          ? MACDData.fromJson(json['macd'] as Map<String, dynamic>)
          : null,
      bollingerBands: json['bollinger_bands'] != null
          ? BollingerBandsData.fromJson(
              json['bollinger_bands'] as Map<String, dynamic>,
            )
          : null,
      ema: json['ema'] != null
          ? EMAData.fromJson(json['ema'] as Map<String, dynamic>)
          : null,
      volume: json['volume'] != null
          ? VolumeData.fromJson(json['volume'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeframe': timeframe,
      if (rsi != null) 'rsi': rsi!.toJson(),
      if (macd != null) 'macd': macd!.toJson(),
      if (bollingerBands != null) 'bollinger_bands': bollingerBands!.toJson(),
      if (ema != null) 'ema': ema!.toJson(),
      if (volume != null) 'volume': volume!.toJson(),
    };
  }
}

/// RSI (Relative Strength Index) data
class RSIData {
  final double value;
  final String signal; // 'overbought', 'oversold', 'neutral'

  RSIData({
    required this.value,
    required this.signal,
  });

  factory RSIData.fromJson(Map<String, dynamic> json) {
    return RSIData(
      value: (json['value'] as num?)?.toDouble() ?? 50.0,
      signal: json['signal'] as String? ?? 'neutral',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'signal': signal,
    };
  }

  bool get isOverbought => value > 70;
  bool get isOversold => value < 30;
}

/// MACD (Moving Average Convergence Divergence) data
class MACDData {
  final double macd;
  final double signal;
  final double histogram;
  final String trend; // 'bullish', 'bearish', 'neutral'

  MACDData({
    required this.macd,
    required this.signal,
    required this.histogram,
    required this.trend,
  });

  factory MACDData.fromJson(Map<String, dynamic> json) {
    return MACDData(
      macd: (json['macd'] as num?)?.toDouble() ?? 0.0,
      signal: (json['signal'] as num?)?.toDouble() ?? 0.0,
      histogram: (json['histogram'] as num?)?.toDouble() ?? 0.0,
      trend: json['trend'] as String? ?? 'neutral',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'macd': macd,
      'signal': signal,
      'histogram': histogram,
      'trend': trend,
    };
  }

  bool get isBullish => histogram > 0;
  bool get isBearish => histogram < 0;
}

/// Bollinger Bands data
class BollingerBandsData {
  final double upper;
  final double middle;
  final double lower;
  final double currentPrice;
  final String position; // 'above_upper', 'below_lower', 'within_bands'

  BollingerBandsData({
    required this.upper,
    required this.middle,
    required this.lower,
    required this.currentPrice,
    required this.position,
  });

  factory BollingerBandsData.fromJson(Map<String, dynamic> json) {
    return BollingerBandsData(
      upper: (json['upper'] as num?)?.toDouble() ?? 0.0,
      middle: (json['middle'] as num?)?.toDouble() ?? 0.0,
      lower: (json['lower'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      position: json['position'] as String? ?? 'within_bands',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'upper': upper,
      'middle': middle,
      'lower': lower,
      'current_price': currentPrice,
      'position': position,
    };
  }

  bool get isAboveUpper => currentPrice > upper;
  bool get isBelowLower => currentPrice < lower;
  double get bandWidth => upper - lower;
}

/// EMA (Exponential Moving Average) data
class EMAData {
  final double ema20;
  final double ema50;
  final double ema200;
  final String trend; // 'bullish', 'bearish', 'neutral'

  EMAData({
    required this.ema20,
    required this.ema50,
    required this.ema200,
    required this.trend,
  });

  factory EMAData.fromJson(Map<String, dynamic> json) {
    return EMAData(
      ema20: (json['ema_20'] as num?)?.toDouble() ?? 0.0,
      ema50: (json['ema_50'] as num?)?.toDouble() ?? 0.0,
      ema200: (json['ema_200'] as num?)?.toDouble() ?? 0.0,
      trend: json['trend'] as String? ?? 'neutral',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ema_20': ema20,
      'ema_50': ema50,
      'ema_200': ema200,
      'trend': trend,
    };
  }

  bool get isGoldenCross => ema20 > ema50 && ema50 > ema200;
  bool get isDeathCross => ema20 < ema50 && ema50 < ema200;
}

/// Volume data
class VolumeData {
  final double current;
  final double average;
  final String trend; // 'increasing', 'decreasing', 'stable'

  VolumeData({
    required this.current,
    required this.average,
    required this.trend,
  });

  factory VolumeData.fromJson(Map<String, dynamic> json) {
    return VolumeData(
      current: (json['current'] as num?)?.toDouble() ?? 0.0,
      average: (json['average'] as num?)?.toDouble() ?? 0.0,
      trend: json['trend'] as String? ?? 'stable',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': current,
      'average': average,
      'trend': trend,
    };
  }

  bool get isAboveAverage => current > average;
  double get volumeRatio => average > 0 ? current / average : 0;
}

/// Market scenario with probability
class Scenario {
  final String type; // 'bullish', 'bearish', 'neutral'
  final double probability;
  final String description;
  final List<String> conditions;
  final double? targetPrice;
  final double? stopLoss;

  Scenario({
    required this.type,
    required this.probability,
    required this.description,
    required this.conditions,
    this.targetPrice,
    this.stopLoss,
  });

  factory Scenario.fromJson(Map<String, dynamic> json) {
    return Scenario(
      type: json['type'] as String? ?? 'neutral',
      probability: (json['probability'] as num?)?.toDouble() ??
          (json['change_percent'] as num?)?.toDouble() ??
          0.0,
      description: json['description'] as String? ?? '',
      conditions:
          (json['conditions'] as List?)?.map((e) => e.toString()).toList() ??
              (json['factors'] as List?)?.map((e) => e.toString()).toList() ??
              [],
      targetPrice: (json['target_price'] as num?)?.toDouble() ??
          (json['target'] as num?)?.toDouble(),
      stopLoss: (json['stop_loss'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'probability': probability,
      'description': description,
      'conditions': conditions,
      if (targetPrice != null) 'target_price': targetPrice,
      if (stopLoss != null) 'stop_loss': stopLoss,
    };
  }

  bool get isHighProbability => probability >= 0.7;
  bool get isMediumProbability => probability >= 0.4 && probability < 0.7;
  bool get isLowProbability => probability < 0.4;
}

/// AI-powered trading recommendation
class Recommendation {
  final String action; // 'BUY', 'SELL', 'WAIT'
  final double confidence;
  final double? entry;
  final double? stopLoss;
  final double? takeProfit;
  final List<String> reasoning;
  final List<String> risks;

  Recommendation({
    required this.action,
    required this.confidence,
    this.entry,
    this.stopLoss,
    this.takeProfit,
    required this.reasoning,
    required this.risks,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    // Handle reasoning as either List or String
    List<String> reasoningList = [];
    if (json['reasoning'] is List) {
      reasoningList =
          (json['reasoning'] as List).map((e) => e.toString()).toList();
    } else if (json['reasoning'] is String) {
      reasoningList = [json['reasoning'] as String];
    }

    return Recommendation(
      action: json['action'] as String? ?? 'WAIT',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      entry: (json['entry'] as num?)?.toDouble(),
      stopLoss: (json['stop_loss'] as num?)?.toDouble(),
      takeProfit: (json['take_profit'] as num?)?.toDouble(),
      reasoning: reasoningList,
      risks: (json['risks'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'confidence': confidence,
      if (entry != null) 'entry': entry,
      if (stopLoss != null) 'stop_loss': stopLoss,
      if (takeProfit != null) 'take_profit': takeProfit,
      'reasoning': reasoning,
      'risks': risks,
    };
  }

  bool get isHighConfidence => confidence >= 0.8;
  bool get isMediumConfidence => confidence >= 0.6 && confidence < 0.8;
  bool get isLowConfidence => confidence < 0.6;

  bool get isBuy => action == 'BUY';
  bool get isSell => action == 'SELL';
  bool get isWait => action == 'WAIT';

  double? get riskRewardRatio {
    if (entry == null || stopLoss == null || takeProfit == null) return null;
    final risk = (entry! - stopLoss!).abs();
    final reward = (takeProfit! - entry!).abs();
    return risk > 0 ? reward / risk : null;
  }
}
