/// Multi-timeframe analysis model
///
/// Provides analysis across multiple timeframes to identify
/// trend alignment and potential trading opportunities
class MultiTimeframeAnalysis {
  final Map<String, TimeframeData> timeframes;
  final String? alignment; // 'bullish', 'bearish', 'mixed'
  final double? alignmentScore; // 0-1, how aligned are the timeframes

  const MultiTimeframeAnalysis({
    required this.timeframes,
    this.alignment,
    this.alignmentScore,
  });

  factory MultiTimeframeAnalysis.fromJson(Map<String, dynamic> json) {
    final Map<String, TimeframeData> timeframesMap = {};

    // Parse timeframes
    json.forEach((key, value) {
      // Skip non-timeframe keys
      if (key == 'alignment' || key == 'alignment_score') return;

      if (value is Map<String, dynamic>) {
        timeframesMap[key] = TimeframeData.fromJson(value);
      }
    });

    return MultiTimeframeAnalysis(
      timeframes: timeframesMap,
      alignment: json['alignment'] as String?,
      alignmentScore: (json['alignment_score'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};

    // Add timeframes
    timeframes.forEach((key, value) {
      result[key] = value.toJson();
    });

    // Add metadata
    if (alignment != null) result['alignment'] = alignment;
    if (alignmentScore != null) result['alignment_score'] = alignmentScore;

    return result;
  }

  // Helpers

  /// Verifica si todos los timeframes están alineados alcistamente
  bool get isAlignedBullish => alignment == 'bullish';

  /// Verifica si todos los timeframes están alineados bajistamente
  bool get isAlignedBearish => alignment == 'bearish';

  /// Verifica si los timeframes están mezclados
  bool get isMixed => alignment == 'mixed';

  /// Verifica si hay fuerte alineación (score > 0.7)
  bool get hasStrongAlignment => (alignmentScore ?? 0) > 0.7;

  /// Obtiene el timeframe más corto
  TimeframeData? get shortestTimeframe {
    if (timeframes.isEmpty) return null;
    final keys = ['1m', '5m', '15m', '30m', '1h', '4h', '1d'];
    for (var key in keys) {
      if (timeframes.containsKey(key)) return timeframes[key];
    }
    return timeframes.values.first;
  }

  /// Obtiene el timeframe más largo
  TimeframeData? get longestTimeframe {
    if (timeframes.isEmpty) return null;
    final keys = ['1d', '4h', '1h', '30m', '15m', '5m', '1m'];
    for (var key in keys) {
      if (timeframes.containsKey(key)) return timeframes[key];
    }
    return timeframes.values.last;
  }

  /// Cuenta cuántos timeframes son alcistas
  int get bullishCount {
    return timeframes.values.where((tf) => tf.isBullish).length;
  }

  /// Cuenta cuántos timeframes son bajistas
  int get bearishCount {
    return timeframes.values.where((tf) => tf.isBearish).length;
  }

  /// Verifica si hay divergencia entre timeframes cortos y largos
  bool get hasDivergence {
    final short = shortestTimeframe;
    final long = longestTimeframe;
    if (short == null || long == null) return false;
    return short.trend != long.trend;
  }
}

/// Data for a specific timeframe
class TimeframeData {
  final String timeframe;
  final String trend; // 'bullish', 'bearish', 'neutral'
  final double? rsi;
  final String? rsiSignal; // 'overbought', 'oversold', 'neutral'
  final String? macdTrend;
  final String? emaTrend;
  final double? volume;
  final String? volumeTrend;

  const TimeframeData({
    required this.timeframe,
    required this.trend,
    this.rsi,
    this.rsiSignal,
    this.macdTrend,
    this.emaTrend,
    this.volume,
    this.volumeTrend,
  });

  factory TimeframeData.fromJson(Map<String, dynamic> json) {
    // Handle RSI as either a number or an object
    double? rsiValue;
    String? rsiSignalValue;

    if (json['rsi'] != null) {
      if (json['rsi'] is num) {
        rsiValue = (json['rsi'] as num).toDouble();
      } else if (json['rsi'] is Map) {
        final rsiMap = json['rsi'] as Map<String, dynamic>;
        rsiValue = (rsiMap['value'] as num?)?.toDouble();
        rsiSignalValue = rsiMap['signal'] as String?;
      }
    }

    return TimeframeData(
      timeframe: json['timeframe'] as String? ?? '',
      trend: json['trend'] as String? ?? 'neutral',
      rsi: rsiValue,
      rsiSignal: rsiSignalValue ?? json['rsi_signal'] as String?,
      macdTrend: json['macd_trend'] as String? ??
          (json['macd'] as Map<String, dynamic>?)?['trend'] as String?,
      emaTrend: json['ema_trend'] as String? ??
          (json['ema'] as Map<String, dynamic>?)?['trend'] as String?,
      volume: (json['volume'] is num)
          ? (json['volume'] as num).toDouble()
          : (json['volume'] is Map)
              ? ((json['volume'] as Map<String, dynamic>)['current'] as num?)
                  ?.toDouble()
              : null,
      volumeTrend: json['volume_trend'] as String? ??
          (json['volume'] as Map<String, dynamic>?)?['trend'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeframe': timeframe,
      'trend': trend,
      if (rsi != null) 'rsi': rsi,
      if (rsiSignal != null) 'rsi_signal': rsiSignal,
      if (macdTrend != null) 'macd_trend': macdTrend,
      if (emaTrend != null) 'ema_trend': emaTrend,
      if (volume != null) 'volume': volume,
      if (volumeTrend != null) 'volume_trend': volumeTrend,
    };
  }

  // Helpers

  /// Verifica si el trend es alcista
  bool get isBullish => trend == 'bullish';

  /// Verifica si el trend es bajista
  bool get isBearish => trend == 'bearish';

  /// Verifica si el trend es neutral
  bool get isNeutral => trend == 'neutral';

  /// Verifica si RSI está en sobreventa
  bool get isOversold => rsi != null && rsi! < 30;

  /// Verifica si RSI está en sobrecompra
  bool get isOverbought => rsi != null && rsi! > 70;

  /// Verifica si el volumen está aumentando
  bool get isVolumeIncreasing => volumeTrend == 'increasing';

  /// Verifica si todos los indicadores están alineados alcistamente
  bool get isFullyBullish {
    return isBullish &&
        (macdTrend == 'bullish' || macdTrend == null) &&
        (emaTrend == 'bullish' || emaTrend == null) &&
        (rsi == null || (rsi! > 30 && rsi! < 70));
  }

  /// Verifica si todos los indicadores están alineados bajistamente
  bool get isFullyBearish {
    return isBearish &&
        (macdTrend == 'bearish' || macdTrend == null) &&
        (emaTrend == 'bearish' || emaTrend == null) &&
        (rsi == null || (rsi! > 30 && rsi! < 70));
  }
}
