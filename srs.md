

# Documento de Especificación de Requisitos de Software (SRS) para Cliente Flutter de Trading MCP

## 1. Introducción

### 1.1 Propósito

Este SRS define los requisitos para el desarrollo de un cliente móvil Flutter que actúa como interfaz frontend para el servidor backend Trading MCP (v1.0.0 en Golang, 100% operativo en producción), enfocado en trading automatizado de criptomonedas con scalping de alta frecuencia. La app permite a usuarios monitorear portafolios, ejecutar órdenes de scalping con leverage, gestionar estrategias automatizadas y visualizar datos de mercado en tiempo real, priorizando usabilidad cross-platform para Android/iOS.

El backend expone **65 herramientas MCP validadas** y una **REST API completa** en puerto 8081, con soporte para KuCoin (SPOT y Futures) vía GoCryptoTrader (GCT). El sistema incluye un **Scalping Engine** con 5 estrategias activas (RSI, MACD, Bollinger, Volume, AI) y capacidades de backtesting.

Este documento sigue estándares IEEE 830-1998 adaptados para mobile, con énfasis en integración REST/WebSocket al backend y desarrollo incremental en 4 fases (8 semanas) alineado con el roadmap del backend.

### 1.2 Alcance

La app cubre:
- **Dashboard de Trading:** Visualización de métricas en tiempo real (P&L, win rate, posiciones activas)
- **Gestión de Posiciones:** Monitoreo de posiciones abiertas con SL/TP dinámicos
- **Control de Estrategias:** Activación/desactivación de 5 estrategias de scalping
- **Gestión de Riesgo:** Monitor de drawdown, exposición y kill switch
- **Ejecución de Trades:** Órdenes spot/futures con validaciones automáticas
- **Análisis Técnico:** 17 indicadores técnicos (RSI, MACD, Bollinger, ATR, etc.)
- **Reportes y Métricas:** Exportación de datos y visualización de performance

**Excluye:** Desarrollo backend, integración directa con exchanges (usa GCT como intermediario), trading manual sin validaciones de riesgo.

**Plataformas:** Android 8+ e iOS 12+, no web/desktop en v1.0.

**Fases de Desarrollo:**
- **Fase 0 (Week 1-2):** Dashboard básico + Risk Monitor + Kill Switch
- **Fase 1 (Week 3-4):** Multi-timeframe analysis + Backtesting UI
- **Fase 2 (Week 5-6):** Performance charts + Execution monitoring
- **Fase 3 (Week 7-8):** Alerts + Optimization + Production features

### 1.3 Audiencia

**Usuarios Objetivo:**
- **Traders Activos:** Usuarios que ejecutan scalping de alta frecuencia con leverage
- **Traders Automatizados:** Usuarios que configuran y monitorean bots de trading
- **Gestores de Riesgo:** Usuarios que necesitan control estricto de drawdown y exposición

**Perfil Técnico:** Conocimiento básico de trading crypto, familiaridad con conceptos de leverage, stop-loss y take-profit. No requiere conocimientos de programación.

**Región:** Inicialmente LATAM, con soporte para conexiones 3G/4G.

### 1.4 Definiciones y Acrónimos

- **MCP:** Model Context Protocol - Protocolo para herramientas JSON-RPC
- **GCT:** GoCryptoTrader - Engine de trading multi-exchange
- **Scalping:** Trading de alta frecuencia con posiciones de corta duración (minutos)
- **HFT:** High-Frequency Trading - Trading de muy alta frecuencia
- **P&L:** Profit and Loss - Ganancias y pérdidas
- **SL/TP:** Stop Loss / Take Profit - Órdenes de protección
- **Drawdown:** Pérdida máxima desde un pico de capital
- **Kill Switch:** Mecanismo de emergencia para detener todo el trading
- **Risk Sentinel:** Sistema de monitoreo y control de riesgo
- **Position Manager:** Sistema de gestión de posiciones abiertas
- **MTF:** Multi-Timeframe - Análisis de múltiples marcos temporales
- **REST API:** Representational State Transfer - API HTTP
- **WebSocket:** Protocolo de comunicación bidireccional en tiempo real
- **Flutter:** Framework cross-platform en Dart
- **Riverpod:** State management para Flutter


### 1.5 Visión General

El documento está estructurado en:
1. **Introducción:** Contexto y alcance
2. **Descripción General:** Perspectiva del producto y funciones principales
3. **Requisitos Específicos:** Requisitos funcionales y no funcionales detallados
4. **Información de Soporte:** Diagramas y matrices de trazabilidad

**Metodología de Desarrollo:**
- **Framework:** Flutter 3.0+ con Dart 3.0+
- **State Management:** Riverpod para gestión de estado reactivo
- **HTTP Client:** Dio para comunicación REST API
- **WebSocket:** web_socket_channel para actualizaciones en tiempo real
- **Storage:** Hive para caché local y modo offline
- **Charts:** fl_chart y syncfusion_flutter_charts para visualizaciones

**Integración Backend:**
- **REST API Base:** `http://localhost:8081/api/v1/scalping`
- **WebSocket:** `ws://localhost:8081/ws`
- **Protocolo:** JSON sobre HTTP/WebSocket
- **Autenticación:** JWT (Fase 3)

## 2. Descripción General

### 2.1 Perspectiva del Producto

La aplicación Flutter es el **frontend móvil** del Trading MCP Server, transformando un sistema backend complejo en una interfaz intuitiva para trading automatizado de criptomonedas.

**Diferenciadores Clave:**
1. **Safety-First:** Sistema de Risk Sentinel con kill switch y límites automáticos
2. **Scalping HFT:** Optimizado para trading de alta frecuencia con latencia <100ms
3. **Multi-Estrategia:** 5 estrategias simultáneas con pesos dinámicos
4. **Auto SL/TP:** Gestión automática de stop-loss y take-profit con trailing
5. **Real-Time:** Actualizaciones WebSocket con latencia <1s

**Arquitectura:**
```
Flutter App (Mobile)
    ↓ REST API / WebSocket
Trading MCP Server (Go)
    ↓ gRPC
GoCryptoTrader
    ↓ REST/WebSocket
KuCoin Exchange
```

**Ventaja Competitiva:** A diferencia de apps genéricas de trading, esta app integra validaciones automáticas de riesgo, conversión automática spot/futures, y backtesting integrado.

### 2.2 Funciones del Producto

#### Funciones Core (Fase 0 - Disponibles Ahora)

1. **Dashboard de Trading**
   - Visualización de estado del sistema (running, uptime, health)
   - Métricas clave: Total P&L, Win Rate, Posiciones Activas, Latencia
   - Control de engine (Start/Stop)

2. **Gestión de Posiciones**
   - Lista de posiciones abiertas con detalles (entry, current, P&L)
   - Historial de posiciones cerradas
   - Cierre manual de posiciones

3. **Control de Estrategias**
   - Lista de 5 estrategias disponibles (RSI, MACD, Bollinger, Volume, AI)
   - Activación/desactivación individual
   - Visualización de performance por estrategia
   - Configuración de parámetros

4. **Gestión de Riesgo**
   - Visualización de límites de riesgo actuales
   - Actualización de parámetros de riesgo
   - Monitor de exposición total y por símbolo

5. **Monitoreo de Ejecución**
   - Estadísticas de latencia (p50, p95, p99)
   - Historial de ejecuciones
   - Métricas de slippage

6. **Gestión de Pares**
   - Agregar/remover pares de trading
   - Configuración por par

#### Funciones Avanzadas (Fases 1-3 - Planificadas)

7. **Risk Sentinel (Fase 0 - Week 1-2)**
   - Monitor de drawdown (diario, semanal, mensual)
   - Kill Switch con activación manual/automática
   - Visualización de modo de riesgo (Conservative, Normal, Aggressive)
   - Contador de pérdidas consecutivas

8. **Position Manager Avanzado (Fase 0 - Week 1-2)**
   - Edición de SL/TP en posiciones abiertas
   - Mover SL a breakeven automáticamente
   - Activar trailing stop
   - Detección de conflictos entre posiciones

9. **Análisis Multi-Timeframe (Fase 1 - Week 3-4)**
   - Análisis simultáneo de 1m, 3m, 5m, 15m
   - Consenso de señales entre timeframes
   - Visualización de indicadores por timeframe

10. **Backtesting (Fase 1 - Week 3-4)**
    - Configuración de backtests con datos históricos
    - Visualización de resultados (P&L, win rate, drawdown)
    - Comparación de estrategias

11. **Optimización de Parámetros (Fase 3 - Week 7-8)**
    - Grid search para optimización
    - Walk-forward optimization
    - Validación out-of-sample

12. **Sistema de Alertas (Fase 3 - Week 7-8)**
    - Configuración de alertas personalizadas
    - Notificaciones push vía Telegram
    - Historial de alertas


### 2.3 Clases de Usuarios y Características

#### Usuario Trader (Rol Principal)
- **Acceso:** Todas las funciones de trading y monitoreo
- **Capacidades:**
  - Iniciar/detener scalping engine
  - Activar/desactivar estrategias
  - Configurar parámetros de riesgo
  - Monitorear posiciones en tiempo real
  - Cerrar posiciones manualmente
  - Activar kill switch en emergencias
  - Exportar reportes

#### Usuario Administrador (Futuro - Fase 3)
- **Acceso:** Funciones de trader + administración
- **Capacidades adicionales:**
  - Gestión de múltiples cuentas
  - Configuración avanzada del sistema
  - Acceso a logs y auditoría
  - Gestión de API keys

### 2.4 Entorno Operativo

**Plataformas Móviles:**
- Android 8.0 (API 26) o superior
- iOS 12.0 o superior

**Tecnologías Flutter:**
- Flutter SDK: 3.0+
- Dart: 3.0+
- Riverpod: 2.4+ (state management)
- Dio: 5.4+ (HTTP client)
- web_socket_channel: 2.4+ (WebSocket)
- Hive: 2.2+ (local storage)
- fl_chart: 0.65+ (charts)

**Backend Dependencies:**
- Trading MCP Server: v1.0.0 (puerto 8081)
- GoCryptoTrader: v0.1 (puerto 9052)
- KuCoin API: REST + WebSocket

**Conectividad:**
- Internet: Requerido para trading en vivo
- Ancho de banda mínimo: 3G (1 Mbps)
- Latencia recomendada: <200ms
- Modo offline: Disponible para visualización de datos cacheados

**Permisos Requeridos:**
- Internet (obligatorio)
- Notificaciones (opcional)
- Almacenamiento (para caché y exportación)

### 2.5 Asunciones y Dependencias

**Asunciones:**
1. Backend Trading MCP Server está operativo y accesible
2. Usuario tiene cuenta activa en KuCoin con API keys configuradas
3. Usuario tiene conocimientos básicos de trading crypto
4. Conexión a internet estable durante operaciones de trading
5. Dispositivo móvil con recursos suficientes (2GB RAM mínimo)

**Dependencias Críticas:**
1. **Backend MCP Server:** Debe estar corriendo en puerto 8081
2. **GoCryptoTrader:** Debe estar conectado a KuCoin
3. **KuCoin API:** Debe estar operativa y accesible
4. **Credenciales:** API keys válidas configuradas en backend

**Riesgos y Mitigaciones:**
- **Latencia de red:** Retry logic con exponential backoff
- **Pérdida de conexión:** Modo offline con caché local
- **Errores de API:** Manejo de errores con mensajes claros
- **Rate limiting:** Respeto de límites de API con throttling

### 2.6 Escenarios Operativos

#### Escenario 1: Inicio de Scalping Bot
1. Usuario abre la app
2. Dashboard muestra estado del sistema (stopped)
3. Usuario revisa métricas actuales (balance, exposición)
4. Usuario presiona botón "Start Engine"
5. Sistema inicia scalping engine
6. Dashboard actualiza estado a "running"
7. Usuario ve posiciones abiertas en tiempo real vía WebSocket

#### Escenario 2: Gestión de Riesgo en Emergencia
1. Usuario observa drawdown diario alcanzando 4.5%
2. Sistema muestra alerta de advertencia
3. Usuario decide activar kill switch
4. Sistema confirma acción con diálogo
5. Usuario confirma
6. Sistema detiene todo el trading inmediatamente
7. Todas las posiciones se cierran automáticamente
8. Dashboard muestra "Kill Switch Active"

#### Escenario 3: Configuración de Estrategia
1. Usuario navega a pantalla de estrategias
2. Ve lista de 5 estrategias con performance
3. Usuario selecciona "RSI Scalping"
4. Ve detalles: 50 trades, 65% win rate, $45.50 P&L
5. Usuario presiona "Configure"
6. Ajusta parámetros: RSI period=14, oversold=25
7. Guarda configuración
8. Sistema actualiza estrategia sin reiniciar engine

#### Escenario 4: Monitoreo de Posición
1. Usuario recibe notificación: "Position opened: DOGE-USDT LONG"
2. Abre app y navega a posiciones
3. Ve posición con entry $0.08500, current $0.08650
4. P&L muestra +$15.00 (verde)
5. Usuario decide mover SL a breakeven
6. Presiona "Move to Breakeven"
7. Sistema actualiza SL a $0.08500
8. Confirmación visual con haptic feedback

#### Escenario 5: Análisis de Performance
1. Usuario navega a pantalla de métricas
2. Ve gráfico de P&L diario
3. Filtra por estrategia "MACD Scalping"
4. Ve 20 trades, 60% win rate
5. Exporta reporte en PDF
6. Comparte vía email

## 3. Requisitos Específicos

### 3.1 Requisitos Funcionales

Requisitos organizados por fase de desarrollo, priorizados y trazables a endpoints del backend.

#### 3.1.1 Dashboard y Control del Sistema (Fase 0 - Prioridad CRÍTICA)

**REQ-FR-DASH-01:** Sistema de Status
- **Descripción:** Visualizar estado del scalping engine (running/stopped, uptime, health)
- **Endpoint:** `GET /api/v1/scalping/status`
- **UI:** Card principal con indicador visual (verde/rojo)
- **Actualización:** Cada 5 segundos

**REQ-FR-DASH-02:** Métricas Principales
- **Descripción:** Mostrar métricas clave en dashboard
  - Total P&L (con color verde/rojo)
  - Win Rate (porcentaje)
  - Posiciones Activas (contador)
  - Latencia Promedio (ms)
- **Endpoint:** `GET /api/v1/scalping/metrics`
- **UI:** Grid de 4 cards con iconos
- **Actualización:** Cada 5 segundos

**REQ-FR-DASH-03:** Control de Engine
- **Descripción:** Botones para iniciar/detener scalping engine
- **Endpoints:** 
  - `POST /api/v1/scalping/start`
  - `POST /api/v1/scalping/stop`
- **UI:** Botón flotante con confirmación
- **Validación:** Confirmar antes de detener si hay posiciones abiertas

**REQ-FR-DASH-04:** Health Check
- **Descripción:** Indicador de salud del sistema
- **Endpoint:** `GET /api/v1/scalping/health`
- **UI:** Badge en AppBar (healthy/degraded/down)
- **Actualización:** Cada 10 segundos

#### 3.1.2 Gestión de Posiciones (Fase 0 - Prioridad CRÍTICA)

**REQ-FR-POS-01:** Lista de Posiciones Abiertas
- **Descripción:** Mostrar todas las posiciones abiertas con detalles
  - Symbol, Side (LONG/SHORT)
  - Entry Price, Current Price
  - Size, Leverage
  - Unrealized P&L (con color)
  - Stop Loss, Take Profit
  - Strategy, Open Time
- **Endpoint:** `GET /api/v1/scalping/positions`
- **UI:** ListView con PositionCard expandible
- **Actualización:** WebSocket `position_update`

**REQ-FR-POS-02:** Historial de Posiciones
- **Descripción:** Ver posiciones cerradas con filtros
- **Endpoint:** `GET /api/v1/scalping/positions/history?limit=100`
- **UI:** ListView con paginación
- **Filtros:** Fecha, símbolo, estrategia

**REQ-FR-POS-03:** Cierre Manual de Posición
- **Descripción:** Cerrar posición manualmente
- **Endpoint:** `POST /api/v1/positions/:id/close`
- **UI:** Botón "Close" con confirmación
- **Validación:** Confirmar con diálogo mostrando P&L actual

**REQ-FR-POS-04:** Edición de SL/TP (Fase 0 - Week 1-2)
- **Descripción:** Modificar stop-loss y take-profit de posición abierta
- **Endpoint:** `PUT /api/v1/positions/:id/sltp`
- **UI:** Diálogo con inputs numéricos
- **Validación:** SL < Entry < TP para LONG, TP < Entry < SL para SHORT

**REQ-FR-POS-05:** Move to Breakeven (Fase 0 - Week 1-2)
- **Descripción:** Mover SL al precio de entrada
- **Endpoint:** `POST /api/v1/positions/:id/breakeven`
- **UI:** Botón "Breakeven" en PositionCard
- **Feedback:** Haptic + toast con nuevo SL

**REQ-FR-POS-06:** Trailing Stop (Fase 0 - Week 1-2)
- **Descripción:** Activar trailing stop con distancia configurable
- **Endpoint:** `POST /api/v1/positions/:id/trailing-stop`
- **UI:** Toggle + slider para distancia (0.1% - 1.0%)
- **Indicador:** Badge "Trailing" en posición

#### 3.1.3 Control de Estrategias (Fase 0 - Prioridad ALTA)

**REQ-FR-STRAT-01:** Lista de Estrategias
- **Descripción:** Mostrar las 5 estrategias disponibles
  - RSI Scalping
  - MACD Scalping
  - Bollinger Scalping
  - Volume Scalping
  - AI Scalping
- **Endpoint:** `GET /api/v1/scalping/strategies`
- **UI:** ListView con StrategyCard
- **Info:** Nombre, estado (active/inactive), weight, performance

**REQ-FR-STRAT-02:** Activar/Desactivar Estrategia
- **Descripción:** Toggle para habilitar/deshabilitar estrategia
- **Endpoints:**
  - `POST /api/v1/scalping/strategies/:name/start`
  - `POST /api/v1/scalping/strategies/:name/stop`
- **UI:** Switch en StrategyCard
- **Feedback:** Animación + toast

**REQ-FR-STRAT-03:** Detalles de Estrategia
- **Descripción:** Ver performance detallada de estrategia
  - Total Trades, Win Rate
  - Total P&L, Avg Win/Loss
  - Sharpe Ratio, Max Drawdown
  - Profit Factor
- **Endpoint:** `GET /api/v1/scalping/strategies/:name`
- **UI:** Pantalla de detalles con gráficos

**REQ-FR-STRAT-04:** Configuración de Estrategia
- **Descripción:** Modificar parámetros de estrategia
- **Endpoint:** `PUT /api/v1/scalping/strategies/:name/config`
- **UI:** Formulario con validaciones
- **Parámetros:** Específicos por estrategia (RSI period, MACD periods, etc.)

**REQ-FR-STRAT-05:** Performance por Estrategia
- **Descripción:** Gráfico de P&L por estrategia
- **Endpoint:** `GET /api/v1/scalping/strategies/:name/performance`
- **UI:** Line chart con fl_chart
- **Período:** Diario, semanal, mensual

#### 3.1.4 Gestión de Riesgo (Fase 0 - Prioridad CRÍTICA)

**REQ-FR-RISK-01:** Visualización de Límites
- **Descripción:** Mostrar límites de riesgo actuales
  - Max Position Size (USD)
  - Max Total Exposure (USD)
  - Stop Loss % / Take Profit %
  - Max Daily Loss (USD)
  - Max Consecutive Losses
- **Endpoint:** `GET /api/v1/scalping/risk/limits`
- **UI:** Card con lista de límites

**REQ-FR-RISK-02:** Actualización de Límites
- **Descripción:** Modificar parámetros de riesgo
- **Endpoint:** `PUT /api/v1/scalping/risk/limits`
- **UI:** Formulario con sliders y validaciones
- **Validación:** Confirmar cambios con diálogo

**REQ-FR-RISK-03:** Monitor de Exposición
- **Descripción:** Visualizar exposición actual vs máxima
  - Current Exposure (USD)
  - Max Exposure (USD)
  - Exposure % (barra de progreso)
  - Available Exposure (USD)
- **Endpoint:** `GET /api/v1/scalping/risk/exposure`
- **UI:** Card con progress bar
- **Color:** Verde (<50%), Amarillo (50-80%), Rojo (>80%)

**REQ-FR-RISK-04:** Risk Sentinel State (Fase 0 - Week 1-2)
- **Descripción:** Monitor completo del Risk Sentinel
  - Drawdown diario/semanal/mensual
  - Exposición total y por símbolo
  - Pérdidas consecutivas
  - Modo de riesgo (Conservative/Normal/Aggressive)
  - Estado del kill switch
- **Endpoint:** `GET /api/v1/risk/sentinel/state`
- **UI:** Card expandible con detalles
- **Actualización:** Cada 5 segundos

**REQ-FR-RISK-05:** Kill Switch (Fase 0 - Week 1-2)
- **Descripción:** Botón de emergencia para detener todo el trading
- **Endpoints:**
  - `POST /api/v1/risk/sentinel/kill-switch` (activar)
  - `DELETE /api/v1/risk/sentinel/kill-switch` (desactivar)
- **UI:** Botón rojo prominente con confirmación
- **Confirmación:** Diálogo con advertencia clara
- **Feedback:** Haptic fuerte + notificación

#### 3.1.5 Monitoreo de Ejecución (Fase 0 - Prioridad MEDIA)

**REQ-FR-EXEC-01:** Estadísticas de Latencia
- **Descripción:** Mostrar métricas de latencia de ejecución
  - Avg Latency (ms)
  - P50, P95, P99 Latency
  - Max Latency
- **Endpoint:** `GET /api/v1/scalping/execution/latency`
- **UI:** Card con gráfico de barras

**REQ-FR-EXEC-02:** Historial de Ejecuciones
- **Descripción:** Lista de órdenes ejecutadas
- **Endpoint:** `GET /api/v1/scalping/execution/history?limit=50`
- **UI:** ListView con detalles de orden
- **Info:** Order ID, Symbol, Side, Price, Status, Latency

#### 3.1.6 Gestión de Pares (Fase 0 - Prioridad BAJA)

**REQ-FR-PAIR-01:** Agregar Par de Trading
- **Descripción:** Añadir nuevo par al scalping engine
- **Endpoint:** `POST /api/v1/scalping/pairs/add`
- **UI:** Diálogo con selector de exchange y par
- **Validación:** Verificar que el par existe en el exchange

**REQ-FR-PAIR-02:** Remover Par de Trading
- **Descripción:** Eliminar par del scalping engine
- **Endpoint:** `POST /api/v1/scalping/pairs/remove`
- **UI:** Botón "Remove" con confirmación
- **Validación:** No permitir si hay posiciones abiertas en ese par


#### 3.1.7 Análisis Multi-Timeframe (Fase 1 - Week 3-4)

**REQ-FR-MTF-01:** Análisis de Múltiples Timeframes
- **Descripción:** Analizar 1m, 3m, 5m, 15m simultáneamente
- **Endpoint:** `POST /api/v1/analysis/multi-timeframe`
- **UI:** Tabs para cada timeframe con indicadores
- **Indicadores:** RSI, MACD, Bollinger por timeframe

**REQ-FR-MTF-02:** Consenso de Señales
- **Descripción:** Mostrar consenso entre timeframes
- **UI:** Badge con dirección (LONG/SHORT/NEUTRAL) y confianza %
- **Visualización:** Tabla de confirmación por timeframe

#### 3.1.8 Backtesting (Fase 1 - Week 3-4)

**REQ-FR-BACK-01:** Configuración de Backtest
- **Descripción:** Formulario para configurar backtest
- **Endpoint:** `POST /api/v1/backtest/run`
- **Parámetros:** Symbol, strategy, date range, initial capital
- **UI:** Wizard de 3 pasos

**REQ-FR-BACK-02:** Resultados de Backtest
- **Descripción:** Visualizar resultados detallados
- **Endpoint:** `GET /api/v1/backtest/results/:id`
- **Métricas:** Total trades, win rate, P&L, Sharpe ratio, drawdown
- **UI:** Dashboard con gráficos y tabla de trades

#### 3.1.9 Alertas y Notificaciones (Fase 3 - Week 7-8)

**REQ-FR-ALERT-01:** Configuración de Alertas
- **Descripción:** Crear alertas personalizadas
- **Endpoint:** `POST /api/v1/alerts/configure`
- **Tipos:** Precio, drawdown, P&L, volumen
- **UI:** Formulario con reglas configurables

**REQ-FR-ALERT-02:** Historial de Alertas
- **Descripción:** Ver alertas disparadas
- **Endpoint:** `GET /api/v1/alerts/history`
- **UI:** ListView con filtros por severidad
- **Acciones:** Acknowledge, dismiss

**REQ-FR-ALERT-03:** Notificaciones Push
- **Descripción:** Recibir notificaciones en tiempo real
- **Integración:** Telegram bot
- **Eventos:** Position opened/closed, alert triggered, kill switch

#### 3.1.10 Optimización de Parámetros (Fase 3 - Week 7-8)

**REQ-FR-OPT-01:** Ejecutar Optimización
- **Descripción:** Grid search de parámetros
- **Endpoint:** `POST /api/v1/optimization/run`
- **UI:** Formulario con rangos de parámetros
- **Feedback:** Progress bar con tiempo estimado

**REQ-FR-OPT-02:** Resultados de Optimización
- **Descripción:** Ver mejores parámetros encontrados
- **Endpoint:** `GET /api/v1/optimization/results/:id`
- **UI:** Tabla ordenada por score
- **Acción:** Aplicar parámetros óptimos a estrategia

### 3.2 Requisitos No Funcionales

#### 3.2.1 Rendimiento (Prioridad CRÍTICA)

**REQ-NFR-PERF-01:** Tiempo de Carga Inicial
- **Métrica:** < 3 segundos en 4G
- **Medición:** Desde splash hasta dashboard funcional
- **Optimización:** Lazy loading de módulos

**REQ-NFR-PERF-02:** Actualización en Tiempo Real
- **Métrica:** < 1 segundo de latencia WebSocket
- **Medición:** Desde evento backend hasta UI update
- **Optimización:** Debouncing de actualizaciones

**REQ-NFR-PERF-03:** Consumo de Memoria
- **Métrica:** < 150 MB en uso normal
- **Medición:** Con 10 posiciones abiertas y 5 estrategias activas
- **Optimización:** Dispose de controllers, caché limitado

**REQ-NFR-PERF-04:** Consumo de Batería
- **Métrica:** < 5% por hora en background
- **Medición:** Con WebSocket activo
- **Optimización:** Reducir frecuencia de polling en background

**REQ-NFR-PERF-05:** Fluidez de UI
- **Métrica:** 60 FPS constantes
- **Medición:** Durante scroll y animaciones
- **Optimización:** Builders eficientes, evitar rebuilds innecesarios

#### 3.2.2 Usabilidad (Prioridad ALTA)

**REQ-NFR-USA-01:** Diseño Material 3
- **Estándar:** Material Design 3 guidelines
- **Componentes:** Cards, FABs, Bottom Navigation, Dialogs
- **Colores:** Verde (#4CAF50) para profits, Rojo (#F44336) para losses

**REQ-NFR-USA-02:** Navegación Intuitiva
- **Estructura:** Bottom Navigation con 5 tabs
  - Home (Dashboard)
  - Positions (Posiciones)
  - Strategies (Estrategias)
  - Risk (Riesgo)
  - More (Más opciones)
- **Gestos:** Swipe para refresh, long-press para opciones

**REQ-NFR-USA-03:** Accesibilidad
- **Estándar:** WCAG 2.1 Level AA
- **Contraste:** Mínimo 4.5:1 para texto
- **Tamaños:** Botones mínimo 48x48 dp
- **Screen readers:** Soporte completo

**REQ-NFR-USA-04:** Feedback Visual
- **Acciones:** Loading spinners, progress bars
- **Confirmaciones:** Toasts, snackbars
- **Errores:** Dialogs con mensajes claros
- **Haptic:** Feedback táctil en acciones críticas

**REQ-NFR-USA-05:** Onboarding
- **Primera vez:** Tour guiado de 5 pasos
- **Tooltips:** Ayuda contextual en funciones avanzadas
- **Help:** Sección de ayuda con FAQs

#### 3.2.3 Seguridad (Prioridad CRÍTICA)

**REQ-NFR-SEC-01:** Autenticación (Fase 3)
- **Método:** JWT tokens
- **Storage:** flutter_secure_storage
- **Refresh:** Automático antes de expiración
- **Biometría:** Face ID / Fingerprint opcional

**REQ-NFR-SEC-02:** Comunicación Segura
- **Protocolo:** HTTPS/TLS 1.3
- **WebSocket:** WSS (WebSocket Secure)
- **Certificados:** Certificate pinning

**REQ-NFR-SEC-03:** Datos Sensibles
- **API Keys:** Nunca almacenadas en app (solo en backend)
- **Credenciales:** Encriptadas en secure storage
- **Logs:** Sin información sensible

**REQ-NFR-SEC-04:** Validaciones
- **Input:** Sanitización de todos los inputs
- **Rangos:** Validación de límites (leverage, amounts)
- **Confirmaciones:** Doble confirmación en acciones críticas

#### 3.2.4 Disponibilidad (Prioridad ALTA)

**REQ-NFR-DISP-01:** Modo Offline
- **Funcionalidad:** Visualización de datos cacheados
- **Storage:** Hive para persistencia local
- **Sync:** Automático al reconectar
- **Limitaciones:** No trading en modo offline

**REQ-NFR-DISP-02:** Manejo de Errores
- **Network:** Retry con exponential backoff (3 intentos)
- **API:** Mensajes de error claros y accionables
- **Fallback:** Graceful degradation de funcionalidades

**REQ-NFR-DISP-03:** Reconexión Automática
- **WebSocket:** Reconexión automática con backoff
- **Estado:** Indicador de conexión en AppBar
- **Notificación:** Alert cuando se pierde conexión

#### 3.2.5 Escalabilidad (Prioridad MEDIA)

**REQ-NFR-SCAL-01:** Responsive Design
- **Dispositivos:** Phones (5" - 7"), Tablets (8" - 12")
- **Orientación:** Portrait y landscape
- **Adaptación:** Layouts diferentes por tamaño

**REQ-NFR-SCAL-02:** Internacionalización
- **Idiomas:** Español, Inglés, Portugués
- **Formato:** Números, fechas, monedas por locale
- **Implementación:** flutter_localizations

**REQ-NFR-SCAL-03:** Temas
- **Modos:** Light y Dark
- **Persistencia:** Preferencia guardada localmente
- **Automático:** Seguir sistema operativo

#### 3.2.6 Mantenibilidad (Prioridad ALTA)

**REQ-NFR-MANT-01:** Arquitectura Modular
- **Patrón:** Feature-first organization
- **Capas:** Presentation, Domain, Data
- **State:** Riverpod para gestión de estado

**REQ-NFR-MANT-02:** Testing
- **Coverage:** Mínimo 80%
- **Tipos:** Unit tests, Widget tests, Integration tests
- **CI/CD:** Tests automáticos en cada PR

**REQ-NFR-MANT-03:** Documentación
- **Código:** Comentarios en funciones complejas
- **API:** Documentación de servicios
- **README:** Guía de setup y desarrollo

**REQ-NFR-MANT-04:** Logging
- **Niveles:** Debug, Info, Warning, Error
- **Destino:** Console en dev, archivo en prod
- **Formato:** Estructurado con timestamps


### 3.3 Requisitos de Interfaz Externa

#### 3.3.1 Interfaz de Usuario

**REQ-INT-UI-01:** Diseño Touch-Friendly
- Botones mínimo 48x48 dp
- Espaciado adecuado entre elementos (8dp mínimo)
- Gestos estándar (tap, long-press, swipe)

**REQ-INT-UI-02:** Temas
- Light mode (fondo blanco, texto oscuro)
- Dark mode (fondo oscuro, texto claro)
- Colores semánticos (verde=profit, rojo=loss, azul=neutral)

**REQ-INT-UI-03:** Tipografía
- Font family: Roboto (Material Design)
- Tamaños: 12sp (caption), 14sp (body), 16sp (subtitle), 20sp (title)
- Weights: Regular (400), Medium (500), Bold (700)

#### 3.3.2 Interfaz de Hardware

**REQ-INT-HW-01:** Sensores
- Acelerómetro: Para detección de orientación
- Biométricos: Face ID / Fingerprint (opcional)

**REQ-INT-HW-02:** Conectividad
- WiFi: Preferido para trading
- Cellular: 3G/4G/5G soportado
- Bluetooth: No requerido

#### 3.3.3 Interfaz de Software - Backend API

**REQ-INT-SW-01:** REST API
- **Base URL:** `http://localhost:8081/api/v1`
- **Protocolo:** HTTP/1.1 con TLS 1.3
- **Formato:** JSON (Content-Type: application/json)
- **Autenticación:** JWT Bearer token (Fase 3)
- **Rate Limiting:** 100 requests/minute

**REQ-INT-SW-02:** WebSocket
- **URL:** `ws://localhost:8081/ws`
- **Protocolo:** WebSocket (RFC 6455)
- **Formato:** JSON messages
- **Heartbeat:** Ping/Pong cada 30 segundos
- **Reconexión:** Automática con exponential backoff

**REQ-INT-SW-03:** Endpoints Principales
Ver documentación completa en:
- `docs/API_DOCUMENTATION.md`
- `docs/FLUTTER_INTEGRATION_GUIDE.md`

#### 3.3.4 Interfaz de Comunicaciones

**REQ-INT-COM-01:** Protocolos
- HTTPS para REST API
- WSS para WebSocket
- JSON para serialización

**REQ-INT-COM-02:** Timeouts
- Connect timeout: 10 segundos
- Receive timeout: 30 segundos
- WebSocket idle: 5 minutos

**REQ-INT-COM-03:** Retry Logic
- Máximo 3 intentos
- Exponential backoff: 1s, 2s, 4s
- Solo para errores de red (no 4xx)

### 3.4 Requisitos de Datos

#### 3.4.1 Modelos de Datos Principales

**Position (Posición)**
```dart
{
  id: String,
  symbol: String,
  side: "long" | "short",
  entry_price: double,
  current_price: double,
  size: double,
  leverage: double,
  stop_loss: double,
  take_profit: double,
  unrealized_pnl: double,
  realized_pnl: double,
  open_time: DateTime,
  close_time: DateTime?,
  strategy: String,
  status: "open" | "closing" | "closed"
}
```

**Strategy (Estrategia)**
```dart
{
  name: String,
  active: bool,
  weight: double,
  performance: {
    total_trades: int,
    win_rate: double,
    total_pnl: double,
    sharpe_ratio: double
  }
}
```

**RiskState (Estado de Riesgo)**
```dart
{
  current_drawdown_daily: double,
  total_exposure: double,
  consecutive_losses: int,
  risk_mode: "Conservative" | "Normal" | "Aggressive",
  kill_switch_active: bool
}
```

**Metrics (Métricas)**
```dart
{
  total_trades: int,
  win_rate: double,
  total_pnl: double,
  daily_pnl: double,
  active_positions: int,
  avg_latency_ms: double
}
```

#### 3.4.2 Almacenamiento Local

**REQ-DATA-STOR-01:** Caché de Datos
- **Tecnología:** Hive (NoSQL local)
- **Datos:** Positions, Strategies, Metrics (últimas 24h)
- **Tamaño máximo:** 50 MB
- **Expiración:** 24 horas

**REQ-DATA-STOR-02:** Configuración de Usuario
- **Tecnología:** SharedPreferences
- **Datos:** Theme, language, risk parameters
- **Persistencia:** Permanente

**REQ-DATA-STOR-03:** Datos Sensibles
- **Tecnología:** flutter_secure_storage
- **Datos:** JWT tokens, API keys (si aplica)
- **Encriptación:** AES-256

#### 3.4.3 Sincronización

**REQ-DATA-SYNC-01:** Estrategia
- **Modo:** Offline-first con sync
- **Trigger:** Al reconectar a internet
- **Conflictos:** Server wins (backend es source of truth)

**REQ-DATA-SYNC-02:** Frecuencia
- **Polling:** Cada 5 segundos para métricas
- **WebSocket:** Tiempo real para posiciones
- **Manual:** Pull-to-refresh en listas


## 4. Información de Soporte

### 4.1 Diagramas

#### 4.1.1 Arquitectura de la Aplicación

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Mobile App                       │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Presentation Layer                       │  │
│  │  • Screens (Dashboard, Positions, Strategies, Risk)  │  │
│  │  • Widgets (PositionCard, MetricsDashboard, etc.)    │  │
│  │  • State Management (Riverpod Providers)             │  │
│  └──────────────────────────────────────────────────────┘  │
│                          ↓                                   │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Domain Layer                             │  │
│  │  • Models (Position, Strategy, RiskState, Metrics)   │  │
│  │  • Use Cases (Business Logic)                        │  │
│  └──────────────────────────────────────────────────────┘  │
│                          ↓                                   │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Data Layer                               │  │
│  │  • Services (ScalpingService, PositionService, etc.) │  │
│  │  • API Client (Dio)                                  │  │
│  │  • WebSocket Manager                                 │  │
│  │  • Local Storage (Hive)                              │  │
│  └──────────────────────────────────────────────────────┘  │
│                          ↓                                   │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ↓ REST API / WebSocket
┌─────────────────────────────────────────────────────────────┐
│              Trading MCP Server (Backend)                    │
│              Port 8081 (REST + WebSocket)                    │
└─────────────────────────────────────────────────────────────┘
```

#### 4.1.2 Flujo de Navegación Principal

```
Splash Screen
     ↓
Dashboard (Home)
     ├─→ Positions Screen
     │   ├─→ Position Details
     │   └─→ Edit SL/TP Dialog
     │
     ├─→ Strategies Screen
     │   ├─→ Strategy Details
     │   └─→ Configure Strategy
     │
     ├─→ Risk Monitor Screen
     │   ├─→ Edit Risk Limits
     │   └─→ Kill Switch Confirmation
     │
     └─→ More Screen
         ├─→ Settings
         ├─→ Execution Stats
         └─→ About
```

#### 4.1.3 Flujo de Datos en Tiempo Real

```
Backend Event (Position Update)
     ↓
WebSocket Message
     ↓
WebSocket Service (Parse JSON)
     ↓
Riverpod Provider (Update State)
     ↓
UI Widget (Rebuild)
     ↓
User sees update (<1s latency)
```

#### 4.1.4 Estructura de Pantallas

```
┌─────────────────────────────────────────────────────────┐
│ AppBar: Trading MCP | Status Badge | Settings Icon      │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  [Dashboard Content - varies by tab]                     │
│                                                           │
│  Home Tab:                                               │
│    • System Status Card                                  │
│    • Metrics Grid (4 cards)                              │
│    • Quick Actions (Start/Stop)                          │
│                                                           │
│  Positions Tab:                                          │
│    • Open Positions List                                 │
│    • Position Cards (expandable)                         │
│    • Swipe actions (Close, Edit)                         │
│                                                           │
│  Strategies Tab:                                         │
│    • Strategy List                                       │
│    • Toggle switches                                     │
│    • Performance metrics                                 │
│                                                           │
│  Risk Tab:                                               │
│    • Risk Sentinel State                                 │
│    • Drawdown bars                                       │
│    • Kill Switch button                                  │
│    • Exposure monitor                                    │
│                                                           │
├─────────────────────────────────────────────────────────┤
│ Bottom Navigation: Home | Positions | Strategies |       │
│                    Risk | More                           │
└─────────────────────────────────────────────────────────┘
```

### 4.2 Matriz de Trazabilidad de Requisitos (MTR)

#### Fase 0 - Critical Safety (Week 1-2)

| ID Requisito | Descripción | Prioridad | Endpoint Backend | Verificación | Estimación |
|--------------|-------------|-----------|------------------|--------------|------------|
| REQ-FR-DASH-01 | Sistema Status | CRÍTICA | GET /scalping/status | Widget Test | 2h |
| REQ-FR-DASH-02 | Métricas | CRÍTICA | GET /scalping/metrics | Widget Test | 3h |
| REQ-FR-DASH-03 | Control Engine | CRÍTICA | POST /scalping/start, /stop | Integration Test | 2h |
| REQ-FR-POS-01 | Lista Posiciones | CRÍTICA | GET /scalping/positions | Widget Test | 4h |
| REQ-FR-POS-04 | Editar SL/TP | CRÍTICA | PUT /positions/:id/sltp | Integration Test | 3h |
| REQ-FR-POS-05 | Move Breakeven | CRÍTICA | POST /positions/:id/breakeven | Integration Test | 2h |
| REQ-FR-STRAT-01 | Lista Estrategias | ALTA | GET /scalping/strategies | Widget Test | 3h |
| REQ-FR-STRAT-02 | Toggle Estrategia | ALTA | POST /strategies/:name/start | Integration Test | 2h |
| REQ-FR-RISK-04 | Risk Sentinel | CRÍTICA | GET /risk/sentinel/state | Widget Test | 4h |
| REQ-FR-RISK-05 | Kill Switch | CRÍTICA | POST /risk/sentinel/kill-switch | Integration Test | 3h |

**Total Fase 0:** ~28 horas de desarrollo

#### Fase 1 - Scalping Foundation (Week 3-4)

| ID Requisito | Descripción | Prioridad | Endpoint Backend | Verificación | Estimación |
|--------------|-------------|-----------|------------------|--------------|------------|
| REQ-FR-MTF-01 | Multi-Timeframe | ALTA | POST /analysis/multi-timeframe | Integration Test | 6h |
| REQ-FR-BACK-01 | Config Backtest | ALTA | POST /backtest/run | Widget Test | 4h |
| REQ-FR-BACK-02 | Resultados Backtest | ALTA | GET /backtest/results/:id | Widget Test | 5h |

**Total Fase 1:** ~15 horas de desarrollo

#### Fase 2 - HFT Optimization (Week 5-6)

| ID Requisito | Descripción | Prioridad | Endpoint Backend | Verificación | Estimación |
|--------------|-------------|-----------|------------------|--------------|------------|
| REQ-FR-EXEC-01 | Stats Latencia | MEDIA | GET /execution/latency | Widget Test | 3h |
| REQ-FR-EXEC-02 | Historial Exec | MEDIA | GET /execution/history | Widget Test | 3h |

**Total Fase 2:** ~6 horas de desarrollo

#### Fase 3 - Scaling (Week 7-8)

| ID Requisito | Descripción | Prioridad | Endpoint Backend | Verificación | Estimación |
|--------------|-------------|-----------|------------------|--------------|------------|
| REQ-FR-ALERT-01 | Config Alertas | MEDIA | POST /alerts/configure | Integration Test | 4h |
| REQ-FR-ALERT-02 | Historial Alertas | MEDIA | GET /alerts/history | Widget Test | 3h |
| REQ-FR-OPT-01 | Ejecutar Opt | MEDIA | POST /optimization/run | Integration Test | 4h |
| REQ-FR-OPT-02 | Resultados Opt | MEDIA | GET /optimization/results/:id | Widget Test | 3h |

**Total Fase 3:** ~14 horas de desarrollo

**TOTAL ESTIMADO:** ~63 horas de desarrollo (1.5 semanas por fase)

### 4.3 Dependencias de Paquetes Flutter

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9
  
  # HTTP & WebSocket
  dio: ^5.4.0
  web_socket_channel: ^2.4.0
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  
  # Charts & Visualization
  fl_chart: ^0.65.0
  syncfusion_flutter_charts: ^24.1.41
  
  # UI Components
  flutter_slidable: ^3.0.1
  shimmer: ^3.0.0
  
  # Utils
  intl: ^0.18.1
  timeago: ^3.6.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.7
```

### 4.4 Guías de Referencia

#### Documentación del Backend
- **API Completa:** `docs/API_DOCUMENTATION.md`
- **Guía de Integración:** `docs/FLUTTER_INTEGRATION_GUIDE.md`
- **Resumen Ejecutivo:** `docs/API_SUMMARY_FOR_FLUTTER_TEAM.md`
- **Índice:** `docs/README.md`

#### Documentación Externa
- **Flutter:** https://docs.flutter.dev
- **Riverpod:** https://riverpod.dev
- **Dio:** https://pub.dev/packages/dio
- **Material Design 3:** https://m3.material.io

### 4.5 Convenciones de Código

#### Nomenclatura
- **Archivos:** snake_case (e.g., `position_service.dart`)
- **Clases:** PascalCase (e.g., `PositionService`)
- **Variables:** camelCase (e.g., `currentPrice`)
- **Constantes:** UPPER_SNAKE_CASE (e.g., `API_BASE_URL`)

#### Estructura de Directorios
```
lib/
├── config/          # Configuración (API URLs, constants)
├── models/          # Data models
├── services/        # API services
├── providers/       # Riverpod providers
├── screens/         # Pantallas principales
├── widgets/         # Widgets reutilizables
└── utils/           # Utilidades y helpers
```

### 4.6 Criterios de Aceptación

#### Fase 0 (MVP)
- ✅ Dashboard muestra métricas en tiempo real
- ✅ Usuario puede iniciar/detener engine
- ✅ Usuario puede ver posiciones abiertas
- ✅ Usuario puede editar SL/TP
- ✅ Usuario puede activar kill switch
- ✅ WebSocket actualiza UI en <1s
- ✅ App funciona en modo offline (solo lectura)

#### Fase 1
- ✅ Usuario puede analizar múltiples timeframes
- ✅ Usuario puede ejecutar backtests
- ✅ Usuario puede ver resultados de backtests

#### Fase 2
- ✅ Usuario puede ver estadísticas de latencia
- ✅ Usuario puede monitorear performance de ejecución

#### Fase 3
- ✅ Usuario puede configurar alertas
- ✅ Usuario puede optimizar parámetros
- ✅ Usuario recibe notificaciones push

---

## 5. Conclusión

Este SRS define una aplicación Flutter completa para trading automatizado de criptomonedas, alineada con el backend Trading MCP Server v1.0.0. El desarrollo se estructura en 4 fases incrementales (8 semanas), priorizando funcionalidad crítica de seguridad (Risk Sentinel, Kill Switch) antes de features avanzadas.

**Próximos Pasos:**
1. Revisar y aprobar este SRS
2. Configurar proyecto Flutter con estructura base
3. Implementar Fase 0 (Week 1-2)
4. Testing y validación continua
5. Iteración basada en feedback

**Contacto:**
- Backend Team: Ver `docs/API_SUMMARY_FOR_FLUTTER_TEAM.md`
- Slack: `#trading-api-updates`, `#flutter-backend-support`

---

**Versión:** 2.0.0  
**Fecha:** 2025-11-16  
**Estado:** Aprobado para Desarrollo  
**Próxima Revisión:** 2025-11-23

