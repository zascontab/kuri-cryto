/// Complete analysis model for AI-powered market analysis
class CompleteAnalysis {
  final String symbol;
  final String exchange;
  final DateTime timestamp;
  final FormattedAnalysis formattedAnalysis;
  final Map<String, dynamic> rawData;
  final AnalysisSummary summary;

  const CompleteAnalysis({
    required this.symbol,
    required this.exchange,
    required this.timestamp,
    required this.formattedAnalysis,
    required this.rawData,
    required this.summary,
  });

  factory CompleteAnalysis.fromJson(Map<String, dynamic> json) {
    return CompleteAnalysis(
      symbol: json['symbol'] ?? '',
      exchange: json['exchange'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      formattedAnalysis:
          FormattedAnalysis.fromJson(json['formattedAnalysis'] ?? {}),
      rawData: Map<String, dynamic>.from(json['rawData'] ?? {}),
      summary: AnalysisSummary.fromJson(json['summary'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'exchange': exchange,
      'timestamp': timestamp.toIso8601String(),
      'formattedAnalysis': formattedAnalysis.toJson(),
      'rawData': rawData,
      'summary': summary.toJson(),
    };
  }

  CompleteAnalysis copyWith({
    String? symbol,
    String? exchange,
    DateTime? timestamp,
    FormattedAnalysis? formattedAnalysis,
    Map<String, dynamic>? rawData,
    AnalysisSummary? summary,
  }) {
    return CompleteAnalysis(
      symbol: symbol ?? this.symbol,
      exchange: exchange ?? this.exchange,
      timestamp: timestamp ?? this.timestamp,
      formattedAnalysis: formattedAnalysis ?? this.formattedAnalysis,
      rawData: rawData ?? this.rawData,
      summary: summary ?? this.summary,
    );
  }

  /// Check if analysis is fresh (within last 10 minutes)
  bool get isFresh {
    return DateTime.now().difference(timestamp).inMinutes < 10;
  }

  /// Get overall confidence score (0-100)
  double get confidenceScore {
    return summary.confidenceScore;
  }

  /// Check if analysis recommends buying
  bool get recommendsBuy {
    return summary.recommendation.toLowerCase().contains('buy');
  }

  /// Check if analysis recommends selling
  bool get recommendsSell {
    return summary.recommendation.toLowerCase().contains('sell');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CompleteAnalysis &&
        other.symbol == symbol &&
        other.exchange == exchange &&
        other.timestamp == timestamp &&
        other.formattedAnalysis == formattedAnalysis &&
        other.rawData.length == rawData.length &&
        other.summary == summary;
  }

  @override
  int get hashCode {
    return Object.hash(
      symbol,
      exchange,
      timestamp,
      formattedAnalysis,
      Object.hashAll(rawData.entries),
      summary,
    );
  }

  @override
  String toString() {
    return 'CompleteAnalysis(symbol: $symbol, exchange: $exchange, confidence: ${summary.confidenceScore})';
  }
}

/// Formatted analysis model
class FormattedAnalysis {
  final String systemStatus;
  final String marketAnalysis;
  final String positionAnalysis;
  final String aiAnalysis;
  final String riskAssessment;
  final String recommendations;

  const FormattedAnalysis({
    required this.systemStatus,
    required this.marketAnalysis,
    required this.positionAnalysis,
    required this.aiAnalysis,
    required this.riskAssessment,
    required this.recommendations,
  });

  factory FormattedAnalysis.fromJson(Map<String, dynamic> json) {
    return FormattedAnalysis(
      systemStatus: json['systemStatus'] ?? '',
      marketAnalysis: json['marketAnalysis'] ?? '',
      positionAnalysis: json['positionAnalysis'] ?? '',
      aiAnalysis: json['aiAnalysis'] ?? '',
      riskAssessment: json['riskAssessment'] ?? '',
      recommendations: json['recommendations'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'systemStatus': systemStatus,
      'marketAnalysis': marketAnalysis,
      'positionAnalysis': positionAnalysis,
      'aiAnalysis': aiAnalysis,
      'riskAssessment': riskAssessment,
      'recommendations': recommendations,
    };
  }

  FormattedAnalysis copyWith({
    String? systemStatus,
    String? marketAnalysis,
    String? positionAnalysis,
    String? aiAnalysis,
    String? riskAssessment,
    String? recommendations,
  }) {
    return FormattedAnalysis(
      systemStatus: systemStatus ?? this.systemStatus,
      marketAnalysis: marketAnalysis ?? this.marketAnalysis,
      positionAnalysis: positionAnalysis ?? this.positionAnalysis,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      riskAssessment: riskAssessment ?? this.riskAssessment,
      recommendations: recommendations ?? this.recommendations,
    );
  }

  /// Check if system status is healthy
  bool get isSystemHealthy {
    return systemStatus.toLowerCase().contains('healthy') ||
        systemStatus.toLowerCase().contains('good');
  }

  /// Get all analysis sections as a list
  List<String> get allSections {
    return [
      systemStatus,
      marketAnalysis,
      positionAnalysis,
      aiAnalysis,
      riskAssessment,
      recommendations,
    ];
  }

  /// Get combined analysis text
  String get combinedAnalysis {
    return allSections.where((section) => section.isNotEmpty).join('\n\n');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FormattedAnalysis &&
        other.systemStatus == systemStatus &&
        other.marketAnalysis == marketAnalysis &&
        other.positionAnalysis == positionAnalysis &&
        other.aiAnalysis == aiAnalysis &&
        other.riskAssessment == riskAssessment &&
        other.recommendations == recommendations;
  }

  @override
  int get hashCode {
    return Object.hash(
      systemStatus,
      marketAnalysis,
      positionAnalysis,
      aiAnalysis,
      riskAssessment,
      recommendations,
    );
  }

  @override
  String toString() {
    return 'FormattedAnalysis(systemStatus: ${systemStatus.length} chars, recommendations: ${recommendations.length} chars)';
  }
}

/// Analysis summary model
class AnalysisSummary {
  final String recommendation;
  final double confidenceScore;
  final String riskLevel;
  final List<String> keyPoints;
  final Map<String, double> indicators;

  const AnalysisSummary({
    required this.recommendation,
    required this.confidenceScore,
    required this.riskLevel,
    required this.keyPoints,
    required this.indicators,
  });

  factory AnalysisSummary.fromJson(Map<String, dynamic> json) {
    return AnalysisSummary(
      recommendation: json['recommendation'] ?? '',
      confidenceScore: json['confidenceScore']?.toDouble() ?? 0.0,
      riskLevel: json['riskLevel'] ?? 'medium',
      keyPoints: List<String>.from(json['keyPoints'] ?? []),
      indicators: Map<String, double>.from((json['indicators'] ?? {})
          .map((k, v) => MapEntry(k, v?.toDouble() ?? 0.0))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommendation': recommendation,
      'confidenceScore': confidenceScore,
      'riskLevel': riskLevel,
      'keyPoints': keyPoints,
      'indicators': indicators,
    };
  }

  AnalysisSummary copyWith({
    String? recommendation,
    double? confidenceScore,
    String? riskLevel,
    List<String>? keyPoints,
    Map<String, double>? indicators,
  }) {
    return AnalysisSummary(
      recommendation: recommendation ?? this.recommendation,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      riskLevel: riskLevel ?? this.riskLevel,
      keyPoints: keyPoints ?? this.keyPoints,
      indicators: indicators ?? this.indicators,
    );
  }

  /// Check if confidence is high (>70%)
  bool get isHighConfidence => confidenceScore > 70;

  /// Check if risk is low
  bool get isLowRisk => riskLevel.toLowerCase() == 'low';

  /// Check if risk is high
  bool get isHighRisk => riskLevel.toLowerCase() == 'high';

  /// Get indicator value by name
  double getIndicator(String name) {
    return indicators[name] ?? 0.0;
  }

  /// Check if has bullish indicators
  bool get hasBullishIndicators {
    return indicators.values.any((value) => value > 0.6);
  }

  /// Check if has bearish indicators
  bool get hasBearishIndicators {
    return indicators.values.any((value) => value < 0.4);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalysisSummary &&
        other.recommendation == recommendation &&
        other.confidenceScore == confidenceScore &&
        other.riskLevel == riskLevel &&
        other.keyPoints.length == keyPoints.length &&
        other.keyPoints.every((element) => keyPoints.contains(element)) &&
        other.indicators.length == indicators.length &&
        other.indicators.entries
            .every((entry) => indicators[entry.key] == entry.value);
  }

  @override
  int get hashCode {
    return Object.hash(
      recommendation,
      confidenceScore,
      riskLevel,
      Object.hashAll(keyPoints),
      Object.hashAll(indicators.entries),
    );
  }

  @override
  String toString() {
    return 'AnalysisSummary(recommendation: $recommendation, confidence: $confidenceScore, risk: $riskLevel)';
  }
}
