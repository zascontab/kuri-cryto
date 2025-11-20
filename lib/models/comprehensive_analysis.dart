/// Análisis comprehensivo de mercado con AI
class ComprehensiveAnalysis {
  final String symbol;
  final String exchange;
  final DateTime timestamp;
  final CurrentPrice currentPrice;
  final TechnicalAnalysis technicalAnalysis;
  final MultiTimeframeAnalysis multiTimeframe;
  final List<CandleData> recentMovement;
  final KeyLevels keyLevels;
  final Recommendation recommendation;
  final List<MarketScenario> scenarios;
  final RiskAssessment riskAssessment;

  const ComprehensiveAnalysis({
    required this.symbol,
    required this.exchange,
    required this.timestamp,
    required this.currentPrice,
    required this.technicalAnalysis,
    required this.multiTimeframe,
    required this.recentMovement,
    required this.keyLevels,
    required this.recommendation,
    required this.scenarios,
    required this.riskAssessment,
  });

  factory ComprehensiveAnalysis.fromJson(Map<String, dynamic> json) {
    return ComprehensiveAnalysis(
      symbol: json['symbol'] as String,
      exchange: json['exchange'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      currentPrice: CurrentPrice.fromJson(json['current_price'] as Map<String, dynamic>),
      technicalAnalysis: TechnicalAnalysis.fromJson(json['technical_analysis'] as Map<String, dynamic>),
      multiTimeframe: MultiTimeframeAnalysis.fromJson(json['multi_timeframe'] as Map<String, dynamic>),
      recentMovement: (json['recent_movement'] as List)
          .map((e) => CandleData.fromJson(e as Map<String, dynamic>))
          .toList(),
      keyLevels: KeyLevels.fromJson(json['key_levels'] as Map<String, dynamic>),
      recommendation: Recommendation.fromJson(json['recommendation'] as Map<String, dynamic>),
      scenarios: (json['scenarios'] as List)
          .map((e) => MarketScenario.fromJson(e as Map<String, dynamic>))
          .toList(),
      riskAssessment: RiskAssessment.fromJson(json['risk_assessment'] as Map<String, dynamic>),
    );
  }
}

/// Precio actual y estadísticas 24h
class CurrentPrice {
  final double current;
  final double change24h;
  final double high24h;
  final double low24h;
  final double volume24h;

  const CurrentPrice({
    required this.current,
    required this.change24h,
    required this.high24h,
    required this.low24h,
    required this.volume24h,
  });

  factory CurrentPrice.fromJson(Map<String, dynamic> json) {
    return CurrentPrice(
      current: (json['current'] as num).toDouble(),
      change24h: (json['change_24h'] as num).toDouble(),
      high24h: (json['high_24h'] as num).toDouble(),
      low24h: (json['low_24h'] as num).toDouble(),
      volume24h: (json['volume_24h'] as num).toDouble(),
    );
  }

  bool get isPositiveChange => change24h >= 0;
}

/// Análisis técnico con indicadores
class TechnicalAnalysis {
  final RsiData rsi;
  final MacdData macd;
  final BollingerData bollinger;
  final EmaData ema;
  final String trend; // 'bullish', 'bearish', 'neutral'
  final double strength; // 0.0 a 1.0

  const TechnicalAnalysis({
    required this.rsi,
    required this.macd,
    required this.bollinger,
    required this.ema,
    required this.trend,
    required this.strength,
  });

  factory TechnicalAnalysis.fromJson(Map<String, dynamic> json) {
    return TechnicalAnalysis(
      rsi: RsiData.fromJson(json['rsi'] as Map<String, dynamic>),
      macd: MacdData.fromJson(json['macd'] as Map<String, dynamic>),
      bollinger: BollingerData.fromJson(json['bollinger'] as Map<String, dynamic>),
      ema: EmaData.fromJson(json['ema'] as Map<String, dynamic>),
      trend: json['trend'] as String,
      strength: (json['strength'] as num).toDouble(),
    );
  }

  bool get isBullish => trend == 'bullish';
  bool get isBearish => trend == 'bearish';
  bool get isNeutral => trend == 'neutral';
}

class RsiData {
  final double value;
  final String interpretation;
  final String signal; // 'oversold', 'overbought', 'neutral'

  const RsiData({
    required this.value,
    required this.interpretation,
    required this.signal,
  });

  factory RsiData.fromJson(Map<String, dynamic> json) {
    return RsiData(
      value: (json['value'] as num).toDouble(),
      interpretation: json['interpretation'] as String,
      signal: json['signal'] as String,
    );
  }

  bool get isOversold => signal == 'oversold' || value < 30;
  bool get isOverbought => signal == 'overbought' || value > 70;
}

class MacdData {
  final double value;
  final double signal;
  final double histogram;
  final String trend; // 'bullish', 'bearish', 'neutral'

  const MacdData({
    required this.value,
    required this.signal,
    required this.histogram,
    required this.trend,
  });

  factory MacdData.fromJson(Map<String, dynamic> json) {
    return MacdData(
      value: (json['value'] as num).toDouble(),
      signal: (json['signal'] as num).toDouble(),
      histogram: (json['histogram'] as num).toDouble(),
      trend: json['trend'] as String,
    );
  }
}

class BollingerData {
  final double upper;
  final double middle;
  final double lower;
  final String position; // 'upper', 'middle', 'lower'

  const BollingerData({
    required this.upper,
    required this.middle,
    required this.lower,
    required this.position,
  });

  factory BollingerData.fromJson(Map<String, dynamic> json) {
    return BollingerData(
      upper: (json['upper'] as num).toDouble(),
      middle: (json['middle'] as num).toDouble(),
      lower: (json['lower'] as num).toDouble(),
      position: json['position'] as String,
    );
  }
}

class EmaData {
  final double ema9;
  final double ema21;
  final double ema50;
  final String priceVsEma;

  const EmaData({
    required this.ema9,
    required this.ema21,
    required this.ema50,
    required this.priceVsEma,
  });

  factory EmaData.fromJson(Map<String, dynamic> json) {
    return EmaData(
      ema9: (json['ema_9'] as num).toDouble(),
      ema21: (json['ema_21'] as num).toDouble(),
      ema50: (json['ema_50'] as num).toDouble(),
      priceVsEma: json['price_vs_ema'] as String,
    );
  }
}

/// Análisis multi-temporalidad
class MultiTimeframeAnalysis {
  final TimeframeData oneMinute;
  final TimeframeData fiveMinutes;
  final TimeframeData fifteenMinutes;
  final TimeframeData oneHour;
  final String alignment; // 'bullish_aligned', 'bearish_aligned', 'not_aligned'

  const MultiTimeframeAnalysis({
    required this.oneMinute,
    required this.fiveMinutes,
    required this.fifteenMinutes,
    required this.oneHour,
    required this.alignment,
  });

  factory MultiTimeframeAnalysis.fromJson(Map<String, dynamic> json) {
    return MultiTimeframeAnalysis(
      oneMinute: TimeframeData.fromJson(json['1m'] as Map<String, dynamic>),
      fiveMinutes: TimeframeData.fromJson(json['5m'] as Map<String, dynamic>),
      fifteenMinutes: TimeframeData.fromJson(json['15m'] as Map<String, dynamic>),
      oneHour: TimeframeData.fromJson(json['1h'] as Map<String, dynamic>),
      alignment: json['alignment'] as String,
    );
  }

  bool get isAligned => alignment != 'not_aligned';
  bool get isBullishAligned => alignment == 'bullish_aligned';
  bool get isBearishAligned => alignment == 'bearish_aligned';
}

class TimeframeData {
  final double rsi;
  final String trend;
  final String signal;

  const TimeframeData({
    required this.rsi,
    required this.trend,
    required this.signal,
  });

  factory TimeframeData.fromJson(Map<String, dynamic> json) {
    return TimeframeData(
      rsi: (json['rsi'] as num).toDouble(),
      trend: json['trend'] as String,
      signal: json['signal'] as String,
    );
  }
}

/// Datos de vela (OHLCV)
class CandleData {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final String direction; // 'bullish', 'bearish'
  final double changePercent;

  const CandleData({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.direction,
    required this.changePercent,
  });

  factory CandleData.fromJson(Map<String, dynamic> json) {
    return CandleData(
      timestamp: DateTime.parse(json['timestamp'] as String),
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
      direction: json['direction'] as String,
      changePercent: (json['change_percent'] as num).toDouble(),
    );
  }

  bool get isBullish => direction == 'bullish';
}

/// Niveles clave de soporte y resistencia
class KeyLevels {
  final double support;
  final double resistance;
  final DistanceData distance;

  const KeyLevels({
    required this.support,
    required this.resistance,
    required this.distance,
  });

  factory KeyLevels.fromJson(Map<String, dynamic> json) {
    return KeyLevels(
      support: (json['support'] as num).toDouble(),
      resistance: (json['resistance'] as num).toDouble(),
      distance: DistanceData.fromJson(json['distance'] as Map<String, dynamic>),
    );
  }
}

class DistanceData {
  final double toSupportPercent;
  final double toResistancePercent;

  const DistanceData({
    required this.toSupportPercent,
    required this.toResistancePercent,
  });

  factory DistanceData.fromJson(Map<String, dynamic> json) {
    return DistanceData(
      toSupportPercent: (json['to_support_percent'] as num).toDouble(),
      toResistancePercent: (json['to_resistance_percent'] as num).toDouble(),
    );
  }
}

/// Recomendación de trading
class Recommendation {
  final String action; // 'BUY', 'SELL', 'WAIT'
  final double confidence;
  final List<String> reasoning;
  final double entryPrice;
  final double stopLoss;
  final double takeProfit;

  const Recommendation({
    required this.action,
    required this.confidence,
    required this.reasoning,
    required this.entryPrice,
    required this.stopLoss,
    required this.takeProfit,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      action: json['action'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      reasoning: List<String>.from(json['reasoning'] as List),
      entryPrice: (json['entry_price'] as num).toDouble(),
      stopLoss: (json['stop_loss'] as num).toDouble(),
      takeProfit: (json['take_profit'] as num).toDouble(),
    );
  }

  bool get isBuy => action == 'BUY';
  bool get isSell => action == 'SELL';
  bool get isWait => action == 'WAIT';
}

/// Escenario de mercado posible
class MarketScenario {
  final String name;
  final double probability;
  final double targetPrice;
  final double changePercent;
  final String timeframe;
  final String impact; // 'positive', 'negative', 'neutral'
  final String description;

  const MarketScenario({
    required this.name,
    required this.probability,
    required this.targetPrice,
    required this.changePercent,
    required this.timeframe,
    required this.impact,
    required this.description,
  });

  factory MarketScenario.fromJson(Map<String, dynamic> json) {
    return MarketScenario(
      name: json['name'] as String,
      probability: (json['probability'] as num).toDouble(),
      targetPrice: (json['target_price'] as num).toDouble(),
      changePercent: (json['change_percent'] as num).toDouble(),
      timeframe: json['timeframe'] as String,
      impact: json['impact'] as String,
      description: json['description'] as String,
    );
  }

  bool get isPositive => impact == 'positive';
  bool get isNegative => impact == 'negative';
}

/// Evaluación de riesgo
class RiskAssessment {
  final String level; // 'low', 'medium', 'high'
  final double score; // 0-100
  final List<String> factors;
  final String volatility; // 'low', 'medium', 'high'

  const RiskAssessment({
    required this.level,
    required this.score,
    required this.factors,
    required this.volatility,
  });

  factory RiskAssessment.fromJson(Map<String, dynamic> json) {
    return RiskAssessment(
      level: json['level'] as String,
      score: (json['score'] as num).toDouble(),
      factors: List<String>.from(json['factors'] as List),
      volatility: json['volatility'] as String,
    );
  }

  bool get isLowRisk => level == 'low';
  bool get isMediumRisk => level == 'medium';
  bool get isHighRisk => level == 'high';
}
