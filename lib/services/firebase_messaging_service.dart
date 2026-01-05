import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../models/push_notification.dart';

/// Handler global para mensajes en background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.messageId}');
}

/// Servicio para gestionar Firebase Cloud Messaging
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final Logger _logger = Logger();

  // Stream controllers para notificaciones
  final _notificationStreamController = StreamController<PushNotification>.broadcast();
  final _tokenStreamController = StreamController<String>.broadcast();

  Stream<PushNotification> get onNotification => _notificationStreamController.stream;
  Stream<String> get onTokenRefresh => _tokenStreamController.stream;

  String? _currentToken;
  bool _isInitialized = false;

  /// Obtiene el token FCM actual
  String? get currentToken => _currentToken;

  /// Verifica si el servicio está inicializado
  bool get isInitialized => _isInitialized;

  /// Inicializa Firebase Messaging
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.i('Firebase Messaging ya está inicializado');
      return;
    }

    try {
      // Solicitar permisos
      await _requestPermission();

      // Configurar handlers de mensajes
      _setupMessageHandlers();

      // Obtener token FCM
      await _getToken();

      // Configurar listener de token refresh
      _setupTokenRefreshListener();

      _isInitialized = true;
      _logger.i('Firebase Messaging inicializado correctamente');
    } catch (e, stackTrace) {
      _logger.e('Error al inicializar Firebase Messaging', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Solicita permisos de notificaciones al usuario
  Future<NotificationSettings> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    _logger.i('Permission status: ${settings.authorizationStatus}');
    return settings;
  }

  /// Configura los handlers de mensajes FCM
  void _setupMessageHandlers() {
    // Mensaje recibido cuando la app está en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Mensaje clickeado cuando la app estaba en background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Verificar si la app fue abierta desde una notificación
    _checkInitialMessage();
  }

  /// Maneja mensajes recibidos cuando la app está en foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    _logger.i('Foreground message: ${message.messageId}');

    final notification = PushNotification.fromFCM(
      messageId: message.messageId,
      title: message.notification?.title ?? 'Notificación',
      body: message.notification?.body ?? '',
      data: message.data,
    );

    // Emitir evento
    _notificationStreamController.add(notification);
  }

  /// Maneja mensajes cuando la app es abierta desde background
  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    _logger.i('Background message opened: ${message.messageId}');

    final notification = PushNotification.fromFCM(
      messageId: message.messageId,
      title: message.notification?.title ?? 'Notificación',
      body: message.notification?.body ?? '',
      data: message.data,
    );

    _notificationStreamController.add(notification);
  }

  /// Verifica si la app fue abierta desde una notificación
  Future<void> _checkInitialMessage() async {
    final message = await _firebaseMessaging.getInitialMessage();
    if (message != null) {
      _handleBackgroundMessage(message);
    }
  }

  /// Obtiene el token FCM
  Future<String?> _getToken() async {
    try {
      _currentToken = await _firebaseMessaging.getToken();
      _logger.i('FCM Token: $_currentToken');
      
      if (_currentToken != null) {
        _tokenStreamController.add(_currentToken!);
      }
      
      return _currentToken;
    } catch (e, stackTrace) {
      _logger.e('Error al obtener token FCM', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Configura el listener de refresh de token
  void _setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _logger.i('Token refreshed: $newToken');
      _currentToken = newToken;
      _tokenStreamController.add(newToken);
    });
  }

  /// Suscribe a un topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      _logger.i('Suscrito al topic: $topic');
    } catch (e, stackTrace) {
      _logger.e('Error al suscribirse al topic $topic', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Desuscribe de un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      _logger.i('Desuscrito del topic: $topic');
    } catch (e, stackTrace) {
      _logger.e('Error al desuscribirse del topic $topic', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Elimina el token FCM
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _currentToken = null;
      _logger.i('Token FCM eliminado');
    } catch (e, stackTrace) {
      _logger.e('Error al eliminar token FCM', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Verifica el estado de los permisos
  Future<bool> areNotificationsEnabled() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
           settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Limpia recursos
  void dispose() {
    _notificationStreamController.close();
    _tokenStreamController.close();
  }
}
