import 'package:flutter/material.dart';
import '../models/comprehensive_analysis.dart';

/// Widget that displays current price information in a header format
///
/// Shows:
/// - Symbol and current price
/// - 24h price change with up/down arrow
/// - 24h high and low prices
///
/// Colors adapt based on theme and price movement (green for gains, red for losses)
class PriceHeaderWidget extends StatelessWidget {
  /// Current price data
  final CurrentPrice currentPrice;

  /// Trading symbol (e.g., "BTC/USDT")
  final String symbol;

  const PriceHeaderWidget({
    super.key,
    required this.currentPrice,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPositive = currentPrice.isPositiveChange;
    final changeColor = isPositive
        ? const Color(0xFF10B981) // profitGreen
        : const Color(0xFFEF4444); // lossRed

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Symbol
          Text(
            symbol,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Current Price and Change
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Current Price
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, animValue, child) {
                  return Opacity(
                    opacity: animValue,
                    child: Transform.scale(
                      scale: 0.8 + (0.2 * animValue),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  '\$${currentPrice.current.toStringAsFixed(2)}',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 24h Change
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 16,
                      color: changeColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isPositive ? '+' : ''}${currentPrice.change24h.toStringAsFixed(2)}%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: changeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // High and Low 24h
          Row(
            children: [
              Expanded(
                child: _HighLowItem(
                  label: '24h High',
                  value: currentPrice.high24h,
                  theme: theme,
                  colorScheme: colorScheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HighLowItem(
                  label: '24h Low',
                  value: currentPrice.low24h,
                  theme: theme,
                  colorScheme: colorScheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Helper widget for displaying high/low values
class _HighLowItem extends StatelessWidget {
  final String label;
  final double value;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _HighLowItem({
    required this.label,
    required this.value,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
