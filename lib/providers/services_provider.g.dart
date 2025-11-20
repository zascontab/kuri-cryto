// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'services_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dioHash() => r'e1c6b2bf32f5332a8a77d06b82210c4f6ab516ca';

/// Provider for Dio HTTP client
///
/// Configured with:
/// - Base URL (API Gateway)
/// - Connect timeout: 10s
/// - Receive timeout: 30s
/// - Send timeout: 30s
/// - JSON content type
/// - Logging interceptor (debug mode)
///
/// Copied from [dio].
@ProviderFor(dio)
final dioProvider = AutoDisposeProvider<Dio>.internal(
  dio,
  name: r'dioProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DioRef = AutoDisposeProviderRef<Dio>;
String _$apiClientHash() => r'830b3339c24d952121db45e5d7278545d0d2fbfd';

/// Provider for API client
///
/// Creates ApiClient with custom error handling and retry logic
///
/// Copied from [apiClient].
@ProviderFor(apiClient)
final apiClientProvider = AutoDisposeProvider<ApiClient>.internal(
  apiClient,
  name: r'apiClientProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$apiClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ApiClientRef = AutoDisposeProviderRef<ApiClient>;
String _$scalpingServiceHash() => r'cbaa2c2e23b62007b8542a6ae3c0da33f34d880d';

/// Provider for Scalping Service
///
/// Handles all scalping-related API calls:
/// - System control (start/stop)
/// - Status and metrics
/// - Health check
///
/// Copied from [scalpingService].
@ProviderFor(scalpingService)
final scalpingServiceProvider = AutoDisposeProvider<ScalpingService>.internal(
  scalpingService,
  name: r'scalpingServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scalpingServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ScalpingServiceRef = AutoDisposeProviderRef<ScalpingService>;
String _$positionServiceHash() => r'de0a96f6af5941f610db50f9780fe8fd64c01017';

/// Provider for Position Service
///
/// Manages position-related operations:
/// - Get open positions
/// - Get position history
/// - Close positions
/// - Update SL/TP
/// - Move to breakeven
/// - Enable trailing stop
///
/// Copied from [positionService].
@ProviderFor(positionService)
final positionServiceProvider = AutoDisposeProvider<PositionService>.internal(
  positionService,
  name: r'positionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$positionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PositionServiceRef = AutoDisposeProviderRef<PositionService>;
String _$strategyServiceHash() => r'e159e20ce7b935299226b7484f2478397e849d8b';

/// Provider for Strategy Service
///
/// Handles strategy configuration and control:
/// - List strategies
/// - Start/Stop strategies
/// - Update strategy config
/// - Get strategy performance
///
/// Copied from [strategyService].
@ProviderFor(strategyService)
final strategyServiceProvider = AutoDisposeProvider<StrategyService>.internal(
  strategyService,
  name: r'strategyServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$strategyServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StrategyServiceRef = AutoDisposeProviderRef<StrategyService>;
String _$riskServiceHash() => r'c742d500fe00a8bd4056b801462e220d28e16714';

/// Provider for Risk Service
///
/// Manages risk parameters and monitoring:
/// - Get/Update risk limits
/// - Get exposure
/// - Risk Sentinel state
/// - Kill switch activation/deactivation
///
/// Copied from [riskService].
@ProviderFor(riskService)
final riskServiceProvider = AutoDisposeProvider<RiskService>.internal(
  riskService,
  name: r'riskServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$riskServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RiskServiceRef = AutoDisposeProviderRef<RiskService>;
String _$websocketServiceHash() => r'1a73f837636b51854e8ef2afee014530a7419ee1';

/// Provider for WebSocket Service
///
/// Manages WebSocket connection for real-time updates:
/// - Position updates
/// - Metrics updates
/// - Alerts
/// - Kill switch events
///
/// Auto-reconnection with exponential backoff
///
/// Copied from [websocketService].
@ProviderFor(websocketService)
final websocketServiceProvider = AutoDisposeProvider<WebSocketService>.internal(
  websocketService,
  name: r'websocketServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$websocketServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WebsocketServiceRef = AutoDisposeProviderRef<WebSocketService>;
String _$analysisServiceHash() => r'c0bf5edcef281db33906450658f109a629c2efd1';

/// Provider for Analysis Service
///
/// Handles multi-timeframe market analysis:
/// - Technical indicators (RSI, MACD, Bollinger)
/// - Signal generation
/// - Consensus analysis across timeframes
///
/// Copied from [analysisService].
@ProviderFor(analysisService)
final analysisServiceProvider = AutoDisposeProvider<AnalysisService>.internal(
  analysisService,
  name: r'analysisServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analysisServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AnalysisServiceRef = AutoDisposeProviderRef<AnalysisService>;
String _$backtestServiceHash() => r'9e5469d55dcb40128d35d7a466525316e9b23d11';

/// Provider for Backtest Service
///
/// Manages strategy backtesting:
/// - Run backtests with historical data
/// - Get performance metrics
/// - Trade history and equity curves
///
/// Copied from [backtestService].
@ProviderFor(backtestService)
final backtestServiceProvider = AutoDisposeProvider<BacktestService>.internal(
  backtestService,
  name: r'backtestServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$backtestServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BacktestServiceRef = AutoDisposeProviderRef<BacktestService>;
String _$optimizationServiceHash() =>
    r'68460f4d51165cce05bf1468532ef018542b0bb5';

/// Provider for Optimization Service
///
/// Manages parameter optimization:
/// - Run parameter optimizations
/// - Get optimization results
/// - Apply optimal parameters
/// - Manage optimization history
///
/// Copied from [optimizationService].
@ProviderFor(optimizationService)
final optimizationServiceProvider =
    AutoDisposeProvider<OptimizationService>.internal(
  optimizationService,
  name: r'optimizationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$optimizationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef OptimizationServiceRef = AutoDisposeProviderRef<OptimizationService>;
String _$executionServiceHash() => r'3cc75c07df8f7525cd79e99aa7bc2bbc0ffbd7bb';

/// Provider for Execution Service
///
/// Handles execution statistics and performance:
/// - Latency statistics
/// - Execution history
/// - Queue management
/// - Performance metrics
/// - Metrics export
///
/// Copied from [executionService].
@ProviderFor(executionService)
final executionServiceProvider = AutoDisposeProvider<ExecutionService>.internal(
  executionService,
  name: r'executionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$executionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ExecutionServiceRef = AutoDisposeProviderRef<ExecutionService>;
String _$alertServiceHash() => r'78afd1bf3a1440c841a6d53cb71d0accba478fdb';

/// Provider for Alert Service
///
/// Manages alert system:
/// - Configure alert rules
/// - Get alert history
/// - Acknowledge/dismiss alerts
/// - Get active alerts
/// - Test alert configuration
///
/// Copied from [alertService].
@ProviderFor(alertService)
final alertServiceProvider = AutoDisposeProvider<AlertService>.internal(
  alertService,
  name: r'alertServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$alertServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AlertServiceRef = AutoDisposeProviderRef<AlertService>;
String _$aiBotServiceHash() => r'6a2aa91de7e08b68cb719febd331dc4783b13a77';

/// Provider for AI Bot Service
///
/// Manages AI trading bot operations:
/// - Bot control (start/stop/pause/resume)
/// - Status monitoring
/// - Configuration management
/// - Position tracking
/// - Market analysis with AI
/// - Emergency stop
///
/// Copied from [aiBotService].
@ProviderFor(aiBotService)
final aiBotServiceProvider = AutoDisposeProvider<AiBotService>.internal(
  aiBotService,
  name: r'aiBotServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$aiBotServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AiBotServiceRef = AutoDisposeProviderRef<AiBotService>;
String _$comprehensiveAnalysisServiceHash() =>
    r'bfb2ef700251c6796261e425d578991a7fd85af3';

/// Provider for Comprehensive Analysis Service
///
/// Provides detailed market analysis with AI:
/// - Current price and 24h statistics
/// - Technical analysis (RSI, MACD, Bollinger, EMAs)
/// - Multi-timeframe analysis (1m, 5m, 15m, 1h)
/// - Recent movement analysis
/// - Key support/resistance levels
/// - Trading recommendations (BUY/SELL/WAIT)
/// - Market scenarios and risk evaluation
///
/// Copied from [comprehensiveAnalysisService].
@ProviderFor(comprehensiveAnalysisService)
final comprehensiveAnalysisServiceProvider =
    AutoDisposeProvider<ComprehensiveAnalysisService>.internal(
  comprehensiveAnalysisService,
  name: r'comprehensiveAnalysisServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$comprehensiveAnalysisServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ComprehensiveAnalysisServiceRef
    = AutoDisposeProviderRef<ComprehensiveAnalysisService>;
String _$futuresServiceHash() => r'01afa1a3b0f5b16ab1cd3339ce71a87d617f0a9b';

/// Provider for Futures Service
///
/// Handles futures trading operations on KuCoin:
/// - Get open futures positions
/// - Close positions (single/all/filtered)
/// - Stop loss and take profit management
/// - Mark and index price retrieval
/// - Symbol conversion helpers (spot <-> futures)
///
/// Copied from [futuresService].
@ProviderFor(futuresService)
final futuresServiceProvider = AutoDisposeProvider<FuturesService>.internal(
  futuresService,
  name: r'futuresServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$futuresServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FuturesServiceRef = AutoDisposeProviderRef<FuturesService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
