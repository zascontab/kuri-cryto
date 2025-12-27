import 'dart:async';
import 'dart:developer' as developer;
import '../exceptions/mcp_exceptions.dart';
import '../exceptions/matp_exceptions.dart';

/// Fallback service for MCP tool failures and system resilience
///
/// This service provides:
/// - Multiple fallback strategies for MCP tool failures
/// - Cached data serving when tools are unavailable
/// - Mock data generation for development/testing
/// - Graceful degradation of functionality
/// - Fallback chain execution with priority
class FallbackService {
  final Map<String, List<FallbackStrategy>> _fallbackStrategies = {};
  final Map<String, CachedResult> _cache = {};
  final Map<String, MockDataGenerator> _mockGenerators = {};

  /// Register a fallback strategy for a specific tool or operation
  void registerFallback(String toolName, FallbackStrategy strategy) {
    _fallbackStrategies.putIfAbsent(toolName, () => []).add(strategy);

    // Sort by priority (higher priority first)
    _fallbackStrategies[toolName]!
        .sort((a, b) => b.priority.compareTo(a.priority));

    developer.log(
      'Registered fallback strategy for $toolName: ${strategy.name} (priority: ${strategy.priority})',
      name: 'FallbackService',
    );
  }

  /// Execute operation with fallback support
  Future<T> executeWithFallback<T>(
    String operationName,
    Future<T> Function() primaryOperation, {
    Duration? cacheTimeout,
    bool enableMockData = false,
    Map<String, dynamic>? mockDataParams,
  }) async {
    final List<String> attemptedMethods = [];
    Exception? lastException;

    try {
      // Try primary operation first
      attemptedMethods.add('primary');
      final result = await primaryOperation();

      // Cache successful result
      if (cacheTimeout != null) {
        _cacheResult(operationName, result, cacheTimeout);
      }

      return result;
    } catch (e) {
      lastException = e is Exception ? e : Exception(e.toString());

      developer.log(
        'Primary operation failed for $operationName: $e',
        name: 'FallbackService',
        error: e,
      );

      // Try fallback strategies
      final strategies = _fallbackStrategies[operationName] ?? [];

      for (final strategy in strategies) {
        try {
          attemptedMethods.add(strategy.name);

          developer.log(
            'Trying fallback strategy: ${strategy.name} for $operationName',
            name: 'FallbackService',
          );

          final result = await _executeFallbackStrategy<T>(
            strategy,
            operationName,
            lastException,
            mockDataParams,
          );

          if (result != null) {
            // Cache successful fallback result
            if (cacheTimeout != null) {
              _cacheResult(operationName, result, cacheTimeout);
            }

            developer.log(
              'Fallback strategy succeeded: ${strategy.name} for $operationName',
              name: 'FallbackService',
            );

            return result;
          }
        } catch (e) {
          developer.log(
            'Fallback strategy failed: ${strategy.name} for $operationName - $e',
            name: 'FallbackService',
            error: e,
          );
          continue;
        }
      }

      // All fallbacks failed
      throw MCPFallbackException.allFallbacksFailed(
        attemptedMethods: attemptedMethods,
        originalError: lastException.toString(),
      );
    }
  }

  /// Execute a specific fallback strategy
  Future<T?> _executeFallbackStrategy<T>(
    FallbackStrategy strategy,
    String operationName,
    Exception? originalException,
    Map<String, dynamic>? mockDataParams,
  ) async {
    switch (strategy.type) {
      case FallbackType.cache:
        return _tryCache<T>(operationName);

      case FallbackType.mockData:
        return _tryMockData<T>(operationName, mockDataParams);

      case FallbackType.alternative:
        if (strategy.alternativeOperation != null) {
          return await strategy.alternativeOperation!() as T;
        }
        break;

      case FallbackType.degraded:
        return _tryDegradedResponse<T>(operationName, strategy.degradedData);

      case FallbackType.retry:
        if (strategy.retryOperation != null) {
          return await strategy.retryOperation!() as T;
        }
        break;

      case FallbackType.custom:
        if (strategy.customHandler != null) {
          return await strategy.customHandler!(originalException) as T;
        }
        break;
    }

    return null;
  }

  /// Try to serve from cache
  T? _tryCache<T>(String operationName) {
    final cached = _cache[operationName];
    if (cached != null && !cached.isExpired) {
      developer.log(
        'Serving cached result for $operationName (age: ${cached.age.inSeconds}s)',
        name: 'FallbackService',
      );
      return cached.data as T;
    }
    return null;
  }

  /// Try to generate mock data
  T? _tryMockData<T>(String operationName, Map<String, dynamic>? params) {
    final generator = _mockGenerators[operationName];
    if (generator != null) {
      developer.log(
        'Generating mock data for $operationName',
        name: 'FallbackService',
      );
      return generator.generate(params) as T;
    }
    return null;
  }

  /// Try to serve degraded response
  T? _tryDegradedResponse<T>(String operationName, dynamic degradedData) {
    if (degradedData != null) {
      developer.log(
        'Serving degraded response for $operationName',
        name: 'FallbackService',
      );
      return degradedData as T;
    }
    return null;
  }

  /// Cache a result
  void _cacheResult<T>(String operationName, T result, Duration timeout) {
    _cache[operationName] = CachedResult(
      data: result,
      cachedAt: DateTime.now(),
      timeout: timeout,
    );

    developer.log(
      'Cached result for $operationName (timeout: ${timeout.inMinutes}min)',
      name: 'FallbackService',
    );
  }

  /// Register mock data generator
  void registerMockGenerator(
      String operationName, MockDataGenerator generator) {
    _mockGenerators[operationName] = generator;

    developer.log(
      'Registered mock data generator for $operationName',
      name: 'FallbackService',
    );
  }

  /// Setup default fallback strategies for common MCP tools
  void setupDefaultFallbacks() {
    // Market data fallbacks
    _setupMarketDataFallbacks();

    // Technical indicators fallbacks
    _setupIndicatorFallbacks();

    // Account data fallbacks
    _setupAccountDataFallbacks();

    // Analysis fallbacks
    _setupAnalysisFallbacks();
  }

  void _setupMarketDataFallbacks() {
    // Candles data fallback
    registerFallback(
        'get_candles',
        FallbackStrategy(
          name: 'cached_candles',
          type: FallbackType.cache,
          priority: 100,
        ));

    registerFallback(
        'get_candles',
        FallbackStrategy(
          name: 'mock_candles',
          type: FallbackType.mockData,
          priority: 50,
        ));

    // Markets data fallback
    registerFallback(
        'get_markets',
        FallbackStrategy(
          name: 'cached_markets',
          type: FallbackType.cache,
          priority: 100,
        ));

    registerFallback(
        'get_markets',
        FallbackStrategy(
          name: 'mock_markets',
          type: FallbackType.mockData,
          priority: 50,
        ));

    // Register mock generators
    registerMockGenerator('get_candles', CandlesMockGenerator());
    registerMockGenerator('get_markets', MarketsMockGenerator());
  }

  void _setupIndicatorFallbacks() {
    final indicators = [
      'calculate_rsi',
      'calculate_macd',
      'calculate_bollinger'
    ];

    for (final indicator in indicators) {
      registerFallback(
          indicator,
          FallbackStrategy(
            name: 'cached_$indicator',
            type: FallbackType.cache,
            priority: 100,
          ));

      registerFallback(
          indicator,
          FallbackStrategy(
            name: 'mock_$indicator',
            type: FallbackType.mockData,
            priority: 50,
          ));

      // Register mock generators
      registerMockGenerator(indicator, IndicatorMockGenerator(indicator));
    }
  }

  void _setupAccountDataFallbacks() {
    // Balance fallback
    registerFallback(
        'get_balance',
        FallbackStrategy(
          name: 'cached_balance',
          type: FallbackType.cache,
          priority: 100,
        ));

    registerFallback(
        'get_balance',
        FallbackStrategy(
          name: 'degraded_balance',
          type: FallbackType.degraded,
          priority: 75,
          degradedData: {
            'currency': 'USDT',
            'available': 0.0,
            'locked': 0.0,
            'total': 0.0,
            'note': 'Balance unavailable - showing cached/default values'
          },
        ));

    // Positions fallback
    registerFallback(
        'get_futures_positions',
        FallbackStrategy(
          name: 'cached_positions',
          type: FallbackType.cache,
          priority: 100,
        ));

    registerFallback(
        'get_futures_positions',
        FallbackStrategy(
          name: 'empty_positions',
          type: FallbackType.degraded,
          priority: 75,
          degradedData: {
            'positions': [],
            'note': 'Positions unavailable - showing empty list'
          },
        ));
  }

  void _setupAnalysisFallbacks() {
    // LLM analysis fallback
    registerFallback(
        'llm_analyze_market',
        FallbackStrategy(
          name: 'cached_llm_analysis',
          type: FallbackType.cache,
          priority: 100,
        ));

    registerFallback(
        'llm_analyze_market',
        FallbackStrategy(
          name: 'basic_analysis',
          type: FallbackType.degraded,
          priority: 75,
          degradedData: {
            'action': 'HOLD',
            'confidence': 0.5,
            'reasoning': ['Analysis service temporarily unavailable'],
            'entry_price': 0.0,
            'stop_loss': 0.0,
            'take_profit': 0.0,
            'note': 'Using basic fallback analysis'
          },
        ));

    // Backtest fallback
    registerFallback(
        'backtest_strategy',
        FallbackStrategy(
          name: 'cached_backtest',
          type: FallbackType.cache,
          priority: 100,
        ));

    registerFallback(
        'backtest_strategy',
        FallbackStrategy(
          name: 'mock_backtest',
          type: FallbackType.mockData,
          priority: 50,
        ));

    registerMockGenerator('backtest_strategy', BacktestMockGenerator());
  }

  /// Get fallback status for debugging
  Map<String, dynamic> getFallbackStatus() {
    return {
      'registered_strategies': _fallbackStrategies.map(
        (key, value) => MapEntry(key, value.map((s) => s.name).toList()),
      ),
      'cached_operations': _cache.keys.toList(),
      'mock_generators': _mockGenerators.keys.toList(),
      'cache_stats': _cache.map(
        (key, value) => MapEntry(key, {
          'age_seconds': value.age.inSeconds,
          'is_expired': value.isExpired,
        }),
      ),
    };
  }

  /// Clear cache (useful for testing)
  void clearCache() {
    _cache.clear();
  }

  /// Clear all fallback strategies (useful for testing)
  void clearFallbacks() {
    _fallbackStrategies.clear();
    _mockGenerators.clear();
  }
}

/// Fallback strategy configuration
class FallbackStrategy {
  final String name;
  final FallbackType type;
  final int priority;
  final Future<dynamic> Function()? alternativeOperation;
  final Future<dynamic> Function()? retryOperation;
  final Future<dynamic> Function(Exception?)? customHandler;
  final dynamic degradedData;

  FallbackStrategy({
    required this.name,
    required this.type,
    required this.priority,
    this.alternativeOperation,
    this.retryOperation,
    this.customHandler,
    this.degradedData,
  });
}

/// Types of fallback strategies
enum FallbackType {
  cache, // Serve from cache
  mockData, // Generate mock data
  alternative, // Use alternative operation
  degraded, // Serve degraded response
  retry, // Retry with different parameters
  custom, // Custom fallback handler
}

/// Cached result with expiration
class CachedResult {
  final dynamic data;
  final DateTime cachedAt;
  final Duration timeout;

  CachedResult({
    required this.data,
    required this.cachedAt,
    required this.timeout,
  });

  bool get isExpired => DateTime.now().difference(cachedAt) > timeout;
  Duration get age => DateTime.now().difference(cachedAt);
}

/// Abstract mock data generator
abstract class MockDataGenerator {
  dynamic generate(Map<String, dynamic>? params);
}

/// Mock generator for candles data
class CandlesMockGenerator extends MockDataGenerator {
  @override
  dynamic generate(Map<String, dynamic>? params) {
    final limit = params?['limit'] ?? 100;
    final candles = <Map<String, dynamic>>[];

    var price = 50000.0;
    final now = DateTime.now();

    for (int i = 0; i < limit; i++) {
      final timestamp = now.subtract(Duration(hours: limit - i));
      final change =
          (DateTime.now().millisecondsSinceEpoch % 1000 - 500) / 100.0;

      price += change;
      final high = price + (price * 0.01);
      final low = price - (price * 0.01);

      candles.add({
        'timestamp': timestamp.toIso8601String(),
        'open': price - change,
        'high': high,
        'low': low,
        'close': price,
        'volume': 1000.0 + (DateTime.now().millisecondsSinceEpoch % 500),
      });
    }

    return {'candles': candles};
  }
}

/// Mock generator for markets data
class MarketsMockGenerator extends MockDataGenerator {
  @override
  dynamic generate(Map<String, dynamic>? params) {
    final markets = [
      'BTC-USDT',
      'ETH-USDT',
      'BNB-USDT',
      'ADA-USDT',
      'DOT-USDT',
      'LINK-USDT',
      'LTC-USDT',
      'BCH-USDT',
      'XRP-USDT',
      'DOGE-USDT'
    ];

    return {
      'pairs': markets
          .map((market) => {
                'symbol': market,
                'base': market.split('-')[0],
                'quote': market.split('-')[1],
                'active': true,
                'type': 'spot',
              })
          .toList(),
    };
  }
}

/// Mock generator for technical indicators
class IndicatorMockGenerator extends MockDataGenerator {
  final String indicatorType;

  IndicatorMockGenerator(this.indicatorType);

  @override
  dynamic generate(Map<String, dynamic>? params) {
    switch (indicatorType) {
      case 'calculate_rsi':
        return {
          'rsi': 50.0 + (DateTime.now().millisecondsSinceEpoch % 50 - 25)
        };

      case 'calculate_macd':
        return {
          'macd': 0.5,
          'signal': 0.3,
          'histogram': 0.2,
        };

      case 'calculate_bollinger':
        const price = 50000.0;
        return {
          'upper': price * 1.02,
          'middle': price,
          'lower': price * 0.98,
        };

      default:
        return {'value': 0.0, 'note': 'Mock indicator data'};
    }
  }
}

/// Mock generator for backtest results
class BacktestMockGenerator extends MockDataGenerator {
  @override
  dynamic generate(Map<String, dynamic>? params) {
    return {
      'roi': 15.5 + (DateTime.now().millisecondsSinceEpoch % 20 - 10),
      'sharpe_ratio': 1.2 + (DateTime.now().millisecondsSinceEpoch % 10) / 10.0,
      'max_drawdown': -5.0 - (DateTime.now().millisecondsSinceEpoch % 10),
      'total_trades': 100 + (DateTime.now().millisecondsSinceEpoch % 50),
      'win_rate': 60.0 + (DateTime.now().millisecondsSinceEpoch % 20),
      'note': 'Mock backtest results - analysis service unavailable'
    };
  }
}
