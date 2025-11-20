import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/ai_bot_status.dart';
import '../models/ai_bot_config.dart';
import '../models/ai_analysis.dart';
import '../services/ai_bot_service.dart';
import 'services_provider.dart';

part 'ai_bot_provider.g.dart';

/// Provider for AI Bot Service
@riverpod
AiBotService aiBotService(AiBotServiceRef ref) {
  final dio = ref.watch(dioProvider);
  return AiBotService(dio);
}

/// Provider for AI Bot status with auto-refresh every 5 seconds
///
/// Fetches current AI Bot status including:
/// - Running state (running, paused, emergency stop)
/// - Uptime and analysis/execution counts
/// - Daily loss and trades
/// - Open positions
/// - Current configuration
///
/// Auto-refreshes every 5 seconds while provider is alive
@riverpod
class AiBotStatusNotifier extends _$AiBotStatusNotifier {
  Timer? _timer;

  @override
  FutureOr<AiBotStatus> build() async {
    ref.onDispose(() {
      _timer?.cancel();
    });

    _startAutoRefresh();
    return _fetchStatus();
  }

  Future<AiBotStatus> _fetchStatus() async {
    final service = ref.read(aiBotServiceProvider);
    return await service.getStatus();
  }

  void _startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      refresh();
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchStatus());
  }

  /// Start the AI Bot
  Future<void> start() async {
    try {
      final service = ref.read(aiBotServiceProvider);
      await service.start();
      await refresh();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Stop the AI Bot
  Future<void> stop() async {
    try {
      final service = ref.read(aiBotServiceProvider);
      await service.stop();
      await refresh();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Pause the AI Bot
  Future<void> pause() async {
    try {
      final service = ref.read(aiBotServiceProvider);
      await service.pause();
      await refresh();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Resume the AI Bot
  Future<void> resume() async {
    try {
      final service = ref.read(aiBotServiceProvider);
      await service.resume();
      await refresh();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Emergency stop - immediately halt all operations
  Future<void> emergencyStop() async {
    try {
      final service = ref.read(aiBotServiceProvider);
      await service.emergencyStop();
      await refresh();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

/// Provider for AI Bot Configuration
///
/// Manages bot configuration updates
@riverpod
class AiBotConfigNotifier extends _$AiBotConfigNotifier {
  @override
  FutureOr<AiBotConfig> build() async {
    return _fetchConfig();
  }

  Future<AiBotConfig> _fetchConfig() async {
    final service = ref.read(aiBotServiceProvider);
    return await service.getConfig();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchConfig());
  }

  /// Update configuration
  Future<void> updateConfig(Map<String, dynamic> updates) async {
    try {
      final service = ref.read(aiBotServiceProvider);
      final newConfig = await service.updateConfig(updates);
      state = AsyncValue.data(newConfig);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Enable dry run mode
  Future<void> enableDryRun() async {
    try {
      final service = ref.read(aiBotServiceProvider);
      final newConfig = await service.enableDryRunMode();
      state = AsyncValue.data(newConfig);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Enable live trading mode
  Future<void> enableLiveMode() async {
    try {
      final service = ref.read(aiBotServiceProvider);
      final newConfig = await service.enableLiveMode();
      state = AsyncValue.data(newConfig);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Update confidence threshold
  Future<void> updateConfidenceThreshold(double threshold) async {
    try {
      final service = ref.read(aiBotServiceProvider);
      final newConfig = await service.updateConfidenceThreshold(threshold);
      state = AsyncValue.data(newConfig);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Update trade size
  Future<void> updateTradeSize(double sizeUsd) async {
    try {
      final service = ref.read(aiBotServiceProvider);
      final newConfig = await service.updateTradeSize(sizeUsd);
      state = AsyncValue.data(newConfig);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Update leverage
  Future<void> updateLeverage(int leverage) async {
    try {
      final service = ref.read(aiBotServiceProvider);
      final newConfig = await service.updateLeverage(leverage);
      state = AsyncValue.data(newConfig);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Update trading pair
  Future<void> updateTradingPair(String pair) async {
    try {
      final service = ref.read(aiBotServiceProvider);
      final newConfig = await service.updateTradingPair(pair);
      state = AsyncValue.data(newConfig);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Update safety limits
  Future<void> updateSafetyLimits({
    double? maxDailyLoss,
    int? maxDailyTrades,
    int? maxConsecutiveErrors,
    int? maxOpenPositions,
  }) async {
    try {
      final service = ref.read(aiBotServiceProvider);
      final newConfig = await service.updateSafetyLimits(
        maxDailyLoss: maxDailyLoss,
        maxDailyTrades: maxDailyTrades,
        maxConsecutiveErrors: maxConsecutiveErrors,
        maxOpenPositions: maxOpenPositions,
      );
      state = AsyncValue.data(newConfig);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

/// Provider for AI Bot Positions with auto-refresh every 5 seconds
@riverpod
class AiBotPositions extends _$AiBotPositions {
  Timer? _timer;

  @override
  FutureOr<List<AiPosition>> build() async {
    ref.onDispose(() {
      _timer?.cancel();
    });

    _startAutoRefresh();
    return _fetchPositions();
  }

  Future<List<AiPosition>> _fetchPositions() async {
    final service = ref.read(aiBotServiceProvider);
    return await service.getPositions();
  }

  void _startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      refresh();
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPositions());
  }
}
