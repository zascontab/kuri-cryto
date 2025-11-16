/// WebSocket Event Models for Trading MCP Client
///
/// This file contains all data models for WebSocket events received from the backend.
/// Supports Position updates, Trade executions, Metrics updates, Alerts, and Kill Switch events.

import 'package:flutter/foundation.dart';

/// Generic WebSocket Event wrapper
///
/// Wraps all WebSocket messages with type information and timestamp.
/// Type parameter [T] represents the data payload type.
class WebSocketEvent<T> {
  /// Event type identifier (e.g., 'position_update', 'trade_executed')
  final String type;

  /// Event payload data
  final T data;

  /// Event timestamp
  final DateTime timestamp;

  WebSocketEvent({
    required this.type,
    required this.data,
    required this.timestamp,
  });

  /// Create from JSON
  factory WebSocketEvent.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) dataFactory,
  ) {
    return WebSocketEvent<T>(
      type: json['type'] as String,
      data: dataFactory(json['data'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) dataToJson) {
    return {
      'type': type,
      'data': dataToJson(data),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() => 'WebSocketEvent(type: $type, timestamp: $timestamp)';
}

/// Position model representing an open or closed trading position
class Position {
  /// Unique position identifier
  final String id;

  /// Trading symbol (e.g., 'DOGE-USDT', 'BTC-USDT')
  final String symbol;

  /// Position side: 'long' or 'short'
  final String side;

  /// Entry price
  final double entryPrice;

  /// Current market price
  final double currentPrice;

  /// Position size
  final double size;

  /// Leverage multiplier
  final double leverage;

  /// Stop loss price
  final double stopLoss;

  /// Take profit price
  final double takeProfit;

  /// Unrealized profit/loss
  final double unrealizedPnl;

  /// Realized profit/loss (for closed positions)
  final double? realizedPnl;

  /// Time when position was opened
  final DateTime openTime;

  /// Time when position was closed (null if still open)
  final DateTime? closeTime;

  /// Strategy name that created this position
  final String strategy;

  /// Position status: 'open', 'closing', 'closed'
  final String status;

  /// Reason for closing (only for closed positions)
  final String? closeReason;

  Position({
    required this.id,
    required this.symbol,
    required this.side,
    required this.entryPrice,
    required this.currentPrice,
    required this.size,
    required this.leverage,
    required this.stopLoss,
    required this.takeProfit,
    required this.unrealizedPnl,
    this.realizedPnl,
    required this.openTime,
    this.closeTime,
    required this.strategy,
    required this.status,
    this.closeReason,
  });

  /// Create from JSON
  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      side: json['side'] as String,
      entryPrice: (json['entry_price'] as num).toDouble(),
      currentPrice: (json['current_price'] as num).toDouble(),
      size: (json['size'] as num).toDouble(),
      leverage: (json['leverage'] as num).toDouble(),
      stopLoss: (json['stop_loss'] as num).toDouble(),
      takeProfit: (json['take_profit'] as num).toDouble(),
      unrealizedPnl: (json['unrealized_pnl'] as num).toDouble(),
      realizedPnl: json['realized_pnl'] != null
          ? (json['realized_pnl'] as num).toDouble()
          : null,
      openTime: DateTime.parse(json['open_time'] as String),
      closeTime: json['close_time'] != null
          ? DateTime.parse(json['close_time'] as String)
          : null,
      strategy: json['strategy'] as String,
      status: json['status'] as String,
      closeReason: json['close_reason'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'side': side,
      'entry_price': entryPrice,
      'current_price': currentPrice,
      'size': size,
      'leverage': leverage,
      'stop_loss': stopLoss,
      'take_profit': takeProfit,
      'unrealized_pnl': unrealizedPnl,
      'realized_pnl': realizedPnl,
      'open_time': openTime.toIso8601String(),
      'close_time': closeTime?.toIso8601String(),
      'strategy': strategy,
      'status': status,
      'close_reason': closeReason,
    };
  }

  /// Calculate profit/loss percentage
  double get pnlPercentage {
    if (entryPrice == 0) return 0.0;
    return ((currentPrice - entryPrice) / entryPrice) * 100 *
        (side == 'long' ? 1 : -1);
  }

  /// Check if position is profitable
  bool get isProfitable => unrealizedPnl > 0;

  /// Check if position is open
  bool get isOpen => status == 'open';

  @override
  String toString() =>
      'Position(id: $id, symbol: $symbol, side: $side, pnl: $unrealizedPnl)';
}

/// Trade model representing an executed order
class Trade {
  /// Unique trade identifier
  final String id;

  /// Order identifier
  final String orderId;

  /// Trading symbol
  final String symbol;

  /// Trade side: 'buy' or 'sell'
  final String side;

  /// Order type: 'market', 'limit', 'stop'
  final String type;

  /// Execution price
  final double price;

  /// Trade size
  final double size;

  /// Order status: 'pending', 'filled', 'cancelled', 'failed'
  final String status;

  /// Execution latency in milliseconds
  final double latencyMs;

  /// Trade execution timestamp
  final DateTime timestamp;

  Trade({
    required this.id,
    required this.orderId,
    required this.symbol,
    required this.side,
    required this.type,
    required this.price,
    required this.size,
    required this.status,
    required this.latencyMs,
    required this.timestamp,
  });

  /// Create from JSON
  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      id: json['id'] as String? ?? json['order_id'] as String,
      orderId: json['order_id'] as String,
      symbol: json['symbol'] as String,
      side: json['side'] as String,
      type: json['type'] as String? ?? 'market',
      price: (json['price'] as num).toDouble(),
      size: (json['size'] as num).toDouble(),
      status: json['status'] as String,
      latencyMs: json['latency_ms'] != null
          ? (json['latency_ms'] as num).toDouble()
          : 0.0,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'symbol': symbol,
      'side': side,
      'type': type,
      'price': price,
      'size': size,
      'status': status,
      'latency_ms': latencyMs,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Check if trade is filled
  bool get isFilled => status == 'filled';

  /// Check if trade is pending
  bool get isPending => status == 'pending';

  @override
  String toString() =>
      'Trade(id: $id, symbol: $symbol, side: $side, price: $price)';
}

/// Metrics model representing system performance metrics
class Metrics {
  /// Total number of trades
  final int totalTrades;

  /// Number of winning trades
  final int? winningTrades;

  /// Number of losing trades
  final int? losingTrades;

  /// Win rate percentage (0-100)
  final double winRate;

  /// Total profit/loss
  final double totalPnl;

  /// Daily profit/loss
  final double dailyPnl;

  /// Weekly profit/loss
  final double? weeklyPnl;

  /// Monthly profit/loss
  final double? monthlyPnl;

  /// Number of currently active positions
  final int activePositions;

  /// Average execution latency in milliseconds
  final double avgLatencyMs;

  /// Average win amount
  final double? avgWin;

  /// Average loss amount
  final double? avgLoss;

  /// Profit factor (total wins / total losses)
  final double? profitFactor;

  /// Sharpe ratio
  final double? sharpeRatio;

  /// Maximum drawdown
  final double? maxDrawdown;

  /// Average slippage percentage
  final double? avgSlippagePct;

  Metrics({
    required this.totalTrades,
    this.winningTrades,
    this.losingTrades,
    required this.winRate,
    required this.totalPnl,
    required this.dailyPnl,
    this.weeklyPnl,
    this.monthlyPnl,
    required this.activePositions,
    required this.avgLatencyMs,
    this.avgWin,
    this.avgLoss,
    this.profitFactor,
    this.sharpeRatio,
    this.maxDrawdown,
    this.avgSlippagePct,
  });

  /// Create from JSON
  factory Metrics.fromJson(Map<String, dynamic> json) {
    return Metrics(
      totalTrades: json['total_trades'] as int? ?? 0,
      winningTrades: json['winning_trades'] as int?,
      losingTrades: json['losing_trades'] as int?,
      winRate: (json['win_rate'] as num?)?.toDouble() ?? 0.0,
      totalPnl: (json['total_pnl'] as num?)?.toDouble() ?? 0.0,
      dailyPnl: (json['daily_pnl'] as num?)?.toDouble() ?? 0.0,
      weeklyPnl: (json['weekly_pnl'] as num?)?.toDouble(),
      monthlyPnl: (json['monthly_pnl'] as num?)?.toDouble(),
      activePositions: json['active_positions'] as int? ?? 0,
      avgLatencyMs: (json['avg_latency_ms'] as num?)?.toDouble() ?? 0.0,
      avgWin: (json['avg_win'] as num?)?.toDouble(),
      avgLoss: (json['avg_loss'] as num?)?.toDouble(),
      profitFactor: (json['profit_factor'] as num?)?.toDouble(),
      sharpeRatio: (json['sharpe_ratio'] as num?)?.toDouble(),
      maxDrawdown: (json['max_drawdown'] as num?)?.toDouble(),
      avgSlippagePct: (json['avg_slippage_pct'] as num?)?.toDouble(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'total_trades': totalTrades,
      'winning_trades': winningTrades,
      'losing_trades': losingTrades,
      'win_rate': winRate,
      'total_pnl': totalPnl,
      'daily_pnl': dailyPnl,
      'weekly_pnl': weeklyPnl,
      'monthly_pnl': monthlyPnl,
      'active_positions': activePositions,
      'avg_latency_ms': avgLatencyMs,
      'avg_win': avgWin,
      'avg_loss': avgLoss,
      'profit_factor': profitFactor,
      'sharpe_ratio': sharpeRatio,
      'max_drawdown': maxDrawdown,
      'avg_slippage_pct': avgSlippagePct,
    };
  }

  @override
  String toString() =>
      'Metrics(totalTrades: $totalTrades, winRate: $winRate%, pnl: $totalPnl)';
}

/// Alert model representing system alerts
class Alert {
  /// Unique alert identifier
  final String id;

  /// Alert type identifier
  final String type;

  /// Alert severity: 'info', 'warning', 'critical'
  final String severity;

  /// Alert message
  final String message;

  /// Alert trigger name
  final String trigger;

  /// Trigger value (optional)
  final double? value;

  /// Alert timestamp
  final DateTime timestamp;

  /// Whether alert has been acknowledged
  final bool acknowledged;

  Alert({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    required this.trigger,
    this.value,
    required this.timestamp,
    this.acknowledged = false,
  });

  /// Create from JSON
  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] as String? ?? '',
      type: json['type'] as String,
      severity: json['severity'] as String,
      message: json['message'] as String,
      trigger: json['trigger'] as String,
      value: json['value'] != null ? (json['value'] as num).toDouble() : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
      acknowledged: json['acknowledged'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'severity': severity,
      'message': message,
      'trigger': trigger,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'acknowledged': acknowledged,
    };
  }

  /// Check if alert is critical
  bool get isCritical => severity == 'critical';

  /// Check if alert is warning
  bool get isWarning => severity == 'warning';

  /// Check if alert is info
  bool get isInfo => severity == 'info';

  @override
  String toString() =>
      'Alert(id: $id, severity: $severity, message: $message)';
}

/// Kill Switch Event model
class KillSwitchEvent {
  /// Whether kill switch is active
  final bool active;

  /// Reason for activation/deactivation
  final String reason;

  /// Event timestamp
  final DateTime timestamp;

  KillSwitchEvent({
    required this.active,
    required this.reason,
    required this.timestamp,
  });

  /// Create from JSON
  factory KillSwitchEvent.fromJson(Map<String, dynamic> json) {
    return KillSwitchEvent(
      active: json['active'] as bool,
      reason: json['reason'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'active': active,
      'reason': reason,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'KillSwitchEvent(active: $active, reason: $reason, timestamp: $timestamp)';
}

/// WebSocket connection state
enum WebSocketConnectionState {
  /// Attempting to connect
  connecting,

  /// Successfully connected
  connected,

  /// Disconnected (not attempting to reconnect)
  disconnected,

  /// Connection error (will attempt to reconnect)
  error,
}

/// Extension for WebSocketConnectionState
extension WebSocketConnectionStateExtension on WebSocketConnectionState {
  /// Human-readable name
  String get displayName {
    switch (this) {
      case WebSocketConnectionState.connecting:
        return 'Connecting';
      case WebSocketConnectionState.connected:
        return 'Connected';
      case WebSocketConnectionState.disconnected:
        return 'Disconnected';
      case WebSocketConnectionState.error:
        return 'Error';
    }
  }

  /// Check if connected
  bool get isConnected => this == WebSocketConnectionState.connected;
}
