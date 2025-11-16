/// Execution Statistics Models
///
/// Contains models for execution performance monitoring:
/// - Latency statistics
/// - Execution history
/// - Execution queue state
/// - Performance metrics

/// Latency Statistics
///
/// Contains latency metrics for order execution
class LatencyStats {
  /// Average latency in milliseconds
  final double avgLatency;

  /// 50th percentile latency (median)
  final double p50Latency;

  /// 95th percentile latency
  final double p95Latency;

  /// 99th percentile latency
  final double p99Latency;

  /// Maximum latency observed
  final double maxLatency;

  /// Minimum latency observed
  final double minLatency;

  /// Total number of executions measured
  final int totalExecutions;

  /// Timestamp of stats generation
  final DateTime timestamp;

  const LatencyStats({
    this.avgLatency = 0.0,
    this.p50Latency = 0.0,
    this.p95Latency = 0.0,
    this.p99Latency = 0.0,
    this.maxLatency = 0.0,
    this.minLatency = 0.0,
    this.totalExecutions = 0,
    required this.timestamp,
  });

  /// Create LatencyStats from JSON
  factory LatencyStats.fromJson(Map<String, dynamic> json) {
    try {
      return LatencyStats(
        avgLatency: _parseDouble(json['avg_latency']),
        p50Latency: _parseDouble(json['p50_latency']),
        p95Latency: _parseDouble(json['p95_latency']),
        p99Latency: _parseDouble(json['p99_latency']),
        maxLatency: _parseDouble(json['max_latency']),
        minLatency: _parseDouble(json['min_latency']),
        totalExecutions: _parseInt(json['total_executions']),
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'])
            : DateTime.now(),
      );
    } catch (e) {
      throw FormatException('Failed to parse LatencyStats from JSON: $e');
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'avg_latency': avgLatency,
      'p50_latency': p50Latency,
      'p95_latency': p95Latency,
      'p99_latency': p99Latency,
      'max_latency': maxLatency,
      'min_latency': minLatency,
      'total_executions': totalExecutions,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}

/// Execution History Entry
///
/// Represents a single execution in the history
class ExecutionHistoryEntry {
  /// Unique execution ID
  final String id;

  /// Trading symbol
  final String symbol;

  /// Order side (buy/sell)
  final String side;

  /// Order size
  final double size;

  /// Execution price
  final double price;

  /// Execution latency in milliseconds
  final double latency;

  /// Execution status (filled, partial, rejected)
  final String status;

  /// Timestamp of execution
  final DateTime timestamp;

  /// Strategy that triggered the execution
  final String? strategy;

  /// Optional error message
  final String? error;

  /// Slippage in basis points
  final double? slippage;

  const ExecutionHistoryEntry({
    required this.id,
    required this.symbol,
    required this.side,
    required this.size,
    required this.price,
    required this.latency,
    required this.status,
    required this.timestamp,
    this.strategy,
    this.error,
    this.slippage,
  });

  /// Create ExecutionHistoryEntry from JSON
  factory ExecutionHistoryEntry.fromJson(Map<String, dynamic> json) {
    try {
      return ExecutionHistoryEntry(
        id: json['id']?.toString() ?? '',
        symbol: json['symbol']?.toString() ?? '',
        side: json['side']?.toString() ?? '',
        size: _parseDouble(json['size']),
        price: _parseDouble(json['price']),
        latency: _parseDouble(json['latency']),
        status: json['status']?.toString() ?? 'unknown',
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'])
            : DateTime.now(),
        strategy: json['strategy']?.toString(),
        error: json['error']?.toString(),
        slippage: json['slippage'] != null ? _parseDouble(json['slippage']) : null,
      );
    } catch (e) {
      throw FormatException('Failed to parse ExecutionHistoryEntry from JSON: $e');
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'side': side,
      'size': size,
      'price': price,
      'latency': latency,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      if (strategy != null) 'strategy': strategy,
      if (error != null) 'error': error,
      if (slippage != null) 'slippage': slippage,
    };
  }

  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}

/// Execution History
///
/// Contains list of recent executions
class ExecutionHistory {
  /// List of execution entries
  final List<ExecutionHistoryEntry> executions;

  /// Total count of executions
  final int totalCount;

  const ExecutionHistory({
    this.executions = const [],
    this.totalCount = 0,
  });

  /// Create ExecutionHistory from JSON
  factory ExecutionHistory.fromJson(Map<String, dynamic> json) {
    try {
      final executionsList = json['executions'] as List<dynamic>? ?? [];
      final executions = executionsList
          .map((e) => ExecutionHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();

      return ExecutionHistory(
        executions: executions,
        totalCount: json['total_count'] as int? ?? executions.length,
      );
    } catch (e) {
      throw FormatException('Failed to parse ExecutionHistory from JSON: $e');
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'executions': executions.map((e) => e.toJson()).toList(),
      'total_count': totalCount,
    };
  }
}

/// Queue Entry
///
/// Represents an order in the execution queue
class QueueEntry {
  /// Order ID
  final String orderId;

  /// Trading symbol
  final String symbol;

  /// Order side
  final String side;

  /// Order size
  final double size;

  /// Order type (market, limit)
  final String orderType;

  /// Queue position
  final int position;

  /// Time in queue (milliseconds)
  final int timeInQueue;

  /// Order status
  final String status;

  const QueueEntry({
    required this.orderId,
    required this.symbol,
    required this.side,
    required this.size,
    required this.orderType,
    required this.position,
    required this.timeInQueue,
    required this.status,
  });

  /// Create QueueEntry from JSON
  factory QueueEntry.fromJson(Map<String, dynamic> json) {
    try {
      return QueueEntry(
        orderId: json['order_id']?.toString() ?? '',
        symbol: json['symbol']?.toString() ?? '',
        side: json['side']?.toString() ?? '',
        size: _parseDouble(json['size']),
        orderType: json['order_type']?.toString() ?? 'market',
        position: json['position'] as int? ?? 0,
        timeInQueue: json['time_in_queue'] as int? ?? 0,
        status: json['status']?.toString() ?? 'pending',
      );
    } catch (e) {
      throw FormatException('Failed to parse QueueEntry from JSON: $e');
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'symbol': symbol,
      'side': side,
      'size': size,
      'order_type': orderType,
      'position': position,
      'time_in_queue': timeInQueue,
      'status': status,
    };
  }

  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}

/// Execution Queue
///
/// Contains current state of execution queue
class ExecutionQueue {
  /// List of orders in queue
  final List<QueueEntry> orders;

  /// Total queue length
  final int queueLength;

  /// Average wait time in milliseconds
  final double avgWaitTime;

  /// Queue health status
  final String status;

  const ExecutionQueue({
    this.orders = const [],
    this.queueLength = 0,
    this.avgWaitTime = 0.0,
    this.status = 'healthy',
  });

  /// Create ExecutionQueue from JSON
  factory ExecutionQueue.fromJson(Map<String, dynamic> json) {
    try {
      final ordersList = json['orders'] as List<dynamic>? ?? [];
      final orders = ordersList
          .map((e) => QueueEntry.fromJson(e as Map<String, dynamic>))
          .toList();

      return ExecutionQueue(
        orders: orders,
        queueLength: json['queue_length'] as int? ?? orders.length,
        avgWaitTime: _parseDouble(json['avg_wait_time']),
        status: json['status']?.toString() ?? 'healthy',
      );
    } catch (e) {
      throw FormatException('Failed to parse ExecutionQueue from JSON: $e');
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'orders': orders.map((e) => e.toJson()).toList(),
      'queue_length': queueLength,
      'avg_wait_time': avgWaitTime,
      'status': status,
    };
  }

  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}

/// Execution Performance Metrics
///
/// Contains performance metrics for order execution
class ExecutionPerformance {
  /// Average slippage in basis points
  final double avgSlippage;

  /// Fill rate percentage
  final double fillRate;

  /// Number of successful executions
  final int successfulExecutions;

  /// Number of failed executions
  final int failedExecutions;

  /// Total executions
  final int totalExecutions;

  /// Error rate percentage
  final double errorRate;

  /// Average execution time in milliseconds
  final double avgExecutionTime;

  /// Execution success rate by symbol
  final Map<String, double> successRateBySymbol;

  /// Slippage by symbol
  final Map<String, double> slippageBySymbol;

  const ExecutionPerformance({
    this.avgSlippage = 0.0,
    this.fillRate = 0.0,
    this.successfulExecutions = 0,
    this.failedExecutions = 0,
    this.totalExecutions = 0,
    this.errorRate = 0.0,
    this.avgExecutionTime = 0.0,
    this.successRateBySymbol = const {},
    this.slippageBySymbol = const {},
  });

  /// Create ExecutionPerformance from JSON
  factory ExecutionPerformance.fromJson(Map<String, dynamic> json) {
    try {
      return ExecutionPerformance(
        avgSlippage: _parseDouble(json['avg_slippage']),
        fillRate: _parseDouble(json['fill_rate']),
        successfulExecutions: _parseInt(json['successful_executions']),
        failedExecutions: _parseInt(json['failed_executions']),
        totalExecutions: _parseInt(json['total_executions']),
        errorRate: _parseDouble(json['error_rate']),
        avgExecutionTime: _parseDouble(json['avg_execution_time']),
        successRateBySymbol: _parseMap(json['success_rate_by_symbol']),
        slippageBySymbol: _parseMap(json['slippage_by_symbol']),
      );
    } catch (e) {
      throw FormatException('Failed to parse ExecutionPerformance from JSON: $e');
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'avg_slippage': avgSlippage,
      'fill_rate': fillRate,
      'successful_executions': successfulExecutions,
      'failed_executions': failedExecutions,
      'total_executions': totalExecutions,
      'error_rate': errorRate,
      'avg_execution_time': avgExecutionTime,
      'success_rate_by_symbol': successRateBySymbol,
      'slippage_by_symbol': slippageBySymbol,
    };
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static Map<String, double> _parseMap(dynamic value) {
    if (value == null) return {};
    if (value is! Map) return {};

    final result = <String, double>{};
    value.forEach((key, val) {
      result[key.toString()] = _parseDouble(val);
    });
    return result;
  }
}

/// Metrics Export Result
///
/// Result from exporting metrics
class MetricsExportResult {
  /// Export format (csv, json, excel)
  final String format;

  /// File path or URL to download
  final String? filePath;

  /// Export data (if inline)
  final String? data;

  /// Export status
  final String status;

  /// Error message if failed
  final String? error;

  const MetricsExportResult({
    required this.format,
    this.filePath,
    this.data,
    this.status = 'success',
    this.error,
  });

  /// Create MetricsExportResult from JSON
  factory MetricsExportResult.fromJson(Map<String, dynamic> json) {
    try {
      return MetricsExportResult(
        format: json['format']?.toString() ?? 'json',
        filePath: json['file_path']?.toString(),
        data: json['data']?.toString(),
        status: json['status']?.toString() ?? 'success',
        error: json['error']?.toString(),
      );
    } catch (e) {
      throw FormatException('Failed to parse MetricsExportResult from JSON: $e');
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'format': format,
      if (filePath != null) 'file_path': filePath,
      if (data != null) 'data': data,
      'status': status,
      if (error != null) 'error': error,
    };
  }
}
