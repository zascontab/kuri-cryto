/// Resultado del indicador RSI (Relative Strength Index)
///
/// El RSI es un oscilador de momento que mide la velocidad y el cambio
/// de los movimientos de precio. Los valores van de 0 a 100.
///
/// Interpretación:
/// - RSI > 70: Sobrecomprado (posible corrección bajista)
/// - RSI < 30: Sobrevendido (posible rebote alcista)
/// - RSI = 50: Punto neutral
///
/// Este modelo se usa con la herramienta MCP 'calculate_rsi'.
///
/// Ejemplo de uso:
/// ```dart
/// final indicatorsService = TechnicalIndicatorsService(mcpService);
/// final rsi = await indicatorsService.calculateRSI(
///   exchange: 'kucoin',
///   pair: 'BTC-USDT',
///   interval: '1h',
///   period: 14,
/// );
///
/// if (rsi.isOverbought) {
///   print('⚠️ Sobrecomprado - RSI: ${rsi.value}');
/// } else if (rsi.isOversold) {
///   print('✅ Sobrevendido - RSI: ${rsi.value}');
/// }
/// ```
class MCPRSIResult {
  /// Valor del RSI (0-100)
  final double value;

  /// Timestamp del cálculo
  final DateTime timestamp;

  /// Par de trading
  final String? pair;

  /// Exchange
  final String? exchange;

  /// Período usado para el cálculo (default: 14)
  final int? period;

  MCPRSIResult({
    required this.value,
    required this.timestamp,
    this.pair,
    this.exchange,
    this.period,
  });

  /// Crea un MCPRSIResult desde JSON
  factory MCPRSIResult.fromJson(Map<String, dynamic> json) {
    return MCPRSIResult(
      value: (json['rsi'] ?? json['value'] as num).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      pair: json['pair'] as String?,
      exchange: json['exchange'] as String?,
      period: json['period'] as int?,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'rsi': value,
      'timestamp': timestamp.toIso8601String(),
      if (pair != null) 'pair': pair,
      if (exchange != null) 'exchange': exchange,
      if (period != null) 'period': period,
    };
  }

  /// Indica si está en zona de sobrecompra (> 70)
  bool get isOverbought => value > 70;

  /// Indica si está en zona de sobreventa (< 30)
  bool get isOversold => value < 30;

  /// Indica si está en zona neutral (30-70)
  bool get isNeutral => value >= 30 && value <= 70;

  /// Indica si está extremadamente sobrecomprado (> 80)
  bool get isExtremelyOverbought => value > 80;

  /// Indica si está extremadamente sobrevendido (< 20)
  bool get isExtremelyOversold => value < 20;

  /// Indica si está cerca del nivel 50 (neutral)
  bool get isNearNeutral => (value - 50).abs() < 5;

  /// Obtiene la señal del RSI
  ///
  /// Retorna:
  /// - 'BUY': RSI < 30 (sobrevendido)
  /// - 'SELL': RSI > 70 (sobrecomprado)
  /// - 'NEUTRAL': RSI entre 30-70
  String get signal {
    if (isOversold) return 'BUY';
    if (isOverbought) return 'SELL';
    return 'NEUTRAL';
  }

  /// Obtiene la intensidad de la señal (0-100)
  ///
  /// Cuanto más alejado de 50, más intensa la señal
  double get signalStrength {
    return (value - 50).abs() * 2;
  }

  /// Crea una copia con campos modificados
  MCPRSIResult copyWith({
    double? value,
    DateTime? timestamp,
    String? pair,
    String? exchange,
    int? period,
  }) {
    return MCPRSIResult(
      value: value ?? this.value,
      timestamp: timestamp ?? this.timestamp,
      pair: pair ?? this.pair,
      exchange: exchange ?? this.exchange,
      period: period ?? this.period,
    );
  }

  @override
  String toString() {
    return 'MCPRSIResult(value: ${value.toStringAsFixed(2)}, signal: $signal, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MCPRSIResult &&
        other.value == value &&
        other.timestamp == timestamp &&
        other.pair == pair &&
        other.exchange == exchange &&
        other.period == period;
  }

  @override
  int get hashCode {
    return Object.hash(value, timestamp, pair, exchange, period);
  }
}
