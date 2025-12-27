/// Rebalancing plan model for portfolio optimization
class RebalancingPlan {
  final List<Trade> trades;
  final double estimatedCost;
  final Map<String, double> expectedAllocation;
  final DateTime createdAt;

  const RebalancingPlan({
    required this.trades,
    required this.estimatedCost,
    required this.expectedAllocation,
    required this.createdAt,
  });

  /// Total number of trades required
  int get totalTrades => trades.length;

  /// Buy trades
  List<Trade> get buyTrades =>
      trades.where((t) => t.action == TradeAction.buy).toList();

  /// Sell trades
  List<Trade> get sellTrades =>
      trades.where((t) => t.action == TradeAction.sell).toList();

  /// Whether plan is executable
  bool get isExecutable => trades.isNotEmpty && estimatedCost >= 0;

  factory RebalancingPlan.fromJson(Map<String, dynamic> json) {
    return RebalancingPlan(
      trades: (json['trades'] as List<dynamic>?)
              ?.map((e) => Trade.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      estimatedCost: (json['estimated_cost'] as num?)?.toDouble() ?? 0.0,
      expectedAllocation:
          (json['expected_allocation'] as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(key, (value as num).toDouble()),
              ) ??
              {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trades': trades.map((e) => e.toJson()).toList(),
      'estimated_cost': estimatedCost,
      'expected_allocation': expectedAllocation,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Trade model for rebalancing
class Trade {
  final TradeAction action;
  final String symbol;
  final double quantity;
  final double estimatedPrice;
  final String exchange;

  const Trade({
    required this.action,
    required this.symbol,
    required this.quantity,
    required this.estimatedPrice,
    required this.exchange,
  });

  /// Total value of trade
  double get totalValue => quantity * estimatedPrice;

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      action: TradeAction.values.firstWhere(
        (e) => e.name == json['action'],
        orElse: () => TradeAction.buy,
      ),
      symbol: json['symbol'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      estimatedPrice: (json['estimated_price'] as num?)?.toDouble() ?? 0.0,
      exchange: json['exchange'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action.name,
      'symbol': symbol,
      'quantity': quantity,
      'estimated_price': estimatedPrice,
      'exchange': exchange,
    };
  }
}

/// Trade action enum
enum TradeAction {
  buy,
  sell,
}
