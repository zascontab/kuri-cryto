# Spec: Integración Completa Backend con IA

**Fecha de Creación**: 29 de Noviembre, 2025  
**Estado**: 🔄 En Progreso  
**Prioridad**: 🔴 Alta  
**Versión Backend**: 5.0 - AI Enhanced

---

## 📋 Resumen Ejecutivo

El equipo de backend ha actualizado la documentación incorporando **funcionalidades de IA** (Inteligencia Artificial) al Trading MCP Server. Esta spec documenta:

1. ✅ **Qué existe actualmente** en el proyecto Flutter
2. ❌ **Qué falta implementar** según la nueva documentación
3. 🔄 **Qué necesita refactorización** para aprovechar las nuevas features
4. 📝 **Plan de implementación** paso a paso

---

## 🎯 Nuevas Funcionalidades del Backend (v5.0)

### 1. **Análisis con IA** 🤖
- **LLM Multi-Provider**: OpenAI, Claude, Gemini
- **Análisis de Sentimiento**: News, Twitter, Reddit
- **Explicaciones Generadas por IA**: Contexto detallado de recomendaciones
- **Gestión de Costos**: Control automático de presupuesto

### 2. **Endpoints Nuevos**
```
POST /api/v1/ai-bot/comprehensive-analysis (con enable_llm: true)
GET  /api/v1/ai/status
GET  /api/v1/ai/costs
GET  /api/v1/ai/notifications
```

### 3. **Respuestas Mejoradas**
- `llm_analysis`: Explicación detallada de IA
- `sentiment_analysis`: Análisis de sentimiento de mercado
- `key_factors`: Factores clave identificados por IA
- `risk_assessment`: Evaluación de riesgo mejorada

---

## 📊 Estado Actual del Proyecto

### ✅ **LO QUE YA EXISTE**

#### Modelos (lib/models/)
- ✅ `comprehensive_analysis.dart` - Modelo base
- ✅ `ai_analysis.dart` - Análisis de IA básico
- ✅ `ai_bot_status.dart` - Estado del bot
- ✅ `ai_bot_config.dart` - Configuración del bot
- ✅ `futures_data.dart` - Datos de futuros
- ✅ `key_levels.dart` - Niveles clave
- ✅ `risk_assessment.dart` - Evaluación de riesgo
- ✅ `position.dart` - Posiciones

#### Servicios (lib/services/)
- ✅ `comprehensive_analysis_service.dart` - Servicio de análisis
- ✅ `ai_bot_service.dart` - Servicio del bot AI
- ✅ `market_service.dart` - Servicio de mercado
- ✅ `api_client.dart` - Cliente HTTP base

#### Providers (lib/providers/)
- ✅ `comprehensive_analysis_provider.dart` - Provider de análisis
- ✅ `ai_bot_provider.dart` - Provider del bot
- ✅ `market_provider.dart` - Provider de mercado

#### Screens (lib/screens/)
- ✅ `comprehensive_analysis_screen.dart` - Pantalla de análisis
- ✅ `ai_bot_control_screen.dart` - Control del bot
- ✅ `ai_bot_config_screen.dart` - Configuración del bot

#### Widgets (lib/widgets/)
- ✅ `recommendation_widget.dart` - Widget de recomendación
- ✅ `technical_indicators_widget.dart` - Indicadores técnicos
- ✅ `risk_assessment_widget.dart` - Evaluación de riesgo
- ✅ `bot_status_card_widget.dart` - Estado del bot
- ✅ `scenarios_widget.dart` - Escenarios
- ✅ `multi_timeframe_widget.dart` - Multi-timeframe

---

### ❌ **LO QUE FALTA IMPLEMENTAR**

#### 1. Modelos Nuevos
- ❌ `llm_analysis.dart` - Análisis LLM
- ❌ `sentiment_analysis.dart` - Análisis de sentimiento
- ❌ `ai_notification.dart` - Notificaciones con IA
- ❌ `ai_costs.dart` - Costos de IA
- ❌ `ai_status.dart` - Estado completo de IA

#### 2. Servicios Nuevos
- ❌ `ai_service.dart` - Servicio centralizado de IA
  - `getAIStatus()` - Estado de IA
  - `getAICosts()` - Costos de IA
  - `getAINotifications()` - Notificaciones
  - `getAIAnalysis()` - Análisis con IA habilitada

#### 3. Providers Nuevos
- ❌ `ai_status_provider.dart` - Estado de IA en tiempo real
- ❌ `ai_costs_provider.dart` - Gestión de costos
- ❌ `ai_notifications_provider.dart` - Notificaciones

#### 4. Screens Nuevas
- ❌ `ai_dashboard_screen.dart` - Dashboard principal con IA
- ❌ `ai_notifications_screen.dart` - Lista de notificaciones
- ❌ `ai_costs_screen.dart` - Pantalla de costos
- ❌ `ai_settings_screen.dart` - Configuración de IA

#### 5. Widgets Nuevos
- ❌ `ai_analysis_card.dart` - Card de análisis con IA
- ❌ `ai_status_indicator.dart` - Indicador de estado de IA
- ❌ `ai_notification_item.dart` - Item de notificación
- ❌ `sentiment_indicator.dart` - Indicador de sentimiento
- ❌ `llm_explanation_card.dart` - Card de explicación LLM
- ❌ `ai_cost_tracker.dart` - Tracker de costos

---

### 🔄 **LO QUE NECESITA REFACTORIZACIÓN**

#### 1. `comprehensive_analysis_service.dart`
**Problema**: No soporta parámetros `enable_llm` y `enable_sentiment`

**Refactorización Necesaria**:
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
  bool enableLLM = true,        // NUEVO
  bool enableSentiment = true,  // NUEVO
})
```

#### 2. `comprehensive_analysis.dart` (Modelo)
**Problema**: Falta soporte para campos de IA

**Campos a Agregar**:
```dart
class ComprehensiveAnalysis {
  // ... campos existentes ...
  
  // NUEVOS CAMPOS
  final LLMAnalysis? llmAnalysis;
  final SentimentAnalysis? sentimentAnalysis;
}
```

#### 3. `recommendation_widget.dart`
**Problema**: No muestra explicación de IA ni sentimiento

**Mejoras Necesarias**:
- Mostrar `llm_analysis.explanation`
- Mostrar `sentiment_analysis.trend`
- Mostrar `key_factors` como chips
- Indicador visual de confianza de IA

#### 4. `comprehensive_analysis_screen.dart`
**Problema**: No muestra información de IA

**Secciones a Agregar**:
- Card de análisis LLM
- Indicador de sentimiento
- Factores clave
- Estado de IA (llamadas, costos)

#### 5. `ai_bot_provider.dart`
**Problema**: No gestiona estado de IA ni costos

**Métodos a Agregar**:
```dart
Future<void> loadAIStatus()
Future<void> loadAICosts()
Future<void> loadAINotifications()
```

---

## 📝 Plan de Implementación

### **FASE 1: Modelos Base** (2-3 horas)
**Prioridad**: 🔴 Alta

#### Tareas:
1. ✅ Crear `lib/models/llm_analysis.dart`
2. ✅ Crear `lib/models/sentiment_analysis.dart`
3. ✅ Crear `lib/models/ai_notification.dart`
4. ✅ Crear `lib/models/ai_costs.dart`
5. ✅ Crear `lib/models/ai_status.dart`
6. ✅ Actualizar `lib/models/comprehensive_analysis.dart`
7. ✅ Actualizar `lib/models/models.dart` (exports)

**Criterios de Aceptación**:
- Todos los modelos tienen `fromJson` y `toJson`
- Todos los modelos están documentados
- Tests unitarios pasan

---

### **FASE 2: Servicios de IA** (3-4 horas)
**Prioridad**: 🔴 Alta

#### Tareas:
1. ✅ Crear `lib/services/ai_service.dart`
   - `getAIStatus()`
   - `getAICosts()`
   - `getAINotifications()`
   - `getAIAnalysis()`
2. ✅ Refactorizar `comprehensive_analysis_service.dart`
   - Agregar parámetros `enableLLM` y `enableSentiment`
   - Manejar respuestas con IA
3. ✅ Actualizar `api_client.dart` si es necesario

**Criterios de Aceptación**:
- Todos los endpoints de IA funcionan
- Manejo de errores implementado
- Fallback a análisis técnico si IA falla
- Logs apropiados

---

### **FASE 3: Providers** (2-3 horas)
**Prioridad**: 🟡 Media

#### Tareas:
1. ✅ Crear `lib/providers/ai_status_provider.dart`
2. ✅ Crear `lib/providers/ai_costs_provider.dart`
3. ✅ Crear `lib/providers/ai_notifications_provider.dart`
4. ✅ Refactorizar `comprehensive_analysis_provider.dart`
   - Agregar soporte para IA
5. ✅ Actualizar `services_provider.dart`

**Criterios de Aceptación**:
- Providers usan Riverpod correctamente
- Estado se actualiza reactivamente
- Caché implementado (5 minutos)
- Auto-refresh opcional

---

### **FASE 4: Widgets Básicos** (3-4 horas)
**Prioridad**: 🟡 Media

#### Tareas:
1. ✅ Crear `lib/widgets/ai_analysis_card.dart`
2. ✅ Crear `lib/widgets/ai_status_indicator.dart`
3. ✅ Crear `lib/widgets/sentiment_indicator.dart`
4. ✅ Crear `lib/widgets/llm_explanation_card.dart`
5. ✅ Refactorizar `recommendation_widget.dart`
   - Agregar soporte para LLM
   - Agregar indicador de sentimiento

**Criterios de Aceptación**:
- Widgets son reutilizables
- Responsive design
- Tema claro/oscuro soportado
- Animaciones suaves

---

### **FASE 5: Screens Principales** (4-5 horas)
**Prioridad**: 🟡 Media

#### Tareas:
1. ✅ Refactorizar `comprehensive_analysis_screen.dart`
   - Agregar card de análisis LLM
   - Agregar indicador de sentimiento
   - Agregar estado de IA
2. ✅ Crear `ai_dashboard_screen.dart`
   - Dashboard principal con IA
   - Análisis en tiempo real
   - Estado de IA
3. ✅ Actualizar navegación en `main_screen.dart`

**Criterios de Aceptación**:
- Pantallas funcionales
- Loading states
- Error handling
- Pull-to-refresh

---

### **FASE 6: Notificaciones y Costos** (3-4 horas)
**Prioridad**: 🟢 Baja

#### Tareas:
1. ✅ Crear `lib/screens/ai_notifications_screen.dart`
2. ✅ Crear `lib/screens/ai_costs_screen.dart`
3. ✅ Crear `lib/widgets/ai_notification_item.dart`
4. ✅ Crear `lib/widgets/ai_cost_tracker.dart`

**Criterios de Aceptación**:
- Lista de notificaciones funcional
- Detalles de notificación
- Gráficos de costos
- Proyecciones de costos

---

### **FASE 7: Configuración y Settings** (2-3 horas)
**Prioridad**: 🟢 Baja

#### Tareas:
1. ✅ Crear `lib/screens/ai_settings_screen.dart`
   - Habilitar/deshabilitar IA
   - Configurar provider (Gemini/GPT/Claude)
   - Configurar presupuesto
2. ✅ Actualizar `settings_screen.dart`

**Criterios de Aceptación**:
- Configuración persistente
- Validación de inputs
- Cambios aplicados en tiempo real

---

### **FASE 8: Testing y Optimización** (3-4 horas)
**Prioridad**: 🟡 Media

#### Tareas:
1. ✅ Tests unitarios para modelos
2. ✅ Tests unitarios para servicios
3. ✅ Tests de integración
4. ✅ Optimización de performance
5. ✅ Caché de análisis
6. ✅ Manejo de errores mejorado

**Criterios de Aceptación**:
- 80%+ code coverage
- Todos los tests pasan
- Performance aceptable (<3s para análisis con IA)
- Sin memory leaks

---

## 🎯 Prioridades de Implementación

### **Sprint 1 (Semana 1)** - Funcionalidad Core
- ✅ FASE 1: Modelos Base
- ✅ FASE 2: Servicios de IA
- ✅ FASE 3: Providers

### **Sprint 2 (Semana 2)** - UI Básica
- ✅ FASE 4: Widgets Básicos
- ✅ FASE 5: Screens Principales

### **Sprint 3 (Semana 3)** - Features Avanzadas
- ✅ FASE 6: Notificaciones y Costos
- ✅ FASE 7: Configuración y Settings

### **Sprint 4 (Semana 4)** - Calidad
- ✅ FASE 8: Testing y Optimización

---

## 📊 Métricas de Éxito

### Funcionalidad
- ✅ Todos los endpoints de IA funcionan
- ✅ Análisis con IA se muestra correctamente
- ✅ Notificaciones funcionan
- ✅ Costos se rastrean correctamente

### Performance
- ✅ Análisis con IA: <3 segundos
- ✅ Análisis sin IA: <500ms
- ✅ Caché hit: <50ms
- ✅ UI responsive: 60fps

### Calidad
- ✅ 80%+ code coverage
- ✅ 0 errores críticos
- ✅ 0 memory leaks
- ✅ Documentación completa

---

## 🚨 Riesgos y Mitigaciones

### Riesgo 1: Costos de IA Elevados
**Mitigación**:
- Implementar caché agresivo (5 minutos)
- Límite diario de llamadas
- Presupuesto diario configurable
- Fallback a análisis técnico

### Riesgo 2: Latencia de IA
**Mitigación**:
- Loading states claros
- Análisis técnico mientras se espera IA
- Timeout de 3 segundos
- Caché de resultados

### Riesgo 3: Complejidad de UI
**Mitigación**:
- Diseño incremental
- Widgets reutilizables
- Documentación clara
- Ejemplos de uso

---

## 📚 Documentación de Referencia

### Backend
- `lib/docs/flutter-team-final/00-LEER-PRIMERO.md`
- `lib/docs/flutter-team-final/08-FUNCIONALIDAD-IA.md`
- `lib/docs/flutter-team-final/AI-QUICK-START.md`
- `lib/docs/flutter-team-final/03-ANALISIS-COMPLETO.md`

### Flutter
- `lib/models/README.md`
- `lib/providers/README.md`
- `lib/services/README.md`

---

## ✅ Checklist de Implementación

### Modelos
- [ ] LLMAnalysis
- [ ] SentimentAnalysis
- [ ] AINotification
- [ ] AICosts
- [ ] AIStatus
- [ ] ComprehensiveAnalysis (actualizado)

### Servicios
- [ ] AIService
- [ ] ComprehensiveAnalysisService (refactorizado)

### Providers
- [ ] AIStatusProvider
- [ ] AICostsProvider
- [ ] AINotificationsProvider
- [ ] ComprehensiveAnalysisProvider (refactorizado)

### Widgets
- [ ] AIAnalysisCard
- [ ] AIStatusIndicator
- [ ] SentimentIndicator
- [ ] LLMExplanationCard
- [ ] AINotificationItem
- [ ] AICostTracker
- [ ] RecommendationWidget (refactorizado)

### Screens
- [ ] AIDashboardScreen
- [ ] AINotificationsScreen
- [ ] AICostsScreen
- [ ] AISettingsScreen
- [ ] ComprehensiveAnalysisScreen (refactorizado)

### Testing
- [ ] Unit tests para modelos
- [ ] Unit tests para servicios
- [ ] Integration tests
- [ ] Widget tests

---

## 🎉 Resultado Esperado

Al completar esta spec, el proyecto Flutter tendrá:

1. ✅ **Integración completa** con el backend v5.0 AI Enhanced
2. ✅ **Análisis mejorados** con explicaciones de IA
3. ✅ **Sentimiento de mercado** visible en UI
4. ✅ **Notificaciones inteligentes** con contexto
5. ✅ **Gestión de costos** de IA
6. ✅ **Fallback robusto** a análisis técnico
7. ✅ **UI moderna** y responsive
8. ✅ **Performance optimizada** con caché

---

**Última Actualización**: 29 de Noviembre, 2025  
**Próxima Revisión**: Al completar cada fase
