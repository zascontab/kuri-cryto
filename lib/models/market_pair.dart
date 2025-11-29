/// Represents a trading pair from the enhanced markets endpoint
///
/// This model represents a single trading pair with its symbol information
/// and market type classification. It's part of the response from the
/// `get_markets` endpoint.
///
/// Example:
/// ```dart
/// final pair = MarketPair(
///   symbol: 'BTCUSDTM',
///   standardSymbol: 'BTC-USDT',
///   base: 'BTC',
///   quote: 'USDT',
///   marketType: 'futures',
/// );
/// ```
class MarketPair {
  /// The exchange-specific symbol format
  ///
  /// Examples:
  /// - Spot: 'BTC-USDT'
  /// - Futures: 'BTCUSDTM'
  /// - Margin: 'BTC-USDT'
  final String symbol;

  /// The standardized symbol format (always 'BASE-QUOTE')
  ///
  /// This is the format used across the application for consistency.
  /// Example: 'BTC-USDT'
  final String standardSymbol;

  /// The base currency (e.g., 'BTC', 'ETH', 'DOGE')
  final String base;

  /// The quote currency (usually 'USDT', 'USDC', 'BTC')
  final String quote;

  /// The market type for this pair
  ///
  /// One of: 'spot', 'futures', 'margin', 'options'
  final String marketType;

  const MarketPair({
    required this.symbol,
    required this.standardSymbol,
    required this.base,
    required this.quote,
    required this.marketType,
  });

  /// Creates a [MarketPair] from JSON data
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "symbol": "BTCUSDTM",
  ///   "standard_symbol": "BTC-USDT",
  ///   "base": "BTC",
  ///   "quote": "USDT",
  ///   "market_type": "futures"
  /// }
  /// ```
  factory MarketPair.fromJson(Map<String, dynamic> json) {
    return MarketPair(
      symbol: json['symbol'] as String,
      standardSymbol: json['standard_symbol'] as String,
      base: json['base'] as String,
      quote: json['quote'] as String,
      marketType: json['market_type'] as String,
    );
  }

  /// Converts this [MarketPair] to JSON
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'standard_symbol': standardSymbol,
      'base': base,
      'quote': quote,
      'market_type': marketType,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MarketPair &&
        other.symbol == symbol &&
        other.standardSymbol == standardSymbol &&
        other.base == base &&
        other.quote == quote &&
        other.marketType == marketType;
  }

  @override
  int get hashCode {
    return Object.hash(
      symbol,
      standardSymbol,
      base,
      quote,
      marketType,
    );
  }

  @override
  String toString() {
    return 'MarketPair('
        'symbol: $symbol, '
        'standardSymbol: $standardSymbol, '
        'base: $base, '
        'quote: $quote, '
        'marketType: $marketType'
        ')';
  }
}
