import 'dart:developer' as developer;
import 'api_client.dart';
import 'api_exception.dart';
import '../models/system_status.dart';
import '../models/metrics.dart';
import '../models/health_status.dart';

/// Scalping Service
///
/// Handles system control and monitoring operations:
/// - System status and health
/// - Metrics retrieval
/// - Engine start/stop
/// - Trading pair management
class ScalpingService {
  final ApiClient _apiClient;
  static const String _basePath = '';

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

      final response = await _apiClient.get<Map<String, dynamic>>('/status');

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

      final response = await _apiClient.get<Map<String, dynamic>>('/metrics');

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

      final response = await _apiClient.get<Map<String, dynamic>>('/health');

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

      final response = await _apiClient.post<Map<String, dynamic>>('/start');

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

      final response = await _apiClient.post<Map<String, dynamic>>('/stop');

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
        '/pairs/add',
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
        '/pairs/remove',
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

  /// Get active trading pairs
  ///
  /// Returns a list of currently active trading pairs being monitored
  /// by the scalping engine.
  ///
  /// Example:
  /// ```dart
  /// final pairs = await scalpingService.getActivePairs();
  /// for (var pair in pairs) {
  ///   print('${pair['exchange']}/${pair['symbol']}');
  /// }
  /// ```
  Future<List<Map<String, dynamic>>> getActivePairs() async {
    try {
      developer.log('Fetching active trading pairs...', name: 'ScalpingService');

      final response = await _apiClient.get<Map<String, dynamic>>('/pairs/active');

      if (response['success'] == true && response['data'] != null) {
        final pairs = (response['data'] as List)
            .map((pair) => pair as Map<String, dynamic>)
            .toList();
        developer.log('Active pairs retrieved: ${pairs.length}', name: 'ScalpingService');
        return pairs;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log('Error getting active pairs: $e', name: 'ScalpingService', error: e);
      rethrow;
    }
  }

  /// Get available trading pairs for an exchange
  ///
  /// Returns a list of available trading pairs that can be added
  /// for the specified exchange.
  ///
  /// Parameters:
  /// - [exchange]: Exchange name (e.g., 'kucoin', 'binance')
  ///
  /// Example:
  /// ```dart
  /// final pairs = await scalpingService.getAvailablePairs('kucoin');
  /// for (var pair in pairs) {
  ///   print(pair['symbol']);
  /// }
  /// ```
  Future<List<Map<String, dynamic>>> getAvailablePairs(String exchange) async {
    try {
      developer.log('Fetching available pairs for $exchange...', name: 'ScalpingService');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/pairs/available',
        queryParameters: {'exchange': exchange},
      );

      if (response['success'] == true && response['data'] != null) {
        final pairs = (response['data'] as List)
            .map((pair) => pair as Map<String, dynamic>)
            .toList();
        developer.log('Available pairs retrieved: ${pairs.length}', name: 'ScalpingService');
        return pairs;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log('Error getting available pairs: $e', name: 'ScalpingService', error: e);
      rethrow;
    }
  }
}
