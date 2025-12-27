import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/risk_state.dart';
import '../models/risk_limits.dart';
import '../models/exposure.dart';
import 'services_provider.dart';

part 'risk_provider.g.dart';

/// Provider for real-time risk state via WebSocket
///
/// Provides live Risk Sentinel state including:
/// - Drawdown (daily, weekly, monthly)
/// - Total exposure and by symbol
/// - Consecutive losses count
/// - Risk mode (Conservative/Normal/Aggressive)
/// - Kill switch status
///
/// For now, fetches from REST API.
/// TODO: Switch to WebSocket stream when available
@riverpod
Future<RiskState> riskState(RiskStateRef ref) async {
  final service = ref.watch(riskServiceProvider);
  return await service.getSentinelState();
}

/// Provider for risk limits configuration
///
/// Fetches current risk limits:
/// - Max position size
/// - Max total exposure
/// - Stop loss %
/// - Take profit %
/// - Max daily loss
/// - Max consecutive losses
///
/// Can be refreshed manually or invalidated after updates.
@riverpod
class RiskLimits extends _$RiskLimits {
  @override
  FutureOr<RiskLimitsModel> build() async {
    return _fetchLimits();
  }

  Future<RiskLimitsModel> _fetchLimits() async {
    final service = ref.read(riskServiceProvider);
    return await service.getRiskLimits();
  }

  /// Manual refresh of risk limits
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchLimits());
  }
}

/// Provider for current exposure
///
/// Fetches current exposure metrics:
/// - Current total exposure
/// - Max exposure limit
/// - Available exposure
/// - Exposure percentage
/// - Exposure by symbol
///
/// Refreshed periodically or on-demand.
@riverpod
class Exposure extends _$Exposure {
  @override
  FutureOr<ExposureInfo> build() async {
    return _fetchExposure();
  }

  Future<ExposureInfo> _fetchExposure() async {
    final service = ref.read(riskServiceProvider);
    return await service.getExposure();
  }

  /// Manual refresh of exposure
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchExposure());
  }

  /// Get exposure percentage (0-100)
  double getExposurePercent() {
    return state.when(
      data: (ExposureInfo exposure) {
        if (exposure.maxExposure == 0) return 0;
        return (exposure.currentExposure / exposure.maxExposure) * 100;
      },
      loading: () => 0,
      error: (_, __) => 0,
    );
  }

  /// Check if exposure is critical (>80%)
  bool isCritical() {
    return getExposurePercent() > 80;
  }

  /// Check if exposure is warning level (>50%)
  bool isWarning() {
    return getExposurePercent() > 50;
  }
}

/// Provider for activating kill switch
///
/// Emergency stop mechanism that:
/// 1. Stops all trading immediately
/// 2. Closes all open positions
/// 3. Prevents new trades until deactivated
///
/// CRITICAL SAFETY FEATURE
@riverpod
class KillSwitchActivator extends _$KillSwitchActivator {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Activate kill switch with reason
  ///
  /// Parameters:
  /// - reason: Description of why kill switch was activated
  ///
  /// This is an emergency action that:
  /// - Stops the trading engine
  /// - Closes all open positions
  /// - Requires manual deactivation to resume trading
  Future<bool> activate(String reason) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(riskServiceProvider);
      final result = await service.activateKillSwitch(reason);

      state = const AsyncValue.data(null);

      // Invalidate all related providers
      ref.invalidate(riskStateProvider);
      ref.invalidate(riskLimitsProvider);

      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for deactivating kill switch
///
/// Deactivates the kill switch to resume normal trading operations.
/// Should only be used after resolving the issue that triggered the kill switch.
@riverpod
class KillSwitchDeactivator extends _$KillSwitchDeactivator {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Deactivate kill switch
  ///
  /// Resumes normal trading operations.
  /// Use with caution - ensure the issue is resolved first.
  Future<bool> deactivate() async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(riskServiceProvider);
      final result = await service.deactivateKillSwitch();

      state = const AsyncValue.data(null);

      // Invalidate all related providers
      ref.invalidate(riskStateProvider);
      ref.invalidate(riskLimitsProvider);

      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for updating risk limits
///
/// Updates risk management parameters.
/// All parameters are optional - only provided ones will be updated.
@riverpod
class RiskLimitsUpdater extends _$RiskLimitsUpdater {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Update risk limits
  ///
  /// Parameters:
  /// - params: RiskParameters object with new limits
  ///
  /// All fields in RiskParameters are required.
  Future<bool> updateLimits(RiskParameters params) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(riskServiceProvider);
      final result = await service.updateRiskLimits(params);

      state = const AsyncValue.data(null);

      // Refresh risk limits to show updated values
      ref.invalidate(riskLimitsProvider);

      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for kill switch status
///
/// Derived from risk state stream.
/// Returns true if kill switch is active, false otherwise.
@riverpod
bool killSwitchActive(KillSwitchActiveRef ref) {
  final riskStateAsync = ref.watch(riskStateProvider);

  return riskStateAsync.when(
    data: (state) => state.killSwitchActive,
    loading: () => false,
    error: (_, __) => false,
  );
}

/// Provider for current risk mode
///
/// Derived from risk state stream.
/// Returns current risk mode: Conservative, Normal, or Aggressive.
@riverpod
String riskMode(RiskModeRef ref) {
  final riskStateAsync = ref.watch(riskStateProvider);

  return riskStateAsync.when(
    data: (state) => state.riskMode,
    loading: () => 'Unknown',
    error: (_, __) => 'Unknown',
  );
}

/// Provider for drawdown status
///
/// Provides current drawdown levels and warnings.
@riverpod
class DrawdownStatus extends _$DrawdownStatus {
  @override
  DrawdownInfo build() {
    final riskStateAsync = ref.watch(riskStateProvider);

    return riskStateAsync.when(
      data: (state) => DrawdownInfo(
        daily: state.currentDrawdownDaily,
        weekly: state.currentDrawdownWeekly,
        monthly: state.currentDrawdownMonthly,
        isDailyCritical: state.currentDrawdownDaily > 4.5,
        isWeeklyCritical: state.currentDrawdownWeekly > 10.0,
        isMonthlyCritical: state.currentDrawdownMonthly > 20.0,
      ),
      loading: () => DrawdownInfo.empty(),
      error: (_, __) => DrawdownInfo.empty(),
    );
  }

  /// Get highest drawdown level
  double getMaxDrawdown() {
    final info = state;
    return [info.daily, info.weekly, info.monthly]
        .reduce((a, b) => a > b ? a : b);
  }

  /// Check if any drawdown level is critical
  bool isAnyCritical() {
    final info = state;
    return info.isDailyCritical || info.isWeeklyCritical || info.isMonthlyCritical;
  }
}

/// Drawdown information model
class DrawdownInfo {
  final double daily;
  final double weekly;
  final double monthly;
  final bool isDailyCritical;
  final bool isWeeklyCritical;
  final bool isMonthlyCritical;

  DrawdownInfo({
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.isDailyCritical,
    required this.isWeeklyCritical,
    required this.isMonthlyCritical,
  });

  factory DrawdownInfo.empty() {
    return DrawdownInfo(
      daily: 0,
      weekly: 0,
      monthly: 0,
      isDailyCritical: false,
      isWeeklyCritical: false,
      isMonthlyCritical: false,
    );
  }
}

/// Provider for consecutive losses status
///
/// Monitors consecutive losses and warns when approaching limit.
@riverpod
class ConsecutiveLossesStatus extends _$ConsecutiveLossesStatus {
  @override
  ConsecutiveLossesInfo build() {
    final riskStateAsync = ref.watch(riskStateProvider);
    final limitsAsync = ref.watch(riskLimitsProvider);

    if (!riskStateAsync.hasValue || !limitsAsync.hasValue) {
      return ConsecutiveLossesInfo.empty();
    }

    final state = riskStateAsync.value!;
    final limits = limitsAsync.value!;

    final current = state.consecutiveLosses;
    final max = limits.parameters.maxConsecutiveLosses;

    return ConsecutiveLossesInfo(
      current: current,
      max: max,
      percentage: max > 0 ? (current / max) * 100 : 0,
      isWarning: current >= (max * 0.7),
      isCritical: current >= (max * 0.9),
    );
  }
}

/// Consecutive losses information model
class ConsecutiveLossesInfo {
  final int current;
  final int max;
  final double percentage;
  final bool isWarning;
  final bool isCritical;

  ConsecutiveLossesInfo({
    required this.current,
    required this.max,
    required this.percentage,
    required this.isWarning,
    required this.isCritical,
  });

  factory ConsecutiveLossesInfo.empty() {
    return ConsecutiveLossesInfo(
      current: 0,
      max: 0,
      percentage: 0,
      isWarning: false,
      isCritical: false,
    );
  }
}
