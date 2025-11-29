# Design Document - API Integration Update

## Overview

Este diseño actualiza la capa de integración de APIs de la aplicación Flutter para consumir correctamente las APIs del backend versión 3.1. El enfoque principal es:

1. **Mínima disrupción**: Mantener la arquitectura existente de servicios
2. **Compatibilidad**: Asegurar que el código existente siga funcionando
3. **Extensibilidad**: Agregar nuevas funcionalidades sin romper las existentes
4. **Type Safety**: Usar modelos Dart fuertemente tipados
5. **Error Handling**: Mejorar el manejo de errores con mensajes descriptivos

## Architecture

### Current Architecture (Maintained)

```
┌─────────────────┐
│   UI Layer      │
│  (Screens)      │
└────────┬────────┘
         │
┌────────▼────────┐
│  Provider Layer │
│  (State Mgmt)   │
└────────┬────────┘
         │
┌────────▼────────┐
│ Service Layer   │  ← UPDATES HERE
│  (API Calls)    │
└────────┬────────┘
         │
┌────────▼────────┐
│  Model Layer    │  ← NEW MODELS
│  (Data Models)  │
└────────┬────────┘
         │
┌────────▼────────┐
│   API Client    │
│  (Dio + Config) │
└─────────────────┘
```

### Updated Service Architecture

```
AiBotService
├── getStatus() - Enhanced with new fields
├── getConfig() - NEW: Get dynamic config
├── updateConfig() - NEW: Update config dynamically
├── getComprehensiveAnalysis() - NEW: Full market analysis
├── start/stop/pause/resume()
└── analyze() - Existing

FuturesService
├── getPositions() - Enhanced with mark_price
├── closePosition() - Existing
├── getMarkPrice() - NEW: Get mark price
├── getIndexPrice() - NEW: Get index price
└── Helper methods

MCPService
├── callTool() - Enhanced error handling
├── callToolTyped() - Existing
└── Error handling improvements

MarketDataService
├── getTicker() - Existing
├── getCandles() - Existing
├── getMarkPrice() - NEW: Wrapper for futures
└── Other methods
```

## Components and Interfaces

### 1. New Models

#### ComprehensiveAnalysis Model

```dart
class ComprehensiveAnalysis {
  final String symbol;
  final String exchange;
  final DateTime timestamp;
  final PriceData priceData;
  final Map<String, TechnicalIndicators> technicalIndicators; // Key: timeframe
  final Map<String, Scenario> scenarios; // Key: scenario type
  final Recommendation recommendation;
  
  ComprehensiveAnalysis.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

class PriceData {
  final double last;
  final double bid;
  final double ask;
  final double volume;
  final double high24h;
  final double low24h;
  final double change24h;
  final double changePercent24h;
  
  PriceData.fromJson(Map<String, dynamic> json);
}

class TechnicalIndicators {
  final String timeframe;
  final RSIData? rsi;
  final MACDData? macd;
  final BollingerBandsData? bollingerBands;
  final EMAData? ema;
  final VolumeData? volume;
  
  TechnicalIndicators.fromJson(Map<String, dynamic> json);
}

class Scenario {
  final String type; // 'bullish', 'bearish', 'neutral'
  final double probability;
  final String description;
  final List<String> conditions;
  final double? targetPrice;
  final double? stopLoss;
  
  Scenario.fromJson(Map<String, dynamic> json);
}

class Recommendation {
  final String action; // 'BUY', 'SELL', 'WAIT'
  final double confidence;
  final double? entry;
  final double? stopLoss;
  final double? takeProfit;
  final String reasoning;
  final List<String> risks;
  
  Recommendation.fromJson(Map<String, dynamic> json);
}
```

#### Enhanced AiBotConfig Model

```dart
class AiBotConfig {
  final String pair;
  final String exchange;
  final double confidenceThreshold;
  final double tradeSizeUsd;
  final int leverage;
  final bool dryRun;
  final bool autoExecute;
  final double maxDailyLossUsd;
  final int maxDailyTrades;
  final int maxConsecutiveErrors;
  final int maxOpenPositions;
  
  // Validation methods
  bool isValidConfidenceThreshold() => 
    confidenceThreshold >= 0.5 && confidenceThreshold <= 1.0;
  
  bool isValidLeverage() => 
    leverage >= 1 && leverage <= 100;
  
  AiBotConfig.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  
  // Copy with for updates
  AiBotConfig copyWith({...});
}
```

#### Enhanced AiBotStatus Model

```dart
class AiBotStatus {
  final bool running;
  final bool paused;
  final bool emergencyStop;
  final DateTime? startedAt;
  final DateTime? lastAnalysisAt;
  final int uptimeSeconds;
  final int analysisCount;
  final int executionCount;
  final int errorCount;
  final int consecutiveErrors;
  final double dailyLoss;
  final int dailyTrades;
  final int openPositions;
  final AiBotConfig config;
  
  // Computed properties
  Duration get uptime => Duration(seconds: uptimeSeconds);
  bool get isHealthy => consecutiveErrors < 3;
  bool get hasReachedDailyLimit => 
    dailyTrades >= config.maxDailyTrades || 
    dailyLoss.abs() >= config.maxDailyLossUsd;
  
  AiBotStatus.fromJson(Map<String, dynamic> json);
}
```

#### Enhanced FuturesPosition Model

```dart
class FuturesPosition {
  final String symbol;
  final String side; // 'long' or 'short'
  final double size;
  final double entryPrice;
  final double currentPrice; // mark price
  final double unrealizedPnl;
  final double realizedPnl;
  final int leverage;
  final double margin;
  final String marginMode; // 'ISOLATED' or 'CROSS'
  final double liquidationPrice;
  final double pnlPercent;
  final DateTime updatedAt;
  
  // Computed properties
  double get totalPnl => unrealizedPnl + realizedPnl;
  bool get isProfit => unrealizedPnl > 0;
  bool get isLoss => unrealizedPnl < 0;
  bool get isNearLiquidation => 
    (currentPrice - liquidationPrice).abs() / currentPrice < 0.1; // 10%
  
  FuturesPosition.fromJson(Map<String, dynamic> json);
}
```

### 2. Service Updates

#### AiBotService Updates

```dart
class AiBotService {
  final Dio _dio;
  
  // NEW: Get comprehensive analysis
  Future<ComprehensiveAnalysis> getComprehensiveAnalysis({
    required String symbol,
    String exchange = 'kucoin',
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.comprehensiveAnalysisUrl}',
        data: {
          'symbol': symbol,
          'exchange': exchange,
        },
      );
      return ComprehensiveAnalysis.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // NEW: Get current config
  Future<AiBotConfig> getConfig() async {
    try {
      final response = await _dio.get(ApiConfig.aiBotConfigUrl);
      return AiBotConfig.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // NEW: Update config (bot must be stopped)
  Future<AiBotConfig> updateConfig(Map<String, dynamic> updates) async {
    try {
      final response = await _dio.post(
        ApiConfig.aiBotConfigUrl,
        data: updates,
      );
      final result = response.data as Map<String, dynamic>;
      return AiBotConfig.fromJson(result['config']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ENHANCED: Get status with new fields
  Future<AiBotStatus> getStatus() async {
    try {
      final response = await _dio.get('${ApiConfig.aiBotBaseUrl}/status');
      return AiBotStatus.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // Helper methods for common config updates
  Future<AiBotConfig> enableDryRunMode() async {
    return updateConfig({'dry_run': true, 'auto_execute': false});
  }
  
  Future<AiBotConfig> enableLiveMode() async {
    return updateConfig({'dry_run': false, 'auto_execute': true});
  }
  
  Future<AiBotConfig> updateConfidenceThreshold(double threshold) async {
    if (threshold < 0.5 || threshold > 1.0) {
      throw ApiException(
        message: 'Confidence threshold must be between 0.5 and 1.0',
        code: 'INVALID_THRESHOLD',
      );
    }
    return updateConfig({'confidence_threshold': threshold});
  }
}
```

#### FuturesService Updates

```dart
class FuturesService {
  final Dio _dio;
  
  // ENHANCED: Get positions with mark price
  Future<FuturesPositionsResponse> getPositions({
    String exchange = 'kucoin',
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.mcpToolsUrl,
        data: {
          'jsonrpc': '2.0',
          'method': 'tools/call',
          'params': {
            'name': 'get_futures_positions',
            'arguments': {'exchange': exchange}
          },
          'id': DateTime.now().millisecondsSinceEpoch,
        },
      );
      
      final result = response.data['result'];
      return FuturesPositionsResponse.fromJson(result);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // NEW: Get mark price
  Future<double> getMarkPrice({
    required String symbol,
    String exchange = 'kucoin',
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.mcpToolsUrl,
        data: {
          'jsonrpc': '2.0',
          'method': 'tools/call',
          'params': {
            'name': 'get_mark_price',
            'arguments': {
              'exchange': exchange,
              'symbol': symbol,
            }
          },
          'id': DateTime.now().millisecondsSinceEpoch,
        },
      );
      
      final result = response.data['result'];
      return (result['mark_price'] as num).toDouble();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // NEW: Get index price
  Future<double> getIndexPrice({
    required String symbol,
    String exchange = 'kucoin',
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.mcpToolsUrl,
        data: {
          'jsonrpc': '2.0',
          'method': 'tools/call',
          'params': {
            'name': 'get_index_price',
            'arguments': {
              'exchange': exchange,
              'symbol': symbol,
            }
          },
          'id': DateTime.now().millisecondsSinceEpoch,
        },
      );
      
      final result = response.data['result'];
      return (result['index_price'] as num).toDouble();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
```

#### MCPService Error Handling Enhancement

```dart
class MCPService {
  final Dio _dio;
  
  Future<Map<String, dynamic>> callTool({
    required String toolName,
    required Map<String, dynamic> arguments,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.mcpToolsUrl,
        data: {
          'jsonrpc': '2.0',
          'method': 'tools/call',
          'params': {
            'name': toolName,
            'arguments': arguments,
          },
          'id': DateTime.now().millisecondsSinceEpoch,
        },
      );
      
      final data = response.data as Map<String, dynamic>;
      
      // ENHANCED: Check for JSON-RPC error
      if (data['error'] != null) {
        final error = data['error'] as Map<String, dynamic>;
        throw ApiException(
          message: error['message'] as String? ?? 'MCP Tool error',
          code: error['code']?.toString() ?? 'MCP_ERROR',
          details: error['data'],
        );
      }
      
      if (data['result'] == null) {
        throw ApiException(
          message: 'No result in MCP response',
          code: 'NO_RESULT',
        );
      }
      
      return data['result'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ENHANCED: Better error messages
  ApiException _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      
      // JSON-RPC error format
      if (data is Map<String, dynamic> && data['error'] != null) {
        final error = data['error'];
        return ApiException(
          message: error['message'] ?? 'MCP error',
          code: error['code']?.toString(),
          details: error['data'],
          statusCode: e.response!.statusCode,
        );
      }
    }
    
    // Network errors with helpful messages
    if (e.type == DioExceptionType.connectionTimeout) {
      return ApiException(
        message: 'Connection timeout - check network connection',
        code: 'TIMEOUT',
        hint: 'Verify server is running at ${ApiConfig.serverIp}',
      );
    }
    
    if (e.type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'Connection error - server might be down',
        code: 'CONNECTION_ERROR',
        hint: 'Check if MCP Server is running on port 10600',
      );
    }
    
    return ApiException(
      message: 'Network error: ${e.message}',
      code: 'NETWORK_ERROR',
    );
  }
}
```

### 3. API Configuration Updates

```dart
class ApiConfig {
  // Existing configuration maintained
  static const String serverIp = '192.168.100.145';
  static const String gatewayBaseUrl = 'http://$serverIp:9090';
  static const String mcpDirectUrl = 'http://$serverIp:10600';
  
  // NEW: Comprehensive analysis endpoint
  static const String comprehensiveAnalysisUrl = 
    '$mcpDirectUrl/api/v1/ai-bot/comprehensive-analysis';
  
  // NEW: Dynamic config endpoint
  static const String aiBotConfigUrl = 
    '$mcpDirectUrl/api/v1/ai-bot/config';
  
  // Existing endpoints
  static const String aiBotBaseUrl = '$mcpDirectUrl/api/v1/ai-bot';
  static const String mcpToolsUrl = '$gatewayBaseUrl/api/mcp/tools/execute';
  
  // NEW: Validation method
  static bool validateConfiguration() {
    try {
      // Check if URLs are properly formatted
      Uri.parse(gatewayBaseUrl);
      Uri.parse(mcpDirectUrl);
      Uri.parse(comprehensiveAnalysisUrl);
      return true;
    } catch (e) {
      return false;
    }
  }
}
```

## Data Models

### Model Hierarchy

```
ComprehensiveAnalysis
├── PriceData
├── TechnicalIndicators (per timeframe)
│   ├── RSIData
│   ├── MACDData
│   ├── BollingerBandsData
│   ├── EMAData
│   └── VolumeData
├── Scenario (bullish/bearish/neutral)
└── Recommendation

AiBotStatus
└── AiBotConfig

FuturesPositionsResponse
└── List<FuturesPosition>

CloseFuturesPositionResponse
```

### JSON Parsing Strategy

All models will use:
1. **Null safety**: Handle missing fields gracefully
2. **Type conversion**: Convert num to double, int as needed
3. **Default values**: Provide sensible defaults for optional fields
4. **Validation**: Validate critical fields in fromJson

Example:
```dart
class ComprehensiveAnalysis {
  ComprehensiveAnalysis.fromJson(Map<String, dynamic> json)
      : symbol = json['symbol'] as String? ?? '',
        exchange = json['exchange'] as String? ?? 'kucoin',
        timestamp = json['timestamp'] != null
            ? DateTime.parse(json['timestamp'])
            : DateTime.now(),
        priceData = PriceData.fromJson(
          json['price_data'] as Map<String, dynamic>? ?? {}
        ),
        technicalIndicators = _parseTechnicalIndicators(
          json['technical_indicators']
        ),
        scenarios = _parseScenarios(json['scenarios']),
        recommendation = Recommendation.fromJson(
          json['recommendation'] as Map<String, dynamic>? ?? {}
        );
  
  static Map<String, TechnicalIndicators> _parseTechnicalIndicators(
    dynamic data
  ) {
    if (data == null || data is! Map) return {};
    
    return Map.fromEntries(
      (data as Map<String, dynamic>).entries.map(
        (e) => MapEntry(
          e.key,
          TechnicalIndicators.fromJson(e.value as Map<String, dynamic>)
        )
      )
    );
  }
}
```

## Error Handling

### Error Hierarchy

```
ApiException (base)
├── NetworkException
│   ├── TimeoutException
│   └── ConnectionException
├── ServerException
│   ├── InternalServerException (500)
│   └── ServiceUnavailableException (503)
├── ClientException
│   ├── BadRequestException (400)
│   ├── UnauthorizedException (401)
│   ├── ForbiddenException (403)
│   └── NotFoundException (404)
└── TradingException
    ├── InsufficientBalanceException
    ├── RiskLimitExceededException
    ├── KillSwitchActiveException
    └── BotConfigException
```

### Error Messages

```dart
class ErrorMessages {
  static const Map<String, String> userFriendly = {
    'TIMEOUT': 'La conexión tardó demasiado. Verifica tu red.',
    'CONNECTION_ERROR': 'No se pudo conectar al servidor. Verifica que esté corriendo.',
    'INSUFFICIENT_BALANCE': 'Balance insuficiente para ejecutar la operación.',
    'RISK_LIMIT_EXCEEDED': 'Límite de riesgo excedido. Operación bloqueada.',
    'KILL_SWITCH_ACTIVE': 'Sistema de emergencia activado. Trading pausado.',
    'POSITION_NOT_FOUND': 'La posición no existe o ya fue cerrada.',
    'INVALID_THRESHOLD': 'El umbral de confianza debe estar entre 0.5 y 1.0.',
    'BOT_RUNNING': 'No se puede cambiar la configuración mientras el bot está corriendo.',
  };
  
  static String getFriendlyMessage(String code, {String? fallback}) {
    return userFriendly[code] ?? fallback ?? 'Error desconocido';
  }
}
```

## Testing Strategy

### Unit Tests

1. **Model Tests**
   - Test JSON parsing with valid data
   - Test JSON parsing with missing fields
   - Test JSON parsing with invalid types
   - Test computed properties

2. **Service Tests**
   - Mock Dio responses
   - Test successful API calls
   - Test error handling
   - Test parameter validation

3. **Error Handling Tests**
   - Test JSON-RPC error extraction
   - Test network error messages
   - Test user-friendly error mapping

### Integration Tests

1. **API Integration**
   - Test comprehensive analysis endpoint
   - Test dynamic config endpoints
   - Test new MCP tools
   - Test error scenarios

2. **End-to-End Flows**
   - Get comprehensive analysis → Display in UI
   - Update bot config → Verify changes
   - Get positions → Close position
   - Handle errors → Show user message

### Test Data

Create mock responses for:
- Comprehensive analysis (all scenarios)
- Bot status (running, paused, stopped)
- Bot config (various configurations)
- Futures positions (profit, loss, near liquidation)
- Error responses (all error types)

## Migration Strategy

### Phase 1: Add New Models (No Breaking Changes)
- Add ComprehensiveAnalysis model
- Add enhanced AiBotStatus model
- Add enhanced AiBotConfig model
- Add enhanced FuturesPosition model

### Phase 2: Update Services (Backward Compatible)
- Add new methods to AiBotService
- Add new methods to FuturesService
- Enhance error handling in MCPService
- Keep existing methods working

### Phase 3: Update UI (Gradual)
- Update screens to use new models
- Add comprehensive analysis screen
- Add dynamic config screen
- Enhance error messages

### Phase 4: Deprecate Old Code (Optional)
- Mark old methods as deprecated
- Provide migration guide
- Remove after grace period

## Performance Considerations

1. **Caching**: Cache comprehensive analysis for 30 seconds
2. **Debouncing**: Debounce config updates to prevent spam
3. **Lazy Loading**: Load technical indicators on demand
4. **Connection Pooling**: Reuse Dio instance
5. **Timeout Management**: Set appropriate timeouts per endpoint

## Security Considerations

1. **API Keys**: Never log API keys or sensitive data
2. **HTTPS**: Use HTTPS in production (currently HTTP for local dev)
3. **Input Validation**: Validate all user inputs before sending to API
4. **Error Messages**: Don't expose internal details in error messages
5. **Rate Limiting**: Respect API rate limits

## Monitoring and Logging

```dart
class ApiLogger {
  static void logRequest(String endpoint, Map<String, dynamic> data) {
    if (ApiConfig.enableLogging) {
      developer.log(
        'API Request: $endpoint',
        name: 'ApiClient',
        error: data,
      );
    }
  }
  
  static void logResponse(String endpoint, dynamic data) {
    if (ApiConfig.enableLogging) {
      developer.log(
        'API Response: $endpoint',
        name: 'ApiClient',
      );
    }
  }
  
  static void logError(String endpoint, ApiException error) {
    developer.log(
      'API Error: $endpoint - ${error.message}',
      name: 'ApiClient',
      error: error,
    );
  }
}
```

## Rollback Plan

If issues arise:
1. **Immediate**: Revert to previous service implementations
2. **Short-term**: Use feature flags to toggle new functionality
3. **Long-term**: Fix issues and redeploy

Feature flag example:
```dart
class FeatureFlags {
  static const bool useComprehensiveAnalysis = true;
  static const bool useDynamicConfig = true;
  static const bool useNewMCPTools = true;
}
```

## Documentation Updates

Update the following docs:
1. API integration guide
2. Service usage examples
3. Error handling guide
4. Model reference
5. Testing guide

## Success Metrics

- ✅ All 10 requirements implemented
- ✅ Zero breaking changes to existing code
- ✅ 100% test coverage for new code
- ✅ Error rate < 1%
- ✅ Response time < 500ms for comprehensive analysis
- ✅ User-friendly error messages for all error types
