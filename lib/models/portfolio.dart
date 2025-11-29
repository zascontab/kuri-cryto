/// Portfolio model representing a user's cryptocurrency holdings
class Portfolio {
  final String id;
  final double totalValue;
  final double change24h;
  final double totalPnl;
  final List<Asset> assets;
  final DateTime lastUpdated;

  const Portfolio({
    required this.id,
    required this.totalValue,
    required this.change24h,
    required this.totalPnl,
    required this.assets,
    required this.lastUpdated,
  });

  /// Total number of assets in portfolio
  int get totalAssets => assets.length;

  /// Assets with positive PnL
  List<Asset> get profitableAssets =>
      assets.where((asset) => asset.pnl > 0).toList();

  /// Assets with negative PnL
  List<Asset> get losingAssets =>
      assets.where((asset) => asset.pnl < 0).toList();

  /// Change percentage in 24h
  double get change24hPercent =>
      totalValue > 0 ? (change24h / totalValue) * 100 : 0;

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['id'] as String? ?? '',
      totalValue: (json['total_value'] as num?)?.toDouble() ?? 0.0,
      change24h: (json['change_24h'] as num?)?.toDouble() ?? 0.0,
      totalPnl: (json['total_pnl'] as num?)?.toDouble() ?? 0.0,
      assets: (json['assets'] as List<dynamic>?)
              ?.map((e) => Asset.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'total_value': totalValue,
      'change_24h': change24h,
      'total_pnl': totalPnl,
      'assets': assets.map((e) => e.toJson()).toList(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  Portfolio copyWith({
    String? id,
    double? totalValue,
    double? change24h,
    double? totalPnl,
    List<Asset>? assets,
    DateTime? lastUpdated,
  }) {
    return Portfolio(
      id: id ?? this.id,
      totalValue: totalValue ?? this.totalValue,
      change24h: change24h ?? this.change24h,
      totalPnl: totalPnl ?? this.totalPnl,
      assets: assets ?? this.assets,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Asset model representing a single cryptocurrency holding
class Asset {
  final String symbol;
  final double quantity;
  final double currentPrice;
  final double value;
  final double allocation;
  final String exchange;
  final double? averageBuyPrice;

  const Asset({
    required this.symbol,
    required this.quantity,
    required this.currentPrice,
    required this.value,
    required this.allocation,
    required this.exchange,
    this.averageBuyPrice,
  });

  /// Profit/Loss amount
  double get pnl {
    if (averageBuyPrice == null) return 0.0;
    return (currentPrice - averageBuyPrice!) * quantity;
  }

  /// Profit/Loss percentage
  double get pnlPercent {
    if (averageBuyPrice == null || averageBuyPrice == 0) return 0.0;
    return ((currentPrice - averageBuyPrice!) / averageBuyPrice!) * 100;
  }

  /// Whether asset is profitable
  bool get isProfit => pnl > 0;

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      symbol: json['symbol'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      allocation: (json['allocation'] as num?)?.toDouble() ?? 0.0,
      exchange: json['exchange'] as String? ?? '',
      averageBuyPrice: (json['average_buy_price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'quantity': quantity,
      'current_price': currentPrice,
      'value': value,
      'allocation': allocation,
      'exchange': exchange,
      if (averageBuyPrice != null) 'average_buy_price': averageBuyPrice,
    };
  }

  Asset copyWith({
    String? symbol,
    double? quantity,
    double? currentPrice,
    double? value,
    double? allocation,
    String? exchange,
    double? averageBuyPrice,
  }) {
    return Asset(
      symbol: symbol ?? this.symbol,
      quantity: quantity ?? this.quantity,
      currentPrice: currentPrice ?? this.currentPrice,
      value: value ?? this.value,
      allocation: allocation ?? this.allocation,
      exchange: exchange ?? this.exchange,
      averageBuyPrice: averageBuyPrice ?? this.averageBuyPrice,
    );
  }
}
