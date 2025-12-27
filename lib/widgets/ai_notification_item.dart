import 'package:flutter/material.dart';
import '../models/ai_notification.dart';

/// Widget para item individual de notificación
///
/// Muestra:
/// - Icono según tipo
/// - Título (acción + símbolo)
/// - Snippet de explicación
/// - Tiempo relativo
/// - Badge si no leída
class AINotificationItem extends StatelessWidget {
  final AINotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;

  const AINotificationItem({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionColor = _getActionColor();

    return Card(
      elevation: notification.isRead ? 1 : 3,
      child: InkWell(
        onTap: () {
          if (!notification.isRead && onMarkAsRead != null) {
            onMarkAsRead!();
          }
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: !notification.isRead
                ? Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 2,
                  )
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIcon(),
                  color: actionColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),

              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${notification.action} ${notification.symbol}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Precio
                    Text(
                      '\$${notification.price.toStringAsFixed(4)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: actionColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Snippet de explicación
                    Text(
                      _getExplanationSnippet(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tipo
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getTypeDisplayName(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Tiempo
                        Text(
                          notification.timeAgoFormatted,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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
    if (notification.isBuy) {
      return const Color(0xFF10B981); // Green
    } else if (notification.isSell) {
      return const Color(0xFFEF4444); // Red
    } else {
      return const Color(0xFF6B7280); // Gray
    }
  }

  IconData _getTypeIcon() {
    if (notification.isTradeExecuted) {
      return notification.isBuy ? Icons.trending_up : Icons.trending_down;
    } else if (notification.isAlert) {
      return Icons.notifications_active;
    } else if (notification.isWarning) {
      return Icons.warning;
    } else {
      return Icons.info;
    }
  }

  String _getTypeDisplayName() {
    if (notification.isTradeExecuted) {
      return 'Trade';
    } else if (notification.isAlert) {
      return 'Alerta';
    } else if (notification.isWarning) {
      return 'Advertencia';
    } else {
      return 'Info';
    }
  }

  String _getExplanationSnippet() {
    if (notification.llmExplanation.length <= 100) {
      return notification.llmExplanation;
    }
    return '${notification.llmExplanation.substring(0, 100)}...';
  }
}
