# Tasks: Integración Backend con IA

**Spec**: ai-backend-integration  
**Fecha**: 29 de Noviembre, 2025

---

## 🎯 FASE 1: Modelos Base (2-3 horas)

### Task 1.1: Crear LLMAnalysis Model
**Prioridad**: 🔴 Alta  
**Estimación**: 30 min  
**Estado**: ⬜ Pendiente

**Descripción**:
Crear modelo para análisis LLM con provider, model, explanation, key_factors, etc.

**Archivo**: `lib/models/llm_analysis.dart`

**Criterios de Aceptación**:
- [ ] Clase `LLMAnalysis` creada
- [ ] Método `fromJson` implementado
- [ ] Método `toJson` implementado
- [ ] Propiedades: provider, model, explanation, keyFactors, riskAssessment, confidence
- [ ] Documentación completa

---

### Task 1.2: Crear SentimentAnalysis Model
**Prioridad**: 🔴 Alta  
**Estimación**: 30 min  
**Estado**: ⬜ Pendiente

**Descripción**:
Crear modelo para análisis de sentimiento con overall, trend, sources, confidence.

**Archivo**: `lib/models/sentiment_analysis.dart`

**Criterios de Aceptación**:
- [ ] Clase `SentimentAnalysis` creada
- [ ] Método `fromJson` implementado
- [ ] Método `toJson` implementado
- [ ] Propiedades: overall, trend, sources, confidence
- [ ] Helpers: isBullish, isBearish, isNeutral
- [ ] Documentación completa

---

### Task 1.3: Crear AINotification Model
**Prioridad**: 🔴 Alta  
**Estimación**: 30 min  
**Estado**: ⬜ Pendiente

**Descripción**:
Crear modelo para notificaciones con explicación de IA.

**Archivo**: `lib/models/ai_notification.dart`

**Criterios de Aceptación**:
- [ ] Clase `AINotification` creada
- [ ] Método `fromJson` implementado
- [ ] Propiedades: id, type, symbol, action, price, llmExplanation, marketAnalysis, riskAssessment, timestamp
- [ ] Helper para formatear tiempo relativo
- [ ] Documentación completa

---

### Task 1.4: Crear AICosts Model
**Prioridad**: 🔴 Alta  
**Estimación**: 20 min  
**Estado**: ⬜ Pendiente

**Descripción**:
Crear modelo para costos de IA (hoy, mes, proyección).

**Archivo**: `lib/models/ai_costs.dart`

**Criterios de Aceptación**:
- [ ] Clase `AICosts` creada
- [ ] Clase `DailyCosts` creada
- [ ] Clase `MonthlyCosts` creada
- [ ] Método `fromJson` implementado
- [ ] Helpers para calcular porcentajes
- [ ] Documentación completa

---

### Task 1.5: Crear AIStatus Model
**Prioridad**: 🔴 Alta  
**Estimación**: 30 min  
**Estado**: ⬜ Pendiente

**Descripción**:
Crear modelo para estado completo de IA (LLM, sentiment, costs).

**Archivo**: `lib/models/ai_status.dart`

**Criterios de Aceptación**:
- [ ] Clase `AIStatus` creada
- [ ] Clase `LLMStatus` creada
- [ ] Clase `SentimentStatus` creada
- [ ] Clase `CostManagement` creada
- [ ] Método `fromJson` implementado
- [ ] Helpers: isOperational, hasReachedLimit, etc.
- [ ] Documentación completa

---

### Task 1.6: Actualizar ComprehensiveAnalysis Model
**Prioridad**: 🔴 Alta  
**Estimación**: 30 min  
**Estado**: ⬜ Pendiente

**Descripción**:
Agregar campos opcionales para LLM y sentiment analysis.

**Archivo**: `lib/models/comprehensive_analysis.dart`

**Cambios**:
```dart
class ComprehensiveAnalysis {
  // ... campos existentes ...
  
  // NUEVOS CAMPOS
  final LLMAnalysis? llmAnalysis;
  final SentimentAnalysis? sentimentAnalysis;
}
```

**Criterios de Aceptación**:
- [ ] Campos agregados
- [ ] `fromJson` actualizado
- [ ] `toJson` actualizado
- [ ] Helpers: hasLLMAnalysis, hasSentimentAnalysis
- [ ] Tests actualizados

---

### Task 1.7: Actualizar models.dart (Exports)
**Prioridad**: 🔴 Alta  
**Estimación**: 10 min  
**Estado**: ⬜ Pendiente

**Descripción**:
Agregar exports de los nuevos modelos.

**Archivo**: `lib/models/models.dart`

**Criterios de Aceptación**:
- [ ] Export de `llm_analysis.dart`
- [ ] Export de `sentiment_analysis.dart`
- [ ] Export de `ai_notification.dart`
- [ ] Export de `ai_costs.dart`
- [ ] Export de `ai_status.dart`

---

## 🔧 FASE 2: Servicios de IA (3-4 horas)

### Task 2.1: Crear AIService
**Prioridad**: 🔴 Alta  
**Estimación**: 2 horas  
**Estado**: ⬜ Pendiente

**Descripción**:
Crear servicio centralizado para todas las operaciones de IA.

**Archivo**: `lib/services/ai_service.dart`

**Métodos a Implementar**:
```dart
class AIService {
  Future<AIStatus> getAIStatus()
  Future<AICosts> getAICosts()
  Future<List<AINotification>> getAINotifications()
  Future<ComprehensiveAnalysis> getAIAnalysis({
    required String symbol,
    required String exchange,
    bool enableLLM = true,
    bool enableSentiment = true,
  })
}
```

**Criterios de Aceptación**:
- [ ] Todos los métodos implementados
- [ ] Manejo de errores con try-catch
- [ ] Logging apropiado
- [ ] Timeout de 30 segundos
- [ ] Documentación completa
- [ ] Tests unitarios

---

### Task 2.2: Refactorizar ComprehensiveAnalysisService
**Prioridad**: 🔴 Alta  
**Estimación**: 1 hora  
**Estado**: ⬜ Pendiente

**Descripción**:
Agregar soporte para parámetros de IA.

**Archivo**: `lib/services/comprehensive_analysis_service.dart`

**Cambios**:
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
  bool enableLLM = true,
  bool enableSentiment = true,
})
```

**Criterios de Aceptación**:
- [ ] Parámetros agregados
- [ ] Request body actualizado
- [ ] Parsing de respuesta con IA
- [ ] Fallback si IA falla
- [ ] Tests actualizados

---

### Task 2.3: Actualizar ApiClient (si necesario)
**Prioridad**: 🟡 Media  
**Estimación**: 30 min  
**Estado**: ⬜ Pendiente

**Descripción**:
Verificar y actualizar cliente HTTP si es necesario.

**Archivo**: `lib/services/api_client.dart`

**Criterios de Aceptación**:
- [ ] Timeout configurado (30s)
- [ ] Headers correctos
- [ ] Manejo de errores mejorado
- [ ] Logging de requests/responses

---

## 🎨 FASE 3: Providers (2-3 horas)

### Task 3.1: Crear AIStatusProvider
**Prioridad**: 🟡 Media  
**Estimación**: 1 hora  
**Estado**: ⬜ Pendiente

**Descripción**:
Provider para gestionar estado de IA en tiempo real.

**Archivo**: `lib/providers/ai_status_provider.dart`

**Funcionalidad**:
```dart
@riverpod
class AIStatusNotifier extends _$AIStatusNotifier {
  @override
  Future<AIStatus> build() async {
    return await _loadAIStatus();
  }
  
  Future<void> refresh()
  Future<void> startAutoRefresh()
  void stopAutoRefresh()
}
```

**Criterios de Aceptación**:
- [ ] Provider creado con Riverpod
- [ ] Auto-refresh cada 30 segundos (opcional)
- [ ] Manejo de errores
- [ ] Loading states
- [ ] Tests

---

### Task 3.2: Crear AICostsProvider
**Prioridad**: 🟡 Media  
**Estimación**: 45 min  
**Estado**: ⬜ Pendiente

**Descripción**:
Provider para gestionar costos de IA.

**Archivo**: `lib/providers/ai_costs_provider.dart`

**Criterios de Aceptación**:
- [ ] Provider creado
- [ ] Refresh manual
- [ ] Cálculo de porcentajes
- [ ] Alertas si se excede presupuesto
- [ ] Tests

---

### Task 3.3: Crear AINotificationsProvider
**Prioridad**: 🟡 Media  
**Estimación**: 45 min  
**Estado**: ⬜ Pendiente

**Descripción**:
Provider para gestionar notificaciones con IA.

**Archivo**: `lib/providers/ai_notifications_provider.dart`

**Criterios de Aceptación**:
- [ ] Provider creado
- [ ] Lista de notificaciones
- [ ] Filtrado por tipo
- [ ] Ordenamiento por fecha
- [ ] Marcar como leída
- [ ] Tests

---

### Task 3.4: Refactorizar ComprehensiveAnalysisProvider
**Prioridad**: 🔴 Alta  
**Estimación**: 30 min  
**Estado**: ⬜ Pendiente

**Descripción**:
Agregar soporte para análisis con IA.

**Archivo**: `lib/providers/comprehensive_analysis_provider.dart`

**Cambios**:
- Agregar parámetros `enableLLM` y `enableSentiment`
- Caché de 5 minutos
- Fallback automático

**Criterios de Aceptación**:
- [ ] Parámetros agregados
- [ ] Caché implementado
- [ ] Fallback funcional
- [ ] Tests actualizados

---

### Task 3.5: Actualizar ServicesProvider
**Prioridad**: 🟡 Media  
**Estimación**: 15 min  
**Estado**: ⬜ Pendiente

**Descripción**:
Agregar AIService al provider de servicios.

**Archivo**: `lib/providers/services_provider.dart`

**Criterios de Aceptación**:
- [ ] AIService agregado
- [ ] Singleton configurado
- [ ] Disponible globalmente

---

## 🎨 FASE 4: Widgets Básicos (3-4 horas)

### Task 4.1: Crear AIAnalysisCard
**Prioridad**: 🟡 Media  
**Estimación**: 1.5 horas  
**Estado**: ⬜ Pendiente

**Descripción**:
Card completo para mostrar análisis con IA.

**Archivo**: `lib/widgets/ai_analysis_card.dart`

**Componentes**:
- Acción principal (BUY/SELL/WAIT)
- Confianza (progress bar)
- Explicación de IA
- Factores clave (chips)
- Sentimiento

**Criterios de Aceptación**:
- [ ] Widget creado
- [ ] Responsive
- [ ] Tema claro/oscuro
- [ ] Animaciones suaves
- [ ] Documentación

---

### Task 4.2: Crear AIStatusIndicator
**Prioridad**: 🟡 Media  
**Estimación**: 1 hora  
**Estado**: ⬜ Pendiente

**Descripción**:
Indicador compacto de estado de IA.

**Archivo**: `lib/widgets/ai_status_indicator.dart`

**Información a Mostrar**:
- Estado del LLM (operacional/error)
- Llamadas usadas hoy
- Costo gastado
- Progress bar

**Criterios de Aceptación**:
- [ ] Widget creado
- [ ] Colores según estado
- [ ] Tooltip con detalles
- [ ] Responsive

---

### Task 4.3: Crear SentimentIndicator
**Prioridad**: 🟡 Media  
**Estimación**: 45 min  
**Estado**: ⬜ Pendiente

**Descripción**:
Indicador visual de sentimiento de mercado.

**Archivo**: `lib/widgets/sentiment_indicator.dart`

**Diseño**:
- Emoji según sentimiento (😊/😐/😢)
- Porcentaje
- Trend (bullish/bearish/neutral)
- Fuentes (news, twitter, reddit)

**Criterios de Aceptación**:
- [ ] Widget creado
- [ ] Animación de cambio
- [ ] Colores apropiados
- [ ] Tooltip con detalles

---

### Task 4.4: Crear LLMExplanationCard
**Prioridad**: 🟡 Media  
**Estimación**: 45 min  
**Estado**: ⬜ Pendiente

**Descripción**:
Card para mostrar explicación detallada del LLM.

**Archivo**: `lib/widgets/llm_explanation_card.dart`

**Contenido**:
- Icono de IA
- Explicación completa
- Factores clave
- Evaluación de riesgo
- Provider y modelo usado

**Criterios de Aceptación**:
- [ ] Widget creado
- [ ] Expandible/colapsable
- [ ] Markdown support (opcional)
- [ ] Copy to clipboard

---

### Task 4.5: Refactorizar RecommendationWidget
**Prioridad**: 🔴 Alta  
**Estimación**: 1 hora  
**Estado**: ⬜ Pendiente

**Descripción**:
Agregar soporte para mostrar información de IA.

**Archivo**: `lib/widgets/recommendation_widget.dart`

**Mejoras**:
- Mostrar explicación LLM si existe
- Mostrar sentimiento si existe
- Mostrar factores clave
- Indicador de confianza mejorado

**Criterios de Aceptación**:
- [ ] Cambios implementados
- [ ] Backward compatible
- [ ] Tests actualizados
- [ ] Documentación actualizada

---

## 📱 FASE 5: Screens Principales (4-5 horas)

### Task 5.1: Refactorizar ComprehensiveAnalysisScreen
**Prioridad**: 🔴 Alta  
**Estimación**: 2 horas  
**Estado**: ⬜ Pendiente

**Descripción**:
Agregar secciones de IA a la pantalla de análisis.

**Archivo**: `lib/screens/comprehensive_analysis_screen.dart`

**Secciones a Agregar**:
- AIAnalysisCard (si hay análisis LLM)
- SentimentIndicator (si hay sentimiento)
- AIStatusIndicator (en AppBar o bottom)
- LLMExplanationCard (expandible)

**Criterios de Aceptación**:
- [ ] Secciones agregadas
- [ ] Layout responsive
- [ ] Loading states
- [ ] Error handling
- [ ] Pull-to-refresh

---

### Task 5.2: Crear AIDashboardScreen
**Prioridad**: 🟡 Media  
**Estimación**: 2 horas  
**Estado**: ⬜ Pendiente

**Descripción**:
Dashboard principal con todas las features de IA.

**Archivo**: `lib/screens/ai_dashboard_screen.dart`

**Secciones**:
1. AIStatusIndicator (header)
2. Análisis actual con IA
3. Últimas notificaciones (3-5)
4. Costos del día
5. Quick actions

**Criterios de Aceptación**:
- [ ] Screen creada
- [ ] Todas las secciones funcionales
- [ ] Auto-refresh
- [ ] Navegación a detalles
- [ ] Responsive

---

### Task 5.3: Actualizar MainScreen Navigation
**Prioridad**: 🟡 Media  
**Estimación**: 30 min  
**Estado**: ⬜ Pendiente

**Descripción**:
Agregar navegación al dashboard de IA.

**Archivo**: `lib/screens/main_screen.dart`

**Cambios**:
- Agregar tab/item para AI Dashboard
- Icono apropiado
- Badge si hay notificaciones nuevas

**Criterios de Aceptación**:
- [ ] Navegación agregada
- [ ] Icono apropiado
- [ ] Badge funcional
- [ ] Transiciones suaves

---

## 🔔 FASE 6: Notificaciones y Costos (3-4 horas)

### Task 6.1: Crear AINotificationsScreen
**Prioridad**: 🟢 Baja  
**Estimación**: 2 horas  
**Estado**: ⬜ Pendiente

**Descripción**:
Pantalla con lista de notificaciones con IA.

**Archivo**: `lib/screens/ai_notifications_screen.dart`

**Funcionalidad**:
- Lista de notificaciones
- Filtros (tipo, fecha)
- Tap para ver detalles
- Marcar como leída
- Pull-to-refresh

**Criterios de Aceptación**:
- [ ] Screen creada
- [ ] Lista funcional
- [ ] Filtros funcionan
- [ ] Detalles en modal/nueva screen
- [ ] Empty state

---

### Task 6.2: Crear AICostsScreen
**Prioridad**: 🟢 Baja  
**Estimación**: 1.5 horas  
**Estado**: ⬜ Pendiente

**Descripción**:
Pantalla para ver costos de IA detallados.

**Archivo**: `lib/screens/ai_costs_screen.dart`

**Secciones**:
- Resumen del día
- Resumen del mes
- Gráfico de costos
- Desglose por provider
- Proyección

**Criterios de Aceptación**:
- [ ] Screen creada
- [ ] Gráficos funcionales
- [ ] Desglose detallado
- [ ] Proyección calculada
- [ ] Export a CSV (opcional)

---

### Task 6.3: Crear AINotificationItem Widget
**Prioridad**: 🟢 Baja  
**Estimación**: 45 min  
**Estado**: ⬜ Pendiente

**Descripción**:
Widget para item individual de notificación.

**Archivo**: `lib/widgets/ai_notification_item.dart`

**Diseño**:
- Icono según tipo
- Título (acción + símbolo)
- Snippet de explicación
- Tiempo relativo
- Badge si no leída

**Criterios de Aceptación**:
- [ ] Widget creado
- [ ] Tap handler
- [ ] Swipe actions (opcional)
- [ ] Animaciones

---

### Task 6.4: Crear AICostTracker Widget
**Prioridad**: 🟢 Baja  
**Estimación**: 45 min  
**Estado**: ⬜ Pendiente

**Descripción**:
Widget compacto para tracking de costos.

**Archivo**: `lib/widgets/ai_cost_tracker.dart`

**Información**:
- Costo hoy / presupuesto
- Progress bar
- Llamadas usadas
- Alerta si cerca del límite

**Criterios de Aceptación**:
- [ ] Widget creado
- [ ] Colores según porcentaje
- [ ] Animaciones
- [ ] Tap para ver detalles

---

## ⚙️ FASE 7: Configuración y Settings (2-3 horas)

### Task 7.1: Crear AISettingsScreen
**Prioridad**: 🟢 Baja  
**Estimación**: 2 horas  
**Estado**: ⬜ Pendiente

**Descripción**:
Pantalla para configurar IA.

**Archivo**: `lib/screens/ai_settings_screen.dart`

**Opciones**:
- Habilitar/deshabilitar IA
- Habilitar/deshabilitar sentimiento
- Seleccionar provider (Gemini/GPT/Claude)
- Configurar presupuesto diario
- Configurar límite de llamadas
- Caché duration

**Criterios de Aceptación**:
- [ ] Screen creada
- [ ] Todas las opciones funcionales
- [ ] Validación de inputs
- [ ] Persistencia con SharedPreferences
- [ ] Cambios aplicados inmediatamente

---

### Task 7.2: Actualizar SettingsScreen
**Prioridad**: 🟢 Baja  
**Estimación**: 30 min  
**Estado**: ⬜ Pendiente

**Descripción**:
Agregar sección de IA en settings principal.

**Archivo**: `lib/screens/settings_screen.dart`

**Cambios**:
- Agregar sección "Inteligencia Artificial"
- Link a AISettingsScreen
- Toggle rápido para habilitar/deshabilitar

**Criterios de Aceptación**:
- [ ] Sección agregada
- [ ] Navegación funcional
- [ ] Toggle funcional

---

## 🧪 FASE 8: Testing y Optimización (3-4 horas)

### Task 8.1: Tests Unitarios - Modelos
**Prioridad**: 🟡 Media  
**Estimación**: 1 hora  
**Estado**: ⬜ Pendiente

**Descripción**:
Tests para todos los modelos nuevos.

**Archivos**:
- `test/models/llm_analysis_test.dart`
- `test/models/sentiment_analysis_test.dart`
- `test/models/ai_notification_test.dart`
- `test/models/ai_costs_test.dart`
- `test/models/ai_status_test.dart`

**Criterios de Aceptación**:
- [ ] Tests para fromJson
- [ ] Tests para toJson
- [ ] Tests para helpers
- [ ] 100% coverage en modelos

---

### Task 8.2: Tests Unitarios - Servicios
**Prioridad**: 🟡 Media  
**Estimación**: 1.5 horas  
**Estado**: ⬜ Pendiente

**Descripción**:
Tests para AIService y servicios refactorizados.

**Archivos**:
- `test/services/ai_service_test.dart`
- `test/services/comprehensive_analysis_service_test.dart`

**Criterios de Aceptación**:
- [ ] Tests para todos los métodos
- [ ] Tests de error handling
- [ ] Tests de timeout
- [ ] Mocks de HTTP client

---

### Task 8.3: Tests de Integración
**Prioridad**: 🟡 Media  
**Estimación**: 1 hora  
**Estado**: ⬜ Pendiente

**Descripción**:
Tests end-to-end de flujos principales.

**Archivos**:
- `test/integration/ai_analysis_flow_test.dart`
- `test/integration/ai_notifications_flow_test.dart`

**Criterios de Aceptación**:
- [ ] Test de análisis completo con IA
- [ ] Test de notificaciones
- [ ] Test de costos
- [ ] Test de fallback

---

### Task 8.4: Optimización de Performance
**Prioridad**: 🟡 Media  
**Estimación**: 1 hora  
**Estado**: ⬜ Pendiente

**Descripción**:
Optimizar performance de análisis y UI.

**Tareas**:
- Implementar caché agresivo (5 min)
- Lazy loading de notificaciones
- Optimizar rebuilds de widgets
- Profiling con DevTools

**Criterios de Aceptación**:
- [ ] Análisis con IA <3s
- [ ] Análisis sin IA <500ms
- [ ] UI 60fps
- [ ] Sin memory leaks

---

### Task 8.5: Manejo de Errores Mejorado
**Prioridad**: 🟡 Media  
**Estimación**: 30 min  
**Estado**: ⬜ Pendiente

**Descripción**:
Mejorar manejo de errores en toda la app.

**Mejoras**:
- Mensajes de error claros
- Retry automático (3 intentos)
- Fallback a análisis técnico
- Logging detallado

**Criterios de Aceptación**:
- [ ] Todos los errores manejados
- [ ] Mensajes user-friendly
- [ ] Retry funcional
- [ ] Logs apropiados

---

## 📊 Resumen de Tareas

### Por Prioridad
- 🔴 Alta: 10 tareas
- 🟡 Media: 15 tareas
- 🟢 Baja: 8 tareas

### Por Fase
- FASE 1: 7 tareas (2-3 horas)
- FASE 2: 3 tareas (3-4 horas)
- FASE 3: 5 tareas (2-3 horas)
- FASE 4: 5 tareas (3-4 horas)
- FASE 5: 3 tareas (4-5 horas)
- FASE 6: 4 tareas (3-4 horas)
- FASE 7: 2 tareas (2-3 horas)
- FASE 8: 5 tareas (3-4 horas)

### Tiempo Total Estimado
- Mínimo: 22 horas
- Máximo: 30 horas
- Promedio: 26 horas (~3-4 días de trabajo)

---

## 🎯 Orden Recomendado de Implementación

1. **Día 1**: FASE 1 + FASE 2 (Modelos y Servicios)
2. **Día 2**: FASE 3 + FASE 4 (Providers y Widgets)
3. **Día 3**: FASE 5 (Screens Principales)
4. **Día 4**: FASE 6 + FASE 7 + FASE 8 (Features avanzadas y testing)

---

**Última Actualización**: 29 de Noviembre, 2025
