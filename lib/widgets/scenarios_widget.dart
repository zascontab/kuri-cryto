import 'package:flutter/material.dart';
import '../models/comprehensive_analysis.dart';

/// Widget that displays market scenarios
///
/// Shows:
/// - List of possible market scenarios
/// - Probability percentage for each scenario
/// - Target price and change percentage
/// - Impact type (positive/negative/neutral)
/// - Description and timeframe
///
/// Color-coded based on impact type
class ScenariosWidget extends StatelessWidget {
  /// List of market scenarios
  final List<MarketScenario> scenarios;

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
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(
                    milliseconds: 400 + (index * 150),
                  ),
                  curve: Curves.easeOut,
                  builder: (context, animValue, child) {
                    return Opacity(
                      opacity: animValue,
                      child: Transform.translate(
                        offset: Offset(30 * (1 - animValue), 0),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      _ScenarioCard(scenario: scenario),
                      if (index < scenarios.length - 1)
                        const SizedBox(height: 12),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

/// Card widget for displaying a single market scenario
class _ScenarioCard extends StatelessWidget {
  final MarketScenario scenario;

  const _ScenarioCard({
    required this.scenario,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final impactColor = _getImpactColor();
    final isPositive = scenario.isPositive;
    final isNegative = scenario.isNegative;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: impactColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: impactColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name and impact badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  scenario.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _ImpactBadge(
                impact: scenario.impact,
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
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: scenario.probability),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOut,
                        builder: (context, animValue, child) {
                          return LinearProgressIndicator(
                            value: animValue,
                            minHeight: 6,
                            backgroundColor: colorScheme.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              impactColor,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Target and Change
          Row(
            children: [
              Expanded(
                child: _MetricItem(
                  label: 'Target',
                  value: '\$${scenario.targetPrice.toStringAsFixed(2)}',
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricItem(
                  label: 'Change',
                  value: '${isPositive ? '+' : ''}${scenario.changePercent.toStringAsFixed(2)}%',
                  valueColor: impactColor,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricItem(
                  label: 'Timeframe',
                  value: scenario.timeframe,
                  theme: theme,
                ),
              ),
            ],
          ),
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
        ],
      ),
    );
  }

  Color _getImpactColor() {
    switch (scenario.impact.toLowerCase()) {
      case 'positive':
        return const Color(0xFF10B981); // Green
      case 'negative':
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
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
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
      case 'positive':
        return Icons.arrow_upward;
      case 'negative':
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
