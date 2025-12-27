import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';
import '../models/futures_position.dart';
import '../providers/futures_provider.dart';

/// Futures Positions Screen
///
/// Displays futures positions with enhanced information:
/// - Mark price and liquidation price
/// - Total PnL (realized + unrealized)
/// - Liquidation warnings
/// - Bulk actions (Close All, Close Losing, Close Profitable)
class FuturesPositionsScreen extends ConsumerStatefulWidget {
  const FuturesPositionsScreen({super.key});

  @override
  ConsumerState<FuturesPositionsScreen> createState() =>
      _FuturesPositionsScreenState();
}

class _FuturesPositionsScreenState
    extends ConsumerState<FuturesPositionsScreen> {
  final String _selectedExchange = 'kucoin';

  Future<void> _onRefresh() async {
    await ref
        .read(futuresPositionsProvider(exchange: _selectedExchange).notifier)
        .refresh();
  }

  Future<void> _closePosition(String symbol) async {
    HapticFeedback.heavyImpact();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Position'),
        content: Text('Are you sure you want to close $symbol?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.lossRed,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref
          .read(futuresPositionsProvider(exchange: _selectedExchange).notifier)
          .closePosition(symbol);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Position $symbol closed successfully'),
            backgroundColor: AppTheme.profitGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.lossRed,
          ),
        );
      }
    }
  }

  Future<void> _closeAllPositions() async {
    HapticFeedback.heavyImpact();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close All Positions'),
        content: const Text(
          'Are you sure you want to close ALL open positions? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.lossRed,
            ),
            child: const Text('Close All'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final results = await ref
          .read(futuresPositionsProvider(exchange: _selectedExchange).notifier)
          .closeAll();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Closed ${results.length} positions'),
            backgroundColor: AppTheme.profitGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.lossRed,
          ),
        );
      }
    }
  }

  Future<void> _closeLosingPositions() async {
    HapticFeedback.mediumImpact();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Losing Positions'),
        content: const Text(
          'Close all positions with negative P&L?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.lossRed,
            ),
            child: const Text('Close Losing'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final results = await ref
          .read(futuresPositionsProvider(exchange: _selectedExchange).notifier)
          .closeLosingPositions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Closed ${results.length} losing positions'),
            backgroundColor: AppTheme.profitGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.lossRed,
          ),
        );
      }
    }
  }

  Future<void> _closeProfitablePositions() async {
    HapticFeedback.mediumImpact();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Profitable Positions'),
        content: const Text(
          'Close all positions with positive P&L?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.profitGreen,
            ),
            child: const Text('Close Profitable'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final results = await ref
          .read(futuresPositionsProvider(exchange: _selectedExchange).notifier)
          .closeProfitablePositions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Closed ${results.length} profitable positions'),
            backgroundColor: AppTheme.profitGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.lossRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final positionsAsync =
        ref.watch(futuresPositionsProvider(exchange: _selectedExchange));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Futures Positions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: positionsAsync.when(
        data: (response) {
          if (response.isEmpty) {
            return _buildEmptyState(theme);
          }

          final positions = response.positions;
          final losingCount = positions.where((p) => p.isLoss).length;
          final profitableCount = positions.where((p) => p.isProfit).length;

          return Column(
            children: [
              // Summary Card
              _buildSummaryCard(theme, response, losingCount, profitableCount),

              // Positions List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: positions.length,
                    itemBuilder: (context, index) {
                      return _buildPositionCard(
                        theme,
                        positions[index],
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading positions...',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'If this takes too long, check backend connection',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        error: (e, _) => _buildErrorState(theme, e),
      ),
      bottomNavigationBar: positionsAsync.maybeWhen(
        data: (response) =>
            response.hasPositions ? _buildActionButtons(theme, response) : null,
        orElse: () => null,
      ),
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    FuturesPositionsResponse response,
    int losingCount,
    int profitableCount,
  ) {
    final totalPnlColor = response.totalUnrealizedPnl >= 0
        ? AppTheme.profitGreen
        : AppTheme.lossRed;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Positions',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  '${response.count}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Unrealized P&L',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  '\$${response.totalUnrealizedPnl.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: totalPnlColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  theme,
                  'Profitable',
                  profitableCount.toString(),
                  AppTheme.profitGreen,
                ),
                _buildSummaryItem(
                  theme,
                  'Losing',
                  losingCount.toString(),
                  AppTheme.lossRed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    ThemeData theme,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPositionCard(ThemeData theme, FuturesPosition position) {
    final pnlColor =
        position.isProfit ? AppTheme.profitGreen : AppTheme.lossRed;
    final sideColor = position.isLong ? AppTheme.profitGreen : AppTheme.lossRed;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Header with symbol and side
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: sideColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  position.isLong ? Icons.arrow_upward : Icons.arrow_downward,
                  color: sideColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        position.symbol,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${position.side.toUpperCase()} ${position.leverage}x ${position.marginMode}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: sideColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Liquidation Warning
                if (position.isNearLiquidation)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.lossRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'NEAR LIQ',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Position Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // P&L Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total P&L',
                      style: theme.textTheme.titleMedium,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${position.totalPnl.toStringAsFixed(2)}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: pnlColor,
                          ),
                        ),
                        Text(
                          '${position.pnlPercent >= 0 ? '+' : ''}${position.pnlPercent.toStringAsFixed(2)}%',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: pnlColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // Price Information
                _buildInfoRow(theme, 'Entry Price',
                    '\$${position.entryPrice.toStringAsFixed(4)}'),
                const SizedBox(height: 8),
                _buildInfoRow(theme, 'Mark Price',
                    '\$${(position.markPrice ?? position.currentPrice).toStringAsFixed(4)}'),
                const SizedBox(height: 8),
                _buildInfoRow(
                  theme,
                  'Liquidation Price',
                  '\$${position.liquidationPrice.toStringAsFixed(4)}',
                  valueColor:
                      position.isNearLiquidation ? AppTheme.lossRed : null,
                  trailing: position.isNearLiquidation
                      ? Text(
                          '${position.distanceToLiquidationPercent.toStringAsFixed(1)}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lossRed,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),

                // Position Details
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        theme,
                        'Size',
                        position.size.toStringAsFixed(0),
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        theme,
                        'Margin',
                        '\$${position.margin.toStringAsFixed(2)}',
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        theme,
                        'Unrealized',
                        '\$${position.unrealizedPnl.toStringAsFixed(2)}',
                        valueColor: position.isProfit
                            ? AppTheme.profitGreen
                            : AppTheme.lossRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Close Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _closePosition(position.symbol),
                icon: const Icon(Icons.close),
                label: const Text('Close Position'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.lossRed,
                  side: const BorderSide(color: AppTheme.lossRed),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    String label,
    String value, {
    Color? valueColor,
    Widget? trailing,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing,
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    ThemeData theme,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Column(
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
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    ThemeData theme,
    FuturesPositionsResponse response,
  ) {
    final hasLosingPositions = response.positions.any((p) => p.isLoss);
    final hasProfitablePositions = response.positions.any((p) => p.isProfit);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (hasLosingPositions)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _closeLosingPositions,
                      icon: const Icon(Icons.trending_down),
                      label: const Text('Close Losing'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.lossRed,
                        side: const BorderSide(color: AppTheme.lossRed),
                      ),
                    ),
                  ),
                if (hasLosingPositions && hasProfitablePositions)
                  const SizedBox(width: 8),
                if (hasProfitablePositions)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _closeProfitablePositions,
                      icon: const Icon(Icons.trending_up),
                      label: const Text('Close Profitable'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.profitGreen,
                        side: const BorderSide(color: AppTheme.profitGreen),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _closeAllPositions,
                icon: const Icon(Icons.close_fullscreen),
                label: const Text('Close All Positions'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.lossRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Open Positions',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your futures positions will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, Object error) {
    final errorMessage = error.toString();
    final isTimeout = errorMessage.contains('timeout') ||
        errorMessage.contains('SocketException');
    final isConnection = errorMessage.contains('Connection') ||
        errorMessage.contains('Failed host lookup');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: AppTheme.lossRed, size: 64),
            const SizedBox(height: 16),
            Text(
              isTimeout
                  ? 'Backend Timeout'
                  : isConnection
                      ? 'Connection Error'
                      : 'Error Loading Positions',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lossRed,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lossRed,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (isTimeout || isConnection) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(height: 8),
                    Text(
                      'Backend MCP Server not responding',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Check:\n• MCP Server is running (port 9090)\n• Network connection\n• Server logs',
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
