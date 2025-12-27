# Requirements Document - Backend Integration Complete

## Introduction

Este spec define la implementación completa de la integración con el backend Trading MCP Server v5.0 (AI Enhanced) según la documentación oficial enviada por el backend team. El objetivo es tener una integración completa, robusta y mantenible de todos los endpoints y funcionalidades disponibles, incluyendo las nuevas capacidades de Inteligencia Artificial.

## Glossary

- **Trading MCP Server**: Servidor backend que proporciona 70+ herramientas de trading y análisis
- **Comprehensive Analysis**: Análisis exhaustivo de un par de criptomonedas con indicadores técnicos, recomendaciones y escenarios
- **Market Type**: Tipo de mercado (spot, futures, margin, options)
- **AI Bot**: Bot de trading automatizado con IA
- **MCP Tools**: Herramientas del Model Context Protocol para trading
- **Flutter App**: Aplicación móvil cliente que consume el backend

## Requirements

### Requirement 1: Análisis Comprehensivo de Mercado

**User Story:** Como trader, quiero obtener un análisis completo de cualquier par de criptomonedas para tomar decisiones informadas de trading.

#### Acceptance Criteria

1. WHEN el usuario solicita análisis de un símbolo, THE Flutter App SHALL enviar request a `/api/v1/ai-bot/comprehensive-analysis`
2. WHEN el backend responde, THE Flutter App SHALL parsear correctamente todos los campos del análisis
3. THE Flutter App SHALL mostrar precio actual, cambio 24h, volumen y estadísticas
4. THE Flutter App SHALL mostrar indicadores técnicos (RSI, MACD, Bollinger, EMA)
5. THE Flutter App SHALL mostrar análisis multi-timeframe (1m, 5m, 15m, 1h)
6. THE Flutter App SHALL mostrar niveles clave (soporte y resistencia)
7. THE Flutter App SHALL mostrar recomendación de trading (BUY/SELL/WAIT) con confianza
8. THE Flutter App SHALL mostrar escenarios posibles con probabilidades
9. THE Flutter App SHALL mostrar evaluación de riesgo
10. WHEN market_type es futures, THE Flutter App SHALL mostrar datos específicos de futures (funding rate, mark price, liquidation price)

### Requirement 2: Gestión de Estado del Bot

**User Story:** Como trader, quiero controlar el bot de trading (iniciar, detener, configurar) para automatizar mis operaciones.

#### Acceptance Criteria

1. THE Flutter App SHALL obtener el estado actual del bot mediante `/api/v1/ai-bot/status`
2. THE Flutter App SHALL permitir iniciar el bot mediante `/api/v1/ai-bot/start`
3. THE Flutter App SHALL permitir detener el bot mediante `/api/v1/ai-bot/stop`
4. THE Flutter App SHALL obtener la configuración del bot mediante `/api/v1/ai-bot/config`
5. THE Flutter App SHALL permitir actualizar la configuración del bot mediante POST `/api/v1/ai-bot/config`
6. THE Flutter App SHALL mostrar el estado del bot en tiempo real (enabled/disabled, running/stopped)
7. THE Flutter App SHALL validar la configuración antes de enviarla al backend

### Requirement 3: Gestión de Posiciones

**User Story:** Como trader, quiero ver mis posiciones abiertas y su P&L para monitorear mi portafolio.

#### Acceptance Criteria

1. THE Flutter App SHALL obtener posiciones mediante `/api/v1/ai-bot/positions`
2. THE Flutter App SHALL mostrar lista de posiciones abiertas
3. THE Flutter App SHALL mostrar P&L (profit and loss) de cada posición
4. THE Flutter App SHALL mostrar P&L total del portafolio
5. THE Flutter App SHALL actualizar posiciones automáticamente cada X segundos
6. THE Flutter App SHALL permitir filtrar posiciones por market type
7. THE Flutter App SHALL mostrar detalles de cada posición (entry price, current price, size, leverage)

### Requirement 4: Health Check y Monitoreo

**User Story:** Como desarrollador, quiero monitorear la salud del backend para detectar problemas de conectividad.

#### Acceptance Criteria

1. THE Flutter App SHALL verificar health del servidor mediante `/health`
2. THE Flutter App SHALL mostrar indicador de conectividad en la UI
3. WHEN el servidor no responde, THE Flutter App SHALL mostrar mensaje de error
4. THE Flutter App SHALL reintentar conexión automáticamente con backoff exponencial
5. THE Flutter App SHALL mostrar versión del servidor y uptime

### Requirement 5: Soporte de Market Types

**User Story:** Como trader, quiero operar en diferentes tipos de mercado (spot, futures, margin, options) con datos específicos para cada uno.

#### Acceptance Criteria

1. THE Flutter App SHALL soportar 4 market types: spot, futures, margin, options
2. WHEN market_type es futures, THE Flutter App SHALL mostrar funding rate, mark price, liquidation price
3. WHEN market_type es margin, THE Flutter App SHALL mostrar interest rate, margin level, borrowed amount
4. WHEN market_type es options, THE Flutter App SHALL mostrar implied volatility, greeks
5. WHEN market_type es spot, THE Flutter App SHALL ocultar campos específicos de otros tipos
6. THE Flutter App SHALL permitir seleccionar market type en la UI
7. THE Flutter App SHALL enviar market_type en requests cuando sea especificado

### Requirement 6: Modelos de Datos Robustos

**User Story:** Como desarrollador, quiero modelos de datos type-safe y bien estructurados para evitar errores de parsing.

#### Acceptance Criteria

1. THE Flutter App SHALL tener modelos Dart para todas las respuestas del backend
2. THE Flutter App SHALL usar null-safety correctamente en todos los modelos
3. THE Flutter App SHALL tener métodos fromJson para parsear respuestas
4. THE Flutter App SHALL tener métodos toJson para serializar requests
5. THE Flutter App SHALL tener helpers útiles en los modelos (isHealthy, isBuy, etc.)
6. THE Flutter App SHALL validar tipos de datos al parsear JSON
7. THE Flutter App SHALL manejar campos opcionales correctamente

### Requirement 7: Manejo de Errores Robusto

**User Story:** Como usuario, quiero ver mensajes de error claros cuando algo falla para entender qué pasó.

#### Acceptance Criteria

1. THE Flutter App SHALL capturar errores de red (DioException)
2. THE Flutter App SHALL capturar errores de parsing (FormatException)
3. THE Flutter App SHALL capturar errores del backend (error responses)
4. THE Flutter App SHALL mostrar mensajes de error user-friendly
5. THE Flutter App SHALL loggear errores para debugging
6. THE Flutter App SHALL reintentar requests fallidos automáticamente (con límite)
7. THE Flutter App SHALL mostrar indicador de loading durante requests

### Requirement 8: Testing y Validación

**User Story:** Como desarrollador, quiero tests automatizados para asegurar que la integración funciona correctamente.

#### Acceptance Criteria

1. THE Flutter App SHALL tener unit tests para todos los modelos
2. THE Flutter App SHALL tener unit tests para todos los servicios
3. THE Flutter App SHALL tener integration tests para endpoints críticos
4. THE Flutter App SHALL tener mocks para testing sin backend
5. THE Flutter App SHALL validar responses del backend en tests
6. THE Flutter App SHALL tener coverage mínimo de 70%

### Requirement 9: Performance y Optimización

**User Story:** Como usuario, quiero que la app sea rápida y responsive para una buena experiencia.

#### Acceptance Criteria

1. THE Flutter App SHALL cachear responses cuando sea apropiado
2. THE Flutter App SHALL usar debouncing para requests frecuentes
3. THE Flutter App SHALL mostrar loading indicators durante requests
4. THE Flutter App SHALL cancelar requests obsoletos
5. THE Flutter App SHALL usar pagination para listas grandes
6. THE Flutter App SHALL optimizar rebuilds de widgets
7. THE Flutter App SHALL cargar datos en background cuando sea posible

### Requirement 10: Documentación y Mantenibilidad

**User Story:** Como desarrollador, quiero código bien documentado para facilitar mantenimiento futuro.

#### Acceptance Criteria

1. THE Flutter App SHALL tener comentarios en todos los servicios
2. THE Flutter App SHALL tener comentarios en todos los modelos
3. THE Flutter App SHALL tener README con instrucciones de setup
4. THE Flutter App SHALL tener ejemplos de uso en comentarios
5. THE Flutter App SHALL seguir convenciones de Dart/Flutter
6. THE Flutter App SHALL usar nombres descriptivos para variables y métodos
7. THE Flutter App SHALL tener changelog actualizado

### Requirement 11: Análisis Comprehensivo con IA

**User Story:** Como trader, quiero obtener análisis de mercado mejorados con IA que incluyan explicaciones detalladas y análisis de sentimiento para tomar mejores decisiones de trading.

#### Acceptance Criteria

1. WHEN el usuario solicita análisis con IA habilitada, THE Flutter App SHALL enviar parámetros `enable_llm: true` y `enable_sentiment: true`
2. WHEN el backend responde con análisis LLM, THE Flutter App SHALL mostrar la explicación generada por IA
3. THE Flutter App SHALL mostrar el proveedor de IA utilizado (Google, OpenAI, Anthropic)
4. THE Flutter App SHALL mostrar el modelo específico usado (gemini-2.5-flash, gpt-4, claude-3)
5. THE Flutter App SHALL mostrar los factores clave identificados por la IA
6. THE Flutter App SHALL mostrar la evaluación de riesgo generada por IA
7. THE Flutter App SHALL mostrar el nivel de confianza del análisis de IA
8. WHEN hay análisis de sentimiento disponible, THE Flutter App SHALL mostrar el sentimiento general (bullish/bearish/neutral)
9. THE Flutter App SHALL mostrar las fuentes del análisis de sentimiento (news, twitter, reddit)
10. THE Flutter App SHALL proporcionar fallback automático a análisis técnico si la IA falla

### Requirement 12: Estado y Monitoreo de IA

**User Story:** Como usuario, quiero monitorear el estado de los servicios de IA y el consumo de recursos para entender la disponibilidad y costos.

#### Acceptance Criteria

1. THE Flutter App SHALL obtener el estado de IA mediante `/api/v1/ai/status`
2. THE Flutter App SHALL mostrar si el LLM está habilitado y operacional
3. THE Flutter App SHALL mostrar el proveedor y modelo de IA actualmente en uso
4. THE Flutter App SHALL mostrar el número de llamadas realizadas hoy vs límite diario
5. THE Flutter App SHALL mostrar el estado del análisis de sentimiento y sus fuentes
6. THE Flutter App SHALL mostrar el presupuesto diario y gasto actual de IA
7. THE Flutter App SHALL mostrar indicadores visuales del estado (operacional/error/límite alcanzado)
8. THE Flutter App SHALL actualizar el estado automáticamente cada 30 segundos
9. WHEN se alcanza el 80% del presupuesto diario, THE Flutter App SHALL mostrar advertencia
10. WHEN se alcanza el límite de llamadas, THE Flutter App SHALL informar al usuario

### Requirement 13: Gestión de Costos de IA

**User Story:** Como usuario, quiero ver y controlar los costos de IA para mantener el presupuesto bajo control.

#### Acceptance Criteria

1. THE Flutter App SHALL obtener costos de IA mediante `/api/v1/ai/costs`
2. THE Flutter App SHALL mostrar el costo total del día actual
3. THE Flutter App SHALL mostrar el desglose de costos por proveedor (Google, OpenAI, Anthropic)
4. THE Flutter App SHALL mostrar el número total de llamadas realizadas
5. THE Flutter App SHALL mostrar el costo total del mes actual
6. THE Flutter App SHALL mostrar la proyección de costo mensual
7. THE Flutter App SHALL mostrar el costo promedio por llamada
8. THE Flutter App SHALL mostrar progreso visual del presupuesto diario usado
9. THE Flutter App SHALL permitir ver historial de costos (opcional)
10. THE Flutter App SHALL alertar cuando se acerque al límite de presupuesto

### Requirement 14: Notificaciones Inteligentes con IA

**User Story:** Como trader, quiero recibir notificaciones de trading con explicaciones generadas por IA para entender mejor las decisiones automatizadas.

#### Acceptance Criteria

1. THE Flutter App SHALL obtener notificaciones mediante `/api/v1/ai/notifications`
2. THE Flutter App SHALL mostrar lista de notificaciones de trading con IA
3. THE Flutter App SHALL mostrar la explicación LLM para cada trade ejecutado
4. THE Flutter App SHALL mostrar el análisis de mercado que motivó la decisión
5. THE Flutter App SHALL mostrar la evaluación de riesgo de cada operación
6. THE Flutter App SHALL mostrar el timestamp de cada notificación
7. THE Flutter App SHALL permitir ver detalles completos de cada notificación
8. THE Flutter App SHALL marcar notificaciones como leídas/no leídas
9. THE Flutter App SHALL mostrar badge con número de notificaciones no leídas
10. THE Flutter App SHALL actualizar notificaciones en tiempo real

### Requirement 15: Configuración y Preferencias de IA

**User Story:** Como usuario, quiero configurar las preferencias de IA según mis necesidades y presupuesto.

#### Acceptance Criteria

1. THE Flutter App SHALL permitir habilitar/deshabilitar análisis con IA
2. THE Flutter App SHALL permitir habilitar/deshabilitar análisis de sentimiento
3. THE Flutter App SHALL permitir seleccionar proveedor de IA preferido (si disponible)
4. THE Flutter App SHALL permitir configurar presupuesto diario de IA
5. THE Flutter App SHALL permitir configurar límite de llamadas diarias
6. THE Flutter App SHALL permitir configurar duración de caché para análisis
7. THE Flutter App SHALL persistir configuraciones usando SharedPreferences
8. THE Flutter App SHALL aplicar cambios de configuración inmediatamente
9. THE Flutter App SHALL validar configuraciones antes de guardar
10. THE Flutter App SHALL mostrar configuración actual en pantalla de settings
