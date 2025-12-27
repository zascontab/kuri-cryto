/// Futures-specific market data
///
/// Contains data specific to futures trading including funding rate,
/// mark price, liquidation price, and open interest.
class FuturesData {
  /// Current funding rate (as decimal, e.g., 0.0001 = 0.01%)
  final double fundingRate;

  /// Next funding time
  final DateTime nextFundingTime;

  /// Mark price used for liquidation calculations
  final double markPrice;

  /// Index price (spot price reference)
  final double indexPrice;

  /// Total open interest in the market
  final double openInterest;

  /// Estimated liquidation price for current position
  final double? liquidationPrice;

  const FuturesData({
    required this.fundingRate,
    required this.nextFundingTime,
    required this.markPrice,
    required this.indexPrice,
    required this.openInterest,
    this.liquidationPrice,
  });

  factory FuturesData.fromJson(Map<String, dynamic> json) {
    return FuturesData(
      fundingRate: (json['funding_rate'] as num?)?.toDouble() ?? 0.0,
      nextFundingTime: json['next_funding_time'] != null
          ? DateTime.parse(json['next_funding_time'] as String)
          : DateTime.now(),
      markPrice: (json['mark_price'] as num?)?.toDouble() ?? 0.0,
      indexPrice: (json['index_price'] as num?)?.toDouble() ?? 0.0,
      openInterest: (json['open_interest'] as num?)?.toDouble() ?? 0.0,
      liquidationPrice: (json['liquidation_price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'funding_rate': fundingRate,
      'next_funding_time': nextFundingTime.toIso8601String(),
      'mark_price': markPrice,
      'index_price': indexPrice,
      'open_interest': openInterest,
      if (liquidationPrice != null) 'liquidation_price': liquidationPrice,
    };
  }

  /// Get funding rate as percentage string
  String get fundingRatePercent => '${(fundingRate * 100).toStringAsFixed(4)}%';

  /// Check if funding rate is positive (longs pay shorts)
  bool get isPositiveFunding => fundingRate > 0;

  /// Check if funding rate is negative (shorts pay longs)
  bool get isNegativeFunding => fundingRate < 0;

  @override
  String toString() {
    return 'FuturesData(fundingRate: $fundingRate, markPrice: $markPrice, '
        'indexPrice: $indexPrice, openInterest: $openInterest)';
  }
}
