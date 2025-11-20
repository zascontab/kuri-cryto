/// Example usage of CacheService
///
/// This file demonstrates various ways to use the CacheService
/// for offline functionality and improved performance.
library;

import 'cache_service.dart';
import '../models/position.dart';
import '../models/trade.dart';
import '../models/strategy.dart';
import '../models/risk_state.dart';
import '../models/metrics.dart';
import '../models/system_status.dart';

/// Example 1: Basic usage - Save and retrieve positions
Future<void> example1BasicUsage() async {
  final cache = CacheService();

  // Create a position
  final position = Position(
    id: 'pos_001',
    symbol: 'BTC-USDT',
    side: 'long',
    entryPrice: 45000.0,
    currentPrice: 46000.0,
    size: 0.1,
    leverage: 2.0,
    unrealizedPnl: 100.0,
    openTime: DateTime.now(),
    strategy: 'scalping',
  );

  // Save to cache
  await cache.savePosition(position);
  print('Position saved to cache');

  // Retrieve from cache
  final retrieved = cache.getPosition('pos_001');
  print('Retrieved position: ${retrieved?.symbol}');

  // Get all positions
  final allPositions = cache.getAllPositions();
  print('Total cached positions: ${allPositions.length}');
}

/// Example 2: Batch operations - Save multiple items at once
Future<void> example2BatchOperations() async {
  final cache = CacheService();

  // Create multiple positions
  final positions = [
    Position(
      id: 'pos_001',
      symbol: 'BTC-USDT',
      side: 'long',
      entryPrice: 45000.0,
      currentPrice: 46000.0,
      size: 0.1,
      openTime: DateTime.now(),
      strategy: 'scalping',
    ),
    Position(
      id: 'pos_002',
      symbol: 'ETH-USDT',
      side: 'short',
      entryPrice: 2500.0,
      currentPrice: 2450.0,
      size: 2.0,
      openTime: DateTime.now(),
      strategy: 'trend_following',
    ),
  ];

  // Save all at once (more efficient)
  await cache.savePositions(positions);
  print('Batch saved ${positions.length} positions');

  // Get only open positions
  final openPositions = cache.getOpenPositions();
  print('Open positions: ${openPositions.length}');
}

/// Example 3: Working with trades and time-based filtering
Future<void> example3TradesAndTimeFiltering() async {
  final cache = CacheService();

  // Create trades
  final trades = [
    Trade(
      id: 'trade_001',
      orderId: 'order_001',
      symbol: 'BTC-USDT',
      side: 'buy',
      price: 45000.0,
      size: 0.1,
      status: 'filled',
      latencyMs: 50.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Trade(
      id: 'trade_002',
      orderId: 'order_002',
      symbol: 'ETH-USDT',
      side: 'sell',
      price: 2500.0,
      size: 2.0,
      status: 'filled',
      latencyMs: 45.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 26)),
    ),
  ];

  await cache.saveTrades(trades);

  // Get only recent trades (last 24h)
  final recentTrades = cache.getRecentTrades();
  print('Recent trades (24h): ${recentTrades.length}');

  // Get all trades
  final allTrades = cache.getAllTrades();
  print('All cached trades: ${allTrades.length}');
}

/// Example 4: Strategies with active filtering
Future<void> example4Strategies() async {
  final cache = CacheService();

  // Create strategies
  final strategies = [
    const Strategy(
      name: 'Scalping',
      active: true,
      weight: 0.4,
      performance: StrategyPerformance(
        totalTrades: 100,
        winningTrades: 65,
        losingTrades: 35,
        winRate: 65.0,
        totalPnl: 5000.0,
      ),
    ),
    const Strategy(
      name: 'Trend Following',
      active: false,
      weight: 0.3,
      performance: StrategyPerformance(
        totalTrades: 50,
        winningTrades: 30,
        losingTrades: 20,
        winRate: 60.0,
        totalPnl: 3000.0,
      ),
    ),
  ];

  await cache.saveStrategies(strategies);

  // Get only active strategies
  final activeStrategies = cache.getActiveStrategies();
  print('Active strategies: ${activeStrategies.length}');

  // Get specific strategy
  final scalping = cache.getStrategy('Scalping');
  print('Scalping win rate: ${scalping?.performance.winRate}%');
}

/// Example 5: Metrics with history
Future<void> example5MetricsHistory() async {
  final cache = CacheService();

  // Save metrics (automatically timestamped)
  const metrics = Metrics(
    totalTrades: 150,
    winningTrades: 95,
    losingTrades: 55,
    winRate: 63.33,
    totalPnl: 8000.0,
    dailyPnl: 500.0,
    weeklyPnl: 2500.0,
    monthlyPnl: 8000.0,
    activePositions: 5,
  );

  await cache.saveMetrics(metrics);
  print('Metrics saved');

  // Get current metrics
  final current = cache.getMetrics();
  print('Current PnL: ${current?.totalPnl}');

  // Get metrics history from last 24h
  final history = cache.getMetricsHistory();
  print('Metrics history entries: ${history.length}');
}

/// Example 6: Risk state monitoring
Future<void> example6RiskState() async {
  final cache = CacheService();

  final riskState = RiskState(
    currentDrawdownDaily: -2.5,
    currentDrawdownWeekly: -5.0,
    currentDrawdownMonthly: -8.0,
    totalExposure: 50000.0,
    exposureBySymbol: {
      'BTC-USDT': 30000.0,
      'ETH-USDT': 20000.0,
    },
    consecutiveLosses: 2,
    riskMode: 'Normal',
    killSwitchActive: false,
    lastUpdate: DateTime.now(),
    maxTotalExposure: 100000.0,
  );

  await cache.saveRiskState(riskState);

  final cached = cache.getRiskState();
  print('Can trade: ${cached?.canTrade()}');
  print('Risk level: ${cached?.getRiskLevel()}%');
  print('Available exposure: ${cached?.getAvailableExposure()}');
}

/// Example 7: System status
Future<void> example7SystemStatus() async {
  final cache = CacheService();

  final status = SystemStatus(
    running: true,
    uptime: '5h30m15s',
    pairsCount: 10,
    activeStrategies: 3,
    healthStatus: 'healthy',
    errors: [],
    timestamp: DateTime.now(),
  );

  await cache.saveSystemStatus(status);

  final cached = cache.getSystemStatus();
  print('System operational: ${cached?.isOperational}');
  print('Uptime: ${cached?.uptime}');
  print('Health: ${cached?.healthStatus}');
}

/// Example 8: Cache freshness and sync
Future<void> example8CacheFreshness() async {
  final cache = CacheService();

  // Check if cache is fresh
  final positionsFresh = cache.isCacheFresh('positions_batch');
  print('Positions cache fresh: $positionsFresh');

  final metricsFresh = cache.isCacheFresh('metrics');
  print('Metrics cache fresh: $metricsFresh');

  // Check if sync is needed
  final needsSync = cache.needsSync('strategies_batch');
  print('Strategies need sync: $needsSync');

  // Get last update time
  final lastUpdate = cache.getLastUpdateTime('positions_batch');
  print('Last positions update: $lastUpdate');

  // Mark as synced after updating
  await cache.markSynced('positions_batch');
}

/// Example 9: Cache statistics
Future<void> example9CacheStats() async {
  final cache = CacheService();

  final stats = cache.getCacheStats();

  print('\n=== Cache Statistics ===');
  print('Positions: ${stats['positions_count']}');
  print('Trades: ${stats['trades_count']}');
  print('Strategies: ${stats['strategies_count']}');
  print('Has Risk State: ${stats['has_risk_state']}');
  print('Has Metrics: ${stats['has_metrics']}');
  print('Has System Status: ${stats['has_system_status']}');
  print('Positions Fresh: ${stats['positions_fresh']}');
  print('Metrics Fresh: ${stats['metrics_fresh']}');
  print('Last Metrics Update: ${stats['last_metrics_update']}');
}

/// Example 10: Cache cleanup
Future<void> example10CacheCleanup() async {
  final cache = CacheService();

  // Clean old metrics (older than 24h)
  await cache.cleanOldMetrics();
  print('Old metrics cleaned');

  // Clean all old cache (trades, expired data, etc.)
  await cache.cleanOldCache();
  print('Old cache cleaned');

  // Clear specific cache
  await cache.clearPositions();
  print('Positions cache cleared');

  // Clear all cache (use with caution!)
  // await cache.clearAllCache();
  // print('All cache cleared');
}

/// Example 11: Offline-first pattern
Future<void> example11OfflineFirstPattern() async {
  final cache = CacheService();

  // Simulated API call
  Future<List<Position>> fetchPositionsFromAPI() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simulate network error (uncomment to test offline)
    // throw Exception('Network error');

    return [
      Position(
        id: 'pos_001',
        symbol: 'BTC-USDT',
        side: 'long',
        entryPrice: 45000.0,
        currentPrice: 46000.0,
        size: 0.1,
        openTime: DateTime.now(),
        strategy: 'scalping',
      ),
    ];
  }

  // Offline-first pattern
  List<Position> positions;

  try {
    // Try to fetch from API
    print('Fetching from API...');
    positions = await fetchPositionsFromAPI();

    // Save to cache for offline use
    await cache.savePositions(positions);
    print('Positions fetched and cached');
  } catch (e) {
    // If API fails, use cache
    print('API failed, using cache: $e');
    positions = cache.getAllPositions();

    if (positions.isEmpty) {
      print('No cached data available');
      return;
    }

    print('Using ${positions.length} cached positions');
  }

  // Use positions (from API or cache)
  for (final pos in positions) {
    print('Position: ${pos.symbol} - ${pos.status}');
  }
}

/// Example 12: Smart caching strategy
Future<void> example12SmartCaching() async {
  final cache = CacheService();

  Future<List<Strategy>> fetchStrategiesFromAPI() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      const Strategy(
        name: 'Scalping',
        active: true,
        weight: 0.5,
        performance: StrategyPerformance(
          totalTrades: 100,
          winningTrades: 65,
          winRate: 65.0,
        ),
      ),
    ];
  }

  // Smart caching: only fetch if cache is stale
  List<Strategy> strategies;

  if (cache.isCacheFresh('strategies_batch')) {
    // Use cache if fresh
    print('Using fresh cache');
    strategies = cache.getAllStrategies();
  } else {
    // Fetch from API if cache is stale
    print('Cache is stale, fetching from API');

    try {
      strategies = await fetchStrategiesFromAPI();
      await cache.saveStrategies(strategies);
    } catch (e) {
      // Fallback to stale cache on error
      print('API failed, using stale cache');
      strategies = cache.getAllStrategies();
    }
  }

  print('Using ${strategies.length} strategies');
}

/// Run all examples
Future<void> main() async {
  print('=== CacheService Examples ===\n');

  try {
    await example1BasicUsage();
    print('---\n');

    await example2BatchOperations();
    print('---\n');

    await example3TradesAndTimeFiltering();
    print('---\n');

    await example4Strategies();
    print('---\n');

    await example5MetricsHistory();
    print('---\n');

    await example6RiskState();
    print('---\n');

    await example7SystemStatus();
    print('---\n');

    await example8CacheFreshness();
    print('---\n');

    await example9CacheStats();
    print('---\n');

    await example11OfflineFirstPattern();
    print('---\n');

    await example12SmartCaching();
    print('---\n');

    // Cleanup last
    await example10CacheCleanup();
  } catch (e) {
    print('Error running examples: $e');
  }
}
