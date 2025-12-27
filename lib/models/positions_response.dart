import 'trading_position.dart';

/// Response model for positions endpoint
///
/// Contains list of open positions and summary statistics
class PositionsResponse {
  final List<TradingPosition> positions;
  final int totalPositions;
  final double totalPnL;
  final double totalPnLPercent;
  final double totalValue;
  final DateTime timestamp;

  const PositionsResponse({
    required this.positions,
    required this.totalPositions,
    required this.totalPnL,
    required this.totalPnLPercent,
    required this.totalValue,
    required this.timestamp,
  });

  factory PositionsResponse.fromJson(Map<String, dynamic> json) {
    final positionsList = json['positions'] as List? ?? [];
    final positions = positionsList
        .map((e) => TradingPosition.fromJson(e as Map<String, dynamic>))
        .toList();

    return PositionsResponse(
      positions: positions,
      totalPositions: json['total_positions'] as int? ?? positions.length,
      totalPnL: (json['total_pnl'] as num?)?.toDouble() ?? 0.0,
      totalPnLPercent: (json['total_pnl_percent'] as num?)?.toDouble() ?? 0.0,
      totalValue: (json['total_value'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'positions': positions.map((e) => e.toJson()).toList(),
      'total_positions': totalPositions,
      'total_pnl': totalPnL,
      'total_pnl_percent': totalPnLPercent,
      'total_value': totalValue,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Helpers

  /// Verifica si hay posiciones abiertas
  bool get hasPositions => positions.isNotEmpty;

  /// Verifica si el P&L total es positivo
  bool get isProfitable => totalPnL > 0;

  /// Verifica si el P&L total es negativo
  bool get isLosing => totalPnL < 0;

  /// Obtiene posiciones con ganancia
  List<TradingPosition> get profitablePositions =>
      positions.where((p) => p.isProfitable).toList();

  /// Obtiene posiciones con pérdida
  List<TradingPosition> get losingPositions =>
      positions.where((p) => p.isLosing).toList();

  /// Obtiene el número de posiciones con ganancia
  int get profitableCount => profitablePositions.length;

  /// Obtiene el número de posiciones con pérdida
  int get losingCount => losingPositions.length;

  /// Obtiene el ratio de ganancia/pérdida
  double get winRate =>
      totalPositions > 0 ? profitableCount / totalPositions : 0.0;

  /// Filtra posiciones por market type
  List<TradingPosition> filterByMarketType(String marketType) {
    return positions.where((p) => p.marketType == marketType).toList();
  }

  /// Filtra posiciones por símbolo
  List<TradingPosition> filterBySymbol(String symbol) {
    return positions.where((p) => p.symbol == symbol).toList();
  }
}
