# Implementation Plan - Backend Integration Complete

## Task Overview

Este plan implementa la integración completa con el Trading MCP Server en fases incrementales, asegurando que cada paso sea funcional antes de continuar.

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

- [ ] 2. Crear/actualizar modelos core
- [ ] 2.1 Actualizar ComprehensiveAnalysis model
  - Agregar campo multiTimeframe
  - Agregar campo recentMovement
  - Agregar campo technicalAnalysis detallado
  - Verificar estructura de scenarios
  - _Requirements: 1.2, 1.4, 1.5, 6.3_

- [ ] 2.2 Crear MultiTimeframeAnalysis model
  - Clase MultiTimeframeAnalysis
  - Clase TimeframeData
  - Métodos fromJson/toJson
  - Helpers (isAligned, isOversold, etc.)
  - _Requirements: 1.5, 6.3_

- [ ] 2.3 Crear TechnicalAnalysis model detallado
  - Clase TechnicalAnalysis
  - Incluir RSI, MACD, Bollinger, EMA
  - Métodos fromJson/toJson
  - Helpers útiles
  - _Requirements: 1.4, 6.3_

- [ ] 2.4 Crear BotStatus model
  - Clase BotStatus
  - Campos: aiEnabled, status, isRunning
  - Métodos fromJson/toJson
  - Helper isHealthy
  - _Requirements: 2.1, 6.3_

- [ ] 2.5 Crear BotConfig model
  - Clase BotConfig
  - Campos: confidenceThreshold, dryRun, maxPositions, maxRiskPerTrade
  - Métodos fromJson/toJson
  - Validación de campos
  - _Requirements: 2.4, 2.5, 6.3_

- [ ] 2.6 Crear PositionsResponse y Position models
  - Clase PositionsResponse
  - Clase Position
  - Métodos fromJson/toJson
  - Helpers para P&L
  - _Requirements: 3.1, 3.2, 3.3, 6.3_

- [ ] 2.7 Crear HealthResponse model
  - Clase HealthResponse
  - Campos: status, gctConnected, toolsCount, uptime, version
  - Métodos fromJson/toJson
  - Helper isHealthy
  - _Requirements: 4.1, 6.3_

- [ ]* 2.8 Crear modelos de respuesta para bot actions
  - BotStartResponse
  - BotStopResponse
  - Métodos fromJson/toJson
  - _Requirements: 2.2, 2.3, 6.3_

- [ ] 2.9 Actualizar exports en models.dart
  - Exportar todos los modelos nuevos
  - Organizar exports por categoría
  - _Requirements: 6.3_

---

## Phase 3: Services Layer

- [ ] 3. Refactorizar/crear servicios
- [ ] 3.1 Refactorizar ComprehensiveAnalysisService
  - Verificar que soporte marketType correctamente
  - Asegurar que parsea todos los campos nuevos
  - Agregar manejo de errores robusto
  - _Requirements: 1.1, 1.2, 7.1, 7.2_

- [ ] 3.2 Crear AIBotService
  - Método getStatus()
  - Método start()
  - Método stop()
  - Método getConfig()
  - Método updateConfig()
  - Método getPositions()
  - Manejo de errores
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 7.1_

- [ ] 3.3 Crear HealthService
  - Método check()
  - Método monitorHealth() con Stream
  - Manejo de errores
  - _Requirements: 4.1, 4.2, 7.1_

- [ ] 3.4 Crear TradingApiService (cliente unificado)
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

- [ ] 4. Crear/actualizar providers
- [ ] 4.1 Actualizar ComprehensiveAnalysisProvider
  - Agregar soporte para market type selection
  - Agregar loading states
  - Agregar error handling
  - Agregar auto-refresh opcional
  - _Requirements: 1.1, 5.6, 7.4, 9.3_

- [ ] 4.2 Crear AIBotProvider
  - Estado del bot (status, config, positions)
  - Métodos para start/stop bot
  - Método para update config
  - Auto-refresh de posiciones
  - Loading y error states
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.5, 7.4, 9.3_

- [ ] 4.3 Crear HealthProvider
  - Estado de health check
  - Monitoring continuo
  - Indicador de conectividad
  - _Requirements: 4.1, 4.2, 4.3, 7.4_

---

## Phase 5: UI Components

- [ ] 5. Actualizar/crear pantallas
- [ ] 5.1 Mejorar ComprehensiveAnalysisScreen
  - Agregar selector de market type
  - Mostrar multi-timeframe analysis
  - Mostrar recent movement (chart)
  - Mejorar visualización de scenarios
  - Mostrar datos específicos por market type
  - _Requirements: 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 1.10, 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 5.2 Crear AIBotControlScreen
  - Mostrar estado del bot
  - Botones start/stop
  - Formulario de configuración
  - Validación de inputs
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 7.4, 9.3_

- [ ] 5.3 Crear PositionsScreen
  - Lista de posiciones
  - Filtro por market type
  - Detalles de cada posición
  - P&L total
  - Auto-refresh
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 9.3_

- [ ] 5.4 Agregar indicador de conectividad global
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

- [ ] 6. Implementar manejo de errores robusto
- [ ] 6.1 Crear clases de excepción
  - TradingApiException
  - NetworkException
  - ParsingException
  - ValidationException
  - _Requirements: 7.1, 7.2, 7.3_

- [ ] 6.2 Agregar error handling a servicios
  - Try-catch en todos los métodos
  - Logging de errores
  - Conversión a excepciones custom
  - _Requirements: 7.1, 7.2, 7.5_

- [ ] 6.3 Agregar error handling a providers
  - Capturar excepciones de servicios
  - Actualizar error state
  - Notificar a UI
  - _Requirements: 7.4_

- [ ] 6.4 Agregar error display en UI
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

- [ ] 8. Optimizar performance
- [ ]* 8.1 Implementar caching
  - Cache de análisis (30s)
  - Cache de bot status (5s)
  - Invalidación inteligente
  - _Requirements: 9.1_

- [ ]* 8.2 Implementar debouncing
  - Búsqueda de símbolos (300ms)
  - Auto-refresh (5s)
  - _Requirements: 9.2_

- [ ]* 8.3 Optimizar rebuilds
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

- [ ] 9. Documentación y pulido final
- [ ] 9.1 Documentar servicios
  - Comentarios en métodos
  - Ejemplos de uso
  - _Requirements: 10.1, 10.4_

- [ ] 9.2 Documentar modelos
  - Comentarios en clases
  - Comentarios en campos
  - _Requirements: 10.2, 10.4_

- [ ] 9.3 Crear README de integración
  - Setup instructions
  - Ejemplos de uso
  - Troubleshooting
  - _Requirements: 10.3_

- [ ] 9.4 Actualizar CHANGELOG
  - Listar todos los cambios
  - Versionar correctamente
  - _Requirements: 10.7_

- [ ]* 9.5 Code review y refactoring
  - Revisar nombres de variables
  - Seguir convenciones Dart
  - Eliminar código duplicado
  - _Requirements: 10.5, 10.6_

---

## Notes

- Tasks marcadas con `*` son opcionales pero recomendadas
- Cada task debe ser completada y testeada antes de continuar
- Priorizar funcionalidad core sobre optimizaciones
- Mantener backwards compatibility cuando sea posible
