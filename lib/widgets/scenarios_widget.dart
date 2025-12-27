import 'package:flutter/material.dart';
import '../models/comprehensive_analysis.dart';

/// Widget that displays market scenarios
///
/// Shows:
/// - List of possible market scenarios
/// - Probability percentage for each scenario
/// - Target price and stop loss
/// - Description and conditions
///
/// Color-coded based on scenario type (bullish/bearish/neutral)
class ScenariosWidget extends StatelessWidget {
  /// List of market scenarios
  final List<Scenario> scenarios;

  const ScenariosWidget({
    super.key,
    required this.scenarios,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  Icons.trending_up,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Market Scenarios',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Scenarios List
            if (scenarios.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'No scenarios available',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...scenarios.asMap().entries.map((entry) {
                final index = entry.key;
                final scenario = entry.value;
                return Column(
                  children: [
                    _ScenarioCard(scenario: scenario),
                    if (index < scenarios.length - 1)
                      const SizedBox(height: 12),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }
}

/// Card widget for displaying a single market scenario
class _ScenarioCard extends StatelessWidget {
  final Scenario scenario;

  const _ScenarioCard({
    required this.scenario,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final impactColor = _getImpactColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: impactColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: impactColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with type and badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  scenario.type.toUpperCase(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _ImpactBadge(
                impact: scenario.type,
                color: impactColor,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Probability bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Probability',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${(scenario.probability * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: impactColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: scenario.probability,
                        minHeight: 6,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(impactColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Target and Stop Loss
          if (scenario.targetPrice != null || scenario.stopLoss != null)
            Row(
              children: [
                if (scenario.targetPrice != null)
                  Expanded(
                    child: _MetricItem(
                      label: 'Target',
                      value: '\$${scenario.targetPrice!.toStringAsFixed(2)}',
                      theme: theme,
                    ),
                  ),
                if (scenario.targetPrice != null && scenario.stopLoss != null)
                  const SizedBox(width: 12),
                if (scenario.stopLoss != null)
                  Expanded(
                    child: _MetricItem(
                      label: 'Stop Loss',
                      value: '\$${scenario.stopLoss!.toStringAsFixed(2)}',
                      valueColor: Colors.red,
                      theme: theme,
                    ),
                  ),
              ],
            ),
          if (scenario.targetPrice != null || scenario.stopLoss != null)
            const SizedBox(height: 12),

          // Description
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    scenario.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Conditions
          if (scenario.conditions.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...scenario.conditions.map((condition) {
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: impactColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        condition,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Color _getImpactColor() {
    switch (scenario.type.toLowerCase()) {
      case 'bullish':
        return const Color(0xFF10B981); // Green
      case 'bearish':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }
}

/// Badge for displaying impact type
class _ImpactBadge extends StatelessWidget {
  final String impact;
  final Color color;

  const _ImpactBadge({
    required this.impact,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = _getImpactIcon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
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
            impact.toUpperCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getImpactIcon() {
    switch (impact.toLowerCase()) {
      case 'bullish':
        return Icons.arrow_upward;
      case 'bearish':
        return Icons.arrow_downward;
      default:
        return Icons.horizontal_rule;
    }
  }
}

/// Helper widget for displaying a metric with label and value
class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final ThemeData theme;

  const _MetricItem({
    required this.label,
    required this.value,
    this.valueColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? theme.colorScheme.onSurface,
            fontSize: 13,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
