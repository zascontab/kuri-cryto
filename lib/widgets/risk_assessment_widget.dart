import 'package:flutter/material.dart';
import '../models/comprehensive_analysis.dart';

/// Widget that displays risk assessment information
///
/// Shows:
/// - Risk level badge (LOW/MEDIUM/HIGH)
/// - Risk score with progress indicator
/// - List of risk factors with icons
/// - Volatility indicator
///
/// Color-coded based on risk level (green for low, orange for medium, red for high)
class RiskAssessmentWidget extends StatelessWidget {
  /// Risk assessment data
  final RiskAssessment riskAssessment;

  const RiskAssessmentWidget({
    super.key,
    required this.riskAssessment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final riskColor = _getRiskColor();

    return Card(
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              riskColor.withOpacity(0.08),
              riskColor.withOpacity(0.02),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Risk Assessment',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Risk Level Badge (Large and Prominent)
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: riskColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: riskColor.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getRiskIcon(),
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${riskAssessment.level.toUpperCase()} RISK',
                          style: theme.textTheme.headlineMedium?.copyWith(
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

              // Risk Score
              Text(
                'Risk Score',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: riskAssessment.score / 100),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOut,
                builder: (context, animValue, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: animValue,
                                minHeight: 16,
                                backgroundColor: colorScheme.surfaceVariant,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  riskColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: riskColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${(animValue * 100).toStringAsFixed(0)}/100',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: riskColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Volatility
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.show_chart,
                          color: _getVolatilityColor(),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Volatility',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
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
                        color: _getVolatilityColor().withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        riskAssessment.volatility.toUpperCase(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getVolatilityColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Risk Factors
              Text(
                'Risk Factors',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (riskAssessment.factors.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No risk factors identified',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                ...riskAssessment.factors.asMap().entries.map((entry) {
                  final index = entry.key;
                  final factor = entry.value;
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(
                      milliseconds: 400 + (index * 100),
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
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: riskColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: riskColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              factor,
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
            ],
          ),
        ),
      ),
    );
  }

  Color _getRiskColor() {
    if (riskAssessment.isLowRisk) {
      return const Color(0xFF10B981); // Green
    } else if (riskAssessment.isMediumRisk) {
      return const Color(0xFFF59E0B); // Orange
    } else {
      return const Color(0xFFEF4444); // Red
    }
  }

  IconData _getRiskIcon() {
    if (riskAssessment.isLowRisk) {
      return Icons.check_circle;
    } else if (riskAssessment.isMediumRisk) {
      return Icons.warning;
    } else {
      return Icons.error;
    }
  }

  Color _getVolatilityColor() {
    switch (riskAssessment.volatility.toLowerCase()) {
      case 'low':
        return const Color(0xFF10B981); // Green
      case 'medium':
        return const Color(0xFFF59E0B); // Orange
      case 'high':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }
}
