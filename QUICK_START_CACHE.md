# Quick Start - Sistema de Caché Local

## 🚀 Todo está listo para usar

El sistema de caché local con Hive está **completamente implementado** y configurado.

## 📁 Archivos Principales

```
kuri-cryto/
│
├── lib/
│   ├── models/adapters/
│   │   ├── position_adapter.dart         ← Adapter para Position
│   │   ├── trade_adapter.dart            ← Adapter para Trade
│   │   ├── strategy_adapter.dart         ← Adapters para Strategy
│   │   ├── risk_state_adapter.dart       ← Adapter para RiskState
│   │   ├── metrics_adapter.dart          ← Adapter para Metrics
│   │   ├── system_status_adapter.dart    ← Adapter para SystemStatus
│   │   ├── adapters.dart                 ← Export all adapters
│   │   └── README.md                     ← Documentación técnica
│   │
│   ├── services/
│   │   ├── cache_service.dart            ← ⭐ Servicio principal
│   │   └── cache_service_example.dart    ← 12 ejemplos de uso
│   │
│   ├── providers/
│   │   ├── cache_provider.dart           ← Riverpod providers
│   │   └── INTEGRATION_EXAMPLE.md        ← Cómo integrar con providers
│   │
│   └── main.dart                         ← ✅ Ya configurado
│
├── CACHE_IMPLEMENTATION.md               ← 📖 Guía completa
├── IMPLEMENTATION_CHECKLIST.md           ← ✅ Checklist detallado
└── QUICK_START_CACHE.md                  ← 🚀 Este archivo
```

## ⚡ Uso Inmediato

### 1. Importar el servicio

```dart
import 'package:kuri_crypto/services/cache_service.dart';
```

### 2. Usar en tu código

```dart
final cache = CacheService();

// Guardar position
await cache.savePosition(position);

// Recuperar positions
final positions = cache.getAllPositions();
final openPositions = cache.getOpenPositions();

// Guardar strategies
await cache.saveStrategies(strategies);

// Recuperar strategies activas
final activeStrategies = cache.getActiveStrategies();

// Guardar y recuperar metrics
await cache.saveMetrics(metrics);
final currentMetrics = cache.getMetrics();
final metricsHistory = cache.getMetricsHistory();

// Verificar estado del caché
final isFresh = cache.isCacheFresh('positions_batch');
final stats = cache.getCacheStats();
```

### 3. Usar con Riverpod

```dart
import 'package:kuri_crypto/providers/cache_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cache = ref.watch(cacheServiceProvider);
    final positions = ref.watch(cachedOpenPositionsProvider);
    final cacheStats = ref.watch(cacheStatsProvider);
    
    // Usar los datos...
  }
}
```

## 🎯 Patrones Comunes

### Patrón Offline-First

```dart
Future<List<Position>> getPositions() async {
  final cache = CacheService();
  
  try {
    // Intentar obtener del backend
    final positions = await api.getPositions();
    
    // Guardar en caché
    await cache.savePositions(positions);
    
    return positions;
  } catch (e) {
    // Si falla, usar caché
    return cache.getAllPositions();
  }
}
```

### Patrón Smart Caching

```dart
Future<List<Strategy>> getStrategies() async {
  final cache = CacheService();
  
  // Usar caché si es fresco
  if (cache.isCacheFresh('strategies_batch')) {
    final cached = cache.getAllStrategies();
    if (cached.isNotEmpty) return cached;
  }
  
  // Obtener del backend si necesario
  final strategies = await api.getStrategies();
  await cache.saveStrategies(strategies);
  
  return strategies;
}
```

## 📊 Providers Disponibles

| Provider | Descripción |
|----------|-------------|
| `cacheServiceProvider` | Servicio singleton |
| `cachedPositionsProvider` | Todas las positions |
| `cachedOpenPositionsProvider` | Positions abiertas |
| `cachedStrategiesProvider` | Todas las strategies |
| `cachedActiveStrategiesProvider` | Strategies activas |
| `cachedTradesProvider` | Todos los trades |
| `cachedRecentTradesProvider` | Trades de 24h |
| `cachedRiskStateProvider` | Risk state |
| `cachedMetricsProvider` | Metrics actuales |
| `cachedSystemStatusProvider` | System status |
| `cacheStatsProvider` | Estadísticas |

## 🛠️ Comandos Útiles

```dart
// Limpiar caché antigua
await cache.cleanOldCache();

// Limpiar todo
await cache.clearAllCache();

// Ver estadísticas
final stats = cache.getCacheStats();
print('Positions: ${stats['positions_count']}');
print('Fresh: ${stats['positions_fresh']}');

// Verificar si necesita sync
if (cache.needsSync('metrics')) {
  // Actualizar desde backend
}
```

## 📚 Documentación

- **Guía Completa**: `CACHE_IMPLEMENTATION.md`
- **Ejemplos de Código**: `lib/services/cache_service_example.dart`
- **Integración con Providers**: `lib/providers/INTEGRATION_EXAMPLE.md`
- **Detalles Técnicos**: `lib/models/adapters/README.md`
- **Checklist**: `IMPLEMENTATION_CHECKLIST.md`

## ⚙️ Configuración

La configuración ya está completa en `main.dart`:

```dart
// ✅ Ya configurado - no requiere cambios
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  // Adapters registrados
  Hive.registerAdapter(PositionAdapter());
  Hive.registerAdapter(TradeAdapter());
  Hive.registerAdapter(StrategyAdapter());
  Hive.registerAdapter(StrategyPerformanceAdapter());
  Hive.registerAdapter(RiskStateAdapter());
  Hive.registerAdapter(MetricsAdapter());
  Hive.registerAdapter(SystemStatusAdapter());
  
  // CacheService inicializado
  await CacheService().init();
  
  runApp(const ProviderScope(child: KuriCryptoApp()));
}
```

## 🎨 Ejemplo en UI

```dart
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheStats = ref.watch(cacheStatsProvider);
    final isFresh = cacheStats['positions_fresh'] ?? false;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          // Indicador de caché
          if (!isFresh)
            Chip(
              label: Text('Offline'),
              avatar: Icon(Icons.cached),
            ),
        ],
      ),
      body: /* tu contenido */,
    );
  }
}
```

## ✅ Estado Actual

- ✅ 7 Hive Adapters creados y registrados
- ✅ CacheService completo con todas las funcionalidades
- ✅ 13 Providers de Riverpod listos
- ✅ Documentación completa
- ✅ 12 ejemplos de uso
- ✅ Configuración en main.dart completada
- ✅ Políticas de expiración implementadas
- ✅ Limpieza automática de caché

## 🚀 Comenzar Ahora

1. **Ver ejemplos**: `lib/services/cache_service_example.dart`
2. **Leer guía**: `CACHE_IMPLEMENTATION.md`
3. **Integrar**: `lib/providers/INTEGRATION_EXAMPLE.md`

## 💡 Tips

1. Siempre guarda en caché después de obtener del backend
2. Usa `isCacheFresh()` para evitar llamadas innecesarias
3. Implementa fallback a caché en errores
4. Limpia caché periódicamente
5. Muestra indicadores en UI cuando uses datos en caché

---

**Todo está listo. Solo importa y usa. 🎉**
