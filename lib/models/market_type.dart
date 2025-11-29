import 'package:flutter/material.dart';

/// Represents the different types of trading markets available in the system.
///
/// Each market type has unique characteristics including leverage limits,
/// funding rates, and trading mechanisms. This enum provides a type-safe
/// way to handle different market types throughout the application.
///
/// Available market types:
/// - [spot]: Direct cryptocurrency trading without leverage
/// - [futures]: Derivative contracts with high leverage (up to 100x)
/// - [margin]: Leveraged spot trading with borrowed funds (up to 10x)
/// - [options]: Options contracts for hedging and speculation
///
/// Example usage:
/// ```dart
/// // Create a market type
/// final marketType = MarketType.futures;
///
/// // Get properties
/// print(marketType.displayName); // "Futures"
/// print(marketType.maxLeverage); // 100
/// print(marketType.description); // "Contracts with leverage (1-100x)"
///
/// // Validate leverage
/// if (marketType.isValidLeverage(50)) {
///   print('Leverage is valid');
/// }
///
/// // Convert from string
/// final type = MarketType.fromString('spot');
/// ```
enum MarketType {
  /// Spot trading market type.
  ///
  /// Direct buy/sell of cryptocurrencies with immediate settlement.
  /// No leverage is available (fixed at 1x). Suitable for long-term
  /// holding and low-risk trading strategies.
  spot('spot', 'Spot'),

  /// Futures trading market type.
  ///
  /// Trade perpetual or dated futures contracts with leverage up to 100x.
  /// Includes funding rate mechanism. Higher risk and potential returns.
  /// Suitable for short-term speculation and hedging.
  futures('futures', 'Futures'),

  /// Margin trading market type.
  ///
  /// Borrow funds to trade with leverage up to 10x. Interest is charged
  /// on borrowed amounts. Medium risk profile. Suitable for amplifying
  /// spot trading positions.
  margin('margin', 'Margin'),

  /// Options trading market type.
  ///
  /// Trade call and put options contracts. No leverage on the option itself.
  /// Provides the right (but not obligation) to buy/sell at a specific price.
  /// Suitable for hedging and advanced strategies.
  options('options', 'Options');

  /// The string value used for API communication and serialization.
  ///
  /// This value is sent to backend APIs and stored in configurations.
  final String value;

  /// The human-readable display name for UI presentation.
  ///
  /// Used in dropdowns, labels, and other UI components.
  final String displayName;

  /// Creates a [MarketType] with the given [value] and [displayName].
  const MarketType(this.value, this.displayName);

  /// Converts a string value to a [MarketType].
  ///
  /// The conversion is case-insensitive. If the value doesn't match any
  /// market type, returns [MarketType.futures] as the default.
  ///
  /// Example:
  /// ```dart
  /// final type1 = MarketType.fromString('spot');    // MarketType.spot
  /// final type2 = MarketType.fromString('FUTURES'); // MarketType.futures
  /// final type3 = MarketType.fromString('invalid'); // MarketType.futures (default)
  /// ```
  ///
  /// Parameters:
  /// - [value]: The string value to convert (case-insensitive)
  ///
  /// Returns: The corresponding [MarketType], or [MarketType.futures] if not found
  static MarketType fromString(String value) {
    return MarketType.values.firstWhere(
      (type) => type.value == value.toLowerCase(),
      orElse: () => MarketType.futures, // Default to futures
    );
  }

  /// Whether leverage is allowed for this market type.
  ///
  /// Returns `true` for all market types except [spot], which has fixed 1x leverage.
  ///
  /// Example:
  /// ```dart
  /// MarketType.spot.allowsLeverage;    // false
  /// MarketType.futures.allowsLeverage; // true
  /// MarketType.margin.allowsLeverage;  // true
  /// ```
  bool get allowsLeverage => this != MarketType.spot;

  /// The minimum leverage value allowed for this market type.
  ///
  /// All market types have a minimum leverage of 1x.
  int get minLeverage => 1;

  /// The maximum leverage value allowed for this market type.
  ///
  /// Different market types have different maximum leverage limits:
  /// - Spot: 1x (no leverage)
  /// - Futures: 100x (highest leverage)
  /// - Margin: 10x (moderate leverage)
  /// - Options: 1x (no leverage on the option itself)
  ///
  /// Example:
  /// ```dart
  /// MarketType.spot.maxLeverage;    // 1
  /// MarketType.futures.maxLeverage; // 100
  /// MarketType.margin.maxLeverage;  // 10
  /// ```
  int get maxLeverage {
    switch (this) {
      case MarketType.spot:
        return 1;
      case MarketType.futures:
        return 100;
      case MarketType.margin:
        return 10;
      case MarketType.options:
        return 1;
    }
  }

  /// Whether this market type has a funding rate mechanism.
  ///
  /// Only [futures] markets have funding rates, which are periodic payments
  /// between long and short position holders to keep the futures price
  /// anchored to the spot price.
  ///
  /// Returns `true` only for [MarketType.futures].
  bool get hasFundingRate => this == MarketType.futures;

  /// A human-readable description of this market type.
  ///
  /// Provides a brief explanation of the market type's characteristics
  /// and leverage capabilities. Useful for educational UI elements.
  ///
  /// Example:
  /// ```dart
  /// print(MarketType.spot.description);
  /// // Output: "Direct buy/sell without leverage"
  /// ```
  String get description {
    switch (this) {
      case MarketType.spot:
        return 'Direct buy/sell without leverage';
      case MarketType.futures:
        return 'Contracts with leverage (1-100x)';
      case MarketType.margin:
        return 'Leveraged trading (1-10x)';
      case MarketType.options:
        return 'Options contracts';
    }
  }

  /// The emoji icon representing this market type.
  ///
  /// Each market type has a unique emoji for quick visual identification:
  /// - Spot: 💰 (money bag)
  /// - Futures: 📈 (chart increasing)
  /// - Margin: ⚡ (lightning bolt)
  /// - Options: 🎯 (target)
  ///
  /// Example:
  /// ```dart
  /// Text('${MarketType.futures.icon} ${MarketType.futures.displayName}');
  /// // Displays: "📈 Futures"
  /// ```
  String get icon {
    switch (this) {
      case MarketType.spot:
        return '💰';
      case MarketType.futures:
        return '📈';
      case MarketType.margin:
        return '⚡';
      case MarketType.options:
        return '🎯';
    }
  }

  /// Validates whether the given leverage value is valid for this market type.
  ///
  /// Checks if the leverage is within the allowed range ([minLeverage] to [maxLeverage]).
  /// For market types that don't allow leverage (like [spot]), only 1x is valid.
  ///
  /// Parameters:
  /// - [leverage]: The leverage value to validate
  ///
  /// Returns: `true` if the leverage is valid, `false` otherwise
  ///
  /// Example:
  /// ```dart
  /// MarketType.spot.isValidLeverage(1);    // true
  /// MarketType.spot.isValidLeverage(5);    // false
  /// MarketType.futures.isValidLeverage(50); // true
  /// MarketType.futures.isValidLeverage(150); // false
  /// MarketType.margin.isValidLeverage(8);   // true
  /// ```
  bool isValidLeverage(double leverage) {
    if (!allowsLeverage && leverage > 1) return false;
    return leverage >= minLeverage && leverage <= maxLeverage;
  }

  /// The color value (ARGB format) for this market type.
  ///
  /// Each market type has a distinct color for visual consistency:
  /// - Spot: Blue (0xFF2196F3)
  /// - Futures: Orange (0xFFFF9800)
  /// - Margin: Purple (0xFF9C27B0)
  /// - Options: Teal (0xFF009688)
  ///
  /// Use the [color] getter from [MarketTypeUI] extension for a [Color] object.
  ///
  /// See also:
  /// - [MarketTypeUI.color] for getting a [Color] object
  int get colorValue {
    switch (this) {
      case MarketType.spot:
        return 0xFF2196F3; // Blue
      case MarketType.futures:
        return 0xFFFF9800; // Orange
      case MarketType.margin:
        return 0xFF9C27B0; // Purple
      case MarketType.options:
        return 0xFF009688; // Teal
    }
  }

  /// The Material Icons code point for this market type.
  ///
  /// Each market type has an associated Material Icon:
  /// - Spot: currency_exchange (0xe25a)
  /// - Futures: trending_up (0xe8e5)
  /// - Margin: account_balance (0xe84f)
  /// - Options: show_chart (0xe6e1)
  ///
  /// Use the [iconData] getter from [MarketTypeUI] extension for an [IconData] object.
  ///
  /// See also:
  /// - [MarketTypeUI.iconData] for getting an [IconData] object
  int get iconCodePoint {
    switch (this) {
      case MarketType.spot:
        return 0xe25a; // Icons.currency_exchange
      case MarketType.futures:
        return 0xe8e5; // Icons.trending_up
      case MarketType.margin:
        return 0xe84f; // Icons.account_balance
      case MarketType.options:
        return 0xe6e1; // Icons.show_chart
    }
  }
}

/// Extension providing UI-specific helpers for [MarketType].
///
/// This extension adds convenient getters for Flutter UI components,
/// converting the raw color and icon values into usable [Color] and
/// [IconData] objects.
///
/// Example usage:
/// ```dart
/// // Get color for a Container
/// Container(
///   color: MarketType.futures.color,
///   child: Icon(MarketType.futures.iconData),
/// );
///
/// // Use in a theme
/// final theme = ThemeData(
///   primaryColor: MarketType.spot.color,
/// );
/// ```
extension MarketTypeUI on MarketType {
  /// Returns a [Color] object for this market type.
  ///
  /// Converts the [colorValue] (ARGB integer) into a Flutter [Color] object
  /// that can be used directly in widgets.
  ///
  /// Example:
  /// ```dart
  /// Container(
  ///   color: MarketType.futures.color, // Orange color
  ///   child: Text('Futures Trading'),
  /// );
  /// ```
  Color get color => Color(colorValue);

  /// Returns an [IconData] object for this market type.
  ///
  /// Converts the [iconCodePoint] into a Flutter [IconData] object
  /// that can be used with the [Icon] widget.
  ///
  /// Example:
  /// ```dart
  /// Icon(
  ///   MarketType.futures.iconData, // trending_up icon
  ///   color: MarketType.futures.color,
  /// );
  /// ```
  IconData get iconData => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
}

/// Represents the features and capabilities of a market type.
///
/// This class encapsulates the various features that a market type may support,
/// such as leverage, funding rates, margin trading, and options. It's typically
/// used when receiving market type configuration from backend APIs.
///
/// Example usage:
/// ```dart
/// final features = MarketTypeFeatures(
///   hasLeverage: true,
///   leverageMin: 1,
///   leverageMax: 100,
///   hasFundingRate: true,
///   hasMargin: false,
///   hasOptions: false,
/// );
///
/// if (features.hasLeverage) {
///   print('Leverage range: ${features.leverageMin}x - ${features.leverageMax}x');
/// }
/// ```
class MarketTypeFeatures {
  /// Whether this market type supports leverage trading.
  final bool hasLeverage;

  /// The minimum leverage multiplier allowed (typically 1).
  final int leverageMin;

  /// The maximum leverage multiplier allowed.
  final int leverageMax;

  /// Whether this market type has a funding rate mechanism.
  final bool hasFundingRate;

  /// Whether this market type supports margin trading.
  final bool hasMargin;

  /// Whether this market type supports options trading.
  final bool hasOptions;

  /// Creates a [MarketTypeFeatures] instance with the specified capabilities.
  const MarketTypeFeatures({
    required this.hasLeverage,
    required this.leverageMin,
    required this.leverageMax,
    required this.hasFundingRate,
    required this.hasMargin,
    required this.hasOptions,
  });

  /// Creates a [MarketTypeFeatures] instance from a JSON map.
  ///
  /// Provides default values for missing fields:
  /// - `hasLeverage`: false
  /// - `leverageMin`: 1
  /// - `leverageMax`: 1
  /// - `hasFundingRate`: false
  /// - `hasMargin`: false
  /// - `hasOptions`: false
  ///
  /// Example:
  /// ```dart
  /// final json = {
  ///   'has_leverage': true,
  ///   'leverage_min': 1,
  ///   'leverage_max': 100,
  ///   'has_funding_rate': true,
  /// };
  /// final features = MarketTypeFeatures.fromJson(json);
  /// ```
  factory MarketTypeFeatures.fromJson(Map<String, dynamic> json) {
    return MarketTypeFeatures(
      hasLeverage: json['has_leverage'] as bool? ?? false,
      leverageMin: json['leverage_min'] as int? ?? 1,
      leverageMax: json['leverage_max'] as int? ?? 1,
      hasFundingRate: json['has_funding_rate'] as bool? ?? false,
      hasMargin: json['has_margin'] as bool? ?? false,
      hasOptions: json['has_options'] as bool? ?? false,
    );
  }

  /// Converts this [MarketTypeFeatures] instance to a JSON map.
  ///
  /// Returns a map with snake_case keys suitable for API communication.
  ///
  /// Example:
  /// ```dart
  /// final features = MarketTypeFeatures(
  ///   hasLeverage: true,
  ///   leverageMin: 1,
  ///   leverageMax: 100,
  ///   hasFundingRate: true,
  ///   hasMargin: false,
  ///   hasOptions: false,
  /// );
  /// final json = features.toJson();
  /// // {
  /// //   'has_leverage': true,
  /// //   'leverage_min': 1,
  /// //   'leverage_max': 100,
  /// //   'has_funding_rate': true,
  /// //   'has_margin': false,
  /// //   'has_options': false
  /// // }
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'has_leverage': hasLeverage,
      'leverage_min': leverageMin,
      'leverage_max': leverageMax,
      'has_funding_rate': hasFundingRate,
      'has_margin': hasMargin,
      'has_options': hasOptions,
    };
  }
}
