import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mcp_backtest_models.dart';

/// Widget for displaying a list of backtest trades
class TradeListWidget extends StatelessWidget {
  final List<BacktestTrade> trades;
  final bool showSymbol;
  final VoidCallback? onTradeSelected;

  const TradeListWidget({
    super.key,
    required this.trades,
    this.showSymbol = true,
    this.onTradeSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (trades.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No trades to display',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: trades.length,
      itemBuilder: (context, index) {
        final trade = trades[index];
        return _buildTradeCard(context, trade, index + 1);
      },
    );
  }

  Widget _buildTradeCard(
      BuildContext context, BacktestTrade trade, int tradeNumber) {
    final isProfit = trade.isProfitable;
    final profitColor = isProfit ? Colors.green : Colors.red;
    final dateFormat = DateFormat('MMM dd, HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTradeSelected,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: profitColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: profitColor),
                        ),
                        child: Center(
                          child: Text(
                            tradeNumber.toString(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: profitColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showSymbol)
                            Text(
                              trade.symbol,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          Text(
                            trade.side.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: trade.side.toLowerCase() == 'buy'
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isProfit ? '+' : ''}${trade.pnlPercent.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: profitColor,
                        ),
                      ),
                      Text(
                        '\$${trade.pnl.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: profitColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Trade details
              Row(
                children: [
                  Expanded(
                    child: _buildTradeDetail(
                      'Entry',
                      '\$${trade.entryPrice.toStringAsFixed(4)}',
                      dateFormat.format(trade.entryTime),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTradeDetail(
                      'Exit',
                      '\$${trade.exitPrice.toStringAsFixed(4)}',
                      trade.exitTime != null
                          ? dateFormat.format(trade.exitTime!)
                          : 'Open',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTradeDetail(
                      'Size',
                      trade.size.toStringAsFixed(4),
                      _getTradeDuration(trade),
                    ),
                  ),
                ],
              ),

              // Progress bar for P&L visualization
              const SizedBox(height: 8),
              _buildPnLProgressBar(trade),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTradeDetail(String label, String value, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPnLProgressBar(BacktestTrade trade) {
    final isProfit = trade.isProfitable;
    final profitColor = isProfit ? Colors.green : Colors.red;
    final percentage = (trade.pnlPercent.abs() / 10)
        .clamp(0.0, 1.0); // Normalize to 0-1 for 10% max

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'P&L Impact',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${trade.pnlPercent.abs().toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 10,
                color: profitColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(profitColor),
          minHeight: 4,
        ),
      ],
    );
  }

  String _getTradeDuration(BacktestTrade trade) {
    if (trade.exitTime == null) return 'Open';

    final duration = trade.exitTime!.difference(trade.entryTime);

    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}
