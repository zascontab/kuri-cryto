// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'websocket_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$positionUpdatesStreamHash() =>
    r'723ccb6f701fab9e7788ed644b98e19378b8e9c9';

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
///
/// Copied from [positionUpdatesStream].
@ProviderFor(positionUpdatesStream)
final positionUpdatesStreamProvider =
    AutoDisposeStreamProvider<Position>.internal(
  positionUpdatesStream,
  name: r'positionUpdatesStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$positionUpdatesStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PositionUpdatesStreamRef = AutoDisposeStreamProviderRef<Position>;
String _$metricsUpdatesStreamHash() =>
    r'9b1bb2b0123332ddcde6360853c7ed7763968b7d';

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
///
/// Copied from [metricsUpdatesStream].
@ProviderFor(metricsUpdatesStream)
final metricsUpdatesStreamProvider =
    AutoDisposeStreamProvider<Metrics>.internal(
  metricsUpdatesStream,
  name: r'metricsUpdatesStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$metricsUpdatesStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MetricsUpdatesStreamRef = AutoDisposeStreamProviderRef<Metrics>;
String _$alertsStreamHash() => r'e6bd76b45b67a5a4f9bfec39f861149d2e2e60c7';

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
///
/// Copied from [alertsStream].
@ProviderFor(alertsStream)
final alertsStreamProvider = AutoDisposeStreamProvider<AlertEvent>.internal(
  alertsStream,
  name: r'alertsStreamProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$alertsStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AlertsStreamRef = AutoDisposeStreamProviderRef<AlertEvent>;
String _$tradeExecutionStreamHash() =>
    r'4bbcd9b6586a6e94e8aebe47a513bab4ab4bd38e';

/// Provider for risk updates stream
///
/// NOTE: Risk updates are not yet implemented in WebSocket service.
/// This provider will be empty until the backend adds risk update events.
///
/// TODO: Enable when backend implements risk_update WebSocket events
/// Provider for trade execution events stream
///
/// Streams notifications when trades are executed.
/// Useful for showing real-time execution confirmations.
///
/// Copied from [tradeExecutionStream].
@ProviderFor(tradeExecutionStream)
final tradeExecutionStreamProvider = AutoDisposeStreamProvider<Trade>.internal(
  tradeExecutionStream,
  name: r'tradeExecutionStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tradeExecutionStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TradeExecutionStreamRef = AutoDisposeStreamProviderRef<Trade>;
String _$killSwitchStreamHash() => r'47a1dd1c85cbfd6e612949019d1ae9950b203409';

/// Provider for kill switch events stream
///
/// Streams kill switch activation/deactivation events.
/// Critical for real-time safety monitoring.
///
/// Copied from [killSwitchStream].
@ProviderFor(killSwitchStream)
final killSwitchStreamProvider =
    AutoDisposeStreamProvider<KillSwitchEvent>.internal(
  killSwitchStream,
  name: r'killSwitchStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$killSwitchStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef KillSwitchStreamRef = AutoDisposeStreamProviderRef<KillSwitchEvent>;
String _$websocketConnectionStateHash() =>
    r'43e2508728ff18ccd225b91ae75429626633bcb9';

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
///
/// Copied from [WebsocketConnectionState].
@ProviderFor(WebsocketConnectionState)
final websocketConnectionStateProvider = AutoDisposeNotifierProvider<
    WebsocketConnectionState, WebSocketConnectionState>.internal(
  WebsocketConnectionState.new,
  name: r'websocketConnectionStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$websocketConnectionStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WebsocketConnectionState
    = AutoDisposeNotifier<WebSocketConnectionState>;
String _$websocketStatusHash() => r'9c7a467287fea92c9f3a61c818bd5c2b09fcacb0';

/// Provider for WebSocket connection status indicator
///
/// Returns a user-friendly status message and color.
///
/// Copied from [WebsocketStatus].
@ProviderFor(WebsocketStatus)
final websocketStatusProvider =
    AutoDisposeNotifierProvider<WebsocketStatus, ConnectionStatus>.internal(
  WebsocketStatus.new,
  name: r'websocketStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$websocketStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WebsocketStatus = AutoDisposeNotifier<ConnectionStatus>;
String _$websocketLatencyHash() => r'536363095c3672b0b810b83c4fbf92e850020914';

/// Provider for WebSocket latency monitoring
///
/// Tracks WebSocket latency by measuring ping/pong roundtrip time.
///
/// Copied from [WebsocketLatency].
@ProviderFor(WebsocketLatency)
final websocketLatencyProvider =
    AutoDisposeNotifierProvider<WebsocketLatency, LatencyStats>.internal(
  WebsocketLatency.new,
  name: r'websocketLatencyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$websocketLatencyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WebsocketLatency = AutoDisposeNotifier<LatencyStats>;
String _$reconnectionAttemptsHash() =>
    r'fc1a9f96e3e1abcba32c3305eaf1b8b80aef401d';

/// Provider for WebSocket reconnection attempts counter
///
/// Tracks how many reconnection attempts have been made.
/// Resets to 0 when successfully connected.
///
/// Copied from [ReconnectionAttempts].
@ProviderFor(ReconnectionAttempts)
final reconnectionAttemptsProvider =
    AutoDisposeNotifierProvider<ReconnectionAttempts, int>.internal(
  ReconnectionAttempts.new,
  name: r'reconnectionAttemptsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reconnectionAttemptsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReconnectionAttempts = AutoDisposeNotifier<int>;
String _$lastEventTimestampHash() =>
    r'a8bbfefeb6a765bb382ef211e9c5887ddea769dd';

/// Provider for last WebSocket event timestamp
///
/// Tracks when the last event was received from WebSocket.
/// Useful for detecting stale connections.
///
/// Copied from [LastEventTimestamp].
@ProviderFor(LastEventTimestamp)
final lastEventTimestampProvider =
    AutoDisposeNotifierProvider<LastEventTimestamp, DateTime?>.internal(
  LastEventTimestamp.new,
  name: r'lastEventTimestampProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$lastEventTimestampHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LastEventTimestamp = AutoDisposeNotifier<DateTime?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
