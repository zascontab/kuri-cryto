import 'package:flutter/material.dart';
import '../models/comprehensive_analysis.dart';

/// Widget that displays multi-timeframe analysis
///
/// Shows:
/// - Analysis for 1m, 5m, 15m, and 1h timeframes
/// - RSI, trend, and signal for each timeframe
/// - Alignment badge indicating if timeframes agree
///
/// Color-coded signals and alignment status
class MultiTimeframeWidget extends StatelessWidget {
  /// Multi-timeframe analysis data
  final MultiTimeframeAnalysis multiTimeframe;

  const MultiTimeframeWidget({
    super.key,
    required this.multiTimeframe,
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
            // Title and Alignment Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Multi-Timeframe Analysis',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _AlignmentBadge(
                  alignment: multiTimeframe.alignment,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1m Timeframe
            _TimeframeRow(
              timeframe: '1m',
              data: multiTimeframe.oneMinute,
              isFirst: true,
            ),
            const Divider(height: 20),

            // 5m Timeframe
            _TimeframeRow(
              timeframe: '5m',
              data: multiTimeframe.fiveMinutes,
            ),
            const Divider(height: 20),

            // 15m Timeframe
            _TimeframeRow(
              timeframe: '15m',
              data: multiTimeframe.fifteenMinutes,
            ),
            const Divider(height: 20),

            // 1h Timeframe
            _TimeframeRow(
              timeframe: '1h',
              data: multiTimeframe.oneHour,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Row widget for displaying a single timeframe's analysis
class _TimeframeRow extends StatelessWidget {
  final String timeframe;
  final TimeframeData data;
  final bool isFirst;
  final bool isLast;

  const _TimeframeRow({
    required this.timeframe,
    required this.data,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(
        milliseconds: 400 + (_getTimeframeIndex(timeframe) * 100),
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
      child: Row(
        children: [
          // Timeframe Label
          SizedBox(
            width: 40,
            child: Text(
              timeframe,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // RSI Value
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RSI',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.rsi.toStringAsFixed(1),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getRsiColor(data.rsi),
                  ),
                ),
              ],
            ),
          ),

          // Trend Badge
          Expanded(
            flex: 3,
            child: _TrendBadge(
              trend: data.trend,
            ),
          ),
          const SizedBox(width: 8),

          // Signal Badge
          Expanded(
            flex: 3,
            child: _SignalBadge(
              signal: data.signal,
            ),
          ),
        ],
      ),
    );
  }

  int _getTimeframeIndex(String tf) {
    switch (tf) {
      case '1m':
        return 0;
      case '5m':
        return 1;
      case '15m':
        return 2;
      case '1h':
        return 3;
      default:
        return 0;
    }
  }

  Color _getRsiColor(double rsi) {
    if (rsi < 30) return const Color(0xFF10B981); // Oversold - Green
    if (rsi > 70) return const Color(0xFFEF4444); // Overbought - Red
    return const Color(0xFF6B7280); // Neutral - Gray
  }
}

/// Badge for displaying alignment status
class _AlignmentBadge extends StatelessWidget {
  final String alignment;

  const _AlignmentBadge({
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBullish = alignment == 'bullish_aligned';
    final isBearish = alignment == 'bearish_aligned';
    final isAligned = isBullish || isBearish;

    final color = isBullish
        ? const Color(0xFF10B981) // Green
        : isBearish
            ? const Color(0xFFEF4444) // Red
            : const Color(0xFF6B7280); // Gray

    final text = isBullish
        ? 'BULLISH'
        : isBearish
            ? 'BEARISH'
            : 'NOT ALIGNED';

    final icon = isBullish
        ? Icons.arrow_upward
        : isBearish
            ? Icons.arrow_downward
            : Icons.horizontal_rule;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(isAligned ? 0.5 : 0.3),
          width: isAligned ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge for displaying trend
class _TrendBadge extends StatelessWidget {
  final String trend;

  const _TrendBadge({
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getTrendColor(trend);
    final icon = _getTrendIcon(trend);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              trend.toUpperCase(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'bullish':
      case 'up':
        return const Color(0xFF10B981); // Green
      case 'bearish':
      case 'down':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend.toLowerCase()) {
      case 'bullish':
      case 'up':
        return Icons.trending_up;
      case 'bearish':
      case 'down':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }
}

/// Badge for displaying signal
class _SignalBadge extends StatelessWidget {
  final String signal;

  const _SignalBadge({
    required this.signal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getSignalColor(signal);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        signal.toUpperCase(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Color _getSignalColor(String signal) {
    switch (signal.toLowerCase()) {
      case 'buy':
      case 'long':
        return const Color(0xFF10B981); // Green
      case 'sell':
      case 'short':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }
}
