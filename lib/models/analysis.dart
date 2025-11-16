/// Multi-timeframe Analysis Models
///
/// Models for market analysis across multiple timeframes

/// Timeframe enum
enum Timeframe {
  m1('1m'),
  m3('3m'),
  m5('5m'),
  m15('15m'),
  m30('30m'),
  h1('1h'),
  h4('4h'),
  d1('1d');

  final String value;
  const Timeframe(this.value);

  static Timeframe fromString(String value) {
    return Timeframe.values.firstWhere(
      (t) => t.value == value,
      orElse: () => Timeframe.m5,
    );
  }
}

/// Indicator values for a specific timeframe
class IndicatorValues {
  final double? rsi;
  final MACDValues? macd;
  final BollingerBands? bollinger;
  final double? volume;

  IndicatorValues({
    this.rsi,
    this.macd,
    this.bollinger,
    this.volume,
  });

  factory IndicatorValues.fromJson(Map<String, dynamic> json) {
    return IndicatorValues(
      rsi: json['rsi']?.toDouble(),
      macd: json['macd'] != null ? MACDValues.fromJson(json['macd']) : null,
      bollinger: json['bollinger'] != null
          ? BollingerBands.fromJson(json['bollinger'])
          : null,
      volume: json['volume']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rsi': rsi,
      'macd': macd?.toJson(),
      'bollinger': bollinger?.toJson(),
      'volume': volume,
    };
  }
}

/// MACD indicator values
class MACDValues {
  final double macd;
  final double signal;
  final double histogram;

  MACDValues({
    required this.macd,
    required this.signal,
    required this.histogram,
  });

  factory MACDValues.fromJson(Map<String, dynamic> json) {
    return MACDValues(
      macd: json['macd']?.toDouble() ?? 0.0,
      signal: json['signal']?.toDouble() ?? 0.0,
      histogram: json['histogram']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'macd': macd,
      'signal': signal,
      'histogram': histogram,
    };
  }
}

/// Bollinger Bands values
class BollingerBands {
  final double upper;
  final double middle;
  final double lower;

  BollingerBands({
    required this.upper,
    required this.middle,
    required this.lower,
  });

  factory BollingerBands.fromJson(Map<String, dynamic> json) {
    return BollingerBands(
      upper: json['upper']?.toDouble() ?? 0.0,
      middle: json['middle']?.toDouble() ?? 0.0,
      lower: json['lower']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'upper': upper,
      'middle': middle,
      'lower': lower,
    };
  }
}

/// Signal type
enum SignalType {
  buy,
  sell,
  neutral;

  static SignalType fromString(String value) {
    return SignalType.values.firstWhere(
      (t) => t.name == value.toLowerCase(),
      orElse: () => SignalType.neutral,
    );
  }
}

/// Analysis for a specific timeframe
class TimeframeAnalysis {
  final Timeframe timeframe;
  final IndicatorValues indicators;
  final SignalType signal;
  final double confidence;
  final String? recommendation;

  TimeframeAnalysis({
    required this.timeframe,
    required this.indicators,
    required this.signal,
    required this.confidence,
    this.recommendation,
  });

  factory TimeframeAnalysis.fromJson(Map<String, dynamic> json) {
    return TimeframeAnalysis(
      timeframe: Timeframe.fromString(json['timeframe'] ?? '5m'),
      indicators: IndicatorValues.fromJson(json['indicators'] ?? {}),
      signal: SignalType.fromString(json['signal'] ?? 'neutral'),
      confidence: json['confidence']?.toDouble() ?? 0.0,
      recommendation: json['recommendation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeframe': timeframe.value,
      'indicators': indicators.toJson(),
      'signal': signal.name,
      'confidence': confidence,
      'recommendation': recommendation,
    };
  }
}

/// Multi-timeframe analysis result
class MultiTimeframeAnalysis {
  final String symbol;
  final double currentPrice;
  final List<TimeframeAnalysis> timeframes;
  final SignalType consensusSignal;
  final double consensusConfidence;
  final DateTime timestamp;

  MultiTimeframeAnalysis({
    required this.symbol,
    required this.currentPrice,
    required this.timeframes,
    required this.consensusSignal,
    required this.consensusConfidence,
    required this.timestamp,
  });

  factory MultiTimeframeAnalysis.fromJson(Map<String, dynamic> json) {
    final timeframesData = json['timeframes'] as List<dynamic>? ?? [];

    return MultiTimeframeAnalysis(
      symbol: json['symbol'] ?? '',
      currentPrice: json['current_price']?.toDouble() ?? 0.0,
      timeframes: timeframesData
          .map((t) => TimeframeAnalysis.fromJson(t as Map<String, dynamic>))
          .toList(),
      consensusSignal: SignalType.fromString(json['consensus_signal'] ?? 'neutral'),
      consensusConfidence: json['consensus_confidence']?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'current_price': currentPrice,
      'timeframes': timeframes.map((t) => t.toJson()).toList(),
      'consensus_signal': consensusSignal.name,
      'consensus_confidence': consensusConfidence,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Get analysis for a specific timeframe
  TimeframeAnalysis? getTimeframe(Timeframe timeframe) {
    try {
      return timeframes.firstWhere((t) => t.timeframe == timeframe);
    } catch (_) {
      return null;
    }
  }
}
