# Design Document - Backend Integration Complete

## Overview

Este documento describe el diseño de la integración completa con el Trading MCP Server. La arquitectura sigue el patrón de capas (layered architecture) con separación clara de responsabilidades.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         UI Layer                             │
│  (Screens, Widgets, State Management)                       │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                    Provider Layer                            │
│  (State Management, Business Logic)                         │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                    Service Layer                             │
│  (API Clients, Data Fetching)                               │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                    Model Layer                               │
│  (Data Models, DTOs)                                        │
└─────────────────────────────────────────────────────────────┘
```

## Components and Interfaces

### 1. Service Layer

#### TradingApiService
**Responsabilidad**: Cliente principal para comunicación con el backend

```dart
class TradingApiService {
  final Dio _dio;
  final String baseUrl;
  
  // Comprehensive Analysis
  Future<ComprehensiveAnalysis> getComprehensiveAnalysis({
    required String symbol,
    String exchange = 'kucoin',
    MarketType? marketType,
  });
  
  // Bot Management
  Future<BotStatus> getBotStatus();
  Future<BotStartResponse> startBot();
  Future<BotStopResponse> stopBot();
  Future<BotConfig> getBotConfig();
  Future<BotConfig> updateBotConfig(BotConfig config);
  
  // Positions
  Future<PositionsResponse> getPositions({MarketType? marketType});
  
  // Health
  Future<HealthResponse> getHealth();
  
  // Tools
  Future<List<Tool>> listTools();
}
```

#### ComprehensiveAnalysisService (Existing - Refactor)
**Responsabilidad**: Servicio especializado para análisis comprehensivo

```dart
class ComprehensiveAnalysisService {
  final Dio _dio;
  
  Future<ComprehensiveAnalysis> getAnalysis({
    required String symbol,
    String exchange = 'kucoin',
    MarketType? marketType,
  });
  
  Future<List<ComprehensiveAnalysis>> getMultipleAnalyses({
    required List<String> symbols,
    String exchange = 'kucoin',
    MarketType? marketType,
  });
}
```

#### AIBotService (New)
**Responsabilidad**: Gestión del bot de trading

```dart
class AIBotService {
  final Dio _dio;
  
  Future<BotStatus> getStatus();
  Future<BotStartResponse> start();
  Future<BotStopResponse> stop();
  Future<BotConfig> getConfig();
  Future<BotConfig> updateConfig(BotConfig config);
  Future<PositionsResponse> getPositions({MarketType? marketType});
}
```

#### HealthService (New)
**Responsabilidad**: Monitoreo de salud del backend

```dart
class HealthService {
  final Dio _dio;
  
  Future<HealthResponse> check();
  Stream<HealthResponse> monitorHealth({Duration interval});
}
```

### 2. Model Layer

#### Core Models (Existing - Enhance)

**ComprehensiveAnalysis** (Already implemented with market types)
- ✅ Ya tiene marketType, futuresData, marginData, optionsData
- ✅ Ya tiene keyLevels, riskAssessment
- ⚠️ Necesita agregar: multiTimeframe, recentMovement, scenarios

**Nuevos campos a agregar**:
```dart
class ComprehensiveAnalysis {
  // ... campos existentes ...
  
  // ❌ FALTA: Multi-timeframe analysis
  final MultiTimeframeAnalysis? multiTimeframe;
  
  // ❌ FALTA: Recent movement (últimas 10 velas)
  final List<Candle>? recentMovement;
  
  // ✅ YA EXISTE: scenarios (pero verificar estructura)
  final Map<String, Scenario> scenarios;
  
  // ❌ FALTA: Technical analysis detallado
  final TechnicalAnalysis? technicalAnalysis;
}
```

#### New Models

**MultiTimeframeAnalysis**
```dart
class MultiTimeframeAnalysis {
  final TimeframeData tf1m;
  final TimeframeData tf5m;
  final TimeframeData tf15m;
  final TimeframeData tf1h;
  final String alignment; // "aligned", "not_aligned"
  
  bool get isAligned => alignment == 'aligned';
}

class TimeframeData {
  final double rsi;
  final String signal; // "oversold", "overbought", "neutral"
  final String trend; // "bullish", "bearish", "neutral"
  
  bool get isOversold => signal == 'oversold';
  bool get isOverbought => signal == 'overbought';
  bool get isBullish => trend == 'bullish';
  bool get isBearish => trend == 'bearish';
}
```

**TechnicalAnalysis**
```dart
class TechnicalAnalysis {
  final RSIData rsi;
  final MACDData macd;
  final BollingerBandsData? bollinger;
  final EMAData? ema;
  final String trend; // "bullish", "bearish", "neutral"
  final double strength; // 0.0 - 1.0
}
```

**BotStatus**
```dart
class BotStatus {
  final bool aiEnabled;
  final String status; // "ok", "error", "stopped"
  final bool isRunning;
  
  bool get isHealthy => status == 'ok';
}
```

**BotConfig**
```dart
class BotConfig {
  final double confidenceThreshold;
  final bool dryRun;
  final int maxPositions;
  final double maxRiskPerTrade;
  
  Map<String, dynamic> toJson();
  factory BotConfig.fromJson(Map<String, dynamic> json);
}
```

**PositionsResponse**
```dart
class PositionsResponse {
  final List<Position> positions;
  final int count;
  final double totalPnL;
  final double totalPnLPercent;
}

class Position {
  final String symbol;
  final MarketType marketType;
  final String side; // "long", "short"
  final double size;
  final double entryPrice;
  final double currentPrice;
  final double unrealizedPnL;
  final double pnLPercent;
  final int? leverage;
  final double? liquidationPrice;
  final double? fundingRate;
}
```

**HealthResponse**
```dart
class HealthResponse {
  final String status;
  final bool gctConnected;
  final int toolsCount;
  final String? uptime;
  final String? version;
  
  bool get isHealthy => status == 'ok' || status == 'healthy';
}
```

### 3. Provider Layer

#### ComprehensiveAnalysisProvider (Existing - Enhance)
```dart
class ComprehensiveAnalysisProvider extends ChangeNotifier {
  final ComprehensiveAnalysisService _service;
  
  ComprehensiveAnalysis? _analysis;
  bool _isLoading = false;
  String? _error;
  MarketType _selectedMarketType = MarketType.futures;
  
  // Getters
  ComprehensiveAnalysis? get analysis => _analysis;
  bool get isLoading => _isLoading;
  String? get error => _error;
  MarketType get selectedMarketType => _selectedMarketType;
  
  // Methods
  Future<void> loadAnalysis(String symbol);
  void setMarketType(MarketType type);
  void clearError();
}
```

#### AIBotProvider (New)
```dart
class AIBotProvider extends ChangeNotifier {
  final AIBotService _service;
  
  BotStatus? _status;
  BotConfig? _config;
  PositionsResponse? _positions;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  BotStatus? get status => _status;
  BotConfig? get config => _config;
  PositionsResponse? get positions => _positions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isBotRunning => _status?.isRunning ?? false;
  
  // Methods
  Future<void> loadStatus();
  Future<void> loadConfig();
  Future<void> loadPositions();
  Future<void> startBot();
  Future<void> stopBot();
  Future<void> updateConfig(BotConfig config);
  void startAutoRefresh({Duration interval = const Duration(seconds: 5)});
  void stopAutoRefresh();
}
```

#### HealthProvider (New)
```dart
class HealthProvider extends ChangeNotifier {
  final HealthService _service;
  
  HealthResponse? _health;
  bool _isConnected = false;
  DateTime? _lastCheck;
  
  // Getters
  HealthResponse? get health => _health;
  bool get isConnected => _isConnected;
  DateTime? get lastCheck => _lastCheck;
  
  // Methods
  Future<void> checkHealth();
  void startMonitoring({Duration interval = const Duration(seconds: 30)});
  void stopMonitoring();
}
```

### 4. UI Layer

#### Screens

**ComprehensiveAnalysisScreen** (Existing - Enhance)
- Agregar selector de market type
- Mostrar multi-timeframe analysis
- Mostrar recent movement (gráfico de velas)
- Mostrar scenarios con probabilidades
- Mejorar visualización de recomendaciones

**AIBotControlScreen** (New)
- Estado del bot (running/stopped)
- Botones start/stop
- Configuración del bot
- Lista de posiciones abiertas
- P&L total

**PositionsScreen** (New)
- Lista de posiciones
- Filtro por market type
- Detalles de cada posición
- P&L individual y total
- Botones de acción (close position)

**HealthMonitorScreen** (New - Optional)
- Estado del servidor
- Uptime y versión
- Conectividad
- Logs de errores

## Data Models

### Existing Models to Enhance

1. **ComprehensiveAnalysis**
   - ✅ marketType
   - ✅ futuresData, marginData, optionsData
   - ✅ keyLevels, riskAssessment
   - ❌ multiTimeframe (AGREGAR)
   - ❌ recentMovement (AGREGAR)
   - ⚠️ scenarios (VERIFICAR estructura)
   - ❌ technicalAnalysis detallado (AGREGAR)

2. **Recommendation** (Existing)
   - ✅ action, confidence, reasoning
   - ⚠️ Verificar si tiene entry, stopLoss, takeProfit

3. **Scenario** (Existing)
   - ⚠️ Verificar estructura vs backend

### New Models to Create

1. **MultiTimeframeAnalysis** + **TimeframeData**
2. **TechnicalAnalysis** (detallado con RSI, MACD, Bollinger, EMA)
3. **BotStatus**
4. **BotConfig**
5. **PositionsResponse** + **Position**
6. **HealthResponse**
7. **BotStartResponse** / **BotStopResponse**

## Error Handling

### Error Types

```dart
class TradingApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;
  
  TradingApiException(this.message, {this.statusCode, this.details});
}

class NetworkException extends TradingApiException {
  NetworkException(String message) : super(message);
}

class ParsingException extends TradingApiException {
  ParsingException(String message) : super(message);
}

class ValidationException extends TradingApiException {
  ValidationException(String message) : super(message);
}
```

### Error Handling Strategy

1. **Network Errors**: Retry con exponential backoff (max 3 intentos)
2. **Parsing Errors**: Log y mostrar mensaje genérico al usuario
3. **Validation Errors**: Mostrar mensaje específico al usuario
4. **Backend Errors**: Mostrar mensaje del backend al usuario

## Testing Strategy

### Unit Tests

1. **Models**: fromJson, toJson, helpers
2. **Services**: Mocking Dio responses
3. **Providers**: State management logic
4. **Validators**: Input validation

### Integration Tests

1. **API Endpoints**: Requests reales al backend (en test environment)
2. **End-to-End**: Flujos completos de usuario

### Widget Tests

1. **Screens**: Rendering y interacciones
2. **Components**: Widgets reutilizables

## Performance Considerations

1. **Caching**: Cachear responses de análisis por 30 segundos
2. **Debouncing**: Debounce de búsqueda de símbolos (300ms)
3. **Pagination**: Para listas de posiciones (si > 50)
4. **Lazy Loading**: Cargar datos bajo demanda
5. **Background Refresh**: Actualizar posiciones en background cada 5s

## Security Considerations

1. **No Auth Required**: Backend no requiere autenticación actualmente
2. **HTTPS**: Considerar migrar a HTTPS en producción
3. **Input Validation**: Validar todos los inputs del usuario
4. **Error Messages**: No exponer detalles técnicos al usuario

## Deployment Strategy

### Phase 1: Core Integration (Week 1)
- Refactorizar ComprehensiveAnalysisService
- Crear modelos faltantes
- Implementar AIBotService
- Testing básico

### Phase 2: UI Enhancement (Week 2)
- Mejorar ComprehensiveAnalysisScreen
- Crear AIBotControlScreen
- Crear PositionsScreen
- Testing de UI

### Phase 3: Polish & Testing (Week 3)
- Error handling robusto
- Performance optimization
- Integration tests
- Documentation

## AI Integration Architecture

### AI-Specific Components

#### AI Models
```dart
// LLM Analysis
class LLMAnalysis {
  final String provider;           // "google", "openai", "anthropic"
  final String model;              // "gemini-2.5-flash", "gpt-4", "claude-3"
  final String explanation;        // Explicación detallada del LLM
  final List<String> keyFactors;   // Factores clave identificados
  final String riskAssessment;     // "low", "medium", "high"
  final double confidence;         // 0.0 - 1.0
}

// Sentiment Analysis
class SentimentAnalysis {
  final double overall;            // -1.0 (bearish) to 1.0 (bullish)
  final String trend;              // "bullish", "bearish", "neutral"
  final List<String> sources;     // ["news", "twitter", "reddit"]
  final double confidence;         // 0.0 - 1.0
}

// AI Costs
class AICosts {
  final DailyCosts today;
  final MonthlyCosts thisMonth;
}

// AI Status
class AIStatus {
  final LLMStatus llm;
  final SentimentStatus sentiment;
  final CostManagement costManagement;
}
```

#### AI Services
```dart
class AIService {
  Future<AIStatus> getAIStatus();
  Future<AICosts> getAICosts();
  Future<List<AINotification>> getAINotifications();
  Future<ComprehensiveAnalysis> getAIAnalysis({
    required String symbol,
    required String exchange,
    bool enableLLM = true,
    bool enableSentiment = true,
  });
}

class AIFallbackService {
  Future<ComprehensiveAnalysis> getAnalysisWithFallback({
    required String symbol,
    required String exchange,
    bool enableLLM = true,
    bool enableSentiment = true,
  });
}
```

#### AI Providers
```dart
@riverpod
class AIStatusNotifier extends _$AIStatusNotifier {
  // Auto-refresh every 30 seconds
  // Handle loading/error states
  // Cache for 30 seconds
}

@riverpod
class AICostsNotifier extends _$AICostsNotifier {
  // Track daily usage
  // Budget alerts
  // Cache for 10 minutes
}

@riverpod
class AINotificationsNotifier extends _$AINotificationsNotifier {
  // Real-time notifications
  // Mark as read functionality
  // Unread count
}
```

#### AI UI Components
```dart
class AIAnalysisCard extends StatelessWidget {
  // Display LLM explanation
  // Show confidence level
  // Display key factors
  // Risk assessment
}

class AIStatusIndicator extends ConsumerWidget {
  // Compact and full modes
  // LLM status
  // Usage progress
  // Budget tracking
}

class SentimentIndicator extends StatelessWidget {
  // Visual sentiment display
  // Trend indicators
  // Source information
}
```

### Enhanced Existing Components

#### ComprehensiveAnalysis (Enhanced)
```dart
class ComprehensiveAnalysis {
  // ... existing fields ...
  
  // NEW AI FIELDS
  final LLMAnalysis? llmAnalysis;
  final SentimentAnalysis? sentimentAnalysis;
  
  // Helpers
  bool get hasLLMAnalysis => llmAnalysis != null;
  bool get hasSentimentAnalysis => sentimentAnalysis != null;
  bool get isAIEnhanced => hasLLMAnalysis || hasSentimentAnalysis;
}
```

#### ComprehensiveAnalysisService (Enhanced)
```dart
class ComprehensiveAnalysisService {
  Future<ComprehensiveAnalysis> getComprehensiveAnalysis({
    required String symbol,
    required String exchange,
    bool enableLLM = true,
    bool enableSentiment = true,
    bool fallbackOnError = true,
  });
}
```

### AI Error Handling

#### AI-Specific Exceptions
```dart
abstract class AIException implements Exception {
  final String message;
  final String? details;
}

class AIBudgetExceededException extends AIException {
  final double currentSpent;
  final double dailyBudget;
}

class AILimitReachedException extends AIException {
  final int currentCalls;
  final int dailyLimit;
}

class AIProviderUnavailableException extends AIException {
  final String provider;
}
```

#### Fallback Strategy
1. **Try AI Analysis First**: If enableLLM or enableSentiment is true
2. **Handle Specific Errors**:
   - Budget exceeded → Inform user, continue with regular analysis
   - Limit reached → Inform user, continue with regular analysis
   - Provider unavailable → Silent fallback to regular analysis
   - Other errors → Log and fallback to regular analysis
3. **Always Provide Analysis**: Never fail completely, always return some analysis

### AI Caching Strategy
- **AI Analysis**: 5 minutes (balance between freshness and cost)
- **AI Status**: 30 seconds (frequent updates for monitoring)
- **AI Costs**: 10 minutes (moderate frequency)
- **Notifications**: No cache (real-time updates)

### AI Performance Considerations
- **Smart Caching**: Reduce redundant AI calls
- **Fallback First**: Show regular analysis immediately, enhance with AI
- **Budget Monitoring**: Proactive warnings at 80% budget usage
- **Circuit Breaker**: Stop AI calls when budget/limits reached
- **Background Loading**: Load AI data in background threads

## Migration Plan

### Existing Code
- ✅ ComprehensiveAnalysisService existe
- ✅ ComprehensiveAnalysis model existe (con market types)
- ✅ MarketService existe (con solución híbrida)
- ⚠️ Necesita refactoring para nuevos campos de IA

### New AI Code
- ❌ AIService (crear)
- ❌ AIFallbackService (crear)
- ❌ Modelos de IA (crear)
- ❌ Providers de IA (crear)
- ❌ Pantallas de IA (crear)
- ❌ Componentes UI de IA (crear)

### Existing Code to Enhance
- ❌ AIBotService (crear)
- ❌ HealthService (crear)
- ❌ Nuevos modelos base (crear)
- ❌ Nuevos providers base (crear)
- ❌ Nuevas screens base (crear)

### Refactoring Needed
- ⚠️ ComprehensiveAnalysis model (agregar campos de IA)
- ⚠️ ComprehensiveAnalysisService (agregar soporte completo de IA)
- ⚠️ ComprehensiveAnalysisScreen (integrar componentes de IA)
- ⚠️ CacheService (agregar estrategias de caché de IA)
