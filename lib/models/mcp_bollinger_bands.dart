/// Resultado del indicador Bollinger Bands
///
/// Las Bandas de Bollinger son un indicador de volatilidad que consiste
/// en una media móvil simple (SMA) y dos bandas de desviación estándar.
///
/// Componentes:
/// - Upper Band: SMA + (desviación estándar × multiplicador)
/// - Middle Band: SMA (normalmente 20 períodos)
/// - Lower Band: SMA - (desviación estándar × multiplicador)
///
/// Interpretación:
/// - Precio cerca de Upper Band: Sobrecomprado
/// - Precio cerca de Lower Band: Sobrevendido
/// - Bandas estrechas: Baja volatilidad (posible breakout)
/// - Bandas amplias: Alta volatilidad
/// - Precio rebota en las bandas: Estrategia de reversión
/// - Precio rompe las bandas: Estrategia de tendencia
///
/// Este modelo se usa con la herramienta MCP 'calculate_bollinger_bands'.
///
/// Ejemplo de uso:
/// ```dart
/// final indicatorsService = TechnicalIndicatorsService(mcpService);
/// final bb = await indicatorsService.calculateBollingerBands(
///   exchange: 'kucoin',
///   pair: 'BTC-USDT',
///   interval: '1h',
///   period: 20,
///   stdDev: 2.0,
/// );
///
/// final currentPrice = 90500.0;
/// if (bb.isPriceNearUpperBand(currentPrice)) {
///   print('⚠️ Precio cerca de banda superior - Sobrecomprado');
/// } else if (bb.isPriceNearLowerBand(currentPrice)) {
///   print('✅ Precio cerca de banda inferior - Sobrevendido');
/// }
/// print('Ancho de banda: ${bb.bandwidthPercent.toStringAsFixed(2)}%');
/// ```
class MCPBollingerBands {
  /// Banda superior
  final double upper;

  /// Banda media (SMA)
  final double middle;

  /// Banda inferior
  final double lower;

  /// Timestamp del cálculo
  final DateTime timestamp;

  /// Par de trading
  final String? pair;

  /// Exchange
  final String? exchange;

  /// Período de la SMA (default: 20)
  final int? period;

  /// Desviación estándar multiplicador (default: 2.0)
  final double? stdDev;

  MCPBollingerBands({
    required this.upper,
    required this.middle,
    required this.lower,
    required this.timestamp,
    this.pair,
    this.exchange,
    this.period,
    this.stdDev,
  });

  /// Crea un MCPBollingerBands desde JSON
  factory MCPBollingerBands.fromJson(Map<String, dynamic> json) {
    return MCPBollingerBands(
      upper: (json['upper'] ?? json['upper_band'] as num).toDouble(),
      middle: (json['middle'] ?? json['middle_band'] ?? json['sma'] as num)
          .toDouble(),
      lower: (json['lower'] ?? json['lower_band'] as num).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      pair: json['pair'] as String?,
      exchange: json['exchange'] as String?,
      period: json['period'] as int?,
      stdDev: json['std_dev'] != null
          ? (json['std_dev'] as num).toDouble()
          : null,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'upper': upper,
      'middle': middle,
      'lower': lower,
      'timestamp': timestamp.toIso8601String(),
      if (pair != null) 'pair': pair,
      if (exchange != null) 'exchange': exchange,
      if (period != null) 'period': period,
      if (stdDev != null) 'std_dev': stdDev,
    };
  }

  /// Ancho de banda absoluto (upper - lower)
  double get bandwidth => upper - lower;

  /// Ancho de banda en porcentaje relativo a la banda media
  double get bandwidthPercent => (bandwidth / middle) * 100;

  /// %B - Posición del precio relativa a las bandas (0-1)
  ///
  /// %B = (price - lower) / (upper - lower)
  /// - %B > 1: Precio por encima de la banda superior
  /// - %B < 0: Precio por debajo de la banda inferior
  /// - %B = 0.5: Precio en la banda media
  double percentB(double price) {
    if (bandwidth == 0) return 0.5; // Evitar división por cero
    return (price - lower) / bandwidth;
  }

  /// Indica si el precio está cerca de la banda superior
  ///
  /// threshold: porcentaje de proximidad (default: 5%)
  bool isPriceNearUpperBand(double price, {double threshold = 5.0}) {
    final distance = ((upper - price) / upper).abs() * 100;
    return distance <= threshold && price <= upper;
  }

  /// Indica si el precio está cerca de la banda inferior
  ///
  /// threshold: porcentaje de proximidad (default: 5%)
  bool isPriceNearLowerBand(double price, {double threshold = 5.0}) {
    final distance = ((price - lower) / lower).abs() * 100;
    return distance <= threshold && price >= lower;
  }

  /// Indica si el precio está fuera de la banda superior
  bool isPriceAboveUpperBand(double price) => price > upper;

  /// Indica si el precio está fuera de la banda inferior
  bool isPriceBelowLowerBand(double price) => price < lower;

  /// Indica si el precio está dentro de las bandas
  bool isPriceWithinBands(double price) =>
      price >= lower && price <= upper;

  /// Indica si las bandas están estrechándose (baja volatilidad)
  ///
  /// Requiere el valor anterior de bandwidth para comparar
  bool isSqueeze(double previousBandwidth) {
    return bandwidth < previousBandwidth;
  }

  /// Indica si las bandas están expandiéndose (alta volatilidad)
  ///
  /// Requiere el valor anterior de bandwidth para comparar
  bool isExpanding(double previousBandwidth) {
    return bandwidth > previousBandwidth;
  }

  /// Obtiene la señal basada en la posición del precio
  ///
  /// Retorna:
  /// - 'BUY': Precio cerca o debajo de lower band
  /// - 'SELL': Precio cerca o encima de upper band
  /// - 'NEUTRAL': Precio en zona media
  String getSignal(double price) {
    if (isPriceBelowLowerBand(price) || isPriceNearLowerBand(price)) {
      return 'BUY';
    }
    if (isPriceAboveUpperBand(price) || isPriceNearUpperBand(price)) {
      return 'SELL';
    }
    return 'NEUTRAL';
  }

  /// Distancia del precio a la banda superior en porcentaje
  double distanceToUpperBand(double price) {
    return ((upper - price) / price) * 100;
  }

  /// Distancia del precio a la banda inferior en porcentaje
  double distanceToLowerBand(double price) {
    return ((price - lower) / price) * 100;
  }

  /// Distancia del precio a la banda media en porcentaje
  double distanceToMiddleBand(double price) {
    return ((price - middle) / price).abs() * 100;
  }

  /// Indica si hay un squeeze extremo (baja volatilidad extrema)
  ///
  /// Bandwidth < 2% indica squeeze extremo
  bool get isExtremeSqueeze => bandwidthPercent < 2.0;

  /// Indica si hay expansión extrema (alta volatilidad)
  ///
  /// Bandwidth > 10% indica volatilidad alta
  bool get isExtremeExpansion => bandwidthPercent > 10.0;

  /// Crea una copia con campos modificados
  MCPBollingerBands copyWith({
    double? upper,
    double? middle,
    double? lower,
    DateTime? timestamp,
    String? pair,
    String? exchange,
    int? period,
    double? stdDev,
  }) {
    return MCPBollingerBands(
      upper: upper ?? this.upper,
      middle: middle ?? this.middle,
      lower: lower ?? this.lower,
      timestamp: timestamp ?? this.timestamp,
      pair: pair ?? this.pair,
      exchange: exchange ?? this.exchange,
      period: period ?? this.period,
      stdDev: stdDev ?? this.stdDev,
    );
  }

  @override
  String toString() {
    return 'MCPBollingerBands('
        'upper: ${upper.toStringAsFixed(2)}, '
        'middle: ${middle.toStringAsFixed(2)}, '
        'lower: ${lower.toStringAsFixed(2)}, '
        'bandwidth: ${bandwidthPercent.toStringAsFixed(2)}%'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MCPBollingerBands &&
        other.upper == upper &&
        other.middle == middle &&
        other.lower == lower &&
        other.timestamp == timestamp &&
        other.pair == pair &&
        other.exchange == exchange;
  }

  @override
  int get hashCode {
    return Object.hash(upper, middle, lower, timestamp, pair, exchange);
  }
}
