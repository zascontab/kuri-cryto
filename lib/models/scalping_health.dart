/// Scalping system health model
///
/// Represents health status according to the backend specification
/// (SCALPING_ENDPOINTS_SPEC.md)
class ScalpingHealth {
  /// Health status ('healthy', 'degraded', 'unhealthy')
  final String status;

  /// Timestamp when health was checked (RFC3339 format)
  final String timestamp;

  const ScalpingHealth({
    required this.status,
    required this.timestamp,
  });

  /// Check if system is healthy
  bool get isHealthy => status.toLowerCase() == 'healthy';

  /// Check if system is degraded
  bool get isDegraded => status.toLowerCase() == 'degraded';

  /// Check if system is unhealthy
  bool get isUnhealthy => status.toLowerCase() == 'unhealthy';

  /// Get timestamp as DateTime
  DateTime get timestampAsDateTime => DateTime.parse(timestamp);

  /// Create ScalpingHealth from JSON
  factory ScalpingHealth.fromJson(Map<String, dynamic> json) {
    return ScalpingHealth(
      status: json['status'] as String,
      timestamp: json['timestamp'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return 'ScalpingHealth(status: $status, timestamp: $timestamp)';
  }
}
