import 'ai_bot_config.dart';

/// Estado del AI Trading Bot
class AiBotStatus {
  final bool running;
  final bool paused;
  final bool emergencyStop;
  final DateTime? startedAt;
  final DateTime? lastAnalysisAt;
  final int uptimeSeconds;
  final int analysisCount;
  final int executionCount;
  final int errorCount;
  final int consecutiveErrors;
  final double dailyLoss;
  final int dailyTrades;
  final int openPositions;
  final AiBotConfig config;

  const AiBotStatus({
    required this.running,
    required this.paused,
    required this.emergencyStop,
    this.startedAt,
    this.lastAnalysisAt,
    required this.uptimeSeconds,
    required this.analysisCount,
    required this.executionCount,
    required this.errorCount,
    required this.consecutiveErrors,
    required this.dailyLoss,
    required this.dailyTrades,
    required this.openPositions,
    required this.config,
  });

  factory AiBotStatus.fromJson(Map<String, dynamic> json) {
    return AiBotStatus(
      running: json['running'] as bool? ?? false,
      paused: json['paused'] as bool? ?? false,
      emergencyStop: json['emergency_stop'] as bool? ?? false,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      lastAnalysisAt: json['last_analysis_at'] != null
          ? DateTime.parse(json['last_analysis_at'] as String)
          : null,
      uptimeSeconds: json['uptime_seconds'] as int? ?? 0,
      analysisCount: json['analysis_count'] as int? ?? 0,
      executionCount: json['execution_count'] as int? ?? 0,
      errorCount: json['error_count'] as int? ?? 0,
      consecutiveErrors: json['consecutive_errors'] as int? ?? 0,
      dailyLoss: (json['daily_loss'] as num?)?.toDouble() ?? 0.0,
      dailyTrades: json['daily_trades'] as int? ?? 0,
      openPositions: json['open_positions'] as int? ?? 0,
      config:
          AiBotConfig.fromJson(json['config'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'running': running,
      'paused': paused,
      'emergency_stop': emergencyStop,
      'started_at': startedAt?.toIso8601String(),
      'last_analysis_at': lastAnalysisAt?.toIso8601String(),
      'uptime_seconds': uptimeSeconds,
      'analysis_count': analysisCount,
      'execution_count': executionCount,
      'error_count': errorCount,
      'consecutive_errors': consecutiveErrors,
      'daily_loss': dailyLoss,
      'daily_trades': dailyTrades,
      'open_positions': openPositions,
      'config': config.toJson(),
    };
  }

  /// Indica si el bot está activamente operando
  bool get isActive => running && !paused && !emergencyStop;

  /// Indica si hay algún problema
  bool get hasIssues => emergencyStop || consecutiveErrors >= 3;

  /// Porcentaje de la pérdida diaria máxima utilizada
  double get dailyLossPercent {
    if (config.maxDailyLossUsd == 0) return 0.0;
    return (dailyLoss.abs() / config.maxDailyLossUsd) * 100;
  }

  /// Porcentaje de trades diarios utilizados
  double get dailyTradesPercent {
    if (config.maxDailyTrades == 0) return 0.0;
    return (dailyTrades / config.maxDailyTrades) * 100;
  }

  // Additional computed properties

  /// Uptime as Duration
  Duration get uptime => Duration(seconds: uptimeSeconds);

  /// Indicates if the bot is healthy (no consecutive errors)
  bool get isHealthy => consecutiveErrors < 3;

  /// Indicates if daily limits have been reached
  bool get hasReachedDailyLimit {
    return dailyTrades >= config.maxDailyTrades ||
        dailyLoss.abs() >= config.maxDailyLossUsd;
  }

  /// Formatted uptime string (e.g., "2h 30m")
  String get uptimeFormatted {
    final duration = uptime;
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Success rate of executions (percentage)
  double get successRate {
    if (analysisCount == 0) return 0.0;
    final successCount = analysisCount - errorCount;
    return (successCount / analysisCount) * 100;
  }

  /// Execution rate (executions per analysis)
  double get executionRate {
    if (analysisCount == 0) return 0.0;
    return executionCount / analysisCount;
  }

  /// Average daily loss per trade
  double get avgLossPerTrade {
    if (dailyTrades == 0) return 0.0;
    return dailyLoss / dailyTrades;
  }

  /// Status description for UI
  String get statusDescription {
    if (emergencyStop) return 'Emergency Stop Active';
    if (!running) return 'Stopped';
    if (paused) return 'Paused';
    if (hasReachedDailyLimit) return 'Daily Limit Reached';
    if (!isHealthy) return 'Warning: Multiple Errors';
    return 'Running';
  }

  /// Status color indicator
  String get statusColor {
    if (emergencyStop) return 'red';
    if (!running) return 'gray';
    if (paused) return 'orange';
    if (hasReachedDailyLimit) return 'yellow';
    if (!isHealthy) return 'orange';
    return 'green';
  }
}
