import 'package:hive_flutter/hive_flutter.dart';
import '../models/position.dart';
import '../models/trade.dart';
import '../models/strategy.dart';
import '../models/risk_state.dart';
import '../models/metrics.dart';
import '../models/system_status.dart';

/// Service for managing local cache of trading data using Hive
///
/// Provides offline capabilities and fast data access for the app.
/// Automatically manages cache expiration and synchronization.
class CacheService {
  // Box names for different data types
  static const String _positionsBox = 'positions';
  static const String _tradesBox = 'trades';
  static const String _strategiesBox = 'strategies';
  static const String _riskStateBox = 'risk_state';
  static const String _metricsBox = 'metrics';
  static const String _systemStatusBox = 'system_status';
  static const String _metadataBox = 'cache_metadata';

  // Cache expiration times
  static const Duration _metricsExpiration = Duration(hours: 24);
  static const Duration _positionsExpiration = Duration(hours: 1);
  static const Duration _strategiesExpiration = Duration(hours: 6);
  static const Duration _generalExpiration = Duration(hours: 24);

  // Singleton instance
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // Box instances
  Box<Position>? _positions;
  Box<Trade>? _trades;
  Box<Strategy>? _strategies;
  Box<RiskState>? _riskState;
  Box<Metrics>? _metrics;
  Box<SystemStatus>? _systemStatus;
  Box<dynamic>? _metadata;

  /// Initialize all Hive boxes
  ///
  /// Should be called after Hive.initFlutter() and adapter registration
  Future<void> init() async {
    _positions = await Hive.openBox<Position>(_positionsBox);
    _trades = await Hive.openBox<Trade>(_tradesBox);
    _strategies = await Hive.openBox<Strategy>(_strategiesBox);
    _riskState = await Hive.openBox<RiskState>(_riskStateBox);
    _metrics = await Hive.openBox<Metrics>(_metricsBox);
    _systemStatus = await Hive.openBox<SystemStatus>(_systemStatusBox);
    _metadata = await Hive.openBox(_metadataBox);
  }

  /// Close all boxes
  Future<void> close() async {
    await _positions?.close();
    await _trades?.close();
    await _strategies?.close();
    await _riskState?.close();
    await _metrics?.close();
    await _systemStatus?.close();
    await _metadata?.close();
  }

  // ==================== POSITIONS ====================

  /// Save a single position to cache
  Future<void> savePosition(Position position) async {
    await _positions?.put(position.id, position);
    await _updateTimestamp('position_${position.id}');
  }

  /// Save multiple positions to cache
  Future<void> savePositions(List<Position> positions) async {
    final Map<String, Position> positionsMap = {
      for (var position in positions) position.id: position,
    };
    await _positions?.putAll(positionsMap);
    await _updateTimestamp('positions_batch');
  }

  /// Get a specific position by ID
  Position? getPosition(String id) {
    return _positions?.get(id);
  }

  /// Get all cached positions
  List<Position> getAllPositions() {
    return _positions?.values.toList() ?? [];
  }

  /// Get only open positions
  List<Position> getOpenPositions() {
    return _positions?.values.where((p) => p.isOpen).toList() ?? [];
  }

  /// Delete a position from cache
  Future<void> deletePosition(String id) async {
    await _positions?.delete(id);
  }

  /// Clear all positions
  Future<void> clearPositions() async {
    await _positions?.clear();
  }

  // ==================== TRADES ====================

  /// Save a single trade to cache
  Future<void> saveTrade(Trade trade) async {
    await _trades?.put(trade.id, trade);
    await _updateTimestamp('trade_${trade.id}');
  }

  /// Save multiple trades to cache
  Future<void> saveTrades(List<Trade> trades) async {
    final Map<String, Trade> tradesMap = {
      for (var trade in trades) trade.id: trade,
    };
    await _trades?.putAll(tradesMap);
    await _updateTimestamp('trades_batch');
  }

  /// Get a specific trade by ID
  Trade? getTrade(String id) {
    return _trades?.get(id);
  }

  /// Get all cached trades
  List<Trade> getAllTrades() {
    return _trades?.values.toList() ?? [];
  }

  /// Get trades within the last 24 hours
  List<Trade> getRecentTrades() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    return _trades?.values
            .where((trade) => trade.timestamp.isAfter(cutoff))
            .toList() ??
        [];
  }

  /// Clear all trades
  Future<void> clearTrades() async {
    await _trades?.clear();
  }

  // ==================== STRATEGIES ====================

  /// Save a single strategy to cache
  Future<void> saveStrategy(Strategy strategy) async {
    await _strategies?.put(strategy.name, strategy);
    await _updateTimestamp('strategy_${strategy.name}');
  }

  /// Save multiple strategies to cache
  Future<void> saveStrategies(List<Strategy> strategies) async {
    final Map<String, Strategy> strategiesMap = {
      for (var strategy in strategies) strategy.name: strategy,
    };
    await _strategies?.putAll(strategiesMap);
    await _updateTimestamp('strategies_batch');
  }

  /// Get a specific strategy by name
  Strategy? getStrategy(String name) {
    return _strategies?.get(name);
  }

  /// Get all cached strategies
  List<Strategy> getAllStrategies() {
    return _strategies?.values.toList() ?? [];
  }

  /// Get only active strategies
  List<Strategy> getActiveStrategies() {
    return _strategies?.values.where((s) => s.active).toList() ?? [];
  }

  /// Clear all strategies
  Future<void> clearStrategies() async {
    await _strategies?.clear();
  }

  // ==================== RISK STATE ====================

  /// Save risk state to cache
  Future<void> saveRiskState(RiskState riskState) async {
    await _riskState?.put('current', riskState);
    await _updateTimestamp('risk_state');
  }

  /// Get current risk state
  RiskState? getRiskState() {
    return _riskState?.get('current');
  }

  /// Clear risk state
  Future<void> clearRiskState() async {
    await _riskState?.clear();
  }

  // ==================== METRICS ====================

  /// Save metrics to cache with timestamp
  Future<void> saveMetrics(Metrics metrics) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await _metrics?.put('current', metrics);
    await _metrics?.put('metrics_$timestamp', metrics);
    await _updateTimestamp('metrics');
  }

  /// Get current metrics
  Metrics? getMetrics() {
    return _metrics?.get('current');
  }

  /// Get metrics history from last 24 hours
  List<Metrics> getMetricsHistory() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    final cutoffMs = cutoff.millisecondsSinceEpoch;

    return _metrics?.keys
            .where((key) =>
                key.toString().startsWith('metrics_') &&
                int.tryParse(key.toString().substring(8)) != null &&
                int.parse(key.toString().substring(8)) > cutoffMs)
            .map((key) => _metrics!.get(key))
            .whereType<Metrics>()
            .toList() ??
        [];
  }

  /// Clear old metrics (older than 24h)
  Future<void> cleanOldMetrics() async {
    final cutoff = DateTime.now().subtract(_metricsExpiration);
    final cutoffMs = cutoff.millisecondsSinceEpoch;

    final keysToDelete = _metrics?.keys
        .where((key) =>
            key.toString().startsWith('metrics_') &&
            int.tryParse(key.toString().substring(8)) != null &&
            int.parse(key.toString().substring(8)) < cutoffMs)
        .toList();

    if (keysToDelete != null) {
      await _metrics?.deleteAll(keysToDelete);
    }
  }

  /// Clear all metrics
  Future<void> clearMetrics() async {
    await _metrics?.clear();
  }

  // ==================== SYSTEM STATUS ====================

  /// Save system status to cache
  Future<void> saveSystemStatus(SystemStatus status) async {
    await _systemStatus?.put('current', status);
    await _updateTimestamp('system_status');
  }

  /// Get current system status
  SystemStatus? getSystemStatus() {
    return _systemStatus?.get('current');
  }

  /// Clear system status
  Future<void> clearSystemStatus() async {
    await _systemStatus?.clear();
  }

  // ==================== CACHE MANAGEMENT ====================

  /// Clean all old cached data based on expiration rules
  Future<void> cleanOldCache() async {
    await cleanOldMetrics();
    await _cleanOldTrades();
    await _cleanExpiredData();
  }

  /// Clean trades older than 24 hours
  Future<void> _cleanOldTrades() async {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    final keysToDelete = <String>[];

    _trades?.toMap().forEach((key, trade) {
      if (trade.timestamp.isBefore(cutoff)) {
        keysToDelete.add(key);
      }
    });

    if (keysToDelete.isNotEmpty) {
      await _trades?.deleteAll(keysToDelete);
    }
  }

  /// Clean expired data based on timestamps
  Future<void> _cleanExpiredData() async {
    final now = DateTime.now();

    // Clean positions if older than expiration
    final positionsTimestamp = _metadata?.get('positions_batch');
    if (positionsTimestamp is DateTime &&
        now.difference(positionsTimestamp) > _positionsExpiration) {
      await clearPositions();
    }

    // Clean strategies if older than expiration
    final strategiesTimestamp = _metadata?.get('strategies_batch');
    if (strategiesTimestamp is DateTime &&
        now.difference(strategiesTimestamp) > _strategiesExpiration) {
      await clearStrategies();
    }

    // Clean system status if older than expiration
    final statusTimestamp = _metadata?.get('system_status');
    if (statusTimestamp is DateTime &&
        now.difference(statusTimestamp) > _generalExpiration) {
      await clearSystemStatus();
    }

    // Clean risk state if older than expiration
    final riskTimestamp = _metadata?.get('risk_state');
    if (riskTimestamp is DateTime &&
        now.difference(riskTimestamp) > _generalExpiration) {
      await clearRiskState();
    }
  }

  /// Clear all cached data
  Future<void> clearAllCache() async {
    await _positions?.clear();
    await _trades?.clear();
    await _strategies?.clear();
    await _riskState?.clear();
    await _metrics?.clear();
    await _systemStatus?.clear();
    await _metadata?.clear();
  }

  /// Update timestamp for a specific data type
  Future<void> _updateTimestamp(String key) async {
    await _metadata?.put(key, DateTime.now());
  }

  /// Get last update timestamp for a data type
  DateTime? getLastUpdateTime(String key) {
    final timestamp = _metadata?.get(key);
    return timestamp is DateTime ? timestamp : null;
  }

  // ==================== CACHE STATUS ====================

  /// Check if cache is fresh (not expired)
  bool isCacheFresh(String dataType) {
    final timestamp = getLastUpdateTime(dataType);
    if (timestamp == null) return false;

    final now = DateTime.now();
    final age = now.difference(timestamp);

    switch (dataType) {
      case 'positions':
      case 'positions_batch':
        return age < _positionsExpiration;
      case 'metrics':
        return age < _metricsExpiration;
      case 'strategies':
      case 'strategies_batch':
        return age < _strategiesExpiration;
      default:
        return age < _generalExpiration;
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'positions_count': _positions?.length ?? 0,
      'trades_count': _trades?.length ?? 0,
      'strategies_count': _strategies?.length ?? 0,
      'has_risk_state': _riskState?.containsKey('current') ?? false,
      'has_metrics': _metrics?.containsKey('current') ?? false,
      'has_system_status': _systemStatus?.containsKey('current') ?? false,
      'last_positions_update': getLastUpdateTime('positions_batch'),
      'last_trades_update': getLastUpdateTime('trades_batch'),
      'last_strategies_update': getLastUpdateTime('strategies_batch'),
      'last_metrics_update': getLastUpdateTime('metrics'),
      'positions_fresh': isCacheFresh('positions_batch'),
      'metrics_fresh': isCacheFresh('metrics'),
      'strategies_fresh': isCacheFresh('strategies_batch'),
    };
  }

  // ==================== SYNC HELPERS ====================

  /// Check if we need to sync with backend
  bool needsSync(String dataType) {
    return !isCacheFresh(dataType);
  }

  /// Mark sync as completed for a data type
  Future<void> markSynced(String dataType) async {
    await _updateTimestamp(dataType);
  }
}
