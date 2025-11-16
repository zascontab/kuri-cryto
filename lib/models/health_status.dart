/// Health Status Model
class HealthStatus {
  final String status;
  final bool running;
  final String uptime;
  final List<String> errors;
  final DateTime timestamp;

  HealthStatus({
    required this.status,
    required this.running,
    required this.uptime,
    required this.errors,
    required this.timestamp,
  });

  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    return HealthStatus(
      status: json['status'] ?? 'unknown',
      running: json['running'] ?? false,
      uptime: json['uptime'] ?? '',
      errors: List<String>.from(json['errors'] ?? []),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'running': running,
      'uptime': uptime,
      'errors': errors,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
