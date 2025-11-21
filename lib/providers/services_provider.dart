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
/// Wraps Dio instance with custom error handling and retry logic
@riverpod
ApiClient apiClient(ApiClientRef ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
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
  final service = WebSocketService(websocketUrl);

  // Ensure cleanup on provider disposal
  ref.onDispose(() {
    service.disconnect();
  });

  return service;
}
