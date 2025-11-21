import 'dart:developer' as developer;
import 'api_client.dart';
import 'api_exception.dart';

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
class RiskLimits {
  final RiskParameters parameters;
  final bool canTrade;
  final String limitReason;
  final double currentExposure;
  final double dailyPnl;
  final int consecutiveLosses;

  RiskLimits({
    required this.parameters,
    required this.canTrade,
    required this.limitReason,
    required this.currentExposure,
    required this.dailyPnl,
    required this.consecutiveLosses,
  });

  factory RiskLimits.fromJson(Map<String, dynamic> json) {
    return RiskLimits(
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

/// Exposure Information Model
class ExposureInfo {
  final double currentExposure;
  final double maxExposure;
  final double exposurePercent;
  final double availableExposure;

  ExposureInfo({
    required this.currentExposure,
    required this.maxExposure,
    required this.exposurePercent,
    required this.availableExposure,
  });

  factory ExposureInfo.fromJson(Map<String, dynamic> json) {
    return ExposureInfo(
      currentExposure: (json['current_exposure']).toDouble(),
      maxExposure: (json['max_exposure']).toDouble(),
      exposurePercent: (json['exposure_percent']).toDouble(),
      availableExposure: (json['available_exposure']).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_exposure': currentExposure,
      'max_exposure': maxExposure,
      'exposure_percent': exposurePercent,
      'available_exposure': availableExposure,
    };
  }
}

/// Risk State Model (Risk Sentinel)
class RiskState {
  final double currentDrawdownDaily;
  final double currentDrawdownWeekly;
  final double currentDrawdownMonthly;
  final double totalExposure;
  final Map<String, double> exposureBySymbol;
  final int consecutiveLosses;
  final String riskMode; // 'Conservative', 'Normal', 'Aggressive', 'ControlledCrazy'
  final bool killSwitchActive;
  final DateTime lastUpdate;

  RiskState({
    required this.currentDrawdownDaily,
    required this.currentDrawdownWeekly,
    required this.currentDrawdownMonthly,
    required this.totalExposure,
    required this.exposureBySymbol,
    required this.consecutiveLosses,
    required this.riskMode,
    required this.killSwitchActive,
    required this.lastUpdate,
  });

  factory RiskState.fromJson(Map<String, dynamic> json) {
    return RiskState(
      currentDrawdownDaily: (json['current_drawdown_daily'] ?? 0).toDouble(),
      currentDrawdownWeekly: (json['current_drawdown_weekly'] ?? 0).toDouble(),
      currentDrawdownMonthly: (json['current_drawdown_monthly'] ?? 0).toDouble(),
      totalExposure: (json['total_exposure'] ?? 0).toDouble(),
      exposureBySymbol: Map<String, double>.from(
        (json['exposure_by_symbol'] ?? {}).map(
          (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
        ),
      ),
      consecutiveLosses: json['consecutive_losses'] ?? 0,
      riskMode: json['risk_mode'] ?? 'Normal',
      killSwitchActive: json['kill_switch_active'] ?? false,
      lastUpdate: DateTime.parse(json['last_update']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_drawdown_daily': currentDrawdownDaily,
      'current_drawdown_weekly': currentDrawdownWeekly,
      'current_drawdown_monthly': currentDrawdownMonthly,
      'total_exposure': totalExposure,
      'exposure_by_symbol': exposureBySymbol,
      'consecutive_losses': consecutiveLosses,
      'risk_mode': riskMode,
      'kill_switch_active': killSwitchActive,
      'last_update': lastUpdate.toIso8601String(),
    };
  }
}

/// Risk Service
///
/// Handles risk management operations:
/// - Get and update risk limits
/// - Monitor exposure
/// - Get Risk Sentinel state
/// - Activate/deactivate kill switch
class RiskService {
  final ApiClient _apiClient;
  static const String _basePath = '/scalping/risk';

  RiskService(this._apiClient);

  /// Get current risk limits
  ///
  /// Returns current risk parameters and limits including
  /// trading status, exposure, and P&L.
  ///
  /// Example:
  /// ```dart
  /// final limits = await riskService.getRiskLimits();
  /// print('Can trade: ${limits.canTrade}');
  /// ```
  Future<RiskLimits> getRiskLimits() async {
    try {
      developer.log('Fetching risk limits...', name: 'RiskService');

      final response = await _apiClient.get<Map<String, dynamic>>('$_basePath/limits');

      if (response['success'] == true && response['data'] != null) {
        final limits = RiskLimits.fromJson(response['data']);
        developer.log('Risk limits retrieved successfully', name: 'RiskService');
        return limits;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log('Error getting risk limits: $e', name: 'RiskService', error: e);
      rethrow;
    }
  }

  /// Update risk limits
  ///
  /// Updates the risk parameters for the trading system.
  ///
  /// Parameters:
  /// - [params]: New risk parameters
  ///
  /// Example:
  /// ```dart
  /// final params = RiskParameters(
  ///   maxPositionSizeUsd: 50.0,
  ///   maxTotalExposureUsd: 100.0,
  ///   stopLossPercent: 0.5,
  ///   takeProfitPercent: 1.0,
  ///   maxDailyLossUsd: 20.0,
  ///   maxConsecutiveLosses: 3,
  /// );
  /// await riskService.updateRiskLimits(params);
  /// ```
  Future<bool> updateRiskLimits(RiskParameters params) async {
    try {
      developer.log('Updating risk limits...', name: 'RiskService');

      final response = await _apiClient.put<Map<String, dynamic>>(
        '$_basePath/limits',
        data: params.toJson(),
      );

      if (response['success'] == true) {
        developer.log('Risk limits updated successfully', name: 'RiskService');
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to update risk limits',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error updating risk limits: $e', name: 'RiskService', error: e);
      rethrow;
    }
  }

  /// Get current exposure
  ///
  /// Returns current exposure information including total,
  /// maximum, percentage, and available exposure.
  ///
  /// Example:
  /// ```dart
  /// final exposure = await riskService.getExposure();
  /// print('Exposure: ${exposure.exposurePercent}%');
  /// ```
  Future<ExposureInfo> getExposure() async {
    try {
      developer.log('Fetching exposure information...', name: 'RiskService');

      final response = await _apiClient.get<Map<String, dynamic>>('$_basePath/exposure');

      if (response['success'] == true && response['data'] != null) {
        final exposure = ExposureInfo.fromJson(response['data']);
        developer.log('Exposure information retrieved successfully', name: 'RiskService');
        return exposure;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log('Error getting exposure: $e', name: 'RiskService', error: e);
      rethrow;
    }
  }

  /// Get Risk Sentinel state
  ///
  /// Returns the current state of the Risk Sentinel including
  /// drawdowns, exposure, and kill switch status.
  ///
  /// Example:
  /// ```dart
  /// final state = await riskService.getSentinelState();
  /// if (state.killSwitchActive) {
  ///   print('Kill switch is active!');
  /// }
  /// ```
  Future<RiskState> getSentinelState() async {
    try {
      developer.log('Fetching Risk Sentinel state...', name: 'RiskService');

      final response = await _apiClient.get<Map<String, dynamic>>('$_basePath/sentinel/state');

      if (response['success'] == true && response['data'] != null) {
        final state = RiskState.fromJson(response['data']);
        developer.log('Risk Sentinel state retrieved successfully', name: 'RiskService');
        return state;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log('Error getting Risk Sentinel state: $e', name: 'RiskService', error: e);
      rethrow;
    }
  }

  /// Activate kill switch
  ///
  /// Immediately stops all trading and closes positions.
  /// This is an emergency stop mechanism.
  ///
  /// Parameters:
  /// - [reason]: Reason for activating the kill switch
  ///
  /// Example:
  /// ```dart
  /// await riskService.activateKillSwitch('Manual activation - high volatility');
  /// ```
  Future<bool> activateKillSwitch(String reason) async {
    try {
      developer.log('Activating kill switch...', name: 'RiskService');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_basePath/sentinel/kill-switch',
        data: {
          'reason': reason,
        },
      );

      if (response['success'] == true) {
        developer.log('Kill switch activated successfully', name: 'RiskService');
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to activate kill switch',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error activating kill switch: $e', name: 'RiskService', error: e);
      rethrow;
    }
  }

  /// Deactivate kill switch
  ///
  /// Deactivates the kill switch to resume normal trading.
  ///
  /// Example:
  /// ```dart
  /// await riskService.deactivateKillSwitch();
  /// ```
  Future<bool> deactivateKillSwitch() async {
    try {
      developer.log('Deactivating kill switch...', name: 'RiskService');

      final response = await _apiClient.delete<Map<String, dynamic>>(
        '$_basePath/sentinel/kill-switch',
      );

      if (response['success'] == true) {
        developer.log('Kill switch deactivated successfully', name: 'RiskService');
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to deactivate kill switch',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error deactivating kill switch: $e', name: 'RiskService', error: e);
      rethrow;
    }
  }

  /// Check if a trade is within risk limits
  ///
  /// Validates if a proposed trade is within risk limits before execution.
  ///
  /// Parameters:
  /// - [positionSizeUsd]: Position size in USD
  ///
  /// Returns true if the trade is allowed.
  ///
  /// Example:
  /// ```dart
  /// final allowed = await riskService.checkTradeAllowed(45.0);
  /// if (!allowed) {
  ///   print('Trade exceeds risk limits');
  /// }
  /// ```
  Future<bool> checkTradeAllowed(double positionSizeUsd) async {
    try {
      developer.log('Checking if trade is allowed...', name: 'RiskService');

      final limits = await getRiskLimits();

      if (!limits.canTrade) {
        developer.log('Trading is not allowed: ${limits.limitReason}', name: 'RiskService');
        return false;
      }

      if (positionSizeUsd > limits.parameters.maxPositionSizeUsd) {
        developer.log('Position size exceeds limit', name: 'RiskService');
        return false;
      }

      final newExposure = limits.currentExposure + positionSizeUsd;
      if (newExposure > limits.parameters.maxTotalExposureUsd) {
        developer.log('Total exposure would exceed limit', name: 'RiskService');
        return false;
      }

      developer.log('Trade is allowed', name: 'RiskService');
      return true;
    } catch (e) {
      developer.log('Error checking trade: $e', name: 'RiskService', error: e);
      rethrow;
    }
  }

  /// Get available trading capacity
  ///
  /// Returns the remaining capacity for new positions in USD.
  ///
  /// Example:
  /// ```dart
  /// final capacity = await riskService.getAvailableCapacity();
  /// print('Available capacity: \$$capacity');
  /// ```
  Future<double> getAvailableCapacity() async {
    try {
      developer.log('Calculating available capacity...', name: 'RiskService');

      final exposure = await getExposure();
      final available = exposure.availableExposure;

      developer.log('Available capacity: \$$available', name: 'RiskService');
      return available;
    } catch (e) {
      developer.log('Error getting available capacity: $e', name: 'RiskService', error: e);
      rethrow;
    }
  }

  /// Get risk mode
  ///
  /// Returns the current risk mode (Conservative, Normal, Aggressive, etc.)
  ///
  /// Example:
  /// ```dart
  /// final mode = await riskService.getRiskMode();
  /// print('Current risk mode: $mode');
  /// ```
  Future<String> getRiskMode() async {
    try {
      developer.log('Fetching risk mode...', name: 'RiskService');

      final state = await getSentinelState();
      final mode = state.riskMode;

      developer.log('Risk mode: $mode', name: 'RiskService');
      return mode;
    } catch (e) {
      developer.log('Error getting risk mode: $e', name: 'RiskService', error: e);
      rethrow;
    }
  }

  /// Check if kill switch is active
  ///
  /// Returns true if the kill switch is currently active.
  ///
  /// Example:
  /// ```dart
  /// final active = await riskService.isKillSwitchActive();
  /// if (active) {
  ///   print('Trading is disabled');
  /// }
  /// ```
  Future<bool> isKillSwitchActive() async {
    try {
      developer.log('Checking kill switch status...', name: 'RiskService');

      final state = await getSentinelState();
      final active = state.killSwitchActive;

      developer.log('Kill switch active: $active', name: 'RiskService');
      return active;
    } catch (e) {
      developer.log('Error checking kill switch: $e', name: 'RiskService', error: e);
      rethrow;
    }
  }
}
