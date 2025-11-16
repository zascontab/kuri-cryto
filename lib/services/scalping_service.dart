import 'dart:developer' as developer;
import 'api_client.dart';
import 'api_exception.dart';

/// System Status Model
class SystemStatus {
  final bool running;
  final String uptime;
  final int pairsCount;
  final int activeStrategies;
  final String healthStatus;
  final List<String> errors;

  SystemStatus({
    required this.running,
    required this.uptime,
    required this.pairsCount,
    required this.activeStrategies,
    required this.healthStatus,
    required this.errors,
  });

  factory SystemStatus.fromJson(Map<String, dynamic> json) {
    return SystemStatus(
      running: json['running'] ?? false,
      uptime: json['uptime'] ?? '',
      pairsCount: json['pairs_count'] ?? 0,
      activeStrategies: json['active_strategies'] ?? 0,
      healthStatus: json['health_status'] ?? 'unknown',
      errors: List<String>.from(json['errors'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'running': running,
      'uptime': uptime,
      'pairs_count': pairsCount,
      'active_strategies': activeStrategies,
      'health_status': healthStatus,
      'errors': errors,
    };
  }
}

/// Metrics Model
class Metrics {
  final int totalTrades;
  final double winRate;
  final double totalPnl;
  final double dailyPnl;
  final double avgLatencyMs;
  final int activePositions;

  Metrics({
    required this.totalTrades,
    required this.winRate,
    required this.totalPnl,
    required this.dailyPnl,
    required this.avgLatencyMs,
    required this.activePositions,
  });

  factory Metrics.fromJson(Map<String, dynamic> json) {
    return Metrics(
      totalTrades: json['total_trades'] ?? 0,
      winRate: (json['win_rate'] ?? 0).toDouble(),
      totalPnl: (json['total_pnl'] ?? 0).toDouble(),
      dailyPnl: (json['daily_pnl'] ?? 0).toDouble(),
      avgLatencyMs: (json['avg_latency_ms'] ?? 0).toDouble(),
      activePositions: json['active_positions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_trades': totalTrades,
      'win_rate': winRate,
      'total_pnl': totalPnl,
      'daily_pnl': dailyPnl,
      'avg_latency_ms': avgLatencyMs,
      'active_positions': activePositions,
    };
  }
}

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

/// Scalping Service
///
/// Handles system control and monitoring operations:
/// - System status and health
/// - Metrics retrieval
/// - Engine start/stop
/// - Trading pair management
class ScalpingService {
  final ApiClient _apiClient;
  static const String _basePath = '/scalping';

  ScalpingService(this._apiClient);

  /// Get current system status
  ///
  /// Returns system status including running state, uptime,
  /// active pairs, strategies, and health information.
  ///
  /// Example:
  /// ```dart
  /// final status = await scalpingService.getStatus();
  /// print('Engine running: ${status.running}');
  /// ```
  Future<SystemStatus> getStatus() async {
    try {
      developer.log('Fetching system status...', name: 'ScalpingService');

      final response = await _apiClient.get<Map<String, dynamic>>('$_basePath/status');

      if (response['success'] == true && response['data'] != null) {
        final status = SystemStatus.fromJson(response['data']);
        developer.log('System status retrieved successfully', name: 'ScalpingService');
        return status;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log('Error getting status: $e', name: 'ScalpingService', error: e);
      rethrow;
    }
  }

  /// Get system metrics
  ///
  /// Returns trading metrics including total trades, win rate,
  /// P&L, latency, and active positions.
  ///
  /// Example:
  /// ```dart
  /// final metrics = await scalpingService.getMetrics();
  /// print('Win Rate: ${metrics.winRate}%');
  /// ```
  Future<Metrics> getMetrics() async {
    try {
      developer.log('Fetching system metrics...', name: 'ScalpingService');

      final response = await _apiClient.get<Map<String, dynamic>>('$_basePath/metrics');

      if (response['success'] == true && response['data'] != null) {
        final metrics = Metrics.fromJson(response['data']);
        developer.log('Metrics retrieved successfully', name: 'ScalpingService');
        return metrics;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log('Error getting metrics: $e', name: 'ScalpingService', error: e);
      rethrow;
    }
  }

  /// Get health status
  ///
  /// Returns detailed health check information including
  /// status, uptime, errors, and timestamp.
  ///
  /// Example:
  /// ```dart
  /// final health = await scalpingService.getHealth();
  /// if (health.status == 'healthy') {
  ///   print('System is healthy');
  /// }
  /// ```
  Future<HealthStatus> getHealth() async {
    try {
      developer.log('Fetching health status...', name: 'ScalpingService');

      final response = await _apiClient.get<Map<String, dynamic>>('$_basePath/health');

      if (response['success'] == true && response['data'] != null) {
        final health = HealthStatus.fromJson(response['data']);
        developer.log('Health status retrieved successfully', name: 'ScalpingService');
        return health;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log('Error getting health: $e', name: 'ScalpingService', error: e);
      rethrow;
    }
  }

  /// Start the scalping engine
  ///
  /// Starts the scalping engine and all active strategies.
  /// Returns true if successful, throws exception otherwise.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final success = await scalpingService.startEngine();
  ///   if (success) {
  ///     print('Engine started successfully');
  ///   }
  /// } catch (e) {
  ///   print('Failed to start engine: $e');
  /// }
  /// ```
  Future<bool> startEngine() async {
    try {
      developer.log('Starting scalping engine...', name: 'ScalpingService');

      final response = await _apiClient.post<Map<String, dynamic>>('$_basePath/start');

      if (response['success'] == true) {
        developer.log('Engine started successfully', name: 'ScalpingService');
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to start engine',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error starting engine: $e', name: 'ScalpingService', error: e);
      rethrow;
    }
  }

  /// Stop the scalping engine
  ///
  /// Stops the scalping engine and all running strategies.
  /// Returns true if successful, throws exception otherwise.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final success = await scalpingService.stopEngine();
  ///   if (success) {
  ///     print('Engine stopped successfully');
  ///   }
  /// } catch (e) {
  ///   print('Failed to stop engine: $e');
  /// }
  /// ```
  Future<bool> stopEngine() async {
    try {
      developer.log('Stopping scalping engine...', name: 'ScalpingService');

      final response = await _apiClient.post<Map<String, dynamic>>('$_basePath/stop');

      if (response['success'] == true) {
        developer.log('Engine stopped successfully', name: 'ScalpingService');
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to stop engine',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error stopping engine: $e', name: 'ScalpingService', error: e);
      rethrow;
    }
  }

  /// Add a trading pair
  ///
  /// Adds a new trading pair to the scalping engine.
  ///
  /// Parameters:
  /// - [exchange]: Exchange name (e.g., 'kucoin')
  /// - [pair]: Trading pair (e.g., 'DOGE-USDT')
  ///
  /// Example:
  /// ```dart
  /// await scalpingService.addPair('kucoin', 'DOGE-USDT');
  /// ```
  Future<bool> addPair(String exchange, String pair) async {
    try {
      developer.log('Adding trading pair: $exchange/$pair', name: 'ScalpingService');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_basePath/pairs/add',
        data: {
          'exchange': exchange,
          'pair': pair,
        },
      );

      if (response['success'] == true) {
        developer.log('Pair added successfully', name: 'ScalpingService');
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to add pair',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error adding pair: $e', name: 'ScalpingService', error: e);
      rethrow;
    }
  }

  /// Remove a trading pair
  ///
  /// Removes a trading pair from the scalping engine.
  ///
  /// Parameters:
  /// - [exchange]: Exchange name (e.g., 'kucoin')
  /// - [pair]: Trading pair (e.g., 'DOGE-USDT')
  ///
  /// Example:
  /// ```dart
  /// await scalpingService.removePair('kucoin', 'DOGE-USDT');
  /// ```
  Future<bool> removePair(String exchange, String pair) async {
    try {
      developer.log('Removing trading pair: $exchange/$pair', name: 'ScalpingService');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_basePath/pairs/remove',
        data: {
          'exchange': exchange,
          'pair': pair,
        },
      );

      if (response['success'] == true) {
        developer.log('Pair removed successfully', name: 'ScalpingService');
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to remove pair',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error removing pair: $e', name: 'ScalpingService', error: e);
      rethrow;
    }
  }
}
