import 'dart:developer' as developer;
import 'api_client.dart';
import 'api_exception.dart';
import '../models/backtest.dart';

/// Backtest Service
///
/// Handles strategy backtesting operations:
/// - Run backtests with historical data
/// - Get backtest results and metrics
/// - List past backtests
/// - Download backtest reports
class BacktestService {
  final ApiClient _apiClient;
  static const String _basePath = '/backtest';

  BacktestService(this._apiClient);

  /// Run a new backtest
  ///
  /// Executes a backtest with the provided configuration and returns
  /// the backtest ID for tracking progress.
  ///
  /// Parameters:
  /// - [config]: Backtest configuration with symbol, strategy, dates, etc.
  ///
  /// Returns backtest ID as String
  ///
  /// Example:
  /// ```dart
  /// final config = BacktestConfig(
  ///   symbol: 'BTCUSDT',
  ///   strategy: 'rsi_scalping',
  ///   startDate: DateTime(2024, 1, 1),
  ///   endDate: DateTime(2024, 1, 31),
  ///   initialCapital: 10000.0,
  /// );
  /// final backtestId = await backtestService.runBacktest(config);
  /// print('Backtest started: $backtestId');
  /// ```
  Future<String> runBacktest(BacktestConfig config) async {
    try {
      developer.log(
        'Starting backtest for ${config.symbol} with ${config.strategy}...',
        name: 'BacktestService',
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_basePath/run',
        data: config.toJson(),
      );

      if (response['success'] == true && response['data'] != null) {
        final backtestId = response['data']['backtest_id'] as String;
        developer.log(
          'Backtest started with ID: $backtestId',
          name: 'BacktestService',
        );
        return backtestId;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to start backtest',
        code: response['code'],
      );
    } catch (e) {
      developer.log(
        'Error starting backtest: $e',
        name: 'BacktestService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get backtest results by ID
  ///
  /// Retrieves complete backtest results including:
  /// - Performance metrics
  /// - Trade history
  /// - Equity curve
  ///
  /// Parameters:
  /// - [backtestId]: The ID of the backtest to retrieve
  ///
  /// Returns [BacktestResult] with all metrics and trades
  ///
  /// Example:
  /// ```dart
  /// final result = await backtestService.getBacktestResults(backtestId);
  /// print('Win Rate: ${result.metrics.winRate}%');
  /// print('Total P&L: \$${result.metrics.totalPnl}');
  /// ```
  Future<BacktestResult> getBacktestResults(String backtestId) async {
    try {
      developer.log(
        'Fetching backtest results for ID: $backtestId',
        name: 'BacktestService',
      );

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_basePath/results/$backtestId',
      );

      if (response['success'] == true && response['data'] != null) {
        final result = BacktestResult.fromJson(response['data']);
        developer.log(
          'Backtest results retrieved successfully',
          name: 'BacktestService',
        );
        return result;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log(
        'Error getting backtest results: $e',
        name: 'BacktestService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get backtest status
  ///
  /// Check the current status of a running backtest
  ///
  /// Parameters:
  /// - [backtestId]: The ID of the backtest to check
  ///
  /// Returns status string: 'running', 'completed', 'failed'
  ///
  /// Example:
  /// ```dart
  /// final status = await backtestService.getBacktestStatus(backtestId);
  /// if (status == 'completed') {
  ///   final result = await backtestService.getBacktestResults(backtestId);
  /// }
  /// ```
  Future<String> getBacktestStatus(String backtestId) async {
    try {
      developer.log(
        'Checking backtest status for ID: $backtestId',
        name: 'BacktestService',
      );

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_basePath/status/$backtestId',
      );

      if (response['success'] == true && response['data'] != null) {
        final status = response['data']['status'] as String;
        developer.log(
          'Backtest status: $status',
          name: 'BacktestService',
        );
        return status;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log(
        'Error getting backtest status: $e',
        name: 'BacktestService',
        error: e,
      );
      rethrow;
    }
  }

  /// List all backtests
  ///
  /// Get a list of all backtests (recent first)
  ///
  /// Parameters:
  /// - [limit]: Maximum number of backtests to return (default: 50)
  ///
  /// Returns list of [BacktestResult]
  ///
  /// Example:
  /// ```dart
  /// final backtests = await backtestService.listBacktests(limit: 10);
  /// for (var backtest in backtests) {
  ///   print('${backtest.config.symbol}: ${backtest.metrics.winRate}%');
  /// }
  /// ```
  Future<List<BacktestResult>> listBacktests({int limit = 50}) async {
    try {
      developer.log(
        'Fetching backtest list...',
        name: 'BacktestService',
      );

      final response = await _apiClient.get<Map<String, dynamic>>(
        _basePath,
        queryParameters: {
          'limit': limit,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> backtestsData = response['data'];
        final backtests = backtestsData
            .map((b) => BacktestResult.fromJson(b as Map<String, dynamic>))
            .toList();
        developer.log(
          'Retrieved ${backtests.length} backtests',
          name: 'BacktestService',
        );
        return backtests;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log(
        'Error listing backtests: $e',
        name: 'BacktestService',
        error: e,
      );
      rethrow;
    }
  }

  /// Delete a backtest
  ///
  /// Remove a backtest and its results
  ///
  /// Parameters:
  /// - [backtestId]: The ID of the backtest to delete
  ///
  /// Returns true if successful
  ///
  /// Example:
  /// ```dart
  /// await backtestService.deleteBacktest(backtestId);
  /// ```
  Future<bool> deleteBacktest(String backtestId) async {
    try {
      developer.log(
        'Deleting backtest: $backtestId',
        name: 'BacktestService',
      );

      final response = await _apiClient.delete<Map<String, dynamic>>(
        '$_basePath/$backtestId',
      );

      if (response['success'] == true) {
        developer.log(
          'Backtest deleted successfully',
          name: 'BacktestService',
        );
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to delete backtest',
        code: response['code'],
      );
    } catch (e) {
      developer.log(
        'Error deleting backtest: $e',
        name: 'BacktestService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get available strategies for backtesting
  ///
  /// Returns list of strategy names that can be backtested
  ///
  /// Example:
  /// ```dart
  /// final strategies = await backtestService.getAvailableStrategies();
  /// print('Available strategies: $strategies');
  /// ```
  Future<List<String>> getAvailableStrategies() async {
    try {
      developer.log(
        'Fetching available strategies...',
        name: 'BacktestService',
      );

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_basePath/strategies',
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> strategiesData = response['data'];
        final strategies = strategiesData.map((s) => s.toString()).toList();
        developer.log(
          'Retrieved ${strategies.length} strategies',
          name: 'BacktestService',
        );
        return strategies;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log(
        'Error getting strategies: $e',
        name: 'BacktestService',
        error: e,
      );
      rethrow;
    }
  }

  /// Cancel a running backtest
  ///
  /// Stop a backtest that is currently running
  ///
  /// Parameters:
  /// - [backtestId]: The ID of the backtest to cancel
  ///
  /// Returns true if successful
  ///
  /// Example:
  /// ```dart
  /// await backtestService.cancelBacktest(backtestId);
  /// ```
  Future<bool> cancelBacktest(String backtestId) async {
    try {
      developer.log(
        'Cancelling backtest: $backtestId',
        name: 'BacktestService',
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_basePath/cancel/$backtestId',
      );

      if (response['success'] == true) {
        developer.log(
          'Backtest cancelled successfully',
          name: 'BacktestService',
        );
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to cancel backtest',
        code: response['code'],
      );
    } catch (e) {
      developer.log(
        'Error cancelling backtest: $e',
        name: 'BacktestService',
        error: e,
      );
      rethrow;
    }
  }
}
