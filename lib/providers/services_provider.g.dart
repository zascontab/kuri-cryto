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
String _$aiBotServiceHash() => r'efcef304233c03e8d56757bf844e9803ac8c6cbe';

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
final aiBotServiceProvider = AutoDisposeProvider<AIBotService>.internal(
  aiBotService,
  name: r'aiBotServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$aiBotServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AiBotServiceRef = AutoDisposeProviderRef<AIBotService>;
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
String _$mcpServiceHash() => r'bca90fc1706ddc7625adcf0ef437f0e360d62408';

/// Provider for MCP Service
///
/// Generic service for calling MCP Tools via JSON-RPC 2.0:
/// - Centralized tool execution
/// - Type-safe responses
/// - Error handling
/// - Request ID management
/// - Access to all 67 MCP tools
///
/// Herramientas disponibles:
/// - Market data: get_ticker, get_candles, get_orderbook
/// - Technical indicators: calculate_rsi, calculate_macd, etc.
/// - Trading: execute_scalping_trade, place_market_order
/// - Account: account_info, get_account_balances
/// - Y 57 herramientas más
///
/// Copied from [mcpService].
@ProviderFor(mcpService)
final mcpServiceProvider = AutoDisposeProvider<MCPService>.internal(
  mcpService,
  name: r'mcpServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$mcpServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef McpServiceRef = AutoDisposeProviderRef<MCPService>;
String _$marketDataServiceHash() => r'f3853df11b574e415138e8e170fa975c6aecd430';

/// Provider for Market Data Service
///
/// Wrapper tipo-seguro para herramientas MCP de datos de mercado:
/// - get_ticker: Ticker actual con precio, bid, ask, volumen, cambios 24h
/// - get_candles: Datos históricos OHLCV (Open, High, Low, Close, Volume)
/// - get_orderbook: Libro de órdenes con bids/asks y análisis de liquidez
/// - get_24h_stats: Estadísticas de 24 horas
/// - get_multiple_tickers: Múltiples tickers en paralelo
/// - get_mark_price: Precio de referencia para futures
///
/// Incluye métodos de conveniencia para:
/// - Análisis de spread y liquidez
/// - Cálculo de slippage esperado
/// - Verificación de liquidez disponible
/// - Detección de tendencias
///
/// Copied from [marketDataService].
@ProviderFor(marketDataService)
final marketDataServiceProvider =
    AutoDisposeProvider<MarketDataService>.internal(
  marketDataService,
  name: r'marketDataServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$marketDataServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MarketDataServiceRef = AutoDisposeProviderRef<MarketDataService>;
String _$technicalIndicatorsServiceHash() =>
    r'f2e875069b7f8072e0d65e9bb555bd5f81e635d2';

/// Provider for Technical Indicators Service
///
/// Wrapper tipo-seguro para herramientas MCP de indicadores técnicos:
/// - RSI (Relative Strength Index): Oscilador de momentum (0-100)
/// - MACD (Moving Average Convergence Divergence): Indicador de tendencia
/// - Bollinger Bands: Bandas de volatilidad
/// - EMA/SMA: Medias móviles exponenciales y simples
/// - ATR (Average True Range): Medida de volatilidad
/// - Stochastic Oscillator: Oscilador de momentum
/// - ADX (Average Directional Index): Fuerza de tendencia
/// - CCI (Commodity Channel Index): Indicador de momentum
/// - Williams %R: Oscilador de momentum
///
/// Incluye métodos para:
/// - Análisis técnico individual de cada indicador
/// - Cálculo de múltiples EMAs en paralelo
/// - Análisis técnico completo combinando múltiples indicadores
///
/// Copied from [technicalIndicatorsService].
@ProviderFor(technicalIndicatorsService)
final technicalIndicatorsServiceProvider =
    AutoDisposeProvider<TechnicalIndicatorsService>.internal(
  technicalIndicatorsService,
  name: r'technicalIndicatorsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$technicalIndicatorsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TechnicalIndicatorsServiceRef
    = AutoDisposeProviderRef<TechnicalIndicatorsService>;
String _$accountPortfolioServiceHash() =>
    r'b7ae3c3f24a597db23cb288ef394a2d5fed49fad';

/// Provider for Account & Portfolio Service
///
/// Wrapper tipo-seguro para herramientas MCP de gestión de cuenta:
/// - account_info: Información de cuenta con permisos y comisiones
/// - get_account_balances: Todos los balances de activos
/// - get_balance: Balance de un activo específico
/// - get_portfolio: Composición del portafolio con análisis
/// - portfolio_analysis: Análisis de diversificación y riesgo
///
/// Incluye métodos para:
/// - Obtener información de cuenta y permisos
/// - Gestionar balances de activos
/// - Analizar composición del portafolio
/// - Calcular métricas de diversificación
/// - Verificar disponibilidad de fondos
///
/// Copied from [accountPortfolioService].
@ProviderFor(accountPortfolioService)
final accountPortfolioServiceProvider =
    AutoDisposeProvider<AccountPortfolioService>.internal(
  accountPortfolioService,
  name: r'accountPortfolioServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$accountPortfolioServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AccountPortfolioServiceRef
    = AutoDisposeProviderRef<AccountPortfolioService>;
String _$integratedAnalysisServiceHash() =>
    r'3648b5bfe6f43e3163118fb6ec94a0f74c6b3f9b';

/// Provider for Integrated Analysis Service
///
/// Servicio que integra múltiples fuentes de datos para análisis completo:
/// - Market Data (ticker, candles, orderbook)
/// - Technical Indicators (RSI, MACD, Bollinger Bands)
/// - Generación de señales de trading
///
/// Funcionalidades:
/// - Análisis completo de mercado combinando múltiples indicadores
/// - Generación de señales BUY/SELL/HOLD con niveles de confianza
/// - Análisis rápido para escaneo de múltiples pares
/// - Búsqueda de oportunidades de compra
/// - Análisis de condiciones de mercado (volatilidad, momentum)
///
/// Depende de MarketDataService y TechnicalIndicatorsService
///
/// Copied from [integratedAnalysisService].
@ProviderFor(integratedAnalysisService)
final integratedAnalysisServiceProvider =
    AutoDisposeProvider<IntegratedAnalysisService>.internal(
  integratedAnalysisService,
  name: r'integratedAnalysisServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$integratedAnalysisServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IntegratedAnalysisServiceRef
    = AutoDisposeProviderRef<IntegratedAnalysisService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
