/// Enhanced LLM analysis model for MATP integration
class EnhancedLLMAnalysis {
  final String action;
  final double confidence;
  final List<String> reasoning;
  final double entryPrice;
  final double stopLoss;
  final double takeProfit;
  final String provider;
  final double cost;

  const EnhancedLLMAnalysis({
    required this.action,
    required this.confidence,
    required this.reasoning,
    required this.entryPrice,
    required this.stopLoss,
    required this.takeProfit,
    required this.provider,
    required this.cost,
  });

  factory EnhancedLLMAnalysis.fromJson(Map<String, dynamic> json) {
    return EnhancedLLMAnalysis(
      action: json['action'] ?? '',
      confidence: json['confidence']?.toDouble() ?? 0.0,
      reasoning: List<String>.from(json['reasoning'] ?? []),
      entryPrice: json['entryPrice']?.toDouble() ?? 0.0,
      stopLoss: json['stopLoss']?.toDouble() ?? 0.0,
      takeProfit: json['takeProfit']?.toDouble() ?? 0.0,
      provider: json['provider'] ?? '',
      cost: json['cost']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'confidence': confidence,
      'reasoning': reasoning,
      'entryPrice': entryPrice,
      'stopLoss': stopLoss,
      'takeProfit': takeProfit,
      'provider': provider,
      'cost': cost,
    };
  }

  EnhancedLLMAnalysis copyWith({
    String? action,
    double? confidence,
    List<String>? reasoning,
    double? entryPrice,
    double? stopLoss,
    double? takeProfit,
    String? provider,
    double? cost,
  }) {
    return EnhancedLLMAnalysis(
      action: action ?? this.action,
      confidence: confidence ?? this.confidence,
      reasoning: reasoning ?? this.reasoning,
      entryPrice: entryPrice ?? this.entryPrice,
      stopLoss: stopLoss ?? this.stopLoss,
      takeProfit: takeProfit ?? this.takeProfit,
      provider: provider ?? this.provider,
      cost: cost ?? this.cost,
    );
  }

  /// Check if action is buy
  bool get isBuyAction => action.toLowerCase() == 'buy';

  /// Check if action is sell
  bool get isSellAction => action.toLowerCase() == 'sell';

  /// Check if action is hold
  bool get isHoldAction => action.toLowerCase() == 'hold';

  /// Check if confidence is high (>70%)
  bool get isHighConfidence => confidence > 0.7;

  /// Check if confidence is medium (40-70%)
  bool get isMediumConfidence => confidence >= 0.4 && confidence <= 0.7;

  /// Check if confidence is low (<40%)
  bool get isLowConfidence => confidence < 0.4;

  /// Calculate risk/reward ratio
  double get riskRewardRatio {
    if (stopLoss == 0 || entryPrice == 0) return 0;

    final risk = (entryPrice - stopLoss).abs();
    final reward = (takeProfit - entryPrice).abs();

    return risk > 0 ? reward / risk : 0;
  }

  /// Check if risk/reward ratio is favorable (>2:1)
  bool get isFavorableRiskReward => riskRewardRatio > 2.0;

  /// Get confidence level as string
  String get confidenceLevel {
    if (isHighConfidence) return 'High';
    if (isMediumConfidence) return 'Medium';
    return 'Low';
  }

  /// Get provider display name
  String get providerDisplayName {
    switch (provider.toLowerCase()) {
      case 'openai':
        return 'GPT';
      case 'anthropic':
        return 'Claude';
      case 'google':
        return 'Gemini';
      default:
        return provider;
    }
  }

  /// Get formatted reasoning text
  String get formattedReasoning {
    return reasoning.map((reason) => '• $reason').join('\n');
  }

  /// Check if analysis has valid price levels
  bool get hasValidPriceLevels {
    return entryPrice > 0 && stopLoss > 0 && takeProfit > 0;
  }

  /// Calculate potential profit percentage
  double get potentialProfitPercent {
    if (entryPrice == 0) return 0;
    return ((takeProfit - entryPrice) / entryPrice * 100).abs();
  }

  /// Calculate potential loss percentage
  double get potentialLossPercent {
    if (entryPrice == 0) return 0;
    return ((entryPrice - stopLoss) / entryPrice * 100).abs();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EnhancedLLMAnalysis &&
        other.action == action &&
        other.confidence == confidence &&
        other.reasoning.length == reasoning.length &&
        other.reasoning.every((element) => reasoning.contains(element)) &&
        other.entryPrice == entryPrice &&
        other.stopLoss == stopLoss &&
        other.takeProfit == takeProfit &&
        other.provider == provider &&
        other.cost == cost;
  }

  @override
  int get hashCode {
    return Object.hash(
      action,
      confidence,
      Object.hashAll(reasoning),
      entryPrice,
      stopLoss,
      takeProfit,
      provider,
      cost,
    );
  }

  @override
  String toString() {
    return 'EnhancedLLMAnalysis(action: $action, confidence: $confidence, provider: $provider)';
  }
}

/// Sentiment data model
class SentimentData {
  final double score;
  final String label;
  final Map<String, double> breakdown;

  const SentimentData({
    required this.score,
    required this.label,
    required this.breakdown,
  });

  factory SentimentData.fromJson(Map<String, dynamic> json) {
    return SentimentData(
      score: json['score']?.toDouble() ?? 0.0,
      label: json['label'] ?? 'neutral',
      breakdown: Map<String, double>.from((json['breakdown'] ?? {})
          .map((k, v) => MapEntry(k, v?.toDouble() ?? 0.0))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'label': label,
      'breakdown': breakdown,
    };
  }

  /// Check if sentiment is positive
  bool get isPositive => score > 0.1;

  /// Check if sentiment is negative
  bool get isNegative => score < -0.1;

  /// Check if sentiment is neutral
  bool get isNeutral => score >= -0.1 && score <= 0.1;

  /// Get sentiment strength (0-100)
  double get strength => (score.abs() * 100).clamp(0, 100);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SentimentData &&
        other.score == score &&
        other.label == label &&
        other.breakdown.length == breakdown.length &&
        other.breakdown.entries
            .every((entry) => breakdown[entry.key] == entry.value);
  }

  @override
  int get hashCode {
    return Object.hash(score, label, Object.hashAll(breakdown.entries));
  }

  @override
  String toString() {
    return 'SentimentData(score: $score, label: $label)';
  }
}

/// Sentiment interpretation model
class SentimentInterpretation {
  final String summary;
  final String impact;
  final List<String> keyFactors;

  const SentimentInterpretation({
    required this.summary,
    required this.impact,
    required this.keyFactors,
  });

  factory SentimentInterpretation.fromJson(Map<String, dynamic> json) {
    return SentimentInterpretation(
      summary: json['summary'] ?? '',
      impact: json['impact'] ?? '',
      keyFactors: List<String>.from(json['keyFactors'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'impact': impact,
      'keyFactors': keyFactors,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SentimentInterpretation &&
        other.summary == summary &&
        other.impact == impact &&
        other.keyFactors.length == keyFactors.length &&
        other.keyFactors.every((element) => keyFactors.contains(element));
  }

  @override
  int get hashCode {
    return Object.hash(summary, impact, Object.hashAll(keyFactors));
  }

  @override
  String toString() {
    return 'SentimentInterpretation(summary: ${summary.length} chars, factors: ${keyFactors.length})';
  }
}

/// Enhanced sentiment analysis model
class EnhancedSentimentAnalysis {
  final String symbol;
  final SentimentData sentiment;
  final SentimentInterpretation interpretation;
  final Map<String, int> dataCounts;

  const EnhancedSentimentAnalysis({
    required this.symbol,
    required this.sentiment,
    required this.interpretation,
    required this.dataCounts,
  });

  factory EnhancedSentimentAnalysis.fromJson(Map<String, dynamic> json) {
    return EnhancedSentimentAnalysis(
      symbol: json['symbol'] ?? '',
      sentiment: SentimentData.fromJson(json['sentiment'] ?? {}),
      interpretation:
          SentimentInterpretation.fromJson(json['interpretation'] ?? {}),
      dataCounts: Map<String, int>.from(json['dataCounts'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'sentiment': sentiment.toJson(),
      'interpretation': interpretation.toJson(),
      'dataCounts': dataCounts,
    };
  }

  EnhancedSentimentAnalysis copyWith({
    String? symbol,
    SentimentData? sentiment,
    SentimentInterpretation? interpretation,
    Map<String, int>? dataCounts,
  }) {
    return EnhancedSentimentAnalysis(
      symbol: symbol ?? this.symbol,
      sentiment: sentiment ?? this.sentiment,
      interpretation: interpretation ?? this.interpretation,
      dataCounts: dataCounts ?? this.dataCounts,
    );
  }

  /// Get total data points analyzed
  int get totalDataPoints {
    return dataCounts.values.fold(0, (sum, count) => sum + count);
  }

  /// Check if has sufficient data for reliable analysis
  bool get hasSufficientData => totalDataPoints >= 100;

  /// Get data source with most coverage
  String get primaryDataSource {
    if (dataCounts.isEmpty) return '';
    return dataCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EnhancedSentimentAnalysis &&
        other.symbol == symbol &&
        other.sentiment == sentiment &&
        other.interpretation == interpretation &&
        other.dataCounts.length == dataCounts.length &&
        other.dataCounts.entries
            .every((entry) => dataCounts[entry.key] == entry.value);
  }

  @override
  int get hashCode {
    return Object.hash(
      symbol,
      sentiment,
      interpretation,
      Object.hashAll(dataCounts.entries),
    );
  }

  @override
  String toString() {
    return 'EnhancedSentimentAnalysis(symbol: $symbol, sentiment: ${sentiment.label}, dataPoints: $totalDataPoints)';
  }
}
