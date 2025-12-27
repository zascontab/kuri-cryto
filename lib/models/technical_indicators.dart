/// Technical indicators model for enhanced trading
class TechnicalIndicators {
  final double? rsi;
  final BollingerBands? bollingerBands;
  final MACD? macd;
  final DateTime timestamp;
  final String symbol;
  final String timeframe;

  const TechnicalIndicators({
    this.rsi,
    this.bollingerBands,
    this.macd,
    required this.timestamp,
    required this.symbol,
    required this.timeframe,
  });

  factory TechnicalIndicators.fromJson(Map<String, dynamic> json) {
    return TechnicalIndicators(
      rsi: json['rsi']?.toDouble(),
      bollingerBands: json['bollingerBands'] != null
          ? BollingerBands.fromJson(json['bollingerBands'])
          : null,
      macd: json['macd'] != null ? MACD.fromJson(json['macd']) : null,
      timestamp: DateTime.parse(json['timestamp']),
      symbol: json['symbol'] ?? '',
      timeframe: json['timeframe'] ?? '1h',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rsi': rsi,
      'bollingerBands': bollingerBands?.toJson(),
      'macd': macd?.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'symbol': symbol,
      'timeframe': timeframe,
    };
  }

  TechnicalIndicators copyWith({
    double? rsi,
    BollingerBands? bollingerBands,
    MACD? macd,
    DateTime? timestamp,
    String? symbol,
    String? timeframe,
  }) {
    return TechnicalIndicators(
      rsi: rsi ?? this.rsi,
      bollingerBands: bollingerBands ?? this.bollingerBands,
      macd: macd ?? this.macd,
      timestamp: timestamp ?? this.timestamp,
      symbol: symbol ?? this.symbol,
      timeframe: timeframe ?? this.timeframe,
    );
  }

  /// Check if indicators are fresh (within last 5 minutes)
  bool get isFresh {
    return DateTime.now().difference(timestamp).inMinutes < 5;
  }

  /// Check if any indicators are available
  bool get hasIndicators {
    return rsi != null || bollingerBands != null || macd != null;
  }

  /// Get overall signal strength (0-100)
  double get signalStrength {
    if (!hasIndicators) return 0;

    double strength = 0;
    int count = 0;

    if (rsi != null) {
      // RSI signal strength
      if (rsi! <= 30) {
        strength += 80; // Oversold
      } else if (rsi! >= 70) {
        strength += 80; // Overbought
      } else {
        strength += 50; // Neutral
      }
      count++;
    }

    if (bollingerBands != null) {
      strength += bollingerBands!.signalStrength;
      count++;
    }

    if (macd != null) {
      strength += macd!.signalStrength;
      count++;
    }

    return count > 0 ? strength / count : 0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TechnicalIndicators &&
        other.rsi == rsi &&
        other.bollingerBands == bollingerBands &&
        other.macd == macd &&
        other.timestamp == timestamp &&
        other.symbol == symbol &&
        other.timeframe == timeframe;
  }

  @override
  int get hashCode {
    return Object.hash(
      rsi,
      bollingerBands,
      macd,
      timestamp,
      symbol,
      timeframe,
    );
  }

  @override
  String toString() {
    return 'TechnicalIndicators(symbol: $symbol, timeframe: $timeframe, rsi: $rsi)';
  }
}

/// Enhanced Bollinger Bands model
class BollingerBands {
  final double upper;
  final double middle;
  final double lower;
  final double bandwidth;
  final double percentB;

  const BollingerBands({
    required this.upper,
    required this.middle,
    required this.lower,
    required this.bandwidth,
    required this.percentB,
  });

  factory BollingerBands.fromJson(Map<String, dynamic> json) {
    return BollingerBands(
      upper: json['upper']?.toDouble() ?? 0.0,
      middle: json['middle']?.toDouble() ?? 0.0,
      lower: json['lower']?.toDouble() ?? 0.0,
      bandwidth: json['bandwidth']?.toDouble() ?? 0.0,
      percentB: json['percentB']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'upper': upper,
      'middle': middle,
      'lower': lower,
      'bandwidth': bandwidth,
      'percentB': percentB,
    };
  }

  BollingerBands copyWith({
    double? upper,
    double? middle,
    double? lower,
    double? bandwidth,
    double? percentB,
  }) {
    return BollingerBands(
      upper: upper ?? this.upper,
      middle: middle ?? this.middle,
      lower: lower ?? this.lower,
      bandwidth: bandwidth ?? this.bandwidth,
      percentB: percentB ?? this.percentB,
    );
  }

  /// Check if price is near upper band (oversold signal)
  bool get isNearUpper => percentB > 0.8;

  /// Check if price is near lower band (oversold signal)
  bool get isNearLower => percentB < 0.2;

  /// Check if bands are squeezing (low volatility)
  bool get isSqueezing => bandwidth < 0.1;

  /// Get signal strength (0-100)
  double get signalStrength {
    if (isNearUpper || isNearLower) return 80;
    if (isSqueezing) return 60;
    return 50;
  }

  /// Get trading signal
  String get signal {
    if (isNearLower) return 'BUY';
    if (isNearUpper) return 'SELL';
    return 'HOLD';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BollingerBands &&
        other.upper == upper &&
        other.middle == middle &&
        other.lower == lower &&
        other.bandwidth == bandwidth &&
        other.percentB == percentB;
  }

  @override
  int get hashCode {
    return Object.hash(upper, middle, lower, bandwidth, percentB);
  }

  @override
  String toString() {
    return 'BollingerBands(upper: $upper, middle: $middle, lower: $lower)';
  }
}

/// Enhanced MACD model
class MACD {
  final double macd;
  final double signal;
  final double histogram;
  final String trend;

  const MACD({
    required this.macd,
    required this.signal,
    required this.histogram,
    required this.trend,
  });

  factory MACD.fromJson(Map<String, dynamic> json) {
    return MACD(
      macd: json['macd']?.toDouble() ?? 0.0,
      signal: json['signal']?.toDouble() ?? 0.0,
      histogram: json['histogram']?.toDouble() ?? 0.0,
      trend: json['trend'] ?? 'neutral',
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

  MACD copyWith({
    double? macd,
    double? signal,
    double? histogram,
    String? trend,
  }) {
    return MACD(
      macd: macd ?? this.macd,
      signal: signal ?? this.signal,
      histogram: histogram ?? this.histogram,
      trend: trend ?? this.trend,
    );
  }

  /// Check if MACD is bullish (above signal line)
  bool get isBullish => macd > signal;

  /// Check if MACD is bearish (below signal line)
  bool get isBearish => macd < signal;

  /// Check if histogram is increasing
  bool get isHistogramIncreasing => histogram > 0;

  /// Get signal strength (0-100)
  double get signalStrength {
    double strength = 50; // Base neutral strength

    if (isBullish && isHistogramIncreasing) {
      strength += 30;
    } else if (isBearish && !isHistogramIncreasing) {
      strength += 30;
    }

    // Add trend strength
    switch (trend.toLowerCase()) {
      case 'bullish':
        strength += 20;
        break;
      case 'bearish':
        strength += 20;
        break;
    }

    return strength.clamp(0, 100);
  }

  /// Get trading signal
  String get tradingSignal {
    if (isBullish && isHistogramIncreasing) return 'BUY';
    if (isBearish && !isHistogramIncreasing) return 'SELL';
    return 'HOLD';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MACD &&
        other.macd == macd &&
        other.signal == signal &&
        other.histogram == histogram &&
        other.trend == trend;
  }

  @override
  int get hashCode {
    return Object.hash(macd, signal, histogram, trend);
  }

  @override
  String toString() {
    return 'MACD(macd: $macd, signal: $signal, trend: $trend)';
  }
}
