# Implementation Plan - Backend Integration Complete (AI Enhanced)

## Task Overview

Este plan implementa la integración completa con el Trading MCP Server v5.0 (AI Enhanced) en fases incrementales, incorporando las nuevas funcionalidades de IA mientras mantiene la funcionalidad existente.

---

## Phase 1: Audit y Preparación

- [ ] 1. Auditar código existente
- [x] 1.1 Revisar ComprehensiveAnalysisService actual
  - Verificar qué endpoints ya están implementados
  - Verificar qué modelos ya existen
  - Identificar gaps vs documentación del backend
  - _Requirements: 1.1, 6.1_

- [x] 1.2 Revisar modelos existentes
  - ComprehensiveAnalysis - verificar campos vs backend
  - MarketType - verificar si está completo
  - Otros modelos relacionados
  - _Requirements: 6.1, 6.2_

- [x] 1.3 Crear documento de gaps
  - Listar qué falta implementar
  - Listar qué necesita refactoring
  - Priorizar tareas
  - _Requirements: 10.1_

---

## Phase 2: Modelos de Datos

- [x] 2. Crear/actualizar modelos core
- [x] 2.1 Actualizar ComprehensiveAnalysis model
  - Agregar campo multiTimeframe
  - Agregar campo recentMovement
  - Agregar campo technicalAnalysis detallado
  - Verificar estructura de scenarios
  - _Requirements: 1.2, 1.4, 1.5, 6.3_

- [x] 2.2 Crear MultiTimeframeAnalysis model
  - Clase MultiTimeframeAnalysis
  - Clase TimeframeData
  - Métodos fromJson/toJson
  - Helpers (isAligned, isOversold, etc.)
  - _Requirements: 1.5, 6.3_

- [x] 2.3 Crear TechnicalAnalysis model detallado
  - Clase TechnicalAnalysis
  - Incluir RSI, MACD, Bollinger, EMA
  - Métodos fromJson/toJson
  - Helpers útiles
  - _Requirements: 1.4, 6.3_

- [x] 2.4 Crear BotStatus model
  - Clase BotStatus
  - Campos: aiEnabled, status, isRunning
  - Métodos fromJson/toJson
  - Helper isHealthy
  - _Requirements: 2.1, 6.3_

- [x] 2.5 Crear BotConfig model
  - Clase BotConfig
  - Campos: confidenceThreshold, dryRun, maxPositions, maxRiskPerTrade
  - Métodos fromJson/toJson
  - Validación de campos
  - _Requirements: 2.4, 2.5, 6.3_

- [x] 2.6 Crear PositionsResponse y Position models
  - Clase PositionsResponse
  - Clase Position
  - Métodos fromJson/toJson
  - Helpers para P&L
  - _Requirements: 3.1, 3.2, 3.3, 6.3_

- [x] 2.7 Crear HealthResponse model
  - Clase HealthResponse
  - Campos: status, gctConnected, toolsCount, uptime, version
  - Métodos fromJson/toJson
  - Helper isHealthy
  - _Requirements: 4.1, 6.3_

- [x]* 2.8 Crear modelos de respuesta para bot actions
  - BotStartResponse
  - BotStopResponse
  - Métodos fromJson/toJson
  - _Requirements: 2.2, 2.3, 6.3_

- [x] 2.9 Actualizar exports en models.dart
  - Exportar todos los modelos nuevos
  - Organizar exports por categoría
  - _Requirements: 6.3_

---

## Phase 3: Services Layer

- [x] 3. Refactorizar/crear servicios
- [x] 3.1 Refactorizar ComprehensiveAnalysisService
  - Verificar que soporte marketType correctamente
  - Asegurar que parsea todos los campos nuevos
  - Agregar manejo de errores robusto
  - _Requirements: 1.1, 1.2, 7.1, 7.2_

- [x] 3.2 Crear AIBotService
  - Método getStatus()
  - Método start()
  - Método stop()
  - Método getConfig()
  - Método updateConfig()
  - Método getPositions()
  - Manejo de errores
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 7.1_

- [x] 3.3 Crear HealthService
  - Método check()
  - Método monitorHealth() con Stream
  - Manejo de errores
  - _Requirements: 4.1, 4.2, 7.1_

- [x] 3.4 Crear TradingApiService (cliente unificado)
  - Consolidar todos los endpoints
  - Configuración de Dio centralizada
  - Interceptors para logging
  - Retry logic con exponential backoff
  - _Requirements: 7.1, 7.6, 9.1, 9.4_

- [ ]* 3.5 Agregar caching a servicios
  - Cache para comprehensive analysis (30s)
  - Cache para bot status (5s)
  - Invalidación de cache
  - _Requirements: 9.1_

---

## Phase 4: Providers (State Management)

- [x] 4. Crear/actualizar providers
- [x] 4.1 Actualizar ComprehensiveAnalysisProvider
  - Agregar soporte para market type selection
  - Agregar loading states
  - Agregar error handling
  - Agregar auto-refresh opcional
  - _Requirements: 1.1, 5.6, 7.4, 9.3_

- [x] 4.2 Crear AIBotProvider
  - Estado del bot (status, config, positions)
  - Métodos para start/stop bot
  - Método para update config
  - Auto-refresh de posiciones
  - Loading y error states
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.5, 7.4, 9.3_

- [x] 4.3 Crear HealthProvider
  - Estado de health check
  - Monitoring continuo
  - Indicador de conectividad
  - _Requirements: 4.1, 4.2, 4.3, 7.4_

---

## Phase 5: UI Components

- [ ] 5. Actualizar/crear pantallas
- [x] 5.1 Mejorar ComprehensiveAnalysisScreen
  - Agregar selector de market type
  - Mostrar multi-timeframe analysis
  - Mostrar recent movement (chart)
  - Mejorar visualización de scenarios
  - Mostrar datos específicos por market type
  - _Requirements: 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 1.10, 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 5.2 Crear AIBotControlScreen
  - Mostrar estado del bot
  - Botones start/stop
  - Formulario de configuración
  - Validación de inputs
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 7.4, 9.3_

- [x] 5.3 Crear PositionsScreen
  - Lista de posiciones
  - Filtro por market type
  - Detalles de cada posición
  - P&L total
  - Auto-refresh
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 9.3_

- [x] 5.4 Agregar indicador de conectividad global
  - Widget en AppBar
  - Usa HealthProvider
  - Muestra estado de conexión
  - _Requirements: 4.2, 4.3_

- [ ]* 5.5 Crear widgets reutilizables
  - MarketTypeSelector
  - TechnicalIndicatorCard
  - ScenarioCard
  - PositionCard
  - LoadingIndicator
  - ErrorDisplay
  - _Requirements: 9.6_

---

## Phase 6: Error Handling & Validation

- [x] 6. Implementar manejo de errores robusto
- [x] 6.1 Crear clases de excepción
  - TradingApiException
  - NetworkException
  - ParsingException
  - ValidationException
  - _Requirements: 7.1, 7.2, 7.3_

- [x] 6.2 Agregar error handling a servicios
  - Try-catch en todos los métodos
  - Logging de errores
  - Conversión a excepciones custom
  - _Requirements: 7.1, 7.2, 7.5_

- [x] 6.3 Agregar error handling a providers
  - Capturar excepciones de servicios
  - Actualizar error state
  - Notificar a UI
  - _Requirements: 7.4_

- [x] 6.4 Agregar error display en UI
  - Snackbars para errores
  - Error widgets
  - Retry buttons
  - _Requirements: 7.4_

- [ ]* 6.5 Implementar retry logic
  - Exponential backoff
  - Máximo 3 intentos
  - Cancelación de requests obsoletos
  - _Requirements: 7.6, 9.4_

---

## Phase 7: Testing

- [ ] 7. Implementar tests
- [ ]* 7.1 Unit tests para modelos
  - Test fromJson para todos los modelos
  - Test toJson para todos los modelos
  - Test helpers
  - _Requirements: 8.1, 8.5_

- [ ]* 7.2 Unit tests para servicios
  - Mock Dio responses
  - Test happy paths
  - Test error paths
  - _Requirements: 8.2, 8.5_

- [ ]* 7.3 Unit tests para providers
  - Test state changes
  - Test error handling
  - Test loading states
  - _Requirements: 8.2, 8.5_

- [ ]* 7.4 Integration tests
  - Test endpoints reales (en test environment)
  - Test flujos completos
  - _Requirements: 8.3_

- [ ]* 7.5 Widget tests
  - Test screens
  - Test widgets reutilizables
  - _Requirements: 8.3_

---

## Phase 8: Performance & Optimization

- [x] 8. Optimizar performance
- [x]* 8.1 Implementar caching
  - Cache de análisis (30s)
  - Cache de bot status (5s)
  - Invalidación inteligente
  - _Requirements: 9.1_

- [x]* 8.2 Implementar debouncing
  - Búsqueda de símbolos (300ms)
  - Auto-refresh (5s)
  - _Requirements: 9.2_

- [x]* 8.3 Optimizar rebuilds
  - Usar const constructors
  - Usar keys apropiadamente
  - Evitar rebuilds innecesarios
  - _Requirements: 9.6_

- [ ]* 8.4 Implementar pagination
  - Para lista de posiciones (si > 50)
  - Lazy loading
  - _Requirements: 9.5_

- [ ]* 8.5 Background loading
  - Cargar datos en background
  - Mostrar datos cacheados mientras carga
  - _Requirements: 9.7_

---

## Phase 9: Documentation & Polish

- [x] 9. Documentación y pulido final
- [x] 9.1 Documentar servicios
  - Comentarios en métodos
  - Ejemplos de uso
  - _Requirements: 10.1, 10.4_

- [x] 9.2 Documentar modelos
  - Comentarios en clases
  - Comentarios en campos
  - _Requirements: 10.2, 10.4_

- [x] 9.3 Crear README de integración
  - Setup instructions
  - Ejemplos de uso
  - Troubleshooting
  - _Requirements: 10.3_

- [x] 9.4 Actualizar CHANGELOG
  - Listar todos los cambios
  - Versionar correctamente
  - _Requirements: 10.7_

- [ ]* 9.5 Code review y refactoring
  - Revisar nombres de variables
  - Seguir convenciones Dart
  - Eliminar código duplicado
  - _Requirements: 10.5, 10.6_

---

## Phase 10: AI Integration - Models

- [ ] 10. Crear modelos de IA
- [ ] 10.1 Crear LLMAnalysis model
  - Clase LLMAnalysis con propiedades: provider, model, explanation, keyFactors, riskAssessment, confidence
  - Métodos fromJson/toJson
  - Helpers: isHighConfidence, isLowRisk, providerDisplayName
  - _Requirements: AI functionality from backend v5.0_

- [ ] 10.2 Crear SentimentAnalysis model
  - Clase SentimentAnalysis con propiedades: overall, trend, sources, confidence
  - Métodos fromJson/toJson
  - Helpers: isBullish, isBearish, isNeutral, sentimentColor
  - _Requirements: AI functionality from backend v5.0_

- [ ] 10.3 Crear AINotification model
  - Clase AINotification con propiedades: id, type, symbol, action, price, llmExplanation, marketAnalysis, riskAssessment, timestamp, isRead
  - Métodos fromJson/toJson
  - Helpers: timeAgo, actionColor, actionIcon
  - _Requirements: AI functionality from backend v5.0_

- [ ] 10.4 Crear AICosts model
  - Clases AICosts, DailyCosts, MonthlyCosts
  - Métodos fromJson/toJson
  - Helpers: averageCostPerCall, primaryProvider
  - _Requirements: AI functionality from backend v5.0_

- [ ] 10.5 Crear AIStatus model
  - Clases AIStatus, LLMStatus, SentimentStatus, CostManagement
  - Métodos fromJson/toJson
  - Helpers: isOperational, hasReachedLimits, usagePercentage
  - _Requirements: AI functionality from backend v5.0_

- [ ] 10.6 Actualizar ComprehensiveAnalysis para IA
  - Agregar campos opcionales: llmAnalysis, sentimentAnalysis
  - Actualizar fromJson para parsear datos de IA
  - Helpers: hasLLMAnalysis, hasSentimentAnalysis, isAIEnhanced
  - _Requirements: AI functionality from backend v5.0_

---

## Phase 11: AI Integration - Services

- [ ] 11. Crear servicios de IA
- [ ] 11.1 Crear AIService
  - Métodos: getAIStatus(), getAICosts(), getAINotifications(), getAIAnalysis()
  - Manejo de errores específicos de IA
  - Timeout de 30 segundos
  - _Requirements: AI functionality from backend v5.0_

- [ ] 11.2 Crear excepciones específicas de IA
  - AIServiceException, AIBudgetExceededException, AILimitReachedException, AIProviderUnavailableException
  - Mensajes de error claros
  - _Requirements: AI functionality from backend v5.0_

- [ ] 11.3 Actualizar ComprehensiveAnalysisService para IA
  - Agregar parámetros enableLLM, enableSentiment
  - Implementar fallback automático si IA falla
  - Mantener compatibilidad con código existente
  - _Requirements: AI functionality from backend v5.0_

- [ ] 11.4 Crear AIFallbackService
  - Lógica de fallback inteligente
  - Manejo específico para cada tipo de error de IA
  - Logging detallado
  - _Requirements: AI functionality from backend v5.0_

- [ ] 11.5 Mejorar CacheService para IA
  - Caché específico para análisis de IA (5 min)
  - Caché para estado de IA (30 sec)
  - Caché para costos de IA (10 min)
  - _Requirements: AI functionality from backend v5.0_

---

## Phase 12: AI Integration - Providers

- [ ] 12. Crear providers de IA
- [ ] 12.1 Crear AIStatusProvider
  - Estado de IA en tiempo real
  - Auto-refresh cada 30 segundos
  - Manejo de estados loading/error/success
  - _Requirements: AI functionality from backend v5.0_

- [ ] 12.2 Crear AICostsProvider
  - Gestión de costos de IA
  - Cálculo de porcentajes de uso
  - Alertas de presupuesto
  - _Requirements: AI functionality from backend v5.0_

- [ ] 12.3 Crear AINotificationsProvider
  - Lista de notificaciones con IA
  - Marcar como leída
  - Contador de no leídas
  - _Requirements: AI functionality from backend v5.0_

- [ ] 12.4 Actualizar ComprehensiveAnalysisProvider para IA
  - Soporte para parámetros de IA
  - Caché inteligente
  - Fallback automático
  - _Requirements: AI functionality from backend v5.0_

---

## Phase 13: AI Integration - UI Components

- [ ] 13. Crear componentes UI de IA
- [ ] 13.1 Crear AIAnalysisCard
  - Mostrar explicación de IA
  - Mostrar factores clave
  - Mostrar nivel de confianza
  - Mostrar evaluación de riesgo
  - _Requirements: AI functionality from backend v5.0_

- [ ] 13.2 Crear AIStatusIndicator
  - Indicador compacto y completo
  - Estado del LLM
  - Progreso de uso diario
  - Progreso de presupuesto
  - _Requirements: AI functionality from backend v5.0_

- [ ] 13.3 Crear SentimentIndicator
  - Visualización de sentimiento
  - Emojis según tendencia
  - Fuentes de datos
  - Colores apropiados
  - _Requirements: AI functionality from backend v5.0_

- [ ] 13.4 Crear LLMExplanationCard
  - Explicación detallada expandible
  - Información del proveedor
  - Copiar al portapapeles
  - _Requirements: AI functionality from backend v5.0_

- [ ] 13.5 Crear AINotificationItem
  - Item de notificación con IA
  - Explicación resumida
  - Tiempo relativo
  - Estados leída/no leída
  - _Requirements: AI functionality from backend v5.0_

- [ ] 13.6 Crear AICostTracker
  - Tracker compacto de costos
  - Progress bar visual
  - Alertas de límite
  - _Requirements: AI functionality from backend v5.0_

---

## Phase 14: AI Integration - Screens

- [ ] 14. Crear/actualizar pantallas con IA
- [ ] 14.1 Actualizar ComprehensiveAnalysisScreen con IA
  - Integrar AIAnalysisCard
  - Integrar SentimentIndicator
  - Toggle para habilitar/deshabilitar IA
  - AIStatusIndicator en AppBar
  - _Requirements: AI functionality from backend v5.0_

- [ ] 14.2 Crear AIDashboardScreen
  - Dashboard principal de IA
  - Estado de IA
  - Análisis actual
  - Últimas notificaciones
  - Costos del día
  - _Requirements: AI functionality from backend v5.0_

- [ ] 14.3 Crear AINotificationsScreen
  - Lista completa de notificaciones
  - Filtros por tipo y fecha
  - Detalles en modal
  - Marcar como leída
  - _Requirements: AI functionality from backend v5.0_

- [ ] 14.4 Crear AICostsScreen
  - Análisis detallado de costos
  - Gráficos de uso
  - Desglose por proveedor
  - Proyecciones
  - _Requirements: AI functionality from backend v5.0_

- [ ] 14.5 Actualizar MainScreen Navigation
  - Agregar tab para IA Dashboard
  - Badge de notificaciones
  - Icono apropiado
  - _Requirements: AI functionality from backend v5.0_

---

## Phase 15: AI Configuration & Settings

- [ ] 15. Configuración de IA
- [ ] 15.1 Crear AISettingsScreen
  - Habilitar/deshabilitar IA
  - Habilitar/deshabilitar sentimiento
  - Configurar presupuesto diario
  - Configurar límite de llamadas
  - _Requirements: AI functionality from backend v5.0_

- [ ] 15.2 Actualizar SettingsScreen principal
  - Sección "Inteligencia Artificial"
  - Toggle rápido para IA
  - Navegación a configuración detallada
  - _Requirements: AI functionality from backend v5.0_

- [ ] 15.3 Crear AIPreferencesService
  - Persistencia con SharedPreferences
  - Valores por defecto
  - Validación de configuración
  - _Requirements: AI functionality from backend v5.0_

---

## Phase 16: AI Testing & Optimization

- [ ] 16. Testing y optimización de IA
- [ ] 16.1 Unit tests para modelos de IA
  - Tests para fromJson/toJson
  - Tests para helpers
  - Coverage completo
  - _Requirements: AI functionality from backend v5.0_

- [ ] 16.2 Unit tests para servicios de IA
  - Mocks de Dio
  - Tests de error handling
  - Tests de fallback
  - _Requirements: AI functionality from backend v5.0_

- [ ] 16.3 Widget tests para componentes de IA
  - Tests de rendering
  - Tests de interacciones
  - Tests de estados
  - _Requirements: AI functionality from backend v5.0_

- [ ] 16.4 Integration tests para flujos de IA
  - Tests end-to-end
  - Tests de fallback
  - Tests de configuración
  - _Requirements: AI functionality from backend v5.0_

- [ ] 16.5 Optimización de performance de IA
  - Caché estratégico
  - Cancelación de requests
  - Optimización de rebuilds
  - Circuit breaker para fallos
  - _Requirements: AI functionality from backend v5.0_

---

## Notes

- **ACTUALIZACIÓN v5.0**: Agregadas fases 10-16 para integración completa de IA
- Tasks marcadas con `*` son opcionales pero recomendadas
- Cada task debe ser completada y testeada antes de continuar
- Priorizar funcionalidad core sobre optimizaciones
- Mantener backwards compatibility cuando sea posible
- **IA**: Implementar fallback automático a análisis técnico si IA falla
