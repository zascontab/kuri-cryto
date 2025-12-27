import 'package:flutter/material.dart';
import '../models/ai_status.dart';

/// Indicador compacto de estado de IA
///
/// Muestra:
/// - Estado del LLM (operacional/error)
/// - Llamadas usadas hoy
/// - Costo gastado
/// - Progress bar
class AIStatusIndicator extends StatelessWidget {
  final AIStatus aiStatus;
  final VoidCallback? onTap;

  const AIStatusIndicator({
    super.key,
    required this.aiStatus,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final llm = aiStatus.llm;
    final costs = aiStatus.costManagement;

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
                    Icons.psychology,
                    color: _getStatusColor(llm.status),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '🤖 Estado de IA',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(llm.status).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      llm.providerDisplayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(llm.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // LLM Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LLM: ${llm.model}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Row(
                    children: [
                      Icon(
                        llm.isOperational ? Icons.check_circle : Icons.error,
                        size: 16,
                        color: _getStatusColor(llm.status),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        llm.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(llm.status),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Llamadas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Llamadas hoy:',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    '${llm.callsToday} / ${llm.dailyLimit}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: llm.usagePercent / 100,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    llm.isNearLimit
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF3B82F6),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Costos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Costo hoy:',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    '\$${costs.spentToday.toStringAsFixed(2)} / \$${costs.dailyBudget.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: costs.usagePercent / 100,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    costs.isNearLimit
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'operational':
        return const Color(0xFF10B981); // Green
      case 'degraded':
        return const Color(0xFFF59E0B); // Orange
      case 'error':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }
}
