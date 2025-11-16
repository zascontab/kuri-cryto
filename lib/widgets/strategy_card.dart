import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Card widget for displaying strategy information
class StrategyCard extends StatelessWidget {
  final String name;
  final bool isActive;
  final double weight;
  final int totalTrades;
  final double winRate;
  final double totalPnl;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onConfigure;

  const StrategyCard({
    super.key,
    required this.name,
    required this.isActive,
    required this.weight,
    required this.totalTrades,
    required this.winRate,
    required this.totalPnl,
    this.onToggle,
    this.onTap,
    this.onConfigure,
  });

  Color _getPnLColor() {
    if (totalPnl > 0) return const Color(0xFF4CAF50); // Green
    if (totalPnl < 0) return const Color(0xFFF44336); // Red
    return Colors.grey;
  }

  IconData _getStrategyIcon() {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('rsi')) return Icons.show_chart;
    if (nameLower.contains('macd')) return Icons.trending_up;
    if (nameLower.contains('bollinger')) return Icons.waves;
    if (nameLower.contains('volume')) return Icons.bar_chart;
    if (nameLower.contains('ai')) return Icons.psychology;
    return Icons.analytics;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pnlColor = _getPnLColor();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Strategy name and toggle
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStrategyIcon(),
                      color: isActive
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isActive ? 'Active' : 'Inactive',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isActive,
                    onChanged: (value) {
                      HapticFeedback.mediumImpact();
                      onToggle?.call(value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Weight indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Weight',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${(weight * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: weight,
                      minHeight: 6,
                      backgroundColor: colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isActive ? colorScheme.primary : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Performance metrics
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetric(
                    'Trades',
                    totalTrades.toString(),
                    theme,
                  ),
                  _buildMetric(
                    'Win Rate',
                    '${winRate.toStringAsFixed(1)}%',
                    theme,
                    color: winRate >= 50
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFF44336),
                  ),
                  _buildMetric(
                    'P&L',
                    '${totalPnl >= 0 ? '+' : ''}\$${totalPnl.toStringAsFixed(2)}',
                    theme,
                    color: pnlColor,
                  ),
                ],
              ),
              if (onConfigure != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onConfigure?.call();
                    },
                    icon: const Icon(Icons.settings, size: 18),
                    label: const Text('Configure'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(
    String label,
    String value,
    ThemeData theme, {
    Color? color,
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
            color: color ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
