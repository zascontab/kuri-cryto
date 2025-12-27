/// Response models for API responses
library;

/// Position size response model
class PositionSize {
  final double recommendedSize;
  final double maxSize;
  final double riskAmount;
  final double riskPercent;

  const PositionSize({
    required this.recommendedSize,
    required this.maxSize,
    required this.riskAmount,
    required this.riskPercent,
  });

  factory PositionSize.fromJson(Map<String, dynamic> json) {
    return PositionSize(
      recommendedSize: json['recommendedSize']?.toDouble() ?? 0.0,
      maxSize: json['maxSize']?.toDouble() ?? 0.0,
      riskAmount: json['riskAmount']?.toDouble() ?? 0.0,
      riskPercent: json['riskPercent']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommendedSize': recommendedSize,
      'maxSize': maxSize,
      'riskAmount': riskAmount,
      'riskPercent': riskPercent,
    };
  }

  @override
  String toString() {
    return 'PositionSize(recommended: $recommendedSize, risk: $riskPercent%)';
  }
}

/// Candle model for MCP
class Candle {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const Candle({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory Candle.fromJson(Map<String, dynamic> json) {
    return Candle(
      timestamp: DateTime.parse(json['timestamp']),
      open: json['open']?.toDouble() ?? 0.0,
      high: json['high']?.toDouble() ?? 0.0,
      low: json['low']?.toDouble() ?? 0.0,
      close: json['close']?.toDouble() ?? 0.0,
      volume: json['volume']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
    };
  }

  @override
  String toString() {
    return 'Candle(timestamp: $timestamp, close: $close, volume: $volume)';
  }
}

/// Market model for MCP
class Market {
  final String symbol;
  final String baseAsset;
  final String quoteAsset;
  final String status;
  final double minPrice;
  final double maxPrice;
  final double tickSize;

  const Market({
    required this.symbol,
    required this.baseAsset,
    required this.quoteAsset,
    required this.status,
    required this.minPrice,
    required this.maxPrice,
    required this.tickSize,
  });

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      symbol: json['symbol'] ?? '',
      baseAsset: json['baseAsset'] ?? '',
      quoteAsset: json['quoteAsset'] ?? '',
      status: json['status'] ?? 'active',
      minPrice: json['minPrice']?.toDouble() ?? 0.0,
      maxPrice: json['maxPrice']?.toDouble() ?? 0.0,
      tickSize: json['tickSize']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'baseAsset': baseAsset,
      'quoteAsset': quoteAsset,
      'status': status,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'tickSize': tickSize,
    };
  }

  @override
  String toString() {
    return 'Market(symbol: $symbol, status: $status)';
  }
}

/// Account info model for MCP
class AccountInfo {
  final String accountId;
  final String accountType;
  final double totalBalance;
  final double availableBalance;
  final double marginUsed;
  final List<Balance> balances;

  const AccountInfo({
    required this.accountId,
    required this.accountType,
    required this.totalBalance,
    required this.availableBalance,
    required this.marginUsed,
    required this.balances,
  });

  factory AccountInfo.fromJson(Map<String, dynamic> json) {
    return AccountInfo(
      accountId: json['accountId'] ?? '',
      accountType: json['accountType'] ?? 'spot',
      totalBalance: json['totalBalance']?.toDouble() ?? 0.0,
      availableBalance: json['availableBalance']?.toDouble() ?? 0.0,
      marginUsed: json['marginUsed']?.toDouble() ?? 0.0,
      balances: (json['balances'] as List?)
              ?.map((balance) => Balance.fromJson(balance))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'accountType': accountType,
      'totalBalance': totalBalance,
      'availableBalance': availableBalance,
      'marginUsed': marginUsed,
      'balances': balances.map((balance) => balance.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'AccountInfo(id: $accountId, balance: $totalBalance)';
  }
}

/// Balance model for MCP
class Balance {
  final String asset;
  final double free;
  final double locked;
  final double total;

  const Balance({
    required this.asset,
    required this.free,
    required this.locked,
    required this.total,
  });

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      asset: json['asset'] ?? '',
      free: json['free']?.toDouble() ?? 0.0,
      locked: json['locked']?.toDouble() ?? 0.0,
      total: json['total']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset': asset,
      'free': free,
      'locked': locked,
      'total': total,
    };
  }

  @override
  String toString() {
    return 'Balance(asset: $asset, free: $free, locked: $locked)';
  }
}

/// Exposure model for MCP
class Exposure {
  final String exchange;
  final double totalExposure;
  final double maxExposure;
  final Map<String, double> assetExposure;

  const Exposure({
    required this.exchange,
    required this.totalExposure,
    required this.maxExposure,
    required this.assetExposure,
  });

  factory Exposure.fromJson(Map<String, dynamic> json) {
    return Exposure(
      exchange: json['exchange'] ?? '',
      totalExposure: json['totalExposure']?.toDouble() ?? 0.0,
      maxExposure: json['maxExposure']?.toDouble() ?? 0.0,
      assetExposure: Map<String, double>.from((json['assetExposure'] ?? {})
          .map((k, v) => MapEntry(k, v?.toDouble() ?? 0.0))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exchange': exchange,
      'totalExposure': totalExposure,
      'maxExposure': maxExposure,
      'assetExposure': assetExposure,
    };
  }

  @override
  String toString() {
    return 'Exposure(exchange: $exchange, total: $totalExposure)';
  }
}
