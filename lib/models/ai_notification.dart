/// Modelo para notificaciones con explicaciones de IA
///
/// Representa una notificación generada por el sistema de trading
/// con análisis y explicaciones proporcionadas por IA
class AINotification {
  final String id;
  final String type; // 'trade_executed', 'alert', 'warning'
  final String symbol;
  final String action; // 'BUY', 'SELL', 'HOLD'
  final double price;
  final String llmExplanation;
  final String marketAnalysis;
  final String riskAssessment;
  final DateTime timestamp;
  final bool isRead;
  final String actionColorHex; // '#10B981' for buy, '#EF4444' for sell

  const AINotification({
    required this.id,
    required this.type,
    required this.symbol,
    required this.action,
    required this.price,
    required this.llmExplanation,
    required this.marketAnalysis,
    required this.riskAssessment,
    required this.timestamp,
    this.isRead = false,
    required this.actionColorHex,
  });

  /// Crea una instancia desde JSON
  factory AINotification.fromJson(Map<String, dynamic> json) {
    return AINotification(
      id: json['id'] as String,
      type: json['type'] as String,
      symbol: json['symbol'] as String,
      action: json['action'] as String,
      price: (json['price'] as num).toDouble(),
      llmExplanation: json['llm_explanation'] as String,
      marketAnalysis: json['market_analysis'] as String,
      riskAssessment: json['risk_assessment'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['is_read'] as bool? ?? false,
      actionColorHex: json['action_color_hex'] as String,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'symbol': symbol,
      'action': action,
      'price': price,
      'llm_explanation': llmExplanation,
      'market_analysis': marketAnalysis,
      'risk_assessment': riskAssessment,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'action_color_hex': actionColorHex,
    };
  }

  /// Crea una copia con campos modificados
  AINotification copyWith({
    String? id,
    String? type,
    String? symbol,
    String? action,
    double? price,
    String? llmExplanation,
    String? marketAnalysis,
    String? riskAssessment,
    DateTime? timestamp,
    bool? isRead,
    String? actionColorHex,
  }) {
    return AINotification(
      id: id ?? this.id,
      type: type ?? this.type,
      symbol: symbol ?? this.symbol,
      action: action ?? this.action,
      price: price ?? this.price,
      llmExplanation: llmExplanation ?? this.llmExplanation,
      marketAnalysis: marketAnalysis ?? this.marketAnalysis,
      riskAssessment: riskAssessment ?? this.riskAssessment,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      actionColorHex: actionColorHex ?? this.actionColorHex,
    );
  }

  // Helpers

  /// Verifica si es una notificación de trade ejecutado
  bool get isTradeExecuted => type == 'trade_executed';

  /// Verifica si es una alerta
  bool get isAlert => type == 'alert';

  /// Verifica si es una advertencia
  bool get isWarning => type == 'warning';

  /// Verifica si la acción es compra
  bool get isBuy => action.toUpperCase() == 'BUY';

  /// Verifica si la acción es venta
  bool get isSell => action.toUpperCase() == 'SELL';

  /// Verifica si la acción es mantener
  bool get isHold => action.toUpperCase() == 'HOLD';

  /// Obtiene el tiempo transcurrido en formato legible
  String get timeAgoFormatted {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Hace ${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return 'Hace ${difference.inDays}d';
    }
  }

  @override
  String toString() {
    return 'AINotification(id: $id, type: $type, symbol: $symbol, action: $action, price: $price, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AINotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
