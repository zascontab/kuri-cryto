import 'dart:developer' as developer;
import '../models/bot_status.dart';
import '../models/bot_config.dart';
import '../models/bot_action_response.dart';
import 'matp_api_client.dart';
import '../exceptions/matp_exceptions.dart';

/// Autonomous Bot Service for bot control and monitoring
///
/// This service provides comprehensive bot management capabilities including:
/// - Bot control (start, stop, pause, emergency stop)
/// - Configuration management
/// - Autonomous mode enable/disable functionality
/// - Performance monitoring and analytics
/// - Real-time status updates
///
/// Features:
/// - Complete bot lifecycle management
/// - Configuration validation and updates
/// - Performance metrics and analytics
/// - Emergency stop functionality
/// - Real-time monitoring
/// - Action logging and audit trail
///
/// Example usage:
/// ```dart
/// final botService = AutonomousBotService(matpClient);
///
/// // Start bot
/// final status = await botService.startBot();
///
/// // Configure bot
/// final config = BotConfig(
///   confidenceThreshold: 0.8,
///   dryRun: false,
///   maxPositions: 5,
/// );
/// await botService.updateBotConfig(config);
///
/// // Enable autonomous mode
/// await botService.enableAutonomousMode(autonomousConfig);
/// ```
class AutonomousBotService {
  final MATPApiClient _matpClient;

  AutonomousBotService(this._matpClient);

  // ============================================================================
  // BOT CONTROL
  // ============================================================================

  /// Start the autonomous trading bot
  ///
  /// Returns: [BotStatus] with current bot state after starting
  Future<BotStatus> startBot() async {
    try {
      developer.log(
        'Starting autonomous bot',
        name: 'AutonomousBotService',
      );

      final response = await _matpClient.post('/api/v1/bot/start');

      return BotStatus.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to start bot - $e',
        name: 'AutonomousBotService',
        error: e,
      );
      rethrow;
    }
  }

  /// Stop the autonomous trading bot
  ///
  /// Returns: [BotStatus] with current bot state after stopping
  Future<BotStatus> stopBot() async {
    try {
      developer.log(
        'Stopping autonomous bot',
        name: 'AutonomousBotService',
      );

      final response = await _matpClient.post('/api/v1/bot/stop');

      return BotStatus.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to stop bot - $e',
        name: 'AutonomousBotService',
        error: e,
      );
      rethrow;
    }
  }

  /// Pause the autonomous trading bot
  ///
  /// Returns: [BotStatus] with current bot state after pausing
  Future<BotStatus> pauseBot() async {
    try {
      developer.log(
        'Pausing autonomous bot',
        name: 'AutonomousBotService',
      );

      final response = await _matpClient.post('/api/v1/bot/pause');

      return BotStatus.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to pause bot - $e',
        name: 'AutonomousBotService',
        error: e,
      );
      rethrow;
    }
  }

  /// Emergency stop - immediately halt all bot operations
  ///
  /// This is a critical operation that stops all trading immediately
  /// and cannot be undone. Use with caution.
  ///
  /// Returns: [BotActionResponse] confirming emergency stop
  Future<BotActionResponse> emergencyStop() async {
    try {
      developer.log(
        'Executing emergency stop',
        name: 'AutonomousBotService',
      );

      final response = await _matpClient.post('/api/v1/bot/emergency-stop');

      return BotActionResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to execute emergency stop - $e',
        name: 'AutonomousBotService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get current bot status
  ///
  /// Returns: [BotStatus] with real-time bot information
  Future<BotStatus> getBotStatus() async {
    try {
      final response = await _matpClient.get('/api/v1/bot/status');

      return BotStatus.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to get bot status - $e',
        name: 'AutonomousBotService',
        error: e,
      );
      rethrow;
    }
  }

  // ============================================================================
  // BOT CONFIGURATION
  // ============================================================================

  /// Get current bot configuration
  ///
  /// Returns: [BotConfig] with current configuration parameters
  Future<BotConfig> getBotConfig() async {
    try {
      final response = await _matpClient.get('/api/v1/bot/config');

      return BotConfig.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to get bot config - $e',
        name: 'AutonomousBotService',
        error: e,
      );
      rethrow;
    }
  }

  /// Update bot configuration
  ///
  /// [config]: New configuration parameters
  ///
  /// Returns: [BotConfig] with updated configuration
  Future<BotConfig> updateBotConfig(BotConfig config) async {
    try {
      developer.log(
        'Updating bot configuration',
        name: 'AutonomousBotService',
      );

      // Validate configuration before sending
      _validateBotConfig(config);

      final response = await _matpClient.put(
        '/api/v1/bot/config',
        data: config.toJson(),
      );

      return BotConfig.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to update bot config - $e',
        name: 'AutonomousBotService',
        error: e,
      );
      rethrow;
    }
  }

  /// Reset bot configuration to defaults
  ///
  /// Returns: [BotConfig] with default configuration
  Future<BotConfig> resetBotConfig() async {
    try {
      developer.log(
        'Resetting bot configuration to defaults',
        name: 'AutonomousBotService',
      );

      final response = await _matpClient.post('/api/v1/bot/config/reset');

      return BotConfig.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to reset bot config - $e',
        name: 'AutonomousBotService',
        error: e,
      );
      rethrow;
    }
  }

  // ============================================================================
  // AUTONOMOUS MODE
  // ============================================================================

  /// Enable autonomous mode with specified configuration
  ///
  /// [config]: Autonomous mode configuration
  ///
  /// Returns: [AutonomousStatus] with autonomous mode information
  Future<AutonomousStatus> enableAutonomousMode(
    AutonomousConfig config,
  ) async {
    try {
      developer.log(
        'Enabling autonomous mode',
        name: 'AutonomousBotService',
      );

      final response = await _matpClient.post(
        '/api/v1/bot/autonomous/enable',
        data: config.toJson(),
      );

      return AutonomousStatus.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to enable autonomous mode - $e',
        name: 'AutonomousBotService',
        error: e,
      );
      rethrow;
    }
  }

  /// Disable autonomous mode
  ///
  /// Returns: [AutonomousStatus] with updated autonomous mode information
  Future<AutonomousStatus> disableAutonomousMode() async {
    try {
      developer.log(
        'Disabling autonomous mode',
        name: 'AutonomousBotService',
      );

      final response = await _matpClient.post('/api/v1/bot/autonomous/disable');

      return AutonomousStatus.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to disable autonomous mode - $e',
        name: 'AutonomousBotService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get autonomous mode status
  ///
  /// Returns: [AutonomousStatus] with current autonomous mode information
  Future<AutonomousStatus> getAutonomousStatus() async {
    try {
      final response = await _matpClient.get('/api/v1/bot/autonomous/status');

      return AutonomousStatus.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to get autonomous status - $e',
        name: 'AutonomousBotService',
        error: e,
      );
      rethrow;
    }
  }

  // ============================================================================
  // PERFORMANCE MONITORING
  // ============================================================================

  /// Get bot performance metrics
  ///
  /// [timeframe]: Performance timeframe ('1h', '24h', '7d', '30d')
  ///
  /// Returns: [BotPerformance] with performance metrics
  Future<BotPerformance> getBotPerformance({String timeframe = '24h'}) async {
    try {
      final response = await _matpClient.get(
        '/api/v1/bot/performance',
        queryParameters: {'timeframe': timeframe},
      );

      return BotPerformance.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to get bot performance - $e',
        name: 'AutonomousBotService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get bot analytics and statistics
  ///
  /// [period]: Analytics period ('day', 'week', 'month')
  ///
  /// Returns: [BotAnalytics] with comprehensive analytics
  Future<BotAnalytics> getBotAnalytics({String period = 'week'}) async {
    try {
      final response = await _matpClient.get(
        '/api/v1/bot/analytics',
        queryParameters: {'period': period},
      );

      return BotAnalytics.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to get bot analytics - $e',
        name: 'AutonomousBotService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get bot action history and logs
  ///
  /// [limit]: Maximum number of actions to return
  /// [offset]: Pagination offset
  /// [actionType]: Optional filter by action type
  ///
  /// Returns: [BotActionHistory] with action logs
  Future<BotActionHistory> getBotActionHistory({
    int limit = 50,
    int offset = 0,
    String? actionType,
  }) async {
    try {
      final queryParams = {
        'limit': limit,
        'offset': offset,
        if (actionType != null) 'action_type': actionType,
      };

      final response = await _matpClient.get(
        '/api/v1/bot/actions/history',
        queryParameters: queryParams,
      );

      return BotActionHistory.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to get bot action history - $e',
        name: 'AutonomousBotService',
        error: e,
      );
      rethrow;
    }
  }

  // ============================================================================
  // REAL-TIME MONITORING
  // ============================================================================

  /// Subscribe to real-time bot status updates
  ///
  /// Returns: Stream of [BotStatusUpdate] events
  Stream<BotStatusUpdate> subscribeToStatusUpdates() async* {
    try {
      developer.log(
        'Subscribing to bot status updates',
        name: 'AutonomousBotService',
      );

      // This would typically connect to a WebSocket stream
      // For now, we'll simulate with periodic polling
      await for (final _ in Stream.periodic(const Duration(seconds: 2))) {
        try {
          final status = await getBotStatus();
          yield BotStatusUpdate(
            type: 'status_update',
            status: status,
            timestamp: DateTime.now(),
          );
        } catch (e) {
          developer.log(
            'Error in bot status update stream - $e',
            name: 'AutonomousBotService',
            error: e,
          );
        }
      }
    } catch (e) {
      developer.log(
        'Failed to subscribe to status updates - $e',
        name: 'AutonomousBotService',
        error: e,
      );
      rethrow;
    }
  }

  /// Subscribe to real-time bot performance updates
  ///
  /// Returns: Stream of [BotPerformanceUpdate] events
  Stream<BotPerformanceUpdate> subscribeToPerformanceUpdates() async* {
    try {
      developer.log(
        'Subscribing to bot performance updates',
        name: 'AutonomousBotService',
      );

      await for (final _ in Stream.periodic(const Duration(seconds: 10))) {
        try {
          final performance = await getBotPerformance();
          yield BotPerformanceUpdate(
            type: 'performance_update',
            performance: performance,
            timestamp: DateTime.now(),
          );
        } catch (e) {
          developer.log(
            'Error in bot performance update stream - $e',
            name: 'AutonomousBotService',
            error: e,
          );
        }
      }
    } catch (e) {
      developer.log(
        'Failed to subscribe to performance updates - $e',
        name: 'AutonomousBotService',
        error: e,
      );
      rethrow;
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Validate bot configuration parameters
  void _validateBotConfig(BotConfig config) {
    if (config.confidenceThreshold < 0.0 || config.confidenceThreshold > 1.0) {
      throw MATPValidationException(
      message:  'Confidence threshold must be between 0.0 and 1.0',
      );
    }

    if (config.maxPositions <= 0) {
      throw MATPValidationException(
      message:  'Max positions must be greater than 0',
      );
    }

    if (config.maxRiskPerTrade < 0.0 || config.maxRiskPerTrade > 1.0) {
      throw MATPValidationException(
      message:  'Max risk per trade must be between 0.0 and 1.0',
      );
    }

    // Additional validation can be added here
  }

  /// Get bot health check
  ///
  /// Returns: [BotHealthCheck] with system health information
  Future<BotHealthCheck> getBotHealthCheck() async {
    try {
      final response = await _matpClient.get('/api/v1/bot/health');

      return BotHealthCheck.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to get bot health check - $e',
        name: 'AutonomousBotService',
        error: e,
      );
      rethrow;
    }
  }
}

// ============================================================================
// REQUEST/RESPONSE MODELS
// ============================================================================

/// Configuration for autonomous mode
class AutonomousConfig {
  final bool enabled;
  final double riskTolerance; // 0.0 - 1.0
  final List<String> allowedSymbols;
  final List<String> strategies;
  final Map<String, dynamic> parameters;

  AutonomousConfig({
    required this.enabled,
    required this.riskTolerance,
    required this.allowedSymbols,
    required this.strategies,
    required this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'risk_tolerance': riskTolerance,
      'allowed_symbols': allowedSymbols,
      'strategies': strategies,
      'parameters': parameters,
    };
  }

  factory AutonomousConfig.fromJson(Map<String, dynamic> json) {
    return AutonomousConfig(
      enabled: json['enabled'] as bool? ?? false,
      riskTolerance: (json['risk_tolerance'] as num?)?.toDouble() ?? 0.5,
      allowedSymbols: (json['allowed_symbols'] as List?)?.cast<String>() ?? [],
      strategies: (json['strategies'] as List?)?.cast<String>() ?? [],
      parameters: json['parameters'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// Autonomous mode status
class AutonomousStatus {
  final bool enabled;
  final DateTime? enabledAt;
  final AutonomousConfig? config;
  final Map<String, dynamic> metrics;

  AutonomousStatus({
    required this.enabled,
    this.enabledAt,
    this.config,
    required this.metrics,
  });

  factory AutonomousStatus.fromJson(Map<String, dynamic> json) {
    return AutonomousStatus(
      enabled: json['enabled'] as bool? ?? false,
      enabledAt: json['enabled_at'] != null
          ? DateTime.parse(json['enabled_at'] as String)
          : null,
      config: json['config'] != null
          ? AutonomousConfig.fromJson(json['config'] as Map<String, dynamic>)
          : null,
      metrics: json['metrics'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      if (enabledAt != null) 'enabled_at': enabledAt!.toIso8601String(),
      if (config != null) 'config': config!.toJson(),
      'metrics': metrics,
    };
  }
}

/// Bot performance metrics
class BotPerformance {
  final double totalPnl;
  final double totalPnlPercent;
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final double winRate;
  final double averageWin;
  final double averageLoss;
  final double profitFactor;
  final double sharpeRatio;
  final double maxDrawdown;
  final DateTime periodStart;
  final DateTime periodEnd;

  BotPerformance({
    required this.totalPnl,
    required this.totalPnlPercent,
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.winRate,
    required this.averageWin,
    required this.averageLoss,
    required this.profitFactor,
    required this.sharpeRatio,
    required this.maxDrawdown,
    required this.periodStart,
    required this.periodEnd,
  });

  factory BotPerformance.fromJson(Map<String, dynamic> json) {
    return BotPerformance(
      totalPnl: (json['total_pnl'] as num?)?.toDouble() ?? 0.0,
      totalPnlPercent: (json['total_pnl_percent'] as num?)?.toDouble() ?? 0.0,
      totalTrades: json['total_trades'] as int? ?? 0,
      winningTrades: json['winning_trades'] as int? ?? 0,
      losingTrades: json['losing_trades'] as int? ?? 0,
      winRate: (json['win_rate'] as num?)?.toDouble() ?? 0.0,
      averageWin: (json['average_win'] as num?)?.toDouble() ?? 0.0,
      averageLoss: (json['average_loss'] as num?)?.toDouble() ?? 0.0,
      profitFactor: (json['profit_factor'] as num?)?.toDouble() ?? 0.0,
      sharpeRatio: (json['sharpe_ratio'] as num?)?.toDouble() ?? 0.0,
      maxDrawdown: (json['max_drawdown'] as num?)?.toDouble() ?? 0.0,
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_pnl': totalPnl,
      'total_pnl_percent': totalPnlPercent,
      'total_trades': totalTrades,
      'winning_trades': winningTrades,
      'losing_trades': losingTrades,
      'win_rate': winRate,
      'average_win': averageWin,
      'average_loss': averageLoss,
      'profit_factor': profitFactor,
      'sharpe_ratio': sharpeRatio,
      'max_drawdown': maxDrawdown,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
    };
  }

  bool get isProfitable => totalPnl > 0;
  bool get hasGoodWinRate => winRate >= 0.5;
  Duration get period => periodEnd.difference(periodStart);
}

/// Bot analytics and statistics
class BotAnalytics {
  final Map<String, double> symbolPerformance;
  final Map<String, double> strategyPerformance;
  final Map<String, int> actionCounts;
  final List<PerformanceDataPoint> performanceHistory;
  final Map<String, dynamic> insights;

  BotAnalytics({
    required this.symbolPerformance,
    required this.strategyPerformance,
    required this.actionCounts,
    required this.performanceHistory,
    required this.insights,
  });

  factory BotAnalytics.fromJson(Map<String, dynamic> json) {
    return BotAnalytics(
      symbolPerformance: (json['symbol_performance'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
          {},
      strategyPerformance:
          (json['strategy_performance'] as Map<String, dynamic>?)
                  ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
              {},
      actionCounts: (json['action_counts'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      performanceHistory: (json['performance_history'] as List?)
              ?.map((e) =>
                  PerformanceDataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      insights: json['insights'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol_performance': symbolPerformance,
      'strategy_performance': strategyPerformance,
      'action_counts': actionCounts,
      'performance_history': performanceHistory.map((e) => e.toJson()).toList(),
      'insights': insights,
    };
  }
}

/// Performance data point for charting
class PerformanceDataPoint {
  final DateTime timestamp;
  final double pnl;
  final double pnlPercent;
  final int trades;

  PerformanceDataPoint({
    required this.timestamp,
    required this.pnl,
    required this.pnlPercent,
    required this.trades,
  });

  factory PerformanceDataPoint.fromJson(Map<String, dynamic> json) {
    return PerformanceDataPoint(
      timestamp: DateTime.parse(json['timestamp'] as String),
      pnl: (json['pnl'] as num).toDouble(),
      pnlPercent: (json['pnl_percent'] as num).toDouble(),
      trades: json['trades'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'pnl': pnl,
      'pnl_percent': pnlPercent,
      'trades': trades,
    };
  }
}

/// Bot action history
class BotActionHistory {
  final List<BotAction> actions;
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  BotActionHistory({
    required this.actions,
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  factory BotActionHistory.fromJson(Map<String, dynamic> json) {
    return BotActionHistory(
      actions: (json['actions'] as List)
          .map((action) => BotAction.fromJson(action as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      hasMore: json['has_more'] as bool,
    );
  }
}

/// Individual bot action
class BotAction {
  final String id;
  final String type; // 'trade', 'config_change', 'start', 'stop', etc.
  final String description;
  final Map<String, dynamic> details;
  final DateTime timestamp;
  final String? result; // 'success', 'failure', 'pending'

  BotAction({
    required this.id,
    required this.type,
    required this.description,
    required this.details,
    required this.timestamp,
    this.result,
  });

  factory BotAction.fromJson(Map<String, dynamic> json) {
    return BotAction(
      id: json['id'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      details: json['details'] as Map<String, dynamic>? ?? {},
      timestamp: DateTime.parse(json['timestamp'] as String),
      result: json['result'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
      if (result != null) 'result': result,
    };
  }

  bool get isSuccessful => result == 'success';
  bool get isFailed => result == 'failure';
  bool get isPending => result == 'pending';
}

/// Real-time bot status update
class BotStatusUpdate {
  final String type;
  final BotStatus status;
  final DateTime timestamp;

  BotStatusUpdate({
    required this.type,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'status': status.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Real-time bot performance update
class BotPerformanceUpdate {
  final String type;
  final BotPerformance performance;
  final DateTime timestamp;

  BotPerformanceUpdate({
    required this.type,
    required this.performance,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'performance': performance.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Bot health check result
class BotHealthCheck {
  final bool healthy;
  final List<String> issues;
  final Map<String, dynamic> systemMetrics;
  final DateTime lastCheck;

  BotHealthCheck({
    required this.healthy,
    required this.issues,
    required this.systemMetrics,
    required this.lastCheck,
  });

  factory BotHealthCheck.fromJson(Map<String, dynamic> json) {
    return BotHealthCheck(
      healthy: json['healthy'] as bool? ?? false,
      issues: (json['issues'] as List?)?.cast<String>() ?? [],
      systemMetrics: json['system_metrics'] as Map<String, dynamic>? ?? {},
      lastCheck: DateTime.parse(json['last_check'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'healthy': healthy,
      'issues': issues,
      'system_metrics': systemMetrics,
      'last_check': lastCheck.toIso8601String(),
    };
  }

  bool get hasIssues => issues.isNotEmpty;
}
