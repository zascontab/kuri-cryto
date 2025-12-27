/// Trading position model
///
/// Represents an open trading position with P&L calculations
class TradingPosition {
  final String id;
  final String symbol;
  final String side; // 'long' or 'short'
  final double entryPrice;
  final double currentPrice;
  final double size;
  final double? leverage;
  final String marketType; // 'spot', 'futures', 'margin', 'options'
  final DateTime openedAt;
  final double pnl;
  final double pnlPercent;
  final double? stopLoss;
  final double? takeProfit;
  final double? liquidationPrice;
  final String? exchange;

  const TradingPosition({
    required this.id,
    required this.symbol,
    required this.side,
    required this.entryPrice,
    required this.currentPrice,
    required this.size,
    this.leverage,
    required this.marketType,
    required this.openedAt,
    required this.pnl,
    required this.pnlPercent,
    this.stopLoss,
    this.takeProfit,
    this.liquidationPrice,
    this.exchange,
  });

  factory TradingPosition.fromJson(Map<String, dynamic> json) {
    return TradingPosition(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      side: json['side'] as String? ?? 'long',
      entryPrice: (json['entry_price'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      size: (json['size'] as num?)?.toDouble() ?? 0.0,
      leverage: (json['leverage'] as num?)?.toDouble(),
      marketType: json['market_type'] as String? ?? 'spot',
      openedAt: json['opened_at'] != null
          ? DateTime.parse(json['opened_at'] as String)
          : DateTime.now(),
      pnl: (json['pnl'] as num?)?.toDouble() ?? 0.0,
      pnlPercent: (json['pnl_percent'] as num?)?.toDouble() ?? 0.0,
      stopLoss: (json['stop_loss'] as num?)?.toDouble(),
      takeProfit: (json['take_profit'] as num?)?.toDouble(),
      liquidationPrice: (json['liquidation_price'] as num?)?.toDouble(),
      exchange: json['exchange'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'side': side,
      'entry_price': entryPrice,
      'current_price': currentPrice,
      'size': size,
      if (leverage != null) 'leverage': leverage,
      'market_type': marketType,
      'opened_at': openedAt.toIso8601String(),
      'pnl': pnl,
      'pnl_percent': pnlPercent,
      if (stopLoss != null) 'stop_loss': stopLoss,
      if (takeProfit != null) 'take_profit': takeProfit,
      if (liquidationPrice != null) 'liquidation_price': liquidationPrice,
      if (exchange != null) 'exchange': exchange,
    };
  }

  /// Crea una copia con campos modificados
  TradingPosition copyWith({
    String? id,
    String? symbol,
    String? side,
    double? entryPrice,
    double? currentPrice,
    double? size,
    double? leverage,
    String? marketType,
    DateTime? openedAt,
    double? pnl,
    double? pnlPercent,
    double? stopLoss,
    double? takeProfit,
    double? liquidationPrice,
    String? exchange,
  }) {
    return TradingPosition(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      side: side ?? this.side,
      entryPrice: entryPrice ?? this.entryPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      size: size ?? this.size,
      leverage: leverage ?? this.leverage,
      marketType: marketType ?? this.marketType,
      openedAt: openedAt ?? this.openedAt,
      pnl: pnl ?? this.pnl,
      pnlPercent: pnlPercent ?? this.pnlPercent,
      stopLoss: stopLoss ?? this.stopLoss,
      takeProfit: takeProfit ?? this.takeProfit,
      liquidationPrice: liquidationPrice ?? this.liquidationPrice,
      exchange: exchange ?? this.exchange,
    );
  }

  // Helpers

  /// Verifica si es posición larga
  bool get isLong => side.toLowerCase() == 'long';

  /// Verifica si es posición corta
  bool get isShort => side.toLowerCase() == 'short';

  /// Verifica si la posición es rentable
  bool get isProfitable => pnl > 0;

  /// Verifica si la posición tiene pérdidas
  bool get isLosing => pnl < 0;

  /// Verifica si la posición está en breakeven
  bool get isBreakeven => pnl == 0;

  /// Obtiene el valor total de la posición
  double get totalValue => currentPrice * size;

  /// Obtiene el valor de entrada
  double get entryValue => entryPrice * size;

  /// Obtiene el cambio de precio
  double get priceChange => currentPrice - entryPrice;

  /// Obtiene el cambio de precio en porcentaje
  double get priceChangePercent =>
      entryPrice > 0 ? (priceChange / entryPrice) * 100 : 0.0;

  /// Verifica si tiene stop loss configurado
  bool get hasStopLoss => stopLoss != null;

  /// Verifica si tiene take profit configurado
  bool get hasTakeProfit => takeProfit != null;

  /// Verifica si está cerca del stop loss (dentro del 5%)
  bool get isNearStopLoss {
    if (stopLoss == null) return false;
    final distance = (currentPrice - stopLoss!).abs();
    final threshold = currentPrice * 0.05;
    return distance <= threshold;
  }

  /// Verifica si está cerca del take profit (dentro del 5%)
  bool get isNearTakeProfit {
    if (takeProfit == null) return false;
    final distance = (currentPrice - takeProfit!).abs();
    final threshold = currentPrice * 0.05;
    return distance <= threshold;
  }

  /// Verifica si está cerca del precio de liquidación (dentro del 10%)
  bool get isNearLiquidation {
    if (liquidationPrice == null) return false;
    final distance = (currentPrice - liquidationPrice!).abs();
    final threshold = currentPrice * 0.10;
    return distance <= threshold;
  }

  /// Obtiene el tiempo que la posición ha estado abierta
  Duration get duration => DateTime.now().difference(openedAt);

  /// Obtiene el tiempo en formato legible
  String get durationFormatted {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 24) {
      final days = hours ~/ 24;
      return '${days}d ${hours % 24}h';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Obtiene el color para mostrar el P&L en la UI
  String get pnlColor {
    if (isProfitable) return '#10B981'; // Green
    if (isLosing) return '#EF4444'; // Red
    return '#6B7280'; // Gray
  }

  /// Obtiene el ratio riesgo/recompensa
  double? get riskRewardRatio {
    if (stopLoss == null || takeProfit == null) return null;
    final risk = (entryPrice - stopLoss!).abs();
    final reward = (takeProfit! - entryPrice).abs();
    return risk > 0 ? reward / risk : null;
  }

  @override
  String toString() {
    return 'TradingPosition(id: $id, symbol: $symbol, side: $side, pnl: $pnl, pnlPercent: $pnlPercent%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TradingPosition && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
