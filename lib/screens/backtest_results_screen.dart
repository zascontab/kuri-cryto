import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mcp_backtest_models.dart';
import '../widgets/performance_metrics_card.dart';
import '../widgets/trade_list_widget.dart';
import '../widgets/equity_curve_chart.dart';

/// Screen for displaying comprehensive backtest results
///
/// Features:
/// - Performance metrics overview
/// - Equity curve visualization
/// - Trade-by-trade analysis
/// - Risk metrics and statistics
/// - Export and sharing capabilities
class BacktestResultsScreen extends ConsumerStatefulWidget {
  final String backtestId;
  final BacktestResult? initialResult;

  const BacktestResultsScreen({
    super.key,
    required this.backtestId,
    this.initialResult,
  });

  @override
  ConsumerState<BacktestResultsScreen> createState() =>
      _BacktestResultsScreenState();
}

class _BacktestResultsScreenState extends ConsumerState<BacktestResultsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showOnlyProfitableTrades = false;

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

  @override
  Widget build(BuildContext context) {
    // Use initial result if provided, otherwise show loading
    final result = widget.initialResult;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Backtest Results'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Backtest Results - ${widget.backtestId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareResults(result),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportResults(result),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Overview'),
            Tab(icon: Icon(Icons.show_chart), text: 'Equity Curve'),
            Tab(icon: Icon(Icons.list), text: 'Trades'),
            Tab(icon: Icon(Icons.assessment), text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(result),
          _buildEquityCurveTab(result),
          _buildTradesTab(result),
          _buildAnalyticsTab(result),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BacktestResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Grade Card
          _buildPerformanceGradeCard(result),
          const SizedBox(height: 16),

          // Key Metrics Grid
          _buildKeyMetricsGrid(result),
          const SizedBox(height: 16),

          // Performance Summary
          PerformanceMetricsCard(result: result),
          const SizedBox(height: 16),

          // Quick Stats
          _buildQuickStatsCard(result),
        ],
      ),
    );
  }

  Widget _buildPerformanceGradeCard(BacktestResult result) {
    final grade = result.performanceGrade;
    final gradeColor = _getGradeColor(grade);

    return Card(
      color: gradeColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: gradeColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  grade,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Grade',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getGradeDescription(grade),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        result.isViableStrategy
                            ? Icons.check_circle
                            : Icons.warning,
                        color: result.isViableStrategy
                            ? Colors.green
                            : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        result.isViableStrategy
                            ? 'Viable Strategy'
                            : 'Needs Improvement',
                        style: TextStyle(
                          color: result.isViableStrategy
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetricsGrid(BacktestResult result) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildMetricCard(
          'Total Return',
          '${result.roi.toStringAsFixed(2)}%',
          Icons.trending_up,
          result.roi > 0 ? Colors.green : Colors.red,
        ),
        _buildMetricCard(
          'Sharpe Ratio',
          result.sharpeRatio.toStringAsFixed(2),
          Icons.analytics,
          result.sharpeRatio > 1 ? Colors.green : Colors.orange,
        ),
        _buildMetricCard(
          'Max Drawdown',
          '${result.maxDrawdown.toStringAsFixed(2)}%',
          Icons.trending_down,
          result.maxDrawdown < 20 ? Colors.green : Colors.red,
        ),
        _buildMetricCard(
          'Win Rate',
          '${result.winRate.toStringAsFixed(1)}%',
          Icons.percent,
          result.winRate > 50 ? Colors.green : Colors.orange,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard(BacktestResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Statistics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Trades',
                    result.totalTrades.toString(),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Winning Trades',
                    result.winningTrades.toString(),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Losing Trades',
                    result.losingTrades.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Profit Factor',
                    result.profitFactor.toStringAsFixed(2),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Avg Duration',
                    '${result.averageTradeDurationHours.toStringAsFixed(1)}h',
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Best Trade',
                    result.largestWin != null
                        ? '${result.largestWin!.pnlPercent.toStringAsFixed(1)}%'
                        : 'N/A',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEquityCurveTab(BacktestResult result) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Equity Curve',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: EquityCurveChart(trades: result.trades),
          ),
        ],
      ),
    );
  }

  Widget _buildTradesTab(BacktestResult result) {
    return Column(
      children: [
        // Filter controls
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Trades (${result.trades.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FilterChip(
                label: const Text('Profitable Only'),
                selected: _showOnlyProfitableTrades,
                onSelected: (selected) {
                  setState(() {
                    _showOnlyProfitableTrades = selected;
                  });
                },
              ),
            ],
          ),
        ),
        // Trades list
        Expanded(
          child: TradeListWidget(
            trades: _showOnlyProfitableTrades
                ? result.trades.where((trade) => trade.isProfitable).toList()
                : result.trades,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab(BacktestResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Analytics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Risk Analysis
          _buildRiskAnalysisCard(result),
          const SizedBox(height: 16),

          // Trade Distribution
          _buildTradeDistributionCard(result),
          const SizedBox(height: 16),

          // Performance Breakdown
          _buildPerformanceBreakdownCard(result),
        ],
      ),
    );
  }

  Widget _buildRiskAnalysisCard(BacktestResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Risk Analysis',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildRiskMetric(
              'Maximum Drawdown',
              '${result.maxDrawdown.toStringAsFixed(2)}%',
              result.hasAcceptableRisk,
            ),
            _buildRiskMetric(
              'Sharpe Ratio',
              result.sharpeRatio.toStringAsFixed(2),
              result.sharpeRatio > 1.0,
            ),
            _buildRiskMetric(
              'Profit Factor',
              result.profitFactor.toStringAsFixed(2),
              result.profitFactor > 1.5,
            ),
            _buildRiskMetric(
              'Statistical Significance',
              '${result.totalTrades} trades',
              result.hasSufficientTrades,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskMetric(String label, String value, bool isGood) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Icon(
                isGood ? Icons.check_circle : Icons.warning,
                color: isGood ? Colors.green : Colors.orange,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTradeDistributionCard(BacktestResult result) {
    final profitableTrades = result.trades.where((t) => t.isProfitable).length;
    final losingTrades = result.trades.length - profitableTrades;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trade Distribution',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: profitableTrades.toDouble(),
                      title: 'Wins\n$profitableTrades',
                      color: Colors.green,
                      radius: 80,
                    ),
                    PieChartSectionData(
                      value: losingTrades.toDouble(),
                      title: 'Losses\n$losingTrades',
                      color: Colors.red,
                      radius: 80,
                    ),
                  ],
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceBreakdownCard(BacktestResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Breakdown',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (result.largestWin != null)
              _buildPerformanceItem(
                'Largest Win',
                '${result.largestWin!.pnlPercent.toStringAsFixed(2)}%',
                '${result.largestWin!.symbol} - ${result.largestWin!.side.toUpperCase()}',
                Colors.green,
              ),
            if (result.largestLoss != null)
              _buildPerformanceItem(
                'Largest Loss',
                '${result.largestLoss!.pnlPercent.toStringAsFixed(2)}%',
                '${result.largestLoss!.symbol} - ${result.largestLoss!.side.toUpperCase()}',
                Colors.red,
              ),
            _buildPerformanceItem(
              'Average Trade Duration',
              '${result.averageTradeDurationHours.toStringAsFixed(1)} hours',
              'Based on ${result.trades.length} trades',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceItem(
      String title, String value, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.lightGreen;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      default:
        return Colors.red;
    }
  }

  String _getGradeDescription(String grade) {
    switch (grade) {
      case 'A':
        return 'Excellent performance with strong risk-adjusted returns';
      case 'B':
        return 'Good performance with acceptable risk levels';
      case 'C':
        return 'Average performance, room for improvement';
      case 'D':
        return 'Below average performance, needs optimization';
      default:
        return 'Poor performance, significant improvements needed';
    }
  }

  void _shareResults(BacktestResult result) {
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  void _exportResults(BacktestResult result) {
    // Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon')),
    );
  }
}
