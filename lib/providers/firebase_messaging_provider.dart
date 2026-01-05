import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/push_notification.dart';
import '../services/firebase_messaging_service.dart';

/// Provider del servicio de Firebase Messaging
final firebaseMessagingServiceProvider = Provider<FirebaseMessagingService>((ref) {
  return FirebaseMessagingService();
});

/// Provider del estado de inicialización
final fcmInitializationProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(firebaseMessagingServiceProvider);
  try {
    await service.initialize();
    return true;
  } catch (e) {
    Logger().e('Error al inicializar FCM', error: e);
    return false;
  }
});

/// Provider del token FCM actual
final fcmTokenProvider = StreamProvider<String?>((ref) {
  final service = ref.watch(firebaseMessagingServiceProvider);
  
  // Devolver el token actual si existe
  if (service.currentToken != null) {
    return Stream.value(service.currentToken);
  }
  
  // Escuchar cambios de token
  return service.onTokenRefresh;
});

/// Provider del stream de notificaciones
final notificationsStreamProvider = StreamProvider<PushNotification>((ref) {
  final service = ref.watch(firebaseMessagingServiceProvider);
  return service.onNotification;
});

/// Estado de las notificaciones
class NotificationsState {
  final List<PushNotification> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  NotificationsState copyWith({
    List<PushNotification>? notifications,
    bool? isLoading,
    String? error,
    int? unreadCount,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  /// Calcula el contador de no leídas desde la lista
  int get calculatedUnreadCount {
    return notifications.where((n) => !n.isRead).length;
  }
}

/// Notifier para gestionar el estado de las notificaciones
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier(this._logger) : super(const NotificationsState());

  final Logger _logger;
  final List<PushNotification> _allNotifications = [];

  /// Agrega una nueva notificación
  void addNotification(PushNotification notification) {
    _allNotifications.insert(0, notification);
    
    // Limitar a las últimas 100 notificaciones
    if (_allNotifications.length > 100) {
      _allNotifications.removeLast();
    }

    _updateState();
    _logger.i('Notificación agregada: ${notification.title}');
  }

  /// Marca una notificación como leída
  void markAsRead(String notificationId) {
    final index = _allNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _allNotifications[index] = _allNotifications[index].copyWith(isRead: true);
      _updateState();
      _logger.d('Notificación marcada como leída: $notificationId');
    }
  }

  /// Marca todas las notificaciones como leídas
  void markAllAsRead() {
    for (var i = 0; i < _allNotifications.length; i++) {
      if (!_allNotifications[i].isRead) {
        _allNotifications[i] = _allNotifications[i].copyWith(isRead: true);
      }
    }
    _updateState();
    _logger.d('Todas las notificaciones marcadas como leídas');
  }

  /// Elimina una notificación
  void removeNotification(String notificationId) {
    _allNotifications.removeWhere((n) => n.id == notificationId);
    _updateState();
    _logger.d('Notificación eliminada: $notificationId');
  }

  /// Elimina todas las notificaciones
  void clearAll() {
    _allNotifications.clear();
    _updateState();
    _logger.d('Todas las notificaciones eliminadas');
  }

  /// Filtra notificaciones por tipo
  List<PushNotification> getByType(NotificationType type) {
    return _allNotifications.where((n) => n.type == type).toList();
  }

  /// Obtiene las notificaciones no leídas
  List<PushNotification> getUnread() {
    return _allNotifications.where((n) => !n.isRead).toList();
  }

  /// Actualiza el estado
  void _updateState() {
    state = state.copyWith(
      notifications: List.from(_allNotifications),
      unreadCount: _allNotifications.where((n) => !n.isRead).length,
    );
  }

  /// Establece un error
  void setError(String error) {
    state = state.copyWith(error: error);
    _logger.e('Error en notificaciones: $error');
  }

  /// Limpia el error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider del notifier de notificaciones
final notificationsProvider = StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final notifier = NotificationsNotifier(Logger());
  
  // Escuchar el stream de notificaciones
  ref.listen(notificationsStreamProvider, (previous, next) {
    next.whenData((notification) {
      notifier.addNotification(notification);
    });
  });
  
  return notifier;
});

/// Provider para verificar si las notificaciones están habilitadas
final notificationsEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(firebaseMessagingServiceProvider);
  return await service.areNotificationsEnabled();
});

/// Provider para topics suscritos
class SubscribedTopicsNotifier extends StateNotifier<Set<String>> {
  SubscribedTopicsNotifier(this._service) : super({});

  final FirebaseMessagingService _service;
  final Logger _logger = Logger();

  /// Suscribirse a un topic
  Future<void> subscribe(String topic) async {
    try {
      await _service.subscribeToTopic(topic);
      state = {...state, topic};
      _logger.i('Suscrito al topic: $topic');
    } catch (e) {
      _logger.e('Error al suscribirse al topic', error: e);
      rethrow;
    }
  }

  /// Desuscribirse de un topic
  Future<void> unsubscribe(String topic) async {
    try {
      await _service.unsubscribeFromTopic(topic);
      state = state.where((t) => t != topic).toSet();
      _logger.i('Desuscrito del topic: $topic');
    } catch (e) {
      _logger.e('Error al desuscribirse del topic', error: e);
      rethrow;
    }
  }

  /// Verifica si está suscrito a un topic
  bool isSubscribed(String topic) {
    return state.contains(topic);
  }
}

/// Provider de topics suscritos
final subscribedTopicsProvider = StateNotifierProvider<SubscribedTopicsNotifier, Set<String>>((ref) {
  final service = ref.watch(firebaseMessagingServiceProvider);
  return SubscribedTopicsNotifier(service);
});
