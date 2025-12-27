# 🤖 Funcionalidad de IA - Trading MCP Server

**Fecha**: 29 de Noviembre, 2025  
**Estado**: ✅ Producción  
**Versión**: 5.0 - AI Enhanced

---

## 🎯 Resumen Ejecutivo

El Trading MCP Server ahora incluye **capacidades avanzadas de Inteligencia Artificial** que mejoran significativamente el análisis de mercado y las decisiones de trading.

### ✨ Características Principales

1. **Multi-Provider LLM** - OpenAI, Claude, Gemini
2. **Análisis de Sentimiento** - News, Twitter, Reddit
3. **Gestión de Costos** - Control de presupuesto automático
4. **Aprendizaje Continuo** - Mejora con cada trade
5. **Notificaciones Inteligentes** - Explicaciones generadas por IA

---

## 📊 Nuevos Endpoints de IA

### 1. Análisis con IA Habilitada

```dart
POST /api/v1/ai-bot/comprehensive-analysis
Content-Type: application/json

{
  "symbol": "DOGE-USDT",
  "exchange": "kucoin",
  "enable_llm": true,        // ⭐ NUEVO
  "enable_sentiment": true   // ⭐ NUEVO
}
```

**Respuesta Mejorada**:
```json
{
  "symbol": "DOGE-USDT",
  "recommendation": {
    "action": "BUY",
    "confidence": 0.86,
    "reasoning": [
      "Strong bullish momentum",
      "RSI in healthy zone",
      "MACD crossover detected"
    ],
    "llm_analysis": {           // ⭐ NUEVO
      "provider": "google",
      "model": "gemini-2.5-flash",
      "explanation": "Market shows strong bullish momentum...",
      "key_factors": ["RSI oversold", "MACD crossover"],
      "risk_assessment": "Medium",
      "confidence": 0.75
    },
    "sentiment_analysis": {     // ⭐ NUEVO
      "overall": 0.65,
      "trend": "bullish",
      "sources": ["news", "twitter", "reddit"],
      "confidence": 0.80
    }
  }
}
```


### 2. Estado de IA

```dart
GET /api/v1/ai/status
```

**Respuesta**:
```json
{
  "llm": {
    "enabled": true,
    "provider": "google",
    "model": "gemini-2.5-flash",
    "status": "operational",
    "calls_today": 45,
    "daily_limit": 100
  },
  "sentiment": {
    "enabled": true,
    "sources": {
      "news": true,
      "twitter": false,
      "reddit": false
    }
  },
  "cost_management": {
    "enabled": true,
    "daily_budget": 2.0,
    "spent_today": 0.68,
    "remaining": 1.32
  }
}
```

### 3. Costos de IA

```dart
GET /api/v1/ai/costs
```

**Respuesta**:
```json
{
  "today": {
    "total": 0.68,
    "by_provider": {
      "google": 0.68,
      "openai": 0.00,
      "anthropic": 0.00
    },
    "call_count": 45
  },
  "this_month": {
    "total": 2.25,
    "projected": 4.50
  }
}
```

### 4. Notificaciones con IA

```dart
GET /api/v1/ai/notifications
```

**Respuesta**:
```json
{
  "notifications": [
    {
      "id": "trade_123",
      "type": "trade_executed",
      "symbol": "DOGE-USDT",
      "action": "BUY",
      "price": 0.14858,
      "llm_explanation": "Strong bullish momentum detected...",
      "market_analysis": "RSI shows healthy levels...",
      "risk_assessment": "Medium",
      "timestamp": "2025-11-29T16:18:55Z"
    }
  ]
}
```

---

## 💻 Integración en Flutter

### Cliente API Extendido

```dart
class AITradingApiClient extends TradingApiClient {
  
  // Análisis con IA
  Future<Map<String, dynamic>> getAIAnalysis({
    required String symbol,
    required String exchange,
    bool enableLLM = true,
    bool enableSentiment = true,
  }) async {
    final response = await dio.post(
      '/api/v1/ai-bot/comprehensive-analysis',
      data: {
        'symbol': symbol,
        'exchange': exchange,
        'enable_llm': enableLLM,
        'enable_sentiment': enableSentiment,
      },
    );
    return response.data;
  }

  // Estado de IA
  Future<Map<String, dynamic>> getAIStatus() async {
    final response = await dio.get('/api/v1/ai/status');
    return response.data;
  }

  // Costos de IA
  Future<Map<String, dynamic>> getAICosts() async {
    final response = await dio.get('/api/v1/ai/costs');
    return response.data;
  }

  // Notificaciones con IA
  Future<List<dynamic>> getAINotifications() async {
    final response = await dio.get('/api/v1/ai/notifications');
    return response.data['notifications'];
  }
}
```

### Modelos de Datos

```dart
// Análisis LLM
class LLMAnalysis {
  final String provider;
  final String model;
  final String explanation;
  final List<String> keyFactors;
  final String riskAssessment;
  final double confidence;

  LLMAnalysis.fromJson(Map<String, dynamic> json)
      : provider = json['provider'],
        model = json['model'],
        explanation = json['explanation'],
        keyFactors = List<String>.from(json['key_factors']),
        riskAssessment = json['risk_assessment'],
        confidence = json['confidence'];
}

// Análisis de Sentimiento
class SentimentAnalysis {
  final double overall;
  final String trend;
  final List<String> sources;
  final double confidence;

  SentimentAnalysis.fromJson(Map<String, dynamic> json)
      : overall = json['overall'],
        trend = json['trend'],
        sources = List<String>.from(json['sources']),
        confidence = json['confidence'];
}

// Recomendación Mejorada
class AIRecommendation {
  final String action;
  final double confidence;
  final List<String> reasoning;
  final LLMAnalysis? llmAnalysis;
  final SentimentAnalysis? sentimentAnalysis;

  AIRecommendation.fromJson(Map<String, dynamic> json)
      : action = json['action'],
        confidence = json['confidence'],
        reasoning = List<String>.from(json['reasoning']),
        llmAnalysis = json['llm_analysis'] != null
            ? LLMAnalysis.fromJson(json['llm_analysis'])
            : null,
        sentimentAnalysis = json['sentiment_analysis'] != null
            ? SentimentAnalysis.fromJson(json['sentiment_analysis'])
            : null;
}
```

---

## 🎨 Componentes UI Sugeridos

### 1. Card de Análisis con IA

```dart
class AIAnalysisCard extends StatelessWidget {
  final AIRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Acción principal
          Container(
            padding: EdgeInsets.all(16),
            color: _getActionColor(recommendation.action),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  recommendation.action,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${(recommendation.confidence * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Explicación de IA
          if (recommendation.llmAnalysis != null)
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Análisis de IA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(recommendation.llmAnalysis!.explanation),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: recommendation.llmAnalysis!.keyFactors
                        .map((factor) => Chip(label: Text(factor)))
                        .toList(),
                  ),
                ],
              ),
            ),

          // Sentimiento
          if (recommendation.sentimentAnalysis != null)
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.sentiment_satisfied, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Sentimiento: '),
                  Text(
                    recommendation.sentimentAnalysis!.trend.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${(recommendation.sentimentAnalysis!.overall * 100).toInt()}%',
                  ),
                ],
              ),
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
        return Colors.grey;
    }
  }
}
```

### 2. Indicador de Estado de IA

```dart
class AIStatusIndicator extends StatelessWidget {
  final Map<String, dynamic> aiStatus;

  @override
  Widget build(BuildContext context) {
    final llm = aiStatus['llm'];
    final costs = aiStatus['cost_management'];

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🤖 Estado de IA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            
            // LLM Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('LLM: ${llm['model']}'),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: llm['status'] == 'operational'
                        ? Colors.green
                        : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    llm['status'],
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            
            // Uso diario
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Llamadas hoy:'),
                Text('${llm['calls_today']} / ${llm['daily_limit']}'),
              ],
            ),
            SizedBox(height: 8),
            
            // Progreso
            LinearProgressIndicator(
              value: llm['calls_today'] / llm['daily_limit'],
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 12),
            
            // Costos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Costo hoy:'),
                Text('\$${costs['spent_today'].toStringAsFixed(2)}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Presupuesto:'),
                Text('\$${costs['daily_budget'].toStringAsFixed(2)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. Lista de Notificaciones con IA

```dart
class AINotificationsList extends StatelessWidget {
  final List<dynamic> notifications;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notif = notifications[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getActionColor(notif['action']),
              child: Icon(
                _getActionIcon(notif['action']),
                color: Colors.white,
              ),
            ),
            title: Text(
              '${notif['action']} ${notif['symbol']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Precio: \$${notif['price']}'),
                SizedBox(height: 4),
                Text(
                  notif['llm_explanation'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Text(
              _formatTime(notif['timestamp']),
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            onTap: () {
              // Mostrar detalles completos
              _showNotificationDetails(context, notif);
            },
          ),
        );
      },
    );
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'BUY':
        return Colors.green;
      case 'SELL':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'BUY':
        return Icons.trending_up;
      case 'SELL':
        return Icons.trending_down;
      default:
        return Icons.remove;
    }
  }

  String _formatTime(String timestamp) {
    final dt = DateTime.parse(timestamp);
    final now = DateTime.now();
    final diff = now.difference(dt);
    
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  void _showNotificationDetails(BuildContext context, Map<String, dynamic> notif) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${notif['action']} ${notif['symbol']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Precio: \$${notif['price']}'),
              SizedBox(height: 12),
              Text(
                'Análisis de IA:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(notif['llm_explanation']),
              SizedBox(height: 12),
              Text(
                'Análisis de Mercado:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(notif['market_analysis']),
              SizedBox(height: 12),
              Text(
                'Evaluación de Riesgo:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(notif['risk_assessment']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
```

---

## 📊 Pantallas Sugeridas

### 1. Dashboard Principal con IA

```
┌─────────────────────────────────────┐
│  🤖 Trading con IA                  │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │  DOGE-USDT                  │   │
│  │  $0.14858                   │   │
│  │                             │   │
│  │  ┌─────────────────────┐   │   │
│  │  │  BUY         86%    │   │   │
│  │  └─────────────────────┘   │   │
│  │                             │   │
│  │  🧠 Análisis de IA:         │   │
│  │  Strong bullish momentum... │   │
│  │                             │   │
│  │  📊 Sentimiento: Bullish    │   │
│  │  65% positivo               │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  🤖 Estado de IA            │   │
│  │  ✅ Gemini Operacional      │   │
│  │  45/100 llamadas hoy        │   │
│  │  $0.68 / $2.00 gastado     │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

### 2. Pantalla de Notificaciones

```
┌─────────────────────────────────────┐
│  🔔 Notificaciones                  │
├─────────────────────────────────────┤
│                                     │
│  📈 BUY DOGE-USDT                   │
│  $0.14858                           │
│  Strong bullish momentum...         │
│  5m ago                             │
│  ─────────────────────────────────  │
│                                     │
│  📉 SELL BTC-USDT                   │
│  $90,873.00                         │
│  Overbought conditions...           │
│  1h ago                             │
│  ─────────────────────────────────  │
│                                     │
└─────────────────────────────────────┘
```

### 3. Pantalla de Costos

```
┌─────────────────────────────────────┐
│  💰 Costos de IA                    │
├─────────────────────────────────────┤
│                                     │
│  Hoy: $0.68 / $2.00                │
│  ████████░░░░░░░░░░ 34%            │
│                                     │
│  Por Proveedor:                     │
│  • Google (Gemini): $0.68          │
│  • OpenAI: $0.00                   │
│  • Anthropic: $0.00                │
│                                     │
│  Este Mes: $2.25                   │
│  Proyectado: $4.50                 │
│                                     │
│  Llamadas: 45                      │
│  Costo promedio: $0.015            │
│                                     │
└─────────────────────────────────────┘
```

---

## 🎯 Mejores Prácticas

### 1. Manejo de Fallback

```dart
Future<AIRecommendation> getRecommendation(String symbol) async {
  try {
    // Intentar con IA
    final analysis = await client.getAIAnalysis(
      symbol: symbol,
      exchange: 'kucoin',
      enableLLM: true,
    );
    return AIRecommendation.fromJson(analysis['recommendation']);
  } catch (e) {
    // Fallback a análisis técnico
    final analysis = await client.getComprehensiveAnalysis(
      symbol: symbol,
      exchange: 'kucoin',
    );
    return AIRecommendation.fromJson(analysis['recommendation']);
  }
}
```

### 2. Caché de Análisis

```dart
class AnalysisCache {
  final Map<String, CachedAnalysis> _cache = {};
  final Duration cacheDuration = Duration(minutes: 5);

  Future<AIRecommendation> getAnalysis(
    String symbol,
    Future<AIRecommendation> Function() fetcher,
  ) async {
    final cached = _cache[symbol];
    if (cached != null && !cached.isExpired) {
      return cached.recommendation;
    }

    final recommendation = await fetcher();
    _cache[symbol] = CachedAnalysis(
      recommendation: recommendation,
      timestamp: DateTime.now(),
    );
    return recommendation;
  }
}

class CachedAnalysis {
  final AIRecommendation recommendation;
  final DateTime timestamp;

  CachedAnalysis({
    required this.recommendation,
    required this.timestamp,
  });

  bool get isExpired =>
      DateTime.now().difference(timestamp) > Duration(minutes: 5);
}
```

### 3. Indicadores de Carga

```dart
class AIAnalysisScreen extends StatefulWidget {
  @override
  _AIAnalysisScreenState createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen> {
  bool _isLoading = false;
  AIRecommendation? _recommendation;

  Future<void> _loadAnalysis() async {
    setState(() => _isLoading = true);
    
    try {
      final analysis = await client.getAIAnalysis(
        symbol: 'DOGE-USDT',
        exchange: 'kucoin',
      );
      setState(() {
        _recommendation = AIRecommendation.fromJson(
          analysis['recommendation'],
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analizando con IA...'),
          ],
        ),
      );
    }

    if (_recommendation == null) {
      return Center(
        child: ElevatedButton(
          onPressed: _loadAnalysis,
          child: Text('Analizar con IA'),
        ),
      );
    }

    return AIAnalysisCard(recommendation: _recommendation!);
  }
}
```

---

## 🚨 Consideraciones Importantes

### 1. Costos

- **Gemini Flash**: ~$0.0015 por análisis
- **Límite diario**: 100 llamadas (configurable)
- **Presupuesto diario**: $2.00 (configurable)
- **Caché**: 5 minutos (reduce costos 50%)

### 2. Fallback Automático

El sistema automáticamente usa análisis técnico si:
- El LLM falla
- Se excede el presupuesto
- Se alcanza el límite de llamadas
- Hay problemas de red

### 3. Performance

- **Análisis con IA**: 1-3 segundos
- **Análisis técnico**: <500ms
- **Caché hit**: <50ms

---

## 📝 Checklist de Implementación

### UI Básica
- [ ] Card de análisis con IA
- [ ] Indicador de estado de IA
- [ ] Manejo de estados de carga
- [ ] Manejo de errores

### UI Avanzada
- [ ] Lista de notificaciones
- [ ] Pantalla de costos
- [ ] Gráficos de sentimiento
- [ ] Historial de análisis

### Funcionalidad
- [ ] Integración con API de IA
- [ ] Caché de análisis
- [ ] Fallback automático
- [ ] Refresh automático

### Testing
- [ ] Probar con IA habilitada
- [ ] Probar fallback
- [ ] Probar límites de presupuesto
- [ ] Probar diferentes símbolos

---

## 🎉 Beneficios de la IA

### Para Usuarios

1. **Mejores Decisiones**: Análisis más profundo y contextual
2. **Explicaciones Claras**: Entender por qué se recomienda una acción
3. **Sentimiento de Mercado**: Información de múltiples fuentes
4. **Aprendizaje Continuo**: El sistema mejora con el tiempo

### Para Desarrolladores

1. **API Simple**: Mismos endpoints, más información
2. **Fallback Robusto**: Nunca falla completamente
3. **Bien Documentado**: Ejemplos completos
4. **Fácil de Integrar**: Cambios mínimos en código existente

---

## 📚 Recursos Adicionales

- **Documentación de IA**: `/docs/ia/AI_SYSTEM_COMPLETE.md`
- **Guía de Costos**: `/docs/ia/COST_MANAGER_GUIDE.md`
- **Setup de Gemini**: `/docs/ia/GEMINI_SETUP.md`
- **Estado del Proyecto**: `/PROJECT_STATUS.md`

---

**Generado por**: Backend Team  
**Fecha**: 29 de Noviembre, 2025  
**Estado**: ✅ **PRODUCCIÓN**

