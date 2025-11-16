import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/websocket_event.dart';
import '../services/websocket_service.dart';
import 'services_provider.dart';

part 'websocket_provider.g.dart';

/// Provider for WebSocket connection state
///
/// Monitors the current connection state of the WebSocket.
/// Updates automatically when connection state changes.
///
/// States:
/// - disconnected: Not connected
/// - connecting: Attempting initial connection
/// - connected: Successfully connected
/// - error: Connection error
/// - reconnecting: Attempting reconnection after disconnect
@riverpod
class WebsocketConnectionState extends _$WebsocketConnectionState {
  StreamSubscription? _subscription;

  @override
  WebSocketConnectionState build() {
    final wsService = ref.watch(websocketServiceProvider);

    // Clean up subscription on dispose
    ref.onDispose(() {
      _subscription?.cancel();
    });

    // Subscribe to connection state changes
    _subscription = wsService.connectionStateStream.listen((wsState) {
      // Map WebSocketService's state to our local enum
      // Note: We use the same enum name so this is a direct assignment
      state = wsState;
    });

    // Initial state - get current state from service
    return wsService.connectionState;
  }

  /// Manually connect to WebSocket
  void connect() {
    state = WebSocketConnectionState.connecting;
    final wsService = ref.read(websocketServiceProvider);
    wsService.connect();
  }

  /// Manually disconnect from WebSocket
  void disconnect() {
    final wsService = ref.read(websocketServiceProvider);
    wsService.disconnect();
    state = WebSocketConnectionState.disconnected;
  }

  /// Check if currently connected
  bool get isConnected => state == WebSocketConnectionState.connected;

  /// Check if currently connecting
  bool get isConnecting =>
      state == WebSocketConnectionState.connecting;

  /// Check if in error state
  bool get hasError => state == WebSocketConnectionState.error;
}

/// Provider for position updates stream
///
/// Streams real-time position updates from WebSocket.
/// Emits Position whenever a position changes.
///
/// Updates include:
/// - New positions opened
/// - Position price updates
/// - Position closures
/// - SL/TP modifications
@riverpod
Stream<Position> positionUpdatesStream(PositionUpdatesStreamRef ref) {
  final wsService = ref.watch(websocketServiceProvider);

  // Ensure connection is active
  wsService.connect();

  // Return position updates stream from WebSocket service
  return wsService.positionUpdates;
}

/// Provider for metrics updates stream
///
/// Streams real-time metrics updates from WebSocket.
/// Emits Metrics whenever metrics change.
///
/// Updates every few seconds with:
/// - Total trades
/// - Win rate
/// - P&L (total and daily)
/// - Active positions
/// - Average latency
@riverpod
Stream<Metrics> metricsUpdatesStream(MetricsUpdatesStreamRef ref) {
  final wsService = ref.watch(websocketServiceProvider);

  wsService.connect();

  return wsService.metricsUpdates;
}

/// Provider for alerts stream
///
/// Streams real-time alerts from WebSocket.
/// Emits Alert whenever a new alert is triggered.
///
/// Alert types:
/// - Price alerts
/// - Drawdown warnings
/// - P&L notifications
/// - Volume alerts
/// - System errors
@riverpod
Stream<Alert> alertsStream(AlertsStreamRef ref) {
  final wsService = ref.watch(websocketServiceProvider);

  wsService.connect();

  return wsService.alerts;
}

/// Provider for risk updates stream
///
/// NOTE: Risk updates are not yet implemented in WebSocket service.
/// This provider will be empty until the backend adds risk update events.
///
/// TODO: Enable when backend implements risk_update WebSocket events
/*
@riverpod
Stream<dynamic> riskUpdatesStream(RiskUpdatesStreamRef ref) {
  final wsService = ref.watch(websocketServiceProvider);
  wsService.connect();
  // TODO: Add risk updates stream when available
  return const Stream.empty();
}
*/

/// Provider for trade execution events stream
///
/// Streams notifications when trades are executed.
/// Useful for showing real-time execution confirmations.
@riverpod
Stream<Trade> tradeExecutionStream(TradeExecutionStreamRef ref) {
  final wsService = ref.watch(websocketServiceProvider);

  wsService.connect();

  return wsService.tradeExecuted;
}

/// Provider for kill switch events stream
///
/// Streams kill switch activation/deactivation events.
/// Critical for real-time safety monitoring.
@riverpod
Stream<KillSwitchEvent> killSwitchStream(KillSwitchStreamRef ref) {
  final wsService = ref.watch(websocketServiceProvider);

  wsService.connect();

  return wsService.killSwitchEvents;
}

/// Provider for WebSocket connection status indicator
///
/// Returns a user-friendly status message and color.
@riverpod
class WebsocketStatus extends _$WebsocketStatus {
  @override
  ConnectionStatus build() {
    final state = ref.watch(websocketConnectionStateProvider);

    switch (state) {
      case WebSocketConnectionState.connected:
        return ConnectionStatus(
          message: 'Connected',
          color: ConnectionStatusColor.success,
        );
      case WebSocketConnectionState.connecting:
        return ConnectionStatus(
          message: 'Connecting...',
          color: ConnectionStatusColor.warning,
        );
      case WebSocketConnectionState.error:
        return ConnectionStatus(
          message: 'Connection Error',
          color: ConnectionStatusColor.error,
        );
      case WebSocketConnectionState.disconnected:
      default:
        return ConnectionStatus(
          message: 'Disconnected',
          color: ConnectionStatusColor.error,
        );
    }
  }
}

/// Connection status display model
class ConnectionStatus {
  final String message;
  final ConnectionStatusColor color;

  ConnectionStatus({
    required this.message,
    required this.color,
  });
}

/// Connection status colors
enum ConnectionStatusColor {
  success, // Green - connected
  warning, // Yellow - connecting/reconnecting
  error, // Red - disconnected/error
}

/// Provider for WebSocket latency monitoring
///
/// Tracks WebSocket latency by measuring ping/pong roundtrip time.
@riverpod
class WebsocketLatency extends _$WebsocketLatency {
  Timer? _pingTimer;
  final List<int> _latencyHistory = [];
  static const int _historySize = 10;

  @override
  LatencyStats build() {
    final wsService = ref.watch(websocketServiceProvider);

    // Clean up timer on dispose
    ref.onDispose(() {
      _pingTimer?.cancel();
    });

    // Start latency monitoring
    _startLatencyMonitoring(wsService);

    return LatencyStats(
      current: 0,
      average: 0,
      min: 0,
      max: 0,
    );
  }

  void _startLatencyMonitoring(WebSocketService wsService) {
    _pingTimer?.cancel();
    // TODO: Implement latency monitoring when WebSocketService supports it
    // _pingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
    //   final latency = await wsService.measureLatency();
    //   _updateLatency(latency);
    // });
  }

  void _updateLatency(int latency) {
    _latencyHistory.add(latency);
    if (_latencyHistory.length > _historySize) {
      _latencyHistory.removeAt(0);
    }

    if (_latencyHistory.isNotEmpty) {
      state = LatencyStats(
        current: latency,
        average: _latencyHistory.reduce((a, b) => a + b) ~/ _latencyHistory.length,
        min: _latencyHistory.reduce((a, b) => a < b ? a : b),
        max: _latencyHistory.reduce((a, b) => a > b ? a : b),
      );
    }
  }
}

/// WebSocket latency statistics
class LatencyStats {
  final int current; // Current latency in ms
  final int average; // Average latency in ms
  final int min; // Minimum latency in ms
  final int max; // Maximum latency in ms

  LatencyStats({
    required this.current,
    required this.average,
    required this.min,
    required this.max,
  });

  /// Check if latency is good (<100ms)
  bool get isGood => average < 100;

  /// Check if latency is acceptable (<500ms)
  bool get isAcceptable => average < 500;

  /// Check if latency is poor (>=500ms)
  bool get isPoor => average >= 500;
}

/// Provider for WebSocket reconnection attempts counter
///
/// Tracks how many reconnection attempts have been made.
/// Resets to 0 when successfully connected.
@riverpod
class ReconnectionAttempts extends _$ReconnectionAttempts {
  @override
  int build() {
    final state = ref.watch(websocketConnectionStateProvider);

    // Reset counter when connected
    if (state == WebSocketConnectionState.connected) {
      return 0;
    }

    return 0;
  }

  void increment() {
    state++;
  }

  void reset() {
    state = 0;
  }
}

/// Provider for last WebSocket event timestamp
///
/// Tracks when the last event was received from WebSocket.
/// Useful for detecting stale connections.
@riverpod
class LastEventTimestamp extends _$LastEventTimestamp {
  StreamSubscription? _subscription;

  @override
  DateTime? build() {
    final wsService = ref.watch(websocketServiceProvider);

    ref.onDispose(() {
      _subscription?.cancel();
    });

    // Listen to any stream to track last event time
    // Using position updates as a proxy for activity
    _subscription = wsService.positionUpdates.listen((_) {
      state = DateTime.now();
    });

    return null;
  }

  /// Check if connection is stale (no events in last 60 seconds)
  bool isStale() {
    if (state == null) return true;
    return DateTime.now().difference(state!).inSeconds > 60;
  }

  /// Get seconds since last event
  int secondsSinceLastEvent() {
    if (state == null) return -1;
    return DateTime.now().difference(state!).inSeconds;
  }
}
