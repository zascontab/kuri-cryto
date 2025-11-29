/// Resultado del indicador MACD (Moving Average Convergence Divergence)
///
/// El MACD es un indicador de tendencia que muestra la relación entre
/// dos medias móviles exponenciales (EMAs) del precio.
///
/// Componentes:
/// - MACD Line: Diferencia entre EMA rápida (12) y EMA lenta (26)
/// - Signal Line: EMA de 9 períodos del MACD Line
/// - Histogram: Diferencia entre MACD Line y Signal Line
///
/// Interpretación:
/// - MACD cruza por encima de Signal: Señal alcista (BUY)
/// - MACD cruza por debajo de Signal: Señal bajista (SELL)
/// - Histogram positivo: Momentum alcista
/// - Histogram negativo: Momentum bajista
///
/// Este modelo se usa con la herramienta MCP 'calculate_macd'.
///
/// Ejemplo de uso:
/// ```dart
/// final indicatorsService = TechnicalIndicatorsService(mcpService);
/// final macd = await indicatorsService.calculateMACD(
///   exchange: 'kucoin',
///   pair: 'BTC-USDT',
///   interval: '1h',
/// );
///
/// if (macd.isBullishCrossover) {
///   print('🔼 Cruce alcista - Señal de compra');
/// } else if (macd.isBearishCrossover) {
///   print('🔽 Cruce bajista - Señal de venta');
/// }
/// print('Histogram: ${macd.histogram}');
/// ```
class MCPMACDResult {
  /// Línea MACD (diferencia entre EMA rápida y lenta)
  final double macd;

  /// Línea de señal (EMA de 9 del MACD)
  final double signal;

  /// Histograma (diferencia entre MACD y Signal)
  final double histogram;

  /// Timestamp del cálculo
  final DateTime timestamp;

  /// Par de trading
  final String? pair;

  /// Exchange
  final String? exchange;

  /// Período rápido (default: 12)
  final int? fastPeriod;

  /// Período lento (default: 26)
  final int? slowPeriod;

  /// Período de señal (default: 9)
  final int? signalPeriod;

  MCPMACDResult({
    required this.macd,
    required this.signal,
    required this.histogram,
    required this.timestamp,
    this.pair,
    this.exchange,
    this.fastPeriod,
    this.slowPeriod,
    this.signalPeriod,
  });

  /// Crea un MCPMACDResult desde JSON
  factory MCPMACDResult.fromJson(Map<String, dynamic> json) {
    return MCPMACDResult(
      macd: (json['macd'] ?? json['macd_line'] as num).toDouble(),
      signal: (json['signal'] ?? json['signal_line'] as num).toDouble(),
      histogram: (json['histogram'] ?? json['hist'] as num).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      pair: json['pair'] as String?,
      exchange: json['exchange'] as String?,
      fastPeriod: json['fast_period'] as int?,
      slowPeriod: json['slow_period'] as int?,
      signalPeriod: json['signal_period'] as int?,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'macd': macd,
      'signal': signal,
      'histogram': histogram,
      'timestamp': timestamp.toIso8601String(),
      if (pair != null) 'pair': pair,
      if (exchange != null) 'exchange': exchange,
      if (fastPeriod != null) 'fast_period': fastPeriod,
      if (slowPeriod != null) 'slow_period': slowPeriod,
      if (signalPeriod != null) 'signal_period': signalPeriod,
    };
  }

  /// Indica si MACD está por encima de la línea de señal (alcista)
  bool get isBullish => macd > signal;

  /// Indica si MACD está por debajo de la línea de señal (bajista)
  bool get isBearish => macd < signal;

  /// Indica si el histograma es positivo (momentum alcista)
  bool get hasPositiveMomentum => histogram > 0;

  /// Indica si el histograma es negativo (momentum bajista)
  bool get hasNegativeMomentum => histogram < 0;

  /// Indica si el histograma está creciendo (comparar con valor anterior)
  /// Nota: requiere el valor anterior del histograma
  bool isHistogramGrowing(double previousHistogram) {
    return histogram > previousHistogram;
  }

  /// Indica si hay un cruce alcista (MACD cruza por encima de Signal)
  /// Nota: requiere el valor anterior para detectar el cruce
  bool isBullishCrossover(MCPMACDResult previous) {
    return previous.isBearish && isBullish;
  }

  /// Indica si hay un cruce bajista (MACD cruza por debajo de Signal)
  /// Nota: requiere el valor anterior para detectar el cruce
  bool isBearishCrossover(MCPMACDResult previous) {
    return previous.isBullish && isBearish;
  }

  /// Obtiene la distancia entre MACD y Signal
  double get divergence => (macd - signal).abs();

  /// Obtiene la señal del MACD
  ///
  /// Retorna:
  /// - 'BUY': MACD > Signal y histograma positivo
  /// - 'SELL': MACD < Signal y histograma negativo
  /// - 'NEUTRAL': Condiciones mixtas
  String get signalType {
    if (isBullish && hasPositiveMomentum) return 'BUY';
    if (isBearish && hasNegativeMomentum) return 'SELL';
    return 'NEUTRAL';
  }

  /// Obtiene la intensidad de la señal basada en el histograma
  double get signalStrength => histogram.abs();

  /// Indica si ambas líneas están cerca de cero (mercado sin tendencia)
  bool get isNearZero {
    const threshold = 0.01; // Ajustar según el activo
    return macd.abs() < threshold && signal.abs() < threshold;
  }

  /// Crea una copia con campos modificados
  MCPMACDResult copyWith({
    double? macd,
    double? signal,
    double? histogram,
    DateTime? timestamp,
    String? pair,
    String? exchange,
    int? fastPeriod,
    int? slowPeriod,
    int? signalPeriod,
  }) {
    return MCPMACDResult(
      macd: macd ?? this.macd,
      signal: signal ?? this.signal,
      histogram: histogram ?? this.histogram,
      timestamp: timestamp ?? this.timestamp,
      pair: pair ?? this.pair,
      exchange: exchange ?? this.exchange,
      fastPeriod: fastPeriod ?? this.fastPeriod,
      slowPeriod: slowPeriod ?? this.slowPeriod,
      signalPeriod: signalPeriod ?? this.signalPeriod,
    );
  }

  @override
  String toString() {
    return 'MCPMACDResult('
        'macd: ${macd.toStringAsFixed(2)}, '
        'signal: ${signal.toStringAsFixed(2)}, '
        'histogram: ${histogram.toStringAsFixed(2)}, '
        'signal: $signalType'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MCPMACDResult &&
        other.macd == macd &&
        other.signal == signal &&
        other.histogram == histogram &&
        other.timestamp == timestamp &&
        other.pair == pair &&
        other.exchange == exchange;
  }

  @override
  int get hashCode {
    return Object.hash(
      macd,
      signal,
      histogram,
      timestamp,
      pair,
      exchange,
    );
  }
}
