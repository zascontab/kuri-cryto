import 'package:flutter/foundation.dart';

/// Modelo para representar una notificación push
class PushNotification {
  final String? id;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;
  final String? imageUrl;
  final String? actionUrl;

  const PushNotification({
    this.id,
    required this.title,
    required this.body,
    this.data,
    required this.timestamp,
    this.isRead = false,
    this.type = NotificationType.general,
    this.imageUrl,
    this.actionUrl,
  });

  /// Crea una notificación desde un mensaje de FCM
  factory PushNotification.fromFCM({
    required String? messageId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    final notificationType = _parseNotificationType(data?['type']);
    
    return PushNotification(
      id: messageId,
      title: title,
      body: body,
      data: data,
      timestamp: DateTime.now(),
      type: notificationType,
      imageUrl: data?['imageUrl'],
      actionUrl: data?['actionUrl'],
    );
  }

  /// Crea una copia con valores modificados
  PushNotification copyWith({
    String? id,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isRead,
    NotificationType? type,
    String? imageUrl,
    String? actionUrl,
  }) {
    return PushNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  /// Convierte a Map para almacenamiento
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type.name,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
    };
  }

  /// Crea desde Map
  factory PushNotification.fromMap(Map<String, dynamic> map) {
    return PushNotification(
      id: map['id'],
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      data: map['data'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'] ?? false,
      type: _parseNotificationType(map['type']),
      imageUrl: map['imageUrl'],
      actionUrl: map['actionUrl'],
    );
  }

  static NotificationType _parseNotificationType(String? typeStr) {
    if (typeStr == null) return NotificationType.general;
    
    try {
      return NotificationType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => NotificationType.general,
      );
    } catch (e) {
      return NotificationType.general;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PushNotification &&
        other.id == id &&
        other.title == title &&
        other.body == body &&
        mapEquals(other.data, data) &&
        other.timestamp == timestamp &&
        other.isRead == isRead &&
        other.type == type &&
        other.imageUrl == imageUrl &&
        other.actionUrl == actionUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      body,
      data,
      timestamp,
      isRead,
      type,
      imageUrl,
      actionUrl,
    );
  }

  @override
  String toString() {
    return 'PushNotification(id: $id, title: $title, body: $body, type: $type, timestamp: $timestamp)';
  }
}

/// Tipos de notificaciones push
enum NotificationType {
  general,
  priceAlert,
  tradeExecution,
  marketUpdate,
  positionUpdate,
  accountUpdate,
  systemAlert,
  promotion,
}

/// Extensión para obtener información sobre el tipo de notificación
extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.general:
        return 'General';
      case NotificationType.priceAlert:
        return 'Alerta de Precio';
      case NotificationType.tradeExecution:
        return 'Ejecución de Trade';
      case NotificationType.marketUpdate:
        return 'Actualización de Mercado';
      case NotificationType.positionUpdate:
        return 'Actualización de Posición';
      case NotificationType.accountUpdate:
        return 'Actualización de Cuenta';
      case NotificationType.systemAlert:
        return 'Alerta del Sistema';
      case NotificationType.promotion:
        return 'Promoción';
    }
  }

  String get icon {
    switch (this) {
      case NotificationType.general:
        return '📢';
      case NotificationType.priceAlert:
        return '💰';
      case NotificationType.tradeExecution:
        return '✅';
      case NotificationType.marketUpdate:
        return '📊';
      case NotificationType.positionUpdate:
        return '📈';
      case NotificationType.accountUpdate:
        return '👤';
      case NotificationType.systemAlert:
        return '⚠️';
      case NotificationType.promotion:
        return '🎁';
    }
  }
}
