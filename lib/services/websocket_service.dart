/// WebSocket Service for Trading MCP Client
///
/// Provides robust WebSocket connection management with automatic reconnection,
/// heartbeat monitoring, event broadcasting, and subscription management.
///
/// Features:
/// - Automatic reconnection with exponential backoff
/// - Heartbeat/ping every 30 seconds
/// - Event-based message routing to typed streams
/// - Subscription management
/// - Connection state tracking
/// - Comprehensive error handling and logging

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../models/websocket_event.dart';

/// WebSocket Service for real-time backend communication
class WebSocketService {
  /// WebSocket server URL
  final String url;

  /// Logger instance for detailed logging
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// WebSocket channel
  WebSocketChannel? _channel;

  /// Current connection state
  WebSocketConnectionState _connectionState =
      WebSocketConnectionState.disconnected;

  /// Subscription to WebSocket stream
  StreamSubscription? _messageSubscription;

  /// Heartbeat timer for periodic ping messages
  Timer? _heartbeatTimer;

  /// Reconnection timer for automatic reconnection
  Timer? _reconnectTimer;

  /// Current backoff delay in seconds
  int _currentBackoffDelay = 1;

  /// Maximum backoff delay in seconds
  static const int _maxBackoffDelay = 30;

  /// Heartbeat interval in seconds
  static const int _heartbeatInterval = 30;

  /// List of subscribed channels
  final Set<String> _subscribedChannels = {};

  // Stream Controllers for event broadcasting
  final _positionUpdateController =
      StreamController<Position>.broadcast();
  final _tradeExecutedController =
      StreamController<Trade>.broadcast();
  final _metricsUpdateController =
      StreamController<Metrics>.broadcast();
  final _alertController = StreamController<Alert>.broadcast();
  final _killSwitchController =
      StreamController<KillSwitchEvent>.broadcast();
  final _connectionStateController =
      StreamController<WebSocketConnectionState>.broadcast();

  /// Stream of position updates
  Stream<Position> get positionUpdates =>
      _positionUpdateController.stream;

  /// Stream of executed trades
  Stream<Trade> get tradeExecuted =>
      _tradeExecutedController.stream;

  /// Stream of metrics updates
  Stream<Metrics> get metricsUpdates =>
      _metricsUpdateController.stream;

  /// Stream of alerts
  Stream<Alert> get alerts => _alertController.stream;

  /// Stream of kill switch events
  Stream<KillSwitchEvent> get killSwitchEvents =>
      _killSwitchController.stream;

  /// Stream of connection state changes
  Stream<WebSocketConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  /// Current connection state
  WebSocketConnectionState get connectionState => _connectionState;

  /// Check if currently connected
  bool get isConnected =>
      _connectionState == WebSocketConnectionState.connected;

  /// Constructor
  WebSocketService({
    this.url = 'ws://localhost:8081/ws',
  }) {
    _logger.i('WebSocketService initialized with URL: $url');
  }

  /// Connect to WebSocket server
  ///
  /// Establishes WebSocket connection and sets up message handling.
  /// Automatically subscribes to previously subscribed channels.
  Future<void> connect() async {
    if (isConnected) {
      _logger.w('Already connected to WebSocket');
      return;
    }

    try {
      _updateConnectionState(WebSocketConnectionState.connecting);
      _logger.i('Connecting to WebSocket: $url');

      // Create WebSocket channel
      _channel = WebSocketChannel.connect(Uri.parse(url));

      // Wait for connection to be established
      await _channel?.ready;

      _logger.i('WebSocket connection established');
      _updateConnectionState(WebSocketConnectionState.connected);

      // Reset backoff delay on successful connection
      _currentBackoffDelay = 1;

      // Setup message handler
      _setupMessageHandler();

      // Start heartbeat
      _startHeartbeat();

      // Resubscribe to channels
      if (_subscribedChannels.isNotEmpty) {
        _logger.i('Resubscribing to ${_subscribedChannels.length} channels');
        await _sendSubscriptionMessage(_subscribedChannels.toList());
      }
    } catch (e, stackTrace) {
      _logger.e('WebSocket connection failed', error: e, stackTrace: stackTrace);
      _updateConnectionState(WebSocketConnectionState.error);
      _scheduleReconnect();
    }
  }

  /// Disconnect from WebSocket server
  ///
  /// Closes the connection and cleans up resources.
  /// Does not clear subscribed channels (they will be restored on reconnect).
  Future<void> disconnect() async {
    _logger.i('Disconnecting from WebSocket');

    // Stop timers
    _stopHeartbeat();
    _cancelReconnect();

    // Close message subscription
    await _messageSubscription?.cancel();
    _messageSubscription = null;

    // Close WebSocket channel
    await _channel?.sink.close(status.normalClosure);
    _channel = null;

    _updateConnectionState(WebSocketConnectionState.disconnected);
    _logger.i('WebSocket disconnected');
  }

  /// Reconnect to WebSocket server
  ///
  /// Disconnects and then reconnects immediately.
  Future<void> reconnect() async {
    _logger.i('Manual reconnection requested');
    await disconnect();
    await connect();
  }

  /// Subscribe to one or more channels
  ///
  /// Sends subscription message to server and adds channels to local set.
  /// Channels will be automatically resubscribed on reconnection.
  ///
  /// Example channels: 'positions', 'trades', 'metrics', 'alerts', 'kill_switch'
  Future<void> subscribe(List<String> channels) async {
    if (channels.isEmpty) {
      _logger.w('No channels provided for subscription');
      return;
    }

    _logger.i('Subscribing to channels: ${channels.join(', ')}');
    _subscribedChannels.addAll(channels);

    if (isConnected) {
      await _sendSubscriptionMessage(channels);
    } else {
      _logger.w('Not connected - channels will be subscribed on connection');
    }
  }

  /// Unsubscribe from one or more channels
  ///
  /// Sends unsubscription message to server and removes channels from local set.
  Future<void> unsubscribe(List<String> channels) async {
    if (channels.isEmpty) {
      _logger.w('No channels provided for unsubscription');
      return;
    }

    _logger.i('Unsubscribing from channels: ${channels.join(', ')}');
    _subscribedChannels.removeAll(channels);

    if (isConnected) {
      await _sendUnsubscriptionMessage(channels);
    }
  }

  /// Get list of currently subscribed channels
  List<String> getSubscribedChannels() {
    return _subscribedChannels.toList();
  }

  /// Dispose of all resources
  ///
  /// Closes all streams and disconnects from server.
  /// Should be called when service is no longer needed.
  Future<void> dispose() async {
    _logger.i('Disposing WebSocketService');

    await disconnect();

    // Close all stream controllers
    await _positionUpdateController.close();
    await _tradeExecutedController.close();
    await _metricsUpdateController.close();
    await _alertController.close();
    await _killSwitchController.close();
    await _connectionStateController.close();

    _subscribedChannels.clear();

    _logger.i('WebSocketService disposed');
  }

  // Private Methods

  /// Setup message handler for incoming WebSocket messages
  void _setupMessageHandler() {
    _messageSubscription = _channel?.stream.listen(
      _handleMessage,
      onError: _handleError,
      onDone: _handleDone,
      cancelOnError: false,
    );
  }

  /// Handle incoming WebSocket message
  void _handleMessage(dynamic message) {
    try {
      if (message is String) {
        _logger.d('Received message: ${message.length > 200 ? message.substring(0, 200) + '...' : message}');

        final Map<String, dynamic> json = jsonDecode(message);
        final String type = json['type'] as String;

        // Route message to appropriate stream based on type
        switch (type) {
          case 'position_update':
            _handlePositionUpdate(json);
            break;
          case 'trade_executed':
            _handleTradeExecuted(json);
            break;
          case 'metrics_update':
            _handleMetricsUpdate(json);
            break;
          case 'alert':
            _handleAlert(json);
            break;
          case 'kill_switch':
            _handleKillSwitch(json);
            break;
          case 'pong':
            _logger.d('Received pong from server');
            break;
          default:
            _logger.w('Unknown message type: $type');
        }
      }
    } catch (e, stackTrace) {
      _logger.e('Error handling message', error: e, stackTrace: stackTrace);
    }
  }

  /// Handle position update message
  void _handlePositionUpdate(Map<String, dynamic> json) {
    try {
      final position = Position.fromJson(json['data'] as Map<String, dynamic>);
      _logger.d('Position update: ${position.id} - ${position.symbol}');
      _positionUpdateController.add(position);
    } catch (e, stackTrace) {
      _logger.e('Error parsing position update', error: e, stackTrace: stackTrace);
    }
  }

  /// Handle trade executed message
  void _handleTradeExecuted(Map<String, dynamic> json) {
    try {
      final trade = Trade.fromJson(json['data'] as Map<String, dynamic>);
      _logger.d('Trade executed: ${trade.id} - ${trade.symbol}');
      _tradeExecutedController.add(trade);
    } catch (e, stackTrace) {
      _logger.e('Error parsing trade executed', error: e, stackTrace: stackTrace);
    }
  }

  /// Handle metrics update message
  void _handleMetricsUpdate(Map<String, dynamic> json) {
    try {
      final metrics = Metrics.fromJson(json['data'] as Map<String, dynamic>);
      _logger.d('Metrics update: totalPnl=${metrics.totalPnl}, winRate=${metrics.winRate}%');
      _metricsUpdateController.add(metrics);
    } catch (e, stackTrace) {
      _logger.e('Error parsing metrics update', error: e, stackTrace: stackTrace);
    }
  }

  /// Handle alert message
  void _handleAlert(Map<String, dynamic> json) {
    try {
      final alert = Alert.fromJson(json['data'] as Map<String, dynamic>);
      _logger.w('Alert received: [${alert.severity}] ${alert.message}');
      _alertController.add(alert);
    } catch (e, stackTrace) {
      _logger.e('Error parsing alert', error: e, stackTrace: stackTrace);
    }
  }

  /// Handle kill switch message
  void _handleKillSwitch(Map<String, dynamic> json) {
    try {
      final killSwitch = KillSwitchEvent.fromJson(json['data'] as Map<String, dynamic>);
      _logger.w('Kill switch event: active=${killSwitch.active}, reason=${killSwitch.reason}');
      _killSwitchController.add(killSwitch);
    } catch (e, stackTrace) {
      _logger.e('Error parsing kill switch event', error: e, stackTrace: stackTrace);
    }
  }

  /// Handle WebSocket error
  void _handleError(Object error, StackTrace stackTrace) {
    _logger.e('WebSocket error', error: error, stackTrace: stackTrace);
    _updateConnectionState(WebSocketConnectionState.error);
    _scheduleReconnect();
  }

  /// Handle WebSocket done (connection closed)
  void _handleDone() {
    _logger.w('WebSocket connection closed');
    _stopHeartbeat();

    if (_connectionState != WebSocketConnectionState.disconnected) {
      _updateConnectionState(WebSocketConnectionState.error);
      _scheduleReconnect();
    }
  }

  /// Update connection state and notify listeners
  void _updateConnectionState(WebSocketConnectionState newState) {
    if (_connectionState != newState) {
      _connectionState = newState;
      _connectionStateController.add(newState);
      _logger.i('Connection state changed: ${newState.displayName}');
    }
  }

  /// Start heartbeat timer
  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: _heartbeatInterval),
      (_) => _sendHeartbeat(),
    );
    _logger.d('Heartbeat started (interval: ${_heartbeatInterval}s)');
  }

  /// Stop heartbeat timer
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Send heartbeat ping message
  void _sendHeartbeat() {
    if (isConnected) {
      try {
        _sendMessage({'action': 'ping'});
        _logger.d('Heartbeat ping sent');
      } catch (e) {
        _logger.e('Failed to send heartbeat', error: e);
      }
    }
  }

  /// Send subscription message to server
  Future<void> _sendSubscriptionMessage(List<String> channels) async {
    try {
      final message = {
        'action': 'subscribe',
        'channels': channels,
      };
      _sendMessage(message);
      _logger.i('Subscription message sent for channels: ${channels.join(', ')}');
    } catch (e, stackTrace) {
      _logger.e('Failed to send subscription message', error: e, stackTrace: stackTrace);
    }
  }

  /// Send unsubscription message to server
  Future<void> _sendUnsubscriptionMessage(List<String> channels) async {
    try {
      final message = {
        'action': 'unsubscribe',
        'channels': channels,
      };
      _sendMessage(message);
      _logger.i('Unsubscription message sent for channels: ${channels.join(', ')}');
    } catch (e, stackTrace) {
      _logger.e('Failed to send unsubscription message', error: e, stackTrace: stackTrace);
    }
  }

  /// Send a message through WebSocket
  void _sendMessage(Map<String, dynamic> message) {
    if (_channel == null) {
      throw Exception('WebSocket not connected');
    }

    final jsonMessage = jsonEncode(message);
    _channel!.sink.add(jsonMessage);
  }

  /// Schedule automatic reconnection with exponential backoff
  void _scheduleReconnect() {
    _cancelReconnect();

    _logger.i('Scheduling reconnection in ${_currentBackoffDelay}s');

    _reconnectTimer = Timer(
      Duration(seconds: _currentBackoffDelay),
      () async {
        _logger.i('Attempting automatic reconnection...');
        await connect();
      },
    );

    // Increase backoff delay for next attempt (exponential backoff)
    _currentBackoffDelay = (_currentBackoffDelay * 2).clamp(1, _maxBackoffDelay);
  }

  /// Cancel scheduled reconnection
  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }
}

/// WebSocket Service Provider (Singleton)
///
/// Provides a singleton instance of WebSocketService for app-wide use.
class WebSocketServiceProvider {
  static WebSocketService? _instance;

  /// Get singleton instance
  static WebSocketService get instance {
    _instance ??= WebSocketService();
    return _instance!;
  }

  /// Initialize with custom URL
  static void initialize({String? url}) {
    _instance = WebSocketService(
      url: url ?? 'ws://localhost:8081/ws',
    );
  }

  /// Reset singleton instance
  @visibleForTesting
  static void reset() {
    _instance?.dispose();
    _instance = null;
  }
}
