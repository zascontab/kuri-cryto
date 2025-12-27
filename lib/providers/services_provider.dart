// GENERATED CODE - DO NOT MODIFY BY HAND
// To regenerate, run: flutter pub run build_runner build

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../services/api_client.dart';
import '../services/scalping_service.dart';
import '../services/position_service.dart';
import '../services/strategy_service.dart';
import '../services/risk_service.dart';
import '../services/websocket_service.dart';
import '../services/analysis_service.dart';
import '../services/backtest_service.dart';
import '../services/optimization_service.dart';
import '../services/execution_service.dart';
import '../services/alert_service.dart';
import '../services/ai_bot_service.dart';
import '../services/comprehensive_analysis_service.dart';
import '../services/futures_service.dart';
import '../services/mcp_service.dart';
import '../services/market_data_service.dart';
import '../services/technical_indicators_service.dart';
import '../services/account_portfolio_service.dart';
import '../services/integrated_analysis_service.dart';

part 'services_provider.g.dart';

/// Provider for Dio HTTP client
///
/// Configured with:
/// - Base URL (API Gateway)
/// - Connect timeout: 10s
/// - Receive timeout: 30s
/// - Send timeout: 30s
/// - JSON content type
/// - Logging interceptor (debug mode)
@riverpod
Dio dio(DioRef ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.apiBaseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: ApiConfig.defaultHeaders,
    ),
  );

  // Add interceptor for logging in debug mode
  if (ApiConfig.enableLogging) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: ApiConfig.logRequestBody,
        responseBody: ApiConfig.logResponseBody,
        error: true,
        logPrint: (obj) => print('[API] $obj'),
      ),
    );
  }

  return dio;
}

/// Provider for API client
///
/// Creates ApiClient with custom error handling and retry logic
@riverpod
ApiClient apiClient(ApiClientRef ref) {
  return ApiClient();
}

/// Provider for Scalping Service
///
/// Handles all scalping-related API calls:
/// - System control (start/stop)
/// - Status and metrics
/// - Health check
@riverpod
ScalpingService scalpingService(ScalpingServiceRef ref) {
  final client = ref.watch(apiClientProvider);
  return ScalpingService(client);
}

/// Provider for Position Service
///
/// Manages position-related operations:
/// - Get open positions
/// - Get position history
/// - Close positions
/// - Update SL/TP
/// - Move to breakeven
/// - Enable trailing stop
@riverpod
PositionService positionService(PositionServiceRef ref) {
  final client = ref.watch(apiClientProvider);
  return PositionService(client);
}

/// Provider for Strategy Service
///
/// Handles strategy configuration and control:
/// - List strategies
/// - Start/Stop strategies
/// - Update strategy config
/// - Get strategy performance
@riverpod
StrategyService strategyService(StrategyServiceRef ref) {
  final client = ref.watch(apiClientProvider);
  return StrategyService(client);
}

/// Provider for Risk Service
///
/// Manages risk parameters and monitoring:
/// - Get/Update risk limits
/// - Get exposure
/// - Risk Sentinel state
/// - Kill switch activation/deactivation
@riverpod
RiskService riskService(RiskServiceRef ref) {
  final client = ref.watch(apiClientProvider);
  return RiskService(client);
}

/// Provider for WebSocket Service
///
/// Manages WebSocket connection for real-time updates:
/// - Position updates
/// - Metrics updates
/// - Alerts
/// - Kill switch events
///
/// Auto-reconnection with exponential backoff
@riverpod
WebSocketService websocketService(WebsocketServiceRef ref) {
  final service = WebSocketService(url: ApiConfig.wsBaseUrl);

  // Ensure cleanup on provider disposal
  ref.onDispose(() {
    service.disconnect();
  });

  return service;
}

/// Provider for Analysis Service
///
/// Handles multi-timeframe market analysis:
/// - Technical indicators (RSI, MACD, Bollinger)
/// - Signal generation
/// - Consensus analysis across timeframes
@riverpod
AnalysisService analysisService(AnalysisServiceRef ref) {
  final client = ref.watch(apiClientProvider);
  return AnalysisService(client);
}

/// Provider for Backtest Service
///
/// Manages strategy backtesting:
/// - Run backtests with historical data
/// - Get performance metrics
/// - Trade history and equity curves
@riverpod
BacktestService backtestService(BacktestServiceRef ref) {
  final client = ref.watch(apiClientProvider);
  return BacktestService(client);
}

/// Provider for Optimization Service
///
/// Manages parameter optimization:
/// - Run parameter optimizations
/// - Get optimization results
/// - Apply optimal parameters
/// - Manage optimization history
@riverpod
OptimizationService optimizationService(OptimizationServiceRef ref) {
  final client = ref.watch(apiClientProvider);
  return OptimizationService(client);
}

/// Provider for Execution Service
///
/// Handles execution statistics and performance:
/// - Latency statistics
/// - Execution history
/// - Queue management
/// - Performance metrics
/// - Metrics export
@riverpod
ExecutionService executionService(ExecutionServiceRef ref) {
  final client = ref.watch(apiClientProvider);
  return ExecutionService(client);
}

/// Provider for Alert Service
///
/// Manages alert system:
/// - Configure alert rules
/// - Get alert history
/// - Acknowledge/dismiss alerts
/// - Get active alerts
/// - Test alert configuration
@riverpod
AlertService alertService(AlertServiceRef ref) {
  final client = ref.watch(apiClientProvider);
  return AlertService(client);
}

/// Provider for AI Bot Service
///
/// Manages AI trading bot operations:
/// - Bot control (start/stop/pause/resume)
/// - Status monitoring
/// - Configuration management
/// - Position tracking
/// - Market analysis with AI
/// - Emergency stop
@riverpod
AIBotService aiBotService(AiBotServiceRef ref) {
  final dio = ref.watch(dioProvider);
  return AIBotService(dio);
}

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
@riverpod
ComprehensiveAnalysisService comprehensiveAnalysisService(
  ComprehensiveAnalysisServiceRef ref,
) {
  final dio = ref.watch(dioProvider);
  return ComprehensiveAnalysisService(dio);
}

/// Provider for Futures Service
///
/// Handles futures trading operations on KuCoin:
/// - Get open futures positions
/// - Close positions (single/all/filtered)
/// - Stop loss and take profit management
/// - Mark and index price retrieval
/// - Symbol conversion helpers (spot <-> futures)
@riverpod
FuturesService futuresService(FuturesServiceRef ref) {
  final dio = ref.watch(dioProvider);
  return FuturesService(dio);
}

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
@riverpod
MCPService mcpService(McpServiceRef ref) {
  final dio = ref.watch(dioProvider);
  return MCPService(dio);
}

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
@riverpod
MarketDataService marketDataService(MarketDataServiceRef ref) {
  final mcpService = ref.watch(mcpServiceProvider);
  return MarketDataService(mcpService);
}

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
@riverpod
TechnicalIndicatorsService technicalIndicatorsService(
  TechnicalIndicatorsServiceRef ref,
) {
  final mcpService = ref.watch(mcpServiceProvider);
  return TechnicalIndicatorsService(mcpService);
}

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
@riverpod
AccountPortfolioService accountPortfolioService(
  AccountPortfolioServiceRef ref,
) {
  final mcpService = ref.watch(mcpServiceProvider);
  return AccountPortfolioService(mcpService);
}

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
@riverpod
IntegratedAnalysisService integratedAnalysisService(
  IntegratedAnalysisServiceRef ref,
) {
  final marketDataService = ref.watch(marketDataServiceProvider);
  final technicalIndicatorsService =
      ref.watch(technicalIndicatorsServiceProvider);
  return IntegratedAnalysisService(
    marketDataService,
    technicalIndicatorsService,
  );
}
