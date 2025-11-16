# Resumen de Modelos de Datos - Kuri Crypto Trading App

## Modelos Implementados

Todos los modelos implementados incluyen:
- ✅ Null safety completo
- ✅ Serialización JSON (fromJson/toJson)
- ✅ Método copyWith para inmutabilidad
- ✅ Manejo robusto de errores
- ✅ Valores por defecto sensatos
- ✅ Documentación completa
- ✅ Tests unitarios exhaustivos

---

## 1. Position Model (`lib/models/position.dart`)

Modelo que representa una posición de trading (abierta o cerrada).

### Propiedades Principales:
- **id**: String - Identificador único de la posición
- **symbol**: String - Par de trading (ej: 'BTC-USDT', 'DOGE-USDT')
- **side**: String - Dirección: 'long' o 'short'
- **entryPrice**: double - Precio de entrada
- **currentPrice**: double - Precio actual del mercado
- **size**: double - Tamaño de la posición
- **leverage**: double - Apalancamiento (1x, 2x, etc.)
- **stopLoss**: double? - Precio de stop loss
- **takeProfit**: double? - Precio de take profit
- **unrealizedPnl**: double - Ganancia/pérdida no realizada
- **realizedPnl**: double - Ganancia/pérdida realizada
- **openTime**: DateTime - Momento de apertura
- **closeTime**: DateTime? - Momento de cierre (null si está abierta)
- **strategy**: String - Estrategia que abrió la posición
- **status**: String - Estado: 'open', 'closing', 'closed'

### Métodos Especiales:
- **calculatePnlPercentage()**: Calcula el porcentaje de P&L considerando el lado (long/short) y leverage
- **isProfitable**: getter - Verifica si la posición es rentable
- **isOpen**: getter - Verifica si la posición está abierta

### Ejemplo de Uso:
```dart
final position = Position.fromJson({
  'id': 'pos_123',
  'symbol': 'DOGE-USDT',
  'side': 'long',
  'entry_price': 0.085,
  'current_price': 0.0865,
  'size': 1000,
  'leverage': 2,
  'stop_loss': 0.0835,
  'take_profit': 0.0875,
  'unrealized_pnl': 15.0,
  'open_time': '2025-11-16T10:00:00Z',
  'strategy': 'rsi_scalping',
  'status': 'open',
});

print('P&L: ${position.calculatePnlPercentage()}%');
print('Is profitable: ${position.isProfitable}');
```

---

## 2. Strategy Model (`lib/models/strategy.dart`)

Modelo que representa una estrategia de trading con sus métricas de rendimiento.

### Propiedades Principales:
- **name**: String - Nombre de la estrategia
- **active**: bool - Si la estrategia está activa
- **weight**: double - Peso en el portafolio (0.0 - 1.0)
- **performance**: StrategyPerformance - Métricas de rendimiento
- **config**: Map<String, dynamic>? - Configuración opcional

### StrategyPerformance (Nested Model):
- **totalTrades**: int - Total de trades ejecutados
- **winningTrades**: int - Trades ganadores
- **losingTrades**: int - Trades perdedores
- **winRate**: double - Tasa de victorias (0-100%)
- **totalPnl**: double - P&L total
- **avgWin**: double - Ganancia promedio
- **avgLoss**: double - Pérdida promedio
- **sharpeRatio**: double - Ratio de Sharpe
- **maxDrawdown**: double - Máximo drawdown
- **profitFactor**: double - Factor de beneficio

### Métodos Especiales:
- **isPerformingWell**: getter - Verifica si la estrategia tiene buen rendimiento (winRate > 50% y totalPnl > 0)
- **hasSufficientData**: getter - Verifica si tiene suficientes datos (>= 10 trades)

### Ejemplo de Uso:
```dart
final strategy = Strategy.fromJson({
  'name': 'rsi_scalping',
  'active': true,
  'weight': 0.25,
  'performance': {
    'total_trades': 50,
    'win_rate': 65.0,
    'total_pnl': 45.50,
    'sharpe_ratio': 1.8,
  },
});

print('Performing well: ${strategy.isPerformingWell}');
```

---

## 3. RiskState Model (`lib/models/risk_state.dart`)

Modelo que monitorea el estado de riesgo del sistema.

### Propiedades Principales:
- **currentDrawdownDaily**: double - Drawdown diario actual (%)
- **currentDrawdownWeekly**: double - Drawdown semanal actual (%)
- **currentDrawdownMonthly**: double - Drawdown mensual actual (%)
- **totalExposure**: double - Exposición total
- **exposureBySymbol**: Map<String, double> - Exposición por símbolo
- **consecutiveLosses**: int - Número de pérdidas consecutivas
- **riskMode**: String - Modo de riesgo: 'Conservative', 'Normal', 'Aggressive', 'ControlledCrazy'
- **killSwitchActive**: bool - Si el kill switch está activo
- **lastUpdate**: DateTime - Última actualización
- **maxDailyDrawdown**: double - Drawdown diario máximo permitido
- **maxWeeklyDrawdown**: double - Drawdown semanal máximo permitido
- **maxMonthlyDrawdown**: double - Drawdown mensual máximo permitido
- **maxConsecutiveLosses**: int - Pérdidas consecutivas máximas permitidas
- **maxTotalExposure**: double - Exposición total máxima permitida

### Métodos Especiales:
- **isHighRisk()**: Determina si el sistema está en estado de alto riesgo (>80% de cualquier límite)
- **canTrade()**: Determina si se puede operar (no hay kill switch, no se exceden límites)
- **getRiskLevel()**: Retorna el nivel de riesgo como porcentaje (0-100)
- **getAvailableExposure()**: Retorna la exposición disponible
- **getExposurePercentage()**: Retorna el porcentaje de exposición usado

### Ejemplo de Uso:
```dart
final riskState = RiskState.fromJson({
  'current_drawdown_daily': 2.5,
  'current_drawdown_weekly': 5.0,
  'total_exposure': 45.50,
  'exposure_by_symbol': {
    'DOGE-USDT': 25.00,
    'BTC-USDT': 20.50,
  },
  'consecutive_losses': 1,
  'risk_mode': 'Normal',
  'kill_switch_active': false,
  'last_update': '2025-11-16T10:30:00Z',
});

print('Can trade: ${riskState.canTrade()}');
print('Risk level: ${riskState.getRiskLevel()}%');
print('Is high risk: ${riskState.isHighRisk()}');
```

---

## 4. Metrics Model (`lib/models/metrics.dart`)

Modelo que agrega métricas generales de trading y rendimiento del sistema.

### Propiedades Principales:
- **totalTrades**: int - Total de trades ejecutados
- **winningTrades**: int - Trades ganadores
- **losingTrades**: int - Trades perdedores
- **winRate**: double - Tasa de victorias (%)
- **totalPnl**: double - P&L total
- **dailyPnl**: double - P&L del día
- **weeklyPnl**: double - P&L de la semana
- **monthlyPnl**: double - P&L del mes
- **avgWin**: double - Ganancia promedio
- **avgLoss**: double - Pérdida promedio
- **profitFactor**: double - Factor de beneficio
- **sharpeRatio**: double - Ratio de Sharpe
- **maxDrawdown**: double - Máximo drawdown
- **activePositions**: int - Posiciones activas
- **avgLatencyMs**: double - Latencia promedio (ms)
- **avgSlippagePct**: double - Slippage promedio (%)

### Métodos Especiales:
- **isProfitable**: getter - P&L total positivo
- **isDailyProfitable**: getter - P&L diario positivo
- **isPerformingWell**: getter - winRate > 50% y isProfitable
- **hasFastExecution**: getter - avgLatencyMs < 100ms
- **winLossRatio**: getter - Ratio ganancia/pérdida promedio

### Ejemplo de Uso:
```dart
final metrics = Metrics.fromJson({
  'total_trades': 145,
  'win_rate': 62.5,
  'total_pnl': 125.50,
  'daily_pnl': 15.25,
  'active_positions': 2,
  'avg_latency_ms': 45,
});

print('Performing well: ${metrics.isPerformingWell}');
print('Win/Loss ratio: ${metrics.winLossRatio}');
```

---

## 5. SystemStatus Model (`lib/models/system_status.dart`)

Modelo que representa el estado actual del sistema de trading.

### Propiedades Principales:
- **running**: bool - Si el motor de trading está corriendo
- **uptime**: String - Tiempo activo (formato: '2h30m15s')
- **pairsCount**: int - Número de pares monitoreados
- **activeStrategies**: int - Número de estrategias activas
- **healthStatus**: String - Estado de salud: 'healthy', 'degraded', 'unhealthy'
- **errors**: List<String> - Lista de errores actuales
- **timestamp**: DateTime? - Timestamp del estado

### Métodos Especiales:
- **isHealthy**: getter - Estado saludable y sin errores
- **hasErrors**: getter - Tiene errores
- **isOperational**: getter - Running y healthy
- **uptimeSeconds**: getter - Uptime en segundos
- **uptimeDuration**: getter - Uptime como Duration

### Ejemplo de Uso:
```dart
final status = SystemStatus.fromJson({
  'running': true,
  'uptime': '2h30m15s',
  'pairs_count': 3,
  'active_strategies': 5,
  'health_status': 'healthy',
  'errors': [],
});

print('Is operational: ${status.isOperational}');
print('Uptime: ${status.uptimeDuration}');
```

---

## 6. Trade Model (`lib/models/trade.dart`)

Modelo que representa una ejecución de trade individual.

### Propiedades Principales:
- **id**: String - Identificador único del trade
- **orderId**: String - ID de la orden en el exchange
- **symbol**: String - Par de trading
- **side**: String - Lado: 'buy' o 'sell'
- **type**: String - Tipo: 'market', 'limit', 'stop'
- **price**: double - Precio de ejecución
- **size**: double - Tamaño de la orden
- **status**: String - Estado: 'pending', 'filled', 'cancelled', 'failed'
- **latencyMs**: double - Latencia de ejecución (ms)
- **timestamp**: DateTime - Momento de ejecución
- **fee**: double? - Comisión pagada
- **feeCurrency**: String? - Moneda de la comisión
- **slippagePct**: double? - Porcentaje de slippage

### Métodos Especiales:
- **isBuy**: getter - Es orden de compra
- **isSell**: getter - Es orden de venta
- **isFilled**: getter - Orden completada
- **isPending**: getter - Orden pendiente
- **isFailed**: getter - Orden fallida o cancelada
- **isFastExecution**: getter - Latencia < 100ms
- **getTotalCost()**: Calcula costo total incluyendo fees
- **getEffectivePrice()**: Calcula precio efectivo después de slippage

### Ejemplo de Uso:
```dart
final trade = Trade.fromJson({
  'id': 'trade_123',
  'order_id': 'ord_123',
  'symbol': 'DOGE-USDT',
  'side': 'buy',
  'type': 'market',
  'price': 0.08500,
  'size': 1000,
  'status': 'filled',
  'latency_ms': 45,
  'timestamp': '2025-11-16T10:00:00Z',
});

print('Total cost: ${trade.getTotalCost()}');
print('Fast execution: ${trade.isFastExecution}');
```

---

## Tests Unitarios

Todos los modelos incluyen tests exhaustivos que cubren:
- ✅ Creación de objetos con todos los campos
- ✅ Serialización/deserialización JSON
- ✅ Manejo de campos opcionales
- ✅ Manejo de valores por defecto
- ✅ Parsing de números como strings
- ✅ Métodos copyWith
- ✅ Igualdad de objetos
- ✅ Métodos especiales y cálculos
- ✅ Casos edge y validaciones

### Ejecutar Tests:
```bash
# Con Flutter
flutter test

# Con Dart puro
dart test
```

---

## Importación de Modelos

Para importar todos los modelos de una vez:

```dart
import 'package:kuri_crypto/models/models.dart';
```

O importar modelos individuales:

```dart
import 'package:kuri_crypto/models/position.dart';
import 'package:kuri_crypto/models/strategy.dart';
import 'package:kuri_crypto/models/risk_state.dart';
// etc.
```

---

## Estructura de Archivos

```
lib/models/
├── models.dart           # Barrel file para exportar todos los modelos
├── position.dart         # Modelo Position
├── strategy.dart         # Modelos Strategy y StrategyPerformance
├── risk_state.dart       # Modelo RiskState
├── metrics.dart          # Modelo Metrics
├── system_status.dart    # Modelo SystemStatus
└── trade.dart            # Modelo Trade

test/models/
├── position_test.dart
├── strategy_test.dart
├── risk_state_test.dart
├── metrics_test.dart
├── system_status_test.dart
└── trade_test.dart
```

---

## Características Comunes

### Null Safety
Todos los modelos implementan null safety completo de Dart 3.0:
- Campos no nulos marcados con tipo no nullable
- Campos opcionales marcados con `?`
- Valores por defecto para campos opcionales

### Parsing Robusto
Cada modelo incluye helpers para parsing seguro:
```dart
static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}
```

### Manejo de Errores
Los métodos `fromJson` lanzan `FormatException` con mensajes descriptivos:
```dart
try {
  return Position(...);
} catch (e) {
  throw FormatException('Failed to parse Position from JSON: $e');
}
```

### Inmutabilidad
Todos los campos son `final` y se proporciona `copyWith` para crear copias modificadas:
```dart
final updatedPosition = position.copyWith(
  currentPrice: 44000.0,
  unrealizedPnl: 100.0,
);
```

---

## Próximos Pasos

1. ✅ Modelos de datos implementados
2. ⏳ Implementar servicios API
3. ⏳ Implementar state management con Riverpod
4. ⏳ Crear UI components
5. ⏳ Integrar WebSocket para updates en tiempo real

---

**Documentación generada**: 2025-11-16
**Versión**: 1.0.0
**Autor**: Claude Code
