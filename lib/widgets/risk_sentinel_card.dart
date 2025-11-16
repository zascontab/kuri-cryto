import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Card widget for displaying Risk Sentinel state
class RiskSentinelCard extends StatelessWidget {
  final double dailyDrawdown;
  final double weeklyDrawdown;
  final double monthlyDrawdown;
  final double maxDailyDrawdown;
  final double maxWeeklyDrawdown;
  final double maxMonthlyDrawdown;
  final double totalExposure;
  final double maxExposure;
  final int consecutiveLosses;
  final int maxConsecutiveLosses;
  final String riskMode; // 'Conservative', 'Normal', 'Aggressive'
  final bool killSwitchActive;
  final bool isProcessing;
  final VoidCallback? onKillSwitch;

  const RiskSentinelCard({
    super.key,
    required this.dailyDrawdown,
    required this.weeklyDrawdown,
    required this.monthlyDrawdown,
    required this.maxDailyDrawdown,
    required this.maxWeeklyDrawdown,
    required this.maxMonthlyDrawdown,
    required this.totalExposure,
    required this.maxExposure,
    required this.consecutiveLosses,
    required this.maxConsecutiveLosses,
    required this.riskMode,
    required this.killSwitchActive,
    this.isProcessing = false,
    this.onKillSwitch,
  });

  Color _getDrawdownColor(double current, double max) {
    final percentage = (current / max) * 100;
    if (percentage < 50) return const Color(0xFF4CAF50); // Green
    if (percentage < 80) return Colors.orange; // Warning
    return const Color(0xFFF44336); // Red - Danger
  }

  Color _getRiskModeColor() {
    switch (riskMode) {
      case 'Conservative':
        return const Color(0xFF4CAF50);
      case 'Aggressive':
        return const Color(0xFFF44336);
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: killSwitchActive
                          ? const Color(0xFFF44336)
                          : colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Risk Sentinel',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getRiskModeColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    riskMode,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getRiskModeColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Drawdown indicators
            Text(
              'Drawdown Limits',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildDrawdownBar(
              'Daily',
              dailyDrawdown,
              maxDailyDrawdown,
              theme,
            ),
            const SizedBox(height: 8),
            _buildDrawdownBar(
              'Weekly',
              weeklyDrawdown,
              maxWeeklyDrawdown,
              theme,
            ),
            const SizedBox(height: 8),
            _buildDrawdownBar(
              'Monthly',
              monthlyDrawdown,
              maxMonthlyDrawdown,
              theme,
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            // Exposure monitor
            Text(
              'Exposure Monitor',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Exposure',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '\$${totalExposure.toStringAsFixed(2)} / \$${maxExposure.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: totalExposure / maxExposure,
                minHeight: 10,
                backgroundColor: colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getDrawdownColor(totalExposure, maxExposure),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Consecutive losses
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Consecutive Losses',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: consecutiveLosses >= maxConsecutiveLosses - 1
                        ? const Color(0xFFF44336).withValues(alpha: 0.2)
                        : colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$consecutiveLosses / $maxConsecutiveLosses',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: consecutiveLosses >= maxConsecutiveLosses - 1
                          ? const Color(0xFFF44336)
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            // Kill Switch button
            if (onKillSwitch != null)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: isProcessing ? null : onKillSwitch,
                  icon: isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(
                          killSwitchActive ? Icons.play_arrow : Icons.warning,
                          size: 24,
                        ),
                  label: Text(
                    isProcessing
                        ? 'Processing...'
                        : killSwitchActive
                            ? 'Deactivate Kill Switch'
                            : 'Activate Kill Switch',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: killSwitchActive
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFF44336),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    disabledForegroundColor: Colors.white70,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawdownBar(
    String label,
    double current,
    double max,
    ThemeData theme,
  ) {
    final percentage = (current / max).clamp(0.0, 1.0);
    final color = _getDrawdownColor(current, max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${current.toStringAsFixed(2)}% / ${max.toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
