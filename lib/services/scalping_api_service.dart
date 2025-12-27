import 'package:dio/dio.dart';
import '../models/scalping_status.dart';
import '../models/scalping_metrics.dart';
import '../models/scalping_health.dart';

/// Scalping API Service
///
/// Service for interacting with the Scalping API endpoints.
/// Based on SCALPING_ENDPOINTS_SPEC.md specification.
///
/// Base URL: Configured via Environment variables
class ScalpingApiService {
  final Dio _dio;

  /// Base path for scalping endpoints
  static const String basePath = '/api/scalping/api/v1/scalping';

  ScalpingApiService(this._dio);

  /// Get scalping system status
  ///
  /// Returns the current status of the scalping system including
  /// bot counts and activity state.
  ///
  /// Endpoint: GET /status
  ///
  /// Example:
  /// ```dart
  /// final status = await service.getStatus();
  /// print('Active: ${status.active}');
  /// print('Total Bots: ${status.totalBots}');
  /// print('Active Bots: ${status.activeBots}');
  /// ```
  Future<ScalpingStatus> getStatus() async {
    try {
      final response = await _dio.get('$basePath/status');

      // Backend returns direct JSON (no wrapper)
      return ScalpingStatus.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get scalping status');
    }
  }

  /// Get scalping system metrics
  ///
  /// Returns trading metrics including trades, PnL, win rate, etc.
  ///
  /// Endpoint: GET /metrics
  ///
  /// Example:
  /// ```dart
  /// final metrics = await service.getMetrics();
  /// print('Total Trades: ${metrics.totalTrades}');
  /// print('Win Rate: ${metrics.winRatePercent.toStringAsFixed(2)}%');
  /// print('Total PnL: \$${metrics.totalPnl.toStringAsFixed(2)}');
  /// ```
  Future<ScalpingMetrics> getMetrics() async {
    try {
      final response = await _dio.get('$basePath/metrics');

      // Backend returns direct JSON (no wrapper)
      return ScalpingMetrics.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get scalping metrics');
    }
  }

  /// Get scalping system health
  ///
  /// Returns the health status of the scalping system.
  ///
  /// Endpoint: GET /health
  ///
  /// Example:
  /// ```dart
  /// final health = await service.getHealth();
  /// if (health.isHealthy) {
  ///   print('System is healthy');
  /// } else {
  ///   print('System status: ${health.status}');
  /// }
  /// ```
  Future<ScalpingHealth> getHealth() async {
    try {
      final response = await _dio.get('$basePath/health');

      // Backend returns direct JSON (no wrapper)
      return ScalpingHealth.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get scalping health');
    }
  }

  /// Handle Dio errors and convert to meaningful exceptions
  Exception _handleError(DioException e, String defaultMessage) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      String message = defaultMessage;
      if (data is Map && data['error'] != null) {
        message = data['error'].toString();
      } else if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      }

      return Exception('$message (Status: $statusCode)');
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout: $defaultMessage');
    }

    if (e.type == DioExceptionType.connectionError) {
      return Exception('Connection error: $defaultMessage');
    }

    return Exception('$defaultMessage: ${e.message}');
  }
}
