/* /// Example usage of WebSocketService
///
/// This file demonstrates how to use the WebSocketService in your Flutter app.
library;

import 'package:flutter/material.dart';
import 'websocket_service.dart';
import '../models/websocket_event.dart';

/// Example widget demonstrating WebSocket usage
class WebSocketExample extends StatefulWidget {
  const WebSocketExample({super.key});

  @override
  State<WebSocketExample> createState() => _WebSocketExampleState();
}

class _WebSocketExampleState extends State<WebSocketExample> {
  late WebSocketService _wsService;
  WebSocketConnectionState _connectionState =
      WebSocketConnectionState.disconnected;
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    // Initialize WebSocket service
    _wsService = WebSocketServiceProvider.instance;

    // Listen to connection state changes
    _wsService.connectionStateStream.listen((state) {
      setState(() {
        _connectionState = state;
        _addLog('Connection state: ${state.displayName}');
      });
    });

    // Listen to position updates
    _wsService.positionUpdates.listen((position) {
      _addLog('Position update: ${position.symbol} - PnL: ${position.unrealizedPnl}');
    });

    // Listen to trade executions
    _wsService.tradeExecuted.listen((trade) {
      _addLog('Trade executed: ${trade.symbol} ${trade.side} @ ${trade.price}');
    });

    // Listen to metrics updates
    _wsService.metricsUpdates.listen((metrics) {
      _addLog('Metrics: Total PnL: ${metrics.totalPnl}, Win Rate: ${metrics.winRate}%');
    });

    // Listen to alerts
    _wsService.alerts.listen((alert) {
      _addLog('ALERT [${alert.severity}]: ${alert.message}');
      if (alert.isCritical) {
        _showAlertDialog(alert);
      }
    });

    // Listen to kill switch events
    _wsService.killSwitchEvents.listen((event) {
      _addLog('KILL SWITCH: ${event.active ? 'ACTIVATED' : 'DEACTIVATED'} - ${event.reason}');
      if (event.active) {
        _showKillSwitchDialog(event);
      }
    });
  }

  void _addLog(String message) {
    setState(() {
      _logs.insert(0, '${DateTime.now().toIso8601String()}: $message');
      if (_logs.length > 50) {
        _logs.removeLast();
      }
    });
  }

  Future<void> _connect() async {
    await _wsService.connect();
  }

  Future<void> _disconnect() async {
    await _wsService.disconnect();
  }

  Future<void> _subscribe() async {
    await _wsService.subscribe([
      'positions',
      'trades',
      'metrics',
      'alerts',
      'kill_switch',
    ]);
    _addLog('Subscribed to all channels');
  }

  Future<void> _unsubscribe() async {
    final channels = _wsService.getSubscribedChannels();
    if (channels.isNotEmpty) {
      await _wsService.unsubscribe(channels);
      _addLog('Unsubscribed from all channels');
    }
  }

  void _showAlertDialog(AlertDialog alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Critical Alert: ${alert.type}'),
        content: Text(alert.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showKillSwitchDialog(KillSwitchEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Kill Switch Activated'),
        content: Text('Trading has been halted.\n\nReason: ${event.reason}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Example'),
        backgroundColor: _getStatusColor(),
      ),
      body: Column(
        children: [
          // Connection status bar
          Container(
            padding: const EdgeInsets.all(16),
            color: _getStatusColor().withOpacity(0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status: ${_connectionState.displayName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_connectionState == WebSocketConnectionState.connecting)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),

          // Control buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _connectionState.isConnected ? null : _connect,
                  icon: const Icon(Icons.power),
                  label: const Text('Connect'),
                ),
                ElevatedButton.icon(
                  onPressed: !_connectionState.isConnected ? null : _disconnect,
                  icon: const Icon(Icons.power_off),
                  label: const Text('Disconnect'),
                ),
                ElevatedButton.icon(
                  onPressed: _connectionState.isConnected ? _subscribe : null,
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Subscribe All'),
                ),
                ElevatedButton.icon(
                  onPressed: _connectionState.isConnected ? _unsubscribe : null,
                  icon: const Icon(Icons.remove_circle),
                  label: const Text('Unsubscribe All'),
                ),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _logs.clear()),
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Logs'),
                ),
              ],
            ),
          ),

          // Subscribed channels
          if (_wsService.getSubscribedChannels().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  children: _wsService.getSubscribedChannels().map((channel) {
                    return Chip(
                      label: Text(channel),
                      backgroundColor: Colors.blue.shade100,
                    );
                  }).toList(),
                ),
              ),
            ),

          const Divider(),

          // Event log
          Expanded(
            child: _logs.isEmpty
                ? const Center(
                    child: Text('No events yet. Connect and subscribe to start.'),
                  )
                : ListView.builder(
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          _getLogIcon(log),
                          size: 16,
                          color: _getLogColor(log),
                        ),
                        title: Text(
                          log,
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (_connectionState) {
      case WebSocketConnectionState.connected:
        return Colors.green;
      case WebSocketConnectionState.connecting:
        return Colors.orange;
      case WebSocketConnectionState.error:
        return Colors.red;
      case WebSocketConnectionState.disconnected:
        return Colors.grey;
    }
  }

  IconData _getLogIcon(String log) {
    if (log.contains('ALERT') || log.contains('KILL SWITCH')) {
      return Icons.warning;
    } else if (log.contains('Trade')) {
      return Icons.show_chart;
    } else if (log.contains('Position')) {
      return Icons.trending_up;
    } else if (log.contains('Metrics')) {
      return Icons.analytics;
    } else {
      return Icons.circle;
    }
  }

  Color _getLogColor(String log) {
    if (log.contains('CRITICAL') || log.contains('KILL SWITCH')) {
      return Colors.red;
    } else if (log.contains('ALERT')) {
      return Colors.orange;
    } else if (log.contains('Trade')) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }

  @override
  void dispose() {
    // Note: Don't dispose the singleton service here if it's used elsewhere
    // Only disconnect if this widget is the sole user
    super.dispose();
  }
}

/// Example of using WebSocket in a simple stateless context
class SimpleWebSocketExample {
  final WebSocketService _wsService = WebSocketServiceProvider.instance;

  Future<void> start() async {
    // Connect to WebSocket
    await _wsService.connect();

    // Subscribe to channels
    await _wsService.subscribe(['positions', 'trades', 'metrics']);

    // Listen to position updates
    _wsService.positionUpdates.listen((position) {
      print('Position: ${position.symbol} - PnL: ${position.unrealizedPnl}');
    });

    // Listen to trades
    _wsService.tradeExecuted.listen((trade) {
      print('Trade: ${trade.symbol} ${trade.side} @ ${trade.price}');
    });

    // Listen to metrics
    _wsService.metricsUpdates.listen((metrics) {
      print('Metrics - Total PnL: ${metrics.totalPnl}');
    });

    // Listen to alerts
    _wsService.alerts.listen((alert) {
      if (alert.isCritical) {
        print('CRITICAL ALERT: ${alert.message}');
      }
    });

    // Listen to kill switch
    _wsService.killSwitchEvents.listen((event) {
      if (event.active) {
        print('⚠️ KILL SWITCH ACTIVATED: ${event.reason}');
      }
    });
  }

  Future<void> stop() async {
    await _wsService.disconnect();
  }
}
 */
