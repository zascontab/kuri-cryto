import 'package:flutter/material.dart';
import '../models/comprehensive_analysis.dart';

/// Widget that displays technical analysis indicators
///
/// Shows:
/// - RSI with interpretation and signal badge
/// - MACD with trend indicator
/// - Overall trend with strength indicator
///
/// Uses color-coded badges for different signal types
class TechnicalIndicatorsWidget extends StatelessWidget {
  /// Technical analysis data
  final TechnicalAnalysis technicalAnalysis;

  const TechnicalIndicatorsWidget({
    super.key,
    required this.technicalAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Technical Analysis',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // RSI
            _IndicatorRow(
              label: 'RSI',
              value: technicalAnalysis.rsi.value.toStringAsFixed(2),
              interpretation: technicalAnalysis.rsi.interpretation,
              badge: _SignalBadge(
                text: _getRsiSignalText(technicalAnalysis.rsi),
                color: _getRsiColor(technicalAnalysis.rsi),
              ),
            ),
            const Divider(height: 24),

            // MACD
            _IndicatorRow(
              label: 'MACD',
              value: technicalAnalysis.macd.histogram.toStringAsFixed(4),
              interpretation: 'Histogram',
              badge: _TrendBadge(
                trend: technicalAnalysis.macd.trend,
              ),
            ),
            const Divider(height: 24),

            // Overall Trend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trend',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _TrendBadge(
                      trend: technicalAnalysis.trend,
                      isLarge: true,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Strength',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 120,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: 0.0,
                          end: technicalAnalysis.strength,
                        ),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOut,
                        builder: (context, animValue, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: animValue,
                                  minHeight: 8,
                                  backgroundColor:
                                      colorScheme.surfaceVariant,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getTrendColor(
                                      technicalAnalysis.trend,
                                      colorScheme,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(animValue * 100).toStringAsFixed(0)}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getTrendColor(
                                    technicalAnalysis.trend,
                                    colorScheme,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRsiSignalText(RsiData rsi) {
    if (rsi.isOversold) return 'Oversold';
    if (rsi.isOverbought) return 'Overbought';
    return 'Neutral';
  }

  Color _getRsiColor(RsiData rsi) {
    if (rsi.isOversold) return const Color(0xFF10B981); // Green (buy opportunity)
    if (rsi.isOverbought) return const Color(0xFFEF4444); // Red (sell signal)
    return const Color(0xFF6B7280); // Gray (neutral)
  }

  Color _getTrendColor(String trend, ColorScheme colorScheme) {
    switch (trend.toLowerCase()) {
      case 'bullish':
        return const Color(0xFF10B981); // Green
      case 'bearish':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }
}

/// Row widget for displaying an indicator with label, value, interpretation, and badge
class _IndicatorRow extends StatelessWidget {
  final String label;
  final String value;
  final String interpretation;
  final Widget badge;

  const _IndicatorRow({
    required this.label,
    required this.value,
    required this.interpretation,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                interpretation,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        badge,
      ],
    );
  }
}

/// Badge widget for displaying signal types (oversold, overbought, neutral)
class _SignalBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _SignalBadge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Badge widget for displaying trend direction
class _TrendBadge extends StatelessWidget {
  final String trend;
  final bool isLarge;

  const _TrendBadge({
    required this.trend,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getTrendColor(trend);
    final icon = _getTrendIcon(trend);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 16 : 12,
        vertical: isLarge ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(isLarge ? 20 : 16),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isLarge ? 18 : 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            trend.toUpperCase(),
            style: (isLarge
                    ? theme.textTheme.titleSmall
                    : theme.textTheme.bodySmall)
                ?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'bullish':
        return const Color(0xFF10B981); // Green
      case 'bearish':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend.toLowerCase()) {
      case 'bullish':
        return Icons.trending_up;
      case 'bearish':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }
}
