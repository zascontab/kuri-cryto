/// Margin-specific market data
///
/// Contains data specific to margin trading including interest rate,
/// margin level, borrowed amount, and available margin.
class MarginData {
  /// Current interest rate for borrowed funds (as decimal)
  final double interestRate;

  /// Current margin level (ratio of equity to borrowed amount)
  final double marginLevel;

  /// Total amount borrowed
  final double borrowedAmount;

  /// Available margin for trading
  final double availableMargin;

  const MarginData({
    required this.interestRate,
    required this.marginLevel,
    required this.borrowedAmount,
    required this.availableMargin,
  });

  factory MarginData.fromJson(Map<String, dynamic> json) {
    return MarginData(
      interestRate: (json['interest_rate'] as num?)?.toDouble() ?? 0.0,
      marginLevel: (json['margin_level'] as num?)?.toDouble() ?? 0.0,
      borrowedAmount: (json['borrowed_amount'] as num?)?.toDouble() ?? 0.0,
      availableMargin: (json['available_margin'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interest_rate': interestRate,
      'margin_level': marginLevel,
      'borrowed_amount': borrowedAmount,
      'available_margin': availableMargin,
    };
  }

  /// Get interest rate as percentage string
  String get interestRatePercent =>
      '${(interestRate * 100).toStringAsFixed(4)}%';

  /// Check if margin level is healthy (>= 2.0)
  bool get isHealthy => marginLevel >= 2.0;

  /// Check if margin level is at risk (< 1.5)
  bool get isAtRisk => marginLevel < 1.5;

  /// Check if margin level is critical (< 1.1)
  bool get isCritical => marginLevel < 1.1;

  /// Get margin level status
  String get marginLevelStatus {
    if (isCritical) return 'Critical';
    if (isAtRisk) return 'At Risk';
    if (isHealthy) return 'Healthy';
    return 'Warning';
  }

  @override
  String toString() {
    return 'MarginData(interestRate: $interestRate, marginLevel: $marginLevel, '
        'borrowedAmount: $borrowedAmount, availableMargin: $availableMargin)';
  }
}
