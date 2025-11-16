/// Risk Parameters Model
class RiskParameters {
  final double maxPositionSizeUsd;
  final double maxTotalExposureUsd;
  final double stopLossPercent;
  final double takeProfitPercent;
  final double maxDailyLossUsd;
  final int maxConsecutiveLosses;
  final double? volatilityMultiplier;
  final double? kellyFraction;
  final double? riskFreeRate;
  final double? confidenceThreshold;

  RiskParameters({
    required this.maxPositionSizeUsd,
    required this.maxTotalExposureUsd,
    required this.stopLossPercent,
    required this.takeProfitPercent,
    required this.maxDailyLossUsd,
    required this.maxConsecutiveLosses,
    this.volatilityMultiplier,
    this.kellyFraction,
    this.riskFreeRate,
    this.confidenceThreshold,
  });

  factory RiskParameters.fromJson(Map<String, dynamic> json) {
    return RiskParameters(
      maxPositionSizeUsd: (json['max_position_size_usd']).toDouble(),
      maxTotalExposureUsd: (json['max_total_exposure_usd']).toDouble(),
      stopLossPercent: (json['stop_loss_percent']).toDouble(),
      takeProfitPercent: (json['take_profit_percent']).toDouble(),
      maxDailyLossUsd: (json['max_daily_loss_usd']).toDouble(),
      maxConsecutiveLosses: json['max_consecutive_losses'],
      volatilityMultiplier: json['volatility_multiplier']?.toDouble(),
      kellyFraction: json['kelly_fraction']?.toDouble(),
      riskFreeRate: json['risk_free_rate']?.toDouble(),
      confidenceThreshold: json['confidence_threshold']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'max_position_size_usd': maxPositionSizeUsd,
      'max_total_exposure_usd': maxTotalExposureUsd,
      'stop_loss_percent': stopLossPercent,
      'take_profit_percent': takeProfitPercent,
      'max_daily_loss_usd': maxDailyLossUsd,
      'max_consecutive_losses': maxConsecutiveLosses,
      'volatility_multiplier': volatilityMultiplier,
      'kelly_fraction': kellyFraction,
      'risk_free_rate': riskFreeRate,
      'confidence_threshold': confidenceThreshold,
    };
  }
}

/// Risk Limits Response Model
class RiskLimitsModel {
  final RiskParameters parameters;
  final bool canTrade;
  final String limitReason;
  final double currentExposure;
  final double dailyPnl;
  final int consecutiveLosses;

  RiskLimitsModel({
    required this.parameters,
    required this.canTrade,
    required this.limitReason,
    required this.currentExposure,
    required this.dailyPnl,
    required this.consecutiveLosses,
  });

  factory RiskLimitsModel.fromJson(Map<String, dynamic> json) {
    return RiskLimitsModel(
      parameters: RiskParameters.fromJson(json['parameters']),
      canTrade: json['can_trade'] ?? true,
      limitReason: json['limit_reason'] ?? '',
      currentExposure: (json['current_exposure'] ?? 0).toDouble(),
      dailyPnl: (json['daily_pnl'] ?? 0).toDouble(),
      consecutiveLosses: json['consecutive_losses'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parameters': parameters.toJson(),
      'can_trade': canTrade,
      'limit_reason': limitReason,
      'current_exposure': currentExposure,
      'daily_pnl': dailyPnl,
      'consecutive_losses': consecutiveLosses,
    };
  }
}
