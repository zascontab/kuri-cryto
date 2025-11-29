# 🚀 AI Quick Start - Para Flutter Team

**5 minutos para empezar con IA**

---

## ✨ ¿Qué hay de nuevo?

El Trading MCP Server ahora tiene **IA integrada** que mejora el análisis de mercado.

### Antes (v4.0)
```dart
// Solo análisis técnico
final analysis = await client.getComprehensiveAnalysis(
  symbol: 'DOGE-USDT',
  exchange: 'kucoin',
);
// Respuesta: action, confidence, reasoning básico
```

### Ahora (v5.0) 🆕
```dart
// Análisis técnico + IA + Sentimiento
final analysis = await client.getAIAnalysis(
  symbol: 'DOGE-USDT',
  exchange: 'kucoin',
  enableLLM: true,
  enableSentiment: true,
);
// Respuesta: action, confidence, reasoning + 
//            explicación de IA + sentimiento de mercado
```

---

## 🎯 3 Cambios Principales

### 1. Análisis Mejorado con IA

**Antes**: "BUY - RSI oversold"

**Ahora**: "BUY - Strong bullish momentum detected across both timeframes. RSI shows healthy levels (55.74) indicating room for upward movement. MACD crossover signals support the bullish case. Market sentiment is positive with 65% bullish indicators from news and social media."

### 2. Indicador de Estado de IA

```dart
// Nuevo widget sugerido
AIStatusIndicator(
  aiStatus: aiStatus,
)
```

Muestra:
- Estado del LLM (Gemini/GPT/Claude)
- Llamadas usadas hoy (45/100)
- Costo gastado ($0.68 / $2.00)

### 3. Notificaciones Inteligentes

```dart
// Nuevo endpoint
GET /api/v1/ai/notifications
```

Cada notificación incluye:
- Explicación generada por IA
- Análisis de mercado
- Evaluación de riesgo

---

## 💻 Código Mínimo

### 1. Agregar al Cliente

```dart
class AITradingApiClient extends TradingApiClient {
  Future<Map<String, dynamic>> getAIAnalysis({
    required String symbol,
    required String exchange,
  }) async {
    return await dio.post(
      '/api/v1/ai-bot/comprehensive-analysis',
      data: {
        'symbol': symbol,
        'exchange': exchange,
        'enable_llm': true,
      },
    ).then((r) => r.data);
  }
}
```

### 2. Usar en UI

```dart
final analysis = await client.getAIAnalysis(
  symbol: 'DOGE-USDT',
  exchange: 'kucoin',
);

final llm = analysis['recommendation']['llm_analysis'];
if (llm != null) {
  print('IA dice: ${llm['explanation']}');
  print('Confianza: ${llm['confidence']}');
}
```

---

## 🎨 UI Sugerida

### Card Simple

```dart
Card(
  child: Column(
    children: [
      // Acción
      Text(recommendation['action']), // BUY/SELL/WAIT
      
      // Confianza
      Text('${(recommendation['confidence'] * 100).toInt()}%'),
      
      // Explicación de IA (NUEVO)
      if (recommendation['llm_analysis'] != null)
        Text(recommendation['llm_analysis']['explanation']),
    ],
  ),
)
```

---

## 📊 Endpoints Nuevos

| Endpoint | Descripción |
|----------|-------------|
| `POST /api/v1/ai-bot/comprehensive-analysis` | Análisis con IA (parámetro `enable_llm: true`) |
| `GET /api/v1/ai/status` | Estado del sistema de IA |
| `GET /api/v1/ai/costs` | Costos de IA del día/mes |
| `GET /api/v1/ai/notifications` | Notificaciones con explicaciones de IA |

---

## ✅ Checklist Rápido

### Mínimo Viable (30 min)
- [ ] Agregar método `getAIAnalysis()` al cliente
- [ ] Mostrar `llm_analysis.explanation` en UI
- [ ] Probar con DOGE-USDT

### Recomendado (2 horas)
- [ ] Implementar `AIAnalysisCard` (ver doc completa)
- [ ] Agregar `AIStatusIndicator`
- [ ] Implementar lista de notificaciones
- [ ] Agregar manejo de fallback

### Completo (1 día)
- [ ] Todas las pantallas sugeridas
- [ ] Caché de análisis
- [ ] Gráficos de sentimiento
- [ ] Pantalla de costos

---

## 🚨 Importante

### ✅ Funciona Automáticamente

- **Fallback**: Si la IA falla, usa análisis técnico
- **Sin cambios breaking**: Endpoints antiguos siguen funcionando
- **Opcional**: Puedes usar `enable_llm: false` para desactivar

### 💰 Costos

- **Gemini**: ~$0.0015 por análisis
- **Límite**: 100 llamadas/día
- **Presupuesto**: $2/día
- **Caché**: 5 minutos (reduce costos 50%)

### ⚡ Performance

- Con IA: 1-3 segundos
- Sin IA: <500ms
- Caché: <50ms

---

## 📚 Documentación Completa

Para más detalles, ver:
- **08-FUNCIONALIDAD-IA.md** - Guía completa (20 min)
- **01-API-ENDPOINTS.md** - Endpoints actualizados
- **README.md** - Índice general

---

## 🎉 ¡Listo!

Con estos cambios mínimos ya puedes mostrar análisis mejorados con IA en tu app.

**Siguiente paso**: Leer `08-FUNCIONALIDAD-IA.md` para componentes UI completos.

---

**Versión**: 5.0 AI Enhanced  
**Fecha**: 29 de Noviembre, 2025  
**Estado**: ✅ Producción
