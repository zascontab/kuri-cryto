/// Análisis de mercado generado por AI
class AiAnalysis {
  final String action; // 'BUY', 'SELL', 'WAIT'
  final double confidence; // 0.0 a 1.0
  final String symbol;
  final double? entryPrice;
  final double? stopLoss;
  final double? takeProfit;
  final String? message;
  final List<String>? reasons;

  const AiAnalysis({
    required this.action,
    required this.confidence,
    required this.symbol,
    this.entryPrice,
    this.stopLoss,
    this.takeProfit,
    this.message,
    this.reasons,
  });

  factory AiAnalysis.fromJson(Map<String, dynamic> json) {
    return AiAnalysis(
      action: json['action'] as String? ?? 'WAIT',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      symbol: json['symbol'] as String? ?? '',
      entryPrice: (json['entry_price'] as num?)?.toDouble() ??
                  (json['entry'] as num?)?.toDouble(),
      stopLoss: (json['stop_loss'] as num?)?.toDouble(),
      takeProfit: (json['take_profit'] as num?)?.toDouble(),
      message: json['message'] as String?,
      reasons: json['reasons'] != null
          ? List<String>.from(json['reasons'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'confidence': confidence,
      'symbol': symbol,
      'entry_price': entryPrice,
      'stop_loss': stopLoss,
      'take_profit': takeProfit,
      'message': message,
      'reasons': reasons,
    };
  }

  /// Indica si es una señal de compra
  bool get isBuySignal => action == 'BUY';

  /// Indica si es una señal de venta
  bool get isSellSignal => action == 'SELL';

  /// Indica si es una señal de espera
  bool get isWaitSignal => action == 'WAIT';

  /// Indica si la confianza es alta (>= 70%)
  bool get isHighConfidence => confidence >= 0.70;
}

/// Posición activa del AI Bot
class AiPosition {
  final String id;
  final String symbol;
  final String side; // 'BUY' o 'SELL'
  final double entryPrice;
  final double size;
  final int leverage;
  final double stopLoss;
  final double takeProfit;
  final double pnl;
  final double? currentPrice;
  final DateTime? entryTime;

  const AiPosition({
    required this.id,
    required this.symbol,
    required this.side,
    required this.entryPrice,
    required this.size,
    required this.leverage,
    required this.stopLoss,
    required this.takeProfit,
    required this.pnl,
    this.currentPrice,
    this.entryTime,
  });

  factory AiPosition.fromJson(Map<String, dynamic> json) {
    return AiPosition(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      side: json['side'] as String? ?? '',
      entryPrice: (json['entry_price'] as num?)?.toDouble() ?? 0.0,
      size: (json['size'] as num?)?.toDouble() ?? 0.0,
      leverage: json['leverage'] as int? ?? 1,
      stopLoss: (json['stop_loss'] as num?)?.toDouble() ?? 0.0,
      takeProfit: (json['take_profit'] as num?)?.toDouble() ?? 0.0,
      pnl: (json['pnl'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (json['current_price'] as num?)?.toDouble(),
      entryTime: json['entry_time'] != null
          ? DateTime.parse(json['entry_time'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'side': side,
      'entry_price': entryPrice,
      'size': size,
      'leverage': leverage,
      'stop_loss': stopLoss,
      'take_profit': takeProfit,
      'pnl': pnl,
      'current_price': currentPrice,
      'entry_time': entryTime?.toIso8601String(),
    };
  }

  /// Indica si la posición es larga (compra)
  bool get isLong => side.toUpperCase() == 'BUY' || side.toUpperCase() == 'LONG';

  /// Indica si la posición es corta (venta)
  bool get isShort => side.toUpperCase() == 'SELL' || side.toUpperCase() == 'SHORT';

  /// Indica si está en ganancia
  bool get isProfit => pnl > 0;

  /// Indica si está en pérdida
  bool get isLoss => pnl < 0;
}
