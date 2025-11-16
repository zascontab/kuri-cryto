// GENERATED CODE - DO NOT MODIFY BY HAND
// To regenerate, run: flutter pub run build_runner build

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../services/api_client.dart';
import '../services/scalping_service.dart';
import '../services/position_service.dart';
import '../services/strategy_service.dart';
import '../services/risk_service.dart';
import '../services/websocket_service.dart';
import '../services/analysis_service.dart';
import '../services/backtest_service.dart';
import '../services/optimization_service.dart';
import '../services/execution_service.dart';
import '../services/alert_service.dart';

part 'services_provider.g.dart';

/// API Base URL configuration
const String apiBaseUrl = 'http://localhost:8081/api/v1';
const String websocketUrl = 'ws://localhost:8081/ws';

/// Provider for Dio HTTP client
///
/// Configured with:
/// - Base URL
/// - Connect timeout: 10s
/// - Receive timeout: 30s
/// - JSON content type
/// - Logging interceptor (debug mode)
@riverpod
Dio dio(DioRef ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add interceptor for logging in debug mode
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => print('[API] $obj'),
    ),
  );

  return dio;
}

/// Provider for API client
///
/// Creates ApiClient with custom error handling and retry logic
@riverpod
ApiClient apiClient(ApiClientRef ref) {
  return ApiClient();
}

/// Provider for Scalping Service
///
/// Handles all scalping-related API calls:
/// - System control (start/stop)
/// - Status and metrics
/// - Health check
@riverpod
ScalpingService scalpingService(ScalpingServiceRef ref) {
  final client = ref.watch(apiClientProvider);
  return ScalpingService(client);
}

/// Provider for Position Service
///
/// Manages position-related operations:
/// - Get open positions
/// - Get position history
/// - Close positions
/// - Update SL/TP
/// - Move to breakeven
/// - Enable trailing stop
@riverpod
PositionService positionService(PositionServiceRef ref) {
  final client = ref.watch(apiClientProvider);
  return PositionService(client);
}

/// Provider for Strategy Service
///
/// Handles strategy configuration and control:
/// - List strategies
/// - Start/Stop strategies
/// - Update strategy config
/// - Get strategy performance
@riverpod
StrategyService strategyService(StrategyServiceRef ref) {
  final client = ref.watch(apiClientProvider);
  return StrategyService(client);
}

/// Provider for Risk Service
///
/// Manages risk parameters and monitoring:
/// - Get/Update risk limits
/// - Get exposure
/// - Risk Sentinel state
/// - Kill switch activation/deactivation
@riverpod
RiskService riskService(RiskServiceRef ref) {
  final client = ref.watch(apiClientProvider);
  return RiskService(client);
}

/// Provider for WebSocket Service
///
/// Manages WebSocket connection for real-time updates:
/// - Position updates
/// - Metrics updates
/// - Alerts
/// - Kill switch events
///
/// Auto-reconnection with exponential backoff
@riverpod
WebSocketService websocketService(WebsocketServiceRef ref) {
  final service = WebSocketService(url: websocketUrl);

  // Ensure cleanup on provider disposal
  ref.onDispose(() {
    service.disconnect();
  });

  return service;
}

/// Provider for Analysis Service
///
/// Handles multi-timeframe market analysis:
/// - Technical indicators (RSI, MACD, Bollinger)
/// - Signal generation
/// - Consensus analysis across timeframes
@riverpod
AnalysisService analysisService(AnalysisServiceRef ref) {
  final client = ref.watch(apiClientProvider);
  return AnalysisService(client);
}

/// Provider for Backtest Service
///
/// Manages strategy backtesting:
/// - Run backtests with historical data
/// - Get performance metrics
/// - Trade history and equity curves
@riverpod
BacktestService backtestService(BacktestServiceRef ref) {
  final client = ref.watch(apiClientProvider);
  return BacktestService(client);
}

/// Provider for Optimization Service
///
/// Manages parameter optimization:
/// - Run parameter optimizations
/// - Get optimization results
/// - Apply optimal parameters
/// - Manage optimization history
@riverpod
OptimizationService optimizationService(OptimizationServiceRef ref) {
  final client = ref.watch(apiClientProvider);
  return OptimizationService(client);
}

/// Provider for Execution Service
///
/// Handles execution statistics and performance:
/// - Latency statistics
/// - Execution history
/// - Queue management
/// - Performance metrics
/// - Metrics export
@riverpod
ExecutionService executionService(ExecutionServiceRef ref) {
  final client = ref.watch(apiClientProvider);
  return ExecutionService(client);
}

/// Provider for Alert Service
///
/// Manages alert system:
/// - Configure alert rules
/// - Get alert history
/// - Acknowledge/dismiss alerts
/// - Get active alerts
/// - Test alert configuration
@riverpod
AlertService alertService(AlertServiceRef ref) {
  final client = ref.watch(apiClientProvider);
  return AlertService(client);
}
