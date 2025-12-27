# Quick Reference: Integración Backend IA

**Última Actualización**: 29 de Noviembre, 2025

---

## 🎯 Resumen en 30 Segundos

El backend v5.0 ahora incluye **IA** (LLM + Sentimiento). La app Flutter necesita:
1. ✅ Nuevos modelos para IA
2. ✅ Actualizar servicios existentes
3. ✅ Nuevos widgets para mostrar IA
4. ✅ Actualizar screens principales

**Tiempo estimado**: 3-4 días de trabajo

---

## 📚 Documentación Backend

### Archivos Clave
```
lib/docs/flutter-team-final/
├── 00-LEER-PRIMERO.md          ⭐ Empezar aquí
├── 08-FUNCIONALIDAD-IA.md      🤖 Features de IA
├── AI-QUICK-START.md           🚀 Quick start
├── 03-ANALISIS-COMPLETO.md     📊 Análisis completo
└── 06-MODELOS-DATOS.md         📦 Modelos Dart
```

### URLs del Backend
```dart
const baseUrl = 'http://192.168.1.6:10600';
```

---

## 🆕 Nuevos Endpoints

### 1. Análisis con IA
```dart
POST /api/v1/ai-bot/comprehensive-analysis
{
  "symbol": "DOGE-USDT",
  "exchange": "kucoin",
  "enable_llm": true,        // ⬅️ NUEVO
  "enable_sentiment": true   // ⬅️ NUEVO
}
```

### 2. Estado de IA
```dart
GET /api/v1/ai/status
```

### 3. Costos de IA
```dart
GET /api/v1/ai/costs
```

### 4. Notificaciones con IA
```dart
GET /api/v1/ai/notifications
```

---

## 📦 Nuevos Modelos Necesarios

### LLMAnalysis
```dart
class LLMAnalysis {
  final String provider;        // "google", "openai", "anthropic"
  final String model;           // "gemini-2.5-flash"
  final String explanation;     // Explicación detallada
  final List<String> keyFactors;
  final String riskAssessment;  // "Low", "Medium", "High"
  final double confidence;      // 0.0 - 1.0
}
```

### SentimentAnalysis
```dart
class SentimentAnalysis {
  final double overall;         // 0.0 - 1.0
  final String trend;           // "bullish", "bearish", "neutral"
  final List<String> sources;  // ["news", "twitter", "reddit"]
  final double confidence;      // 0.0 - 1.0
}
```

### AINotification
```dart
class AINotification {
  final String id;
  final String type;            // "trade_executed", "alert", etc.
  final String symbol;
  final String action;          // "BUY", "SELL"
  final double price;
  final String llmExplanation;  // Explicación de IA
  final String marketAnalysis;
  final String riskAssessment;
  final DateTime timestamp;
}
```

### AICosts
```dart
class AICosts {
  final DailyCosts today;
  final MonthlyCosts thisMonth;
}

class DailyCosts {
  final double total;
  final Map<String, double> byProvider;
  final int callCount;
}
```

### AIStatus
```dart
class AIStatus {
  final LLMStatus llm;
  final SentimentStatus sentiment;
  final CostManagement costManagement;
}

class LLMStatus {
  final bool enabled;
  final String provider;
  final String model;
  final String status;          // "operational", "error"
  final int callsToday;
  final int dailyLimit;
}
```

---

## 🔄 Actualizaciones Necesarias

### ComprehensiveAnalysis
```dart
class ComprehensiveAnalysis {
  // ... campos existentes ...
  
  // AGREGAR
  final LLMAnalysis? llmAnalysis;
  final SentimentAnalysis? sentimentAnalysis;
}
```

### ComprehensiveAnalysisService
```dart
// ANTES
Future<ComprehensiveAnalysis> getComprehensiveAnalysis({
  required String symbol,
  required String exchange,
})

// DESPUÉS
Future<ComprehensiveAnalysis> getComprehensiveAnalysis({
  required String symbol,
  required String exchange,
  bool enableLLM = true,        // ⬅️ AGREGAR
  bool enableSentiment = true,  // ⬅️ AGREGAR
})
```

---

## 🎨 Nuevos Widgets

### AIAnalysisCard
```dart
AIAnalysisCard(
  recommendation: recommendation,
  llmAnalysis: analysis.llmAnalysis,
  sentimentAnalysis: analysis.sentimentAnalysis,
)
```

**Muestra**:
- Acción (BUY/SELL/WAIT)
- Confianza (progress bar)
- Explicación de IA
- Factores clave (chips)
- Sentimiento

### AIStatusIndicator
```dart
AIStatusIndicator(
  aiStatus: aiStatus,
)
```

**Muestra**:
- Estado del LLM
- Llamadas usadas (45/100)
- Costo gastado ($0.68 / $2.00)
- Progress bar

### SentimentIndicator
```dart
SentimentIndicator(
  sentiment: sentimentAnalysis,
)
```

**Muestra**:
- Emoji según sentimiento
- Porcentaje (65%)
- Trend (bullish/bearish)
- Fuentes (news, twitter)

---

## 📱 Actualizaciones de Screens

### ComprehensiveAnalysisScreen

**Agregar secciones**:
```dart
ListView(
  children: [
    PriceHeader(...),
    RecommendationCard(...),
    
    // ⬅️ NUEVO
    if (analysis.llmAnalysis != null)
      AIAnalysisCard(
        llmAnalysis: analysis.llmAnalysis!,
        sentimentAnalysis: analysis.sentimentAnalysis,
      ),
    
    TechnicalIndicators(...),
    MultiTimeframeView(...),
    ScenariosView(...),
    
    // ⬅️ NUEVO
    AIStatusIndicator(aiStatus: aiStatus),
  ],
)
```

---

## 🚀 Plan de Implementación Rápido

### Día 1: Modelos y Servicios
1. ✅ Crear 5 modelos nuevos (2h)
2. ✅ Actualizar ComprehensiveAnalysis (30min)
3. ✅ Crear AIService (2h)
4. ✅ Actualizar ComprehensiveAnalysisService (1h)

### Día 2: Providers y Widgets
1. ✅ Crear 3 providers nuevos (2h)
2. ✅ Actualizar provider existente (30min)
3. ✅ Crear 3 widgets básicos (3h)

### Día 3: Screens
1. ✅ Actualizar ComprehensiveAnalysisScreen (2h)
2. ✅ Crear AIDashboardScreen (2h)
3. ✅ Actualizar navegación (30min)

### Día 4: Features Avanzadas y Testing
1. ✅ Notificaciones screen (2h)
2. ✅ Costos screen (1.5h)
3. ✅ Testing (2h)

---

## 🎯 Prioridades

### 🔴 Crítico (Hacer Primero)
- [ ] LLMAnalysis model
- [ ] SentimentAnalysis model
- [ ] AIStatus model
- [ ] AIService
- [ ] Actualizar ComprehensiveAnalysisService
- [ ] AIAnalysisCard widget
- [ ] Actualizar ComprehensiveAnalysisScreen

### 🟡 Importante (Hacer Después)
- [ ] AICosts model
- [ ] AINotification model
- [ ] AIStatusProvider
- [ ] AIStatusIndicator widget
- [ ] SentimentIndicator widget
- [ ] AIDashboardScreen

### 🟢 Nice to Have (Opcional)
- [ ] AINotificationsScreen
- [ ] AICostsScreen
- [ ] AISettingsScreen
- [ ] Tests completos

---

## 📊 Respuesta del Backend (Ejemplo)

```json
{
  "symbol": "DOGE-USDT",
  "recommendation": {
    "action": "BUY",
    "confidence": 0.86,
    "reasoning": ["Strong bullish momentum"],
    
    "llm_analysis": {
      "provider": "google",
      "model": "gemini-2.5-flash",
      "explanation": "Market shows strong bullish momentum with RSI in healthy zone...",
      "key_factors": ["RSI oversold", "MACD crossover"],
      "risk_assessment": "Medium",
      "confidence": 0.75
    },
    
    "sentiment_analysis": {
      "overall": 0.65,
      "trend": "bullish",
      "sources": ["news", "twitter"],
      "confidence": 0.80
    }
  }
}
```

---

## 🔧 Código de Ejemplo

### Usar AIService
```dart
final aiService = ref.read(aiServiceProvider);

// Estado de IA
final status = await aiService.getAIStatus();
print('LLM: ${status.llm.model}');
print('Calls: ${status.llm.callsToday}/${status.llm.dailyLimit}');

// Costos
final costs = await aiService.getAICosts();
print('Today: \$${costs.today.total}');

// Notificaciones
final notifications = await aiService.getAINotifications();
for (var notif in notifications) {
  print('${notif.action} ${notif.symbol}: ${notif.llmExplanation}');
}
```

### Análisis con IA
```dart
final analysis = await comprehensiveAnalysisService.getComprehensiveAnalysis(
  symbol: 'DOGE-USDT',
  exchange: 'kucoin',
  enableLLM: true,
  enableSentiment: true,
);

if (analysis.llmAnalysis != null) {
  print('IA dice: ${analysis.llmAnalysis!.explanation}');
  print('Factores: ${analysis.llmAnalysis!.keyFactors}');
}

if (analysis.sentimentAnalysis != null) {
  print('Sentimiento: ${analysis.sentimentAnalysis!.trend}');
  print('Confianza: ${analysis.sentimentAnalysis!.confidence}');
}
```

---

## ⚠️ Consideraciones Importantes

### Performance
- Análisis con IA: 1-3 segundos
- Análisis sin IA: <500ms
- Implementar caché de 5 minutos

### Costos
- Gemini: ~$0.0015 por análisis
- Límite diario: 100 llamadas
- Presupuesto: $2/día

### Fallback
- Si IA falla → usar análisis técnico
- Si se excede presupuesto → deshabilitar IA
- Si timeout → mostrar error amigable

### UI/UX
- Loading states claros
- Información colapsable
- No abrumar al usuario
- Priorizar información clave

---

## 📞 Recursos

### Documentación
- Spec completa: `.kiro/specs/ai-backend-integration/spec.md`
- Tareas: `.kiro/specs/ai-backend-integration/tasks.md`
- Análisis: `.kiro/specs/ai-backend-integration/analysis.md`

### Backend Docs
- `lib/docs/flutter-team-final/00-LEER-PRIMERO.md`
- `lib/docs/flutter-team-final/08-FUNCIONALIDAD-IA.md`
- `lib/docs/flutter-team-final/AI-QUICK-START.md`

### Ejemplos de Código
- `lib/docs/flutter-team-final/07-EJEMPLOS-COMPLETOS.md`
- `lib/docs/flutter-team-final/06-MODELOS-DATOS.md`

---

## ✅ Checklist Rápido

### Setup
- [ ] Leer documentación backend
- [ ] Probar endpoints con curl/Postman
- [ ] Verificar conectividad

### Implementación
- [ ] Crear modelos de IA
- [ ] Crear AIService
- [ ] Actualizar servicios existentes
- [ ] Crear widgets de IA
- [ ] Actualizar screens

### Testing
- [ ] Tests unitarios
- [ ] Tests de integración
- [ ] Probar con datos reales
- [ ] Verificar performance

### Deploy
- [ ] Code review
- [ ] Documentación actualizada
- [ ] Changelog actualizado
- [ ] Release notes

---

**¡Listo para empezar! 🚀**
