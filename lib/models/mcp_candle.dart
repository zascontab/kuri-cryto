/// Candle (OHLCV) obtenido desde MCP Tools
///
/// Representa una vela/candle con datos de precio OHLCV
/// (Open, High, Low, Close, Volume) para un intervalo de tiempo específico.
///
/// Este modelo se usa con la herramienta MCP 'get_candles'.
///
/// Ejemplo de uso:
/// ```dart
/// final mcpService = MCPService(dio);
/// final result = await mcpService.callTool(
///   toolName: 'get_candles',
///   arguments: {
///     'exchange': 'kucoin',
///     'pair': 'BTC-USDT',
///     'interval': '5m',
///     'limit': 100,
///   },
/// );
///
/// final candles = (result['candles'] as List)
///     .map((c) => MCPCandle.fromJson(c))
///     .toList();
///
/// for (var candle in candles) {
///   print('${candle.timestamp}: ${candle.close}');
/// }
/// ```
class MCPCandle {
  /// Timestamp de la vela
  final DateTime timestamp;

  /// Precio de apertura (Open)
  final double open;

  /// Precio máximo (High)
  final double high;

  /// Precio mínimo (Low)
  final double low;

  /// Precio de cierre (Close)
  final double close;

  /// Volumen de trading
  final double volume;

  /// Número de trades (opcional)
  final int? trades;

  MCPCandle({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    this.trades,
  });

  /// Crea un MCPCandle desde JSON
  ///
  /// El JSON puede venir en diferentes formatos según el backend:
  /// - Formato 1: {'timestamp': '2025-11-20T...', 'open': 100, ...}
  /// - Formato 2: {'time': 1700000000, 'open': 100, ...}
  /// - Formato 3: [timestamp, open, high, low, close, volume]
  factory MCPCandle.fromJson(dynamic json) {
    // Formato array: [timestamp, open, high, low, close, volume]
    if (json is List) {
      return MCPCandle(
        timestamp: _parseTimestamp(json[0]),
        open: (json[1] as num).toDouble(),
        high: (json[2] as num).toDouble(),
        low: (json[3] as num).toDouble(),
        close: (json[4] as num).toDouble(),
        volume: (json[5] as num).toDouble(),
        trades: json.length > 6 ? json[6] as int? : null,
      );
    }

    // Formato objeto: {timestamp: ..., open: ..., ...}
    final map = json as Map<String, dynamic>;
    return MCPCandle(
      timestamp: _parseTimestamp(map['timestamp'] ?? map['time']),
      open: (map['open'] as num).toDouble(),
      high: (map['high'] as num).toDouble(),
      low: (map['low'] as num).toDouble(),
      close: (map['close'] as num).toDouble(),
      volume: (map['volume'] as num).toDouble(),
      trades: map['trades'] as int?,
    );
  }

  /// Parsea timestamp que puede venir como string ISO o como unix timestamp
  static DateTime _parseTimestamp(dynamic value) {
    if (value is String) {
      return DateTime.parse(value);
    } else if (value is int) {
      // Unix timestamp (milisegundos)
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is double) {
      // Unix timestamp en segundos
      return DateTime.fromMillisecondsSinceEpoch((value * 1000).toInt());
    }
    throw FormatException('Invalid timestamp format: $value');
  }

  /// Convierte el candle a JSON
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
      if (trades != null) 'trades': trades,
    };
  }

  /// Convierte a formato array [timestamp, open, high, low, close, volume]
  List<dynamic> toArray() {
    return [
      timestamp.millisecondsSinceEpoch,
      open,
      high,
      low,
      close,
      volume,
      if (trades != null) trades,
    ];
  }

  /// Calcula el cambio de precio (close - open)
  double get change => close - open;

  /// Calcula el cambio de precio en porcentaje
  double get changePercent => ((close - open) / open) * 100;

  /// Calcula el rango (high - low)
  double get range => high - low;

  /// Calcula el body de la vela (|close - open|)
  double get body => (close - open).abs();

  /// Calcula la upper wick/shadow (high - max(open, close))
  double get upperWick => high - (open > close ? open : close);

  /// Calcula la lower wick/shadow (min(open, close) - low)
  double get lowerWick => (open < close ? open : close) - low;

  /// Indica si es una vela alcista (bullish)
  bool get isBullish => close > open;

  /// Indica si es una vela bajista (bearish)
  bool get isBearish => close < open;

  /// Indica si es una vela doji (open == close)
  bool get isDoji => close == open;

  /// Calcula el precio típico (average de high, low, close)
  double get typicalPrice => (high + low + close) / 3;

  /// Calcula el precio medio (average de high y low)
  double get midPrice => (high + low) / 2;

  /// Indica si el volumen es significativo comparado con un umbral
  bool hasSignificantVolume(double threshold) => volume > threshold;

  /// Crea una copia del candle con campos modificados
  MCPCandle copyWith({
    DateTime? timestamp,
    double? open,
    double? high,
    double? low,
    double? close,
    double? volume,
    int? trades,
  }) {
    return MCPCandle(
      timestamp: timestamp ?? this.timestamp,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
      trades: trades ?? this.trades,
    );
  }

  @override
  String toString() {
    return 'MCPCandle('
        'timestamp: $timestamp, '
        'O: $open, H: $high, L: $low, C: $close, '
        'V: $volume'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MCPCandle &&
        other.timestamp == timestamp &&
        other.open == open &&
        other.high == high &&
        other.low == low &&
        other.close == close &&
        other.volume == volume &&
        other.trades == trades;
  }

  @override
  int get hashCode {
    return Object.hash(
      timestamp,
      open,
      high,
      low,
      close,
      volume,
      trades,
    );
  }
}

/// Extensión para facilitar análisis de listas de candles
extension MCPCandleListExtensions on List<MCPCandle> {
  /// Obtiene el precio más alto de todos los candles
  double get maxHigh {
    if (isEmpty) return 0;
    return map((c) => c.high).reduce((a, b) => a > b ? a : b);
  }

  /// Obtiene el precio más bajo de todos los candles
  double get minLow {
    if (isEmpty) return 0;
    return map((c) => c.low).reduce((a, b) => a < b ? a : b);
  }

  /// Calcula el volumen total
  double get totalVolume {
    if (isEmpty) return 0;
    return map((c) => c.volume).reduce((a, b) => a + b);
  }

  /// Calcula el volumen promedio
  double get averageVolume {
    if (isEmpty) return 0;
    return totalVolume / length;
  }

  /// Obtiene los precios de cierre
  List<double> get closePrices => map((c) => c.close).toList();

  /// Obtiene los precios típicos
  List<double> get typicalPrices => map((c) => c.typicalPrice).toList();

  /// Filtra candles alcistas
  List<MCPCandle> get bullishCandles => where((c) => c.isBullish).toList();

  /// Filtra candles bajistas
  List<MCPCandle> get bearishCandles => where((c) => c.isBearish).toList();

  /// Cuenta cuántas velas son alcistas
  int get bullishCount => where((c) => c.isBullish).length;

  /// Cuenta cuántas velas son bajistas
  int get bearishCount => where((c) => c.isBearish).length;

  /// Calcula el porcentaje de velas alcistas
  double get bullishPercent {
    if (isEmpty) return 0;
    return (bullishCount / length) * 100;
  }
}
