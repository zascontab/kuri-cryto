/// Análisis de sentimiento de mercado
///
/// Analiza el sentimiento general del mercado basado en múltiples fuentes
/// como noticias, Twitter, Reddit, etc.
class SentimentAnalysis {
  /// Sentimiento general (0.0 = muy negativo, 1.0 = muy positivo)
  final double overall;

  /// Tendencia del sentimiento ('bullish', 'bearish', 'neutral')
  final String trend;

  /// Fuentes de datos analizadas (ej: ['news', 'twitter', 'reddit'])
  final List<String> sources;

  /// Nivel de confianza del análisis (0.0 - 1.0)
  final double confidence;

  const SentimentAnalysis({
    required this.overall,
    required this.trend,
    required this.sources,
    required this.confidence,
  });

  factory SentimentAnalysis.fromJson(Map<String, dynamic> json) {
    return SentimentAnalysis(
      overall: (json['overall'] as num?)?.toDouble() ?? 0.5,
      trend: json['trend'] as String? ?? 'neutral',
      sources: json['sources'] != null
          ? List<String>.from(json['sources'] as List)
          : [],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall': overall,
      'trend': trend,
      'sources': sources,
      'confidence': confidence,
    };
  }

  /// Indica si el sentimiento es alcista (bullish)
  bool get isBullish => trend.toLowerCase() == 'bullish';

  /// Indica si el sentimiento es bajista (bearish)
  bool get isBearish => trend.toLowerCase() == 'bearish';

  /// Indica si el sentimiento es neutral
  bool get isNeutral => trend.toLowerCase() == 'neutral';

  /// Indica si el sentimiento es muy positivo (>= 70%)
  bool get isVeryPositive => overall >= 0.70;

  /// Indica si el sentimiento es muy negativo (<= 30%)
  bool get isVeryNegative => overall <= 0.30;

  /// Indica si la confianza es alta (>= 70%)
  bool get isHighConfidence => confidence >= 0.70;

  /// Porcentaje de sentimiento positivo
  int get positivePercent => (overall * 100).round();

  /// Emoji representativo del sentimiento
  String get emoji {
    if (overall >= 0.70) return '😊';
    if (overall >= 0.55) return '🙂';
    if (overall >= 0.45) return '😐';
    if (overall >= 0.30) return '😕';
    return '😢';
  }

  /// Color sugerido para UI
  String get colorHex {
    if (isBullish) return '#10B981'; // Green
    if (isBearish) return '#EF4444'; // Red
    return '#6B7280'; // Gray
  }
}
