# 📱 Guía Completa de Market Types para Flutter Team

**Fecha**: 2025-11-27  
**Versión Backend**: v3.2  
**Estado**: ✅ Producción  

---

## 📋 Índice

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Cambios Principales](#cambios-principales)
3. [Endpoints Actualizados](#endpoints-actualizados)
4. [Nuevos Endpoints](#nuevos-endpoints)
5. [Ejemplos de Integración](#ejemplos-de-integración)
6. [Modelos de Datos](#modelos-de-datos)
7. [Manejo de Errores](#manejo-de-errores)
8. [Testing](#testing)
9. [Migración](#migración)
10. [FAQ](#faq)

---

## 🎯 Resumen Ejecutivo

El backend ahora soporta **4 tipos de mercado**:
- **spot**: Trading sin apalancamiento
- **futures**: Contratos con apalancamiento
- **margin**: Trading con fondos prestados
- **options**: Contratos de opciones

### ✅ Backwards Compatibility
Todos los endpoints funcionan **sin cambios** si no envías `market_type`. El sistema asume `futures` por defecto.

### 🚀 Beneficios
- Respuestas adaptadas por tipo de mercado
- Validaciones específicas (leverage, funding rate, etc)
- Conversión automática de símbolos (BTC-USDT ↔ BTCUSDTM)
- Mejor UX para usuarios que operan en diferentes mercados

---

## 🔄 Cambios Principales

### 1. Parámetro `market_type` (Opcional)
Todos los endpoints de trading ahora aceptan un parámetro opcional `market_type`:

```dart
// Antes (sigue funcionando)
{
  "symbol": "BTC-USDT",
  "exchange": "kucoin"
}

// Ahora (recomendado)
{
  "symbol": "BTC-USDT",
  "exchange": "kucoin",
  "market_type": "futures"  // spot, futures, margin, options
}
```

### 2. Respuestas Adaptadas
Las respuestas incluyen datos específicos según el tipo:

**Futures**: `funding_rate`, `mark_price`, `liquidation_price`  
**Margin**: `interest_rate`, `margin_level`, `borrowed_amount`  
**Spot**: Sin datos de leverage  
**Options**: `implied_volatility`, `greeks`

### 3. Validaciones Automáticas
- **Spot**: Rechaza leverage > 1
- **Futures**: Valida leverage 1-100
- **Margin**: Valida margin_level
- **Funding Rate**: Solo disponible para futures

---

## 📡 Endpoints Actualizados

### 1. Comprehensive Analysis (NUEVO)

**Endpoint**: `POST /api/v1/ai-bot/comprehensive-analysis`  
**Auth**: Required (Level 2)  
**Test**: `POST /tools/comprehensive-analysis` (sin auth)

#### Request
```json
{
  "symbol": "BTC-USDT",
  "exchange": "kucoin",
  "market_type": "futures"  // opcional: spot, futures, margin, options
}
```

#### Response (Futures)
```json
{
  "symbol": "BTC-USDT",
  "exchange": "kucoin",
  "market_type": "futures",
  "timestamp": "2025-11-27T21:30:00Z",
  "current_price": {
    "current": 96500.50,
    "change_24h": 2.5,
    "high_24h": 97100.00,
    "low_24h": 94500.00,
    "volume_24h": 1234567890.50
  },
  "technical_analysis": {
    "rsi": {
      "value": 65.7,
      "interpretation": "Zona neutral",
      "signal": "neutral"
    },
    "macd": {
      "value": 0.00023,
      "signal": 0.00023,
      "histogram": 0,
      "trend": "neutral"
    },
    "trend": "neutral",
    "strength": 0.5
  },
  "futures_data": {
    "funding_rate": 0.0001,
    "next_funding_time": "2025-11-28T05:30:00Z",
    "mark_price": 96500.50,
    "index_price": 96498.20,
    "open_interest": 12345678.90,
    "liquidation_price": 85000.00
  },
  "key_levels": {
    "support": 94500.00,
    "resistance": 97100.00,
    "distance": {
      "to_support_percent": 2.1,
      "to_resistance_percent": 0.6
    }
  },
  "recommendation": {
    "action": "WAIT",
    "confidence": 0.5,
    "reasoning": [
      "RSI en zona neutral",
      "MACD sin dirección clara",
      "Funding rate neutral - no presión de mercado",
      "Señales mixtas - mejor esperar confirmación"
    ]
  },
  "scenarios": [
    {
      "name": "Rebote Alcista",
      "probability": 0.40,
      "target_price": 98500.00,
      "change_percent": 2.0,
      "timeframe": "1-2 horas",
      "impact": "positive"
    }
  ],
  "risk_assessment": {
    "level": "medium",
    "score": 55.0,
    "factors": ["Volatilidad moderada", "Temporalidades no alineadas"],
    "volatility": "medium"
  }
}
```

#### Response (Spot)
```json
{
  "symbol": "BTC-USDT",
  "market_type": "spot",
  // ... same structure but WITHOUT futures_data
  "recommendation": {
    "action": "WAIT",
    "confidence": 0.5,
    "reasoning": [
      "RSI en zona neutral",
      "MACD sin dirección clara",
      "Señales mixtas - mejor esperar confirmación"
    ]
  }
}
```

#### Response (Margin)
```json
{
  "symbol": "BTC-USDT",
  "market_type": "margin",
  // ... same structure
  "margin_data": {
    "interest_rate": 0.0002,
    "margin_level": 2.5,
    "borrowed_amount": 10000.00,
    "available_margin": 25000.00
  },
  "recommendation": {
    "reasoning": [
      "RSI en zona neutral",
      "MACD sin dirección clara",
      "Nivel de margen saludable (2.5x)",
      "Señales mixtas"
    ]
  }
}
```



### 2. Get Markets (Enhanced)

**Endpoint**: `POST /tools/call`  
**Tool Name**: `get_markets`

#### Request
```json
{
  "name": "get_markets",
  "arguments": {
    "exchange": "kucoin",
    "market_type": "futures"  // opcional: spot, futures, margin, options
  }
}
```

#### Response
```json
{
  "exchange": "kucoin",
  "market_type": "futures",
  "total_count": 22,
  "pairs": [
    {
      "symbol": "BTCUSDTM",
      "base_currency": "BTC",
      "quote_currency": "USDT",
      "min_order_size": 0.001,
      "max_order_size": 1000.0,
      "price_precision": 2,
      "amount_precision": 3,
      "is_active": true,
      "leverage_available": true,
      "max_leverage": 100
    },
    // ... más pares
  ]
}
```

---

## 🆕 Nuevos Endpoints

### 1. Get Market Types

**Endpoint**: `POST /tools/call`  
**Tool Name**: `get_market_types`

#### Request
```json
{
  "name": "get_market_types",
  "arguments": {}
}
```

#### Response
```json
{
  "types": ["spot", "futures", "margin", "options"],
  "default": "futures"
}
```

### 2. Get Ticker (con market_type)

**Endpoint**: `POST /tools/call`  
**Tool Name**: `get_ticker`

#### Request
```json
{
  "name": "get_ticker",
  "arguments": {
    "exchange": "kucoin",
    "pair": "BTC-USDT",
    "market_type": "futures"  // opcional
  }
}
```

#### Response
```json
{
  "symbol": "BTCUSDTM",  // convertido automáticamente
  "last": 96500.50,
  "bid": 96500.00,
  "ask": 96501.00,
  "high": 97100.00,
  "low": 94500.00,
  "volume": 1234567890.50,
  "timestamp": "2025-11-27T21:30:00Z"
}
```

### 3. Submit Order (con validación)

**Endpoint**: `POST /tools/call`  
**Tool Name**: `submit_order`

#### Request (Futures - OK)
```json
{
  "name": "submit_order",
  "arguments": {
    "exchange": "kucoin",
    "pair": "BTC-USDT",
    "market_type": "futures",
    "side": "buy",
    "amount": 0.1,
    "price": 96500.00,
    "leverage": 10  // OK para futures
  }
}
```

#### Request (Spot - ERROR)
```json
{
  "name": "submit_order",
  "arguments": {
    "exchange": "kucoin",
    "pair": "BTC-USDT",
    "market_type": "spot",
    "side": "buy",
    "amount": 0.1,
    "price": 96500.00,
    "leverage": 10  // ❌ ERROR: Leverage not allowed for spot
  }
}
```

#### Error Response
```json
{
  "error": "Invalid leverage",
  "code": "INVALID_LEVERAGE",
  "details": "Leverage not allowed for spot trading"
}
```

### 4. Get Positions (con filtro)

**Endpoint**: `POST /tools/call`  
**Tool Name**: `get_positions`

#### Request
```json
{
  "name": "get_positions",
  "arguments": {
    "exchange": "kucoin",
    "market_type": "futures"  // opcional: filtra por tipo
  }
}
```

#### Response
```json
{
  "positions": [
    {
      "symbol": "BTC-USDT",
      "market_type": "futures",
      "side": "long",
      "size": 0.5,
      "entry_price": 95000.00,
      "current_price": 96500.00,
      "unrealized_pnl": 750.00,
      "pnl_percent": 1.58,
      "leverage": 10,
      "liquidation_price": 85500.00,
      "funding_rate": 0.0001
    }
  ],
  "total_count": 1,
  "total_pnl": 750.00
}
```

---

## 💻 Ejemplos de Integración

### Dart/Flutter Models

```dart
// Market Type Enum
enum MarketType {
  spot,
  futures,
  margin,
  options;
  
  String toJson() => name;
  
  static MarketType fromJson(String json) {
    return MarketType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => MarketType.futures,
    );
  }
}

// Comprehensive Analysis Request
class ComprehensiveAnalysisRequest {
  final String symbol;
  final String exchange;
  final MarketType? marketType;
  
  ComprehensiveAnalysisRequest({
    required this.symbol,
    this.exchange = 'kucoin',
    this.marketType,
  });
  
  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'exchange': exchange,
    if (marketType != null) 'market_type': marketType!.toJson(),
  };
}

// Comprehensive Analysis Response
class ComprehensiveAnalysisResponse {
  final String symbol;
  final String exchange;
  final MarketType marketType;
  final DateTime timestamp;
  final CurrentPrice currentPrice;
  final TechnicalAnalysis technicalAnalysis;
  final FuturesData? futuresData;  // nullable
  final MarginData? marginData;    // nullable
  final OptionsData? optionsData;  // nullable
  final KeyLevels keyLevels;
  final Recommendation recommendation;
  final List<Scenario> scenarios;
  final RiskAssessment riskAssessment;
  
  ComprehensiveAnalysisResponse({
    required this.symbol,
    required this.exchange,
    required this.marketType,
    required this.timestamp,
    required this.currentPrice,
    required this.technicalAnalysis,
    this.futuresData,
    this.marginData,
    this.optionsData,
    required this.keyLevels,
    required this.recommendation,
    required this.scenarios,
    required this.riskAssessment,
  });
  
  factory ComprehensiveAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return ComprehensiveAnalysisResponse(
      symbol: json['symbol'],
      exchange: json['exchange'],
      marketType: MarketType.fromJson(json['market_type']),
      timestamp: DateTime.parse(json['timestamp']),
      currentPrice: CurrentPrice.fromJson(json['current_price']),
      technicalAnalysis: TechnicalAnalysis.fromJson(json['technical_analysis']),
      futuresData: json['futures_data'] != null 
          ? FuturesData.fromJson(json['futures_data']) 
          : null,
      marginData: json['margin_data'] != null 
          ? MarginData.fromJson(json['margin_data']) 
          : null,
      optionsData: json['options_data'] != null 
          ? OptionsData.fromJson(json['options_data']) 
          : null,
      keyLevels: KeyLevels.fromJson(json['key_levels']),
      recommendation: Recommendation.fromJson(json['recommendation']),
      scenarios: (json['scenarios'] as List)
          .map((s) => Scenario.fromJson(s))
          .toList(),
      riskAssessment: RiskAssessment.fromJson(json['risk_assessment']),
    );
  }
}

// Futures Data Model
class FuturesData {
  final double fundingRate;
  final DateTime nextFundingTime;
  final double markPrice;
  final double indexPrice;
  final double openInterest;
  final double liquidationPrice;
  
  FuturesData({
    required this.fundingRate,
    required this.nextFundingTime,
    required this.markPrice,
    required this.indexPrice,
    required this.openInterest,
    required this.liquidationPrice,
  });
  
  factory FuturesData.fromJson(Map<String, dynamic> json) {
    return FuturesData(
      fundingRate: json['funding_rate'].toDouble(),
      nextFundingTime: DateTime.parse(json['next_funding_time']),
      markPrice: json['mark_price'].toDouble(),
      indexPrice: json['index_price'].toDouble(),
      openInterest: json['open_interest'].toDouble(),
      liquidationPrice: json['liquidation_price'].toDouble(),
    );
  }
}

// Margin Data Model
class MarginData {
  final double interestRate;
  final double marginLevel;
  final double borrowedAmount;
  final double availableMargin;
  
  MarginData({
    required this.interestRate,
    required this.marginLevel,
    required this.borrowedAmount,
    required this.availableMargin,
  });
  
  factory MarginData.fromJson(Map<String, dynamic> json) {
    return MarginData(
      interestRate: json['interest_rate'].toDouble(),
      marginLevel: json['margin_level'].toDouble(),
      borrowedAmount: json['borrowed_amount'].toDouble(),
      availableMargin: json['available_margin'].toDouble(),
    );
  }
}
```

### Service Example

```dart
class TradingApiService {
  final String baseUrl = 'http://192.168.1.6:10600';
  final Dio _dio;
  
  TradingApiService(this._dio);
  
  Future<ComprehensiveAnalysisResponse> getComprehensiveAnalysis({
    required String symbol,
    String exchange = 'kucoin',
    MarketType? marketType,
  }) async {
    try {
      final request = ComprehensiveAnalysisRequest(
        symbol: symbol,
        exchange: exchange,
        marketType: marketType,
      );
      
      final response = await _dio.post(
        '$baseUrl/tools/comprehensive-analysis',
        data: request.toJson(),
      );
      
      return ComprehensiveAnalysisResponse.fromJson(response.data);
    } catch (e) {
      throw TradingApiException('Failed to get comprehensive analysis: $e');
    }
  }
  
  Future<List<MarketPair>> getMarkets({
    required String exchange,
    MarketType? marketType,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/tools/call',
        data: {
          'name': 'get_markets',
          'arguments': {
            'exchange': exchange,
            if (marketType != null) 'market_type': marketType.toJson(),
          },
        },
      );
      
      final pairs = response.data['pairs'] as List;
      return pairs.map((p) => MarketPair.fromJson(p)).toList();
    } catch (e) {
      throw TradingApiException('Failed to get markets: $e');
    }
  }
  
  Future<OrderResponse> submitOrder({
    required String exchange,
    required String pair,
    required MarketType marketType,
    required String side,
    required double amount,
    required double price,
    int? leverage,
  }) async {
    try {
      // Validación local
      if (marketType == MarketType.spot && leverage != null && leverage > 1) {
        throw ValidationException('Leverage not allowed for spot trading');
      }
      
      final response = await _dio.post(
        '$baseUrl/tools/call',
        data: {
          'name': 'submit_order',
          'arguments': {
            'exchange': exchange,
            'pair': pair,
            'market_type': marketType.toJson(),
            'side': side,
            'amount': amount,
            'price': price,
            if (leverage != null) 'leverage': leverage,
          },
        },
      );
      
      return OrderResponse.fromJson(response.data);
    } catch (e) {
      throw TradingApiException('Failed to submit order: $e');
    }
  }
}
```



### UI Example

```dart
class MarketTypeSelector extends StatelessWidget {
  final MarketType selectedType;
  final ValueChanged<MarketType> onChanged;
  
  const MarketTypeSelector({
    required this.selectedType,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return SegmentedButton<MarketType>(
      segments: const [
        ButtonSegment(
          value: MarketType.spot,
          label: Text('Spot'),
          icon: Icon(Icons.currency_exchange),
        ),
        ButtonSegment(
          value: MarketType.futures,
          label: Text('Futures'),
          icon: Icon(Icons.trending_up),
        ),
        ButtonSegment(
          value: MarketType.margin,
          label: Text('Margin'),
          icon: Icon(Icons.account_balance),
        ),
        ButtonSegment(
          value: MarketType.options,
          label: Text('Options'),
          icon: Icon(Icons.settings_suggest),
        ),
      ],
      selected: {selectedType},
      onSelectionChanged: (Set<MarketType> newSelection) {
        onChanged(newSelection.first);
      },
    );
  }
}

class TradingScreen extends StatefulWidget {
  @override
  _TradingScreenState createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  MarketType _selectedMarketType = MarketType.futures;
  ComprehensiveAnalysisResponse? _analysis;
  bool _loading = false;
  
  Future<void> _loadAnalysis() async {
    setState(() => _loading = true);
    
    try {
      final analysis = await context.read<TradingApiService>()
          .getComprehensiveAnalysis(
        symbol: 'BTC-USDT',
        marketType: _selectedMarketType,
      );
      
      setState(() {
        _analysis = analysis;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trading')),
      body: Column(
        children: [
          // Market Type Selector
          Padding(
            padding: EdgeInsets.all(16),
            child: MarketTypeSelector(
              selectedType: _selectedMarketType,
              onChanged: (type) {
                setState(() => _selectedMarketType = type);
                _loadAnalysis();
              },
            ),
          ),
          
          // Analysis Display
          if (_loading)
            CircularProgressIndicator()
          else if (_analysis != null)
            Expanded(
              child: _buildAnalysisView(_analysis!),
            ),
        ],
      ),
    );
  }
  
  Widget _buildAnalysisView(ComprehensiveAnalysisResponse analysis) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Current Price
        _buildPriceCard(analysis.currentPrice),
        
        // Technical Analysis
        _buildTechnicalCard(analysis.technicalAnalysis),
        
        // Market Type Specific Data
        if (analysis.futuresData != null)
          _buildFuturesCard(analysis.futuresData!),
        if (analysis.marginData != null)
          _buildMarginCard(analysis.marginData!),
        if (analysis.optionsData != null)
          _buildOptionsCard(analysis.optionsData!),
        
        // Recommendation
        _buildRecommendationCard(analysis.recommendation),
        
        // Scenarios
        _buildScenariosCard(analysis.scenarios),
      ],
    );
  }
  
  Widget _buildFuturesCard(FuturesData data) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Futures Data', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            _buildDataRow('Funding Rate', '${(data.fundingRate * 100).toStringAsFixed(4)}%'),
            _buildDataRow('Mark Price', '\$${data.markPrice.toStringAsFixed(2)}'),
            _buildDataRow('Index Price', '\$${data.indexPrice.toStringAsFixed(2)}'),
            _buildDataRow('Open Interest', '\$${data.openInterest.toStringAsFixed(2)}'),
            _buildDataRow('Liquidation Price', '\$${data.liquidationPrice.toStringAsFixed(2)}'),
            _buildDataRow('Next Funding', _formatDateTime(data.nextFundingTime)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMarginCard(MarginData data) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Margin Data', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            _buildDataRow('Interest Rate', '${(data.interestRate * 100).toStringAsFixed(4)}%'),
            _buildDataRow('Margin Level', '${data.marginLevel.toStringAsFixed(2)}x'),
            _buildDataRow('Borrowed', '\$${data.borrowedAmount.toStringAsFixed(2)}'),
            _buildDataRow('Available', '\$${data.availableMargin.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
```

---

## 🔧 Modelos de Datos Completos

### Current Price
```dart
class CurrentPrice {
  final double current;
  final double change24h;
  final double high24h;
  final double low24h;
  final double volume24h;
  
  CurrentPrice({
    required this.current,
    required this.change24h,
    required this.high24h,
    required this.low24h,
    required this.volume24h,
  });
  
  factory CurrentPrice.fromJson(Map<String, dynamic> json) {
    return CurrentPrice(
      current: json['current'].toDouble(),
      change24h: json['change_24h'].toDouble(),
      high24h: json['high_24h'].toDouble(),
      low24h: json['low_24h'].toDouble(),
      volume24h: json['volume_24h'].toDouble(),
    );
  }
}
```

### Technical Analysis
```dart
class TechnicalAnalysis {
  final RSI rsi;
  final MACD macd;
  final String trend;
  final double strength;
  
  TechnicalAnalysis({
    required this.rsi,
    required this.macd,
    required this.trend,
    required this.strength,
  });
  
  factory TechnicalAnalysis.fromJson(Map<String, dynamic> json) {
    return TechnicalAnalysis(
      rsi: RSI.fromJson(json['rsi']),
      macd: MACD.fromJson(json['macd']),
      trend: json['trend'],
      strength: json['strength'].toDouble(),
    );
  }
}

class RSI {
  final double value;
  final String interpretation;
  final String signal;
  
  RSI({
    required this.value,
    required this.interpretation,
    required this.signal,
  });
  
  factory RSI.fromJson(Map<String, dynamic> json) {
    return RSI(
      value: json['value'].toDouble(),
      interpretation: json['interpretation'],
      signal: json['signal'],
    );
  }
}

class MACD {
  final double value;
  final double signal;
  final double histogram;
  final String trend;
  
  MACD({
    required this.value,
    required this.signal,
    required this.histogram,
    required this.trend,
  });
  
  factory MACD.fromJson(Map<String, dynamic> json) {
    return MACD(
      value: json['value'].toDouble(),
      signal: json['signal'].toDouble(),
      histogram: json['histogram'].toDouble(),
      trend: json['trend'],
    );
  }
}
```

### Recommendation
```dart
class Recommendation {
  final String action;  // WAIT, BUY, SELL
  final double confidence;  // 0.0 - 1.0
  final List<String> reasoning;
  
  Recommendation({
    required this.action,
    required this.confidence,
    required this.reasoning,
  });
  
  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      action: json['action'],
      confidence: json['confidence'].toDouble(),
      reasoning: List<String>.from(json['reasoning']),
    );
  }
  
  Color get actionColor {
    switch (action) {
      case 'BUY':
        return Colors.green;
      case 'SELL':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
  
  IconData get actionIcon {
    switch (action) {
      case 'BUY':
        return Icons.trending_up;
      case 'SELL':
        return Icons.trending_down;
      default:
        return Icons.pause;
    }
  }
}
```

### Scenario
```dart
class Scenario {
  final String name;
  final double probability;
  final double targetPrice;
  final double changePercent;
  final String timeframe;
  final String impact;  // positive, negative, neutral
  final String? description;
  
  Scenario({
    required this.name,
    required this.probability,
    required this.targetPrice,
    required this.changePercent,
    required this.timeframe,
    required this.impact,
    this.description,
  });
  
  factory Scenario.fromJson(Map<String, dynamic> json) {
    return Scenario(
      name: json['name'],
      probability: json['probability'].toDouble(),
      targetPrice: json['target_price'].toDouble(),
      changePercent: json['change_percent'].toDouble(),
      timeframe: json['timeframe'],
      impact: json['impact'],
      description: json['description'],
    );
  }
  
  Color get impactColor {
    switch (impact) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
```

---

## ⚠️ Manejo de Errores

### Error Codes

| Code | Description | Action |
|------|-------------|--------|
| `INVALID_MARKET_TYPE` | market_type inválido | Usar: spot, futures, margin, options |
| `INVALID_LEVERAGE` | Leverage no permitido para el tipo | Spot: sin leverage, Futures: 1-100 |
| `MARKET_TYPE_NOT_SUPPORTED` | Exchange no soporta el tipo | Verificar con get_market_types |
| `SYMBOL_CONVERSION_FAILED` | Error convirtiendo símbolo | Verificar formato del símbolo |
| `PAIR_NOT_AVAILABLE` | Par no disponible para el tipo | Usar get_markets para ver disponibles |

### Error Response Format

```json
{
  "error": "Invalid market_type",
  "code": "INVALID_MARKET_TYPE",
  "details": "market_type must be one of: spot, futures, margin, options"
}
```

### Error Handling Example

```dart
class TradingApiException implements Exception {
  final String message;
  final String? code;
  final String? details;
  
  TradingApiException(this.message, {this.code, this.details});
  
  factory TradingApiException.fromResponse(Map<String, dynamic> json) {
    return TradingApiException(
      json['error'] ?? 'Unknown error',
      code: json['code'],
      details: json['details'],
    );
  }
  
  @override
  String toString() {
    if (details != null) {
      return '$message: $details';
    }
    return message;
  }
}

// Usage
try {
  final analysis = await apiService.getComprehensiveAnalysis(
    symbol: 'BTC-USDT',
    marketType: MarketType.spot,
  );
} on DioException catch (e) {
  if (e.response?.data != null) {
    throw TradingApiException.fromResponse(e.response!.data);
  }
  throw TradingApiException('Network error: ${e.message}');
} catch (e) {
  throw TradingApiException('Unexpected error: $e');
}
```



---

## 🧪 Testing

### Test Endpoints (Sin Autenticación)

Para testing rápido, usar estos endpoints sin auth:

```bash
# Comprehensive Analysis
curl -X POST http://192.168.1.6:10600/tools/comprehensive-analysis \
  -H "Content-Type: application/json" \
  -d '{"symbol":"BTC-USDT","market_type":"futures"}'

# Get Markets
curl -X POST http://192.168.1.6:10600/tools/call \
  -H "Content-Type: application/json" \
  -d '{"name":"get_markets","arguments":{"exchange":"kucoin","market_type":"futures"}}'

# Get Market Types
curl -X POST http://192.168.1.6:10600/tools/call \
  -H "Content-Type: application/json" \
  -d '{"name":"get_market_types","arguments":{}}'
```

### Unit Tests Example

```dart
void main() {
  group('MarketType', () {
    test('toJson returns correct string', () {
      expect(MarketType.spot.toJson(), 'spot');
      expect(MarketType.futures.toJson(), 'futures');
      expect(MarketType.margin.toJson(), 'margin');
      expect(MarketType.options.toJson(), 'options');
    });
    
    test('fromJson parses correctly', () {
      expect(MarketType.fromJson('spot'), MarketType.spot);
      expect(MarketType.fromJson('futures'), MarketType.futures);
      expect(MarketType.fromJson('margin'), MarketType.margin);
      expect(MarketType.fromJson('options'), MarketType.options);
    });
    
    test('fromJson defaults to futures for invalid input', () {
      expect(MarketType.fromJson('invalid'), MarketType.futures);
    });
  });
  
  group('ComprehensiveAnalysisResponse', () {
    test('parses futures response correctly', () {
      final json = {
        'symbol': 'BTC-USDT',
        'exchange': 'kucoin',
        'market_type': 'futures',
        'timestamp': '2025-11-27T21:30:00Z',
        'futures_data': {
          'funding_rate': 0.0001,
          'next_funding_time': '2025-11-28T05:30:00Z',
          'mark_price': 96500.50,
          'index_price': 96498.20,
          'open_interest': 12345678.90,
          'liquidation_price': 85000.00,
        },
        // ... other fields
      };
      
      final response = ComprehensiveAnalysisResponse.fromJson(json);
      
      expect(response.marketType, MarketType.futures);
      expect(response.futuresData, isNotNull);
      expect(response.futuresData!.fundingRate, 0.0001);
      expect(response.marginData, isNull);
    });
    
    test('parses spot response without futures data', () {
      final json = {
        'symbol': 'BTC-USDT',
        'market_type': 'spot',
        // ... no futures_data
      };
      
      final response = ComprehensiveAnalysisResponse.fromJson(json);
      
      expect(response.marketType, MarketType.spot);
      expect(response.futuresData, isNull);
    });
  });
  
  group('TradingApiService', () {
    late MockDio mockDio;
    late TradingApiService service;
    
    setUp(() {
      mockDio = MockDio();
      service = TradingApiService(mockDio);
    });
    
    test('getComprehensiveAnalysis sends correct request', () async {
      when(mockDio.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                data: mockAnalysisResponse,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));
      
      await service.getComprehensiveAnalysis(
        symbol: 'BTC-USDT',
        marketType: MarketType.futures,
      );
      
      verify(mockDio.post(
        'http://192.168.1.6:10600/tools/comprehensive-analysis',
        data: {
          'symbol': 'BTC-USDT',
          'exchange': 'kucoin',
          'market_type': 'futures',
        },
      )).called(1);
    });
    
    test('submitOrder validates spot leverage', () async {
      expect(
        () => service.submitOrder(
          exchange: 'kucoin',
          pair: 'BTC-USDT',
          marketType: MarketType.spot,
          side: 'buy',
          amount: 0.1,
          price: 96500.00,
          leverage: 10,  // Invalid for spot
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
```

### Integration Tests

```dart
void main() {
  group('Market Types Integration', () {
    late TradingApiService service;
    
    setUpAll(() {
      service = TradingApiService(Dio());
    });
    
    test('can fetch futures analysis', () async {
      final analysis = await service.getComprehensiveAnalysis(
        symbol: 'BTC-USDT',
        marketType: MarketType.futures,
      );
      
      expect(analysis.marketType, MarketType.futures);
      expect(analysis.futuresData, isNotNull);
      expect(analysis.futuresData!.fundingRate, isNotNull);
    });
    
    test('can fetch spot analysis', () async {
      final analysis = await service.getComprehensiveAnalysis(
        symbol: 'BTC-USDT',
        marketType: MarketType.spot,
      );
      
      expect(analysis.marketType, MarketType.spot);
      expect(analysis.futuresData, isNull);
    });
    
    test('can get markets by type', () async {
      final markets = await service.getMarkets(
        exchange: 'kucoin',
        marketType: MarketType.futures,
      );
      
      expect(markets, isNotEmpty);
      expect(markets.first.leverageAvailable, true);
    });
  });
}
```

---

## 🔄 Migración

### Paso 1: Actualizar Modelos

Agregar `MarketType` enum y campos opcionales a tus modelos existentes.

### Paso 2: Actualizar Requests (Opcional)

Puedes empezar sin cambios. El backend asume `futures` por defecto.

```dart
// Antes (sigue funcionando)
final analysis = await apiService.getComprehensiveAnalysis(
  symbol: 'BTC-USDT',
);

// Después (recomendado)
final analysis = await apiService.getComprehensiveAnalysis(
  symbol: 'BTC-USDT',
  marketType: _selectedMarketType,
);
```

### Paso 3: Actualizar UI

Agregar selector de market type donde sea relevante.

### Paso 4: Manejar Respuestas Adaptadas

Verificar campos opcionales según el tipo:

```dart
Widget buildMarketSpecificData(ComprehensiveAnalysisResponse analysis) {
  switch (analysis.marketType) {
    case MarketType.futures:
      if (analysis.futuresData != null) {
        return FuturesDataWidget(data: analysis.futuresData!);
      }
      break;
    case MarketType.margin:
      if (analysis.marginData != null) {
        return MarginDataWidget(data: analysis.marginData!);
      }
      break;
    case MarketType.spot:
      return SpotDataWidget();
    case MarketType.options:
      if (analysis.optionsData != null) {
        return OptionsDataWidget(data: analysis.optionsData!);
      }
      break;
  }
  return SizedBox.shrink();
}
```

### Paso 5: Testing

Probar con diferentes market types y verificar que la UI se adapta correctamente.

---

## ❓ FAQ

### ¿Necesito cambiar mi código existente?

**No.** Todos los endpoints funcionan sin cambios. El parámetro `market_type` es opcional.

### ¿Qué pasa si no envío market_type?

El sistema asume `futures` por defecto para mantener backwards compatibility.

### ¿Cómo sé qué market types soporta un exchange?

Usa el endpoint `get_market_types` o verifica la documentación del exchange.

### ¿El símbolo se convierte automáticamente?

Sí. Si envías `BTC-USDT` con `market_type=futures`, el backend lo convierte a `BTCUSDTM` para KuCoin automáticamente.

### ¿Puedo usar leverage en spot trading?

No. El backend rechazará la orden con error `INVALID_LEVERAGE`.

### ¿Qué campos son opcionales en la respuesta?

Depende del market type:
- `futures_data`: Solo en futures
- `margin_data`: Solo en margin
- `options_data`: Solo en options
- Spot no tiene campos adicionales

### ¿Cómo manejo errores de validación?

El backend retorna errores con código y detalles. Usa try-catch y muestra mensajes apropiados al usuario.

### ¿Hay límites de rate limiting?

Los mismos que antes. El parámetro `market_type` no afecta rate limits.

### ¿Puedo filtrar posiciones por market type?

Sí. Usa el parámetro `market_type` en `get_positions`.

### ¿Necesito autenticación para testing?

No. Usa `/tools/comprehensive-analysis` y `/tools/call` para testing sin auth.

---

## 📞 Soporte

### Contacto Backend Team

- **Email**: backend-team@example.com
- **Slack**: #backend-support
- **Docs**: Ver `SPEC_COMPLETION_REPORT.md`

### Recursos Adicionales

- **API Tests**: `TEST_RESULTS_PARALLEL.md`
- **Migration Guide**: `MARKET_TYPE_MIGRATION_GUIDE.md`
- **Integration Guide**: `FLUTTER-API-INTEGRATION-GUIDE.md`

### Testing Scripts

```bash
# Test paralelo (12 requests)
./scripts/parallel-market-types-test.sh

# Stress test (50 requests)
./scripts/stress-test-market-types.sh
```

---

## 📊 Performance

### Response Times (Bajo Carga)

- **Min**: 13ms
- **Avg**: 31ms
- **Median**: 31ms
- **P95**: 45ms
- **Max**: 103ms

### Concurrent Requests

Testeado con **50 requests concurrentes**: 100% success rate.

### Recommendations

- Cache responses cuando sea posible
- Usa debouncing para requests frecuentes
- Implementa retry logic con exponential backoff
- Monitorea errores y reporta patrones

---

## ✅ Checklist de Integración

- [ ] Agregar `MarketType` enum
- [ ] Actualizar modelos de request
- [ ] Actualizar modelos de response
- [ ] Agregar campos opcionales (futuresData, marginData, etc)
- [ ] Implementar selector de market type en UI
- [ ] Actualizar service layer
- [ ] Agregar validación local de leverage
- [ ] Implementar manejo de errores
- [ ] Escribir unit tests
- [ ] Escribir integration tests
- [ ] Probar con diferentes market types
- [ ] Verificar backwards compatibility
- [ ] Actualizar documentación interna
- [ ] Deploy a staging
- [ ] Testing QA
- [ ] Deploy a producción

---

**¡Listo para integrar! 🚀**

Si tienes preguntas o necesitas ayuda, contacta al backend team.
