import 'package:flutter/material.dart';
import '../models/ai_bot_status.dart';

/// Widget that displays AI bot status in a card format
///
/// Shows:
/// - Bot status indicator (running/paused/stopped/emergency)
/// - Metrics grid (analysis count, trades, errors, positions)
/// - Daily limits progress bars (loss and trades)
/// - Quick action button based on current state
///
/// Color-coded status indicators and progress bars
class BotStatusCardWidget extends StatelessWidget {
  /// AI bot status data
  final AiBotStatus status;

  /// Callback when action button is pressed
  final VoidCallback? onActionPressed;

  const BotStatusCardWidget({
    super.key,
    required this.status,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _getStatusColor();
    final statusText = _getStatusText();
    final statusIcon = _getStatusIcon();

    return Card(
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              statusColor.withOpacity(0.08),
              statusColor.withOpacity(0.02),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Status Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.smart_toy,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI Trading Bot',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  _StatusBadge(
                    text: statusText,
                    color: statusColor,
                    icon: statusIcon,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Metrics Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: [
                  _MetricItem(
                    icon: Icons.analytics,
                    label: 'Analysis',
                    value: status.analysisCount.toString(),
                    color: const Color(0xFF3B82F6), // Blue
                  ),
                  _MetricItem(
                    icon: Icons.swap_horiz,
                    label: 'Trades',
                    value: status.executionCount.toString(),
                    color: const Color(0xFF10B981), // Green
                  ),
                  _MetricItem(
                    icon: Icons.error_outline,
                    label: 'Errors',
                    value: status.errorCount.toString(),
                    color: status.hasIssues
                        ? const Color(0xFFEF4444) // Red
                        : const Color(0xFF6B7280), // Gray
                  ),
                  _MetricItem(
                    icon: Icons.account_balance_wallet,
                    label: 'Positions',
                    value: status.openPositions.toString(),
                    color: const Color(0xFFF59E0B), // Orange
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Daily Loss Limit
              _LimitProgressBar(
                label: 'Daily Loss',
                current: status.dailyLoss.abs(),
                max: status.config.maxDailyLossUsd,
                percentage: status.dailyLossPercent,
                icon: Icons.trending_down,
                color: const Color(0xFFEF4444), // Red
              ),
              const SizedBox(height: 16),

              // Daily Trades Limit
              _LimitProgressBar(
                label: 'Daily Trades',
                current: status.dailyTrades.toDouble(),
                max: status.config.maxDailyTrades.toDouble(),
                percentage: status.dailyTradesPercent,
                icon: Icons.bar_chart,
                color: const Color(0xFF3B82F6), // Blue
              ),
              const SizedBox(height: 20),

              // Action Button
              if (onActionPressed != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onActionPressed,
                    icon: Icon(_getActionIcon()),
                    label: Text(
                      _getActionText(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getActionColor(),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (status.emergencyStop) {
      return const Color(0xFFEF4444); // Red
    } else if (status.paused) {
      return const Color(0xFFF59E0B); // Orange
    } else if (status.running) {
      return const Color(0xFF10B981); // Green
    } else {
      return const Color(0xFF6B7280); // Gray
    }
  }

  String _getStatusText() {
    if (status.emergencyStop) {
      return 'EMERGENCY STOP';
    } else if (status.paused) {
      return 'PAUSED';
    } else if (status.running) {
      return 'RUNNING';
    } else {
      return 'STOPPED';
    }
  }

  IconData _getStatusIcon() {
    if (status.emergencyStop) {
      return Icons.warning;
    } else if (status.paused) {
      return Icons.pause_circle;
    } else if (status.running) {
      return Icons.play_circle;
    } else {
      return Icons.stop_circle;
    }
  }

  String _getActionText() {
    if (status.emergencyStop) {
      return 'Reset Emergency Stop';
    } else if (status.paused) {
      return 'Resume Trading';
    } else if (status.running) {
      return 'Pause Trading';
    } else {
      return 'Start Trading';
    }
  }

  IconData _getActionIcon() {
    if (status.emergencyStop) {
      return Icons.restart_alt;
    } else if (status.paused) {
      return Icons.play_arrow;
    } else if (status.running) {
      return Icons.pause;
    } else {
      return Icons.play_arrow;
    }
  }

  Color _getActionColor() {
    if (status.emergencyStop) {
      return const Color(0xFFEF4444); // Red
    } else if (status.paused) {
      return const Color(0xFF10B981); // Green
    } else if (status.running) {
      return const Color(0xFFF59E0B); // Orange
    } else {
      return const Color(0xFF10B981); // Green
    }
  }
}

/// Badge for displaying bot status
class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;

  const _StatusBadge({
    required this.text,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.7 + (0.3 * animValue),
          child: Opacity(
            opacity: animValue,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying a metric item in the grid
class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying a limit progress bar
class _LimitProgressBar extends StatelessWidget {
  final String label;
  final double current;
  final double max;
  final double percentage;
  final IconData icon;
  final Color color;

  const _LimitProgressBar({
    required this.label,
    required this.current,
    required this.max,
    required this.percentage,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    final progressColor = progress > 0.8 ? color : color.withOpacity(0.7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              '${current.toStringAsFixed(0)} / ${max.toStringAsFixed(0)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: progress),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOut,
                builder: (context, animValue, child) {
                  return LinearProgressIndicator(
                    value: animValue,
                    minHeight: 10,
                    backgroundColor: colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: progress > 0.5
                        ? Colors.white
                        : colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
