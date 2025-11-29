/// Scalping system status model
///
/// Represents the current state of the scalping system according to
/// the backend specification (SCALPING_ENDPOINTS_SPEC.md)
class ScalpingStatus {
  /// System status ('running', 'stopped', etc.)
  final String status;

  /// Whether the system is active
  final bool active;

  /// Total number of bots
  final int totalBots;

  /// Number of active bots
  final int activeBots;

  /// Number of paused bots
  final int pausedBots;

  /// Number of stopped bots
  final int stoppedBots;

  /// Timestamp when status was generated (RFC3339 format)
  final String timestamp;

  const ScalpingStatus({
    required this.status,
    required this.active,
    required this.totalBots,
    required this.activeBots,
    required this.pausedBots,
    required this.stoppedBots,
    required this.timestamp,
  });

  /// Check if system is running
  bool get isRunning => status.toLowerCase() == 'running';

  /// Check if system is stopped
  bool get isStopped => status.toLowerCase() == 'stopped';

  /// Check if system is active
  bool get isActive => active;

  /// Check if there are any active bots
  bool get hasActiveBots => activeBots > 0;

  /// Get timestamp as DateTime
  DateTime get timestampAsDateTime => DateTime.parse(timestamp);

  /// Create ScalpingStatus from JSON
  factory ScalpingStatus.fromJson(Map<String, dynamic> json) {
    return ScalpingStatus(
      status: json['status'] as String,
      active: json['active'] as bool,
      totalBots: json['total_bots'] as int,
      activeBots: json['active_bots'] as int,
      pausedBots: json['paused_bots'] as int,
      stoppedBots: json['stopped_bots'] as int,
      timestamp: json['timestamp'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'active': active,
      'total_bots': totalBots,
      'active_bots': activeBots,
      'paused_bots': pausedBots,
      'stopped_bots': stoppedBots,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return 'ScalpingStatus('
        'status: $status, '
        'active: $active, '
        'totalBots: $totalBots, '
        'activeBots: $activeBots, '
        'pausedBots: $pausedBots, '
        'stoppedBots: $stoppedBots'
        ')';
  }
}
