import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/system_status.dart' as models;
import '../models/metrics.dart' as models;
import '../models/health_status.dart' as models;
import 'services_provider.dart';

part 'system_provider.g.dart';

/// Provider for system status with auto-refresh every 5 seconds
///
/// Fetches current system status including:
/// - Running state
/// - Uptime
/// - Pairs count
/// - Active strategies
///
/// Auto-refreshes every 5 seconds while provider is alive
@riverpod
class SystemStatus extends _$SystemStatus {
  Timer? _timer;

  @override
  FutureOr<models.SystemStatus> build() async {
    // Clean up timer on dispose
    ref.onDispose(() {
      _timer?.cancel();
    });

    // Start auto-refresh
    _startAutoRefresh();

    // Initial fetch
    return _fetchStatus();
  }

  /// Fetch system status from API
  Future<models.SystemStatus> _fetchStatus() async {
    final service = ref.read(scalpingServiceProvider);
    return await service.getStatus();
  }

  /// Start auto-refresh timer
  void _startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      refresh();
    });
  }

  /// Manual refresh trigger
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchStatus());
  }

  /// Start the scalping engine
  Future<void> startEngine() async {
    try {
      final service = ref.read(scalpingServiceProvider);
      await service.startEngine();

      // Refresh status after starting
      await refresh();
    } catch (e) {
      // Error will be captured in state
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Stop the scalping engine
  Future<void> stopEngine() async {
    try {
      final service = ref.read(scalpingServiceProvider);
      await service.stopEngine();

      // Refresh status after stopping
      await refresh();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

/// Provider for trading metrics with auto-refresh every 5 seconds
///
/// Provides real-time trading metrics:
/// - Total trades
/// - Win rate
/// - Total P&L
/// - Daily P&L
/// - Active positions
/// - Average latency
///
/// Auto-refreshes every 5 seconds
@riverpod
class Metrics extends _$Metrics {
  Timer? _timer;

  @override
  FutureOr<models.Metrics> build() async {
    ref.onDispose(() {
      _timer?.cancel();
    });

    _startAutoRefresh();
    return _fetchMetrics();
  }

  Future<models.Metrics> _fetchMetrics() async {
    final service = ref.read(scalpingServiceProvider);
    return await service.getMetrics();
  }

  void _startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      refresh();
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchMetrics());
  }
}

/// Provider for health status with auto-refresh every 10 seconds
///
/// Monitors system health
///
/// Auto-refreshes every 10 seconds
@riverpod
class Health extends _$Health {
  Timer? _timer;

  @override
  FutureOr<models.HealthStatus> build() async {
    ref.onDispose(() {
      _timer?.cancel();
    });

    _startAutoRefresh();
    return _fetchHealth();
  }

  Future<models.HealthStatus> _fetchHealth() async {
    final service = ref.read(scalpingServiceProvider);
    return await service.getHealth();
  }

  void _startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      refresh();
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchHealth());
  }
}

/// Provider for pause/resume state of auto-refresh
///
/// Allows UI to pause auto-refresh when app is in background
/// to save battery and bandwidth
@riverpod
class AutoRefreshEnabled extends _$AutoRefreshEnabled {
  @override
  bool build() {
    return true; // Auto-refresh enabled by default
  }

  void enable() => state = true;
  void disable() => state = false;
  void toggle() => state = !state;
}
