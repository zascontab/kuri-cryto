/// Trading Pair model representing a cryptocurrency trading pair
///
/// This model represents a trading pair configuration with exchange,
/// symbol, status, and market information.
class TradingPair {
  /// Trading pair symbol (e.g., 'BTC-USDT', 'DOGE-USDT')
  final String symbol;

  /// Exchange name (e.g., 'kucoin', 'binance')
  final String exchange;

  /// Pair status: 'active', 'inactive', 'error'
  final String status;

  /// Last traded price
  final double? lastPrice;

  /// 24-hour trading volume
  final double? volume24h;

  /// Current exposure for this pair (total position value)
  final double? exposure;

  /// Number of open positions for this pair
  final int? openPositions;

  /// Whether the pair is enabled for trading
  final bool enabled;

  /// When the pair was added
  final DateTime? addedAt;

  const TradingPair({
    required this.symbol,
    required this.exchange,
    this.status = 'active',
    this.lastPrice,
    this.volume24h,
    this.exposure,
    this.openPositions,
    this.enabled = true,
    this.addedAt,
  });

  /// Check if pair is currently active
  bool get isActive => status == 'active' && enabled;

  /// Check if pair has open positions
  bool get hasOpenPositions => (openPositions ?? 0) > 0;

  /// Create a TradingPair from JSON
  ///
  /// Handles missing or invalid fields gracefully with default values
  factory TradingPair.fromJson(Map<String, dynamic> json) {
    try {
      return TradingPair(
        symbol: json['symbol']?.toString() ?? json['pair']?.toString() ?? '',
        exchange: json['exchange']?.toString() ?? '',
        status: json['status']?.toString() ?? 'active',
        lastPrice: _parseDouble(json['last_price'] ?? json['lastPrice']),
        volume24h: _parseDouble(json['volume_24h'] ?? json['volume24h']),
        exposure: _parseDouble(json['exposure']),
        openPositions: _parseInt(json['open_positions'] ?? json['openPositions']),
        enabled: json['enabled'] == null ? true : json['enabled'] as bool,
        addedAt: _parseDateTime(json['added_at'] ?? json['addedAt']),
      );
    } catch (e) {
      throw FormatException('Failed to parse TradingPair from JSON: $e');
    }
  }

  /// Convert TradingPair to JSON
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'exchange': exchange,
      'status': status,
      'last_price': lastPrice,
      'volume_24h': volume24h,
      'exposure': exposure,
      'open_positions': openPositions,
      'enabled': enabled,
      'added_at': addedAt?.toIso8601String(),
    };
  }

  /// Create a copy of this TradingPair with modified fields
  TradingPair copyWith({
    String? symbol,
    String? exchange,
    String? status,
    double? lastPrice,
    double? volume24h,
    double? exposure,
    int? openPositions,
    bool? enabled,
    DateTime? addedAt,
  }) {
    return TradingPair(
      symbol: symbol ?? this.symbol,
      exchange: exchange ?? this.exchange,
      status: status ?? this.status,
      lastPrice: lastPrice ?? this.lastPrice,
      volume24h: volume24h ?? this.volume24h,
      exposure: exposure ?? this.exposure,
      openPositions: openPositions ?? this.openPositions,
      enabled: enabled ?? this.enabled,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  /// Helper to safely parse double from dynamic value
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Helper to safely parse int from dynamic value
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Helper to safely parse DateTime from dynamic value
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TradingPair &&
        other.symbol == symbol &&
        other.exchange == exchange &&
        other.status == status &&
        other.lastPrice == lastPrice &&
        other.volume24h == volume24h &&
        other.exposure == exposure &&
        other.openPositions == openPositions &&
        other.enabled == enabled &&
        other.addedAt == addedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      symbol,
      exchange,
      status,
      lastPrice,
      volume24h,
      exposure,
      openPositions,
      enabled,
      addedAt,
    );
  }

  @override
  String toString() {
    return 'TradingPair('
        'symbol: $symbol, '
        'exchange: $exchange, '
        'status: $status, '
        'lastPrice: $lastPrice, '
        'volume24h: $volume24h, '
        'enabled: $enabled'
        ')';
  }
}
