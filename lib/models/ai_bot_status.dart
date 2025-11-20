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
      config: AiBotConfig.fromJson(json['config'] as Map<String, dynamic>? ?? {}),
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
}
