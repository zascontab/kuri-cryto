# Reporte de Análisis de Implementación - Trading MCP Flutter Client

**Fecha:** 2025-11-16
**Versión:** 1.0.0
**Estado:** Fase 0 - Parcialmente Implementado

---

## Resumen Ejecutivo

El proyecto Flutter ha implementado la **arquitectura base completa** con services, providers, models y UI. Sin embargo, **las pantallas NO están conectadas a los providers reales** y usan datos mock hardcoded. La infraestructura está lista, pero falta la integración crítica entre UI y backend.

### Estado General
- ✅ **Servicios**: 100% implementados (ScalpingService, PositionService, RiskService, StrategyService, WebSocketService)
- ✅ **Modelos**: 100% implementados con fromJson/toJson
- ✅ **Providers**: 100% implementados con Riverpod
- ⚠️ **Pantallas**: 100% UI implementada pero **0% conectada a providers reales**
- ❌ **Integración**: **Crítico - UI usa mock data en lugar de providers**

---

## 1. ESTADO ACTUAL DE IMPLEMENTACIÓN

### 1.1 Servicios (lib/services/)

#### ✅ COMPLETOS Y FUNCIONALES

##### `/home/user/kuri-cryto/lib/services/scalping_service.dart`
**Estado:** ✅ COMPLETO (100%)

**Métodos implementados:**
- ✅ `getStatus()` - REQ-FR-DASH-01
- ✅ `getMetrics()` - REQ-FR-DASH-02
- ✅ `getHealth()` - REQ-FR-DASH-04
- ✅ `startEngine()` - REQ-FR-DASH-03
- ✅ `stopEngine()` - REQ-FR-DASH-03
- ✅ `addPair()` - REQ-FR-PAIR-01
- ✅ `removePair()` - REQ-FR-PAIR-02

**Endpoints cubiertos:** 7/7 (100%)

---

##### `/home/user/kuri-cryto/lib/services/position_service.dart`
**Estado:** ✅ COMPLETO (100%)

**Métodos implementados:**
- ✅ `getPositions()` - REQ-FR-POS-01
- ✅ `getPositionHistory()` - REQ-FR-POS-02
- ✅ `closePosition()` - REQ-FR-POS-03
- ✅ `updateSlTp()` - REQ-FR-POS-04
- ✅ `moveToBreakeven()` - REQ-FR-POS-05
- ✅ `enableTrailingStop()` - REQ-FR-POS-06
- ✅ `getPosition()` - Helper method
- ✅ `partialClose()` - Advanced feature

**Endpoints cubiertos:** 8/8 (100%)

---

##### `/home/user/kuri-cryto/lib/services/risk_service.dart`
**Estado:** ✅ COMPLETO (100%)

**Métodos implementados:**
- ✅ `getRiskLimits()` - REQ-FR-RISK-01
- ✅ `updateRiskLimits()` - REQ-FR-RISK-02
- ✅ `getExposure()` - REQ-FR-RISK-03
- ✅ `getSentinelState()` - REQ-FR-RISK-04
- ✅ `activateKillSwitch()` - REQ-FR-RISK-05
- ✅ `deactivateKillSwitch()` - REQ-FR-RISK-05
- ✅ `checkTradeAllowed()` - Helper method
- ✅ `getAvailableCapacity()` - Helper method
- ✅ `getRiskMode()` - Helper method
- ✅ `isKillSwitchActive()` - Helper method

**Endpoints cubiertos:** 10/10 (100%)

---

##### `/home/user/kuri-cryto/lib/services/strategy_service.dart`
**Estado:** ✅ COMPLETO (100%)

**Métodos implementados:**
- ✅ `getStrategies()` - REQ-FR-STRAT-01
- ✅ `getStrategy()` - REQ-FR-STRAT-03
- ✅ `startStrategy()` - REQ-FR-STRAT-02
- ✅ `stopStrategy()` - REQ-FR-STRAT-02
- ✅ `updateConfig()` - REQ-FR-STRAT-04
- ✅ `getPerformance()` - REQ-FR-STRAT-05
- ✅ `updateWeight()` - Advanced feature
- ✅ `resetPerformance()` - Advanced feature
- ✅ `getActiveStrategies()` - Helper method
- ✅ `getTopPerformers()` - Helper method

**Endpoints cubiertos:** 10/10 (100%)

---

##### `/home/user/kuri-cryto/lib/services/websocket_service.dart`
**Estado:** ✅ COMPLETO (100%)

**Funcionalidades implementadas:**
- ✅ Conexión/desconexión automática
- ✅ Reconexión con exponential backoff
- ✅ Heartbeat/ping cada 30 segundos
- ✅ Subscripción a canales (positions, trades, metrics, alerts, kill_switch)
- ✅ Stream controllers para cada tipo de evento
- ✅ Manejo robusto de errores
- ✅ Estado de conexión observable

**Streams disponibles:**
- ✅ `positionUpdates` - Position updates
- ✅ `tradeExecuted` - Trade execution events
- ✅ `metricsUpdates` - Metrics updates
- ✅ `alerts` - Alert events
- ✅ `killSwitchEvents` - Kill switch events
- ✅ `connectionStateStream` - Connection state changes

---

##### `/home/user/kuri-cryto/lib/services/api_client.dart`
**Estado:** ✅ COMPLETO (100%)

**Funcionalidades:**
- ✅ Dio configurado con retry logic
- ✅ Exponential backoff (3 intentos)
- ✅ Logging de requests/responses
- ✅ Manejo de errores específicos (401, 403, 404, 429, etc.)
- ✅ Transformación de errores del backend a excepciones custom
- ✅ Soporte para todos los métodos HTTP (GET, POST, PUT, DELETE, PATCH)

---

#### ❌ SERVICIOS FALTANTES (NO IMPLEMENTADOS)

##### **ExecutionService** - REQ-FR-EXEC-01, REQ-FR-EXEC-02
**Prioridad:** MEDIA
**Endpoints requeridos:**
- `GET /api/v1/scalping/execution/latency` - Estadísticas de latencia
- `GET /api/v1/scalping/execution/history` - Historial de ejecuciones

**Estimación:** 2-3 horas

---

##### **AnalysisService** - REQ-FR-MTF-01, REQ-FR-MTF-02 (Fase 1)
**Prioridad:** ALTA (Fase 1)
**Endpoints requeridos:**
- `POST /api/v1/analysis/multi-timeframe` - Análisis multi-timeframe

**Estimación:** 4-5 horas

---

##### **BacktestService** - REQ-FR-BACK-01, REQ-FR-BACK-02 (Fase 1)
**Prioridad:** ALTA (Fase 1)
**Endpoints requeridos:**
- `POST /api/v1/backtest/run` - Ejecutar backtest
- `GET /api/v1/backtest/results/:id` - Obtener resultados

**Estimación:** 3-4 horas

---

##### **AlertService** - REQ-FR-ALERT-01, REQ-FR-ALERT-02 (Fase 3)
**Prioridad:** MEDIA (Fase 3)
**Endpoints requeridos:**
- `POST /api/v1/alerts/configure` - Configurar alertas
- `GET /api/v1/alerts/history` - Historial de alertas

**Estimación:** 3-4 horas

---

##### **OptimizationService** - REQ-FR-OPT-01, REQ-FR-OPT-02 (Fase 3)
**Prioridad:** MEDIA (Fase 3)
**Endpoints requeridos:**
- `POST /api/v1/optimization/run` - Ejecutar optimización
- `GET /api/v1/optimization/results/:id` - Resultados de optimización

**Estimación:** 3-4 horas

---

### 1.2 Providers (lib/providers/)

#### ✅ PROVIDERS IMPLEMENTADOS (100%)

##### `/home/user/kuri-cryto/lib/providers/system_provider.dart`
**Estado:** ✅ COMPLETO

**Providers:**
- ✅ `SystemStatus` - Auto-refresh cada 5s, con start/stop engine
- ✅ `Metrics` - Auto-refresh cada 5s
- ✅ `Health` - Auto-refresh cada 10s
- ✅ `AutoRefreshEnabled` - Control de auto-refresh

**Conexión:** ✅ Conectado a `ScalpingService`

---

##### `/home/user/kuri-cryto/lib/providers/position_provider.dart`
**Estado:** ✅ COMPLETO

**Providers:**
- ✅ `positions` - StreamProvider para WebSocket updates
- ✅ `positionHistory` - FutureProvider con filtros
- ✅ `SelectedPosition` - State provider
- ✅ `PositionCloser` - Action provider
- ✅ `SlTpUpdater` - Action provider
- ✅ `BreakevenMover` - Action provider
- ✅ `TrailingStopEnabler` - Action provider

**Conexión:** ✅ Conectado a `PositionService` y `WebSocketService`

**Nota:** ⚠️ Provider `positions` retorna `Stream<Position>` (individual updates), no `List<Position>` (lista completa). Esto requiere acumulación manual en UI.

---

##### `/home/user/kuri-cryto/lib/providers/risk_provider.dart`
**Estado:** ✅ COMPLETO

**Providers:**
- ✅ `riskState` - FutureProvider para Risk Sentinel
- ✅ `RiskLimits` - Auto-refresh manual
- ✅ `Exposure` - Con helpers (getExposurePercent, isCritical, isWarning)
- ✅ `KillSwitchActivator` - Action provider
- ✅ `KillSwitchDeactivator` - Action provider
- ✅ `RiskLimitsUpdater` - Action provider
- ✅ `killSwitchActive` - Derived provider
- ✅ `riskMode` - Derived provider
- ✅ `DrawdownStatus` - Derived provider con helpers
- ✅ `ConsecutiveLossesStatus` - Derived provider

**Conexión:** ✅ Conectado a `RiskService`

---

##### `/home/user/kuri-cryto/lib/providers/strategy_provider.dart`
**Estado:** ✅ COMPLETO

**Providers:**
- ✅ `Strategies` - Lista de todas las estrategias
- ✅ `SelectedStrategy` - State provider
- ✅ `StrategyStarter` - Action provider
- ✅ `StrategyStopper` - Action provider
- ✅ `StrategyConfigUpdater` - Action provider
- ✅ `strategyDetails` - FutureProvider por nombre
- ✅ `strategyPerformance` - FutureProvider por nombre
- ✅ `activeStrategiesCount` - Derived provider
- ✅ `strategiesByStatus` - Derived provider
- ✅ `StrategyToggler` - Convenience provider
- ✅ `StrategyStats` - Aggregated statistics

**Conexión:** ✅ Conectado a `StrategyService`

---

##### `/home/user/kuri-cryto/lib/providers/websocket_provider.dart`
**Estado:** ✅ COMPLETO

**Providers:**
- ✅ `WebsocketConnectionState` - Estado de conexión
- ✅ `positionUpdatesStream` - Stream de posiciones
- ✅ `metricsUpdatesStream` - Stream de métricas
- ✅ `alertsStream` - Stream de alertas
- ✅ `tradeExecutionStream` - Stream de trades ejecutados
- ✅ `killSwitchStream` - Stream de eventos kill switch
- ✅ `WebsocketStatus` - Status con color
- ✅ `WebsocketLatency` - Monitoreo de latencia (TODO: implementar medición)
- ✅ `ReconnectionAttempts` - Contador de reconexiones
- ✅ `LastEventTimestamp` - Timestamp del último evento

**Conexión:** ✅ Conectado a `WebSocketService`

---

### 1.3 Modelos (lib/models/)

#### ✅ MODELOS IMPLEMENTADOS (100%)

##### Modelos Core:
- ✅ `Position` - Con fromJson/toJson, copyWith, helpers
- ✅ `Strategy` - Con StrategyPerformance anidado
- ✅ `StrategyPerformance` - Métricas completas
- ✅ `SystemStatus` - Estado del sistema
- ✅ `Metrics` - Métricas de trading
- ✅ `HealthStatus` - Estado de salud
- ✅ `RiskState` - Estado del Risk Sentinel
- ✅ `RiskLimits` - Límites y parámetros de riesgo
- ✅ `Exposure` - Información de exposición
- ✅ `Trade` - Modelo de trade ejecutado
- ✅ `WebSocketEvent` - Eventos WebSocket (Position, Trade, Metrics, Alert, KillSwitchEvent)

**Calidad:** ✅ Todos con validación robusta, parsing seguro, y métodos helper

---

### 1.4 Pantallas (lib/screens/)

#### ⚠️ CRÍTICO: TODAS LAS PANTALLAS USAN MOCK DATA

##### `/home/user/kuri-cryto/lib/screens/dashboard_screen.dart`
**Estado:** ⚠️ UI COMPLETA - **NO CONECTADA A PROVIDERS**

**Implementado:**
- ✅ UI completa con System Status Card
- ✅ Grid de métricas (4 cards)
- ✅ Auto-refresh cada 5s
- ✅ Botón Start/Stop Engine con confirmación
- ✅ Pull-to-refresh

**Problema CRÍTICO:**
```dart
// LÍNEAS 20-27: DATOS HARDCODED
bool _isEngineRunning = false;
String _uptime = '2h 30m';
String _healthStatus = 'healthy';
double _totalPnl = 125.50;
double _dailyPnlChange = 12.3;
double _winRate = 65.5;
int _activePositions = 3;
double _avgLatency = 45.2;
```

**DEBE USAR:**
```dart
// CORRECTO: Usar providers
final systemStatus = ref.watch(systemStatusProvider);
final metrics = ref.watch(metricsProvider);
final health = ref.watch(healthProvider);
```

**Estimación de corrección:** 2-3 horas

---

##### `/home/user/kuri-cryto/lib/screens/positions_screen.dart`
**Estado:** ⚠️ UI COMPLETA - **NO CONECTADA A PROVIDERS**

**Implementado:**
- ✅ UI completa con tabs (Open/History)
- ✅ PositionCard con todas las acciones
- ✅ Diálogo de edición SL/TP
- ✅ Acciones: Close, Edit SL/TP, Breakeven, Trailing

**Problema CRÍTICO:**
```dart
// LÍNEAS 20-97: LISTA HARDCODED DE POSICIONES
final List<_PositionData> _openPositions = [
  _PositionData(
    id: '1',
    symbol: 'BTC-USDT',
    // ... más datos mock
  ),
  // ...
];
```

**DEBE USAR:**
```dart
// CORRECTO: Usar providers
// Para posiciones en tiempo real (stream)
final positionsStream = ref.watch(positionsProvider);

// Para lista completa (REST API)
final service = ref.watch(positionServiceProvider);
final positions = await service.getPositions();

// Para cerrar posición
ref.read(positionCloserProvider.notifier).closePosition(positionId);

// Para editar SL/TP
ref.read(slTpUpdaterProvider.notifier).updateSlTp(
  positionId: id,
  stopLoss: newSL,
  takeProfit: newTP,
);
```

**Estimación de corrección:** 3-4 horas

---

##### `/home/user/kuri-cryto/lib/screens/risk_screen.dart`
**Estado:** ⚠️ UI COMPLETA - **NO CONECTADA A PROVIDERS**

**Implementado:**
- ✅ UI completa con Risk Sentinel Card
- ✅ Drawdown bars (daily, weekly, monthly)
- ✅ Exposure monitor
- ✅ Kill Switch button con confirmación
- ✅ Risk Limits editor
- ✅ Risk Mode selector
- ✅ Exposure by Symbol

**Problema CRÍTICO:**
```dart
// LÍNEAS 19-31: DATOS HARDCODED
double _dailyDrawdown = 2.3;
double _weeklyDrawdown = 4.8;
double _monthlyDrawdown = 8.5;
double _totalExposure = 3500.0;
int _consecutiveLosses = 2;
String _riskMode = 'Normal';
bool _killSwitchActive = false;
// ... más datos mock
```

**DEBE USAR:**
```dart
// CORRECTO: Usar providers
final riskState = ref.watch(riskStateProvider);
final exposure = ref.watch(exposureProvider);
final limits = ref.watch(riskLimitsProvider);

// Para activar kill switch
ref.read(killSwitchActivatorProvider.notifier).activate(reason);

// Para actualizar límites
ref.read(riskLimitsUpdaterProvider.notifier).updateLimits(params);
```

**Estimación de corrección:** 3-4 horas

---

##### `/home/user/kuri-cryto/lib/screens/strategies_screen.dart`
**Estado:** ⚠️ UI COMPLETA - **NO CONECTADA A PROVIDERS**

**Implementado:**
- ✅ UI completa con resumen de estrategias
- ✅ Lista de estrategias con StrategyCard
- ✅ Toggle para activar/desactivar
- ✅ Detalles de estrategia (modal)
- ✅ Configuración de estrategia (diálogo)

**Problema CRÍTICO:**
```dart
// LÍNEAS 18-86: LISTA HARDCODED DE ESTRATEGIAS
final List<_StrategyData> _strategies = [
  _StrategyData(
    name: 'RSI Scalping',
    isActive: true,
    weight: 0.25,
    totalTrades: 150,
    winRate: 68.5,
    // ... más datos mock
  ),
  // ...
];
```

**DEBE USAR:**
```dart
// CORRECTO: Usar providers
final strategies = ref.watch(strategiesProvider);

// Para activar/desactivar
ref.read(strategyTogglerProvider.notifier).toggle(strategyName);

// Para configurar
ref.read(strategyConfigUpdaterProvider.notifier).updateConfig(
  strategyName: name,
  config: configMap,
);
```

**Estimación de corrección:** 2-3 horas

---

## 2. GAPS CRÍTICOS PARA FASE 0

### 2.1 CRÍTICO - Conectar UI a Providers

**Problema:** Todas las pantallas usan datos mock hardcoded en lugar de consumir los providers implementados.

**Impacto:**
- ❌ La aplicación NO funciona con datos reales del backend
- ❌ No hay comunicación con el servidor
- ❌ No hay actualizaciones en tiempo real vía WebSocket
- ❌ Todas las acciones (start/stop engine, close position, etc.) son simuladas

**Solución:**
1. Convertir todas las pantallas a `ConsumerWidget` o `ConsumerStatefulWidget`
2. Reemplazar variables de estado locales con `ref.watch()` de providers
3. Usar action providers para operaciones (close position, update SL/TP, etc.)
4. Implementar manejo de estados `AsyncValue` (loading, error, data)

**Archivos afectados:**
- `/home/user/kuri-cryto/lib/screens/dashboard_screen.dart`
- `/home/user/kuri-cryto/lib/screens/positions_screen.dart`
- `/home/user/kuri-cryto/lib/screens/risk_screen.dart`
- `/home/user/kuri-cryto/lib/screens/strategies_screen.dart`

**Estimación total:** 10-14 horas

**Prioridad:** 🔴 CRÍTICA

---

### 2.2 CRÍTICO - Implementar lista completa de posiciones

**Problema:** El provider `positionsProvider` retorna `Stream<Position>` (actualizaciones individuales), pero las pantallas necesitan `List<Position>` (lista completa).

**Solución:**
```dart
// OPCIÓN A: Crear provider para lista completa vía REST
@riverpod
Future<List<Position>> openPositions(OpenPositionsRef ref) async {
  final service = ref.watch(positionServiceProvider);
  return await service.getPositions();
}

// OPCIÓN B: Acumular stream en StateProvider
@riverpod
class PositionsList extends _$PositionsList {
  @override
  FutureOr<List<Position>> build() async {
    final service = ref.watch(positionServiceProvider);
    final initialPositions = await service.getPositions();

    // Subscribe to updates
    ref.listen(positionsProvider, (previous, next) {
      next.whenData((updatedPosition) {
        // Update position in list
        final currentList = state.value ?? [];
        final index = currentList.indexWhere((p) => p.id == updatedPosition.id);
        if (index >= 0) {
          currentList[index] = updatedPosition;
        } else {
          currentList.add(updatedPosition);
        }
        state = AsyncValue.data([...currentList]);
      });
    });

    return initialPositions;
  }
}
```

**Estimación:** 2-3 horas

**Prioridad:** 🔴 CRÍTICA

---

### 2.3 ALTA - Implementar ExecutionService y pantalla

**Endpoints faltantes:**
- `GET /api/v1/scalping/execution/latency` - REQ-FR-EXEC-01
- `GET /api/v1/scalping/execution/history` - REQ-FR-EXEC-02

**Providers necesarios:**
- `ExecutionLatencyProvider` - Auto-refresh
- `ExecutionHistoryProvider` - Con paginación

**Pantalla:** Crear `lib/screens/execution_screen.dart`

**Estimación:** 4-5 horas

**Prioridad:** 🟡 ALTA (Fase 0)

---

### 2.4 MEDIA - Manejo de errores en UI

**Problema:** Las pantallas no manejan errores de red, timeouts, o errores del backend.

**Solución:**
```dart
// Usar AsyncValue pattern
final systemStatus = ref.watch(systemStatusProvider);

systemStatus.when(
  data: (status) => _buildContent(status),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(
    error: error,
    onRetry: () => ref.refresh(systemStatusProvider),
  ),
);
```

**Estimación:** 3-4 horas

**Prioridad:** 🟡 ALTA

---

### 2.5 MEDIA - Configuración de API base URL

**Problema:** API URL hardcoded a `localhost:8081`, no funciona en dispositivos físicos.

**Solución:**
```dart
// lib/config/api_config.dart
class ApiConfig {
  static String getBaseUrl(String environment) {
    switch (environment) {
      case 'development':
        return Platform.isAndroid
          ? 'http://10.0.2.2:8081/api/v1'  // Android emulator
          : 'http://localhost:8081/api/v1'; // iOS simulator
      case 'staging':
        return 'http://YOUR_STAGING_IP:8081/api/v1';
      case 'production':
        return 'https://YOUR_DOMAIN/api/v1';
      default:
        return 'http://localhost:8081/api/v1';
    }
  }
}
```

**Estimación:** 1-2 horas

**Prioridad:** 🟡 ALTA

---

### 2.6 BAJA - Logging y debugging

**Recomendación:** Añadir logger a providers para debugging

**Estimación:** 1 hora

**Prioridad:** 🟢 BAJA

---

## 3. LISTA PRIORIZADA DE IMPLEMENTACIÓN

### 🔴 PRIORIDAD CRÍTICA (Fase 0 - Week 1-2)

#### 1. Conectar Dashboard a Providers
**Archivo:** `/home/user/kuri-cryto/lib/screens/dashboard_screen.dart`
**Complejidad:** MEDIA
**Estimación:** 2-3 horas
**Requisitos:**
- REQ-FR-DASH-01: Sistema Status
- REQ-FR-DASH-02: Métricas Principales
- REQ-FR-DASH-03: Control de Engine
- REQ-FR-DASH-04: Health Check

**Tareas:**
1. Convertir a `ConsumerStatefulWidget`
2. Reemplazar variables mock con `ref.watch(systemStatusProvider)`
3. Implementar `AsyncValue.when()` para loading/error states
4. Conectar botón Start/Stop a `systemStatusProvider.startEngine()`
5. Testing con backend real

---

#### 2. Conectar Positions Screen a Providers
**Archivo:** `/home/user/kuri-cryto/lib/screens/positions_screen.dart`
**Complejidad:** ALTA
**Estimación:** 3-4 horas
**Requisitos:**
- REQ-FR-POS-01: Lista de Posiciones Abiertas
- REQ-FR-POS-02: Historial de Posiciones
- REQ-FR-POS-03: Cierre Manual
- REQ-FR-POS-04: Editar SL/TP
- REQ-FR-POS-05: Move to Breakeven
- REQ-FR-POS-06: Trailing Stop

**Tareas:**
1. Crear `OpenPositionsListProvider` para lista completa
2. Conectar tab "Open" a provider de lista
3. Conectar tab "History" a `positionHistoryProvider`
4. Implementar acciones con action providers
5. Suscribirse a `positionsProvider` stream para updates en tiempo real

---

#### 3. Conectar Risk Screen a Providers
**Archivo:** `/home/user/kuri-cryto/lib/screens/risk_screen.dart`
**Complejidad:** ALTA
**Estimación:** 3-4 horas
**Requisitos:**
- REQ-FR-RISK-01: Visualización de Límites
- REQ-FR-RISK-02: Actualización de Límites
- REQ-FR-RISK-03: Monitor de Exposición
- REQ-FR-RISK-04: Risk Sentinel State
- REQ-FR-RISK-05: Kill Switch

**Tareas:**
1. Conectar a `riskStateProvider`
2. Conectar a `exposureProvider` con helpers
3. Implementar Kill Switch con `killSwitchActivatorProvider`
4. Conectar editor de límites a `riskLimitsUpdaterProvider`
5. Implementar auto-refresh cada 5s

---

#### 4. Conectar Strategies Screen a Providers
**Archivo:** `/home/user/kuri-cryto/lib/screens/strategies_screen.dart`
**Complejidad:** MEDIA
**Estimación:** 2-3 horas
**Requisitos:**
- REQ-FR-STRAT-01: Lista de Estrategias
- REQ-FR-STRAT-02: Activar/Desactivar Estrategia
- REQ-FR-STRAT-03: Detalles de Estrategia
- REQ-FR-STRAT-04: Configuración de Estrategia
- REQ-FR-STRAT-05: Performance por Estrategia

**Tareas:**
1. Conectar a `strategiesProvider`
2. Implementar toggle con `strategyTogglerProvider`
3. Cargar detalles con `strategyDetailsProvider`
4. Conectar configuración a `strategyConfigUpdaterProvider`

---

#### 5. Implementar lista completa de posiciones
**Archivo:** Nuevo provider en `/home/user/kuri-cryto/lib/providers/position_provider.dart`
**Complejidad:** MEDIA
**Estimación:** 2-3 horas

**Código:**
```dart
@riverpod
class OpenPositionsList extends _$OpenPositionsList {
  @override
  FutureOr<List<Position>> build() async {
    final service = ref.watch(positionServiceProvider);
    final positions = await service.getPositions();

    // Listen to WebSocket updates
    ref.listen(positionsProvider, (previous, next) {
      next.whenData((updatedPosition) {
        _updatePositionInList(updatedPosition);
      });
    });

    return positions;
  }

  void _updatePositionInList(Position updated) {
    final currentList = state.value ?? [];
    final index = currentList.indexWhere((p) => p.id == updated.id);

    List<Position> newList;
    if (index >= 0) {
      if (updated.status == 'closed') {
        // Remove closed position
        newList = [...currentList]..removeAt(index);
      } else {
        // Update existing
        newList = [...currentList]..[index] = updated;
      }
    } else if (updated.status == 'open') {
      // Add new position
      newList = [...currentList, updated];
    } else {
      return;
    }

    state = AsyncValue.data(newList);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(positionServiceProvider);
      return await service.getPositions();
    });
  }
}
```

---

#### 6. Configurar API base URL para dispositivos físicos
**Archivo:** `/home/user/kuri-cryto/lib/config/api_config.dart`
**Complejidad:** BAJA
**Estimación:** 1 hora

**Tareas:**
1. Detectar plataforma (Android emulator, iOS simulator, dispositivo físico)
2. Configurar URL apropiada por ambiente
3. Añadir variable de entorno para IP del servidor

---

#### 7. Implementar manejo de errores en UI
**Archivos:** Todas las pantallas
**Complejidad:** MEDIA
**Estimación:** 3-4 horas

**Tareas:**
1. Crear widget `ErrorDisplay` reutilizable
2. Implementar `AsyncValue.when()` en todas las pantallas
3. Añadir botones de retry
4. Mostrar mensajes de error user-friendly

---

### 🟡 PRIORIDAD ALTA (Fase 0 - Week 1-2)

#### 8. Implementar ExecutionService
**Archivo:** Crear `/home/user/kuri-cryto/lib/services/execution_service.dart`
**Complejidad:** BAJA
**Estimación:** 2 horas

**Endpoints:**
- `GET /api/v1/scalping/execution/latency`
- `GET /api/v1/scalping/execution/history?limit=50`

---

#### 9. Crear ExecutionProvider
**Archivo:** Crear `/home/user/kuri-cryto/lib/providers/execution_provider.dart`
**Complejidad:** BAJA
**Estimación:** 1 hora

---

#### 10. Crear pantalla de Execution Stats
**Archivo:** Crear `/home/user/kuri-cryto/lib/screens/execution_screen.dart`
**Complejidad:** MEDIA
**Estimación:** 2-3 horas

---

### 🟢 PRIORIDAD MEDIA (Fase 1 - Week 3-4)

#### 11. Implementar AnalysisService (Multi-Timeframe)
**Archivo:** Crear `/home/user/kuri-cryto/lib/services/analysis_service.dart`
**Complejidad:** MEDIA
**Estimación:** 4-5 horas
**Requisitos:** REQ-FR-MTF-01, REQ-FR-MTF-02

---

#### 12. Implementar BacktestService
**Archivo:** Crear `/home/user/kuri-cryto/lib/services/backtest_service.dart`
**Complejidad:** MEDIA
**Estimación:** 3-4 horas
**Requisitos:** REQ-FR-BACK-01, REQ-FR-BACK-02

---

#### 13. Crear pantalla de Multi-Timeframe Analysis
**Archivo:** Crear `/home/user/kuri-cryto/lib/screens/analysis_screen.dart`
**Complejidad:** ALTA
**Estimación:** 5-6 horas

---

#### 14. Crear pantalla de Backtesting
**Archivo:** Crear `/home/user/kuri-cryto/lib/screens/backtest_screen.dart`
**Complejidad:** ALTA
**Estimación:** 5-6 horas

---

### 🔵 PRIORIDAD BAJA (Fase 2-3 - Week 5-8)

#### 15. Implementar AlertService
**Complejidad:** MEDIA
**Estimación:** 3-4 horas

#### 16. Implementar OptimizationService
**Complejidad:** MEDIA
**Estimación:** 3-4 horas

#### 17. Performance charts con fl_chart
**Complejidad:** ALTA
**Estimación:** 6-8 horas

#### 18. Sistema de notificaciones push
**Complejidad:** ALTA
**Estimación:** 6-8 horas

#### 19. Internacionalización (i18n)
**Complejidad:** MEDIA
**Estimación:** 4-5 horas

#### 20. Dark mode
**Complejidad:** BAJA
**Estimación:** 2-3 horas

---

## 4. RESUMEN DE ESTIMACIONES

### Fase 0 - CRÍTICO (Total: 21-28 horas)
| # | Tarea | Estimación | Complejidad |
|---|-------|------------|-------------|
| 1 | Dashboard → Providers | 2-3h | MEDIA |
| 2 | Positions → Providers | 3-4h | ALTA |
| 3 | Risk → Providers | 3-4h | ALTA |
| 4 | Strategies → Providers | 2-3h | MEDIA |
| 5 | Lista completa posiciones | 2-3h | MEDIA |
| 6 | API URL config | 1h | BAJA |
| 7 | Manejo de errores UI | 3-4h | MEDIA |
| 8 | ExecutionService | 2h | BAJA |
| 9 | ExecutionProvider | 1h | BAJA |
| 10 | Execution Screen | 2-3h | MEDIA |

### Fase 1 - ALTA (Total: 17-21 horas)
| # | Tarea | Estimación | Complejidad |
|---|-------|------------|-------------|
| 11 | AnalysisService | 4-5h | MEDIA |
| 12 | BacktestService | 3-4h | MEDIA |
| 13 | Analysis Screen | 5-6h | ALTA |
| 14 | Backtest Screen | 5-6h | ALTA |

### Fase 2-3 - MEDIA/BAJA (Total: 25-35 horas)
| # | Tarea | Estimación | Complejidad |
|---|-------|------------|-------------|
| 15 | AlertService | 3-4h | MEDIA |
| 16 | OptimizationService | 3-4h | MEDIA |
| 17 | Performance charts | 6-8h | ALTA |
| 18 | Push notifications | 6-8h | ALTA |
| 19 | i18n | 4-5h | MEDIA |
| 20 | Dark mode | 2-3h | BAJA |

**TOTAL GENERAL:** 63-84 horas

---

## 5. RECOMENDACIONES

### 5.1 Acción Inmediata

1. **PRIORIDAD 1:** Conectar las 4 pantallas principales a providers (12-14 horas)
   - Esto hará que la app funcione con datos reales
   - Es bloqueante para cualquier testing real

2. **PRIORIDAD 2:** Implementar lista completa de posiciones (2-3 horas)
   - Resolver el gap entre `Stream<Position>` y `List<Position>`

3. **PRIORIDAD 3:** Configurar API URL para dispositivos físicos (1 hora)
   - Sin esto, solo funciona en simuladores

### 5.2 Testing

Después de conectar UI a providers:
1. Testing con backend local
2. Testing en emulador Android
3. Testing en simulador iOS
4. Testing en dispositivo físico Android
5. Testing en dispositivo físico iOS
6. Testing de WebSocket reconnection
7. Testing de manejo de errores de red

### 5.3 Mejoras Arquitecturales

1. **Repository Pattern:** Considerar añadir capa de repositorios entre providers y services
2. **Use Cases:** Implementar use cases para lógica de negocio compleja
3. **Error Handling:** Centralizar manejo de errores con Result/Either pattern
4. **Logging:** Implementar logging estructurado con logger package

### 5.4 Próximos Pasos (Post Fase 0)

1. Implementar servicios faltantes (Analysis, Backtest, Alert, Optimization)
2. Crear pantallas de Fase 1 (Multi-Timeframe, Backtesting)
3. Añadir gráficos de performance con fl_chart
4. Implementar sistema de notificaciones
5. Añadir internacionalización
6. Implementar dark mode
7. Optimizar rendimiento y memoria
8. Testing end-to-end completo

---

## 6. CONCLUSIÓN

El proyecto tiene una **arquitectura sólida y bien estructurada** con servicios, providers y modelos completos. Sin embargo, **el gap crítico es la desconexión entre UI y backend**.

**Estado actual:**
- ✅ Backend integration layer: 100% completo
- ✅ State management: 100% implementado
- ⚠️ UI implementation: 100% completo pero **0% conectado**

**Prioridad absoluta:**
1. Conectar las 4 pantallas a providers reales (12-14 horas)
2. Resolver lista de posiciones (2-3 horas)
3. Configurar API URL (1 hora)

**Total tiempo crítico:** 15-18 horas

Una vez completado esto, la app será **funcional end-to-end** y se podrá empezar testing real con el backend.

---

**Preparado por:** Claude Code Agent
**Fecha:** 2025-11-16
**Versión del reporte:** 1.0.0
