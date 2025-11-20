import 'package:flutter/material.dart';
import '../models/comprehensive_analysis.dart';

/// Widget that displays trading recommendation
///
/// Shows:
/// - Action (BUY/SELL/WAIT) with prominent display
/// - Confidence level with progress bar
/// - List of reasoning points
/// - Entry price, stop loss, and take profit levels
///
/// Background color adapts based on action type
class RecommendationWidget extends StatelessWidget {
  /// Recommendation data
  final Recommendation recommendation;

  const RecommendationWidget({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final actionColor = _getActionColor();
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              actionColor.withOpacity(0.1),
              actionColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Action Header
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, animValue, child) {
                    return Transform.scale(
                      scale: 0.5 + (0.5 * animValue),
                      child: Opacity(
                        opacity: animValue,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: actionColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: actionColor.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getActionIcon(),
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          recommendation.action,
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Confidence
              Text(
                'Confidence Level',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: recommendation.confidence),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOut,
                builder: (context, animValue, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: animValue,
                          minHeight: 12,
                          backgroundColor: colorScheme.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            actionColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(animValue * 100).toStringAsFixed(1)}%',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: actionColor,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Reasoning
              Text(
                'Analysis',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...recommendation.reasoning.asMap().entries.map((entry) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(
                    milliseconds: 400 + (entry.key * 100),
                  ),
                  curve: Curves.easeOut,
                  builder: (context, animValue, child) {
                    return Opacity(
                      opacity: animValue,
                      child: Transform.translate(
                        offset: Offset(20 * (1 - animValue), 0),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: actionColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),

              // Price Levels (only show if not WAIT)
              if (!recommendation.isWait) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: actionColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _PriceLevel(
                        label: 'Entry Price',
                        value: recommendation.entryPrice,
                        icon: Icons.flag,
                        color: actionColor,
                      ),
                      const SizedBox(height: 12),
                      _PriceLevel(
                        label: 'Stop Loss',
                        value: recommendation.stopLoss,
                        icon: Icons.shield,
                        color: const Color(0xFFEF4444), // Red
                      ),
                      const SizedBox(height: 12),
                      _PriceLevel(
                        label: 'Take Profit',
                        value: recommendation.takeProfit,
                        icon: Icons.emoji_events,
                        color: const Color(0xFF10B981), // Green
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getActionColor() {
    if (recommendation.isBuy) {
      return const Color(0xFF10B981); // Green
    } else if (recommendation.isSell) {
      return const Color(0xFFEF4444); // Red
    } else {
      return const Color(0xFFF59E0B); // Yellow/Orange for WAIT
    }
  }

  IconData _getActionIcon() {
    if (recommendation.isBuy) {
      return Icons.trending_up;
    } else if (recommendation.isSell) {
      return Icons.trending_down;
    } else {
      return Icons.pause_circle_outline;
    }
  }
}

/// Widget for displaying a price level with label, value, and icon
class _PriceLevel extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;

  const _PriceLevel({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '\$${value.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
