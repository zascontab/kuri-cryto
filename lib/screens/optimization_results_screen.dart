import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/optimization.dart';
import '../providers/optimization_provider.dart';
import '../services/optimization_service.dart';
import '../providers/services_provider.dart';
import '../l10n/l10n.dart';

/// Optimization Results Screen
///
/// Displays results from a parameter optimization
class OptimizationResultsScreen extends ConsumerStatefulWidget {
  final String optimizationId;

  const OptimizationResultsScreen({
    super.key,
    required this.optimizationId,
  });

  @override
  ConsumerState<OptimizationResultsScreen> createState() =>
      _OptimizationResultsScreenState();
}

class _OptimizationResultsScreenState
    extends ConsumerState<OptimizationResultsScreen> {
  String _sortBy = 'score'; // 'score', 'win_rate', 'total_pnl', 'sharpe_ratio'
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10n.of(context);
    final resultAsync = ref.watch(optimizationResultProvider(widget.optimizationId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.optimizationResults),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(optimizationResultProvider(widget.optimizationId));
            },
          ),
        ],
      ),
      body: resultAsync.when(
        data: (result) {
          if (result.isRunning) {
            return _buildRunningState(theme, l10n, result);
          }
          if (result.isFailed) {
            return _buildFailedState(theme, l10n, result.errorMessage);
          }
          if (result.isCancelled) {
            return _buildCancelledState(theme, l10n);
          }
          return _buildResultsView(theme, l10n, result);
        },
        loading: () => _buildLoadingState(theme, l10n),
        error: (error, _) => _buildErrorState(theme, l10n, error),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme, L10n l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            l10n.loadingResults,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildRunningState(ThemeData theme, L10n l10n, OptimizationResult result) {
    final progress = result.progress ?? 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: progress / 100,
                      strokeWidth: 8,
                    ),
                  ),
                  Text(
                    '$progress%',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.optimizationRunning,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${result.completedCombinations} / ${result.totalCombinations} ${l10n.combinations}',
              style: theme.textTheme.bodyLarge,
            ),
            if (result.estimatedTimeRemaining != null) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n.estimatedTimeRemaining}: ${result.getFormattedTimeRemaining()}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => _cancelOptimization(l10n),
              icon: const Icon(Icons.stop),
              label: Text(l10n.cancelOptimization),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailedState(ThemeData theme, L10n l10n, String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              l10n.optimizationFailed,
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.goBack),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelledState(ThemeData theme, L10n l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cancel_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.optimizationCancelled,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.goBack),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, L10n l10n, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
      ),
    );
  }

  Widget _buildResultsView(ThemeData theme, L10n l10n, OptimizationResult result) {
    final sortedResults = _getSortedResults(result.results);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary card
          _buildSummaryCard(theme, l10n, result),
          const SizedBox(height: 16),

          // Best parameters card
          if (result.bestParameters != null) ...[
            _buildBestParametersCard(theme, l10n, result),
            const SizedBox(height: 16),
          ],

          // Distribution chart
          if (result.results.isNotEmpty) ...[
            _buildDistributionChart(theme, l10n, result.results),
            const SizedBox(height: 16),
          ],

          // Results table
          _buildResultsTable(theme, l10n, sortedResults),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, L10n l10n, OptimizationResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.optimizationSummary,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              l10n.strategy,
              result.config.strategyName.replaceAll('_', ' ').toUpperCase(),
            ),
            _buildSummaryRow(l10n.symbol, result.config.symbol),
            _buildSummaryRow(
              l10n.dateRange,
              '${DateFormat('MMM dd, yyyy').format(result.config.startDate)} - ${DateFormat('MMM dd, yyyy').format(result.config.endDate)}',
            ),
            _buildSummaryRow(
              l10n.optimizationMethod,
              result.config.optimizationMethod.replaceAll('_', ' ').toUpperCase(),
            ),
            _buildSummaryRow(
              l10n.objective,
              result.config.objective.replaceAll('_', ' ').toUpperCase(),
            ),
            _buildSummaryRow(
              l10n.totalCombinations,
              result.totalCombinations.toString(),
            ),
            _buildSummaryRow(
              l10n.duration,
              result.getFormattedDuration(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBestParametersCard(
    ThemeData theme,
    L10n l10n,
    OptimizationResult result,
  ) {
    final best = result.bestParameters!;

    return Card(
      color: const Color(0xFF10B981).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Color(0xFFFBBF24),
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.bestParameters,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...best.parameters.entries.map((param) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(param.key),
                    Text(
                      param.value.toStringAsFixed(2),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const Divider(height: 32),
            _buildMetricRow(theme, l10n.score, best.score.toStringAsFixed(4)),
            _buildMetricRow(theme, l10n.winRate, '${best.winRate.toStringAsFixed(1)}%'),
            _buildMetricRow(theme, l10n.totalPnl, '\$${best.totalPnl.toStringAsFixed(2)}'),
            _buildMetricRow(theme, l10n.sharpeRatio, best.sharpeRatio.toStringAsFixed(2)),
            _buildMetricRow(
              theme,
              l10n.maxDrawdown,
              '\$${best.maxDrawdown.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _applyParameters(l10n, result),
              icon: const Icon(Icons.check),
              label: Text(l10n.applyTheseParameters),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionChart(
    ThemeData theme,
    L10n l10n,
    List<ParameterSet> results,
  ) {
    // Create histogram of scores
    final scores = results.map((r) => r.score).toList();
    final minScore = scores.reduce((a, b) => a < b ? a : b);
    final maxScore = scores.reduce((a, b) => a > b ? a : b);

    // Create 20 bins
    const bins = 20;
    final binSize = (maxScore - minScore) / bins;
    final histogram = List<int>.filled(bins, 0);

    for (var score in scores) {
      final binIndex = ((score - minScore) / binSize).floor().clamp(0, bins - 1);
      histogram[binIndex]++;
    }

    final barGroups = histogram.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: const Color(0xFF3B82F6),
            width: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.scoreDistribution,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  maxY: histogram.reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
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
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsTable(
    ThemeData theme,
    L10n l10n,
    List<ParameterSet> results,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.allResults,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Row(
                    children: [
                      Text(
                        l10n.sortBy,
                        style: theme.textTheme.bodySmall,
                      ),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                  onSelected: (value) {
                    setState(() {
                      if (_sortBy == value) {
                        _sortAscending = !_sortAscending;
                      } else {
                        _sortBy = value;
                        _sortAscending = false;
                      }
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'score', child: Text(l10n.score)),
                    PopupMenuItem(value: 'win_rate', child: Text(l10n.winRate)),
                    PopupMenuItem(value: 'total_pnl', child: Text(l10n.totalPnl)),
                    PopupMenuItem(value: 'sharpe_ratio', child: Text(l10n.sharpeRatio)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text(l10n.rank)),
                  DataColumn(label: Text(l10n.parameters)),
                  DataColumn(label: Text(l10n.score)),
                  DataColumn(label: Text(l10n.winRate)),
                  DataColumn(label: Text(l10n.totalPnl)),
                  DataColumn(label: Text(l10n.sharpeRatio)),
                  DataColumn(label: Text(l10n.maxDrawdown)),
                ],
                rows: results.take(20).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final result = entry.value;

                  return DataRow(
                    cells: [
                      DataCell(Text('#${index + 1}')),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            result.getFormattedParameters(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(result.score.toStringAsFixed(4))),
                      DataCell(Text('${result.winRate.toStringAsFixed(1)}%')),
                      DataCell(
                        Text(
                          '\$${result.totalPnl.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: result.totalPnl >= 0
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                      DataCell(Text(result.sharpeRatio.toStringAsFixed(2))),
                      DataCell(Text('\$${result.maxDrawdown.toStringAsFixed(2)}')),
                    ],
                  );
                }).toList(),
              ),
            ),
            if (results.length > 20) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n.showing} 20 ${l10n.ofLabel} ${results.length} ${l10n.results}',
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

  List<ParameterSet> _getSortedResults(List<ParameterSet> results) {
    final sorted = List<ParameterSet>.from(results);

    sorted.sort((a, b) {
      double aValue, bValue;

      switch (_sortBy) {
        case 'win_rate':
          aValue = a.winRate;
          bValue = b.winRate;
          break;
        case 'total_pnl':
          aValue = a.totalPnl;
          bValue = b.totalPnl;
          break;
        case 'sharpe_ratio':
          aValue = a.sharpeRatio;
          bValue = b.sharpeRatio;
          break;
        default: // score
          aValue = a.score;
          bValue = b.score;
      }

      return _sortAscending
          ? aValue.compareTo(bValue)
          : bValue.compareTo(aValue);
    });

    return sorted;
  }

  Future<void> _applyParameters(L10n l10n, OptimizationResult result) async {
    if (result.bestParameters == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.applyParameters),
          content: Text(l10n.applyParametersConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.apply),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final service = ref.read(optimizationServiceProvider);
      await service.applyParameters(
        result.config.strategyName,
        result.bestParameters!.parameters,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.parametersAppliedSuccessfully),
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

  Future<void> _cancelOptimization(L10n l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.cancelOptimization),
          content: Text(l10n.cancelOptimizationConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.no),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
              ),
              child: Text(l10n.yes),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final service = ref.read(optimizationServiceProvider);
      await service.cancelOptimization(widget.optimizationId);

      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.optimizationCancelledSuccessfully),
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
}
