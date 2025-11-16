# Implementación de Caché Local con Hive

Este documento describe la implementación completa del sistema de caché local usando Hive para la aplicación Kuri Crypto.

## Estructura de Archivos Creados

```
lib/
├── models/
│   └── adapters/
│       ├── adapters.dart                    # Barrel file para exportar todos los adapters
│       ├── position_adapter.dart            # Adapter para Position (TypeId: 0)
│       ├── trade_adapter.dart               # Adapter para Trade (TypeId: 1)
│       ├── strategy_adapter.dart            # Adapters para Strategy y StrategyPerformance (TypeId: 2, 3)
│       ├── risk_state_adapter.dart          # Adapter para RiskState (TypeId: 4)
│       ├── metrics_adapter.dart             # Adapter para Metrics (TypeId: 5)
│       ├── system_status_adapter.dart       # Adapter para SystemStatus (TypeId: 6)
│       └── README.md                        # Documentación de adapters
│
├── services/
│   ├── cache_service.dart                   # Servicio principal de caché
│   └── cache_service_example.dart           # Ejemplos de uso del servicio
│
├── providers/
│   ├── cache_provider.dart                  # Providers de Riverpod para caché
│   └── INTEGRATION_EXAMPLE.md               # Guía de integración con providers existentes
│
└── main.dart                                 # Actualizado con registro de adapters
```

## Componentes Implementados

### 1. Hive Adapters (7 adapters)

Cada adapter permite serializar/deserializar los modelos principales a formato binario:

| Adapter | TypeId | Modelo |
|---------|--------|--------|
| PositionAdapter | 0 | Position |
| TradeAdapter | 1 | Trade |
| StrategyAdapter | 2 | Strategy |
| StrategyPerformanceAdapter | 3 | StrategyPerformance |
| RiskStateAdapter | 4 | RiskState |
| MetricsAdapter | 5 | Metrics |
| SystemStatusAdapter | 6 | SystemStatus |

**Ubicación**: `/home/user/kuri-cryto/lib/models/adapters/`

### 2. CacheService

Servicio singleton que maneja todas las operaciones de caché:

**Funcionalidades principales:**
- Guardar/recuperar positions (individuales y batch)
- Guardar/recuperar trades con filtrado por fecha
- Guardar/recuperar strategies con filtrado por estado activo
- Guardar/recuperar risk state
- Guardar/recuperar metrics con historial (últimas 24h)
- Guardar/recuperar system status
- Limpieza automática de caché antigua (> 24h)
- Verificación de freshness del caché
- Estadísticas de caché

**Ubicación**: `/home/user/kuri-cryto/lib/services/cache_service.dart`

### 3. Cache Providers

Providers de Riverpod para integración fácil con la aplicación:

```dart
- cacheServiceProvider              // Provider del servicio
- cachedPositionsProvider           // Todas las positions en caché
- cachedOpenPositionsProvider       // Solo positions abiertas
- cachedStrategiesProvider          // Todas las strategies
- cachedActiveStrategiesProvider    // Solo strategies activas
- cachedTradesProvider              // Todos los trades
- cachedRecentTradesProvider        // Trades de últimas 24h
- cachedRiskStateProvider           // Risk state actual
- cachedMetricsProvider             // Metrics actuales
- cachedSystemStatusProvider        // System status actual
- cacheStatsProvider                // Estadísticas de caché
- cacheNeedsSyncProvider.family     // Verificar si necesita sync
- cacheIsFreshProvider.family       // Verificar si caché es fresco
```

**Ubicación**: `/home/user/kuri-cryto/lib/providers/cache_provider.dart`

## Configuración en main.dart

El archivo `main.dart` ha sido actualizado para:

1. **Importar los adapters:**
```dart
import 'models/adapters/position_adapter.dart';
import 'models/adapters/trade_adapter.dart';
import 'models/adapters/strategy_adapter.dart';
import 'models/adapters/risk_state_adapter.dart';
import 'models/adapters/metrics_adapter.dart';
import 'models/adapters/system_status_adapter.dart';
import 'services/cache_service.dart';
```

2. **Registrar los adapters:**
```dart
// Registrar adaptadores de Hive para caché local
Hive.registerAdapter(PositionAdapter());
Hive.registerAdapter(TradeAdapter());
Hive.registerAdapter(StrategyAdapter());
Hive.registerAdapter(StrategyPerformanceAdapter());
Hive.registerAdapter(RiskStateAdapter());
Hive.registerAdapter(MetricsAdapter());
Hive.registerAdapter(SystemStatusAdapter());

// Inicializar el servicio de caché
await CacheService().init();
```

## Uso Básico

### 1. Guardar datos en caché

```dart
final cache = CacheService();

// Guardar position
await cache.savePosition(position);

// Guardar múltiples positions
await cache.savePositions([position1, position2, position3]);

// Guardar trade
await cache.saveTrade(trade);

// Guardar strategies
await cache.saveStrategies([strategy1, strategy2]);

// Guardar metrics (con timestamp automático)
await cache.saveMetrics(metrics);

// Guardar risk state
await cache.saveRiskState(riskState);

// Guardar system status
await cache.saveSystemStatus(status);
```

### 2. Recuperar datos del caché

```dart
final cache = CacheService();

// Obtener una position específica
final position = cache.getPosition('pos_001');

// Obtener todas las positions
final allPositions = cache.getAllPositions();

// Obtener solo positions abiertas
final openPositions = cache.getOpenPositions();

// Obtener trades recientes (últimas 24h)
final recentTrades = cache.getRecentTrades();

// Obtener strategies activas
final activeStrategies = cache.getActiveStrategies();

// Obtener metrics actual
final metrics = cache.getMetrics();

// Obtener historial de metrics (24h)
final metricsHistory = cache.getMetricsHistory();
```

### 3. Gestión de caché

```dart
final cache = CacheService();

// Verificar si el caché es fresco
final isFresh = cache.isCacheFresh('positions_batch');

// Verificar si necesita sincronización
final needsSync = cache.needsSync('metrics');

// Limpiar caché antigua
await cache.cleanOldCache();

// Limpiar métricas antiguas (> 24h)
await cache.cleanOldMetrics();

// Obtener estadísticas
final stats = cache.getCacheStats();
print('Positions cached: ${stats['positions_count']}');
print('Is fresh: ${stats['positions_fresh']}');
```

## Integración con Providers

### Patrón Offline-First

```dart
@riverpod
Future<List<Position>> positions(PositionsRef ref) async {
  final service = ref.watch(positionServiceProvider);
  final cache = ref.watch(cacheServiceProvider);

  try {
    // Intentar obtener del backend
    final positions = await service.getPositions();

    // Guardar en caché
    await cache.savePositions(positions);

    return positions;
  } catch (e) {
    // Si falla, usar caché
    final cached = cache.getAllPositions();

    if (cached.isEmpty) {
      rethrow; // No hay caché disponible
    }

    return cached;
  }
}
```

### Patrón Smart Caching

```dart
@riverpod
Future<List<Strategy>> strategies(StrategiesRef ref) async {
  final service = ref.watch(strategyServiceProvider);
  final cache = ref.watch(cacheServiceProvider);

  // Usar caché si es fresco
  if (cache.isCacheFresh('strategies_batch')) {
    final cached = cache.getAllStrategies();
    if (cached.isNotEmpty) {
      return cached;
    }
  }

  // Obtener del backend si caché está stale
  try {
    final strategies = await service.getStrategies();
    await cache.saveStrategies(strategies);
    return strategies;
  } catch (e) {
    // Fallback a caché stale si hay error
    final cached = cache.getAllStrategies();
    if (cached.isEmpty) rethrow;
    return cached;
  }
}
```

## Políticas de Expiración

El CacheService implementa políticas de expiración automáticas:

| Tipo de Datos | Tiempo de Expiración |
|---------------|---------------------|
| Positions | 1 hora |
| Trades | 24 horas |
| Strategies | 6 horas |
| Metrics | 24 horas |
| Risk State | 24 horas |
| System Status | 24 horas |

## Limpieza Automática

Para implementar limpieza automática periódica, agrega en tu app:

```dart
// En main.dart o en un provider de inicialización
Timer.periodic(const Duration(hours: 1), (_) async {
  await CacheService().cleanOldCache();
});
```

## Uso en la UI

```dart
class PositionsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheStats = ref.watch(cacheStatsProvider);
    final isFresh = cacheStats['positions_fresh'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Positions'),
        actions: [
          // Indicador de caché
          if (!isFresh)
            const Tooltip(
              message: 'Using cached data',
              child: Icon(Icons.cached, color: Colors.orange),
            ),
        ],
      ),
      body: _buildPositionsList(),
    );
  }
}
```

## Estadísticas de Caché

```dart
final cache = CacheService();
final stats = cache.getCacheStats();

print('''
=== Cache Statistics ===
Positions: ${stats['positions_count']}
Trades: ${stats['trades_count']}
Strategies: ${stats['strategies_count']}
Has Risk State: ${stats['has_risk_state']}
Has Metrics: ${stats['has_metrics']}
Positions Fresh: ${stats['positions_fresh']}
Metrics Fresh: ${stats['metrics_fresh']}
Last Update: ${stats['last_positions_update']}
''');
```

## Best Practices

### 1. Siempre guarda después de obtener del backend
```dart
final data = await api.getData();
await cache.saveData(data);  // ✅ Buena práctica
```

### 2. Usa isCacheFresh para evitar llamadas innecesarias
```dart
if (!cache.isCacheFresh('data_type')) {
  // Solo fetch si es necesario
  data = await api.getData();
  await cache.save(data);
}
```

### 3. Implementa fallback a caché en errores
```dart
try {
  return await api.getData();
} catch (e) {
  final cached = cache.getData();
  if (cached != null) return cached;  // ✅ Fallback
  rethrow;
}
```

### 4. Limpia caché periódicamente
```dart
// Cada hora
Timer.periodic(Duration(hours: 1), (_) {
  cache.cleanOldCache();
});
```

### 5. Muestra indicadores en UI
```dart
// Indica al usuario cuando usa datos en caché
if (!isFresh) {
  showCacheIndicator();
}
```

## Testing

Para testing, puedes usar el CacheService en tests:

```dart
test('Cache saves and retrieves positions', () async {
  await Hive.initFlutter();

  // Registrar adapters
  Hive.registerAdapter(PositionAdapter());

  final cache = CacheService();
  await cache.init();

  final position = Position(
    id: 'test',
    symbol: 'BTC-USDT',
    // ...
  );

  await cache.savePosition(position);
  final retrieved = cache.getPosition('test');

  expect(retrieved?.id, equals('test'));

  await cache.close();
});
```

## Troubleshooting

### Error: "Box not found"
**Solución**: Asegúrate de llamar `await CacheService().init()` en `main.dart`.

### Error: "TypeAdapter not found"
**Solución**: Verifica que todos los adapters estén registrados en `main.dart`.

### Datos no se actualizan
**Solución**: Verifica que estés guardando en caché después de obtener del backend.

### Caché crece demasiado
**Solución**: Implementa limpieza automática con `Timer.periodic`.

## Documentación Adicional

- **Adapters**: Ver `/home/user/kuri-cryto/lib/models/adapters/README.md`
- **Ejemplos**: Ver `/home/user/kuri-cryto/lib/services/cache_service_example.dart`
- **Integración**: Ver `/home/user/kuri-cryto/lib/providers/INTEGRATION_EXAMPLE.md`

## Próximos Pasos

1. **Integrar con providers existentes**: Modificar `position_provider.dart`, `strategy_provider.dart`, etc.
2. **Implementar limpieza automática**: Agregar Timer en main.dart
3. **Agregar indicadores UI**: Mostrar cuando se usan datos en caché
4. **Testing**: Crear tests para verificar funcionamiento
5. **Monitoreo**: Agregar logging para debug de caché

## Recursos

- [Hive Documentation](https://docs.hivedb.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Flutter Offline Best Practices](https://flutter.dev/docs/cookbook/networking/background-parsing)
