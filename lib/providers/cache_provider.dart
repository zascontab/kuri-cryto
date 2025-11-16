import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cache_service.dart';
import '../models/position.dart';
import '../models/trade.dart';
import '../models/strategy.dart';
import '../models/risk_state.dart';
import '../models/metrics.dart';
import '../models/system_status.dart';

/// Provider for CacheService singleton
final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

/// Provider for cached positions with auto-refresh
final cachedPositionsProvider = FutureProvider<List<Position>>((ref) async {
  final cache = ref.watch(cacheServiceProvider);
  return cache.getAllPositions();
});

/// Provider for cached open positions
final cachedOpenPositionsProvider = Provider<List<Position>>((ref) {
  final cache = ref.watch(cacheServiceProvider);
  return cache.getOpenPositions();
});

/// Provider for cached strategies
final cachedStrategiesProvider = Provider<List<Strategy>>((ref) {
  final cache = ref.watch(cacheServiceProvider);
  return cache.getAllStrategies();
});

/// Provider for cached active strategies
final cachedActiveStrategiesProvider = Provider<List<Strategy>>((ref) {
  final cache = ref.watch(cacheServiceProvider);
  return cache.getActiveStrategies();
});

/// Provider for cached trades
final cachedTradesProvider = Provider<List<Trade>>((ref) {
  final cache = ref.watch(cacheServiceProvider);
  return cache.getAllTrades();
});

/// Provider for recent cached trades (last 24h)
final cachedRecentTradesProvider = Provider<List<Trade>>((ref) {
  final cache = ref.watch(cacheServiceProvider);
  return cache.getRecentTrades();
});

/// Provider for cached risk state
final cachedRiskStateProvider = Provider<RiskState?>((ref) {
  final cache = ref.watch(cacheServiceProvider);
  return cache.getRiskState();
});

/// Provider for cached metrics
final cachedMetricsProvider = Provider<Metrics?>((ref) {
  final cache = ref.watch(cacheServiceProvider);
  return cache.getMetrics();
});

/// Provider for cached system status
final cachedSystemStatusProvider = Provider<SystemStatus?>((ref) {
  final cache = ref.watch(cacheServiceProvider);
  return cache.getSystemStatus();
});

/// Provider for cache statistics
final cacheStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final cache = ref.watch(cacheServiceProvider);
  return cache.getCacheStats();
});

/// Provider to check if cache needs sync for a specific data type
final cacheNeedsSyncProvider = Provider.family<bool, String>((ref, dataType) {
  final cache = ref.watch(cacheServiceProvider);
  return cache.needsSync(dataType);
});

/// Provider to check if cache is fresh for a specific data type
final cacheIsFreshProvider = Provider.family<bool, String>((ref, dataType) {
  final cache = ref.watch(cacheServiceProvider);
  return cache.isCacheFresh(dataType);
});
