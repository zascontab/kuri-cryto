import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/backtest.dart';
import 'services_provider.dart';

part 'backtest_provider.g.dart';

/// Provider for running a backtest
///
/// Executes a backtest and returns the backtest ID
@riverpod
class BacktestRunner extends _$BacktestRunner {
  @override
  FutureOr<String?> build() {
    return null;
  }

  /// Run a new backtest
  Future<String> run(BacktestConfig config) async {
    state = const AsyncValue.loading();

    return await state.whenData((_) async {
      final service = ref.read(backtestServiceProvider);
      final backtestId = await service.runBacktest(config);

      state = AsyncValue.data(backtestId);

      // Invalidate backtest list to refresh
      ref.invalidate(backtestListProvider);

      return backtestId;
    }).value!;
  }
}

/// Provider for backtest results
///
/// Fetches results for a specific backtest ID
@riverpod
Future<BacktestResult> backtestResult(
  BacktestResultRef ref,
  String backtestId,
) async {
  final service = ref.watch(backtestServiceProvider);
  return await service.getBacktestResults(backtestId);
}

/// Provider for backtest status
///
/// Checks the status of a running backtest
@riverpod
Future<String> backtestStatus(
  BacktestStatusRef ref,
  String backtestId,
) async {
  final service = ref.watch(backtestServiceProvider);
  return await service.getBacktestStatus(backtestId);
}

/// Provider for list of all backtests
///
/// Fetches all backtests (recent first)
@riverpod
class BacktestList extends _$BacktestList {
  @override
  FutureOr<List<BacktestResult>> build({int limit = 50}) async {
    return _fetchBacktests(limit);
  }

  Future<List<BacktestResult>> _fetchBacktests(int limit) async {
    final service = ref.read(backtestServiceProvider);
    return await service.listBacktests(limit: limit);
  }

  /// Refresh the backtest list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchBacktests(50));
  }

  /// Delete a backtest
  Future<void> delete(String backtestId) async {
    final service = ref.read(backtestServiceProvider);
    await service.deleteBacktest(backtestId);

    // Refresh the list
    await refresh();
  }
}

/// Provider for available strategies
///
/// Fetches list of strategies available for backtesting
@riverpod
Future<List<String>> availableBacktestStrategies(
  AvailableBacktestStrategiesRef ref,
) async {
  final service = ref.watch(backtestServiceProvider);
  return await service.getAvailableStrategies();
}

/// Provider for selected backtest result
///
/// Manages the currently selected backtest for viewing
@riverpod
class SelectedBacktest extends _$SelectedBacktest {
  @override
  BacktestResult? build() {
    return null;
  }

  void select(BacktestResult backtest) {
    state = backtest;
  }

  void selectById(String backtestId) async {
    final service = ref.read(backtestServiceProvider);
    final result = await service.getBacktestResults(backtestId);
    state = result;
  }

  void clear() {
    state = null;
  }
}

/// Provider for backtest configuration form state
///
/// Manages the state of the backtest configuration form
@riverpod
class BacktestConfigForm extends _$BacktestConfigForm {
  @override
  BacktestConfig build() {
    return BacktestConfig(
      symbol: 'BTCUSDT',
      strategy: 'rsi_scalping',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now(),
      initialCapital: 10000.0,
    );
  }

  void updateSymbol(String symbol) {
    state = BacktestConfig(
      symbol: symbol,
      strategy: state.strategy,
      startDate: state.startDate,
      endDate: state.endDate,
      initialCapital: state.initialCapital,
      strategyParams: state.strategyParams,
    );
  }

  void updateStrategy(String strategy) {
    state = BacktestConfig(
      symbol: state.symbol,
      strategy: strategy,
      startDate: state.startDate,
      endDate: state.endDate,
      initialCapital: state.initialCapital,
      strategyParams: state.strategyParams,
    );
  }

  void updateStartDate(DateTime startDate) {
    state = BacktestConfig(
      symbol: state.symbol,
      strategy: state.strategy,
      startDate: startDate,
      endDate: state.endDate,
      initialCapital: state.initialCapital,
      strategyParams: state.strategyParams,
    );
  }

  void updateEndDate(DateTime endDate) {
    state = BacktestConfig(
      symbol: state.symbol,
      strategy: state.strategy,
      startDate: state.startDate,
      endDate: endDate,
      initialCapital: state.initialCapital,
      strategyParams: state.strategyParams,
    );
  }

  void updateInitialCapital(double initialCapital) {
    state = BacktestConfig(
      symbol: state.symbol,
      strategy: state.strategy,
      startDate: state.startDate,
      endDate: state.endDate,
      initialCapital: initialCapital,
      strategyParams: state.strategyParams,
    );
  }

  void updateStrategyParams(Map<String, dynamic> params) {
    state = BacktestConfig(
      symbol: state.symbol,
      strategy: state.strategy,
      startDate: state.startDate,
      endDate: state.endDate,
      initialCapital: state.initialCapital,
      strategyParams: params,
    );
  }

  void reset() {
    state = BacktestConfig(
      symbol: 'BTCUSDT',
      strategy: 'rsi_scalping',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now(),
      initialCapital: 10000.0,
    );
  }
}

/// Provider to check if backtest is profitable
@riverpod
bool isBacktestProfitable(IsBacktestProfitableRef ref, BacktestResult result) {
  return result.metrics.totalPnl > 0;
}

/// Provider to get performance rating
@riverpod
String backtestPerformanceRating(
  BacktestPerformanceRatingRef ref,
  BacktestResult result,
) {
  final winRate = result.metrics.winRate;
  final sharpe = result.metrics.sharpeRatio;

  if (winRate >= 70 && sharpe >= 2.0) {
    return 'Excellent';
  } else if (winRate >= 60 && sharpe >= 1.5) {
    return 'Very Good';
  } else if (winRate >= 50 && sharpe >= 1.0) {
    return 'Good';
  } else if (winRate >= 40 && sharpe >= 0.5) {
    return 'Fair';
  } else {
    return 'Poor';
  }
}
