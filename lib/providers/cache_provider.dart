import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cache_service.dart';

/// Provider for CacheService singleton
final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService.instance;
});

/// Provider for cache statistics
final cacheStatsProvider = Provider<CacheStats>((ref) {
  final cache = ref.watch(cacheServiceProvider);
  return cache.getStats();
});

/// Provider to check if a key exists in cache
final cacheHasKeyProvider = Provider.family<bool, String>((ref, key) {
  final cache = ref.watch(cacheServiceProvider);
  return cache.has(key);
});

/// Provider to get cached data by key
final cachedDataProvider = Provider.family<dynamic, String>((ref, key) {
  final cache = ref.watch(cacheServiceProvider);
  return cache.get(key);
});

/// Provider for comprehensive analysis cache
final cachedAnalysisProvider =
    Provider.family<Map<String, dynamic>?, String>((ref, symbol) {
  final cache = ref.watch(cacheServiceProvider);
  final cacheKey = CacheKeys.comprehensiveAnalysisKey(symbol);
  return cache.get<Map<String, dynamic>>(cacheKey);
});

/// Provider for bot status cache
final cachedBotStatusProvider = Provider<Map<String, dynamic>?>((ref) {
  final cache = ref.watch(cacheServiceProvider);
  return cache.get<Map<String, dynamic>>(CacheKeys.botStatus);
});

/// Provider for bot config cache
final cachedBotConfigProvider = Provider<Map<String, dynamic>?>((ref) {
  final cache = ref.watch(cacheServiceProvider);
  return cache.get<Map<String, dynamic>>(CacheKeys.botConfig);
});

/// Provider for bot positions cache
final cachedBotPositionsProvider = Provider<Map<String, dynamic>?>((ref) {
  final cache = ref.watch(cacheServiceProvider);
  return cache.get<Map<String, dynamic>>(CacheKeys.botPositions);
});

/// Provider for health check cache
final cachedHealthCheckProvider = Provider<Map<String, dynamic>?>((ref) {
  final cache = ref.watch(cacheServiceProvider);
  return cache.get<Map<String, dynamic>>(CacheKeys.healthCheck);
});
