/// Trade model for execution history
///
/// Represents a single trade execution with order details and timing information
class Trade {
  /// Unique trade identifier
  final String id;

  /// Order ID from the exchange
  final String orderId;

  /// Trading pair symbol (e.g., 'BTC-USDT', 'DOGE-USDT')
  final String symbol;

  /// Order side: 'buy' or 'sell'
  final String side;

  /// Order type: 'market', 'limit', or 'stop'
  final String type;

  /// Execution price
  final double price;

  /// Order size/amount
  final double size;

  /// Order status: 'pending', 'filled', 'cancelled', or 'failed'
  final String status;

  /// Execution latency in milliseconds
  final double latencyMs;

  /// Timestamp when the trade was executed
  final DateTime timestamp;

  /// Optional fee paid for the trade
  final double? fee;

  /// Optional fee currency
  final String? feeCurrency;

  /// Optional slippage percentage
  final double? slippagePct;

  const Trade({
    required this.id,
    required this.orderId,
    required this.symbol,
    required this.side,
    this.type = 'market',
    required this.price,
    required this.size,
    this.status = 'pending',
    this.latencyMs = 0.0,
    required this.timestamp,
    this.fee,
    this.feeCurrency,
    this.slippagePct,
  });

  /// Check if trade is a buy order
  bool get isBuy => side.toLowerCase() == 'buy';

  /// Check if trade is a sell order
  bool get isSell => side.toLowerCase() == 'sell';

  /// Check if trade was filled successfully
  bool get isFilled => status == 'filled';

  /// Check if trade is still pending
  bool get isPending => status == 'pending';

  /// Check if trade failed
  bool get isFailed => status == 'failed' || status == 'cancelled';

  /// Check if execution was fast (< 100ms latency)
  bool get isFastExecution => latencyMs < 100.0;

  /// Get total cost including fees
  double getTotalCost() {
    final baseCost = price * size;
    if (fee != null) {
      return baseCost + fee!;
    }
    return baseCost;
  }

  /// Get effective price after slippage
  double getEffectivePrice() {
    if (slippagePct == null) return price;
    final slippageMultiplier = 1 + (slippagePct! / 100);
    return price * slippageMultiplier;
  }

  /// Create Trade from JSON
  factory Trade.fromJson(Map<String, dynamic> json) {
    try {
      return Trade(
        id: json['id']?.toString() ?? '',
        orderId: json['order_id']?.toString() ?? '',
        symbol: json['symbol']?.toString() ?? '',
        side: json['side']?.toString() ?? 'buy',
        type: json['type']?.toString() ?? 'market',
        price: _parseDouble(json['price']),
        size: _parseDouble(json['size']),
        status: json['status']?.toString() ?? 'pending',
        latencyMs: _parseDouble(json['latency_ms']),
        timestamp: _parseDateTime(json['timestamp']) ?? DateTime.now(),
        fee: json['fee'] != null ? _parseDouble(json['fee']) : null,
        feeCurrency: json['fee_currency']?.toString(),
        slippagePct: json['slippage_pct'] != null
            ? _parseDouble(json['slippage_pct'])
            : null,
      );
    } catch (e) {
      throw FormatException('Failed to parse Trade from JSON: $e');
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'symbol': symbol,
      'side': side,
      'type': type,
      'price': price,
      'size': size,
      'status': status,
      'latency_ms': latencyMs,
      'timestamp': timestamp.toIso8601String(),
      if (fee != null) 'fee': fee,
      if (feeCurrency != null) 'fee_currency': feeCurrency,
      if (slippagePct != null) 'slippage_pct': slippagePct,
    };
  }

  /// Create a copy with modified fields
  Trade copyWith({
    String? id,
    String? orderId,
    String? symbol,
    String? side,
    String? type,
    double? price,
    double? size,
    String? status,
    double? latencyMs,
    DateTime? timestamp,
    double? fee,
    String? feeCurrency,
    double? slippagePct,
  }) {
    return Trade(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      symbol: symbol ?? this.symbol,
      side: side ?? this.side,
      type: type ?? this.type,
      price: price ?? this.price,
      size: size ?? this.size,
      status: status ?? this.status,
      latencyMs: latencyMs ?? this.latencyMs,
      timestamp: timestamp ?? this.timestamp,
      fee: fee ?? this.fee,
      feeCurrency: feeCurrency ?? this.feeCurrency,
      slippagePct: slippagePct ?? this.slippagePct,
    );
  }

  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Trade &&
      other.id == id &&
      other.orderId == orderId &&
      other.symbol == symbol &&
      other.side == side &&
      other.type == type &&
      other.price == price &&
      other.size == size &&
      other.status == status &&
      other.latencyMs == latencyMs &&
      other.timestamp == timestamp &&
      other.fee == fee &&
      other.feeCurrency == feeCurrency &&
      other.slippagePct == slippagePct;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      orderId,
      symbol,
      side,
      type,
      price,
      size,
      status,
      latencyMs,
      timestamp,
      fee,
      feeCurrency,
      slippagePct,
    );
  }

  @override
  String toString() {
    return 'Trade('
        'id: $id, '
        'symbol: $symbol, '
        'side: $side, '
        'type: $type, '
        'price: $price, '
        'size: $size, '
        'status: $status, '
        'latency: ${latencyMs}ms'
        ')';
  }
}
