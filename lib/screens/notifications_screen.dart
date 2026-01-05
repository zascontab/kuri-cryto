import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/push_notification.dart';
import '../providers/firebase_messaging_provider.dart';

/// Pantalla para mostrar todas las notificaciones
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          if (notificationsState.unreadCount > 0)
            TextButton.icon(
              onPressed: () => notifier.markAllAsRead(),
              icon: const Icon(Icons.done_all, color: Colors.white),
              label: const Text(
                'Marcar todas',
                style: TextStyle(color: Colors.white),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearDialog(context, notifier),
            tooltip: 'Eliminar todas',
          ),
        ],
      ),
      body: _buildBody(context, notificationsState, notifier),
    );
  }

  Widget _buildBody(
    BuildContext context,
    NotificationsState state,
    NotificationsNotifier notifier,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => notifier.clearError(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay notificaciones',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: state.notifications.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final notification = state.notifications[index];
        return _NotificationTile(
          notification: notification,
          onTap: () => _handleNotificationTap(context, notification, notifier),
          onDismiss: () => notifier.removeNotification(notification.id!),
        );
      },
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    PushNotification notification,
    NotificationsNotifier notifier,
  ) {
    if (!notification.isRead) {
      notifier.markAsRead(notification.id!);
    }

    // Mostrar detalles de la notificación
    showDialog(
      context: context,
      builder: (context) => _NotificationDetailDialog(notification: notification),
    );
  }

  void _showClearDialog(BuildContext context, NotificationsNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar todas'),
        content: const Text('¿Estás seguro de que deseas eliminar todas las notificaciones?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              notifier.clearAll();
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar una notificación en la lista
class _NotificationTile extends StatelessWidget {
  final PushNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id ?? notification.hashCode.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.isRead ? Colors.grey : Theme.of(context).primaryColor,
          child: Text(
            notification.type.icon,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(notification.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: !notification.isRead
            ? Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

/// Diálogo para mostrar detalles de una notificación
class _NotificationDetailDialog extends StatelessWidget {
  final PushNotification notification;

  const _NotificationDetailDialog({required this.notification});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text(notification.type.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Expanded(child: Text(notification.title)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(notification.body),
            const SizedBox(height: 16),
            Text(
              'Tipo: ${notification.type.displayName}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fecha: ${_formatFullTimestamp(notification.timestamp)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (notification.data != null && notification.data!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Datos adicionales:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...notification.data!.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
        if (notification.actionUrl != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Aquí puedes agregar navegación a la URL
            },
            child: const Text('Ver más'),
          ),
      ],
    );
  }

  String _formatFullTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

/// Badge para mostrar contador de notificaciones no leídas
class NotificationBadge extends ConsumerWidget {
  final Widget child;
  final bool showZero;

  const NotificationBadge({
    super.key,
    required this.child,
    this.showZero = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsProvider);
    final count = notificationsState.unreadCount;

    if (count == 0 && !showZero) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -8,
          top: -8,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            constraints: const BoxConstraints(
              minWidth: 20,
              minHeight: 20,
            ),
            child: Text(
              count > 99 ? '99+' : count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
