/// Ticker de mercado obtenido desde MCP Tools
///
/// Representa los datos del ticker actual de un par de trading,
/// incluyendo precio actual, bid/ask, volumen y estadísticas de 24h.
///
/// Este modelo se usa con la herramienta MCP 'get_ticker'.
///
/// Ejemplo de uso:
/// ```dart
/// final mcpService = MCPService(dio);
/// final ticker = await mcpService.callToolTyped<MCPTicker>(
///   toolName: 'get_ticker',
///   arguments: {
///     'exchange': 'kucoin',
///     'pair': 'BTC-USDT',
///   },
///   fromJson: MCPTicker.fromJson,
/// );
///
/// print('BTC Price: \$${ticker.last}');
/// print('24h Change: ${ticker.change24hPercent}%');
/// ```
class MCPTicker {
  /// Exchange donde se obtiene el ticker (ej: 'kucoin', 'binance')
  final String exchange;

  /// Par de trading (ej: 'BTC-USDT', 'ETH-USDT')
  final String pair;

  /// Último precio ejecutado
  final double last;

  /// Mejor precio de compra (bid)
  final double bid;

  /// Mejor precio de venta (ask)
  final double ask;

  /// Volumen de trading en 24h
  final double volume;

  /// Precio máximo en 24h
  final double high24h;

  /// Precio mínimo en 24h
  final double low24h;

  /// Cambio de precio en 24h (absoluto)
  final double change24h;

  /// Cambio de precio en 24h (porcentaje)
  final double? change24hPercent;

  /// Timestamp de la última actualización
  final DateTime? timestamp;

  MCPTicker({
    required this.exchange,
    required this.pair,
    required this.last,
    required this.bid,
    required this.ask,
    required this.volume,
    required this.high24h,
    required this.low24h,
    required this.change24h,
    this.change24hPercent,
    this.timestamp,
  });

  /// Crea un MCPTicker desde JSON
  ///
  /// El JSON debe tener el formato retornado por la herramienta MCP 'get_ticker'.
  factory MCPTicker.fromJson(Map<String, dynamic> json) {
    return MCPTicker(
      exchange: json['exchange'] as String,
      pair: json['pair'] as String,
      last: (json['last'] as num).toDouble(),
      bid: (json['bid'] as num).toDouble(),
      ask: (json['ask'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
      high24h: (json['high_24h'] as num).toDouble(),
      low24h: (json['low_24h'] as num).toDouble(),
      change24h: (json['change_24h'] as num).toDouble(),
      change24hPercent: json['change_24h_percent'] != null
          ? (json['change_24h_percent'] as num).toDouble()
          : null,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  /// Convierte el ticker a JSON
  Map<String, dynamic> toJson() {
    return {
      'exchange': exchange,
      'pair': pair,
      'last': last,
      'bid': bid,
      'ask': ask,
      'volume': volume,
      'high_24h': high24h,
      'low_24h': low24h,
      'change_24h': change24h,
      if (change24hPercent != null) 'change_24h_percent': change24hPercent,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }

  /// Calcula el spread (diferencia entre ask y bid)
  double get spread => ask - bid;

  /// Calcula el spread en porcentaje
  double get spreadPercent => (spread / last) * 100;

  /// Calcula el precio medio (mid price)
  double get midPrice => (bid + ask) / 2;

  /// Indica si el precio está subiendo (cambio positivo)
  bool get isRising => change24h > 0;

  /// Indica si el precio está bajando (cambio negativo)
  bool get isFalling => change24h < 0;

  /// Retorna el símbolo base del par (ej: 'BTC' de 'BTC-USDT')
  String get baseAsset {
    final parts = pair.split('-');
    return parts.isNotEmpty ? parts[0] : pair;
  }

  /// Retorna el símbolo quote del par (ej: 'USDT' de 'BTC-USDT')
  String get quoteAsset {
    final parts = pair.split('-');
    return parts.length > 1 ? parts[1] : '';
  }

  /// Crea una copia del ticker con campos modificados
  MCPTicker copyWith({
    String? exchange,
    String? pair,
    double? last,
    double? bid,
    double? ask,
    double? volume,
    double? high24h,
    double? low24h,
    double? change24h,
    double? change24hPercent,
    DateTime? timestamp,
  }) {
    return MCPTicker(
      exchange: exchange ?? this.exchange,
      pair: pair ?? this.pair,
      last: last ?? this.last,
      bid: bid ?? this.bid,
      ask: ask ?? this.ask,
      volume: volume ?? this.volume,
      high24h: high24h ?? this.high24h,
      low24h: low24h ?? this.low24h,
      change24h: change24h ?? this.change24h,
      change24hPercent: change24hPercent ?? this.change24hPercent,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'MCPTicker('
        'exchange: $exchange, '
        'pair: $pair, '
        'last: $last, '
        'change24h: $change24h, '
        'volume: $volume'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MCPTicker &&
        other.exchange == exchange &&
        other.pair == pair &&
        other.last == last &&
        other.bid == bid &&
        other.ask == ask &&
        other.volume == volume &&
        other.high24h == high24h &&
        other.low24h == low24h &&
        other.change24h == change24h &&
        other.change24hPercent == change24hPercent &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      exchange,
      pair,
      last,
      bid,
      ask,
      volume,
      high24h,
      low24h,
      change24h,
      change24hPercent,
      timestamp,
    );
  }
}
