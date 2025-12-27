/// Bot status model
///
/// Represents the current status of the AI trading bot
class BotStatus {
  final bool aiEnabled;
  final String status; // 'running', 'stopped', 'error', 'initializing'
  final bool isRunning;
  final DateTime? lastUpdate;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  const BotStatus({
    required this.aiEnabled,
    required this.status,
    required this.isRunning,
    this.lastUpdate,
    this.errorMessage,
    this.metadata,
  });

  factory BotStatus.fromJson(Map<String, dynamic> json) {
    return BotStatus(
      aiEnabled: json['ai_enabled'] as bool? ?? false,
      status: json['status'] as String? ?? 'stopped',
      isRunning: json['is_running'] as bool? ?? false,
      lastUpdate: json['last_update'] != null
          ? DateTime.parse(json['last_update'] as String)
          : null,
      errorMessage: json['error_message'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ai_enabled': aiEnabled,
      'status': status,
      'is_running': isRunning,
      if (lastUpdate != null) 'last_update': lastUpdate!.toIso8601String(),
      if (errorMessage != null) 'error_message': errorMessage,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Crea una copia con campos modificados
  BotStatus copyWith({
    bool? aiEnabled,
    String? status,
    bool? isRunning,
    DateTime? lastUpdate,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    return BotStatus(
      aiEnabled: aiEnabled ?? this.aiEnabled,
      status: status ?? this.status,
      isRunning: isRunning ?? this.isRunning,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helpers

  /// Verifica si el bot está en estado saludable
  bool get isHealthy => aiEnabled && isRunning && status == 'running';

  /// Verifica si el bot está detenido
  bool get isStopped => status == 'stopped' || !isRunning;

  /// Verifica si el bot tiene un error
  bool get hasError => status == 'error' || errorMessage != null;

  /// Verifica si el bot está inicializando
  bool get isInitializing => status == 'initializing';

  /// Obtiene el color de estado para la UI
  String get statusColor {
    if (hasError) return '#EF4444'; // Red
    if (isHealthy) return '#10B981'; // Green
    if (isInitializing) return '#F59E0B'; // Orange
    return '#6B7280'; // Gray
  }

  /// Obtiene el icono de estado para la UI
  String get statusIcon {
    if (hasError) return 'error';
    if (isHealthy) return 'check_circle';
    if (isInitializing) return 'hourglass_empty';
    return 'stop_circle';
  }

  @override
  String toString() {
    return 'BotStatus(aiEnabled: $aiEnabled, status: $status, isRunning: $isRunning)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BotStatus &&
        other.aiEnabled == aiEnabled &&
        other.status == status &&
        other.isRunning == isRunning;
  }

  @override
  int get hashCode {
    return aiEnabled.hashCode ^ status.hashCode ^ isRunning.hashCode;
  }
}
