import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget mejorado de estado del sistema que incluye las nuevas funcionalidades
class EnhancedSystemStatus extends ConsumerWidget {
  const EnhancedSystemStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.monitor_heart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Estado del Sistema',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Estado de servicios
            _buildServiceStatus(
              context,
              'MATP API',
              true,
              'Conectado',
              Icons.api,
            ),
            const SizedBox(height: 8),
            _buildServiceStatus(
              context,
              'MCP Server',
              true,
              '29 herramientas disponibles',
              Icons.extension,
            ),
            const SizedBox(height: 8),
            _buildServiceStatus(
              context,
              'Bot Autónomo',
              false,
              'Detenido',
              Icons.smart_toy,
            ),
            const SizedBox(height: 8),
            _buildServiceStatus(
              context,
              'Análisis IA',
              true,
              'Activo',
              Icons.psychology,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceStatus(
    BuildContext context,
    String serviceName,
    bool isActive,
    String status,
    IconData icon,
  ) {
    final color = isActive ? Colors.green : Colors.grey;

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            serviceName,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          status,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
