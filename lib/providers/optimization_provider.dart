import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/optimization.dart';
import 'services_provider.dart';

part 'optimization_provider.g.dart';

/// Provider for running an optimization
///
/// Executes an optimization and returns the optimization ID
@riverpod
class OptimizationRunner extends _$OptimizationRunner {
  @override
  FutureOr<String?> build() {
    return null;
  }

  /// Run a new optimization
  Future<String> run(OptimizationConfig config) async {
    state = const AsyncValue.loading();

    return await state.whenData((_) async {
      final service = ref.read(optimizationServiceProvider);
      final optimizationId = await service.runOptimization(config);

      state = AsyncValue.data(optimizationId);

      // Invalidate history to refresh
      ref.invalidate(optimizationHistoryProvider);

      return optimizationId;
    }).value!;
  }
}

/// Provider for optimization results
///
/// Fetches results for a specific optimization ID
@riverpod
Future<OptimizationResult> optimizationResult(
  OptimizationResultRef ref,
  String optimizationId,
) async {
  final service = ref.watch(optimizationServiceProvider);
  return await service.getOptimizationResults(optimizationId);
}

/// Provider for optimization history
///
/// Fetches all past optimizations
@riverpod
class OptimizationHistory extends _$OptimizationHistory {
  @override
  FutureOr<List<OptimizationSummary>> build({int limit = 50}) async {
    return _fetchHistory(limit);
  }

  Future<List<OptimizationSummary>> _fetchHistory(int limit) async {
    final service = ref.read(optimizationServiceProvider);
    return await service.getOptimizationHistory(limit: limit);
  }

  /// Refresh the history list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchHistory(50));
  }

  /// Delete an optimization
  Future<void> delete(String optimizationId) async {
    final service = ref.read(optimizationServiceProvider);
    await service.deleteOptimization(optimizationId);

    // Refresh the list
    await refresh();
  }
}

/// Provider for available optimization strategies
///
/// Fetches list of strategies available for optimization
@riverpod
Future<List<String>> availableOptimizationStrategies(
  AvailableOptimizationStrategiesRef ref,
) async {
  final service = ref.watch(optimizationServiceProvider);
  return await service.getAvailableStrategies();
}

/// Provider for default parameter ranges
///
/// Fetches default parameter ranges for a specific strategy
@riverpod
Future<List<ParameterRange>> defaultParameterRanges(
  DefaultParameterRangesRef ref,
  String strategyName,
) async {
  final service = ref.watch(optimizationServiceProvider);
  return await service.getDefaultParameterRanges(strategyName);
}

/// Provider for currently selected optimization
///
/// Manages the currently selected optimization for viewing
@riverpod
class SelectedOptimization extends _$SelectedOptimization {
  @override
  OptimizationResult? build() {
    return null;
  }

  void select(OptimizationResult optimization) {
    state = optimization;
  }

  void selectById(String optimizationId) async {
    final service = ref.read(optimizationServiceProvider);
    final result = await service.getOptimizationResults(optimizationId);
    state = result;
  }

  void clear() {
    state = null;
  }
}

/// Provider for optimization configuration form state
///
/// Manages the state of the optimization configuration form
@riverpod
class OptimizationConfigForm extends _$OptimizationConfigForm {
  @override
  OptimizationConfig build() {
    return OptimizationConfig(
      strategyName: 'rsi_scalping',
      symbol: 'BTCUSDT',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now(),
      parameterRanges: [],
      optimizationMethod: 'grid_search',
      objective: 'sharpe_ratio',
      initialCapital: 10000.0,
    );
  }

  void updateStrategyName(String strategyName) {
    state = OptimizationConfig(
      strategyName: strategyName,
      symbol: state.symbol,
      startDate: state.startDate,
      endDate: state.endDate,
      parameterRanges: state.parameterRanges,
      optimizationMethod: state.optimizationMethod,
      objective: state.objective,
      maxIterations: state.maxIterations,
      initialCapital: state.initialCapital,
    );
  }

  void updateSymbol(String symbol) {
    state = OptimizationConfig(
      strategyName: state.strategyName,
      symbol: symbol,
      startDate: state.startDate,
      endDate: state.endDate,
      parameterRanges: state.parameterRanges,
      optimizationMethod: state.optimizationMethod,
      objective: state.objective,
      maxIterations: state.maxIterations,
      initialCapital: state.initialCapital,
    );
  }

  void updateStartDate(DateTime startDate) {
    state = OptimizationConfig(
      strategyName: state.strategyName,
      symbol: state.symbol,
      startDate: startDate,
      endDate: state.endDate,
      parameterRanges: state.parameterRanges,
      optimizationMethod: state.optimizationMethod,
      objective: state.objective,
      maxIterations: state.maxIterations,
      initialCapital: state.initialCapital,
    );
  }

  void updateEndDate(DateTime endDate) {
    state = OptimizationConfig(
      strategyName: state.strategyName,
      symbol: state.symbol,
      startDate: state.startDate,
      endDate: endDate,
      parameterRanges: state.parameterRanges,
      optimizationMethod: state.optimizationMethod,
      objective: state.objective,
      maxIterations: state.maxIterations,
      initialCapital: state.initialCapital,
    );
  }

  void updateParameterRanges(List<ParameterRange> parameterRanges) {
    state = OptimizationConfig(
      strategyName: state.strategyName,
      symbol: state.symbol,
      startDate: state.startDate,
      endDate: state.endDate,
      parameterRanges: parameterRanges,
      optimizationMethod: state.optimizationMethod,
      objective: state.objective,
      maxIterations: state.maxIterations,
      initialCapital: state.initialCapital,
    );
  }

  void updateOptimizationMethod(String optimizationMethod) {
    state = OptimizationConfig(
      strategyName: state.strategyName,
      symbol: state.symbol,
      startDate: state.startDate,
      endDate: state.endDate,
      parameterRanges: state.parameterRanges,
      optimizationMethod: optimizationMethod,
      objective: state.objective,
      maxIterations: state.maxIterations,
      initialCapital: state.initialCapital,
    );
  }

  void updateObjective(String objective) {
    state = OptimizationConfig(
      strategyName: state.strategyName,
      symbol: state.symbol,
      startDate: state.startDate,
      endDate: state.endDate,
      parameterRanges: state.parameterRanges,
      optimizationMethod: state.optimizationMethod,
      objective: objective,
      maxIterations: state.maxIterations,
      initialCapital: state.initialCapital,
    );
  }

  void updateMaxIterations(int? maxIterations) {
    state = OptimizationConfig(
      strategyName: state.strategyName,
      symbol: state.symbol,
      startDate: state.startDate,
      endDate: state.endDate,
      parameterRanges: state.parameterRanges,
      optimizationMethod: state.optimizationMethod,
      objective: state.objective,
      maxIterations: maxIterations,
      initialCapital: state.initialCapital,
    );
  }

  void updateInitialCapital(double initialCapital) {
    state = OptimizationConfig(
      strategyName: state.strategyName,
      symbol: state.symbol,
      startDate: state.startDate,
      endDate: state.endDate,
      parameterRanges: state.parameterRanges,
      optimizationMethod: state.optimizationMethod,
      objective: state.objective,
      maxIterations: state.maxIterations,
      initialCapital: initialCapital,
    );
  }

  void addParameterRange(ParameterRange range) {
    final newRanges = [...state.parameterRanges, range];
    updateParameterRanges(newRanges);
  }

  void removeParameterRange(int index) {
    final newRanges = [...state.parameterRanges];
    newRanges.removeAt(index);
    updateParameterRanges(newRanges);
  }

  void updateParameterRange(int index, ParameterRange range) {
    final newRanges = [...state.parameterRanges];
    newRanges[index] = range;
    updateParameterRanges(newRanges);
  }

  void reset() {
    state = OptimizationConfig(
      strategyName: 'rsi_scalping',
      symbol: 'BTCUSDT',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now(),
      parameterRanges: [],
      optimizationMethod: 'grid_search',
      objective: 'sharpe_ratio',
      initialCapital: 10000.0,
    );
  }

  void loadDefaultRanges(List<ParameterRange> ranges) {
    updateParameterRanges(ranges);
  }
}

/// Provider for currently running optimization
///
/// Tracks the current optimization in progress
@riverpod
class CurrentOptimization extends _$CurrentOptimization {
  @override
  String? build() {
    return null;
  }

  void start(String optimizationId) {
    state = optimizationId;
  }

  void clear() {
    state = null;
  }
}

/// Provider to calculate total combinations
///
/// Estimates total parameter combinations for current config
@riverpod
int estimatedCombinations(EstimatedCombinationsRef ref) {
  final config = ref.watch(optimizationConfigFormProvider);

  if (config.parameterRanges.isEmpty) return 0;

  int total = 1;
  for (var range in config.parameterRanges) {
    final steps = ((range.max - range.min) / range.step).ceil() + 1;
    total *= steps;
  }

  // For random/bayesian, use max_iterations if set
  if (config.optimizationMethod != 'grid_search' && config.maxIterations != null) {
    return config.maxIterations! < total ? config.maxIterations! : total;
  }

  return total;
}

/// Provider to check if configuration is valid
@riverpod
bool isOptimizationConfigValid(IsOptimizationConfigValidRef ref) {
  final config = ref.watch(optimizationConfigFormProvider);
  return config.validate();
}
