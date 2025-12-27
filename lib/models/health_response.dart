/// Health check response model
///
/// Contains server health status and connectivity information
class HealthResponse {
  final String status; // 'healthy', 'degraded', 'unhealthy', 'ok'
  final bool gctConnected; // GoCryptoTrader connection status
  final int toolsCount; // Number of available MCP tools
  final int uptime; // Server uptime in seconds
  final String version; // Server version
  final DateTime timestamp;
  final int errorCount; // Number of errors
  final int requestCount; // Number of requests processed
  final Map<String, dynamic>?
      details; // Additional health details (sandbox, etc.)

  const HealthResponse({
    required this.status,
    required this.gctConnected,
    required this.toolsCount,
    required this.uptime,
    required this.version,
    required this.timestamp,
    this.errorCount = 0,
    this.requestCount = 0,
    this.details,
  });

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(
      status: json['status'] as String? ?? 'unknown',
      gctConnected: json['gct_connected'] as bool? ?? false,
      toolsCount: json['tools_count'] as int? ?? 0,
      uptime: _parseUptime(json['uptime']),
      version: json['version'] as String? ?? 'unknown',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      errorCount: json['error_count'] as int? ?? 0,
      requestCount: json['request_count'] as int? ?? 0,
      details: _extractDetails(json),
    );
  }

  /// Extrae detalles adicionales del JSON (sandbox, etc.)
  static Map<String, dynamic>? _extractDetails(Map<String, dynamic> json) {
    final details = <String, dynamic>{};

    // Incluir campos adicionales que no son parte del modelo principal
    if (json['sandbox'] != null) {
      details['sandbox'] = json['sandbox'];
    }

    return details.isNotEmpty ? details : null;
  }

  /// Parsea el uptime que puede venir como int (segundos) o String (con unidades)
  static int _parseUptime(dynamic uptime) {
    if (uptime == null) return 0;

    if (uptime is int) {
      return uptime;
    }

    if (uptime is String) {
      // Parsear strings como "1.467µs", "5m", "2h", etc.
      final uptimeStr = uptime.toLowerCase();

      // Extraer el número
      final numberMatch = RegExp(r'[\d.]+').firstMatch(uptimeStr);
      if (numberMatch == null) return 0;

      final number = double.tryParse(numberMatch.group(0)!) ?? 0.0;

      // Convertir a segundos basado en la unidad
      if (uptimeStr.contains('µs') || uptimeStr.contains('us')) {
        return (number / 1000000).round(); // microsegundos a segundos
      } else if (uptimeStr.contains('ms')) {
        return (number / 1000).round(); // milisegundos a segundos
      } else if (uptimeStr.contains('s') && !uptimeStr.contains('m')) {
        return number.round(); // segundos
      } else if (uptimeStr.contains('m') && !uptimeStr.contains('h')) {
        return (number * 60).round(); // minutos a segundos
      } else if (uptimeStr.contains('h')) {
        return (number * 3600).round(); // horas a segundos
      } else if (uptimeStr.contains('d')) {
        return (number * 86400).round(); // días a segundos
      }

      // Si no tiene unidad, asumir que son segundos
      return number.round();
    }

    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'gct_connected': gctConnected,
      'tools_count': toolsCount,
      'uptime': uptime,
      'version': version,
      'timestamp': timestamp.toIso8601String(),
      'error_count': errorCount,
      'request_count': requestCount,
      if (details != null) ...details!,
    };
  }

  /// Crea una copia con campos modificados
  HealthResponse copyWith({
    String? status,
    bool? gctConnected,
    int? toolsCount,
    int? uptime,
    String? version,
    DateTime? timestamp,
    int? errorCount,
    int? requestCount,
    Map<String, dynamic>? details,
  }) {
    return HealthResponse(
      status: status ?? this.status,
      gctConnected: gctConnected ?? this.gctConnected,
      toolsCount: toolsCount ?? this.toolsCount,
      uptime: uptime ?? this.uptime,
      version: version ?? this.version,
      timestamp: timestamp ?? this.timestamp,
      errorCount: errorCount ?? this.errorCount,
      requestCount: requestCount ?? this.requestCount,
      details: details ?? this.details,
    );
  }

  // Helpers

  /// Verifica si el servidor está saludable
  bool get isHealthy => (status == 'healthy' || status == 'ok') && gctConnected;

  /// Verifica si el servidor está degradado
  bool get isDegraded => status == 'degraded';

  /// Verifica si el servidor no está saludable
  bool get isUnhealthy => status == 'unhealthy' || !gctConnected;

  /// Verifica si hay herramientas disponibles
  bool get hasTools => toolsCount > 0;

  /// Obtiene el uptime en formato legible
  String get uptimeFormatted {
    final duration = Duration(seconds: uptime);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Obtiene el color de estado para la UI
  String get statusColor {
    if (isHealthy) return '#10B981'; // Green
    if (isDegraded) return '#F59E0B'; // Orange
    return '#EF4444'; // Red
  }

  /// Obtiene el icono de estado para la UI
  String get statusIcon {
    if (isHealthy) return 'check_circle';
    if (isDegraded) return 'warning';
    return 'error';
  }

  /// Obtiene un mensaje descriptivo del estado
  String get statusMessage {
    if (isHealthy) {
      return 'All systems operational';
    } else if (isDegraded) {
      return 'Some services degraded';
    } else if (!gctConnected) {
      return 'GoCryptoTrader disconnected';
    } else {
      return 'System unhealthy';
    }
  }

  /// Verifica si el servidor necesita atención
  bool get needsAttention => !isHealthy;

  /// Verifica si hay errores recientes
  bool get hasErrors => errorCount > 0;

  /// Obtiene información de sandbox si está disponible
  Map<String, dynamic>? get sandboxInfo => details?['sandbox'];

  /// Verifica si está en modo sandbox/testnet
  bool get isSandbox =>
      sandboxInfo?['enabled'] == true || sandboxInfo?['testnet_only'] == true;

  @override
  String toString() {
    return 'HealthResponse(status: $status, gctConnected: $gctConnected, toolsCount: $toolsCount, uptime: $uptimeFormatted, errors: $errorCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HealthResponse &&
        other.status == status &&
        other.gctConnected == gctConnected &&
        other.version == version;
  }

  @override
  int get hashCode {
    return status.hashCode ^ gctConnected.hashCode ^ version.hashCode;
  }
}
