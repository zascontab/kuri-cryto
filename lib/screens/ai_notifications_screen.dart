import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_notification.dart';
import '../providers/ai_notifications_provider.dart';

/// Pantalla con lista de notificaciones inteligentes generadas por IA
class AINotificationsScreen extends ConsumerWidget {
  const AINotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(aINotificationsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones de IA'),
        actions: [
          notificationsAsync.when(
            data: (notifications) {
              final unreadCount = notifications.where((n) => !n.isRead).length;
              if (unreadCount > 0) {
                return TextButton.icon(
                  onPressed: () {
                    ref
                        .read(aINotificationsNotifierProvider.notifier)
                        .markAllAsRead();
                  },
                  icon: const Icon(Icons.done_all),
                  label: const Text('Marcar todas'),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(aINotificationsNotifierProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay notificaciones',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(aINotificationsNotifierProvider.notifier)
                  .refresh();
            },
            child: ListView.builder(
              itemCount: notifications.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationItem(
                  notification: notification,
                  onTap: () => _showNotificationDetails(
                    context,
                    ref,
                    notification,
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(aINotificationsNotifierProvider.notifier).refresh();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationDetails(
    BuildContext context,
    WidgetRef ref,
    AINotification notification,
  ) {
    // Mark as read
    if (!notification.isRead) {
      ref
          .read(aINotificationsNotifierProvider.notifier)
          .markAsRead(notification.id);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _NotificationDetailsSheet(
            notification: notification,
            scrollController: scrollController,
          );
        },
      ),
    );
  }
}

/// Widget para item individual de notificación
class _NotificationItem extends StatelessWidget {
  final AINotification notification;
  final VoidCallback onTap;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionColor = _getActionColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getActionIcon(),
                  color: actionColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${notification.action} ${notification.symbol}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3B82F6),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${notification.price.toStringAsFixed(4)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: actionColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.llmExplanation,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.timeAgoFormatted,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getActionColor() {
    if (notification.isBuy) return const Color(0xFF10B981);
    if (notification.isSell) return const Color(0xFFEF4444);
    return const Color(0xFF6B7280);
  }

  IconData _getActionIcon() {
    if (notification.isBuy) return Icons.trending_up;
    if (notification.isSell) return Icons.trending_down;
    return Icons.info_outline;
  }
}

/// Sheet con detalles completos de la notificación
class _NotificationDetailsSheet extends StatelessWidget {
  final AINotification notification;
  final ScrollController scrollController;

  const _NotificationDetailsSheet({
    required this.notification,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionColor = _getActionColor();

    return Container(
      padding: const EdgeInsets.all(24),
      child: ListView(
        controller: scrollController,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getActionIcon(),
                  color: actionColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${notification.action} ${notification.symbol}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${notification.price.toStringAsFixed(4)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: actionColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Explicación de IA
          _buildSection(
            theme,
            '🤖 Análisis de IA',
            notification.llmExplanation,
          ),
          const SizedBox(height: 16),

          // Análisis de mercado
          _buildSection(
            theme,
            '📊 Análisis de Mercado',
            notification.marketAnalysis,
          ),
          const SizedBox(height: 16),

          // Evaluación de riesgo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getRiskColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getRiskColor().withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shield,
                      color: _getRiskColor(),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Evaluación de Riesgo',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  notification.riskAssessment,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Timestamp
          Text(
            'Hace ${notification.timeAgoFormatted}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Color _getActionColor() {
    if (notification.isBuy) return const Color(0xFF10B981);
    if (notification.isSell) return const Color(0xFFEF4444);
    return const Color(0xFF6B7280);
  }

  IconData _getActionIcon() {
    if (notification.isBuy) return Icons.trending_up;
    if (notification.isSell) return Icons.trending_down;
    return Icons.info_outline;
  }

  Color _getRiskColor() {
    final risk = notification.riskAssessment.toLowerCase();
    if (risk.contains('low')) return const Color(0xFF10B981);
    if (risk.contains('high')) return const Color(0xFFEF4444);
    return const Color(0xFFF59E0B);
  }
}
