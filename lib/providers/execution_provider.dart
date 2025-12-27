import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/execution_stats.dart';
import 'services_provider.dart';

part 'execution_provider.g.dart';

/// Provider for latency statistics
///
/// Fetches and caches latency metrics including:
/// - Average latency
/// - Percentile distribution (P50, P95, P99)
/// - Min/Max latency values
/// - Total executions measured
@riverpod
class LatencyStatsNotifier extends _$LatencyStatsNotifier {
  @override
  FutureOr<LatencyStats> build() async {
    return _fetchLatencyStats();
  }

  Future<LatencyStats> _fetchLatencyStats() async {
    final service = ref.read(executionServiceProvider);
    return await service.getLatencyStats();
  }

  /// Manual refresh of latency statistics
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchLatencyStats());
  }
}

/// Provider for execution history
///
/// Fetches recent execution history with configurable limit.
/// Includes execution details, latency, status, and errors.
///
/// Parameters:
/// - limit: Maximum number of executions to fetch (default: 50)
@riverpod
class ExecutionHistoryNotifier extends _$ExecutionHistoryNotifier {
  int _limit = 50;

  @override
  FutureOr<ExecutionHistory> build({int limit = 50}) async {
    _limit = limit;
    return _fetchExecutionHistory();
  }

  Future<ExecutionHistory> _fetchExecutionHistory() async {
    final service = ref.read(executionServiceProvider);
    return await service.getExecutionHistory(limit: _limit);
  }

  /// Manual refresh of execution history
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchExecutionHistory());
  }

  /// Update limit and refresh
  Future<void> updateLimit(int newLimit) async {
    _limit = newLimit;
    await refresh();
  }
}

/// Provider for execution queue state
///
/// Fetches current execution queue including:
/// - Pending orders
/// - Queue length
/// - Average wait time
/// - Queue health status
@riverpod
class ExecutionQueueNotifier extends _$ExecutionQueueNotifier {
  @override
  FutureOr<ExecutionQueue> build() async {
    return _fetchExecutionQueue();
  }

  Future<ExecutionQueue> _fetchExecutionQueue() async {
    final service = ref.read(executionServiceProvider);
    return await service.getExecutionQueue();
  }

  /// Manual refresh of execution queue
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchExecutionQueue());
  }
}

/// Provider for execution performance metrics
///
/// Fetches comprehensive performance data:
/// - Slippage statistics
/// - Fill rate
/// - Success/Failure counts
/// - Error rate
/// - Per-symbol metrics
@riverpod
class ExecutionPerformanceNotifier extends _$ExecutionPerformanceNotifier {
  @override
  FutureOr<ExecutionPerformance> build() async {
    return _fetchExecutionPerformance();
  }

  Future<ExecutionPerformance> _fetchExecutionPerformance() async {
    final service = ref.read(executionServiceProvider);
    return await service.getExecutionPerformance();
  }

  /// Manual refresh of execution performance
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchExecutionPerformance());
  }
}

/// Provider for metrics export
///
/// Exports execution metrics in various formats.
///
/// Parameters:
/// - format: Export format ('csv', 'json', 'excel')
/// - period: Time period ('7d', '30d', '90d', 'all')
/// - metrics: List of metrics to export
@riverpod
class MetricsExporter extends _$MetricsExporter {
  @override
  FutureOr<MetricsExportResult?> build() {
    return null;
  }

  /// Export metrics with specified parameters
  Future<MetricsExportResult> exportMetrics({
    required String format,
    required String period,
    required List<String> metrics,
  }) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(executionServiceProvider);
      final result = await service.exportMetrics(
        format: format,
        period: period,
        metrics: metrics,
      );

      state = AsyncValue.data(result);
      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Reset export state
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for auto-refresh configuration
///
/// State provider for controlling auto-refresh behavior
@riverpod
class ExecutionAutoRefresh extends _$ExecutionAutoRefresh {
  @override
  bool build() {
    return false;
  }

  /// Toggle auto-refresh
  void toggle() {
    state = !state;
  }

  /// Set auto-refresh state
  void set(bool value) {
    state = value;
  }
}

/// Provider for selected history filter
///
/// Filters execution history by status
@riverpod
class ExecutionHistoryFilter extends _$ExecutionHistoryFilter {
  @override
  String build() {
    return 'all'; // all, filled, partial, rejected
  }

  /// Update filter
  void setFilter(String filter) {
    state = filter;
  }
}

/// Filtered execution history provider
///
/// Returns filtered execution history based on selected filter
@riverpod
List<ExecutionHistoryEntry> filteredExecutionHistory(
  FilteredExecutionHistoryRef ref, {
  int limit = 50,
}) {
  final historyAsync = ref.watch(executionHistoryNotifierProvider(limit: limit));
  final filter = ref.watch(executionHistoryFilterProvider);

  return historyAsync.when(
    data: (history) {
      if (filter == 'all') {
        return history.executions;
      }
      return history.executions
          .where((e) => e.status.toLowerCase() == filter.toLowerCase())
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for execution statistics summary
///
/// Calculates aggregated statistics from execution history
@riverpod
class ExecutionStatsSummary extends _$ExecutionStatsSummary {
  @override
  ExecutionSummary build() {
    final historyAsync = ref.watch(executionHistoryNotifierProvider(limit: 100));
    final latencyAsync = ref.watch(latencyStatsNotifierProvider);
    final performanceAsync = ref.watch(executionPerformanceNotifierProvider);

    return historyAsync.when(
      data: (history) => _calculateSummary(
        history,
        latencyAsync.value,
        performanceAsync.value,
      ),
      loading: () => ExecutionSummary.empty(),
      error: (_, __) => ExecutionSummary.empty(),
    );
  }

  ExecutionSummary _calculateSummary(
    ExecutionHistory history,
    LatencyStats? latency,
    ExecutionPerformance? performance,
  ) {
    if (history.executions.isEmpty) {
      return ExecutionSummary.empty();
    }

    final filled = history.executions
        .where((e) => e.status.toLowerCase() == 'filled')
        .length;
    final partial = history.executions
        .where((e) => e.status.toLowerCase() == 'partial')
        .length;
    final rejected = history.executions
        .where((e) => e.status.toLowerCase() == 'rejected')
        .length;

    final avgLatency = latency?.avgLatency ?? 0.0;
    final fillRate = performance?.fillRate ?? 0.0;
    final avgSlippage = performance?.avgSlippage ?? 0.0;

    return ExecutionSummary(
      totalExecutions: history.totalCount,
      filledExecutions: filled,
      partialExecutions: partial,
      rejectedExecutions: rejected,
      avgLatency: avgLatency,
      fillRate: fillRate,
      avgSlippage: avgSlippage,
    );
  }
}

/// Execution summary model
class ExecutionSummary {
  final int totalExecutions;
  final int filledExecutions;
  final int partialExecutions;
  final int rejectedExecutions;
  final double avgLatency;
  final double fillRate;
  final double avgSlippage;

  ExecutionSummary({
    required this.totalExecutions,
    required this.filledExecutions,
    required this.partialExecutions,
    required this.rejectedExecutions,
    required this.avgLatency,
    required this.fillRate,
    required this.avgSlippage,
  });

  factory ExecutionSummary.empty() {
    return ExecutionSummary(
      totalExecutions: 0,
      filledExecutions: 0,
      partialExecutions: 0,
      rejectedExecutions: 0,
      avgLatency: 0.0,
      fillRate: 0.0,
      avgSlippage: 0.0,
    );
  }

  double get successRate {
    if (totalExecutions == 0) return 0.0;
    return (filledExecutions / totalExecutions) * 100;
  }
}
