import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mcp_backtest_models.dart';

/// Widget for displaying equity curve chart from backtest trades
class EquityCurveChart extends StatelessWidget {
  final List<BacktestTrade> trades;
  final double initialBalance;

  const EquityCurveChart({
    super.key,
    required this.trades,
    this.initialBalance = 10000.0,
  });

  @override
  Widget build(BuildContext context) {
    if (trades.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No trade data available for equity curve',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final equityPoints = _calculateEquityPoints();
    final spots = _createSpots(equityPoints);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart header with stats
            _buildChartHeader(equityPoints),
            const SizedBox(height: 16),

            // Chart
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: _getHorizontalInterval(equityPoints),
                    verticalInterval: _getVerticalInterval(equityPoints),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: _getBottomInterval(equityPoints),
                        getTitlesWidget: (value, meta) {
                          return _buildBottomTitle(value, equityPoints);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _getHorizontalInterval(equityPoints),
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return _buildLeftTitle(value);
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  minX: 0,
                  maxX: equityPoints.length.toDouble() - 1,
                  minY: _getMinY(equityPoints),
                  maxY: _getMaxY(equityPoints),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      color: _getEquityColor(equityPoints),
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _getEquityColor(equityPoints)
                            .withValues(alpha: 0.1),
                      ),
                    ),
                    // Add drawdown area
                    if (_hasDrawdown(equityPoints))
                      LineChartBarData(
                        spots: _createDrawdownSpots(equityPoints),
                        isCurved: false,
                        color: Colors.red.withValues(alpha: 0.3),
                        barWidth: 1,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.red.withValues(alpha: 0.1),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Legend
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildChartHeader(List<EquityPoint> equityPoints) {
    final finalBalance =
        equityPoints.isNotEmpty ? equityPoints.last.balance : initialBalance;
    final totalReturn =
        ((finalBalance - initialBalance) / initialBalance * 100);
    final maxDrawdown = _calculateMaxDrawdown(equityPoints);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatColumn(
          'Final Balance',
          '\$${finalBalance.toStringAsFixed(2)}',
          Colors.blue,
        ),
        _buildStatColumn(
          'Total Return',
          '${totalReturn >= 0 ? '+' : ''}${totalReturn.toStringAsFixed(2)}%',
          totalReturn >= 0 ? Colors.green : Colors.red,
        ),
        _buildStatColumn(
          'Max Drawdown',
          '${maxDrawdown.toStringAsFixed(2)}%',
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Equity Curve', _getEquityColor([])),
        const SizedBox(width: 20),
        _buildLegendItem('Drawdown', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 2,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBottomTitle(double value, List<EquityPoint> equityPoints) {
    final index = value.toInt();
    if (index < 0 || index >= equityPoints.length) {
      return const SizedBox.shrink();
    }

    // Show every nth trade based on total trades
    final interval = (equityPoints.length / 5).ceil();
    if (index % interval != 0 && index != equityPoints.length - 1) {
      return const SizedBox.shrink();
    }

    return Text(
      'T${index + 1}',
      style: const TextStyle(
        fontSize: 10,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildLeftTitle(double value) {
    return Text(
      '\$${(value / 1000).toStringAsFixed(0)}K',
      style: const TextStyle(
        fontSize: 10,
        color: Colors.grey,
      ),
    );
  }

  List<EquityPoint> _calculateEquityPoints() {
    final points = <EquityPoint>[];
    double currentBalance = initialBalance;
    double peakBalance = initialBalance;

    // Add initial point
    points.add(EquityPoint(
      tradeNumber: 0,
      balance: currentBalance,
      drawdown: 0,
      timestamp: trades.isNotEmpty ? trades.first.entryTime : DateTime.now(),
    ));

    // Calculate equity after each trade
    for (int i = 0; i < trades.length; i++) {
      final trade = trades[i];
      currentBalance += trade.pnl;

      // Update peak balance
      if (currentBalance > peakBalance) {
        peakBalance = currentBalance;
      }

      // Calculate drawdown
      final drawdown = peakBalance > 0
          ? ((peakBalance - currentBalance) / peakBalance * 100)
          : 0.0;

      points.add(EquityPoint(
        tradeNumber: i + 1,
        balance: currentBalance,
        drawdown: drawdown,
        timestamp: trade.exitTime ?? trade.entryTime,
      ));
    }

    return points;
  }

  List<FlSpot> _createSpots(List<EquityPoint> equityPoints) {
    return equityPoints
        .asMap()
        .entries
        .map((entry) => FlSpot(
              entry.key.toDouble(),
              entry.value.balance,
            ))
        .toList();
  }

  List<FlSpot> _createDrawdownSpots(List<EquityPoint> equityPoints) {
    return equityPoints.asMap().entries.map((entry) {
      final point = entry.value;
      final peakBalance =
          point.balance + (point.balance * point.drawdown / 100);
      return FlSpot(
        entry.key.toDouble(),
        peakBalance,
      );
    }).toList();
  }

  Color _getEquityColor(List<EquityPoint> equityPoints) {
    if (equityPoints.isEmpty) return Colors.blue;

    final finalBalance = equityPoints.last.balance;
    return finalBalance >= initialBalance ? Colors.green : Colors.red;
  }

  double _getMinY(List<EquityPoint> equityPoints) {
    if (equityPoints.isEmpty) return 0;

    final minBalance =
        equityPoints.map((p) => p.balance).reduce((a, b) => a < b ? a : b);

    return (minBalance * 0.95); // Add 5% padding
  }

  double _getMaxY(List<EquityPoint> equityPoints) {
    if (equityPoints.isEmpty) return initialBalance;

    final maxBalance =
        equityPoints.map((p) => p.balance).reduce((a, b) => a > b ? a : b);

    return (maxBalance * 1.05); // Add 5% padding
  }

  double _getHorizontalInterval(List<EquityPoint> equityPoints) {
    if (equityPoints.isEmpty) return 1000;

    final range = _getMaxY(equityPoints) - _getMinY(equityPoints);
    return range / 5; // 5 horizontal lines
  }

  double _getVerticalInterval(List<EquityPoint> equityPoints) {
    return equityPoints.length / 5; // 5 vertical lines
  }

  double _getBottomInterval(List<EquityPoint> equityPoints) {
    return (equityPoints.length / 5).ceilToDouble();
  }

  bool _hasDrawdown(List<EquityPoint> equityPoints) {
    return equityPoints.any((point) => point.drawdown > 0);
  }

  double _calculateMaxDrawdown(List<EquityPoint> equityPoints) {
    if (equityPoints.isEmpty) return 0;

    return equityPoints.map((p) => p.drawdown).reduce((a, b) => a > b ? a : b);
  }
}

/// Data point for equity curve
class EquityPoint {
  final int tradeNumber;
  final double balance;
  final double drawdown;
  final DateTime timestamp;

  const EquityPoint({
    required this.tradeNumber,
    required this.balance,
    required this.drawdown,
    required this.timestamp,
  });
}
