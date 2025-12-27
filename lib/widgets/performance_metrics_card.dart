import 'package:flutter/material.dart';
import '../models/mcp_backtest_models.dart';

/// Widget for displaying comprehensive performance metrics
class PerformanceMetricsCard extends StatelessWidget {
  final BacktestResult result;

  const PerformanceMetricsCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Primary metrics
            _buildMetricRow(
              'Total Return (ROI)',
              '${result.roi.toStringAsFixed(2)}%',
              result.roi > 0 ? Colors.green : Colors.red,
            ),
            _buildMetricRow(
              'Sharpe Ratio',
              result.sharpeRatio.toStringAsFixed(2),
              _getSharpeColor(result.sharpeRatio),
            ),
            _buildMetricRow(
              'Maximum Drawdown',
              '${result.maxDrawdown.toStringAsFixed(2)}%',
              result.maxDrawdown < 20 ? Colors.green : Colors.red,
            ),

            const Divider(height: 24),

            // Trading metrics
            _buildMetricRow(
              'Total Trades',
              result.totalTrades.toString(),
              Colors.blue,
            ),
            _buildMetricRow(
              'Win Rate',
              '${result.winRate.toStringAsFixed(1)}%',
              result.winRate > 50 ? Colors.green : Colors.orange,
            ),
            _buildMetricRow(
              'Profit Factor',
              result.profitFactor.toStringAsFixed(2),
              result.profitFactor > 1.5 ? Colors.green : Colors.orange,
            ),

            const Divider(height: 24),

            // Additional insights
            _buildInsightRow(
              'Strategy Viability',
              result.isViableStrategy ? 'Viable' : 'Needs Improvement',
              result.isViableStrategy ? Colors.green : Colors.orange,
              result.isViableStrategy ? Icons.check_circle : Icons.warning,
            ),
            _buildInsightRow(
              'Statistical Significance',
              result.hasSufficientTrades ? 'Sufficient' : 'Insufficient',
              result.hasSufficientTrades ? Colors.green : Colors.orange,
              result.hasSufficientTrades ? Icons.check_circle : Icons.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(
      String label, String value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getSharpeColor(double sharpe) {
    if (sharpe >= 2.0) return Colors.green;
    if (sharpe >= 1.0) return Colors.lightGreen;
    if (sharpe >= 0.5) return Colors.orange;
    return Colors.red;
  }
}
