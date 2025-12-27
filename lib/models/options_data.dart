/// Options-specific market data
///
/// Contains data specific to options trading including implied volatility
/// and greeks (delta, gamma, theta, vega, rho).
class OptionsData {
  /// Implied volatility (as decimal, e.g., 0.5 = 50%)
  final double impliedVolatility;

  /// Option greeks
  final OptionsGreeks? greeks;

  /// Strike price
  final double? strikePrice;

  /// Expiration date
  final DateTime? expirationDate;

  /// Option type (call or put)
  final String? optionType;

  const OptionsData({
    required this.impliedVolatility,
    this.greeks,
    this.strikePrice,
    this.expirationDate,
    this.optionType,
  });

  factory OptionsData.fromJson(Map<String, dynamic> json) {
    return OptionsData(
      impliedVolatility:
          (json['implied_volatility'] as num?)?.toDouble() ?? 0.0,
      greeks: json['greeks'] != null
          ? OptionsGreeks.fromJson(json['greeks'] as Map<String, dynamic>)
          : null,
      strikePrice: (json['strike_price'] as num?)?.toDouble(),
      expirationDate: json['expiration_date'] != null
          ? DateTime.parse(json['expiration_date'] as String)
          : null,
      optionType: json['option_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'implied_volatility': impliedVolatility,
      if (greeks != null) 'greeks': greeks!.toJson(),
      if (strikePrice != null) 'strike_price': strikePrice,
      if (expirationDate != null)
        'expiration_date': expirationDate!.toIso8601String(),
      if (optionType != null) 'option_type': optionType,
    };
  }

  /// Get implied volatility as percentage string
  String get impliedVolatilityPercent =>
      '${(impliedVolatility * 100).toStringAsFixed(2)}%';

  /// Check if option is a call
  bool get isCall => optionType?.toLowerCase() == 'call';

  /// Check if option is a put
  bool get isPut => optionType?.toLowerCase() == 'put';

  @override
  String toString() {
    return 'OptionsData(impliedVolatility: $impliedVolatility, '
        'optionType: $optionType, strikePrice: $strikePrice)';
  }
}

/// Options greeks
class OptionsGreeks {
  /// Delta: Rate of change of option price with respect to underlying price
  final double delta;

  /// Gamma: Rate of change of delta with respect to underlying price
  final double gamma;

  /// Theta: Rate of change of option price with respect to time
  final double theta;

  /// Vega: Rate of change of option price with respect to volatility
  final double vega;

  /// Rho: Rate of change of option price with respect to interest rate
  final double rho;

  const OptionsGreeks({
    required this.delta,
    required this.gamma,
    required this.theta,
    required this.vega,
    required this.rho,
  });

  factory OptionsGreeks.fromJson(Map<String, dynamic> json) {
    return OptionsGreeks(
      delta: (json['delta'] as num?)?.toDouble() ?? 0.0,
      gamma: (json['gamma'] as num?)?.toDouble() ?? 0.0,
      theta: (json['theta'] as num?)?.toDouble() ?? 0.0,
      vega: (json['vega'] as num?)?.toDouble() ?? 0.0,
      rho: (json['rho'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'delta': delta,
      'gamma': gamma,
      'theta': theta,
      'vega': vega,
      'rho': rho,
    };
  }

  @override
  String toString() {
    return 'OptionsGreeks(delta: $delta, gamma: $gamma, theta: $theta, '
        'vega: $vega, rho: $rho)';
  }
}
