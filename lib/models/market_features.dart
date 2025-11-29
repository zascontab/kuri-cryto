/// Represents the features and capabilities of a market type
///
/// This model describes what features are available for a specific market type,
/// such as leverage limits, funding rates, liquidation, and mark price.
///
/// Example:
/// ```dart
/// final features = MarketFeatures(
///   hasLeverage: true,
///   leverageMin: 1,
///   leverageMax: 100,
///   hasFundingRate: true,
///   hasLiquidation: true,
///   hasMarkPrice: true,
/// );
/// ```
class MarketFeatures {
  /// Whether this market type supports leverage trading
  final bool hasLeverage;

  /// The minimum leverage multiplier allowed
  final int leverageMin;

  /// The maximum leverage multiplier allowed
  final int leverageMax;

  /// Whether this market type has a funding rate mechanism
  final bool hasFundingRate;

  /// Whether this market type has liquidation
  final bool hasLiquidation;

  /// Whether this market type has mark price
  final bool? hasMarkPrice;

  const MarketFeatures({
    required this.hasLeverage,
    required this.leverageMin,
    required this.leverageMax,
    required this.hasFundingRate,
    required this.hasLiquidation,
    this.hasMarkPrice,
  });

  /// Creates a [MarketFeatures] from JSON data
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "has_leverage": true,
  ///   "leverage_min": 1,
  ///   "leverage_max": 100,
  ///   "has_funding_rate": true,
  ///   "has_liquidation": true,
  ///   "has_mark_price": true
  /// }
  /// ```
  factory MarketFeatures.fromJson(Map<String, dynamic> json) {
    return MarketFeatures(
      hasLeverage: json['has_leverage'] as bool? ?? false,
      leverageMin: json['leverage_min'] as int? ?? 1,
      leverageMax: json['leverage_max'] as int? ?? 1,
      hasFundingRate: json['has_funding_rate'] as bool? ?? false,
      hasLiquidation: json['has_liquidation'] as bool? ?? false,
      hasMarkPrice: json['has_mark_price'] as bool?,
    );
  }

  /// Converts this [MarketFeatures] to JSON
  Map<String, dynamic> toJson() {
    return {
      'has_leverage': hasLeverage,
      'leverage_min': leverageMin,
      'leverage_max': leverageMax,
      'has_funding_rate': hasFundingRate,
      'has_liquidation': hasLiquidation,
      if (hasMarkPrice != null) 'has_mark_price': hasMarkPrice,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MarketFeatures &&
        other.hasLeverage == hasLeverage &&
        other.leverageMin == leverageMin &&
        other.leverageMax == leverageMax &&
        other.hasFundingRate == hasFundingRate &&
        other.hasLiquidation == hasLiquidation &&
        other.hasMarkPrice == hasMarkPrice;
  }

  @override
  int get hashCode {
    return Object.hash(
      hasLeverage,
      leverageMin,
      leverageMax,
      hasFundingRate,
      hasLiquidation,
      hasMarkPrice,
    );
  }

  @override
  String toString() {
    return 'MarketFeatures('
        'hasLeverage: $hasLeverage, '
        'leverageMin: $leverageMin, '
        'leverageMax: $leverageMax, '
        'hasFundingRate: $hasFundingRate, '
        'hasLiquidation: $hasLiquidation, '
        'hasMarkPrice: $hasMarkPrice'
        ')';
  }
}
