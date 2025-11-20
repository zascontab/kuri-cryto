/// Risk exposure tracking model
///
/// Represents current exposure relative to maximum allowed exposure
class RiskExposure {
  final double currentExposure;
  final double maxExposure;
  final double exposurePercent;
  final double availableExposure;

  const RiskExposure({
    required this.currentExposure,
    required this.maxExposure,
    required this.exposurePercent,
    required this.availableExposure,
  });

  factory RiskExposure.fromJson(Map<String, dynamic> json) {
    return RiskExposure(
      currentExposure: (json['current_exposure'] as num).toDouble(),
      maxExposure: (json['max_exposure'] as num).toDouble(),
      exposurePercent: (json['exposure_percent'] as num).toDouble(),
      availableExposure: (json['available_exposure'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_exposure': currentExposure,
      'max_exposure': maxExposure,
      'exposure_percent': exposurePercent,
      'available_exposure': availableExposure,
    };
  }

  /// Helper to check if near exposure limit (>80%)
  bool get isNearLimit => exposurePercent > 80.0;

  /// Helper to check if at critical exposure (>90%)
  bool get isCritical => exposurePercent > 90.0;

  /// Helper to check if has available capacity
  bool get hasCapacity => availableExposure > 0;

  @override
  String toString() {
    return 'RiskExposure(current: \$${currentExposure.toStringAsFixed(2)}, '
        'max: \$${maxExposure.toStringAsFixed(2)}, '
        'percent: ${exposurePercent.toStringAsFixed(1)}%)';
  }
}
