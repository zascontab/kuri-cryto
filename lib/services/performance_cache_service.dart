import 'dart:async';
import 'logging_service.dart';
import 'cache_service.dart';

/// Enhanced performance optimization and caching service
///
/// Features:
/// - Intelligent caching with dynamic TTL values
/// - Cache-first data serving with background refresh
/// - Request deduplication to avoid redundant API calls
/// - Offline mode support with cached data indicators
/// - Performance monitoring and analytics
class PerformanceCacheService {
  static PerformanceCacheService? _instance;
  static PerformanceCacheService get instance =>
      _instance ??= PerformanceCacheService._();

  PerformanceCacheService._();

  final CacheService _cacheService = CacheService.instance;
  final Map<String, Future<dynamic>> _pendingRequests = {};
  final Map<String, DateTime> _lastRefreshTimes = {};
  final Map<String, int> _requestCounts = {};
  final Map<String, Duration> _averageResponseTimes = {};

  bool _isOfflineMode = false;
  Timer? _backgroundRefreshTimer;
  Timer? _performanceCleanupTimer;

  /// Initialize the performance cache service
  Future<void> initialize() async {
    await _cacheService.initialize();
    _startBackgroundRefresh();
    _startPerformanceCleanup();

    LoggingService.instance.info(
      'Performance cache service initialized',
      tag: 'PerformanceCacheService',
    );
  }

  /// Get data with intelligent caching and background refresh
  Future<T> getWithCaching<T>({
    required String key,
    required Future<T> Function() fetchFunction,
    Duration? customTtl,
    bool forceRefresh = false,
    bool enableBackgroundRefresh = true,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Check for pending request to avoid duplication
      if (_pendingRequests.containsKey(key) && !forceRefresh) {
        LoggingService.instance.debug(
          'Request deduplication - using pending request',
          tag: 'PerformanceCacheService',
          context: {'key': key},
        );
        return await _pendingRequests[key] as T;
      }

      // Get cached data if available and not force refresh
      if (!forceRefresh) {
        final cached = _cacheService.get<T>(key);
        if (cached != null) {
          _recordCacheHit(key, stopwatch.elapsed);

          // Schedule background refresh if enabled and data is getting stale
          if (enableBackgroundRefresh && _shouldBackgroundRefresh(key)) {
            _scheduleBackgroundRefresh(key, fetchFunction, customTtl);
          }

          return cached;
        }
      }

      // Create pending request to avoid duplication
      final pendingRequest =
          _executeFetchWithMetrics(key, fetchFunction, customTtl);
      _pendingRequests[key] = pendingRequest;

      try {
        final result = await pendingRequest;
        _recordCacheMiss(key, stopwatch.elapsed);
        return result as T;
      } finally {
        _pendingRequests.remove(key);
      }
    } catch (e) {
      _pendingRequests.remove(key);

      // In case of error, try to serve stale cached data if available
      if (!forceRefresh) {
        final staleData = _cacheService.get<T>(key);
        if (staleData != null) {
          LoggingService.instance.warning(
            'Serving stale cached data due to fetch error: $e',
            tag: 'PerformanceCacheService',
            context: {'key': key},
          );
          return staleData;
        }
      }

      rethrow;
    }
  }

  /// Execute fetch function with performance metrics
  Future<dynamic> _executeFetchWithMetrics<T>(
    String key,
    Future<T> Function() fetchFunction,
    Duration? customTtl,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await fetchFunction();
      final responseTime = stopwatch.elapsed;

      // Update performance metrics
      _updateResponseTimeMetrics(key, responseTime);
      _incrementRequestCount(key);

      // Cache the result with intelligent TTL
      final ttl = customTtl ?? _calculateIntelligentTtl(key, responseTime);
      await _cacheService.set(
        key,
        result,
        ttl: ttl,
        persistToDisk: _shouldPersistToDisk(key),
      );

      _lastRefreshTimes[key] = DateTime.now();

      LoggingService.instance.debug(
        'Data fetched and cached',
        tag: 'PerformanceCacheService',
        context: {
          'key': key,
          'response_time_ms': responseTime.inMilliseconds,
          'ttl_seconds': ttl.inSeconds,
        },
      );

      return result;
    } catch (e) {
      LoggingService.instance.error(
        'Failed to fetch data',
        tag: 'PerformanceCacheService',
        context: {'key': key},
        error: e,
      );
      rethrow;
    }
  }

  /// Calculate intelligent TTL based on data type and performance metrics
  Duration _calculateIntelligentTtl(String key, Duration responseTime) {
    // Base TTL values for different data types
    final baseTtl = _getBaseTtlForKey(key);

    // Adjust TTL based on response time (slower responses get longer TTL)
    final responseTimeMultiplier =
        responseTime.inMilliseconds > 1000 ? 1.5 : 1.0;

    // Adjust TTL based on request frequency (frequently requested data gets shorter TTL)
    final requestCount = _requestCounts[key] ?? 0;
    final frequencyMultiplier = requestCount > 10 ? 0.8 : 1.0;

    final adjustedTtl = Duration(
      seconds:
          (baseTtl.inSeconds * responseTimeMultiplier * frequencyMultiplier)
              .round(),
    );

    return adjustedTtl;
  }

  /// Get base TTL for different data types
  Duration _getBaseTtlForKey(String key) {
    if (key.contains('market_data') || key.contains('price')) {
      return const Duration(seconds: 30); // Market data changes frequently
    } else if (key.contains('technical_indicator')) {
      return const Duration(
          minutes: 2); // Technical indicators update less frequently
    } else if (key.contains('position') || key.contains('balance')) {
      return const Duration(
          minutes: 1); // Position data needs to be relatively fresh
    } else if (key.contains('bot_status')) {
      return const Duration(seconds: 15); // Bot status needs frequent updates
    } else if (key.contains('analysis') || key.contains('sentiment')) {
      return const Duration(minutes: 5); // Analysis data can be cached longer
    } else if (key.contains('backtest') || key.contains('optimization')) {
      return const Duration(
          hours: 1); // Backtest results can be cached for longer
    } else if (key.contains('config') || key.contains('settings')) {
      return const Duration(hours: 24); // Configuration data rarely changes
    }

    // Default TTL
    return const Duration(minutes: 5);
  }

  /// Determine if data should be persisted to disk
  bool _shouldPersistToDisk(String key) {
    // Persist important data that should survive app restarts
    return key.contains('config') ||
        key.contains('settings') ||
        key.contains('backtest') ||
        key.contains('optimization') ||
        key.contains('analysis');
  }

  /// Check if background refresh should be triggered
  bool _shouldBackgroundRefresh(String key) {
    final lastRefresh = _lastRefreshTimes[key];
    if (lastRefresh == null) return false;

    final timeSinceRefresh = DateTime.now().difference(lastRefresh);
    final refreshThreshold =
        _getBaseTtlForKey(key) * 0.7; // Refresh at 70% of TTL

    return timeSinceRefresh > refreshThreshold;
  }

  /// Schedule background refresh for stale data
  void _scheduleBackgroundRefresh<T>(
    String key,
    Future<T> Function() fetchFunction,
    Duration? customTtl,
  ) {
    // Don't schedule if already pending
    if (_pendingRequests.containsKey('bg_$key')) return;

    Timer(const Duration(milliseconds: 100), () async {
      try {
        _pendingRequests['bg_$key'] =
            _executeFetchWithMetrics(key, fetchFunction, customTtl);
        await _pendingRequests['bg_$key'];

        LoggingService.instance.debug(
          'Background refresh completed',
          tag: 'PerformanceCacheService',
          context: {'key': key},
        );
      } catch (e) {
        LoggingService.instance.warning(
          'Background refresh failed: $e',
          tag: 'PerformanceCacheService',
          context: {'key': key},
        );
      } finally {
        _pendingRequests.remove('bg_$key');
      }
    });
  }

  /// Start background refresh timer
  void _startBackgroundRefresh() {
    _backgroundRefreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _performBackgroundMaintenance(),
    );
  }

  /// Perform background maintenance tasks
  void _performBackgroundMaintenance() {
    // Clean up expired pending requests
    _pendingRequests.removeWhere((key, future) {
      // Remove requests older than 5 minutes
      return key.startsWith('bg_');
    });

    // Clean up old refresh times
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    _lastRefreshTimes.removeWhere((key, time) => time.isBefore(cutoff));

    LoggingService.instance.debug(
      'Background maintenance completed',
      tag: 'PerformanceCacheService',
      context: {
        'pending_requests': _pendingRequests.length,
        'refresh_times': _lastRefreshTimes.length,
      },
    );
  }

  /// Start performance cleanup timer
  void _startPerformanceCleanup() {
    _performanceCleanupTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => _cleanupPerformanceMetrics(),
    );
  }

  /// Clean up old performance metrics
  void _cleanupPerformanceMetrics() {
    // Keep only recent metrics (last 100 requests per key)
    _requestCounts.removeWhere((key, count) => count > 1000);

    // Reset counters periodically to prevent overflow
    if (_requestCounts.length > 100) {
      _requestCounts.clear();
      _averageResponseTimes.clear();
    }
  }

  /// Update response time metrics
  void _updateResponseTimeMetrics(String key, Duration responseTime) {
    final currentAverage = _averageResponseTimes[key] ?? Duration.zero;
    final requestCount = _requestCounts[key] ?? 0;

    // Calculate rolling average
    final newAverage = Duration(
      microseconds: ((currentAverage.inMicroseconds * requestCount) +
              responseTime.inMicroseconds) ~/
          (requestCount + 1),
    );

    _averageResponseTimes[key] = newAverage;
  }

  /// Increment request count
  void _incrementRequestCount(String key) {
    _requestCounts[key] = (_requestCounts[key] ?? 0) + 1;
  }

  /// Record cache hit
  void _recordCacheHit(String key, Duration responseTime) {
    LoggingService.instance.debug(
      'Cache hit',
      tag: 'PerformanceCacheService',
      context: {
        'key': key,
        'response_time_ms': responseTime.inMilliseconds,
      },
    );
  }

  /// Record cache miss
  void _recordCacheMiss(String key, Duration responseTime) {
    LoggingService.instance.debug(
      'Cache miss',
      tag: 'PerformanceCacheService',
      context: {
        'key': key,
        'response_time_ms': responseTime.inMilliseconds,
      },
    );
  }

  /// Set offline mode
  void setOfflineMode(bool offline) {
    _isOfflineMode = offline;
    LoggingService.instance.info(
      'Offline mode ${offline ? 'enabled' : 'disabled'}',
      tag: 'PerformanceCacheService',
    );
  }

  /// Check if in offline mode
  bool get isOfflineMode => _isOfflineMode;

  /// Get cached data with offline indicator
  CachedDataResult<T>? getCachedWithIndicator<T>(String key) {
    final data = _cacheService.get<T>(key);
    if (data == null) return null;

    final lastRefresh = _lastRefreshTimes[key];
    final isStale = lastRefresh != null &&
        DateTime.now().difference(lastRefresh) > _getBaseTtlForKey(key);

    return CachedDataResult<T>(
      data: data,
      isStale: isStale,
      isOffline: _isOfflineMode,
      lastRefresh: lastRefresh,
    );
  }

  /// Get performance statistics
  PerformanceStats getPerformanceStats() {
    final totalRequests =
        _requestCounts.values.fold(0, (sum, count) => sum + count);
    final averageResponseTime = _averageResponseTimes.values.isEmpty
        ? Duration.zero
        : Duration(
            microseconds: _averageResponseTimes.values
                    .map((d) => d.inMicroseconds)
                    .reduce((a, b) => a + b) ~/
                _averageResponseTimes.length,
          );

    return PerformanceStats(
      totalRequests: totalRequests,
      pendingRequests: _pendingRequests.length,
      averageResponseTime: averageResponseTime,
      cacheStats: _cacheService.getStats(),
      isOfflineMode: _isOfflineMode,
    );
  }

  /// Dispose resources
  void dispose() {
    _backgroundRefreshTimer?.cancel();
    _performanceCleanupTimer?.cancel();
    _pendingRequests.clear();
    _lastRefreshTimes.clear();
    _requestCounts.clear();
    _averageResponseTimes.clear();
  }
}

/// Result of cached data with metadata
class CachedDataResult<T> {
  final T data;
  final bool isStale;
  final bool isOffline;
  final DateTime? lastRefresh;

  CachedDataResult({
    required this.data,
    required this.isStale,
    required this.isOffline,
    this.lastRefresh,
  });
}

/// Performance statistics
class PerformanceStats {
  final int totalRequests;
  final int pendingRequests;
  final Duration averageResponseTime;
  final CacheStats cacheStats;
  final bool isOfflineMode;

  PerformanceStats({
    required this.totalRequests,
    required this.pendingRequests,
    required this.averageResponseTime,
    required this.cacheStats,
    required this.isOfflineMode,
  });
}

/// Enhanced cache keys for performance optimization
class PerformanceCacheKeys {
  // Market data keys
  static String marketData(String exchange, String symbol) =>
      'market_data_${exchange}_$symbol';
  static String priceData(String symbol) => 'price_data_$symbol';
  static String orderbook(String exchange, String symbol) =>
      'orderbook_${exchange}_$symbol';

  // Technical indicator keys
  static String rsi(String exchange, String symbol, int period) =>
      'rsi_${exchange}_${symbol}_$period';
  static String macd(String exchange, String symbol) =>
      'macd_${exchange}_$symbol';
  static String bollingerBands(String exchange, String symbol, int period) =>
      'bb_${exchange}_${symbol}_$period';

  // Position and balance keys
  static String positions(String exchange) => 'positions_$exchange';
  static String balance(String exchange, String currency) =>
      'balance_${exchange}_$currency';
  static String portfolio() => 'portfolio';

  // Bot status keys
  static String botStatus() => 'bot_status';
  static String botConfig() => 'bot_config';
  static String botPerformance() => 'bot_performance';

  // Analysis keys
  static String completeAnalysis(String symbol) => 'complete_analysis_$symbol';
  static String sentimentAnalysis(String symbol) =>
      'sentiment_analysis_$symbol';
  static String llmAnalysis(String symbol) => 'llm_analysis_$symbol';

  // Backtest keys
  static String backtestResult(String strategyId) =>
      'backtest_result_$strategyId';
  static String optimizationResult(String optimizationId) =>
      'optimization_result_$optimizationId';

  // Configuration keys
  static String userConfig() => 'user_config';
  static String appSettings() => 'app_settings';
}
