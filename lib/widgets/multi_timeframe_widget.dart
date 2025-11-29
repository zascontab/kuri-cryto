import 'package:flutter/material.dart';
import '../models/comprehensive_analysis.dart';

/// Widget that displays multi-timeframe analysis
///
/// Shows:
/// - Analysis for multiple timeframes (1m, 5m, 15m, 1h, 4h)
/// - RSI, MACD, and other indicators for each timeframe
/// - Trend signals for each timeframe
///
/// Color-coded signals based on indicator values
class MultiTimeframeWidget extends StatelessWidget {
  /// Map of timeframe to technical indicators
  final Map<String, TechnicalIndicators> technicalIndicators;

  const MultiTimeframeWidget({
    super.key,
    required this.technicalIndicators,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Sort timeframes in order
    final sortedTimeframes = _sortTimeframes(technicalIndicators.keys.toList());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Multi-Timeframe Analysis',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Timeframe rows
            if (sortedTimeframes.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'No timeframe data available',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...sortedTimeframes.asMap().entries.map((entry) {
                final index = entry.key;
                final timeframe = entry.value;
                final indicators = technicalIndicators[timeframe]!;

                return Column(
                  children: [
                    _TimeframeRow(
                      timeframe: timeframe,
                      indicators: indicators,
                    ),
                    if (index < sortedTimeframes.length - 1)
                      const Divider(height: 20),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }

  List<String> _sortTimeframes(List<String> timeframes) {
    final order = ['1m', '5m', '15m', '1h', '4h', '1d'];
    timeframes.sort((a, b) {
      final aIndex = order.indexOf(a);
      final bIndex = order.indexOf(b);
      if (aIndex == -1 && bIndex == -1) return 0;
      if (aIndex == -1) return 1;
      if (bIndex == -1) return -1;
      return aIndex.compareTo(bIndex);
    });
    return timeframes;
  }
}

/// Row widget for displaying a single timeframe's analysis
class _TimeframeRow extends StatelessWidget {
  final String timeframe;
  final TechnicalIndicators indicators;

  const _TimeframeRow({
    required this.timeframe,
    required this.indicators,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeframe header
        Text(
          timeframe.toUpperCase(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),

        // Indicators
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (indicators.rsi != null)
              _IndicatorChip(
                label: 'RSI',
                value: indicators.rsi!.value.toStringAsFixed(1),
                signal: indicators.rsi!.signal,
                color: _getRSIColor(indicators.rsi!.value),
              ),
            if (indicators.macd != null)
              _IndicatorChip(
                label: 'MACD',
                value: indicators.macd!.trend,
                signal: indicators.macd!.histogram > 0 ? 'bullish' : 'bearish',
                color: indicators.macd!.isBullish ? Colors.green : Colors.red,
              ),
            if (indicators.bollingerBands != null)
              _IndicatorChip(
                label: 'BB',
                value: indicators.bollingerBands!.position,
                signal: indicators.bollingerBands!.position,
                color: _getBBColor(indicators.bollingerBands!.position),
              ),
            if (indicators.ema != null)
              _IndicatorChip(
                label: 'EMA',
                value: indicators.ema!.trend,
                signal: indicators.ema!.trend,
                color: _getTrendColor(indicators.ema!.trend),
              ),
            if (indicators.volume != null)
              _IndicatorChip(
                label: 'Volume',
                value: indicators.volume!.trend,
                signal: indicators.volume!.trend,
                color: _getTrendColor(indicators.volume!.trend),
              ),
          ],
        ),
      ],
    );
  }

  Color _getRSIColor(double rsi) {
    if (rsi > 70) return Colors.red;
    if (rsi < 30) return Colors.green;
    return Colors.blue;
  }

  Color _getBBColor(String position) {
    switch (position.toLowerCase()) {
      case 'above_upper':
        return Colors.red;
      case 'below_lower':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'bullish':
      case 'increasing':
        return Colors.green;
      case 'bearish':
      case 'decreasing':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// Chip widget for displaying an indicator
class _IndicatorChip extends StatelessWidget {
  final String label;
  final String value;
  final String signal;
  final Color color;

  const _IndicatorChip({
    required this.label,
    required this.value,
    required this.signal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
