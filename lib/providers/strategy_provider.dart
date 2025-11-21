import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/strategy.dart';
import '../models/strategy_performance.dart';
import '../services/strategy_service.dart';
import 'services_provider.dart';

part 'strategy_provider.g.dart';

/// Provider for all available strategies
///
/// Fetches and manages the list of all trading strategies:
/// - RSI Scalping
/// - MACD Scalping
/// - Bollinger Scalping
/// - Volume Scalping
/// - AI Scalping
///
/// Each strategy includes:
/// - Name and status (active/inactive)
/// - Weight in ensemble
/// - Basic performance metrics
@riverpod
class Strategies extends _$Strategies {
  @override
  FutureOr<List<Strategy>> build() async {
    return _fetchStrategies();
  }

  Future<List<Strategy>> _fetchStrategies() async {
    final service = ref.read(strategyServiceProvider);
    return await service.getStrategies();
  }

  /// Manual refresh of strategies list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchStrategies());
  }

  /// Get a specific strategy by name
  Strategy? getByName(String name) {
    return state.value?.firstWhere(
      (s) => s.name == name,
      orElse: () => throw Exception('Strategy not found: $name'),
    );
  }
}

/// Provider for selected strategy in UI
///
/// State provider to track which strategy is selected for detailed view
/// or configuration. Returns null if no strategy is selected.
@riverpod
class SelectedStrategy extends _$SelectedStrategy {
  @override
  Strategy? build() {
    return null;
  }

  /// Select a strategy
  void select(Strategy strategy) {
    state = strategy;
  }

  /// Select by name
  void selectByName(String name) {
    final strategies = ref.read(strategiesProvider);
    strategies.whenData((list) {
      final strategy = list.firstWhere(
        (s) => s.name == name,
        orElse: () => throw Exception('Strategy not found: $name'),
      );
      state = strategy;
    });
  }

  /// Clear selection
  void clear() {
    state = null;
  }
}

/// Provider for starting a strategy
///
/// Starts an inactive strategy and triggers refresh of strategies list.
@riverpod
class StrategyStarter extends _$StrategyStarter {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Start a strategy by name
  ///
  /// Activates the strategy in the trading engine.
  /// Returns true if successful.
  Future<bool> startStrategy(String strategyName) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(strategyServiceProvider);
      final result = await service.startStrategy(strategyName);

      state = const AsyncValue.data(null);

      // Refresh strategies list to get updated status
      ref.invalidate(strategiesProvider);

      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for stopping a strategy
///
/// Stops an active strategy and triggers refresh of strategies list.
@riverpod
class StrategyStopper extends _$StrategyStopper {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Stop a strategy by name
  ///
  /// Deactivates the strategy in the trading engine.
  /// Returns true if successful.
  Future<bool> stopStrategy(String strategyName) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(strategyServiceProvider);
      final result = await service.stopStrategy(strategyName);

      state = const AsyncValue.data(null);

      // Refresh strategies list to get updated status
      ref.invalidate(strategiesProvider);

      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for updating strategy configuration
///
/// Updates parameters for a specific strategy.
/// Configuration varies by strategy type:
/// - RSI: period, oversold, overbought
/// - MACD: fast, slow, signal periods
/// - Bollinger: period, stdDev
/// - Volume: threshold, period
/// - AI: model parameters
@riverpod
class StrategyConfigUpdater extends _$StrategyConfigUpdater {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Update strategy configuration
  ///
  /// Parameters:
  /// - strategyName: Name of the strategy to update
  /// - config: Map of configuration parameters
  ///
  /// Returns true if successful.
  Future<bool> updateConfig({
    required String strategyName,
    required Map<String, dynamic> config,
  }) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(strategyServiceProvider);
      final result = await service.updateConfig(
        strategyName: strategyName,
        config: config,
      );

      state = const AsyncValue.data(null);

      // Refresh strategies list to get updated config
      ref.invalidate(strategiesProvider);

      // Also invalidate strategy details if viewing the updated strategy
      ref.invalidate(strategyDetailsProvider(strategyName));

      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for detailed strategy information
///
/// Fetches comprehensive details for a specific strategy including:
/// - Full configuration
/// - Detailed performance metrics
/// - Recent trades
/// - P&L history
///
/// Takes strategy name as parameter.
@riverpod
Future<StrategyDetails> strategyDetails(
  StrategyDetailsRef ref,
  String strategyName,
) async {
  final service = ref.watch(strategyServiceProvider);
  return await service.getStrategyDetails(strategyName);
}

/// Provider for strategy performance metrics
///
/// Fetches performance data for a specific strategy:
/// - Total trades
/// - Win rate
/// - Total P&L
/// - Average win/loss
/// - Sharpe ratio
/// - Max drawdown
/// - Profit factor
///
/// Parameters:
/// - strategyName: Name of the strategy
/// - period: Time period ('daily', 'weekly', 'monthly', 'all')
@riverpod
Future<StrategyPerformance> strategyPerformance(
  StrategyPerformanceRef ref, {
  required String strategyName,
  String period = 'daily',
}) async {
  final service = ref.watch(strategyServiceProvider);
  return await service.getStrategyPerformance(
    strategyName: strategyName,
    period: period,
  );
}

/// Provider for active strategies count
///
/// Returns the number of currently active strategies.
/// Derived from strategies list.
@riverpod
int activeStrategiesCount(ActiveStrategiesCountRef ref) {
  final strategiesAsync = ref.watch(strategiesProvider);

  return strategiesAsync.when(
    data: (strategies) => strategies.where((s) => s.active).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

/// Provider for strategies by status
///
/// Filters strategies by active/inactive status.
///
/// Parameters:
/// - active: true for active strategies, false for inactive
@riverpod
List<Strategy> strategiesByStatus(
  StrategiesByStatusRef ref, {
  required bool active,
}) {
  final strategiesAsync = ref.watch(strategiesProvider);

  return strategiesAsync.when(
    data: (strategies) => strategies.where((s) => s.active == active).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for strategy toggle action
///
/// Convenience provider that starts inactive strategies
/// and stops active strategies.
@riverpod
class StrategyToggler extends _$StrategyToggler {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Toggle strategy active state
  ///
  /// If strategy is active, stops it.
  /// If strategy is inactive, starts it.
  Future<bool> toggle(String strategyName) async {
    final strategies = ref.read(strategiesProvider);

    return await strategies.when(
      data: (list) async {
        final strategy = list.firstWhere(
          (s) => s.name == strategyName,
          orElse: () => throw Exception('Strategy not found: $strategyName'),
        );

        if (strategy.active) {
          return await ref.read(strategyStopperProvider.notifier).stopStrategy(strategyName);
        } else {
          return await ref.read(strategyStarterProvider.notifier).startStrategy(strategyName);
        }
      },
      loading: () => throw Exception('Strategies not loaded'),
      error: (e, _) => throw e,
    );
  }
}

/// Provider for aggregated strategy statistics
///
/// Calculates summary statistics across all strategies:
/// - Total strategies
/// - Active strategies
/// - Combined win rate
/// - Combined P&L
@riverpod
class StrategyStats extends _$StrategyStats {
  @override
  StrategyStatistics build() {
    final strategiesAsync = ref.watch(strategiesProvider);

    return strategiesAsync.when(
      data: (strategies) => _calculateStats(strategies),
      loading: () => StrategyStatistics.empty(),
      error: (_, __) => StrategyStatistics.empty(),
    );
  }

  StrategyStatistics _calculateStats(List<Strategy> strategies) {
    if (strategies.isEmpty) {
      return StrategyStatistics.empty();
    }

    final active = strategies.where((s) => s.active).length;

    final totalPnl = strategies.fold<double>(
      0,
      (sum, s) => sum + (s.performance?.totalPnl ?? 0),
    );

    final avgWinRate = strategies.isEmpty
        ? 0.0
        : strategies.fold<double>(
              0,
              (sum, s) => sum + (s.performance?.winRate ?? 0),
            ) /
            strategies.length;

    return StrategyStatistics(
      totalStrategies: strategies.length,
      activeStrategies: active,
      combinedWinRate: avgWinRate,
      combinedPnl: totalPnl,
    );
  }
}

/// Strategy statistics model
class StrategyStatistics {
  final int totalStrategies;
  final int activeStrategies;
  final double combinedWinRate;
  final double combinedPnl;

  StrategyStatistics({
    required this.totalStrategies,
    required this.activeStrategies,
    required this.combinedWinRate,
    required this.combinedPnl,
  });

  factory StrategyStatistics.empty() {
    return StrategyStatistics(
      totalStrategies: 0,
      activeStrategies: 0,
      combinedWinRate: 0,
      combinedPnl: 0,
    );
  }
}
