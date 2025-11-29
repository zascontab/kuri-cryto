/// Señal de trading generada desde análisis integrado
///
/// Representa una señal de compra/venta/espera basada en el análisis
/// combinado de múltiples indicadores técnicos y condiciones de mercado.
///
/// Ejemplo de uso:
/// ```dart
/// final analysisService = IntegratedAnalysisService(...);
/// final analysis = await analysisService.getCompleteMarketAnalysis(
///   exchange: 'kucoin',
///   pair: 'BTC-USDT',
/// );
///
/// final signal = analysis.signal;
/// print('Signal: ${signal.type} (${signal.strength}%)');
/// print('Confidence: ${signal.confidence}%');
/// print('Reasons: ${signal.reasons.join(", ")}');
/// ```
class MCPTradingSignal {
  /// Tipo de señal: 'BUY', 'SELL', 'HOLD'
  final String type;

  /// Fuerza de la señal (0-100)
  final double strength;

  /// Nivel de confianza (0-100)
  final double confidence;

  /// Razones que justifican la señal
  final List<String> reasons;

  /// Indicadores que soportan la señal
  final Map<String, String> indicators;

  /// Nivel de riesgo: 'LOW', 'MEDIUM', 'HIGH'
  final String risk;

  /// Precio sugerido de entrada (opcional)
  final double? entryPrice;

  /// Stop loss sugerido (opcional)
  final double? stopLoss;

  /// Take profit sugerido (opcional)
  final double? takeProfit;

  /// Timestamp de la señal
  final DateTime timestamp;

  MCPTradingSignal({
    required this.type,
    required this.strength,
    required this.confidence,
    required this.reasons,
    required this.indicators,
    required this.risk,
    this.entryPrice,
    this.stopLoss,
    this.takeProfit,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Crea un MCPTradingSignal desde JSON
  factory MCPTradingSignal.fromJson(Map<String, dynamic> json) {
    return MCPTradingSignal(
      type: json['type'] ?? json['signal'] as String,
      strength: (json['strength'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      reasons: (json['reasons'] as List).cast<String>(),
      indicators: Map<String, String>.from(json['indicators'] as Map),
      risk: json['risk'] ?? 'MEDIUM',
      entryPrice: json['entry_price'] != null
          ? (json['entry_price'] as num).toDouble()
          : null,
      stopLoss: json['stop_loss'] != null
          ? (json['stop_loss'] as num).toDouble()
          : null,
      takeProfit: json['take_profit'] != null
          ? (json['take_profit'] as num).toDouble()
          : null,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'strength': strength,
      'confidence': confidence,
      'reasons': reasons,
      'indicators': indicators,
      'risk': risk,
      if (entryPrice != null) 'entry_price': entryPrice,
      if (stopLoss != null) 'stop_loss': stopLoss,
      if (takeProfit != null) 'take_profit': takeProfit,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Indica si es señal de compra
  bool get isBuy => type.toUpperCase() == 'BUY';

  /// Indica si es señal de venta
  bool get isSell => type.toUpperCase() == 'SELL';

  /// Indica si es señal de mantener
  bool get isHold => type.toUpperCase() == 'HOLD';

  /// Indica si la señal es fuerte (strength > 70)
  bool get isStrong => strength > 70;

  /// Indica si la señal es débil (strength < 40)
  bool get isWeak => strength < 40;

  /// Indica si la confianza es alta (confidence > 70)
  bool get isHighConfidence => confidence > 70;

  /// Indica si es una señal de bajo riesgo
  bool get isLowRisk => risk.toUpperCase() == 'LOW';

  /// Indica si es una señal de alto riesgo
  bool get isHighRisk => risk.toUpperCase() == 'HIGH';

  /// Obtiene el score general de la señal (0-100)
  ///
  /// Combina strength y confidence
  double get overallScore => (strength + confidence) / 2;

  /// Indica si la señal es accionable (strong + high confidence)
  bool get isActionable => isStrong && isHighConfidence;

  /// Calcula el ratio riesgo/recompensa si hay SL y TP
  double? get riskRewardRatio {
    if (entryPrice == null || stopLoss == null || takeProfit == null) {
      return null;
    }

    final risk = (entryPrice! - stopLoss!).abs();
    final reward = (takeProfit! - entryPrice!).abs();

    if (risk == 0) return null;
    return reward / risk;
  }

  /// Indica si el ratio riesgo/recompensa es favorable (> 2:1)
  bool get hasFavorableRiskReward {
    final ratio = riskRewardRatio;
    return ratio != null && ratio > 2.0;
  }

  /// Número de indicadores que soportan la señal
  int get supportingIndicatorsCount => indicators.length;

  /// Obtiene descripción de la señal
  String get description {
    final buffer = StringBuffer();
    buffer.write('${type.toUpperCase()} signal with ');
    buffer.write('${strength.toStringAsFixed(0)}% strength and ');
    buffer.write('${confidence.toStringAsFixed(0)}% confidence. ');
    buffer.write('Risk: $risk. ');

    if (supportingIndicatorsCount > 0) {
      buffer.write('Supported by $supportingIndicatorsCount indicators.');
    }

    return buffer.toString();
  }

  /// Crea una copia con campos modificados
  MCPTradingSignal copyWith({
    String? type,
    double? strength,
    double? confidence,
    List<String>? reasons,
    Map<String, String>? indicators,
    String? risk,
    double? entryPrice,
    double? stopLoss,
    double? takeProfit,
    DateTime? timestamp,
  }) {
    return MCPTradingSignal(
      type: type ?? this.type,
      strength: strength ?? this.strength,
      confidence: confidence ?? this.confidence,
      reasons: reasons ?? this.reasons,
      indicators: indicators ?? this.indicators,
      risk: risk ?? this.risk,
      entryPrice: entryPrice ?? this.entryPrice,
      stopLoss: stopLoss ?? this.stopLoss,
      takeProfit: takeProfit ?? this.takeProfit,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'MCPTradingSignal('
        'type: $type, '
        'strength: ${strength.toStringAsFixed(0)}%, '
        'confidence: ${confidence.toStringAsFixed(0)}%, '
        'risk: $risk'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MCPTradingSignal &&
        other.type == type &&
        other.strength == strength &&
        other.confidence == confidence &&
        other.risk == risk;
  }

  @override
  int get hashCode {
    return Object.hash(type, strength, confidence, risk);
  }
}
