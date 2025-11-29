# 📋 Plan de Implementación - Integración MCP Backend

**Proyecto**: Kuri Crypto
**Backend**: Trading MCP Server v3.1
**Fecha**: 20 Noviembre 2025
**Estado**: Planificación

---

## 📊 Análisis de Situación Actual

### ✅ Implementado (36% - 32/89 endpoints)

- **AI Bot Service**: 9/9 endpoints (100%) ✅
- **Scalping Service**: 9/9 endpoints (100%) ✅
- **Futures Service**: 4/4 endpoints (100%) ✅
- **MCP Tools**: ~10/67 herramientas (~15%) ⚠️

### ⚠️ Pendiente (64% - 57/89 endpoints)

- **MCP Tools Genéricos**: ~57 herramientas sin implementar
- **Comprehensive Analysis**: Endpoint nuevo sin implementar
- **Account Info**: Tool sin implementar
- **Risk State**: Tool sin implementar

---

## 🎯 Objetivos del Plan

1. **Crear infraestructura genérica** para MCP Tools (JSON-RPC 2.0)
2. **Implementar endpoints críticos** faltantes
3. **Mejorar cobertura** de herramientas MCP a 60%+
4. **Mantener compatibilidad** con código existente
5. **Documentar** todos los cambios

---

## 📅 Plan de Implementación por Fases

---

## 🔴 **FASE 1: Infraestructura Base** (Prioridad ALTA)
**Duración estimada**: 2-3 horas
**Objetivo**: Crear servicio genérico MCP para centralizar JSON-RPC

### 1.1. Crear MCPService Base

**Archivo**: `lib/services/mcp_service.dart`

```dart
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'api_exception.dart';

/// Servicio genérico para llamadas MCP Tools via JSON-RPC 2.0
///
/// Este servicio centraliza todas las llamadas a las 67 herramientas
/// disponibles en el Trading MCP Server.
class MCPService {
  final Dio _dio;
  int _requestId = 0;

  MCPService(this._dio);

  /// Ejecuta cualquier herramienta MCP usando JSON-RPC 2.0
  ///
  /// [toolName]: Nombre de la herramienta (ej: 'get_ticker', 'calculate_rsi')
  /// [arguments]: Argumentos de la herramienta
  ///
  /// Returns: Resultado de la herramienta (response.data['result'])
  Future<Map<String, dynamic>> callTool({
    required String toolName,
    required Map<String, dynamic> arguments,
  }) async {
    try {
      _requestId++;

      final response = await _dio.post(
        ApiConfig.mcpToolsUrl,
        data: {
          'jsonrpc': '2.0',
          'method': 'tools/call',
          'params': {
            'name': toolName,
            'arguments': arguments,
          },
          'id': _requestId,
        },
      );

      // Validar respuesta JSON-RPC
      if (response.data['error'] != null) {
        throw ApiException(
          message: response.data['error']['message'] ?? 'MCP Tool error',
          code: response.data['error']['code']?.toString(),
        );
      }

      return response.data['result'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Llama a una herramienta y retorna un tipo específico
  Future<T> callToolTyped<T>({
    required String toolName,
    required Map<String, dynamic> arguments,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final result = await callTool(
      toolName: toolName,
      arguments: arguments,
    );
    return fromJson(result);
  }

  ApiException _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      return ApiException(
        message: data['error']?['message'] ?? data['message'] ?? 'Unknown error',
        details: data['details'],
        statusCode: e.response!.statusCode,
      );
    }
    return ApiException(
      message: 'Network error: ${e.message}',
      statusCode: null,
    );
  }
}
```

### 1.2. Crear Modelos Base

**Archivo**: `lib/models/mcp_ticker.dart`

```dart
/// Ticker de mercado desde MCP Tools
class MCPTicker {
  final String exchange;
  final String pair;
  final double last;
  final double bid;
  final double ask;
  final double volume;
  final double high24h;
  final double low24h;
  final double change24h;

  MCPTicker({
    required this.exchange,
    required this.pair,
    required this.last,
    required this.bid,
    required this.ask,
    required this.volume,
    required this.high24h,
    required this.low24h,
    required this.change24h,
  });

  factory MCPTicker.fromJson(Map<String, dynamic> json) {
    return MCPTicker(
      exchange: json['exchange'] as String,
      pair: json['pair'] as String,
      last: (json['last'] as num).toDouble(),
      bid: (json['bid'] as num).toDouble(),
      ask: (json['ask'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
      high24h: (json['high_24h'] as num).toDouble(),
      low24h: (json['low_24h'] as num).toDouble(),
      change24h: (json['change_24h'] as num).toDouble(),
    );
  }
}
```

### 1.3. Agregar MCPService al Provider

**Archivo**: `lib/providers/services_provider.dart`

```dart
// Agregar al final del archivo

/// MCP Service provider
@riverpod
MCPService mcpService(McpServiceRef ref) {
  final dio = ref.watch(dioProvider);
  return MCPService(dio);
}
```

### 1.4. Testing

**Archivo**: `test/services/mcp_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:kuri_crypto/services/mcp_service.dart';

void main() {
  group('MCPService', () {
    late MCPService service;

    setUp(() {
      service = MCPService(Dio());
    });

    test('callTool formats JSON-RPC correctly', () async {
      // Test con mock
    });
  });
}
```

---

## 🟡 **FASE 2: Market Data Tools** (Prioridad ALTA)
**Duración estimada**: 2-3 horas
**Objetivo**: Implementar herramientas de datos de mercado

### 2.1. Crear MarketDataService

**Archivo**: `lib/services/market_data_service.dart`

```dart
import 'mcp_service.dart';
import '../models/mcp_ticker.dart';
import '../models/mcp_candle.dart';
import '../models/mcp_orderbook.dart';

/// Servicio para datos de mercado via MCP Tools
class MarketDataService {
  final MCPService _mcpService;

  MarketDataService(this._mcpService);

  // ============================================================================
  // Ticker & Prices
  // ============================================================================

  /// Obtiene el ticker actual de un par
  Future<MCPTicker> getTicker({
    required String exchange,
    required String pair,
  }) async {
    final result = await _mcpService.callTool(
      toolName: 'get_ticker',
      arguments: {
        'exchange': exchange,
        'pair': pair,
      },
    );
    return MCPTicker.fromJson(result);
  }

  /// Obtiene múltiples tickers a la vez
  Future<List<MCPTicker>> getMultipleTickers({
    required String exchange,
    required List<String> pairs,
  }) async {
    final futures = pairs.map((pair) => getTicker(
      exchange: exchange,
      pair: pair,
    ));
    return Future.wait(futures);
  }

  // ============================================================================
  // Candles (OHLCV)
  // ============================================================================

  /// Obtiene velas/candles históricos
  ///
  /// [interval]: "1m", "5m", "15m", "1h", "4h", "1d"
  Future<List<MCPCandle>> getCandles({
    required String exchange,
    required String pair,
    required String interval,
    int limit = 100,
  }) async {
    final result = await _mcpService.callTool(
      toolName: 'get_candles',
      arguments: {
        'exchange': exchange,
        'pair': pair,
        'interval': interval,
        'limit': limit,
      },
    );

    final candles = (result['candles'] as List)
        .map((c) => MCPCandle.fromJson(c as Map<String, dynamic>))
        .toList();

    return candles;
  }

  // ============================================================================
  // Order Book
  // ============================================================================

  /// Obtiene el libro de órdenes (orderbook)
  Future<MCPOrderBook> getOrderBook({
    required String exchange,
    required String pair,
    int depth = 20,
  }) async {
    final result = await _mcpService.callTool(
      toolName: 'get_orderbook',
      arguments: {
        'exchange': exchange,
        'pair': pair,
        'depth': depth,
      },
    );
    return MCPOrderBook.fromJson(result);
  }

  // ============================================================================
  // 24h Statistics
  // ============================================================================

  /// Obtiene estadísticas de 24 horas
  Future<Map<String, dynamic>> get24hStats({
    required String exchange,
    required String pair,
  }) async {
    return _mcpService.callTool(
      toolName: 'get_24h_stats',
      arguments: {
        'exchange': exchange,
        'pair': pair,
      },
    );
  }
}
```

### 2.2. Crear Modelos Faltantes

```dart
// lib/models/mcp_candle.dart
class MCPCandle {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  MCPCandle({...});
  factory MCPCandle.fromJson(Map<String, dynamic> json) {...}
}

// lib/models/mcp_orderbook.dart
class MCPOrderBook {
  final List<OrderBookEntry> bids;
  final List<OrderBookEntry> asks;
  final DateTime timestamp;

  MCPOrderBook({...});
  factory MCPOrderBook.fromJson(Map<String, dynamic> json) {...}
}

class OrderBookEntry {
  final double price;
  final double amount;

  OrderBookEntry({...});
  factory OrderBookEntry.fromJson(List<dynamic> json) {...}
}
```

---

## 🟡 **FASE 3: Technical Indicators** (Prioridad MEDIA)
**Duración estimada**: 3-4 horas
**Objetivo**: Implementar indicadores técnicos

### 3.1. Crear TechnicalIndicatorsService

**Archivo**: `lib/services/technical_indicators_service.dart`

```dart
import 'mcp_service.dart';

/// Servicio para indicadores técnicos via MCP Tools
///
/// Indicadores disponibles: RSI, MACD, Bollinger Bands, EMA, SMA,
/// Stochastic, ATR, ADX, y más (18 indicadores totales)
class TechnicalIndicatorsService {
  final MCPService _mcpService;

  TechnicalIndicatorsService(this._mcpService);

  // ============================================================================
  // RSI (Relative Strength Index)
  // ============================================================================

  /// Calcula el RSI
  Future<double> calculateRSI({
    required String exchange,
    required String pair,
    String interval = '5m',
    int period = 14,
  }) async {
    final result = await _mcpService.callTool(
      toolName: 'calculate_rsi',
      arguments: {
        'exchange': exchange,
        'pair': pair,
        'interval': interval,
        'period': period,
      },
    );
    return (result['rsi'] as num).toDouble();
  }

  // ============================================================================
  // MACD (Moving Average Convergence Divergence)
  // ============================================================================

  /// Calcula el MACD
  Future<MACDResult> calculateMACD({
    required String exchange,
    required String pair,
    String interval = '5m',
    int fastPeriod = 12,
    int slowPeriod = 26,
    int signalPeriod = 9,
  }) async {
    final result = await _mcpService.callTool(
      toolName: 'calculate_macd',
      arguments: {
        'exchange': exchange,
        'pair': pair,
        'interval': interval,
        'fast_period': fastPeriod,
        'slow_period': slowPeriod,
        'signal_period': signalPeriod,
      },
    );
    return MACDResult.fromJson(result);
  }

  // ============================================================================
  // Bollinger Bands
  // ============================================================================

  /// Calcula Bollinger Bands
  Future<BollingerBandsResult> calculateBollingerBands({
    required String exchange,
    required String pair,
    String interval = '5m',
    int period = 20,
    double stdDev = 2.0,
  }) async {
    final result = await _mcpService.callTool(
      toolName: 'calculate_bollinger_bands',
      arguments: {
        'exchange': exchange,
        'pair': pair,
        'interval': interval,
        'period': period,
        'std_dev': stdDev,
      },
    );
    return BollingerBandsResult.fromJson(result);
  }

  // ============================================================================
  // EMA (Exponential Moving Average)
  // ============================================================================

  /// Calcula EMA
  Future<double> calculateEMA({
    required String exchange,
    required String pair,
    String interval = '5m',
    int period = 12,
  }) async {
    final result = await _mcpService.callTool(
      toolName: 'calculate_ema',
      arguments: {
        'exchange': exchange,
        'pair': pair,
        'interval': interval,
        'period': period,
      },
    );
    return (result['ema'] as num).toDouble();
  }

  // ============================================================================
  // Stochastic
  // ============================================================================

  /// Calcula Stochastic Oscillator
  Future<StochasticResult> calculateStochastic({
    required String exchange,
    required String pair,
    String interval = '5m',
    int kPeriod = 14,
    int dPeriod = 3,
  }) async {
    final result = await _mcpService.callTool(
      toolName: 'calculate_stochastic',
      arguments: {
        'exchange': exchange,
        'pair': pair,
        'interval': interval,
        'k_period': kPeriod,
        'd_period': dPeriod,
      },
    );
    return StochasticResult.fromJson(result);
  }

  // TODO: Agregar más indicadores según necesidad:
  // - SMA (Simple Moving Average)
  // - ATR (Average True Range)
  // - ADX (Average Directional Index)
  // - CCI (Commodity Channel Index)
  // - Williams %R
  // - OBV (On-Balance Volume)
  // - etc.
}

// ============================================================================
// Modelos de Resultados
// ============================================================================

class MACDResult {
  final double macd;
  final double signal;
  final double histogram;

  MACDResult({
    required this.macd,
    required this.signal,
    required this.histogram,
  });

  factory MACDResult.fromJson(Map<String, dynamic> json) {
    return MACDResult(
      macd: (json['macd'] as num).toDouble(),
      signal: (json['signal'] as num).toDouble(),
      histogram: (json['histogram'] as num).toDouble(),
    );
  }
}

class BollingerBandsResult {
  final double upper;
  final double middle;
  final double lower;

  BollingerBandsResult({
    required this.upper,
    required this.middle,
    required this.lower,
  });

  factory BollingerBandsResult.fromJson(Map<String, dynamic> json) {
    return BollingerBandsResult(
      upper: (json['upper'] as num).toDouble(),
      middle: (json['middle'] as num).toDouble(),
      lower: (json['lower'] as num).toDouble(),
    );
  }
}

class StochasticResult {
  final double k;
  final double d;

  StochasticResult({
    required this.k,
    required this.d,
  });

  factory StochasticResult.fromJson(Map<String, dynamic> json) {
    return StochasticResult(
      k: (json['k'] as num).toDouble(),
      d: (json['d'] as num).toDouble(),
    );
  }
}
```

---

## 🟢 **FASE 4: Account & Portfolio** (Prioridad MEDIA)
**Duración estimada**: 2 horas
**Objetivo**: Información de cuenta y portfolio

### 4.1. Crear AccountService

**Archivo**: `lib/services/account_service.dart`

```dart
import 'mcp_service.dart';
import '../models/account_info.dart';
import '../models/balance.dart';

/// Servicio para información de cuenta y portfolio
class AccountService {
  final MCPService _mcpService;

  AccountService(this._mcpService);

  /// Obtiene información completa de la cuenta
  Future<AccountInfo> getAccountInfo({
    required String exchange,
  }) async {
    final result = await _mcpService.callTool(
      toolName: 'account_info',
      arguments: {
        'exchange': exchange,
      },
    );
    return AccountInfo.fromJson(result);
  }

  /// Obtiene balances de la cuenta
  Future<List<Balance>> getBalances({
    required String exchange,
  }) async {
    final result = await _mcpService.callTool(
      toolName: 'get_account_balances',
      arguments: {
        'exchange': exchange,
      },
    );

    final balances = (result['balances'] as List)
        .map((b) => Balance.fromJson(b as Map<String, dynamic>))
        .toList();

    return balances;
  }

  /// Obtiene balance de un asset específico
  Future<Balance?> getAssetBalance({
    required String exchange,
    required String asset,
  }) async {
    final balances = await getBalances(exchange: exchange);
    return balances.where((b) => b.asset == asset).firstOrNull;
  }

  /// Obtiene el valor total del portfolio en USDT
  Future<double> getPortfolioValueUSDT({
    required String exchange,
  }) async {
    final result = await _mcpService.callTool(
      toolName: 'get_portfolio_value',
      arguments: {
        'exchange': exchange,
      },
    );
    return (result['total_value_usdt'] as num).toDouble();
  }
}
```

### 4.2. Crear Modelos

```dart
// lib/models/account_info.dart
class AccountInfo {
  final String exchange;
  final String accountId;
  final double totalBalanceUSDT;
  final double availableBalanceUSDT;
  final double marginLevel;
  final List<Balance> balances;

  AccountInfo({...});
  factory AccountInfo.fromJson(Map<String, dynamic> json) {...}
}

// lib/models/balance.dart
class Balance {
  final String asset;
  final double available;
  final double locked;
  final double total;

  Balance({...});
  factory Balance.fromJson(Map<String, dynamic> json) {...}
}
```

---

## 🟢 **FASE 5: Comprehensive Analysis** (Prioridad MEDIA)
**Duración estimada**: 2-3 horas
**Objetivo**: Implementar análisis comprehensivo con AI

### 5.1. Actualizar AiBotService

**Archivo**: `lib/services/ai_bot_service.dart` (agregar método)

```dart
  /// Obtiene análisis comprehensivo del mercado con AI
  ///
  /// Incluye:
  /// - Indicadores técnicos multi-timeframe
  /// - Análisis de riesgo
  /// - Escenarios probables
  /// - Recomendaciones de trading
  Future<ComprehensiveAnalysis> getComprehensiveAnalysis({
    required String symbol,
    String exchange = 'kucoin',
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.comprehensiveAnalysisUrl,
        data: {
          'symbol': symbol,
          'exchange': exchange,
        },
      );
      return ComprehensiveAnalysis.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
```

### 5.2. Crear Modelo ComprehensiveAnalysis

**Archivo**: `lib/models/comprehensive_analysis.dart`

```dart
/// Análisis comprehensivo del mercado
class ComprehensiveAnalysis {
  final String symbol;
  final String timeframe;
  final DateTime timestamp;
  final TechnicalIndicators indicators;
  final RiskAssessment risk;
  final List<Scenario> scenarios;
  final TradingRecommendation recommendation;

  ComprehensiveAnalysis({
    required this.symbol,
    required this.timeframe,
    required this.timestamp,
    required this.indicators,
    required this.risk,
    required this.scenarios,
    required this.recommendation,
  });

  factory ComprehensiveAnalysis.fromJson(Map<String, dynamic> json) {
    return ComprehensiveAnalysis(
      symbol: json['symbol'] as String,
      timeframe: json['timeframe'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      indicators: TechnicalIndicators.fromJson(json['technical_indicators'] as Map<String, dynamic>),
      risk: RiskAssessment.fromJson(json['risk_assessment'] as Map<String, dynamic>),
      scenarios: (json['scenarios'] as List)
          .map((s) => Scenario.fromJson(s as Map<String, dynamic>))
          .toList(),
      recommendation: TradingRecommendation.fromJson(json['recommendation'] as Map<String, dynamic>),
    );
  }
}

class TechnicalIndicators {
  final double rsi;
  final MACDResult macd;
  final BollingerBandsResult bollingerBands;
  final double ema20;
  final double sma50;
  // ... más indicadores

  TechnicalIndicators({...});
  factory TechnicalIndicators.fromJson(Map<String, dynamic> json) {...}
}

class RiskAssessment {
  final String level; // "low", "medium", "high", "critical"
  final double score; // 0-100
  final List<String> factors;

  RiskAssessment({...});
  factory RiskAssessment.fromJson(Map<String, dynamic> json) {...}
}

class Scenario {
  final String name;
  final double probability;
  final String description;
  final double targetPrice;
  final double timeHorizon;

  Scenario({...});
  factory Scenario.fromJson(Map<String, dynamic> json) {...}
}

class TradingRecommendation {
  final String action; // "BUY", "SELL", "HOLD", "WAIT"
  final double confidence; // 0-1
  final double? entryPrice;
  final double? stopLoss;
  final double? takeProfit;
  final String reasoning;

  TradingRecommendation({...});
  factory TradingRecommendation.fromJson(Map<String, dynamic> json) {...}
}
```

---

## 🔵 **FASE 6: Testing & Quality** (Prioridad ALTA)
**Duración estimada**: 2-3 horas
**Objetivo**: Asegurar calidad del código

### 6.1. Tests Unitarios

```dart
// test/services/mcp_service_test.dart
// test/services/market_data_service_test.dart
// test/services/technical_indicators_service_test.dart
// test/services/account_service_test.dart
```

### 6.2. Tests de Integración

```dart
// test/integration/backend_integration_test.dart
void main() {
  group('Backend Integration Tests', () {
    test('Can fetch ticker from real backend', () async {
      // Test con backend real
    });

    test('Can calculate RSI from real backend', () async {
      // Test con backend real
    });
  });
}
```

### 6.3. Widget Tests

```dart
// test/widgets/comprehensive_analysis_widget_test.dart
```

---

## 🔵 **FASE 7: Documentación** (Prioridad MEDIA)
**Duración estimada**: 1-2 horas
**Objetivo**: Documentar todo el código nuevo

### 7.1. Actualizar CLAUDE.md

Agregar secciones:
- Nuevos servicios MCP
- Uso de MCPService genérico
- Ejemplos de código

### 7.2. Crear Guías de Uso

```markdown
# MCP_INTEGRATION_GUIDE.md
- Cómo usar MCPService
- Ejemplos de cada herramienta
- Best practices
```

### 7.3. Generar Documentación API

```bash
flutter pub run dartdoc
```

---

## 📊 Cronograma Estimado

| Fase | Duración | Prioridad | Dependencias |
|------|----------|-----------|--------------|
| Fase 1: Infraestructura | 2-3h | ALTA | Ninguna |
| Fase 2: Market Data | 2-3h | ALTA | Fase 1 |
| Fase 3: Indicators | 3-4h | MEDIA | Fase 1 |
| Fase 4: Account | 2h | MEDIA | Fase 1 |
| Fase 5: Comprehensive | 2-3h | MEDIA | Fase 1 |
| Fase 6: Testing | 2-3h | ALTA | Fases 1-5 |
| Fase 7: Docs | 1-2h | MEDIA | Fases 1-6 |
| **TOTAL** | **14-20h** | - | - |

---

## ✅ Checklist de Implementación

### Fase 1: Infraestructura
- [ ] Crear `lib/services/mcp_service.dart`
- [ ] Crear modelos base (MCPTicker, etc.)
- [ ] Agregar provider en services_provider.dart
- [ ] Crear tests básicos
- [ ] Verificar que funciona con herramienta simple (get_ticker)

### Fase 2: Market Data
- [ ] Crear `lib/services/market_data_service.dart`
- [ ] Implementar getTicker()
- [ ] Implementar getCandles()
- [ ] Implementar getOrderBook()
- [ ] Implementar get24hStats()
- [ ] Crear modelos (MCPCandle, MCPOrderBook)
- [ ] Tests unitarios

### Fase 3: Technical Indicators
- [ ] Crear `lib/services/technical_indicators_service.dart`
- [ ] Implementar calculateRSI()
- [ ] Implementar calculateMACD()
- [ ] Implementar calculateBollingerBands()
- [ ] Implementar calculateEMA()
- [ ] Implementar calculateStochastic()
- [ ] Crear modelos de resultados
- [ ] Tests unitarios

### Fase 4: Account
- [ ] Crear `lib/services/account_service.dart`
- [ ] Implementar getAccountInfo()
- [ ] Implementar getBalances()
- [ ] Crear modelos (AccountInfo, Balance)
- [ ] Tests unitarios

### Fase 5: Comprehensive Analysis
- [ ] Actualizar AiBotService
- [ ] Crear ComprehensiveAnalysis model
- [ ] Crear sub-modelos necesarios
- [ ] Tests unitarios

### Fase 6: Testing
- [ ] Tests unitarios para todos los servicios
- [ ] Tests de integración con backend
- [ ] Tests de widgets si aplica
- [ ] Verificar coverage > 80%

### Fase 7: Documentación
- [ ] Actualizar CLAUDE.md
- [ ] Crear MCP_INTEGRATION_GUIDE.md
- [ ] Documentar cada método público
- [ ] Generar dartdoc

---

## 🎯 Métricas de Éxito

### Cobertura de Endpoints
- **Objetivo**: 60%+ de herramientas MCP implementadas
- **Actual**: ~15% (10/67)
- **Meta**: ~60% (40/67)

### Calidad del Código
- **Test Coverage**: > 80%
- **Flutter Analyze**: 0 errores
- **Documentación**: 100% métodos públicos documentados

### Performance
- **Tiempo de respuesta**: < 200ms promedio
- **Manejo de errores**: 100% casos cubiertos
- **Logging**: Completo en desarrollo

---

## 🔧 Herramientas MCP por Implementar

### Prioridad ALTA
- [x] get_ticker ✅ (Fase 2)
- [x] get_candles ✅ (Fase 2)
- [x] calculate_rsi ✅ (Fase 3)
- [x] calculate_macd ✅ (Fase 3)
- [ ] account_info (Fase 4)
- [ ] get_account_balances (Fase 4)

### Prioridad MEDIA
- [ ] get_orderbook (Fase 2)
- [ ] get_24h_stats (Fase 2)
- [ ] calculate_bollinger_bands (Fase 3)
- [ ] calculate_ema (Fase 3)
- [ ] calculate_stochastic (Fase 3)
- [ ] get_portfolio_value (Fase 4)

### Prioridad BAJA (Implementar según necesidad)
- [ ] calculate_sma
- [ ] calculate_atr
- [ ] calculate_adx
- [ ] calculate_cci
- [ ] calculate_williams_r
- [ ] calculate_obv
- [ ] place_market_order
- [ ] place_limit_order
- [ ] cancel_order
- [ ] get_order_status
- [ ] ... (30+ herramientas más)

---

## 📝 Notas de Implementación

### Buenas Prácticas

1. **Siempre usar MCPService para JSON-RPC**
   - No duplicar lógica de llamadas
   - Centralizar manejo de errores
   - Usar request ID incremental

2. **Validar argumentos antes de llamar**
   - Verificar tipos de datos
   - Verificar rangos válidos
   - Lanzar excepciones descriptivas

3. **Usar modelos tipados**
   - Evitar Map<String, dynamic> en APIs públicas
   - Crear modelos específicos para cada resultado
   - Usar fromJson consistentemente

4. **Logging apropiado**
   - Log de entrada/salida en desarrollo
   - No loggear datos sensibles
   - Usar niveles apropiados (debug, info, error)

5. **Manejo de errores robusto**
   - Catch DioException específicamente
   - Convertir a ApiException con contexto
   - Propagar errores con información útil

### Compatibilidad

- ✅ **Mantener código existente**: No romper AI Bot, Scalping, Futures services
- ✅ **Backward compatible**: Servicios actuales siguen funcionando
- ✅ **Incremental**: Se puede implementar por fases
- ✅ **Testing**: Tests existentes deben seguir pasando

---

## 🚀 Cómo Empezar

### Opción 1: Implementación Completa (Recomendado)

```bash
# Seguir las fases en orden
1. Implementar Fase 1 (Infraestructura)
2. Verificar que funciona con tests
3. Implementar Fase 2 (Market Data)
4. Continuar con fases siguientes
```

### Opción 2: Implementación Incremental

```bash
# Implementar solo lo que necesites ahora
1. Crear MCPService base (Fase 1)
2. Implementar 1-2 herramientas específicas que necesites
3. Agregar más herramientas cuando las necesites
```

### Opción 3: Mínimo Viable

```bash
# Solo infraestructura + market data crítico
1. MCPService base
2. getTicker()
3. calculateRSI()
```

---

## 📞 Soporte

Para dudas o problemas:
1. Revisar documentación del backend: `/home/wsi/developer/project/rantipay/services/trading-mcp/docs/`
2. Revisar CLAUDE.md del proyecto
3. Consultar código de referencia en FuturesService (ya usa JSON-RPC)

---

## 📅 Versión del Documento

- **Versión**: 1.0
- **Fecha**: 20 Noviembre 2025
- **Autor**: Claude Code
- **Estado**: Planificación
- **Próxima revisión**: Después de Fase 1

---

## 🎉 Conclusión

Este plan permite integrar las **67 herramientas MCP** del backend de manera estructurada y mantenible. La arquitectura propuesta con `MCPService` genérico facilita:

- ✅ Agregar nuevas herramientas fácilmente
- ✅ Mantener código limpio y DRY
- ✅ Testing consistente
- ✅ Evolución futura del sistema

**Siguiente paso**: Comenzar con Fase 1 (Infraestructura Base)
