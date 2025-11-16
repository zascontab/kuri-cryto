/// Position model representing a trading position
///
/// This model represents an open or closed trading position with all
/// relevant information including entry/exit prices, P&L, stop loss, etc.
class Position {
  /// Unique identifier for the position
  final String id;

  /// Trading pair symbol (e.g., 'BTC-USDT', 'DOGE-USDT')
  final String symbol;

  /// Position side: 'long' or 'short'
  final String side;

  /// Entry price of the position
  final double entryPrice;

  /// Current market price
  final double currentPrice;

  /// Position size (amount)
  final double size;

  /// Leverage used (1x, 2x, etc.)
  final double leverage;

  /// Stop loss price
  final double? stopLoss;

  /// Take profit price
  final double? takeProfit;

  /// Unrealized profit/loss
  final double unrealizedPnl;

  /// Realized profit/loss
  final double realizedPnl;

  /// When the position was opened
  final DateTime openTime;

  /// When the position was closed (null if still open)
  final DateTime? closeTime;

  /// Strategy that opened this position
  final String strategy;

  /// Position status: 'open', 'closing', or 'closed'
  final String status;

  const Position({
    required this.id,
    required this.symbol,
    required this.side,
    required this.entryPrice,
    required this.currentPrice,
    required this.size,
    this.leverage = 1.0,
    this.stopLoss,
    this.takeProfit,
    this.unrealizedPnl = 0.0,
    this.realizedPnl = 0.0,
    required this.openTime,
    this.closeTime,
    required this.strategy,
    this.status = 'open',
  });

  /// Calculate P&L percentage based on entry price
  ///
  /// Returns the percentage profit/loss relative to the entry price
  /// taking into account the position side (long/short)
  double calculatePnlPercentage() {
    if (entryPrice == 0) return 0.0;

    final priceDiff = currentPrice - entryPrice;
    final multiplier = side == 'long' ? 1.0 : -1.0;

    return (priceDiff / entryPrice) * 100 * multiplier * leverage;
  }

  /// Check if position is currently profitable
  bool get isProfitable => unrealizedPnl > 0;

  /// Check if position is still open
  bool get isOpen => status == 'open';

  /// Create a Position from JSON
  ///
  /// Handles missing or invalid fields gracefully with default values
  factory Position.fromJson(Map<String, dynamic> json) {
    try {
      return Position(
        id: json['id']?.toString() ?? '',
        symbol: json['symbol']?.toString() ?? '',
        side: json['side']?.toString() ?? 'long',
        entryPrice: _parseDouble(json['entry_price']),
        currentPrice: _parseDouble(json['current_price']),
        size: _parseDouble(json['size']),
        leverage: _parseDouble(json['leverage'], defaultValue: 1.0),
        stopLoss: json['stop_loss'] != null
            ? _parseDouble(json['stop_loss'])
            : null,
        takeProfit: json['take_profit'] != null
            ? _parseDouble(json['take_profit'])
            : null,
        unrealizedPnl: _parseDouble(json['unrealized_pnl'], defaultValue: 0.0),
        realizedPnl: _parseDouble(json['realized_pnl'], defaultValue: 0.0),
        openTime: _parseDateTime(json['open_time']) ?? DateTime.now(),
        closeTime: json['close_time'] != null
            ? _parseDateTime(json['close_time'])
            : null,
        strategy: json['strategy']?.toString() ?? 'unknown',
        status: json['status']?.toString() ?? 'open',
      );
    } catch (e) {
      throw FormatException('Failed to parse Position from JSON: $e');
    }
  }

  /// Convert Position to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'side': side,
      'entry_price': entryPrice,
      'current_price': currentPrice,
      'size': size,
      'leverage': leverage,
      'stop_loss': stopLoss,
      'take_profit': takeProfit,
      'unrealized_pnl': unrealizedPnl,
      'realized_pnl': realizedPnl,
      'open_time': openTime.toIso8601String(),
      'close_time': closeTime?.toIso8601String(),
      'strategy': strategy,
      'status': status,
    };
  }

  /// Create a copy of this Position with modified fields
  Position copyWith({
    String? id,
    String? symbol,
    String? side,
    double? entryPrice,
    double? currentPrice,
    double? size,
    double? leverage,
    double? stopLoss,
    double? takeProfit,
    double? unrealizedPnl,
    double? realizedPnl,
    DateTime? openTime,
    DateTime? closeTime,
    String? strategy,
    String? status,
  }) {
    return Position(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      side: side ?? this.side,
      entryPrice: entryPrice ?? this.entryPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      size: size ?? this.size,
      leverage: leverage ?? this.leverage,
      stopLoss: stopLoss ?? this.stopLoss,
      takeProfit: takeProfit ?? this.takeProfit,
      unrealizedPnl: unrealizedPnl ?? this.unrealizedPnl,
      realizedPnl: realizedPnl ?? this.realizedPnl,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      strategy: strategy ?? this.strategy,
      status: status ?? this.status,
    );
  }

  /// Helper to safely parse double from dynamic value
  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
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

    return other is Position &&
      other.id == id &&
      other.symbol == symbol &&
      other.side == side &&
      other.entryPrice == entryPrice &&
      other.currentPrice == currentPrice &&
      other.size == size &&
      other.leverage == leverage &&
      other.stopLoss == stopLoss &&
      other.takeProfit == takeProfit &&
      other.unrealizedPnl == unrealizedPnl &&
      other.realizedPnl == realizedPnl &&
      other.openTime == openTime &&
      other.closeTime == closeTime &&
      other.strategy == strategy &&
      other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      symbol,
      side,
      entryPrice,
      currentPrice,
      size,
      leverage,
      stopLoss,
      takeProfit,
      unrealizedPnl,
      realizedPnl,
      openTime,
      closeTime,
      strategy,
      status,
    );
  }

  @override
  String toString() {
    return 'Position('
        'id: $id, '
        'symbol: $symbol, '
        'side: $side, '
        'entryPrice: $entryPrice, '
        'currentPrice: $currentPrice, '
        'size: $size, '
        'leverage: ${leverage}x, '
        'unrealizedPnl: $unrealizedPnl, '
        'status: $status'
        ')';
  }
}
