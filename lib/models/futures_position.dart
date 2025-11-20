/// Posición de futuros de KuCoin
class FuturesPosition {
  final String symbol;
  final String side; // 'long' o 'short'
  final double size; // Tamaño en contratos
  final double entryPrice;
  final double currentPrice;
  final double unrealizedPnl;
  final double realizedPnl;
  final int leverage;
  final double margin;
  final String marginMode; // 'ISOLATED' o 'CROSS'
  final double liquidationPrice;
  final double pnlPercent;
  final DateTime updatedAt;
  final double? markPrice;
  final double? indexPrice;

  const FuturesPosition({
    required this.symbol,
    required this.side,
    required this.size,
    required this.entryPrice,
    required this.currentPrice,
    required this.unrealizedPnl,
    required this.realizedPnl,
    required this.leverage,
    required this.margin,
    required this.marginMode,
    required this.liquidationPrice,
    required this.pnlPercent,
    required this.updatedAt,
    this.markPrice,
    this.indexPrice,
  });

  factory FuturesPosition.fromJson(Map<String, dynamic> json) {
    return FuturesPosition(
      symbol: json['symbol'] as String,
      side: json['side'] as String,
      size: (json['size'] as num).toDouble(),
      entryPrice: (json['entry_price'] as num).toDouble(),
      currentPrice: (json['current_price'] as num?)?.toDouble() ??
                    (json['mark_price'] as num?)?.toDouble() ?? 0.0,
      unrealizedPnl: (json['unrealized_pnl'] as num).toDouble(),
      realizedPnl: (json['realized_pnl'] as num?)?.toDouble() ?? 0.0,
      leverage: json['leverage'] as int,
      margin: (json['margin'] as num).toDouble(),
      marginMode: json['margin_mode'] as String? ?? 'ISOLATED',
      liquidationPrice: (json['liquidation_price'] as num).toDouble(),
      pnlPercent: (json['pnl_percent'] as num).toDouble(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      markPrice: (json['mark_price'] as num?)?.toDouble(),
      indexPrice: (json['index_price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'side': side,
      'size': size,
      'entry_price': entryPrice,
      'current_price': currentPrice,
      'unrealized_pnl': unrealizedPnl,
      'realized_pnl': realizedPnl,
      'leverage': leverage,
      'margin': margin,
      'margin_mode': marginMode,
      'liquidation_price': liquidationPrice,
      'pnl_percent': pnlPercent,
      'updated_at': updatedAt.toIso8601String(),
      if (markPrice != null) 'mark_price': markPrice,
      if (indexPrice != null) 'index_price': indexPrice,
    };
  }

  /// Indica si la posición es larga
  bool get isLong => side.toLowerCase() == 'long';

  /// Indica si la posición es corta
  bool get isShort => side.toLowerCase() == 'short';

  /// Indica si está en ganancia
  bool get isProfit => unrealizedPnl > 0;

  /// Indica si está en pérdida
  bool get isLoss => unrealizedPnl < 0;

  /// Indica si usa margen aislado
  bool get isIsolated => marginMode == 'ISOLATED';

  /// Indica si usa margen cruzado
  bool get isCross => marginMode == 'CROSS';

  /// Obtiene el valor total de la posición
  double get totalValue => size * entryPrice;

  /// Obtiene el PnL total (realizado + no realizado)
  double get totalPnl => unrealizedPnl + realizedPnl;

  /// Calcula la distancia al precio de liquidación en porcentaje
  double get distanceToLiquidationPercent {
    if (liquidationPrice == 0) return 0;
    return ((currentPrice - liquidationPrice).abs() / currentPrice) * 100;
  }

  /// Indica si está cerca de la liquidación (< 10%)
  bool get isNearLiquidation => distanceToLiquidationPercent < 10;
}

/// Respuesta del backend al obtener posiciones de futuros
class FuturesPositionsResponse {
  final int count;
  final String exchange;
  final List<FuturesPosition> positions;
  final double totalUnrealizedPnl;

  const FuturesPositionsResponse({
    required this.count,
    required this.exchange,
    required this.positions,
    required this.totalUnrealizedPnl,
  });

  factory FuturesPositionsResponse.fromJson(Map<String, dynamic> json) {
    return FuturesPositionsResponse(
      count: json['count'] as int,
      exchange: json['exchange'] as String,
      positions: (json['positions'] as List)
          .map((e) => FuturesPosition.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalUnrealizedPnl: (json['total_unrealized_pnl'] as num?)?.toDouble() ?? 0.0,
    );
  }

  bool get hasPositions => count > 0;
  bool get isEmpty => count == 0;
}

/// Respuesta del backend al cerrar una posición
class CloseFuturesPositionResponse {
  final String exchange;
  final String symbol;
  final String status;
  final String side;
  final double size;
  final double entryPrice;
  final double exitPrice;
  final double unrealizedPnl;
  final double realizedPnl;
  final double totalPnl;
  final double pnlPercent;
  final int leverage;
  final String marginMode;

  const CloseFuturesPositionResponse({
    required this.exchange,
    required this.symbol,
    required this.status,
    required this.side,
    required this.size,
    required this.entryPrice,
    required this.exitPrice,
    required this.unrealizedPnl,
    required this.realizedPnl,
    required this.totalPnl,
    required this.pnlPercent,
    required this.leverage,
    required this.marginMode,
  });

  factory CloseFuturesPositionResponse.fromJson(Map<String, dynamic> json) {
    return CloseFuturesPositionResponse(
      exchange: json['exchange'] as String,
      symbol: json['symbol'] as String,
      status: json['status'] as String,
      side: json['side'] as String,
      size: (json['size'] as num).toDouble(),
      entryPrice: (json['entry_price'] as num).toDouble(),
      exitPrice: (json['exit_price'] as num).toDouble(),
      unrealizedPnl: (json['unrealized_pnl'] as num).toDouble(),
      realizedPnl: (json['realized_pnl'] as num).toDouble(),
      totalPnl: (json['total_pnl'] as num).toDouble(),
      pnlPercent: (json['pnl_percent'] as num).toDouble(),
      leverage: json['leverage'] as int,
      marginMode: json['margin_mode'] as String,
    );
  }

  bool get isClosed => status == 'closed';
  bool get isProfit => totalPnl > 0;
}
