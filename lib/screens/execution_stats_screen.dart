import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../l10n/l10n_export.dart';
import '../providers/execution_provider.dart';
import '../widgets/tiktok_modal.dart';

/// Execution Statistics Screen
///
/// Displays execution performance monitoring with tabs:
/// - Latency: Latency statistics and percentiles
/// - History: Recent execution history
/// - Queue: Current execution queue state
/// - Performance: Execution performance metrics
class ExecutionStatsScreen extends ConsumerStatefulWidget {
  const ExecutionStatsScreen({super.key});

  @override
  ConsumerState<ExecutionStatsScreen> createState() => _ExecutionStatsScreenState();
}

class _ExecutionStatsScreenState extends ConsumerState<ExecutionStatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final currentIndex = _tabController.index;
    switch (currentIndex) {
      case 0:
        await ref.read(latencyStatsNotifierProvider.notifier).refresh();
        break;
      case 1:
        await ref.read(executionHistoryNotifierProvider().notifier).refresh();
        break;
      case 2:
        await ref.read(executionQueueNotifierProvider.notifier).refresh();
        break;
      case 3:
        await ref.read(executionPerformanceNotifierProvider.notifier).refresh();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.executionStats),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              HapticFeedback.lightImpact();
              _onRefresh();
            },
            tooltip: l10n.refreshStats,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.latency, icon: const Icon(Icons.speed)),
            Tab(text: l10n.history, icon: const Icon(Icons.history)),
            Tab(text: l10n.queue, icon: const Icon(Icons.queue)),
            Tab(text: l10n.performance, icon: const Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLatencyTab(theme, l10n),
          _buildHistoryTab(theme, l10n),
          _buildQueueTab(theme, l10n),
          _buildPerformanceTab(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildLatencyTab(ThemeData theme, L10n l10n) {
    final latencyAsync = ref.watch(latencyStatsNotifierProvider);

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: latencyAsync.when(
        data: (stats) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.speed, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          l10n.latencyStatistics,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.executionsTracked}: ${stats.totalExecutions}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Latency Metrics
            _buildLatencyCard(
              theme,
              l10n,
              l10n.average,
              stats.avgLatency,
              Icons.av_timer,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildLatencyCard(
              theme,
              l10n,
              l10n.median,
              stats.p50Latency,
              Icons.show_chart,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildLatencyCard(
              theme,
              l10n,
              l10n.percentile95,
              stats.p95Latency,
              Icons.trending_up,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildLatencyCard(
              theme,
              l10n,
              l10n.percentile99,
              stats.p99Latency,
              Icons.warning,
              Colors.deepOrange,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildLatencyCard(
                    theme,
                    l10n,
                    l10n.minimum,
                    stats.minLatency,
                    Icons.arrow_downward,
                    Colors.teal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLatencyCard(
                    theme,
                    l10n,
                    l10n.maximum,
                    stats.maxLatency,
                    Icons.arrow_upward,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorView(theme, l10n, error),
      ),
    );
  }

  Widget _buildLatencyCard(
    ThemeData theme,
    L10n l10n,
    String label,
    double value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${value.toStringAsFixed(2)} ${l10n.ms}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(ThemeData theme, L10n l10n) {
    final historyAsync = ref.watch(executionHistoryNotifierProvider());
    final filter = ref.watch(executionHistoryFilterProvider);

    return Column(
      children: [
        // Filter chips
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(theme, l10n, l10n.all, 'all', filter),
                const SizedBox(width: 8),
                _buildFilterChip(theme, l10n, l10n.filled, 'filled', filter),
                const SizedBox(width: 8),
                _buildFilterChip(theme, l10n, l10n.partial, 'partial', filter),
                const SizedBox(width: 8),
                _buildFilterChip(theme, l10n, l10n.rejected, 'rejected', filter),
              ],
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: historyAsync.when(
              data: (history) {
                final filtered = ref.watch(filteredExecutionHistoryProvider());

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noExecutionsYet,
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final execution = filtered[index];
                    return _buildExecutionCard(theme, l10n, execution);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorView(theme, l10n, error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    ThemeData theme,
    L10n l10n,
    String label,
    String value,
    String currentFilter,
  ) {
    final isSelected = currentFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(executionHistoryFilterProvider.notifier).setFilter(value);
        }
      },
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: theme.colorScheme.primary,
    );
  }

  Widget _buildExecutionCard(ThemeData theme, L10n l10n, dynamic execution) {
    final statusColor = _getStatusColor(execution.status);
    final dateFormat = DateFormat('MMM dd, HH:mm:ss');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Show execution details dialog
          _showExecutionDetails(context, theme, l10n, execution);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          execution.status.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        execution.symbol,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: execution.side.toLowerCase() == 'buy'
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                          : const Color(0xFFF44336).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      execution.side.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: execution.side.toLowerCase() == 'buy'
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFF44336),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      theme,
                      l10n.price,
                      '\$${execution.price.toStringAsFixed(6)}',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoRow(
                      theme,
                      l10n.size,
                      execution.size.toStringAsFixed(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      theme,
                      l10n.latency,
                      '${execution.latency.toStringAsFixed(2)} ${l10n.ms}',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoRow(
                      theme,
                      l10n.time,
                      dateFormat.format(execution.timestamp),
                    ),
                  ),
                ],
              ),
              if (execution.error != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF44336).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    execution.error!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFF44336),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQueueTab(ThemeData theme, L10n l10n) {
    final queueAsync = ref.watch(executionQueueNotifierProvider);

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: queueAsync.when(
        data: (queue) {
          if (queue.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.queueEmpty,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Queue summary
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.queue, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            l10n.executionQueue,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQueueStat(
                              theme,
                              l10n.queueLength,
                              queue.queueLength.toString(),
                            ),
                          ),
                          Expanded(
                            child: _buildQueueStat(
                              theme,
                              l10n.avgWaitTime,
                              '${queue.avgWaitTime.toStringAsFixed(0)} ${l10n.ms}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildQueueStat(
                        theme,
                        l10n.queueStatus,
                        queue.status.toUpperCase(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Queue orders
              ...queue.orders.map((order) => _buildQueueOrderCard(theme, l10n, order)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorView(theme, l10n, error),
      ),
    );
  }

  Widget _buildQueueStat(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQueueOrderCard(ThemeData theme, L10n l10n, dynamic order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.symbol,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '#${order.position}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(theme, l10n.orderId, order.orderId),
                ),
                Expanded(
                  child: _buildInfoRow(theme, l10n.orderType, order.orderType),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    theme,
                    l10n.side,
                    order.side.toUpperCase(),
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    theme,
                    l10n.timeInQueue,
                    '${(order.timeInQueue / 1000).toStringAsFixed(1)}s',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceTab(ThemeData theme, L10n l10n) {
    final performanceAsync = ref.watch(executionPerformanceNotifierProvider);

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: performanceAsync.when(
        data: (performance) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary metrics
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.analytics, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          l10n.executionPerformance,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPerformanceMetric(
                            theme,
                            l10n.fillRate,
                            '${performance.fillRate.toStringAsFixed(1)}%',
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPerformanceMetric(
                            theme,
                            l10n.errorRate,
                            '${performance.errorRate.toStringAsFixed(1)}%',
                            Icons.error,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPerformanceMetric(
                            theme,
                            l10n.avgSlippage,
                            '${performance.avgSlippage.toStringAsFixed(2)} ${l10n.basisPoints}',
                            Icons.trending_down,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPerformanceMetric(
                            theme,
                            l10n.avgExecutionTime,
                            '${performance.avgExecutionTime.toStringAsFixed(2)} ${l10n.ms}',
                            Icons.timer,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Execution counts
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.totalTrades,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCountMetric(
                            theme,
                            l10n.successfulExecutions,
                            performance.successfulExecutions.toString(),
                            const Color(0xFF4CAF50),
                          ),
                        ),
                        Expanded(
                          child: _buildCountMetric(
                            theme,
                            l10n.failedExecutions,
                            performance.failedExecutions.toString(),
                            const Color(0xFFF44336),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // By symbol metrics
            if (performance.slippageBySymbol.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.slippageBySymbol,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...performance.slippageBySymbol.entries.map((entry) =>
                          _buildSymbolMetric(
                            theme,
                            l10n,
                            entry.key,
                            '${entry.value.toStringAsFixed(2)} ${l10n.basisPoints}',
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorView(theme, l10n, error),
      ),
    );
  }

  Widget _buildPerformanceMetric(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCountMetric(
    ThemeData theme,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSymbolMetric(ThemeData theme, L10n l10n, String symbol, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            symbol,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(ThemeData theme, L10n l10n, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.error,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'filled':
        return const Color(0xFF4CAF50);
      case 'partial':
        return Colors.orange;
      case 'rejected':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  void _showExecutionDetails(
    BuildContext context,
    ThemeData theme,
    L10n l10n,
    dynamic execution,
  ) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm:ss');

    // Build content widget
    final contentWidget = SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(l10n.orderId, execution.id),
          _buildDetailRow(l10n.status, execution.status.toUpperCase()),
          _buildDetailRow(l10n.price, '\$${execution.price.toStringAsFixed(6)}'),
          _buildDetailRow(l10n.size, execution.size.toStringAsFixed(4)),
          _buildDetailRow(
            l10n.latency,
            '${execution.latency.toStringAsFixed(2)} ${l10n.ms}',
          ),
          _buildDetailRow(l10n.time, dateFormat.format(execution.timestamp)),
          if (execution.strategy != null)
            _buildDetailRow(l10n.strategy, execution.strategy!),
          if (execution.slippage != null)
            _buildDetailRow(
              l10n.avgSlippage,
              '${execution.slippage!.toStringAsFixed(2)} ${l10n.basisPoints}',
            ),
          if (execution.error != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF44336).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${l10n.error}: ${execution.error}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFF44336),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    showTikTokModal(
      context: context,
      title: '${execution.symbol} - ${execution.side.toUpperCase()}',
      content: contentWidget,
      actions: [
        TikTokModalButton(
          text: l10n.ok,
          isPrimary: true,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
