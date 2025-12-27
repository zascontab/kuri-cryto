/// Response models for bot actions (start/stop)
///
/// Simple response models for bot control operations
library;

/// Response when starting the bot
class BotStartResponse {
  final bool success;
  final String message;
  final String? status;
  final DateTime timestamp;

  const BotStartResponse({
    required this.success,
    required this.message,
    this.status,
    required this.timestamp,
  });

  factory BotStartResponse.fromJson(Map<String, dynamic> json) {
    return BotStartResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      status: json['status'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (status != null) 'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isRunning => status == 'running';
}

/// Response when stopping the bot
class BotStopResponse {
  final bool success;
  final String message;
  final String? status;
  final DateTime timestamp;

  const BotStopResponse({
    required this.success,
    required this.message,
    this.status,
    required this.timestamp,
  });

  factory BotStopResponse.fromJson(Map<String, dynamic> json) {
    return BotStopResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      status: json['status'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (status != null) 'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isStopped => status == 'stopped';
}

/// Generic bot action response
class BotActionResponse {
  final bool success;
  final String message;
  final String action; // 'start', 'stop', 'config_update'
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  const BotActionResponse({
    required this.success,
    required this.message,
    required this.action,
    this.data,
    required this.timestamp,
  });

  factory BotActionResponse.fromJson(Map<String, dynamic> json) {
    return BotActionResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      action: json['action'] as String? ?? 'unknown',
      data: json['data'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'action': action,
      if (data != null) 'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isStartAction => action == 'start';
  bool get isStopAction => action == 'stop';
  bool get isConfigUpdate => action == 'config_update';
}
