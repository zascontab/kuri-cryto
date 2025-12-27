import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_notification.dart';
import '../services/logging_service.dart';

/// Provider para notificaciones de IA
///
/// Gestiona el estado de las notificaciones generadas por el sistema
final aINotificationsNotifierProvider = StateNotifierProvider<
    AINotificationsNotifier, AsyncValue<List<AINotification>>>(
  (ref) => AINotificationsNotifier(),
);

/// Notifier para gestionar notificaciones
class AINotificationsNotifier
    extends StateNotifier<AsyncValue<List<AINotification>>> {
  AINotificationsNotifier() : super(const AsyncValue.loading()) {
    _loadNotifications();
  }

  /// Carga las notificaciones desde el backend
  Future<void> _loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      // For now, return empty notifications until AI service is properly integrated
      final notifications = <AINotification>[];
      state = AsyncValue.data(notifications);
    } catch (error, stackTrace) {
      LoggingService.instance.error(
        'Error loading AI notifications',
        tag: 'AINotificationsProvider',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresca las notificaciones
  Future<void> refresh() async {
    await _loadNotifications();
  }

  /// Marca una notificación como leída
  Future<void> markAsRead(String notificationId) async {
    try {
      // Update local state immediately for better UX
      state.whenData((notifications) {
        final updatedNotifications = notifications.map((n) {
          if (n.id == notificationId) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();
        state = AsyncValue.data(updatedNotifications);
      });

      // TODO: Send to backend when AI service endpoints are available
      // await aiService.markNotificationAsRead(notificationId);
    } catch (error, stackTrace) {
      LoggingService.instance.error(
        'Error marking notification as read',
        tag: 'AINotificationsProvider',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Marca todas las notificaciones como leídas
  Future<void> markAllAsRead() async {
    try {
      // Update local state immediately for better UX
      state.whenData((notifications) {
        final updatedNotifications = notifications.map((n) {
          return n.copyWith(isRead: true);
        }).toList();
        state = AsyncValue.data(updatedNotifications);
      });

      // TODO: Send to backend when AI service endpoints are available
      // await aiService.markAllNotificationsAsRead();
    } catch (error, stackTrace) {
      LoggingService.instance.error(
        'Error marking all notifications as read',
        tag: 'AINotificationsProvider',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Obtiene el conteo de notificaciones no leídas
  int get unreadCount {
    return state.maybeWhen(
      data: (notifications) => notifications.where((n) => !n.isRead).length,
      orElse: () => 0,
    );
  }
}
