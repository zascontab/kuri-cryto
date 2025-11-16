import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/backtest.dart';
import '../providers/backtest_provider.dart';
import '../l10n/l10n.dart';

/// Backtest Screen
///
/// Allows users to run backtests and view results
class BacktestScreen extends ConsumerStatefulWidget {
  const BacktestScreen({super.key});

  @override
  ConsumerState<BacktestScreen> createState() => _BacktestScreenState();
}

class _BacktestScreenState extends ConsumerState<BacktestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _currentBacktestId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10n.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.backtesting),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.newBacktest),
            Tab(text: l10n.history),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewBacktestTab(theme, l10n),
          _buildHistoryTab(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildNewBacktestTab(ThemeData theme, L10n l10n) {
    if (_currentBacktestId != null) {
      return _buildBacktestResults(theme, l10n, _currentBacktestId!);
    }

    return _buildBacktestForm(theme, l10n);
  }

  Widget _buildBacktestForm(ThemeData theme, L10n l10n) {
    final config = ref.watch(backtestConfigFormProvider);
    final strategiesAsync = ref.watch(availableBacktestStrategiesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.backtestConfiguration,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Symbol selection
                  _buildSymbolField(theme, l10n, config.symbol),
                  const SizedBox(height: 16),

                  // Strategy selection
                  strategiesAsync.when(
                    data: (strategies) => _buildStrategyField(
                      theme,
                      l10n,
                      config.strategy,
                      strategies,
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => Text(l10n.errorLoadingData),
                  ),
                  const SizedBox(height: 16),

                  // Date range
                  _buildDateRangeFields(theme, l10n, config),
                  const SizedBox(height: 16),

                  // Initial capital
                  _buildInitialCapitalField(theme, l10n, config.initialCapital),
                  const SizedBox(height: 24),

                  // Run button
                  FilledButton.icon(
                    onPressed: () => _runBacktest(l10n),
                    icon: const Icon(Icons.play_arrow),
                    label: Text(l10n.runBacktest),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolField(ThemeData theme, L10n l10n, String currentSymbol) {
    final symbols = ['BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'SOLUSDT', 'ADAUSDT'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.symbol,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: currentSymbol,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: symbols.map((symbol) {
            return DropdownMenuItem(
              value: symbol,
              child: Text(symbol),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              ref.read(backtestConfigFormProvider.notifier).updateSymbol(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildStrategyField(
    ThemeData theme,
    L10n l10n,
    String currentStrategy,
    List<String> strategies,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.strategy,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: currentStrategy,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: strategies.map((strategy) {
            return DropdownMenuItem(
              value: strategy,
              child: Text(strategy.replaceAll('_', ' ').toUpperCase()),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              ref
                  .read(backtestConfigFormProvider.notifier)
                  .updateStrategy(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildDateRangeFields(
    ThemeData theme,
    L10n l10n,
    BacktestConfig config,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dateRange,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                theme,
                l10n.startDate,
                config.startDate,
                (date) => ref
                    .read(backtestConfigFormProvider.notifier)
                    .updateStartDate(date),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                theme,
                l10n.endDate,
                config.endDate,
                (date) => ref
                    .read(backtestConfigFormProvider.notifier)
                    .updateEndDate(date),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(
    ThemeData theme,
    String label,
    DateTime currentDate,
    Function(DateTime) onDateSelected,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: currentDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MMM dd, yyyy').format(currentDate)),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialCapitalField(
    ThemeData theme,
    L10n l10n,
    double currentCapital,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.initialCapital,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: currentCapital.toStringAsFixed(0),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            prefixText: '\$ ',
            hintText: l10n.enterAmount,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (value) {
            final capital = double.tryParse(value);
            if (capital != null) {
              ref
                  .read(backtestConfigFormProvider.notifier)
                  .updateInitialCapital(capital);
            }
          },
        ),
      ],
    );
  }

  Future<void> _runBacktest(L10n l10n) async {
    try {
      HapticFeedback.mediumImpact();

      final config = ref.read(backtestConfigFormProvider);
      final backtestId =
          await ref.read(backtestRunnerProvider.notifier).run(config);

      setState(() {
        _currentBacktestId = backtestId;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.backtestStarted),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Widget _buildBacktestResults(ThemeData theme, L10n l10n, String backtestId) {
    final resultAsync = ref.watch(backtestResultProvider(backtestId));

    return resultAsync.when(
      data: (result) {
        if (result.isRunning) {
          return _buildRunningState(theme, l10n);
        }
        if (result.isFailed) {
          return _buildFailedState(theme, l10n, result.errorMessage);
        }
        return _buildResultsView(theme, l10n, result);
      },
      loading: () => _buildRunningState(theme, l10n),
      error: (error, _) => _buildErrorState(theme, l10n, error),
    );
  }

  Widget _buildRunningState(ThemeData theme, L10n l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            l10n.backtestRunning,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildFailedState(ThemeData theme, L10n l10n, String? errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.backtestFailed,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              setState(() {
                _currentBacktestId = null;
              });
            },
            child: Text(l10n.backToForm),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, L10n l10n, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.errorLoadingData,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(ThemeData theme, L10n l10n, BacktestResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _currentBacktestId = null;
                });
              },
              icon: const Icon(Icons.arrow_back),
              label: Text(l10n.newBacktest),
            ),
          ),
          const SizedBox(height: 16),

          // Summary card
          _buildSummaryCard(theme, l10n, result),
          const SizedBox(height: 16),

          // Performance metrics
          _buildMetricsCard(theme, l10n, result.metrics),
          const SizedBox(height: 16),

          // Equity curve
          _buildEquityCurveCard(theme, l10n, result),
          const SizedBox(height: 16),

          // Trades table
          _buildTradesCard(theme, l10n, result.trades),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, L10n l10n, BacktestResult result) {
    final isProfitable = result.metrics.totalPnl > 0;

    return Card(
      color: isProfitable
          ? const Color(0xFF10B981).withOpacity(0.1)
          : const Color(0xFFEF4444).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              result.config.symbol,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              result.config.strategy.replaceAll('_', ' ').toUpperCase(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isProfitable ? Icons.trending_up : Icons.trending_down,
                  color: isProfitable
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                  size: 32,
                ),
                const SizedBox(width: 8),
                Text(
                  '${isProfitable ? '+' : ''}\$${result.metrics.totalPnl.toStringAsFixed(2)}',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isProfitable
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${result.metrics.totalPnlPercent.toStringAsFixed(2)}%',
              style: theme.textTheme.titleLarge?.copyWith(
                color: isProfitable
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsCard(
    ThemeData theme,
    L10n l10n,
    BacktestMetrics metrics,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.performanceMetrics,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricRow(theme, l10n.totalTrades, metrics.totalTrades.toString()),
            _buildMetricRow(
              theme,
              l10n.winRate,
              '${metrics.winRate.toStringAsFixed(1)}%',
              valueColor: metrics.winRate >= 50
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
            ),
            _buildMetricRow(
              theme,
              l10n.profitFactor,
              metrics.profitFactor.toStringAsFixed(2),
            ),
            _buildMetricRow(
              theme,
              l10n.sharpeRatio,
              metrics.sharpeRatio.toStringAsFixed(2),
            ),
            _buildMetricRow(
              theme,
              l10n.maxDrawdown,
              '-\$${metrics.maxDrawdown.toStringAsFixed(2)} (${metrics.maxDrawdownPercent.toStringAsFixed(2)}%)',
              valueColor: const Color(0xFFEF4444),
            ),
            _buildMetricRow(
              theme,
              l10n.avgWin,
              '\$${metrics.avgWin.toStringAsFixed(2)}',
              valueColor: const Color(0xFF10B981),
            ),
            _buildMetricRow(
              theme,
              l10n.avgLoss,
              '-\$${metrics.avgLoss.abs().toStringAsFixed(2)}',
              valueColor: const Color(0xFFEF4444),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    ThemeData theme,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquityCurveCard(
    ThemeData theme,
    L10n l10n,
    BacktestResult result,
  ) {
    if (result.equityCurve.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = result.equityCurve.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.equity,
      );
    }).toList();

    final minEquity = result.equityCurve
        .map((e) => e.equity)
        .reduce((a, b) => a < b ? a : b);
    final maxEquity = result.equityCurve
        .map((e) => e.equity)
        .reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.equityCurve,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxEquity - minEquity) / 4,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: minEquity * 0.95,
                  maxY: maxEquity * 1.05,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: result.metrics.totalPnl > 0
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: (result.metrics.totalPnl > 0
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444))
                            .withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradesCard(
    ThemeData theme,
    L10n l10n,
    List<BacktestTrade> trades,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.tradeHistory,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text(l10n.entryTime)),
                  DataColumn(label: Text(l10n.exitTime)),
                  DataColumn(label: Text(l10n.side)),
                  DataColumn(label: Text(l10n.entryPrice)),
                  DataColumn(label: Text(l10n.exitPrice)),
                  DataColumn(label: Text(l10n.pnl)),
                ],
                rows: trades.take(10).map((trade) {
                  return DataRow(
                    cells: [
                      DataCell(Text(
                        DateFormat('MMM dd HH:mm').format(trade.entryTime),
                      )),
                      DataCell(Text(
                        DateFormat('MMM dd HH:mm').format(trade.exitTime),
                      )),
                      DataCell(Text(trade.side.toUpperCase())),
                      DataCell(Text('\$${trade.entryPrice.toStringAsFixed(2)}')),
                      DataCell(Text('\$${trade.exitPrice.toStringAsFixed(2)}')),
                      DataCell(
                        Text(
                          '${trade.pnl >= 0 ? '+' : ''}\$${trade.pnl.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: trade.pnl >= 0
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            if (trades.length > 10) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n.showing} 10 ${l10n.of} ${trades.length} ${l10n.trades}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(ThemeData theme, L10n l10n) {
    final backtestsAsync = ref.watch(backtestListProvider());

    return backtestsAsync.when(
      data: (backtests) {
        if (backtests.isEmpty) {
          return _buildEmptyHistoryState(theme, l10n);
        }
        return _buildBacktestsList(theme, l10n, backtests);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorState(theme, l10n, error),
    );
  }

  Widget _buildEmptyHistoryState(ThemeData theme, L10n l10n) {
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
            l10n.noBacktestsYet,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBacktestsList(
    ThemeData theme,
    L10n l10n,
    List<BacktestResult> backtests,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: backtests.length,
      itemBuilder: (context, index) {
        final backtest = backtests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: backtest.metrics.totalPnl > 0
                  ? const Color(0xFF10B981).withOpacity(0.2)
                  : const Color(0xFFEF4444).withOpacity(0.2),
              child: Icon(
                backtest.metrics.totalPnl > 0
                    ? Icons.trending_up
                    : Icons.trending_down,
                color: backtest.metrics.totalPnl > 0
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
              ),
            ),
            title: Text(backtest.config.symbol),
            subtitle: Text(
              '${backtest.config.strategy.replaceAll('_', ' ').toUpperCase()} - ${DateFormat('MMM dd, yyyy').format(backtest.completedAt)}',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${backtest.metrics.totalPnl >= 0 ? '+' : ''}\$${backtest.metrics.totalPnl.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: backtest.metrics.totalPnl > 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
                Text(
                  '${backtest.metrics.winRate.toStringAsFixed(1)}% WR',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _currentBacktestId = backtest.id;
                _tabController.animateTo(0);
              });
            },
          ),
        );
      },
    );
  }
}
