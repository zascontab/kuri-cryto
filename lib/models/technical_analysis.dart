/// Detailed technical analysis model
///
/// Comprehensive technical indicators for a single timeframe
class TechnicalAnalysis {
  final String timeframe;
  final RSIIndicator? rsi;
  final MACDIndicator? macd;
  final BollingerBandsIndicator? bollingerBands;
  final EMAIndicator? ema;
  final VolumeIndicator? volume;
  final StochasticIndicator? stochastic;
  final String? overallTrend; // 'bullish', 'bearish', 'neutral'
  final double? trendStrength; // 0-1

  const TechnicalAnalysis({
    required this.timeframe,
    this.rsi,
    this.macd,
    this.bollingerBands,
    this.ema,
    this.volume,
    this.stochastic,
    this.overallTrend,
    this.trendStrength,
  });

  factory TechnicalAnalysis.fromJson(Map<String, dynamic> json) {
    return TechnicalAnalysis(
      timeframe: json['timeframe'] as String? ?? '',
      rsi: json['rsi'] != null
          ? RSIIndicator.fromJson(json['rsi'] is Map
              ? json['rsi'] as Map<String, dynamic>
              : {'value': json['rsi']})
          : null,
      macd: json['macd'] != null
          ? MACDIndicator.fromJson(json['macd'] as Map<String, dynamic>)
          : null,
      bollingerBands: json['bollinger_bands'] != null
          ? BollingerBandsIndicator.fromJson(
              json['bollinger_bands'] as Map<String, dynamic>)
          : null,
      ema: json['ema'] != null
          ? EMAIndicator.fromJson(json['ema'] as Map<String, dynamic>)
          : null,
      volume: json['volume'] != null
          ? VolumeIndicator.fromJson(json['volume'] is Map
              ? json['volume'] as Map<String, dynamic>
              : {'current': json['volume']})
          : null,
      stochastic: json['stochastic'] != null
          ? StochasticIndicator.fromJson(
              json['stochastic'] as Map<String, dynamic>)
          : null,
      overallTrend:
          json['overall_trend'] as String? ?? json['trend'] as String?,
      trendStrength: (json['trend_strength'] as num?)?.toDouble(),
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
      if (stochastic != null) 'stochastic': stochastic!.toJson(),
      if (overallTrend != null) 'overall_trend': overallTrend,
      if (trendStrength != null) 'trend_strength': trendStrength,
    };
  }

  // Helpers

  bool get isBullish => overallTrend == 'bullish';
  bool get isBearish => overallTrend == 'bearish';
  bool get isNeutral => overallTrend == 'neutral';
  bool get hasStrongTrend => (trendStrength ?? 0) > 0.7;

  /// Verifica si hay señal de compra fuerte
  bool get hasStrongBuySignal {
    return isBullish &&
        (rsi?.isOversold ?? false) &&
        (macd?.isBullish ?? false) &&
        (volume?.isIncreasing ?? false);
  }

  /// Verifica si hay señal de venta fuerte
  bool get hasStrongSellSignal {
    return isBearish &&
        (rsi?.isOverbought ?? false) &&
        (macd?.isBearish ?? false) &&
        (volume?.isIncreasing ?? false);
  }
}

/// RSI (Relative Strength Index) indicator
class RSIIndicator {
  final double value;
  final String signal; // 'overbought', 'oversold', 'neutral'
  final double? period; // Usually 14

  const RSIIndicator({
    required this.value,
    required this.signal,
    this.period,
  });

  factory RSIIndicator.fromJson(Map<String, dynamic> json) {
    final value = (json['value'] as num?)?.toDouble() ?? 50.0;
    String signal = json['signal'] as String? ?? 'neutral';

    // Auto-determine signal if not provided
    if (signal == 'neutral') {
      if (value > 70) {
        signal = 'overbought';
      } else if (value < 30) {
        signal = 'oversold';
      }
    }

    return RSIIndicator(
      value: value,
      signal: signal,
      period: (json['period'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'signal': signal,
      if (period != null) 'period': period,
    };
  }

  bool get isOverbought => value > 70;
  bool get isOversold => value < 30;
  bool get isNeutral => value >= 30 && value <= 70;
}

/// MACD (Moving Average Convergence Divergence) indicator
class MACDIndicator {
  final double macd;
  final double signal;
  final double histogram;
  final String trend; // 'bullish', 'bearish', 'neutral'

  const MACDIndicator({
    required this.macd,
    required this.signal,
    required this.histogram,
    required this.trend,
  });

  factory MACDIndicator.fromJson(Map<String, dynamic> json) {
    final histogram = (json['histogram'] as num?)?.toDouble() ?? 0.0;
    String trend = json['trend'] as String? ?? 'neutral';

    // Auto-determine trend if not provided
    if (trend == 'neutral') {
      if (histogram > 0) {
        trend = 'bullish';
      } else if (histogram < 0) {
        trend = 'bearish';
      }
    }

    return MACDIndicator(
      macd: (json['macd'] as num?)?.toDouble() ?? 0.0,
      signal: (json['signal'] as num?)?.toDouble() ?? 0.0,
      histogram: histogram,
      trend: trend,
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
  bool get hasCrossover => (macd - signal).abs() < 0.1; // Close to crossing
}

/// Bollinger Bands indicator
class BollingerBandsIndicator {
  final double upper;
  final double middle;
  final double lower;
  final double currentPrice;
  final String position; // 'above_upper', 'below_lower', 'within_bands'
  final double? bandwidth; // (upper - lower) / middle

  const BollingerBandsIndicator({
    required this.upper,
    required this.middle,
    required this.lower,
    required this.currentPrice,
    required this.position,
    this.bandwidth,
  });

  factory BollingerBandsIndicator.fromJson(Map<String, dynamic> json) {
    final upper = (json['upper'] as num?)?.toDouble() ?? 0.0;
    final middle = (json['middle'] as num?)?.toDouble() ?? 0.0;
    final lower = (json['lower'] as num?)?.toDouble() ?? 0.0;
    final currentPrice = (json['current_price'] as num?)?.toDouble() ?? 0.0;

    String position = json['position'] as String? ?? 'within_bands';

    // Auto-determine position if not provided
    if (position == 'within_bands' && currentPrice > 0) {
      if (currentPrice > upper) {
        position = 'above_upper';
      } else if (currentPrice < lower) {
        position = 'below_lower';
      }
    }

    final bandwidth = middle > 0 ? (upper - lower) / middle : null;

    return BollingerBandsIndicator(
      upper: upper,
      middle: middle,
      lower: lower,
      currentPrice: currentPrice,
      position: position,
      bandwidth: bandwidth,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'upper': upper,
      'middle': middle,
      'lower': lower,
      'current_price': currentPrice,
      'position': position,
      if (bandwidth != null) 'bandwidth': bandwidth,
    };
  }

  bool get isAboveUpper => currentPrice > upper;
  bool get isBelowLower => currentPrice < lower;
  bool get isWithinBands => !isAboveUpper && !isBelowLower;
  bool get isSqueeze => bandwidth != null && bandwidth! < 0.1; // Narrow bands
}

/// EMA (Exponential Moving Average) indicator
class EMAIndicator {
  final double? ema20;
  final double? ema50;
  final double? ema200;
  final String trend; // 'bullish', 'bearish', 'neutral'
  final bool? goldenCross; // EMA20 > EMA50 > EMA200
  final bool? deathCross; // EMA20 < EMA50 < EMA200

  const EMAIndicator({
    this.ema20,
    this.ema50,
    this.ema200,
    required this.trend,
    this.goldenCross,
    this.deathCross,
  });

  factory EMAIndicator.fromJson(Map<String, dynamic> json) {
    final ema20 = (json['ema_20'] as num?)?.toDouble() ??
        (json['ema20'] as num?)?.toDouble();
    final ema50 = (json['ema_50'] as num?)?.toDouble() ??
        (json['ema50'] as num?)?.toDouble();
    final ema200 = (json['ema_200'] as num?)?.toDouble() ??
        (json['ema200'] as num?)?.toDouble();

    bool? goldenCross;
    bool? deathCross;

    if (ema20 != null && ema50 != null && ema200 != null) {
      goldenCross = ema20 > ema50 && ema50 > ema200;
      deathCross = ema20 < ema50 && ema50 < ema200;
    }

    return EMAIndicator(
      ema20: ema20,
      ema50: ema50,
      ema200: ema200,
      trend: json['trend'] as String? ?? 'neutral',
      goldenCross: goldenCross ?? json['golden_cross'] as bool?,
      deathCross: deathCross ?? json['death_cross'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (ema20 != null) 'ema_20': ema20,
      if (ema50 != null) 'ema_50': ema50,
      if (ema200 != null) 'ema_200': ema200,
      'trend': trend,
      if (goldenCross != null) 'golden_cross': goldenCross,
      if (deathCross != null) 'death_cross': deathCross,
    };
  }

  bool get isBullish => trend == 'bullish' || (goldenCross ?? false);
  bool get isBearish => trend == 'bearish' || (deathCross ?? false);
}

/// Volume indicator
class VolumeIndicator {
  final double current;
  final double average;
  final String trend; // 'increasing', 'decreasing', 'stable'
  final double? ratio; // current / average

  const VolumeIndicator({
    required this.current,
    required this.average,
    required this.trend,
    this.ratio,
  });

  factory VolumeIndicator.fromJson(Map<String, dynamic> json) {
    final current = (json['current'] as num?)?.toDouble() ?? 0.0;
    final average = (json['average'] as num?)?.toDouble() ?? 0.0;
    final ratio = average > 0 ? current / average : null;

    return VolumeIndicator(
      current: current,
      average: average,
      trend: json['trend'] as String? ?? 'stable',
      ratio: ratio ?? (json['ratio'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': current,
      'average': average,
      'trend': trend,
      if (ratio != null) 'ratio': ratio,
    };
  }

  bool get isIncreasing => trend == 'increasing';
  bool get isDecreasing => trend == 'decreasing';
  bool get isAboveAverage => current > average;
  bool get isSignificantlyAboveAverage => (ratio ?? 0) > 1.5;
}

/// Stochastic oscillator indicator
class StochasticIndicator {
  final double k; // %K line
  final double d; // %D line (signal)
  final String signal; // 'overbought', 'oversold', 'neutral'

  const StochasticIndicator({
    required this.k,
    required this.d,
    required this.signal,
  });

  factory StochasticIndicator.fromJson(Map<String, dynamic> json) {
    final k = (json['k'] as num?)?.toDouble() ?? 50.0;
    final d = (json['d'] as num?)?.toDouble() ?? 50.0;

    String signal = json['signal'] as String? ?? 'neutral';

    // Auto-determine signal if not provided
    if (signal == 'neutral') {
      if (k > 80 && d > 80) {
        signal = 'overbought';
      } else if (k < 20 && d < 20) {
        signal = 'oversold';
      }
    }

    return StochasticIndicator(
      k: k,
      d: d,
      signal: signal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'k': k,
      'd': d,
      'signal': signal,
    };
  }

  bool get isOverbought => k > 80 && d > 80;
  bool get isOversold => k < 20 && d < 20;
  bool get hasBullishCrossover => k > d && (k - d) < 5; // K crossing above D
  bool get hasBearishCrossover => k < d && (d - k) < 5; // K crossing below D
}
