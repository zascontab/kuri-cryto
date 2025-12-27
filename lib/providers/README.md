# Riverpod Providers Documentation

Este directorio contiene todos los providers de Riverpod para la gestión de estado reactivo de la aplicación.

## Estructura de Providers

### 1. **services_provider.dart** - Providers de Servicios Base

Provee instancias de todos los servicios de la aplicación con inyección de dependencias.

#### Providers Disponibles:

- **`dioProvider`**: Instancia configurada de Dio HTTP client
  - Base URL: `http://localhost:8081/api/v1`
  - Timeouts: 10s connect, 30s receive
  - Logging interceptor en modo debug

- **`apiClientProvider`**: Cliente API wrapper sobre Dio
  - Manejo de errores unificado
  - Retry logic con exponential backoff

- **`scalpingServiceProvider`**: Servicio de control del sistema
  - Start/Stop engine
  - Status y métricas
  - Health check

- **`positionServiceProvider`**: Servicio de gestión de posiciones
  - CRUD de posiciones
  - Actualización de SL/TP
  - Breakeven y trailing stop

- **`strategyServiceProvider`**: Servicio de estrategias
  - Control de estrategias (start/stop)
  - Configuración de parámetros
  - Performance metrics

- **`riskServiceProvider`**: Servicio de gestión de riesgo
  - Risk limits y exposure
  - Risk Sentinel state
  - Kill switch

- **`websocketServiceProvider`**: Servicio WebSocket
  - Conexión WebSocket persistente
  - Auto-reconexión
  - Event streams

---

### 2. **system_provider.dart** - Estado del Sistema

Gestiona el estado global del sistema de trading con auto-refresh.

#### Providers Disponibles:

**`SystemStatus` (AsyncNotifier)**
- **Descripción**: Estado del sistema con auto-refresh cada 5s
- **Estado**: `AsyncValue<SystemStatusModel>`
- **Métodos**:
  - `refresh()`: Refrescar manualmente
  - `startEngine()`: Iniciar engine de scalping
  - `stopEngine()`: Detener engine de scalping
- **Uso**:
  ```dart
  final status = ref.watch(systemStatusProvider);
  status.when(
    data: (status) => Text('Uptime: ${status.uptime}'),
    loading: () => CircularProgressIndicator(),
    error: (e, _) => Text('Error: $e'),
  );
  ```

**`Metrics` (AsyncNotifier)**
- **Descripción**: Métricas de trading con auto-refresh cada 5s
- **Estado**: `AsyncValue<MetricsModel>`
- **Datos**: Total trades, win rate, P&L, latency
- **Uso**:
  ```dart
  final metrics = ref.watch(metricsProvider);
  ```

**`HealthStatus` (AsyncNotifier)**
- **Descripción**: Estado de salud con auto-refresh cada 10s
- **Estado**: `AsyncValue<HealthStatusModel>`
- **Datos**: Health status, component health
- **Uso**:
  ```dart
  final health = ref.watch(healthStatusProvider);
  ```

**`AutoRefreshEnabled`**
- **Descripción**: Control de auto-refresh (para pausar en background)
- **Estado**: `bool`
- **Métodos**: `enable()`, `disable()`, `toggle()`

---

### 3. **position_provider.dart** - Gestión de Posiciones

Gestiona posiciones abiertas y cerradas con actualizaciones en tiempo real vía WebSocket.

#### Providers Disponibles:

**`positions` (StreamProvider)**
- **Descripción**: Stream de posiciones abiertas en tiempo real
- **Estado**: `Stream<List<Position>>`
- **Fuente**: WebSocket position updates
- **Uso**:
  ```dart
  final positions = ref.watch(positionsProvider);
  positions.when(
    data: (list) => ListView.builder(...),
    loading: () => LoadingIndicator(),
    error: (e, _) => ErrorWidget(e),
  );
  ```

**`positionHistory` (FutureProvider)**
- **Descripción**: Historial de posiciones con paginación
- **Parámetros**: `limit`, `offset`, `symbol`, `strategy`, `startDate`, `endDate`
- **Estado**: `AsyncValue<List<Position>>`
- **Uso**:
  ```dart
  final history = ref.watch(
    positionHistoryProvider(limit: 50, offset: 0)
  );
  ```

**`SelectedPosition` (StateNotifier)**
- **Descripción**: Posición seleccionada en UI
- **Estado**: `Position?`
- **Métodos**: `select()`, `clear()`, `update()`

**`PositionCloser` (AsyncNotifier)**
- **Método**: `closePosition(String id)` - Cerrar posición
- **Invalidaciones**: Actualiza `positionsProvider`

**`SlTpUpdater` (AsyncNotifier)**
- **Método**: `updateSlTp({id, stopLoss, takeProfit})` - Actualizar SL/TP
- **Validación**: Al menos uno de SL o TP debe proveerse

**`BreakevenMover` (AsyncNotifier)**
- **Método**: `moveToBreakeven(String id)` - Mover SL a breakeven

**`TrailingStopEnabler` (AsyncNotifier)**
- **Método**: `enableTrailingStop({id, distancePercent})` - Activar trailing stop
- **Validación**: Distancia entre 0.1% - 1.0%

**`PositionStats`**
- **Descripción**: Estadísticas agregadas de posiciones
- **Datos**: Total positions, unrealized P&L, exposure, by strategy

---

### 4. **strategy_provider.dart** - Gestión de Estrategias

Gestiona las 5 estrategias de scalping y su configuración.

#### Providers Disponibles:

**`Strategies` (AsyncNotifier)**
- **Descripción**: Lista de todas las estrategias disponibles
- **Estado**: `AsyncValue<List<Strategy>>`
- **Métodos**: `refresh()`, `getByName(String name)`
- **Uso**:
  ```dart
  final strategies = ref.watch(strategiesProvider);
  ```

**`SelectedStrategy`**
- **Descripción**: Estrategia seleccionada en UI
- **Métodos**: `select()`, `selectByName()`, `clear()`

**`StrategyStarter` (AsyncNotifier)**
- **Método**: `startStrategy(String name)` - Iniciar estrategia

**`StrategyStopper` (AsyncNotifier)**
- **Método**: `stopStrategy(String name)` - Detener estrategia

**`StrategyConfigUpdater` (AsyncNotifier)**
- **Método**: `updateConfig({name, config})` - Actualizar configuración
- **Parámetros**: Map de configuración específica por estrategia

**`strategyDetails` (FutureProvider)**
- **Descripción**: Detalles completos de una estrategia
- **Parámetro**: `String strategyName`

**`strategyPerformance` (FutureProvider)**
- **Descripción**: Performance de estrategia por período
- **Parámetros**: `strategyName`, `period` (daily/weekly/monthly)

**`StrategyToggler` (AsyncNotifier)**
- **Método**: `toggle(String name)` - Start si inactive, Stop si active

**`StrategyStats`**
- **Descripción**: Estadísticas agregadas de todas las estrategias
- **Datos**: Total, active, combined win rate, combined P&L

---

### 5. **risk_provider.dart** - Gestión de Riesgo

Gestiona Risk Sentinel, límites de riesgo y kill switch.

#### Providers Disponibles:

**`riskState` (StreamProvider)**
- **Descripción**: Estado del Risk Sentinel en tiempo real vía WebSocket
- **Estado**: `Stream<RiskState>`
- **Datos**: Drawdown, exposure, consecutive losses, risk mode, kill switch
- **Uso**:
  ```dart
  final risk = ref.watch(riskStateProvider);
  risk.when(
    data: (state) => RiskMonitorWidget(state),
    loading: () => Shimmer(),
    error: (e, _) => ErrorBanner(e),
  );
  ```

**`RiskLimits` (AsyncNotifier)**
- **Descripción**: Configuración de límites de riesgo
- **Estado**: `AsyncValue<RiskLimitsModel>`
- **Métodos**: `refresh()`

**`Exposure` (AsyncNotifier)**
- **Descripción**: Exposición actual
- **Estado**: `AsyncValue<ExposureModel>`
- **Métodos**: `refresh()`, `getExposurePercent()`, `isCritical()`, `isWarning()`

**`KillSwitchActivator` (AsyncNotifier)**
- **Método**: `activate(String reason)` - Activar kill switch
- **CRÍTICO**: Detiene todo el trading y cierra posiciones

**`KillSwitchDeactivator` (AsyncNotifier)**
- **Método**: `deactivate()` - Desactivar kill switch

**`RiskLimitsUpdater` (AsyncNotifier)**
- **Método**: `updateLimits({...})` - Actualizar límites
- **Parámetros**: maxPositionSize, maxTotalExposure, stopLoss%, etc.

**`killSwitchActive` (Provider)**
- **Descripción**: Estado actual del kill switch (bool)

**`riskMode` (Provider)**
- **Descripción**: Modo de riesgo actual (String)

**`DrawdownStatus`**
- **Descripción**: Estado de drawdown con niveles críticos
- **Métodos**: `getMaxDrawdown()`, `isAnyCritical()`

**`ConsecutiveLossesStatus`**
- **Descripción**: Estado de pérdidas consecutivas
- **Datos**: current, max, percentage, warnings

---

### 6. **websocket_provider.dart** - Estado WebSocket

Gestiona la conexión WebSocket y streams de eventos en tiempo real.

#### Providers Disponibles:

**`WebsocketConnectionState` (StateNotifier)**
- **Descripción**: Estado de la conexión WebSocket
- **Estados**: disconnected, connecting, connected, error, reconnecting
- **Métodos**: `connect()`, `disconnect()`
- **Getters**: `isConnected`, `isConnecting`, `hasError`
- **Uso**:
  ```dart
  final wsState = ref.watch(websocketConnectionStateProvider);
  final statusColor = wsState == WebSocketConnectionState.connected
    ? Colors.green
    : Colors.red;
  ```

**`positionUpdatesStream` (StreamProvider)**
- **Descripción**: Stream de actualizaciones de posiciones
- **Tipo**: `Stream<List<Position>>`

**`metricsUpdatesStream` (StreamProvider)**
- **Descripción**: Stream de actualizaciones de métricas
- **Tipo**: `Stream<MetricsModel>`

**`alertsStream` (StreamProvider)**
- **Descripción**: Stream de alertas
- **Tipo**: `Stream<Alert>`

**`riskUpdatesStream` (StreamProvider)**
- **Descripción**: Stream de actualizaciones de riesgo
- **Tipo**: `Stream<RiskState>`

**`tradeExecutionStream` (StreamProvider)**
- **Descripción**: Stream de ejecuciones de trades
- **Tipo**: `Stream<TradeExecutedEvent>`

**`killSwitchStream` (StreamProvider)**
- **Descripción**: Stream de eventos del kill switch
- **Tipo**: `Stream<KillSwitchEvent>`

**`WebsocketStatus`**
- **Descripción**: Status formateado para UI (mensaje + color)

**`WebsocketLatency`**
- **Descripción**: Estadísticas de latencia WebSocket
- **Datos**: current, average, min, max
- **Getters**: `isGood`, `isAcceptable`, `isPoor`

**`ReconnectionAttempts`**
- **Descripción**: Contador de intentos de reconexión

**`LastEventTimestamp`**
- **Descripción**: Timestamp del último evento recibido
- **Métodos**: `isStale()`, `secondsSinceLastEvent()`

---

## Patrones de Uso

### 1. Consumir datos en UI

```dart
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(systemStatusProvider);
    final metrics = ref.watch(metricsProvider);

    return status.when(
      data: (status) => MetricsCard(status, metrics),
      loading: () => SkeletonLoader(),
      error: (e, _) => ErrorCard(e),
    );
  }
}
```

### 2. Ejecutar acciones

```dart
class StartButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        try {
          await ref.read(systemStatusProvider.notifier).startEngine();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Engine started')),
          );
        } catch (e) {
          // Manejar error
        }
      },
      child: Text('Start'),
    );
  }
}
```

### 3. Escuchar streams

```dart
class PositionsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionsStream = ref.watch(positionsProvider);

    return positionsStream.when(
      data: (positions) => ListView.builder(
        itemCount: positions.length,
        itemBuilder: (context, index) => PositionCard(positions[index]),
      ),
      loading: () => CircularProgressIndicator(),
      error: (e, _) => ErrorWidget(e),
    );
  }
}
```

### 4. Providers con parámetros

```dart
// Usar provider con parámetros
final history = ref.watch(
  positionHistoryProvider(
    limit: 50,
    offset: 0,
    symbol: 'BTC-USDT',
  ),
);

// Usar provider familiar
final btcPerformance = ref.watch(
  strategyPerformanceProvider(
    strategyName: 'RSI Scalping',
    period: 'daily',
  ),
);
```

### 5. Invalidar providers para refrescar

```dart
// Invalidar un provider específico
ref.invalidate(strategiesProvider);

// Invalidar múltiples providers
ref.invalidate(systemStatusProvider);
ref.invalidate(metricsProvider);
```

---

## Auto-Refresh

Los siguientes providers tienen auto-refresh automático:

| Provider | Intervalo | Pausable |
|----------|-----------|----------|
| `systemStatusProvider` | 5 segundos | ✅ |
| `metricsProvider` | 5 segundos | ✅ |
| `healthStatusProvider` | 10 segundos | ✅ |

Para pausar auto-refresh (ej. en background):

```dart
// Pausar
ref.read(autoRefreshEnabledProvider.notifier).disable();

// Reanudar
ref.read(autoRefreshEnabledProvider.notifier).enable();
```

---

## Error Handling

Todos los providers manejan errores automáticamente con `AsyncValue.guard`:

```dart
// En UI
final data = ref.watch(someProvider);
data.when(
  data: (value) => SuccessWidget(value),
  loading: () => LoadingWidget(),
  error: (error, stack) => ErrorWidget(error), // Error capturado aquí
);

// Errores en acciones se propagan
try {
  await ref.read(positionCloserProvider.notifier).closePosition(id);
} catch (e) {
  // Manejar error específico
}
```

---

## Code Generation

Para generar código de Riverpod:

```bash
# Generar una vez
flutter pub run build_runner build

# Generar en watch mode
flutter pub run build_runner watch

# Limpiar y generar
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Dependencias Requeridas

```yaml
dependencies:
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  dio: ^5.4.0

dev_dependencies:
  build_runner: ^2.4.7
  riverpod_generator: ^2.3.9
```

---

## Convenciones

1. **Nombres de Providers**: CamelCase terminando en `Provider`
   - Ejemplo: `systemStatusProvider`, `positionsProvider`

2. **Notifiers**: CamelCase sin sufijo
   - Ejemplo: `SystemStatus`, `Strategies`

3. **Métodos de acción**: Verbos descriptivos
   - Ejemplo: `startEngine()`, `closePosition()`, `updateSlTp()`

4. **Invalidaciones**: Invalidar providers relacionados después de mutaciones
   - Ejemplo: Después de cerrar posición, invalidar `positionsProvider`

5. **Documentación**: Todos los providers documentados con:
   - Descripción clara
   - Parámetros
   - Tipo de retorno
   - Ejemplo de uso

---

## Testing

Ejemplo de test con providers:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('systemStatusProvider fetches status', () async {
    final container = ProviderContainer(
      overrides: [
        scalpingServiceProvider.overrideWithValue(
          MockScalpingService(),
        ),
      ],
    );

    final status = await container.read(systemStatusProvider.future);
    expect(status.running, isTrue);
  });
}
```

---

## Próximos Pasos

1. ✅ Providers creados
2. ⏳ Crear servicios (`lib/services/`)
3. ⏳ Crear modelos (`lib/models/`)
4. ⏳ Implementar UI screens
5. ⏳ Testing
6. ⏳ Integración con backend

---

**Última actualización**: 2025-11-16
**Versión**: 1.0.0
**Riverpod**: 2.4.9
