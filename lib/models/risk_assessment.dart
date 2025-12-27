/// Risk assessment for trading decision
///
/// Contains risk level, score, factors, and volatility assessment.
class RiskAssessment {
  /// Risk level (low, medium, high)
  final String level;

  /// Risk score (0-100)
  final double score;

  /// Risk factors identified
  final List<String> factors;

  /// Volatility level (low, medium, high)
  final String volatility;

  const RiskAssessment({
    required this.level,
    required this.score,
    required this.factors,
    required this.volatility,
  });

  factory RiskAssessment.fromJson(Map<String, dynamic> json) {
    return RiskAssessment(
      level: json['level'] as String? ?? 'medium',
      score: (json['score'] as num?)?.toDouble() ?? 50.0,
      factors: json['factors'] != null
          ? List<String>.from(json['factors'] as List)
          : [],
      volatility: json['volatility'] as String? ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'score': score,
      'factors': factors,
      'volatility': volatility,
    };
  }

  /// Check if risk is low
  bool get isLowRisk => level.toLowerCase() == 'low';

  /// Check if risk is medium
  bool get isMediumRisk => level.toLowerCase() == 'medium';

  /// Check if risk is high
  bool get isHighRisk => level.toLowerCase() == 'high';

  /// Get risk level color
  RiskColor get riskColor {
    switch (level.toLowerCase()) {
      case 'low':
        return RiskColor.green;
      case 'medium':
        return RiskColor.yellow;
      case 'high':
        return RiskColor.red;
      default:
        return RiskColor.yellow;
    }
  }

  /// Get volatility color
  RiskColor get volatilityColor {
    switch (volatility.toLowerCase()) {
      case 'low':
        return RiskColor.green;
      case 'medium':
        return RiskColor.yellow;
      case 'high':
        return RiskColor.red;
      default:
        return RiskColor.yellow;
    }
  }

  @override
  String toString() {
    return 'RiskAssessment(level: $level, score: $score, '
        'volatility: $volatility, factors: ${factors.length})';
  }
}

/// Risk color enum for UI
enum RiskColor {
  green,
  yellow,
  red,
}
