import 'market_pair.dart';
import 'market_features.dart';

/// Response from the enhanced `get_markets` endpoint
///
/// This model represents the complete response from the backend's
/// `get_markets` tool, which provides trading pairs with optional
/// filtering by market type.
///
/// Example:
/// ```dart
/// final response = MarketsResponse(
///   exchange: 'kucoin',
///   marketType: 'futures',
///   pairs: [/* list of MarketPair */],
///   features: MarketFeatures(/* ... */),
///   totalCount: 22,
///   marketTypesCount: {'spot': 22, 'futures': 22},
///   dataSource: 'fallback',
///   cached: false,
///   timestamp: DateTime.now(),
///   version: '2.0',
/// );
/// ```
class MarketsResponse {
  /// The exchange name (e.g., 'kucoin', 'binance')
  final String exchange;

  /// The market type filter applied (if any)
  ///
  /// One of: 'spot', 'futures', 'margin', 'options', or null for all types
  final String? marketType;

  /// List of trading pairs
  final List<MarketPair> pairs;

  /// Features for the filtered market type (if market_type was specified)
  final MarketFeatures? features;

  /// Total number of pairs returned
  final int totalCount;

  /// Count of pairs by market type
  ///
  /// Example: {'spot': 22, 'futures': 22, 'margin': 20, 'options': 10}
  final Map<String, int> marketTypesCount;

  /// Data source: 'gct' (GoCryptoTrader) or 'fallback' (static data)
  final String dataSource;

  /// Whether the response was served from cache
  final bool cached;

  /// Timestamp of the response
  final DateTime timestamp;

  /// API version
  final String version;

  /// Optional note from the backend
  final String? note;

  const MarketsResponse({
    required this.exchange,
    this.marketType,
    required this.pairs,
    this.features,
    required this.totalCount,
    required this.marketTypesCount,
    required this.dataSource,
    required this.cached,
    required this.timestamp,
    required this.version,
    this.note,
  });

  /// Creates a [MarketsResponse] from JSON data
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "exchange": "kucoin",
  ///   "market_type": "futures",
  ///   "pairs": [/* array of pairs */],
  ///   "features": {/* features object */},
  ///   "total_count": 22,
  ///   "market_types_count": {"spot": 22, "futures": 22},
  ///   "data_source": "fallback",
  ///   "cached": false,
  ///   "timestamp": "2025-11-27T10:30:00Z",
  ///   "version": "2.0"
  /// }
  /// ```
  factory MarketsResponse.fromJson(Map<String, dynamic> json) {
    return MarketsResponse(
      exchange: json['exchange'] as String,
      marketType: json['market_type'] as String?,
      pairs: (json['pairs'] as List)
          .map((e) => MarketPair.fromJson(e as Map<String, dynamic>))
          .toList(),
      features: json['features'] != null
          ? MarketFeatures.fromJson(json['features'] as Map<String, dynamic>)
          : null,
      totalCount: json['total_count'] as int,
      marketTypesCount: Map<String, int>.from(
        json['market_types_count'] as Map,
      ),
      dataSource: json['data_source'] as String,
      cached: json['cached'] as bool? ?? false,
      timestamp: DateTime.parse(json['timestamp'] as String),
      version: json['version'] as String,
      note: json['note'] as String?,
    );
  }

  /// Converts this [MarketsResponse] to JSON
  Map<String, dynamic> toJson() {
    return {
      'exchange': exchange,
      if (marketType != null) 'market_type': marketType,
      'pairs': pairs.map((p) => p.toJson()).toList(),
      if (features != null) 'features': features!.toJson(),
      'total_count': totalCount,
      'market_types_count': marketTypesCount,
      'data_source': dataSource,
      'cached': cached,
      'timestamp': timestamp.toIso8601String(),
      'version': version,
      if (note != null) 'note': note,
    };
  }

  /// Whether the data is from GoCryptoTrader (live data)
  bool get isLiveData => dataSource == 'gct';

  /// Whether the data is from fallback (static data)
  bool get isFallbackData => dataSource == 'fallback';

  /// Get pairs for a specific market type
  List<MarketPair> getPairsByType(String type) {
    return pairs.where((p) => p.marketType == type).toList();
  }

  /// Get standard symbols (BASE-QUOTE format) as a list
  List<String> get standardSymbols {
    return pairs.map((p) => p.standardSymbol).toList();
  }

  /// Get exchange-specific symbols as a list
  List<String> get symbols {
    return pairs.map((p) => p.symbol).toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MarketsResponse &&
        other.exchange == exchange &&
        other.marketType == marketType &&
        other.totalCount == totalCount &&
        other.dataSource == dataSource &&
        other.cached == cached &&
        other.version == version;
  }

  @override
  int get hashCode {
    return Object.hash(
      exchange,
      marketType,
      totalCount,
      dataSource,
      cached,
      version,
    );
  }

  @override
  String toString() {
    return 'MarketsResponse('
        'exchange: $exchange, '
        'marketType: $marketType, '
        'totalCount: $totalCount, '
        'dataSource: $dataSource, '
        'cached: $cached, '
        'version: $version'
        ')';
  }
}
