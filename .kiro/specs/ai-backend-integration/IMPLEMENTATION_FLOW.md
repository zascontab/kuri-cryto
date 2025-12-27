# 🔄 Flujo de Implementación - AI Backend Integration

**Diagrama visual del proceso de implementación**

---

## 📊 Vista General del Proyecto

```
┌─────────────────────────────────────────────────────────────┐
│                    BACKEND v5.0 (AI Enhanced)               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   LLM    │  │Sentiment │  │  Costs   │  │  Notif   │   │
│  │ Analysis │  │ Analysis │  │ Manager  │  │ Manager  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
                    ┌───────────────┐
                    │  HTTP/JSON    │
                    └───────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    FLUTTER APP (v4.x → v5.0)                │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    FASE 1: MODELOS                  │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐         │   │
│  │  │   LLM    │  │Sentiment │  │ AIStatus │  ...    │   │
│  │  │ Analysis │  │ Analysis │  │          │         │   │
│  │  └──────────┘  └──────────┘  └──────────┘         │   │
│  └─────────────────────────────────────────────────────┘   │
│                            ↓                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   FASE 2: SERVICIOS                 │   │
│  │  ┌──────────┐  ┌──────────────────────────┐        │   │
│  │  │   AI     │  │ ComprehensiveAnalysis    │        │   │
│  │  │ Service  │  │ Service (refactored)     │        │   │
│  │  └──────────┘  └──────────────────────────┘        │   │
│  └─────────────────────────────────────────────────────┘   │
│                            ↓                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   FASE 3: PROVIDERS                 │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐         │   │
│  │  │AIStatus  │  │ AICosts  │  │AINotif   │  ...    │   │
│  │  │Provider  │  │ Provider │  │Provider  │         │   │
│  │  └──────────┘  └──────────┘  └──────────┘         │   │
│  └─────────────────────────────────────────────────────┘   │
│                            ↓                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    FASE 4: WIDGETS                  │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐         │   │
│  │  │   AI     │  │AIStatus  │  │Sentiment │  ...    │   │
│  │  │Analysis  │  │Indicator │  │Indicator │         │   │
│  │  │  Card    │  │          │  │          │         │   │
│  │  └──────────┘  └──────────┘  └──────────┘         │   │
│  └─────────────────────────────────────────────────────┘   │
│                            ↓                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    FASE 5: SCREENS                  │   │
│  │  ┌──────────────────────────────────────────────┐   │   │
│  │  │  ComprehensiveAnalysisScreen (updated)       │   │   │
│  │  │  ┌────────────┐  ┌────────────┐             │   │   │
│  │  │  │ AI Analysis│  │ Sentiment  │             │   │   │
│  │  │  │    Card    │  │ Indicator  │             │   │   │
│  │  │  └────────────┘  └────────────┘             │   │   │
│  │  └──────────────────────────────────────────────┘   │   │
│  │  ┌──────────────────────────────────────────────┐   │   │
│  │  │  AIDashboardScreen (new)                     │   │   │
│  │  └──────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 Flujo de Datos

### Request Flow (Usuario → Backend)

```
┌──────────┐
│  User    │
│  Action  │
└────┬─────┘
     │
     ↓
┌────────────────────────────────────────┐
│  ComprehensiveAnalysisScreen           │
│  - User taps "Analyze"                 │
└────┬───────────────────────────────────┘
     │
     ↓
┌────────────────────────────────────────┐
│  ComprehensiveAnalysisProvider         │
│  - Manages state                       │
│  - Calls service                       │
└────┬───────────────────────────────────┘
     │
     ↓
┌────────────────────────────────────────┐
│  ComprehensiveAnalysisService          │
│  - Builds request                      │
│  - enableLLM: true                     │
│  - enableSentiment: true               │
└────┬───────────────────────────────────┘
     │
     ↓
┌────────────────────────────────────────┐
│  ApiClient (Dio)                       │
│  - POST /api/v1/ai-bot/                │
│    comprehensive-analysis              │
└────┬───────────────────────────────────┘
     │
     ↓
┌────────────────────────────────────────┐
│  BACKEND v5.0                          │
│  - Processes request                   │
│  - Calls LLM (Gemini)                  │
│  - Analyzes sentiment                  │
│  - Calculates indicators               │
└────┬───────────────────────────────────┘
     │
     ↓
   Response
```

### Response Flow (Backend → UI)

```
┌────────────────────────────────────────┐
│  BACKEND v5.0                          │
│  Returns JSON with:                    │
│  - recommendation                      │
│  - llm_analysis                        │
│  - sentiment_analysis                  │
│  - technical_analysis                  │
└────┬───────────────────────────────────┘
     │
     ↓
┌────────────────────────────────────────┐
│  ApiClient (Dio)                       │
│  - Receives response                   │
│  - Returns Map<String, dynamic>        │
└────┬───────────────────────────────────┘
     │
     ↓
┌────────────────────────────────────────┐
│  ComprehensiveAnalysisService          │
│  - Parses JSON                         │
│  - Creates ComprehensiveAnalysis       │
│    with LLMAnalysis & SentimentAnalysis│
└────┬───────────────────────────────────┘
     │
     ↓
┌────────────────────────────────────────┐
│  ComprehensiveAnalysisProvider         │
│  - Updates state                       │
│  - Notifies listeners                  │
└────┬───────────────────────────────────┘
     │
     ↓
┌────────────────────────────────────────┐
│  ComprehensiveAnalysisScreen           │
│  - Rebuilds with new data              │
│  - Shows AIAnalysisCard                │
│  - Shows SentimentIndicator            │
└────────────────────────────────────────┘
```

---

## 📋 Implementación por Fases

### FASE 1: Modelos Base (2-3 horas)

```
┌─────────────────────────────────────────────────────────┐
│  OBJETIVO: Poder parsear respuestas del backend        │
└─────────────────────────────────────────────────────────┘

Step 1: Crear LLMAnalysis
┌──────────────────────────────────────┐
│  lib/models/llm_analysis.dart        │
│  - provider: String                  │
│  - model: String                     │
│  - explanation: String               │
│  - keyFactors: List<String>          │
│  - riskAssessment: String            │
│  - confidence: double                │
│  - fromJson()                        │
│  - toJson()                          │
└──────────────────────────────────────┘

Step 2: Crear SentimentAnalysis
┌──────────────────────────────────────┐
│  lib/models/sentiment_analysis.dart  │
│  - overall: double                   │
│  - trend: String                     │
│  - sources: List<String>             │
│  - confidence: double                │
│  - fromJson()                        │
│  - toJson()                          │
└──────────────────────────────────────┘

Step 3: Crear AINotification
┌──────────────────────────────────────┐
│  lib/models/ai_notification.dart     │
│  - id, type, symbol, action          │
│  - llmExplanation                    │
│  - marketAnalysis                    │
│  - riskAssessment                    │
│  - timestamp                         │
└──────────────────────────────────────┘

Step 4: Crear AICosts
┌──────────────────────────────────────┐
│  lib/models/ai_costs.dart            │
│  - DailyCosts                        │
│  - MonthlyCosts                      │
└──────────────────────────────────────┘

Step 5: Crear AIStatus
┌──────────────────────────────────────┐
│  lib/models/ai_status.dart           │
│  - LLMStatus                         │
│  - SentimentStatus                   │
│  - CostManagement                    │
└──────────────────────────────────────┘

Step 6: Actualizar ComprehensiveAnalysis
┌──────────────────────────────────────┐
│  lib/models/                         │
│  comprehensive_analysis.dart         │
│  + llmAnalysis: LLMAnalysis?         │
│  + sentimentAnalysis:                │
│    SentimentAnalysis?                │
└──────────────────────────────────────┘

Step 7: Actualizar exports
┌──────────────────────────────────────┐
│  lib/models/models.dart              │
│  + export 'llm_analysis.dart'        │
│  + export 'sentiment_analysis.dart'  │
│  + export 'ai_notification.dart'     │
│  + export 'ai_costs.dart'            │
│  + export 'ai_status.dart'           │
└──────────────────────────────────────┘

✅ RESULTADO: Modelos listos para parsear respuestas
```

---

### FASE 2: Servicios de IA (3-4 horas)

```
┌─────────────────────────────────────────────────────────┐
│  OBJETIVO: Poder llamar a endpoints de IA               │
└─────────────────────────────────────────────────────────┘

Step 1: Crear AIService
┌──────────────────────────────────────┐
│  lib/services/ai_service.dart        │
│                                      │
│  + getAIStatus()                     │
│    → GET /api/v1/ai/status           │
│                                      │
│  + getAICosts()                      │
│    → GET /api/v1/ai/costs            │
│                                      │
│  + getAINotifications()              │
│    → GET /api/v1/ai/notifications    │
│                                      │
│  + getAIAnalysis()                   │
│    → POST /api/v1/ai-bot/            │
│      comprehensive-analysis          │
│    with enableLLM & enableSentiment  │
└──────────────────────────────────────┘

Step 2: Refactorizar ComprehensiveAnalysisService
┌──────────────────────────────────────┐
│  lib/services/                       │
│  comprehensive_analysis_service.dart │
│                                      │
│  ANTES:                              │
│  getComprehensiveAnalysis(           │
│    symbol, exchange                  │
│  )                                   │
│                                      │
│  DESPUÉS:                            │
│  getComprehensiveAnalysis(           │
│    symbol, exchange,                 │
│    enableLLM: true,        ← NUEVO  │
│    enableSentiment: true   ← NUEVO  │
│  )                                   │
└──────────────────────────────────────┘

Step 3: Actualizar ApiClient (si necesario)
┌──────────────────────────────────────┐
│  lib/services/api_client.dart        │
│  - Verificar timeout (30s)           │
│  - Verificar headers                 │
│  - Mejorar error handling            │
└──────────────────────────────────────┘

✅ RESULTADO: Servicios listos para usar
```

---

### FASE 3: Providers (2-3 horas)

```
┌─────────────────────────────────────────────────────────┐
│  OBJETIVO: Gestionar estado de IA en la app             │
└─────────────────────────────────────────────────────────┘

Step 1: Crear AIStatusProvider
┌──────────────────────────────────────┐
│  lib/providers/                      │
│  ai_status_provider.dart             │
│                                      │
│  @riverpod                           │
│  class AIStatusNotifier {            │
│    Future<AIStatus> build()          │
│    Future<void> refresh()            │
│    startAutoRefresh()                │
│    stopAutoRefresh()                 │
│  }                                   │
└──────────────────────────────────────┘

Step 2: Crear AICostsProvider
┌──────────────────────────────────────┐
│  lib/providers/                      │
│  ai_costs_provider.dart              │
│                                      │
│  @riverpod                           │
│  Future<AICosts> aiCosts()           │
└──────────────────────────────────────┘

Step 3: Crear AINotificationsProvider
┌──────────────────────────────────────┐
│  lib/providers/                      │
│  ai_notifications_provider.dart      │
│                                      │
│  @riverpod                           │
│  class AINotificationsNotifier {     │
│    Future<List<AINotification>>      │
│      build()                         │
│    Future<void> refresh()            │
│    markAsRead(id)                    │
│  }                                   │
└──────────────────────────────────────┘

Step 4: Refactorizar ComprehensiveAnalysisProvider
┌──────────────────────────────────────┐
│  lib/providers/                      │
│  comprehensive_analysis_provider.dart│
│                                      │
│  AGREGAR parámetros:                 │
│  - enableLLM                         │
│  - enableSentiment                   │
│                                      │
│  AGREGAR caché (5 min)               │
└──────────────────────────────────────┘

Step 5: Actualizar ServicesProvider
┌──────────────────────────────────────┐
│  lib/providers/                      │
│  services_provider.dart              │
│                                      │
│  + aiServiceProvider                 │
└──────────────────────────────────────┘

✅ RESULTADO: Estado de IA gestionado
```

---

### FASE 4: Widgets Básicos (3-4 horas)

```
┌─────────────────────────────────────────────────────────┐
│  OBJETIVO: Mostrar información de IA en UI              │
└─────────────────────────────────────────────────────────┘

Step 1: Crear AIAnalysisCard
┌──────────────────────────────────────┐
│  lib/widgets/ai_analysis_card.dart   │
│                                      │
│  ┌────────────────────────────────┐ │
│  │  BUY              86%          │ │
│  ├────────────────────────────────┤ │
│  │  🤖 Análisis de IA:            │ │
│  │  Strong bullish momentum...    │ │
│  │                                │ │
│  │  [RSI oversold] [MACD ↑]      │ │
│  │                                │ │
│  │  📊 Sentimiento: Bullish 65%  │ │
│  └────────────────────────────────┘ │
└──────────────────────────────────────┘

Step 2: Crear AIStatusIndicator
┌──────────────────────────────────────┐
│  lib/widgets/                        │
│  ai_status_indicator.dart            │
│                                      │
│  ┌────────────────────────────────┐ │
│  │  🤖 IA: Gemini ✅              │ │
│  │  45/100 llamadas               │ │
│  │  $0.68 / $2.00                 │ │
│  │  ████████░░░░░░░░░░ 34%       │ │
│  └────────────────────────────────┘ │
└──────────────────────────────────────┘

Step 3: Crear SentimentIndicator
┌──────────────────────────────────────┐
│  lib/widgets/                        │
│  sentiment_indicator.dart            │
│                                      │
│  ┌────────────────────────────────┐ │
│  │  😊 Bullish                    │ │
│  │  65% positivo                  │ │
│  │  📰 news, twitter              │ │
│  └────────────────────────────────┘ │
└──────────────────────────────────────┘

Step 4: Crear LLMExplanationCard
┌──────────────────────────────────────┐
│  lib/widgets/                        │
│  llm_explanation_card.dart           │
│                                      │
│  ┌────────────────────────────────┐ │
│  │  🧠 Gemini-2.5-Flash           │ │
│  │  ────────────────────────────  │ │
│  │  Strong bullish momentum       │ │
│  │  detected across both          │ │
│  │  timeframes...                 │ │
│  │                                │ │
│  │  Factores Clave:               │ │
│  │  • RSI oversold                │ │
│  │  • MACD crossover              │ │
│  │                                │ │
│  │  Riesgo: Medium                │ │
│  └────────────────────────────────┘ │
└──────────────────────────────────────┘

Step 5: Refactorizar RecommendationWidget
┌──────────────────────────────────────┐
│  lib/widgets/                        │
│  recommendation_widget.dart          │
│                                      │
│  AGREGAR:                            │
│  - Mostrar llmAnalysis si existe     │
│  - Mostrar sentimentAnalysis         │
│  - Mostrar keyFactors como chips     │
└──────────────────────────────────────┘

✅ RESULTADO: Widgets listos para usar
```

---

### FASE 5: Screens Principales (4-5 horas)

```
┌─────────────────────────────────────────────────────────┐
│  OBJETIVO: Integrar IA en pantallas principales         │
└─────────────────────────────────────────────────────────┘

Step 1: Refactorizar ComprehensiveAnalysisScreen
┌──────────────────────────────────────┐
│  lib/screens/                        │
│  comprehensive_analysis_screen.dart  │
│                                      │
│  AGREGAR secciones:                  │
│                                      │
│  ListView(                           │
│    PriceHeader(),                    │
│    RecommendationCard(),             │
│                                      │
│    // ← NUEVO                        │
│    if (hasLLM)                       │
│      AIAnalysisCard(),               │
│                                      │
│    TechnicalIndicators(),            │
│    MultiTimeframeView(),             │
│    ScenariosView(),                  │
│                                      │
│    // ← NUEVO                        │
│    AIStatusIndicator(),              │
│  )                                   │
└──────────────────────────────────────┘

Step 2: Crear AIDashboardScreen
┌──────────────────────────────────────┐
│  lib/screens/                        │
│  ai_dashboard_screen.dart            │
│                                      │
│  ┌────────────────────────────────┐ │
│  │  🤖 Trading con IA             │ │
│  ├────────────────────────────────┤ │
│  │  AIStatusIndicator             │ │
│  ├────────────────────────────────┤ │
│  │  Análisis Actual               │ │
│  │  AIAnalysisCard                │ │
│  ├────────────────────────────────┤ │
│  │  Últimas Notificaciones        │ │
│  │  - Trade executed...           │ │
│  │  - Alert triggered...          │ │
│  ├────────────────────────────────┤ │
│  │  Costos del Día                │ │
│  │  $0.68 / $2.00                 │ │
│  └────────────────────────────────┘ │
└──────────────────────────────────────┘

Step 3: Actualizar MainScreen
┌──────────────────────────────────────┐
│  lib/screens/main_screen.dart        │
│                                      │
│  AGREGAR tab:                        │
│  - "AI Dashboard"                    │
│  - Icono: Icons.psychology           │
│  - Badge si hay notificaciones       │
└──────────────────────────────────────┘

✅ RESULTADO: IA visible en la app
```

---

## ⏱️ Timeline Visual

```
Semana 1: Core Functionality
├── Día 1: FASE 1 (Modelos)
│   └── ✅ 7 tareas, 2-3 horas
├── Día 2: FASE 2 (Servicios)
│   └── ✅ 3 tareas, 3-4 horas
├── Día 3: FASE 3 (Providers)
│   └── ✅ 5 tareas, 2-3 horas
└── Día 4: Testing y ajustes
    └── ✅ Validar integración

Semana 2: UI Implementation
├── Día 1: FASE 4 (Widgets)
│   └── ✅ 5 tareas, 3-4 horas
├── Día 2: FASE 5 (Screens)
│   └── ✅ 3 tareas, 4-5 horas
├── Día 3: Integración
│   └── ✅ Conectar todo
└── Día 4: Testing y refinamiento
    └── ✅ Pulir UI/UX

Semana 3: Advanced Features
├── Día 1: FASE 6 (Notif/Costs)
│   └── ✅ 4 tareas, 3-4 horas
├── Día 2: FASE 7 (Settings)
│   └── ✅ 2 tareas, 2-3 horas
├── Día 3: Integración completa
│   └── ✅ Todo conectado
└── Día 4: Testing
    └── ✅ Validar features

Semana 4: Quality & Deploy
├── Día 1: FASE 8 (Testing)
│   └── ✅ 5 tareas, 3-4 horas
├── Día 2: Bug fixes
│   └── ✅ Resolver issues
├── Día 3: Documentación
│   └── ✅ Actualizar docs
└── Día 4: Deploy
    └── ✅ Producción
```

---

## 🎯 Checkpoints de Validación

### Checkpoint 1: Después de FASE 1
```
✅ Verificar:
- [ ] Todos los modelos compilan
- [ ] fromJson funciona con datos reales
- [ ] toJson funciona correctamente
- [ ] Tests unitarios pasan

🧪 Test:
final json = {...}; // Respuesta del backend
final analysis = ComprehensiveAnalysis.fromJson(json);
print(analysis.llmAnalysis?.explanation);
```

### Checkpoint 2: Después de FASE 2
```
✅ Verificar:
- [ ] AIService se conecta al backend
- [ ] ComprehensiveAnalysisService pasa parámetros
- [ ] Respuestas se parsean correctamente
- [ ] Error handling funciona

🧪 Test:
final service = AIService();
final status = await service.getAIStatus();
print('LLM: ${status.llm.model}');
```

### Checkpoint 3: Después de FASE 3
```
✅ Verificar:
- [ ] Providers se crean correctamente
- [ ] Estado se actualiza
- [ ] Caché funciona
- [ ] Auto-refresh funciona (si aplica)

🧪 Test:
final status = ref.watch(aiStatusProvider);
status.when(
  data: (data) => print('OK: ${data.llm.status}'),
  loading: () => print('Loading...'),
  error: (e, s) => print('Error: $e'),
);
```

### Checkpoint 4: Después de FASE 4
```
✅ Verificar:
- [ ] Widgets se renderizan correctamente
- [ ] Tema claro/oscuro funciona
- [ ] Responsive en diferentes tamaños
- [ ] Animaciones suaves

🧪 Test:
- Probar en diferentes dispositivos
- Probar con datos reales
- Probar con datos vacíos
- Probar con errores
```

### Checkpoint 5: Después de FASE 5
```
✅ Verificar:
- [ ] Screens se navegan correctamente
- [ ] Datos se muestran correctamente
- [ ] Pull-to-refresh funciona
- [ ] Loading states claros

🧪 Test:
- Flujo completo de análisis
- Navegación entre screens
- Refresh de datos
- Error handling
```

---

## 🚀 Quick Start Commands

### Setup Inicial
```bash
# 1. Leer documentación
cat .kiro/specs/ai-backend-integration/README.md

# 2. Verificar backend
curl http://192.168.1.6:10600/health

# 3. Probar endpoint de IA
curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/comprehensive-analysis \
  -H "Content-Type: application/json" \
  -d '{"symbol":"DOGE-USDT","exchange":"kucoin","enable_llm":true}'
```

### Durante Implementación
```bash
# Ver tareas pendientes
cat .kiro/specs/ai-backend-integration/tasks.md | grep "⬜ Pendiente"

# Consultar referencia rápida
cat .kiro/specs/ai-backend-integration/quick-reference.md

# Ver análisis detallado
cat .kiro/specs/ai-backend-integration/analysis.md
```

---

## 📊 Métricas de Progreso

### Tracking de Implementación
```
FASE 1: Modelos Base
[████████░░] 80% (6/7 tareas completadas)

FASE 2: Servicios de IA
[██████░░░░] 60% (2/3 tareas completadas)

FASE 3: Providers
[████░░░░░░] 40% (2/5 tareas completadas)

FASE 4: Widgets Básicos
[░░░░░░░░░░]  0% (0/5 tareas completadas)

FASE 5: Screens Principales
[░░░░░░░░░░]  0% (0/3 tareas completadas)

FASE 6: Notificaciones y Costos
[░░░░░░░░░░]  0% (0/4 tareas completadas)

FASE 7: Configuración
[░░░░░░░░░░]  0% (0/2 tareas completadas)

FASE 8: Testing
[░░░░░░░░░░]  0% (0/5 tareas completadas)

────────────────────────────────────────
TOTAL: [███░░░░░░░] 30% (10/33 tareas)
```

---

**Última Actualización**: 29 de Noviembre, 2025  
**Versión**: 1.0
