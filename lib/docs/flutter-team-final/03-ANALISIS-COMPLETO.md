# 📊 Análisis Completo - Guía Flutter

**Endpoint**: `POST /api/v1/ai-bot/comprehensive-analysis`  
**Propósito**: Obtener análisis exhaustivo de un par de criptomonedas

---

## 🎯 Caso de Uso

**Juan quiere ver**:
- Precio actual y cambio 24h
- Análisis técnico (RSI, MACD, EMAs)
- Análisis multi-timeframe (1m, 5m, 15m, 1h)
- Movimiento reciente (últimas 10 velas)
- Niveles clave (soporte/resistencia)
- Recomendación (BUY/SELL/WAIT)
- Escenarios posibles
- Evaluación de riesgo

---

## 📡 Request

```dart
final response = await dio.post(
  'http://192.168.100.145:10600/api/v1/ai-bot/comprehensive-analysis',
  data: {
    'symbol': 'DOGE-USDT',
    'exchange': 'kucoin', // opcional, default: kucoin
  },
);
```

---

## 📥 Response Completa

```json
{
  "symbol": "DOGE-USDT",
  "exchange": "kucoin",
  "timestamp": "2025-11-19T09:36:53-05:00",
  
  "current_price": {
    "current": 0.15712,
    "change_24h": -2.5,
    "high_24h": 0.16100,
    "low_24h": 0.15595,
    "volume_24h": 1234567.89
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
    "bollinger": {
      "upper": 0.16200,
      "middle": 0.15800,
      "lower": 0.15400,
      "position": "middle"
    },
    "ema": {
      "ema_9": 0.15750,
      "ema_21": 0.15800,
      "ema_50": 0.15900,
      "price_vs_ema": "below_all"
    },
    "trend": "bearish",
    "strength": 0.7
  },
  
  "multi_timeframe": {
    "1m": {
      "rsi": 65.7,
      "trend": "neutral",
      "signal": "neutral"
    },
    "5m": {
      "rsi": 65.7,
      "trend": "neutral",
      "signal": "neutral"
    },
    "15m": {
      "rsi": 65.7,
      "trend": "neutral",
      "signal": "neutral"
    },
    "1h": {
      "rsi": 65.7,
      "trend": "neutral",
      "signal": "neutral"
    },
    "alignment": "not_aligned"
  },
  
  "recent_movement": [
    {
      "timestamp": "2025-11-19T09:37:00-05:00",
      "open": 0.157,
      "high": 0.15708,
      "low": 0.15696,
      "close": 0.15696,
      "volume": 12345,
      "direction": "bearish",
      "change_percent": -0.03
    },
    // ... 9 velas más
  ],
  
  "key_levels": {
    "support": 0.15595,
    "resistance": 0.16100,
    "distance": {
      "to_support_percent": 0.75,
      "to_resistance_percent": 2.47
    }
  },
  
  "recommendation": {
    "action": "WAIT",
    "confidence": 0.5,
    "reasoning": [
      "RSI en zona neutral",
      "MACD sin dirección clara",
      "Señales mixtas - mejor esperar confirmación"
    ],
    "entry_price": 0,
    "stop_loss": 0,
    "take_profit": 0
  },
  
  "scenarios": [
    {
      "name": "Rebote Alcista",
      "probability": 0.40,
      "target_price": 0.16026,
      "change_percent": 2.0,
      "timeframe": "1-2 horas",
      "impact": "positive",
      "description": "Si RSI rebota desde sobreventa y MACD gira alcista"
    },
    {
      "name": "Consolidación",
      "probability": 0.40,
      "target_price": 0.15712,
      "change_percent": 0.0,
      "timeframe": "2-4 horas",
      "impact": "neutral",
      "description": "Mercado sin dirección clara, movimiento lateral"
    },
    {
      "name": "Corrección Bajista",
      "probability": 0.20,
      "target_price": 0.15398,
      "change_percent": -2.0,
      "timeframe": "1-2 horas",
      "impact": "negative",
      "description": "Si rompe soporte y continúa tendencia bajista"
    }
  ],
  
  "risk_assessment": {
    "level": "medium",
    "score": 55.0,
    "factors": [
      "Volatilidad moderada",
      "Temporalidades no alineadas",
      "Cerca de niveles clave"
    ],
    "volatility": "medium"
  }
}
```

---

## 🎨 UI Components para Flutter

### 1. Header con Precio

```dart
class PriceHeader extends StatelessWidget {
  final ComprehensiveAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final price = analysis.currentPrice;
    final isPositive = price.change24h >= 0;
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              analysis.symbol,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '\$${price.current.toStringAsFixed(5)}',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                Text(
                  '${price.change24h.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 18,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Alto 24h', '\$${price.high24h.toStringAsFixed(5)}'),
                _buildStat('Bajo 24h', '\$${price.low24h.toStringAsFixed(5)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
```

### 2. Indicadores Técnicos

```dart
class TechnicalIndicators extends StatelessWidget {
  final TechnicalAnalysis ta;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Análisis Técnico',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            
            // RSI
            _buildIndicator(
              'RSI (14)',
              ta.rsi.value.toStringAsFixed(2),
              ta.rsi.interpretation,
              _getRSIColor(ta.rsi.value),
            ),
            
            // MACD
            _buildIndicator(
              'MACD',
              ta.macd.histogram.toStringAsFixed(6),
              'Tendencia: ${ta.macd.trend}',
              ta.macd.trend == 'bullish' ? Colors.green : Colors.red,
            ),
            
            // Trend
            _buildIndicator(
              'Tendencia',
              ta.trend.toUpperCase(),
              'Fuerza: ${(ta.strength * 100).toStringAsFixed(0)}%',
              _getTrendColor(ta.trend),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(String name, String value, String description, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(description, style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRSIColor(double rsi) {
    if (rsi < 30) return Colors.green;
    if (rsi > 70) return Colors.red;
    return Colors.orange;
  }

  Color _getTrendColor(String trend) {
    if (trend == 'bullish') return Colors.green;
    if (trend == 'bearish') return Colors.red;
    return Colors.grey;
  }
}
```

### 3. Multi-Timeframe

```dart
class MultiTimeframeView extends StatelessWidget {
  final MultiTimeframeAnalysis mtf;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Análisis Multi-Temporalidad',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildTimeframeRow('1 minuto', mtf.oneMinute),
            _buildTimeframeRow('5 minutos', mtf.fiveMinutes),
            _buildTimeframeRow('15 minutos', mtf.fifteenMinutes),
            _buildTimeframeRow('1 hora', mtf.oneHour),
            SizedBox(height: 16),
            _buildAlignment(mtf.alignment),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeframeRow(String label, TimeframeData data) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Text('RSI: ${data.rsi.toStringAsFixed(1)}'),
              SizedBox(width: 16),
              _buildSignalChip(data.signal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignalChip(String signal) {
    Color color;
    String text;
    
    switch (signal) {
      case 'oversold':
        color = Colors.green;
        text = 'Sobreventa';
        break;
      case 'overbought':
        color = Colors.red;
        text = 'Sobrecompra';
        break;
      default:
        color = Colors.grey;
        text = 'Neutral';
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  Widget _buildAlignment(String alignment) {
    String text;
    Color color;
    
    switch (alignment) {
      case 'bullish_aligned':
        text = '✅ Temporalidades alineadas ALCISTAS';
        color = Colors.green;
        break;
      case 'bearish_aligned':
        text = '⚠️ Temporalidades alineadas BAJISTAS';
        color = Colors.red;
        break;
      default:
        text = '⚡ Temporalidades NO alineadas';
        color = Colors.orange;
    }
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
```

### 4. Recomendación

```dart
class RecommendationCard extends StatelessWidget {
  final Recommendation rec;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getBackgroundColor(rec.action),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recomendación',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                _buildActionChip(rec.action),
              ],
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: rec.confidence,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(_getActionColor(rec.action)),
            ),
            SizedBox(height: 8),
            Text(
              'Confianza: ${(rec.confidence * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Razonamiento:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...rec.reasoning.map((reason) => Padding(
              padding: EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(child: Text(reason)),
                ],
              ),
            )).toList(),
            
            if (rec.action != 'WAIT') ...[
              SizedBox(height: 16),
              Divider(),
              _buildPriceInfo('Entrada', rec.entryPrice),
              _buildPriceInfo('Stop Loss', rec.stopLoss),
              _buildPriceInfo('Take Profit', rec.takeProfit),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(String action) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getActionColor(action),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        action,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildPriceInfo(String label, double price) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '\$${price.toStringAsFixed(5)}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'BUY':
        return Colors.green;
      case 'SELL':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Color _getBackgroundColor(String action) {
    return _getActionColor(action).withOpacity(0.1);
  }
}
```

### 5. Escenarios

```dart
class ScenariosView extends StatelessWidget {
  final List<MarketScenario> scenarios;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Escenarios Posibles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...scenarios.map((scenario) => _buildScenario(scenario)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildScenario(MarketScenario scenario) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: _getImpactColor(scenario.impact)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                scenario.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '${(scenario.probability * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: _getImpactColor(scenario.impact),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(scenario.description, style: TextStyle(fontSize: 12)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Objetivo: \$${scenario.targetPrice.toStringAsFixed(5)}'),
              Text(
                '${scenario.changePercent > 0 ? '+' : ''}${scenario.changePercent.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: scenario.changePercent > 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            'Plazo: ${scenario.timeframe}',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Color _getImpactColor(String impact) {
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

### 6. Evaluación de Riesgo

```dart
class RiskAssessmentView extends StatelessWidget {
  final RiskAssessment risk;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evaluación de Riesgo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nivel de Riesgo:'),
                _buildRiskChip(risk.level),
              ],
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: risk.score / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(_getRiskColor(risk.level)),
            ),
            SizedBox(height: 8),
            Text('Score: ${risk.score.toStringAsFixed(0)}/100'),
            SizedBox(height: 16),
            Text(
              'Factores de Riesgo:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...risk.factors.map((factor) => Padding(
              padding: EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(Icons.warning, size: 16, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(child: Text(factor)),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskChip(String level) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getRiskColor(level).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        level.toUpperCase(),
        style: TextStyle(
          color: _getRiskColor(level),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getRiskColor(String level) {
    switch (level) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
```

---

## 📱 Pantalla Completa

```dart
class ComprehensiveAnalysisScreen extends StatefulWidget {
  final String symbol;

  ComprehensiveAnalysisScreen({required this.symbol});

  @override
  _ComprehensiveAnalysisScreenState createState() => _ComprehensiveAnalysisScreenState();
}

class _ComprehensiveAnalysisScreenState extends State<ComprehensiveAnalysisScreen> {
  ComprehensiveAnalysis? analysis;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    setState(() => isLoading = true);
    
    try {
      final response = await dio.post(
        'http://192.168.100.145:10600/api/v1/ai-bot/comprehensive-analysis',
        data: {
          'symbol': widget.symbol,
          'exchange': 'kucoin',
        },
      );
      
      setState(() {
        analysis = ComprehensiveAnalysis.fromJson(response.data);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Análisis Completo'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadAnalysis,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalysis,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  PriceHeader(analysis: analysis!),
                  SizedBox(height: 16),
                  TechnicalIndicators(ta: analysis!.technicalAnalysis),
                  SizedBox(height: 16),
                  MultiTimeframeView(mtf: analysis!.multiTimeframe),
                  SizedBox(height: 16),
                  RecommendationCard(rec: analysis!.recommendation),
                  SizedBox(height: 16),
                  ScenariosView(scenarios: analysis!.scenarios),
                  SizedBox(height: 16),
                  RiskAssessmentView(risk: analysis!.riskAssessment),
                ],
              ),
            ),
    );
  }
}
```

---

## 🚀 Próximos Pasos

1. **Registrar el endpoint** en `cmd/trading-mcp-server/main.go`
2. **Recompilar** el servidor
3. **Probar** el endpoint
4. **Implementar** los widgets en Flutter
5. **Personalizar** los colores y estilos

---

**Endpoint listo para usar** - Solo falta registrarlo en el servidor Go y recompilar.
