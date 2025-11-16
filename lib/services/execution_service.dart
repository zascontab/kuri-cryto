import 'dart:developer' as developer;
import 'api_client.dart';
import 'api_exception.dart';
import '../models/execution_stats.dart';

/// Execution Service
///
/// Handles execution statistics and performance monitoring:
/// - Latency statistics
/// - Execution history
/// - Queue management
/// - Performance metrics
/// - Metrics export
class ExecutionService {
  final ApiClient _apiClient;
  static const String _basePath = '/api/v1';

  ExecutionService(this._apiClient);

  /// Get latency statistics
  ///
  /// Returns latency metrics including average, percentiles,
  /// and total executions measured.
  ///
  /// Example:
  /// ```dart
  /// final stats = await executionService.getLatencyStats();
  /// print('Avg Latency: ${stats.avgLatency}ms');
  /// print('P95 Latency: ${stats.p95Latency}ms');
  /// ```
  Future<LatencyStats> getLatencyStats() async {
    try {
      developer.log('Fetching latency statistics...', name: 'ExecutionService');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_basePath/scalping/execution/latency',
      );

      if (response['success'] == true && response['data'] != null) {
        final stats = LatencyStats.fromJson(response['data']);
        developer.log('Latency stats retrieved successfully', name: 'ExecutionService');
        return stats;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log('Error getting latency stats: $e', name: 'ExecutionService', error: e);
      rethrow;
    }
  }

  /// Get execution history
  ///
  /// Returns recent execution history with optional limit.
  ///
  /// Parameters:
  /// - [limit]: Maximum number of executions to return (default: 50)
  ///
  /// Example:
  /// ```dart
  /// final history = await executionService.getExecutionHistory(limit: 100);
  /// print('Total executions: ${history.totalCount}');
  /// ```
  Future<ExecutionHistory> getExecutionHistory({int limit = 50}) async {
    try {
      developer.log('Fetching execution history (limit: $limit)...', name: 'ExecutionService');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_basePath/scalping/execution/history',
        queryParameters: {'limit': limit},
      );

      if (response['success'] == true && response['data'] != null) {
        final history = ExecutionHistory.fromJson(response['data']);
        developer.log('Execution history retrieved successfully', name: 'ExecutionService');
        return history;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log('Error getting execution history: $e', name: 'ExecutionService', error: e);
      rethrow;
    }
  }

  /// Get execution queue state
  ///
  /// Returns current state of the execution queue including
  /// pending orders and queue health.
  ///
  /// Example:
  /// ```dart
  /// final queue = await executionService.getExecutionQueue();
  /// print('Queue length: ${queue.queueLength}');
  /// print('Avg wait time: ${queue.avgWaitTime}ms');
  /// ```
  Future<ExecutionQueue> getExecutionQueue() async {
    try {
      developer.log('Fetching execution queue...', name: 'ExecutionService');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_basePath/execution/queue',
      );

      if (response['success'] == true && response['data'] != null) {
        final queue = ExecutionQueue.fromJson(response['data']);
        developer.log('Execution queue retrieved successfully', name: 'ExecutionService');
        return queue;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log('Error getting execution queue: $e', name: 'ExecutionService', error: e);
      rethrow;
    }
  }

  /// Get execution performance metrics
  ///
  /// Returns comprehensive execution performance metrics including
  /// slippage, fill rate, and error statistics.
  ///
  /// Example:
  /// ```dart
  /// final performance = await executionService.getExecutionPerformance();
  /// print('Fill rate: ${performance.fillRate}%');
  /// print('Avg slippage: ${performance.avgSlippage} bps');
  /// ```
  Future<ExecutionPerformance> getExecutionPerformance() async {
    try {
      developer.log('Fetching execution performance...', name: 'ExecutionService');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_basePath/execution/performance',
      );

      if (response['success'] == true && response['data'] != null) {
        final performance = ExecutionPerformance.fromJson(response['data']);
        developer.log('Execution performance retrieved successfully', name: 'ExecutionService');
        return performance;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log('Error getting execution performance: $e', name: 'ExecutionService', error: e);
      rethrow;
    }
  }

  /// Export metrics
  ///
  /// Exports metrics in specified format for a given period.
  ///
  /// Parameters:
  /// - [format]: Export format ('csv', 'json', 'excel')
  /// - [period]: Time period ('7d', '30d', '90d', 'all')
  /// - [metrics]: List of metrics to export (e.g., ['latency', 'slippage', 'fill_rate'])
  ///
  /// Example:
  /// ```dart
  /// final result = await executionService.exportMetrics(
  ///   format: 'csv',
  ///   period: '30d',
  ///   metrics: ['latency', 'slippage'],
  /// );
  /// print('Export path: ${result.filePath}');
  /// ```
  Future<MetricsExportResult> exportMetrics({
    required String format,
    required String period,
    required List<String> metrics,
  }) async {
    try {
      developer.log(
        'Exporting metrics (format: $format, period: $period)...',
        name: 'ExecutionService',
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_basePath/monitoring/metrics/export',
        data: {
          'format': format,
          'period': period,
          'metrics': metrics,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final result = MetricsExportResult.fromJson(response['data']);
        developer.log('Metrics exported successfully', name: 'ExecutionService');
        return result;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to export metrics',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error exporting metrics: $e', name: 'ExecutionService', error: e);
      rethrow;
    }
  }
}
