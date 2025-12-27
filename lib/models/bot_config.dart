/// Bot configuration model
///
/// Configuration parameters for the AI trading bot
class BotConfig {
  final double confidenceThreshold; // 0-1, minimum confidence to execute trades
  final bool dryRun; // If true, bot simulates trades without executing
  final int maxPositions; // Maximum number of open positions
  final double maxRiskPerTrade; // Maximum risk per trade as percentage (0-1)
  final String? preferredExchange;
  final List<String>? allowedSymbols;
  final List<String>? blockedSymbols;
  final double? maxLeverage;
  final bool? useStopLoss;
  final bool? useTakeProfit;

  const BotConfig({
    required this.confidenceThreshold,
    required this.dryRun,
    required this.maxPositions,
    required this.maxRiskPerTrade,
    this.preferredExchange,
    this.allowedSymbols,
    this.blockedSymbols,
    this.maxLeverage,
    this.useStopLoss,
    this.useTakeProfit,
  });

  factory BotConfig.fromJson(Map<String, dynamic> json) {
    return BotConfig(
      confidenceThreshold:
          (json['confidence_threshold'] as num?)?.toDouble() ?? 0.7,
      dryRun: json['dry_run'] as bool? ?? true,
      maxPositions: json['max_positions'] as int? ?? 5,
      maxRiskPerTrade: (json['max_risk_per_trade'] as num?)?.toDouble() ?? 0.02,
      preferredExchange: json['preferred_exchange'] as String?,
      allowedSymbols:
          (json['allowed_symbols'] as List?)?.map((e) => e.toString()).toList(),
      blockedSymbols:
          (json['blocked_symbols'] as List?)?.map((e) => e.toString()).toList(),
      maxLeverage: (json['max_leverage'] as num?)?.toDouble(),
      useStopLoss: json['use_stop_loss'] as bool?,
      useTakeProfit: json['use_take_profit'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confidence_threshold': confidenceThreshold,
      'dry_run': dryRun,
      'max_positions': maxPositions,
      'max_risk_per_trade': maxRiskPerTrade,
      if (preferredExchange != null) 'preferred_exchange': preferredExchange,
      if (allowedSymbols != null) 'allowed_symbols': allowedSymbols,
      if (blockedSymbols != null) 'blocked_symbols': blockedSymbols,
      if (maxLeverage != null) 'max_leverage': maxLeverage,
      if (useStopLoss != null) 'use_stop_loss': useStopLoss,
      if (useTakeProfit != null) 'use_take_profit': useTakeProfit,
    };
  }

  /// Crea una copia con campos modificados
  BotConfig copyWith({
    double? confidenceThreshold,
    bool? dryRun,
    int? maxPositions,
    double? maxRiskPerTrade,
    String? preferredExchange,
    List<String>? allowedSymbols,
    List<String>? blockedSymbols,
    double? maxLeverage,
    bool? useStopLoss,
    bool? useTakeProfit,
  }) {
    return BotConfig(
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      dryRun: dryRun ?? this.dryRun,
      maxPositions: maxPositions ?? this.maxPositions,
      maxRiskPerTrade: maxRiskPerTrade ?? this.maxRiskPerTrade,
      preferredExchange: preferredExchange ?? this.preferredExchange,
      allowedSymbols: allowedSymbols ?? this.allowedSymbols,
      blockedSymbols: blockedSymbols ?? this.blockedSymbols,
      maxLeverage: maxLeverage ?? this.maxLeverage,
      useStopLoss: useStopLoss ?? this.useStopLoss,
      useTakeProfit: useTakeProfit ?? this.useTakeProfit,
    );
  }

  // Validation

  /// Valida que la configuración sea correcta
  List<String> validate() {
    final errors = <String>[];

    if (confidenceThreshold < 0 || confidenceThreshold > 1) {
      errors.add('Confidence threshold must be between 0 and 1');
    }

    if (maxPositions < 1) {
      errors.add('Max positions must be at least 1');
    }

    if (maxRiskPerTrade < 0 || maxRiskPerTrade > 1) {
      errors.add('Max risk per trade must be between 0 and 1');
    }

    if (maxLeverage != null && maxLeverage! < 1) {
      errors.add('Max leverage must be at least 1');
    }

    return errors;
  }

  /// Verifica si la configuración es válida
  bool get isValid => validate().isEmpty;

  // Helpers

  /// Verifica si es modo de prueba
  bool get isTestMode => dryRun;

  /// Verifica si es modo de producción
  bool get isProductionMode => !dryRun;

  /// Verifica si tiene configuración conservadora
  bool get isConservative =>
      confidenceThreshold >= 0.8 && maxRiskPerTrade <= 0.01;

  /// Verifica si tiene configuración agresiva
  bool get isAggressive =>
      confidenceThreshold <= 0.6 && maxRiskPerTrade >= 0.05;

  /// Obtiene el nivel de riesgo como string
  String get riskLevel {
    if (isConservative) return 'conservative';
    if (isAggressive) return 'aggressive';
    return 'moderate';
  }

  /// Obtiene el porcentaje de riesgo como string
  String get riskPercentage => '${(maxRiskPerTrade * 100).toStringAsFixed(1)}%';

  /// Obtiene el porcentaje de confianza como string
  String get confidencePercentage =>
      '${(confidenceThreshold * 100).toStringAsFixed(0)}%';

  @override
  String toString() {
    return 'BotConfig(confidenceThreshold: $confidenceThreshold, dryRun: $dryRun, maxPositions: $maxPositions, maxRiskPerTrade: $maxRiskPerTrade)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BotConfig &&
        other.confidenceThreshold == confidenceThreshold &&
        other.dryRun == dryRun &&
        other.maxPositions == maxPositions &&
        other.maxRiskPerTrade == maxRiskPerTrade;
  }

  @override
  int get hashCode {
    return confidenceThreshold.hashCode ^
        dryRun.hashCode ^
        maxPositions.hashCode ^
        maxRiskPerTrade.hashCode;
  }
}
