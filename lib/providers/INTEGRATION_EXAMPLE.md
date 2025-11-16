# Integración de CacheService con Providers Existentes

Este documento muestra cómo integrar el CacheService con los providers existentes para soportar modo offline.

## Ejemplo 1: Modificar Position Provider para usar caché

### Antes (solo online):
```dart
@riverpod
Future<List<Position>> allPositions(AllPositionsRef ref) async {
  final service = ref.watch(positionServiceProvider);
  return await service.getPositions();
}
```

### Después (con soporte offline):
```dart
@riverpod
Future<List<Position>> allPositions(AllPositionsRef ref) async {
  final service = ref.watch(positionServiceProvider);
  final cache = ref.watch(cacheServiceProvider);

  try {
    // Intentar obtener datos del backend
    final positions = await service.getPositions();

    // Guardar en caché para uso offline
    await cache.savePositions(positions);

    return positions;
  } catch (e) {
    // Si falla, usar caché local
    final cachedPositions = cache.getAllPositions();

    if (cachedPositions.isEmpty) {
      // Si no hay caché, propagar el error
      rethrow;
    }

    // Retornar datos en caché
    return cachedPositions;
  }
}
```

## Ejemplo 2: Actualizar WebSocket con caché

### Modificar el stream de positions para cachear actualizaciones:

```dart
@riverpod
Stream<Position> positions(PositionsRef ref) {
  final wsService = ref.watch(websocketServiceProvider);
  final cache = ref.watch(cacheServiceProvider);

  // Ensure connection
  wsService.connect();

  // Transform WebSocket Position to model Position and cache
  return wsService.positionUpdates.asyncMap((wsPosition) async {
    final position = Position(
      id: wsPosition.id,
      symbol: wsPosition.symbol,
      side: wsPosition.side,
      entryPrice: wsPosition.entryPrice,
      currentPrice: wsPosition.currentPrice,
      size: wsPosition.size,
      leverage: wsPosition.leverage,
      stopLoss: wsPosition.stopLoss,
      takeProfit: wsPosition.takeProfit,
      unrealizedPnl: wsPosition.unrealizedPnl,
      realizedPnl: wsPosition.realizedPnl ?? 0.0,
      openTime: wsPosition.openTime,
      closeTime: wsPosition.closeTime,
      strategy: wsPosition.strategy,
      status: wsPosition.status,
    );

    // Guardar cada actualización en caché
    await cache.savePosition(position);

    return position;
  });
}
```

## Ejemplo 3: Strategy Provider con caché

```dart
@riverpod
Future<List<Strategy>> strategies(StrategiesRef ref) async {
  final service = ref.watch(strategyServiceProvider);
  final cache = ref.watch(cacheServiceProvider);

  // Verificar si el caché es fresco
  if (cache.isCacheFresh('strategies_batch')) {
    final cachedStrategies = cache.getAllStrategies();
    if (cachedStrategies.isNotEmpty) {
      return cachedStrategies;
    }
  }

  try {
    // Obtener del backend
    final strategies = await service.getStrategies();

    // Guardar en caché
    await cache.saveStrategies(strategies);

    return strategies;
  } catch (e) {
    // Fallback a caché en caso de error
    final cachedStrategies = cache.getAllStrategies();

    if (cachedStrategies.isEmpty) {
      rethrow;
    }

    return cachedStrategies;
  }
}
```

## Ejemplo 4: Metrics Provider con historial

```dart
@riverpod
class MetricsNotifier extends _$MetricsNotifier {
  @override
  Future<Metrics> build() async {
    final service = ref.watch(metricsServiceProvider);
    final cache = ref.watch(cacheServiceProvider);

    try {
      // Obtener métricas actuales del backend
      final metrics = await service.getCurrentMetrics();

      // Guardar en caché (con timestamp automático)
      await cache.saveMetrics(metrics);

      return metrics;
    } catch (e) {
      // Usar caché si falla
      final cached = cache.getMetrics();

      if (cached == null) {
        rethrow;
      }

      return cached;
    }
  }

  /// Obtener historial de métricas de las últimas 24h
  List<Metrics> getHistory() {
    final cache = ref.read(cacheServiceProvider);
    return cache.getMetricsHistory();
  }

  /// Refrescar métricas forzando actualización
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(metricsServiceProvider);
      final cache = ref.read(cacheServiceProvider);

      final metrics = await service.getCurrentMetrics();
      await cache.saveMetrics(metrics);

      return metrics;
    });
  }
}
```

## Ejemplo 5: Risk State Provider

```dart
@riverpod
class RiskStateNotifier extends _$RiskStateNotifier {
  @override
  Future<RiskState> build() async {
    final service = ref.watch(riskServiceProvider);
    final cache = ref.watch(cacheServiceProvider);

    try {
      final riskState = await service.getRiskState();
      await cache.saveRiskState(riskState);
      return riskState;
    } catch (e) {
      final cached = cache.getRiskState();
      if (cached == null) {
        rethrow;
      }
      return cached;
    }
  }
}
```

## Ejemplo 6: Limpieza automática de caché

Agregar en el `main.dart` o en un provider de inicialización:

```dart
@riverpod
class CacheManager extends _$CacheManager {
  Timer? _cleanupTimer;

  @override
  void build() {
    // Limpiar caché vieja cada hora
    _cleanupTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _cleanOldCache(),
    );
  }

  Future<void> _cleanOldCache() async {
    final cache = ref.read(cacheServiceProvider);
    await cache.cleanOldCache();
  }

  void dispose() {
    _cleanupTimer?.cancel();
  }
}
```

## Ejemplo 7: Indicador de modo offline

```dart
@riverpod
class ConnectionStatus extends _$ConnectionStatus {
  @override
  bool build() {
    return true; // Asumir online inicialmente
  }

  void setOnline() {
    state = true;
    // Sincronizar caché cuando vuelve conexión
    _syncCache();
  }

  void setOffline() {
    state = false;
  }

  Future<void> _syncCache() async {
    final cache = ref.read(cacheServiceProvider);

    // Invalidar providers que necesitan actualización
    if (cache.needsSync('positions_batch')) {
      ref.invalidate(allPositionsProvider);
    }

    if (cache.needsSync('strategies_batch')) {
      ref.invalidate(strategiesProvider);
    }

    if (cache.needsSync('metrics')) {
      ref.invalidate(metricsProvider);
    }
  }
}
```

## Uso en la UI

```dart
class PositionsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionsAsync = ref.watch(allPositionsProvider);
    final isOnline = ref.watch(connectionStatusProvider);
    final cacheStats = ref.watch(cacheStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Positions'),
        actions: [
          // Indicador de estado
          if (!isOnline)
            const Chip(
              label: Text('Offline'),
              backgroundColor: Colors.orange,
            ),
          // Indicador de caché fresco
          if (cacheStats['positions_fresh'] == true)
            const Icon(Icons.cached, color: Colors.green),
        ],
      ),
      body: positionsAsync.when(
        data: (positions) => ListView.builder(
          itemCount: positions.length,
          itemBuilder: (context, index) {
            return PositionCard(position: positions[index]);
          },
        ),
        loading: () {
          // Mostrar caché mientras carga si está disponible
          final cached = ref.read(cacheServiceProvider).getAllPositions();
          if (cached.isNotEmpty) {
            return ListView.builder(
              itemCount: cached.length,
              itemBuilder: (context, index) {
                return PositionCard(
                  position: cached[index],
                  isStale: true, // Indicar que son datos viejos
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
```

## Notas Importantes

1. **Siempre guarda en caché después de obtener datos del backend** para tener datos frescos offline.

2. **Usa `isCacheFresh()` para evitar llamadas innecesarias** al backend si los datos en caché son recientes.

3. **Limpia caché antigua periódicamente** para no llenar el almacenamiento del dispositivo.

4. **Considera la experiencia del usuario**: muestra indicadores claros cuando se usan datos en caché vs datos frescos.

5. **Manejo de errores**: siempre ten un fallback a caché cuando las llamadas al backend fallen.

6. **Sincronización**: invalida providers cuando la conexión se restablezca para obtener datos frescos.
