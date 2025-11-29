/// Order Book (libro de órdenes) obtenido desde MCP Tools
///
/// Representa el estado actual del libro de órdenes con bids (compras)
/// y asks (ventas) en un exchange.
///
/// Este modelo se usa con la herramienta MCP 'get_orderbook'.
///
/// Ejemplo de uso:
/// ```dart
/// final mcpService = MCPService(dio);
/// final result = await mcpService.callTool(
///   toolName: 'get_orderbook',
///   arguments: {
///     'exchange': 'kucoin',
///     'pair': 'BTC-USDT',
///     'depth': 20,
///   },
/// );
///
/// final orderBook = MCPOrderBook.fromJson(result);
/// print('Best bid: \$${orderBook.bestBid?.price}');
/// print('Best ask: \$${orderBook.bestAsk?.price}');
/// print('Spread: \$${orderBook.spread}');
/// ```
class MCPOrderBook {
  /// Lista de órdenes de compra (bids) ordenadas por precio descendente
  final List<OrderBookEntry> bids;

  /// Lista de órdenes de venta (asks) ordenadas por precio ascendente
  final List<OrderBookEntry> asks;

  /// Timestamp del order book
  final DateTime timestamp;

  /// Par de trading
  final String? pair;

  /// Exchange
  final String? exchange;

  MCPOrderBook({
    required this.bids,
    required this.asks,
    required this.timestamp,
    this.pair,
    this.exchange,
  });

  /// Crea un MCPOrderBook desde JSON
  factory MCPOrderBook.fromJson(Map<String, dynamic> json) {
    return MCPOrderBook(
      bids: (json['bids'] as List)
          .map((entry) => OrderBookEntry.fromJson(entry))
          .toList(),
      asks: (json['asks'] as List)
          .map((entry) => OrderBookEntry.fromJson(entry))
          .toList(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      pair: json['pair'] as String?,
      exchange: json['exchange'] as String?,
    );
  }

  /// Convierte el order book a JSON
  Map<String, dynamic> toJson() {
    return {
      'bids': bids.map((b) => b.toJson()).toList(),
      'asks': asks.map((a) => a.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      if (pair != null) 'pair': pair,
      if (exchange != null) 'exchange': exchange,
    };
  }

  /// Mejor precio de compra (highest bid)
  OrderBookEntry? get bestBid => bids.isNotEmpty ? bids.first : null;

  /// Mejor precio de venta (lowest ask)
  OrderBookEntry? get bestAsk => asks.isNotEmpty ? asks.first : null;

  /// Spread (diferencia entre best ask y best bid)
  double get spread {
    if (bestBid == null || bestAsk == null) return 0;
    return bestAsk!.price - bestBid!.price;
  }

  /// Spread en porcentaje
  double get spreadPercent {
    if (bestBid == null || bestAsk == null) return 0;
    final mid = midPrice;
    if (mid == 0) return 0;
    return (spread / mid) * 100;
  }

  /// Precio medio (mid price)
  double get midPrice {
    if (bestBid == null || bestAsk == null) return 0;
    return (bestBid!.price + bestAsk!.price) / 2;
  }

  /// Volumen total en el lado bid (compras)
  double get totalBidVolume {
    if (bids.isEmpty) return 0;
    return bids.map((b) => b.amount).reduce((a, b) => a + b);
  }

  /// Volumen total en el lado ask (ventas)
  double get totalAskVolume {
    if (asks.isEmpty) return 0;
    return asks.map((a) => a.amount).reduce((a, b) => a + b);
  }

  /// Ratio de volumen bid/ask
  double get bidAskVolumeRatio {
    if (totalAskVolume == 0) return 0;
    return totalBidVolume / totalAskVolume;
  }

  /// Profundidad del order book (número de niveles)
  int get depth => bids.length < asks.length ? bids.length : asks.length;

  /// Calcula el precio promedio ponderado para comprar una cantidad específica
  double? getAverageBuyPrice(double amount) {
    double remainingAmount = amount;
    double totalCost = 0;

    for (final ask in asks) {
      if (remainingAmount <= 0) break;

      final volumeAtThisLevel = ask.amount < remainingAmount
          ? ask.amount
          : remainingAmount;

      totalCost += volumeAtThisLevel * ask.price;
      remainingAmount -= volumeAtThisLevel;
    }

    if (remainingAmount > 0) {
      // No hay suficiente liquidez
      return null;
    }

    return totalCost / amount;
  }

  /// Calcula el precio promedio ponderado para vender una cantidad específica
  double? getAverageSellPrice(double amount) {
    double remainingAmount = amount;
    double totalRevenue = 0;

    for (final bid in bids) {
      if (remainingAmount <= 0) break;

      final volumeAtThisLevel = bid.amount < remainingAmount
          ? bid.amount
          : remainingAmount;

      totalRevenue += volumeAtThisLevel * bid.price;
      remainingAmount -= volumeAtThisLevel;
    }

    if (remainingAmount > 0) {
      // No hay suficiente liquidez
      return null;
    }

    return totalRevenue / amount;
  }

  /// Calcula el slippage para una compra de una cantidad específica
  double? calculateBuySlippage(double amount) {
    final avgPrice = getAverageBuyPrice(amount);
    if (avgPrice == null || bestAsk == null) return null;
    return ((avgPrice - bestAsk!.price) / bestAsk!.price) * 100;
  }

  /// Calcula el slippage para una venta de una cantidad específica
  double? calculateSellSlippage(double amount) {
    final avgPrice = getAverageSellPrice(amount);
    if (avgPrice == null || bestBid == null) return null;
    return ((bestBid!.price - avgPrice) / bestBid!.price) * 100;
  }

  /// Indica si hay suficiente liquidez para comprar una cantidad
  bool hasEnoughLiquidityToBuy(double amount) {
    return getAverageBuyPrice(amount) != null;
  }

  /// Indica si hay suficiente liquidez para vender una cantidad
  bool hasEnoughLiquidityToSell(double amount) {
    return getAverageSellPrice(amount) != null;
  }

  /// Crea una copia del order book con campos modificados
  MCPOrderBook copyWith({
    List<OrderBookEntry>? bids,
    List<OrderBookEntry>? asks,
    DateTime? timestamp,
    String? pair,
    String? exchange,
  }) {
    return MCPOrderBook(
      bids: bids ?? this.bids,
      asks: asks ?? this.asks,
      timestamp: timestamp ?? this.timestamp,
      pair: pair ?? this.pair,
      exchange: exchange ?? this.exchange,
    );
  }

  @override
  String toString() {
    return 'MCPOrderBook('
        'pair: $pair, '
        'bids: ${bids.length}, '
        'asks: ${asks.length}, '
        'spread: $spread, '
        'timestamp: $timestamp'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MCPOrderBook &&
        _listEquals(other.bids, bids) &&
        _listEquals(other.asks, asks) &&
        other.timestamp == timestamp &&
        other.pair == pair &&
        other.exchange == exchange;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(bids),
      Object.hashAll(asks),
      timestamp,
      pair,
      exchange,
    );
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Entrada individual en el order book
///
/// Representa un nivel de precio con su cantidad disponible.
class OrderBookEntry {
  /// Precio del nivel
  final double price;

  /// Cantidad disponible en este nivel
  final double amount;

  OrderBookEntry({
    required this.price,
    required this.amount,
  });

  /// Crea una entrada desde JSON
  ///
  /// Soporta dos formatos:
  /// - Array: [price, amount]
  /// - Objeto: {price: X, amount: Y}
  factory OrderBookEntry.fromJson(dynamic json) {
    if (json is List) {
      return OrderBookEntry(
        price: (json[0] as num).toDouble(),
        amount: (json[1] as num).toDouble(),
      );
    }

    final map = json as Map<String, dynamic>;
    return OrderBookEntry(
      price: (map['price'] as num).toDouble(),
      amount: (map['amount'] ?? map['size'] ?? map['quantity'] as num).toDouble(),
    );
  }

  /// Convierte a JSON como array [price, amount]
  List<double> toJson() {
    return [price, amount];
  }

  /// Convierte a objeto JSON
  Map<String, dynamic> toJsonObject() {
    return {
      'price': price,
      'amount': amount,
    };
  }

  /// Valor total en este nivel (price * amount)
  double get total => price * amount;

  @override
  String toString() {
    return 'OrderBookEntry(price: $price, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OrderBookEntry &&
        other.price == price &&
        other.amount == amount;
  }

  @override
  int get hashCode => Object.hash(price, amount);
}
