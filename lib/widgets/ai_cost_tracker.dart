import 'package:flutter/material.dart';
import '../models/ai_costs.dart';

/// Widget compacto para tracking de costos
///
/// Muestra:
/// - Costo hoy / presupuesto
/// - Progress bar
/// - Llamadas usadas
/// - Alerta si cerca del límite
class AICostTracker extends StatelessWidget {
  final DailyCosts dailyCosts;
  final double dailyBudget;
  final VoidCallback? onTap;

  const AICostTracker({
    super.key,
    required this.dailyCosts,
    required this.dailyBudget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usagePercent =
        dailyBudget > 0 ? (dailyCosts.total / dailyBudget) * 100 : 0.0;
    final isNearLimit = usagePercent >= 80;
    final hasExceeded = usagePercent >= 100;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: _getStatusColor(usagePercent),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Costos de IA',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (isNearLimit)
                    Icon(
                      hasExceeded ? Icons.error : Icons.warning,
                      color: _getStatusColor(usagePercent),
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Costo actual vs presupuesto
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gastado hoy:',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    '\$${dailyCosts.total.toStringAsFixed(4)} / \$${dailyBudget.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(usagePercent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (usagePercent / 100).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStatusColor(usagePercent),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Llamadas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Llamadas:',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    '${dailyCosts.callCount}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Costo promedio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Promedio:',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    '\$${dailyCosts.avgCostPerCall.toStringAsFixed(6)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Alerta si cerca del límite
              if (isNearLimit) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(usagePercent).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          _getStatusColor(usagePercent).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasExceeded ? Icons.error : Icons.warning,
                        size: 16,
                        color: _getStatusColor(usagePercent),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hasExceeded
                              ? 'Presupuesto excedido'
                              : 'Cerca del límite diario',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(usagePercent),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  Color _getStatusColor(double usagePercent) {
    if (usagePercent >= 100) {
      return const Color(0xFFEF4444); // Red - Exceeded
    } else if (usagePercent >= 80) {
      return const Color(0xFFF59E0B); // Orange - Near limit
    } else if (usagePercent >= 50) {
      return const Color(0xFF3B82F6); // Blue - Moderate
    } else {
      return const Color(0xFF10B981); // Green - Low
    }
  }
}
