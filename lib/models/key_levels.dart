/// Key price levels (support and resistance)
///
/// Contains support and resistance levels with distance calculations.
class KeyLevels {
  /// Support level (price floor)
  final double support;

  /// Resistance level (price ceiling)
  final double resistance;

  /// Distance calculations
  final LevelDistance? distance;

  const KeyLevels({
    required this.support,
    required this.resistance,
    this.distance,
  });

  factory KeyLevels.fromJson(Map<String, dynamic> json) {
    return KeyLevels(
      support: (json['support'] as num?)?.toDouble() ?? 0.0,
      resistance: (json['resistance'] as num?)?.toDouble() ?? 0.0,
      distance: json['distance'] != null
          ? LevelDistance.fromJson(json['distance'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'support': support,
      'resistance': resistance,
      if (distance != null) 'distance': distance!.toJson(),
    };
  }

  /// Calculate range between support and resistance
  double get range => resistance - support;

  /// Calculate range as percentage
  double get rangePercent => (range / support) * 100;

  @override
  String toString() {
    return 'KeyLevels(support: $support, resistance: $resistance, '
        'range: ${rangePercent.toStringAsFixed(2)}%)';
  }
}

/// Distance to support and resistance levels
class LevelDistance {
  /// Distance to support as percentage
  final double toSupportPercent;

  /// Distance to resistance as percentage
  final double toResistancePercent;

  const LevelDistance({
    required this.toSupportPercent,
    required this.toResistancePercent,
  });

  factory LevelDistance.fromJson(Map<String, dynamic> json) {
    return LevelDistance(
      toSupportPercent: (json['to_support_percent'] as num?)?.toDouble() ?? 0.0,
      toResistancePercent:
          (json['to_resistance_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'to_support_percent': toSupportPercent,
      'to_resistance_percent': toResistancePercent,
    };
  }

  /// Check if closer to support
  bool get isCloserToSupport => toSupportPercent < toResistancePercent;

  /// Check if closer to resistance
  bool get isCloserToResistance => toResistancePercent < toSupportPercent;

  @override
  String toString() {
    return 'LevelDistance(toSupport: ${toSupportPercent.toStringAsFixed(2)}%, '
        'toResistance: ${toResistancePercent.toStringAsFixed(2)}%)';
  }
}
