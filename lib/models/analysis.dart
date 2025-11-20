/// Multi-timeframe Analysis Models
///
/// Models for market analysis across multiple timeframes
library;

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
  final double? rsi;
  final MACDValues? macd;
  final BollingerBands? bollinger;
  final String? trend;
  final String signal;
  final double strength;

  TimeframeAnalysis({
    this.rsi,
    this.macd,
    this.bollinger,
    this.trend,
    required this.signal,
    required this.strength,
  });

  factory TimeframeAnalysis.fromJson(Map<String, dynamic> json) {
    return TimeframeAnalysis(
      rsi: json['rsi']?.toDouble(),
      macd: json['macd'] != null ? MACDValues.fromJson(json['macd']) : null,
      bollinger: json['bollinger'] != null
          ? BollingerBands.fromJson(json['bollinger'])
          : null,
      trend: json['trend'] as String?,
      signal: json['signal'] as String? ?? 'neutral',
      strength: json['strength']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (rsi != null) 'rsi': rsi,
      if (macd != null) 'macd': macd!.toJson(),
      if (bollinger != null) 'bollinger': bollinger!.toJson(),
      if (trend != null) 'trend': trend,
      'signal': signal,
      'strength': strength,
    };
  }

  /// Helper to check if bullish
  bool get isBullish => signal.toLowerCase() == 'long' || signal.toLowerCase() == 'buy';

  /// Helper to check if bearish
  bool get isBearish => signal.toLowerCase() == 'short' || signal.toLowerCase() == 'sell';

  /// Helper to check if strong signal (>70%)
  bool get isStrongSignal => strength > 0.7;
}

/// Consensus analysis across timeframes
class AnalysisConsensus {
  final String direction;
  final double strength;
  final double confidence;
  final List<String> confirmingTimeframes;
  final List<String> conflictingTimeframes;

  AnalysisConsensus({
    required this.direction,
    required this.strength,
    required this.confidence,
    required this.confirmingTimeframes,
    required this.conflictingTimeframes,
  });

  factory AnalysisConsensus.fromJson(Map<String, dynamic> json) {
    return AnalysisConsensus(
      direction: json['direction'] as String? ?? 'neutral',
      strength: json['strength']?.toDouble() ?? 0.0,
      confidence: json['confidence']?.toDouble() ?? 0.0,
      confirmingTimeframes: (json['confirming_timeframes'] as List<dynamic>?)
              ?.map((t) => t.toString())
              .toList() ??
          [],
      conflictingTimeframes: (json['conflicting_timeframes'] as List<dynamic>?)
              ?.map((t) => t.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'direction': direction,
      'strength': strength,
      'confidence': confidence,
      'confirming_timeframes': confirmingTimeframes,
      'conflicting_timeframes': conflictingTimeframes,
    };
  }

  /// Helper to check if bullish
  bool get isBullish => direction.toLowerCase() == 'long' || direction.toLowerCase() == 'buy';

  /// Helper to check if bearish
  bool get isBearish => direction.toLowerCase() == 'short' || direction.toLowerCase() == 'sell';

  /// Helper to check if strong consensus (>70%)
  bool get isStrong => strength > 0.7;

  /// Helper to check if high confidence (>80%)
  bool get isHighConfidence => confidence > 0.8;

  /// Helper to check if all timeframes agree
  bool get hasFullAgreement => conflictingTimeframes.isEmpty;
}

/// Multi-timeframe analysis result
class MultiTimeframeAnalysis {
  final String symbol;
  final DateTime timestamp;
  final Map<String, TimeframeAnalysis> timeframes;
  final AnalysisConsensus consensus;

  MultiTimeframeAnalysis({
    required this.symbol,
    required this.timestamp,
    required this.timeframes,
    required this.consensus,
  });

  factory MultiTimeframeAnalysis.fromJson(Map<String, dynamic> json) {
    final timeframesData = json['timeframes'] as Map<String, dynamic>? ?? {};

    final timeframesMap = <String, TimeframeAnalysis>{};
    timeframesData.forEach((key, value) {
      timeframesMap[key] = TimeframeAnalysis.fromJson(value as Map<String, dynamic>);
    });

    return MultiTimeframeAnalysis(
      symbol: json['symbol'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      timeframes: timeframesMap,
      consensus: json['consensus'] != null
          ? AnalysisConsensus.fromJson(json['consensus'] as Map<String, dynamic>)
          : AnalysisConsensus(
              direction: 'neutral',
              strength: 0.0,
              confidence: 0.0,
              confirmingTimeframes: [],
              conflictingTimeframes: [],
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'timestamp': timestamp.toIso8601String(),
      'timeframes': timeframes.map((key, value) => MapEntry(key, value.toJson())),
      'consensus': consensus.toJson(),
    };
  }

  /// Get analysis for a specific timeframe
  TimeframeAnalysis? getTimeframe(String timeframe) {
    return timeframes[timeframe];
  }

  /// Get all available timeframes
  List<String> get availableTimeframes => timeframes.keys.toList();

  /// Check if timeframe is available
  bool hasTimeframe(String timeframe) => timeframes.containsKey(timeframe);
}
