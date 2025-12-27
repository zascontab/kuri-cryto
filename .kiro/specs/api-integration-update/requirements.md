# Requirements Document - API Integration Update

## Introduction

La aplicación Flutter actualmente consume las APIs del backend de trading, pero debido a actualizaciones recientes en el backend (versión 3.1), algunos endpoints y estructuras de datos han cambiado. Este spec define los ajustes necesarios para que la aplicación Flutter consuma correctamente las APIs actualizadas, incluyendo:

- Nuevos endpoints del AI Bot (comprehensive analysis, dynamic config)
- Nuevas herramientas MCP (mark_price, index_price, account_info, risk_state)
- Cambios en la estructura de respuestas
- Mejoras en el manejo de errores

## Glossary

- **MCP Server**: Model Context Protocol Server - servidor que expone 67 herramientas de trading via JSON-RPC 2.0
- **AI Bot**: Bot de trading automatizado con inteligencia artificial
- **Comprehensive Analysis**: Análisis completo de mercado con todos los indicadores, escenarios y recomendaciones
- **Dynamic Config**: Configuración dinámica del bot sin necesidad de reiniciar
- **Futures**: Contratos de futuros perpetuos en KuCoin
- **Gateway**: API Gateway en puerto 9090 que enruta a MCP Server (10600) y Scalping API (8081)
- **JSON-RPC 2.0**: Protocolo de llamada a procedimientos remotos usado por MCP Server
- **Flutter App**: Aplicación móvil Flutter que consume las APIs

## Requirements

### Requirement 1: Comprehensive Analysis Integration

**User Story:** Como trader, quiero obtener un análisis completo del mercado con todos los indicadores, escenarios y recomendaciones en una sola llamada, para tomar decisiones informadas rápidamente.

#### Acceptance Criteria

1. WHEN THE Flutter_App solicita análisis comprehensivo, THE System SHALL enviar una petición POST a `/api/v1/ai-bot/comprehensive-analysis` en el MCP_Server
2. WHEN THE System recibe la respuesta del análisis, THE Flutter_App SHALL parsear correctamente todos los campos incluyendo price_data, technical_indicators, scenarios, y recommendation
3. WHEN THE análisis incluye múltiples timeframes, THE Flutter_App SHALL mostrar los indicadores para cada timeframe (1m, 5m, 15m, 1h, 4h)
4. WHEN THE análisis incluye escenarios (bullish, bearish, neutral), THE Flutter_App SHALL calcular y mostrar las probabilidades de cada escenario
5. WHEN THE análisis falla, THE System SHALL manejar el error apropiadamente y mostrar un mensaje descriptivo al usuario

### Requirement 2: Dynamic Bot Configuration

**User Story:** Como trader, quiero cambiar la configuración del bot (modo dry run/live, umbral de confianza, tamaño de trade) sin reiniciar el servidor, para ajustar la estrategia en tiempo real.

#### Acceptance Criteria

1. WHEN THE Flutter_App solicita la configuración actual, THE System SHALL enviar GET a `/api/v1/ai-bot/config` en el MCP_Server
2. WHEN THE usuario actualiza la configuración, THE System SHALL detener el bot primero si está corriendo
3. WHEN THE System envía la nueva configuración, THE MCP_Server SHALL validar los parámetros (confidence_threshold entre 0.5-1.0, leverage entre 1-100)
4. WHEN THE configuración se actualiza exitosamente, THE System SHALL retornar la configuración completa actualizada
5. WHEN THE usuario intenta cambiar configuración con el bot corriendo, THE System SHALL mostrar error "cannot update config while bot is running"

### Requirement 3: New MCP Tools Integration

**User Story:** Como desarrollador, quiero integrar las 4 nuevas herramientas MCP (mark_price, index_price, account_info, risk_state) para proporcionar información más completa a los usuarios.

#### Acceptance Criteria

1. WHEN THE Flutter_App solicita mark price, THE System SHALL llamar a la herramienta `get_mark_price` via JSON-RPC 2.0
2. WHEN THE Flutter_App solicita index price, THE System SHALL llamar a la herramienta `get_index_price` via JSON-RPC 2.0
3. WHEN THE Flutter_App solicita información de cuenta, THE System SHALL llamar a la herramienta `get_account_info` via JSON-RPC 2.0
4. WHEN THE Flutter_App solicita estado de riesgo, THE System SHALL llamar a la herramienta `get_risk_state` via JSON-RPC 2.0
5. WHEN THE herramienta retorna datos, THE Flutter_App SHALL parsear correctamente la estructura de respuesta JSON-RPC 2.0

### Requirement 4: Enhanced Error Handling

**User Story:** Como usuario, quiero recibir mensajes de error claros y accionables cuando algo falla, para entender qué salió mal y cómo solucionarlo.

#### Acceptance Criteria

1. WHEN THE MCP_Server retorna error JSON-RPC, THE System SHALL extraer el mensaje de error del campo `error.message`
2. WHEN THE error incluye código de error, THE System SHALL mapear códigos conocidos a mensajes amigables
3. WHEN THE error es de autenticación (401), THE System SHALL mostrar "Sesión expirada, por favor inicia sesión nuevamente"
4. WHEN THE error es de balance insuficiente, THE System SHALL mostrar el balance requerido vs disponible
5. WHEN THE error es de red, THE System SHALL sugerir verificar la conexión y reintentar

### Requirement 5: Futures Position Management Update

**User Story:** Como trader de futuros, quiero ver y cerrar mis posiciones con información actualizada de mark price y liquidation price, para gestionar mi riesgo efectivamente.

#### Acceptance Criteria

1. WHEN THE Flutter_App obtiene posiciones, THE System SHALL incluir mark_price actualizado en tiempo real
2. WHEN THE posición incluye liquidation_price, THE Flutter_App SHALL mostrar una alerta si el precio actual está cerca del precio de liquidación
3. WHEN THE usuario cierra una posición, THE System SHALL usar la herramienta `close_futures_position` que cierra TODA la posición en una llamada
4. WHEN THE posición se cierra exitosamente, THE System SHALL retornar el PnL total (realizado + no realizado)
5. WHEN THE usuario intenta cerrar una posición que no existe, THE System SHALL mostrar "No open position found"

### Requirement 6: API Configuration Validation

**User Story:** Como desarrollador, quiero validar que todas las URLs de API estén correctamente configuradas, para evitar errores de conexión en producción.

#### Acceptance Criteria

1. WHEN THE Flutter_App inicia, THE System SHALL validar que ApiConfig.mcpDirectUrl apunte a `http://192.168.1.6:10600`
2. WHEN THE Flutter_App inicia, THE System SHALL validar que ApiConfig.gatewayBaseUrl apunte a `http://192.168.1.6:9090`
3. WHEN THE Flutter_App hace llamadas al AI Bot, THE System SHALL usar mcpDirectUrl (puerto 10600)
4. WHEN THE Flutter_App hace llamadas a herramientas MCP, THE System SHALL usar gatewayBaseUrl con path `/api/mcp/tools/execute`
5. WHEN THE configuración de URL es incorrecta, THE System SHALL fallar rápidamente con mensaje descriptivo

### Requirement 7: Bot Status Enhanced Monitoring

**User Story:** Como trader, quiero ver el estado detallado del bot incluyendo uptime, número de análisis, trades ejecutados y errores, para monitorear su desempeño.

#### Acceptance Criteria

1. WHEN THE Flutter_App solicita estado del bot, THE System SHALL incluir campos running, paused, emergency_stop
2. WHEN THE bot está corriendo, THE System SHALL mostrar uptime_seconds, started_at, y last_analysis_at
3. WHEN THE bot ha ejecutado trades, THE System SHALL mostrar analysis_count, execution_count, y daily_trades
4. WHEN THE bot tiene errores, THE System SHALL mostrar error_count y consecutive_errors
5. WHEN THE bot alcanza límites diarios, THE System SHALL mostrar daily_loss y compararlo con max_daily_loss_usd

### Requirement 8: Comprehensive Analysis Model

**User Story:** Como desarrollador, quiero un modelo de datos robusto para el análisis comprehensivo, para manejar toda la información de manera tipo-segura.

#### Acceptance Criteria

1. WHEN THE System crea el modelo ComprehensiveAnalysis, THE modelo SHALL incluir symbol, exchange, timestamp
2. WHEN THE modelo incluye price_data, THE System SHALL parsear last, bid, ask, volume, change_24h
3. WHEN THE modelo incluye technical_indicators, THE System SHALL parsear RSI, MACD, Bollinger Bands para cada timeframe
4. WHEN THE modelo incluye scenarios, THE System SHALL parsear bullish, bearish, neutral con sus probabilidades
5. WHEN THE modelo incluye recommendation, THE System SHALL parsear action, confidence, entry, stop_loss, take_profit

### Requirement 9: Service Layer Refactoring

**User Story:** Como desarrollador, quiero servicios bien organizados que separen responsabilidades, para mantener el código limpio y testeable.

#### Acceptance Criteria

1. WHEN THE AiBotService maneja comprehensive analysis, THE servicio SHALL tener un método dedicado `getComprehensiveAnalysis()`
2. WHEN THE AiBotService maneja configuración dinámica, THE servicio SHALL tener métodos `getConfig()` y `updateConfig()`
3. WHEN THE FuturesService obtiene mark price, THE servicio SHALL usar el método `getMarkPrice()` que llama a la herramienta MCP
4. WHEN THE FuturesService obtiene index price, THE servicio SHALL usar el método `getIndexPrice()` que llama a la herramienta MCP
5. WHEN THE MCPService maneja errores JSON-RPC, THE servicio SHALL extraer correctamente el mensaje del campo `error.message`

### Requirement 10: Testing and Validation

**User Story:** Como desarrollador, quiero tests que validen la integración con las APIs actualizadas, para asegurar que todo funciona correctamente.

#### Acceptance Criteria

1. WHEN THE test solicita comprehensive analysis, THE test SHALL verificar que todos los campos requeridos están presentes
2. WHEN THE test actualiza configuración del bot, THE test SHALL verificar que la validación funciona correctamente
3. WHEN THE test llama a nuevas herramientas MCP, THE test SHALL verificar que el formato JSON-RPC es correcto
4. WHEN THE test simula errores, THE test SHALL verificar que los mensajes de error son descriptivos
5. WHEN THE test verifica URLs, THE test SHALL confirmar que apuntan a los endpoints correctos
