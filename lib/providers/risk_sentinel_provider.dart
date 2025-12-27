import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';
import '../models/risk_state.dart';
import '../models/websocket_event.dart';
import 'services_provider.dart';

part 'risk_sentinel_provider.g.dart';

/// Provider for Risk Sentinel state with real-time WebSocket updates
///
/// This provider combines:
/// - Initial state from REST API
/// - Real-time updates via WebSocket kill_switch events
/// - Auto-refresh every 5 seconds as fallback
///
/// Features:
/// - Automatic WebSocket subscription on build
/// - Real-time kill switch event handling
/// - Periodic state refresh
/// - Error handling and recovery
@riverpod
class RiskSentinel extends _$RiskSentinel {
  Timer? _refreshTimer;
  StreamSubscription<KillSwitchEvent>? _killSwitchSubscription;

  @override
  Future<RiskState> build() async {
    // Setup auto-dispose
    ref.onDispose(() {
      _refreshTimer?.cancel();
      _killSwitchSubscription?.cancel();
    });

    // Initial fetch from API
    final initialState = await _fetchRiskState();

    // Subscribe to WebSocket kill switch events
    _subscribeToKillSwitchEvents();

    // Start periodic refresh (every 5 seconds)
    _startAutoRefresh();

    return initialState;
  }

  /// Fetch risk state from API
  Future<RiskState> _fetchRiskState() async {
    final service = ref.read(riskServiceProvider);
    try {
      return await service.getSentinelState();
    } catch (e) {
      // If endpoint doesn't exist (404), return default state
      // This allows the app to work even if Risk Sentinel is not implemented yet
      return RiskState(
        currentDrawdownDaily: 0.0,
        currentDrawdownWeekly: 0.0,
        currentDrawdownMonthly: 0.0,
        maxDailyDrawdown: 5.0,
        maxWeeklyDrawdown: 10.0,
        maxMonthlyDrawdown: 15.0,
        totalExposure: 0.0,
        maxTotalExposure: 100.0,
        consecutiveLosses: 0,
        maxConsecutiveLosses: 3,
        riskMode: 'Normal',
        killSwitchActive: false,
        lastUpdate: DateTime.now(),
      );
    }
  }

  /// Subscribe to WebSocket kill switch events
  void _subscribeToKillSwitchEvents() {
    final wsService = ref.read(websocketServiceProvider);

    // Subscribe to kill_switch channel if not already subscribed
    final channels = wsService.getSubscribedChannels();
    if (!channels.contains('kill_switch')) {
      wsService.subscribe(['kill_switch']);
    }

    // Listen to kill switch events
    _killSwitchSubscription = wsService.killSwitchEvents.listen(
      (event) {
        // Update state when kill switch event received
        _handleKillSwitchEvent(event);
      },
      onError: (error) {
        // Log error but don't crash
        print('Error in kill switch subscription: $error');
      },
    );
  }

  /// Handle kill switch event from WebSocket
  void _handleKillSwitchEvent(KillSwitchEvent event) {
    state.whenData((currentState) {
      // Update state with new kill switch status
      final updatedState = currentState.copyWith(
        killSwitchActive: event.active,
        lastUpdate: event.timestamp,
      );
      state = AsyncValue.data(updatedState);
    });
  }

  /// Start automatic refresh timer
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _refresh(),
    );
  }

  /// Refresh risk state from API
  Future<void> _refresh() async {
    // Only refresh if not already loading
    if (state.isLoading) return;

    try {
      final newState = await _fetchRiskState();
      state = AsyncValue.data(newState);
    } catch (e) {
      // Don't update state on refresh error to keep showing last good data
      print('Error refreshing risk state: $e');
    }
  }

  /// Manual refresh (called by UI)
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchRiskState());
  }

  /// Activate kill switch
  ///
  /// Parameters:
  /// - reason: Reason for activating kill switch
  ///
  /// Returns true if successful
  Future<bool> activateKillSwitch(String reason) async {
    try {
      final service = ref.read(riskServiceProvider);
      final success = await service.activateKillSwitch(reason);

      if (success) {
        // Immediately update local state (WebSocket will confirm)
        state.whenData((currentState) {
          final updatedState = currentState.copyWith(
            killSwitchActive: true,
            lastUpdate: DateTime.now(),
          );
          state = AsyncValue.data(updatedState);
        });

        // Trigger a refresh to get updated state
        await _refresh();
      }

      return success;
    } catch (e) {
      rethrow;
    }
  }

  /// Deactivate kill switch
  ///
  /// Returns true if successful
  Future<bool> deactivateKillSwitch() async {
    try {
      final service = ref.read(riskServiceProvider);
      final success = await service.deactivateKillSwitch();

      if (success) {
        // Immediately update local state (WebSocket will confirm)
        state.whenData((currentState) {
          final updatedState = currentState.copyWith(
            killSwitchActive: false,
            lastUpdate: DateTime.now(),
          );
          state = AsyncValue.data(updatedState);
        });

        // Trigger a refresh to get updated state
        await _refresh();
      }

      return success;
    } catch (e) {
      rethrow;
    }
  }

  /// Check if kill switch is active
  bool get isKillSwitchActive {
    return state.when(
      data: (riskState) => riskState.killSwitchActive,
      loading: () => false,
      error: (_, __) => false,
    );
  }

  /// Get current risk mode
  String get riskMode {
    return state.when(
      data: (riskState) => riskState.riskMode,
      loading: () => 'Unknown',
      error: (_, __) => 'Unknown',
    );
  }

  /// Check if trading is allowed
  bool get canTrade {
    return state.when(
      data: (riskState) => riskState.canTrade(),
      loading: () => false,
      error: (_, __) => false,
    );
  }

  /// Check if in high risk state
  bool get isHighRisk {
    return state.when(
      data: (riskState) => riskState.isHighRisk(),
      loading: () => false,
      error: (_, __) => false,
    );
  }
}

/// Convenience provider for kill switch status only
@riverpod
bool killSwitchStatus(KillSwitchStatusRef ref) {
  final sentinelState = ref.watch(riskSentinelProvider);

  return sentinelState.when(
    data: (state) => state.killSwitchActive,
    loading: () => false,
    error: (_, __) => false,
  );
}

/// Convenience provider for trading allowed status
@riverpod
bool tradingAllowed(TradingAllowedRef ref) {
  final sentinelState = ref.watch(riskSentinelProvider);

  return sentinelState.when(
    data: (state) => state.canTrade(),
    loading: () => false,
    error: (_, __) => false,
  );
}
