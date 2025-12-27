/// System status model
///
/// Represents the current state and health of the trading system
class SystemStatus {
  /// Whether the trading engine is running
  final bool running;

  /// System uptime as a human-readable string (e.g., '2h30m15s')
  final String uptime;

  /// Number of trading pairs being monitored
  final int pairsCount;

  /// Number of active strategies
  final int activeStrategies;

  /// Overall health status: 'healthy', 'degraded', 'unhealthy'
  final String healthStatus;

  /// List of current errors or issues
  final List<String> errors;

  /// Optional timestamp when status was generated
  final DateTime? timestamp;

  const SystemStatus({
    this.running = false,
    this.uptime = '0s',
    this.pairsCount = 0,
    this.activeStrategies = 0,
    this.healthStatus = 'unknown',
    this.errors = const [],
    this.timestamp,
  });

  /// Check if system is healthy
  bool get isHealthy => healthStatus == 'healthy' && errors.isEmpty;

  /// Check if system has errors
  bool get hasErrors => errors.isNotEmpty;

  /// Check if system is running properly
  bool get isOperational => running && isHealthy;

  /// Get uptime in seconds (approximate parsing)
  int get uptimeSeconds {
    try {
      int seconds = 0;
      final parts = uptime.toLowerCase();

      // Parse hours
      final hourMatch = RegExp(r'(\d+)h').firstMatch(parts);
      if (hourMatch != null) {
        seconds += int.parse(hourMatch.group(1)!) * 3600;
      }

      // Parse minutes
      final minMatch = RegExp(r'(\d+)m').firstMatch(parts);
      if (minMatch != null) {
        seconds += int.parse(minMatch.group(1)!) * 60;
      }

      // Parse seconds
      final secMatch = RegExp(r'(\d+)s').firstMatch(parts);
      if (secMatch != null) {
        seconds += int.parse(secMatch.group(1)!);
      }

      return seconds;
    } catch (e) {
      return 0;
    }
  }

  /// Get formatted uptime as Duration
  Duration get uptimeDuration => Duration(seconds: uptimeSeconds);

  /// Create SystemStatus from JSON
  factory SystemStatus.fromJson(Map<String, dynamic> json) {
    try {
      // Parse errors list
      List<String> errorsList = [];
      if (json['errors'] != null) {
        if (json['errors'] is List) {
          errorsList = (json['errors'] as List)
              .map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
        }
      }

      return SystemStatus(
        running: json['running'] == true,
        uptime: json['uptime']?.toString() ?? '0s',
        pairsCount: _parseInt(json['pairs_count']),
        activeStrategies: _parseInt(json['active_strategies']),
        healthStatus: json['health_status']?.toString() ?? 'unknown',
        errors: errorsList,
        timestamp: json['timestamp'] != null
            ? _parseDateTime(json['timestamp'])
            : null,
      );
    } catch (e) {
      throw FormatException('Failed to parse SystemStatus from JSON: $e');
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'running': running,
      'uptime': uptime,
      'pairs_count': pairsCount,
      'active_strategies': activeStrategies,
      'health_status': healthStatus,
      'errors': errors,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  SystemStatus copyWith({
    bool? running,
    String? uptime,
    int? pairsCount,
    int? activeStrategies,
    String? healthStatus,
    List<String>? errors,
    DateTime? timestamp,
  }) {
    return SystemStatus(
      running: running ?? this.running,
      uptime: uptime ?? this.uptime,
      pairsCount: pairsCount ?? this.pairsCount,
      activeStrategies: activeStrategies ?? this.activeStrategies,
      healthStatus: healthStatus ?? this.healthStatus,
      errors: errors ?? this.errors,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SystemStatus &&
      other.running == running &&
      other.uptime == uptime &&
      other.pairsCount == pairsCount &&
      other.activeStrategies == activeStrategies &&
      other.healthStatus == healthStatus &&
      _listEquals(other.errors, errors) &&
      other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      running,
      uptime,
      pairsCount,
      activeStrategies,
      healthStatus,
      Object.hashAll(errors),
      timestamp,
    );
  }

  @override
  String toString() {
    return 'SystemStatus('
        'running: $running, '
        'uptime: $uptime, '
        'pairs: $pairsCount, '
        'strategies: $activeStrategies, '
        'health: $healthStatus, '
        'errors: ${errors.length}'
        ')';
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
