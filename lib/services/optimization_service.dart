import 'dart:developer' as developer;
import 'api_client.dart';
import 'api_exception.dart';
import '../models/optimization.dart';

/// Optimization Service
///
/// Handles parameter optimization operations:
/// - Run parameter optimization
/// - Get optimization results
/// - List optimization history
/// - Apply optimal parameters to strategy
/// - Cancel running optimizations
class OptimizationService {
  final ApiClient _apiClient;
  static const String _basePath = '/optimization';

  OptimizationService(this._apiClient);

  /// Run a new optimization
  ///
  /// Executes a parameter optimization with the provided configuration
  /// and returns the optimization ID for tracking progress.
  ///
  /// Parameters:
  /// - [config]: Optimization configuration with strategy, symbol, parameters, etc.
  ///
  /// Returns optimization ID as String
  ///
  /// Example:
  /// ```dart
  /// final config = OptimizationConfig(
  ///   strategyName: 'rsi_scalping',
  ///   symbol: 'BTCUSDT',
  ///   startDate: DateTime(2024, 1, 1),
  ///   endDate: DateTime(2024, 1, 31),
  ///   parameterRanges: [
  ///     ParameterRange(name: 'rsi_period', min: 10, max: 20, step: 2),
  ///     ParameterRange(name: 'rsi_oversold', min: 20, max: 35, step: 5),
  ///   ],
  ///   optimizationMethod: 'grid_search',
  ///   objective: 'sharpe_ratio',
  /// );
  /// final optimizationId = await optimizationService.runOptimization(config);
  /// print('Optimization started: $optimizationId');
  /// ```
  Future<String> runOptimization(OptimizationConfig config) async {
    try {
      developer.log(
        'Starting optimization for ${config.strategyName} on ${config.symbol}...',
        name: 'OptimizationService',
      );

      // Validate configuration
      if (!config.validate()) {
        throw ApiException(
          message: 'Invalid optimization configuration',
          code: 'INVALID_CONFIG',
        );
      }

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_basePath/run',
        data: config.toJson(),
      );

      if (response['success'] == true && response['data'] != null) {
        final optimizationId = response['data']['optimization_id'] as String;
        developer.log(
          'Optimization started with ID: $optimizationId',
          name: 'OptimizationService',
        );
        return optimizationId;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to start optimization',
        code: response['code'],
      );
    } catch (e) {
      developer.log(
        'Error starting optimization: $e',
        name: 'OptimizationService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get optimization results by ID
  ///
  /// Retrieves complete optimization results including:
  /// - All parameter combinations tested
  /// - Best parameters found
  /// - Performance metrics for each combination
  ///
  /// Parameters:
  /// - [optimizationId]: The ID of the optimization to retrieve
  ///
  /// Returns [OptimizationResult] with all results and metrics
  ///
  /// Example:
  /// ```dart
  /// final result = await optimizationService.getOptimizationResults(optimizationId);
  /// if (result.isCompleted && result.bestParameters != null) {
  ///   print('Best Sharpe: ${result.bestParameters!.sharpeRatio}');
  ///   print('Parameters: ${result.bestParameters!.getFormattedParameters()}');
  /// }
  /// ```
  Future<OptimizationResult> getOptimizationResults(String optimizationId) async {
    try {
      developer.log(
        'Fetching optimization results for ID: $optimizationId',
        name: 'OptimizationService',
      );

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_basePath/results/$optimizationId',
      );

      if (response['success'] == true && response['data'] != null) {
        final result = OptimizationResult.fromJson(response['data']);
        developer.log(
          'Optimization results retrieved: ${result.status}',
          name: 'OptimizationService',
        );
        return result;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log(
        'Error getting optimization results: $e',
        name: 'OptimizationService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get optimization history
  ///
  /// Retrieves list of all past optimizations (summaries only)
  ///
  /// Parameters:
  /// - [limit]: Maximum number of optimizations to return (default: 50)
  ///
  /// Returns list of [OptimizationSummary]
  ///
  /// Example:
  /// ```dart
  /// final history = await optimizationService.getOptimizationHistory(limit: 10);
  /// for (var opt in history) {
  ///   print('${opt.strategyName} on ${opt.symbol}: ${opt.status}');
  /// }
  /// ```
  Future<List<OptimizationSummary>> getOptimizationHistory({int limit = 50}) async {
    try {
      developer.log(
        'Fetching optimization history...',
        name: 'OptimizationService',
      );

      final response = await _apiClient.get<Map<String, dynamic>>(
        _basePath,
        queryParameters: {
          'limit': limit,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> historyData = response['data'];
        final history = historyData
            .map((o) => OptimizationSummary.fromJson(o as Map<String, dynamic>))
            .toList();
        developer.log(
          'Retrieved ${history.length} optimizations',
          name: 'OptimizationService',
        );
        return history;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log(
        'Error listing optimizations: $e',
        name: 'OptimizationService',
        error: e,
      );
      rethrow;
    }
  }

  /// Apply optimal parameters to strategy
  ///
  /// Updates a strategy's configuration with the best parameters
  /// found during optimization
  ///
  /// Parameters:
  /// - [strategyName]: Name of the strategy to update
  /// - [parameters]: Map of parameter names to values
  ///
  /// Returns true if successful
  ///
  /// Example:
  /// ```dart
  /// await optimizationService.applyParameters(
  ///   'rsi_scalping',
  ///   {'rsi_period': 14, 'rsi_oversold': 30, 'rsi_overbought': 70},
  /// );
  /// ```
  Future<bool> applyParameters(
    String strategyName,
    Map<String, double> parameters,
  ) async {
    try {
      developer.log(
        'Applying parameters to strategy: $strategyName',
        name: 'OptimizationService',
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_basePath/apply',
        data: {
          'strategy_name': strategyName,
          'parameters': parameters,
        },
      );

      if (response['success'] == true) {
        developer.log(
          'Parameters applied successfully',
          name: 'OptimizationService',
        );
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to apply parameters',
        code: response['code'],
      );
    } catch (e) {
      developer.log(
        'Error applying parameters: $e',
        name: 'OptimizationService',
        error: e,
      );
      rethrow;
    }
  }

  /// Cancel a running optimization
  ///
  /// Stops an optimization that is currently running
  ///
  /// Parameters:
  /// - [optimizationId]: The ID of the optimization to cancel
  ///
  /// Returns true if successful
  ///
  /// Example:
  /// ```dart
  /// await optimizationService.cancelOptimization(optimizationId);
  /// ```
  Future<bool> cancelOptimization(String optimizationId) async {
    try {
      developer.log(
        'Cancelling optimization: $optimizationId',
        name: 'OptimizationService',
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_basePath/cancel/$optimizationId',
      );

      if (response['success'] == true) {
        developer.log(
          'Optimization cancelled successfully',
          name: 'OptimizationService',
        );
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to cancel optimization',
        code: response['code'],
      );
    } catch (e) {
      developer.log(
        'Error cancelling optimization: $e',
        name: 'OptimizationService',
        error: e,
      );
      rethrow;
    }
  }

  /// Delete an optimization
  ///
  /// Remove an optimization and its results from history
  ///
  /// Parameters:
  /// - [optimizationId]: The ID of the optimization to delete
  ///
  /// Returns true if successful
  ///
  /// Example:
  /// ```dart
  /// await optimizationService.deleteOptimization(optimizationId);
  /// ```
  Future<bool> deleteOptimization(String optimizationId) async {
    try {
      developer.log(
        'Deleting optimization: $optimizationId',
        name: 'OptimizationService',
      );

      final response = await _apiClient.delete<Map<String, dynamic>>(
        '$_basePath/$optimizationId',
      );

      if (response['success'] == true) {
        developer.log(
          'Optimization deleted successfully',
          name: 'OptimizationService',
        );
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to delete optimization',
        code: response['code'],
      );
    } catch (e) {
      developer.log(
        'Error deleting optimization: $e',
        name: 'OptimizationService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get available strategies for optimization
  ///
  /// Returns list of strategy names that can be optimized
  ///
  /// Example:
  /// ```dart
  /// final strategies = await optimizationService.getAvailableStrategies();
  /// print('Available strategies: $strategies');
  /// ```
  Future<List<String>> getAvailableStrategies() async {
    try {
      developer.log(
        'Fetching available strategies for optimization...',
        name: 'OptimizationService',
      );

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_basePath/strategies',
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> strategiesData = response['data'];
        final strategies = strategiesData.map((s) => s.toString()).toList();
        developer.log(
          'Retrieved ${strategies.length} strategies',
          name: 'OptimizationService',
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
        name: 'OptimizationService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get default parameter ranges for a strategy
  ///
  /// Returns suggested parameter ranges for optimization
  ///
  /// Parameters:
  /// - [strategyName]: Name of the strategy
  ///
  /// Returns list of [ParameterRange]
  ///
  /// Example:
  /// ```dart
  /// final ranges = await optimizationService.getDefaultParameterRanges('rsi_scalping');
  /// ```
  Future<List<ParameterRange>> getDefaultParameterRanges(String strategyName) async {
    try {
      developer.log(
        'Fetching default parameter ranges for: $strategyName',
        name: 'OptimizationService',
      );

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_basePath/strategies/$strategyName/parameters',
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> rangesData = response['data'];
        final ranges = rangesData
            .map((r) => ParameterRange.fromJson(r as Map<String, dynamic>))
            .toList();
        developer.log(
          'Retrieved ${ranges.length} parameter ranges',
          name: 'OptimizationService',
        );
        return ranges;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log(
        'Error getting parameter ranges: $e',
        name: 'OptimizationService',
        error: e,
      );
      rethrow;
    }
  }
}
