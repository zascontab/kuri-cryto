# Referencia Rápida de Propiedades - Modelos de Trading

## Position Model

| Propiedad | Tipo | Nullable | Descripción |
|-----------|------|----------|-------------|
| id | String | ❌ | Identificador único |
| symbol | String | ❌ | Par de trading (ej: 'BTC-USDT') |
| side | String | ❌ | 'long' o 'short' |
| entryPrice | double | ❌ | Precio de entrada |
| currentPrice | double | ❌ | Precio actual |
| size | double | ❌ | Tamaño de la posición |
| leverage | double | ❌ | Apalancamiento (default: 1.0) |
| stopLoss | double | ✅ | Precio de stop loss |
| takeProfit | double | ✅ | Precio de take profit |
| unrealizedPnl | double | ❌ | P&L no realizado (default: 0.0) |
| realizedPnl | double | ❌ | P&L realizado (default: 0.0) |
| openTime | DateTime | ❌ | Momento de apertura |
| closeTime | DateTime | ✅ | Momento de cierre |
| strategy | String | ❌ | Estrategia que abrió la posición |
| status | String | ❌ | 'open', 'closing', 'closed' |

**Métodos**: `calculatePnlPercentage()`, `isProfitable`, `isOpen`

---

## Strategy Model

| Propiedad | Tipo | Nullable | Descripción |
|-----------|------|----------|-------------|
| name | String | ❌ | Nombre de la estrategia |
| active | bool | ❌ | Si está activa (default: false) |
| weight | double | ❌ | Peso 0.0-1.0 (default: 0.0) |
| performance | StrategyPerformance | ❌ | Métricas de rendimiento |
| config | Map<String, dynamic> | ✅ | Configuración opcional |

**Métodos**: `isPerformingWell`, `hasSufficientData`

### StrategyPerformance (Nested)

| Propiedad | Tipo | Nullable | Descripción |
|-----------|------|----------|-------------|
| totalTrades | int | ❌ | Total de trades (default: 0) |
| winningTrades | int | ❌ | Trades ganadores (default: 0) |
| losingTrades | int | ❌ | Trades perdedores (default: 0) |
| winRate | double | ❌ | Tasa de victorias % (default: 0.0) |
| totalPnl | double | ❌ | P&L total (default: 0.0) |
| avgWin | double | ❌ | Ganancia promedio (default: 0.0) |
| avgLoss | double | ❌ | Pérdida promedio (default: 0.0) |
| sharpeRatio | double | ❌ | Ratio de Sharpe (default: 0.0) |
| maxDrawdown | double | ❌ | Drawdown máximo (default: 0.0) |
| profitFactor | double | ❌ | Factor de beneficio (default: 0.0) |

---

## RiskState Model

| Propiedad | Tipo | Nullable | Descripción |
|-----------|------|----------|-------------|
| currentDrawdownDaily | double | ❌ | Drawdown diario % (default: 0.0) |
| currentDrawdownWeekly | double | ❌ | Drawdown semanal % (default: 0.0) |
| currentDrawdownMonthly | double | ❌ | Drawdown mensual % (default: 0.0) |
| totalExposure | double | ❌ | Exposición total (default: 0.0) |
| exposureBySymbol | Map<String, double> | ❌ | Exposición por símbolo (default: {}) |
| consecutiveLosses | int | ❌ | Pérdidas consecutivas (default: 0) |
| riskMode | String | ❌ | 'Conservative', 'Normal', 'Aggressive' |
| killSwitchActive | bool | ❌ | Kill switch activo (default: false) |
| lastUpdate | DateTime | ❌ | Última actualización |
| maxDailyDrawdown | double | ❌ | Límite diario (default: 5.0) |
| maxWeeklyDrawdown | double | ❌ | Límite semanal (default: 10.0) |
| maxMonthlyDrawdown | double | ❌ | Límite mensual (default: 15.0) |
| maxConsecutiveLosses | int | ❌ | Límite pérdidas (default: 3) |
| maxTotalExposure | double | ❌ | Límite exposición (default: 100.0) |

**Métodos**: `isHighRisk()`, `canTrade()`, `getRiskLevel()`, `getAvailableExposure()`, `getExposurePercentage()`

---

## Metrics Model

| Propiedad | Tipo | Nullable | Descripción |
|-----------|------|----------|-------------|
| totalTrades | int | ❌ | Total de trades (default: 0) |
| winningTrades | int | ❌ | Trades ganadores (default: 0) |
| losingTrades | int | ❌ | Trades perdedores (default: 0) |
| winRate | double | ❌ | Tasa de victorias % (default: 0.0) |
| totalPnl | double | ❌ | P&L total (default: 0.0) |
| dailyPnl | double | ❌ | P&L del día (default: 0.0) |
| weeklyPnl | double | ❌ | P&L de la semana (default: 0.0) |
| monthlyPnl | double | ❌ | P&L del mes (default: 0.0) |
| avgWin | double | ❌ | Ganancia promedio (default: 0.0) |
| avgLoss | double | ❌ | Pérdida promedio (default: 0.0) |
| profitFactor | double | ❌ | Factor de beneficio (default: 0.0) |
| sharpeRatio | double | ❌ | Ratio de Sharpe (default: 0.0) |
| maxDrawdown | double | ❌ | Drawdown máximo (default: 0.0) |
| activePositions | int | ❌ | Posiciones activas (default: 0) |
| avgLatencyMs | double | ❌ | Latencia promedio ms (default: 0.0) |
| avgSlippagePct | double | ❌ | Slippage promedio % (default: 0.0) |

**Métodos**: `isProfitable`, `isDailyProfitable`, `isPerformingWell`, `hasFastExecution`, `winLossRatio`

---

## SystemStatus Model

| Propiedad | Tipo | Nullable | Descripción |
|-----------|------|----------|-------------|
| running | bool | ❌ | Motor corriendo (default: false) |
| uptime | String | ❌ | Tiempo activo (default: '0s') |
| pairsCount | int | ❌ | Pares monitoreados (default: 0) |
| activeStrategies | int | ❌ | Estrategias activas (default: 0) |
| healthStatus | String | ❌ | 'healthy', 'degraded', 'unhealthy' |
| errors | List<String> | ❌ | Lista de errores (default: []) |
| timestamp | DateTime | ✅ | Timestamp del estado |

**Métodos**: `isHealthy`, `hasErrors`, `isOperational`, `uptimeSeconds`, `uptimeDuration`

---

## Trade Model

| Propiedad | Tipo | Nullable | Descripción |
|-----------|------|----------|-------------|
| id | String | ❌ | Identificador único |
| orderId | String | ❌ | ID de orden del exchange |
| symbol | String | ❌ | Par de trading |
| side | String | ❌ | 'buy' o 'sell' |
| type | String | ❌ | 'market', 'limit', 'stop' |
| price | double | ❌ | Precio de ejecución |
| size | double | ❌ | Tamaño de la orden |
| status | String | ❌ | 'pending', 'filled', 'cancelled', 'failed' |
| latencyMs | double | ❌ | Latencia en ms (default: 0.0) |
| timestamp | DateTime | ❌ | Momento de ejecución |
| fee | double | ✅ | Comisión pagada |
| feeCurrency | String | ✅ | Moneda de la comisión |
| slippagePct | double | ✅ | Porcentaje de slippage |

**Métodos**: `isBuy`, `isSell`, `isFilled`, `isPending`, `isFailed`, `isFastExecution`, `getTotalCost()`, `getEffectivePrice()`

---

## Convenciones de Naming

### JSON ↔ Dart

| JSON | Dart |
|------|------|
| entry_price | entryPrice |
| current_price | currentPrice |
| stop_loss | stopLoss |
| take_profit | takeProfit |
| unrealized_pnl | unrealizedPnl |
| open_time | openTime |
| total_trades | totalTrades |
| win_rate | winRate |
| avg_latency_ms | avgLatencyMs |

### Tipos de Datos

| Tipo Dart | JSON acepta |
|-----------|-------------|
| double | double, int, String |
| int | int, double, String |
| DateTime | String (ISO 8601) |
| bool | bool, int (0/1) |
| Map<String, double> | Object con valores numéricos |
| List<String> | Array de strings |

---

## Valores por Defecto

| Tipo | Default |
|------|---------|
| double | 0.0 |
| int | 0 |
| bool | false |
| String | '' o 'unknown' |
| List | [] |
| Map | {} |

---

## Estados Válidos

### Position.status
- `'open'` - Posición abierta
- `'closing'` - En proceso de cierre
- `'closed'` - Posición cerrada

### Position.side
- `'long'` - Compra (apuesta a subida)
- `'short'` - Venta (apuesta a bajada)

### Trade.side
- `'buy'` - Orden de compra
- `'sell'` - Orden de venta

### Trade.type
- `'market'` - Orden de mercado
- `'limit'` - Orden limitada
- `'stop'` - Orden stop

### Trade.status
- `'pending'` - Pendiente
- `'filled'` - Ejecutada
- `'cancelled'` - Cancelada
- `'failed'` - Fallida

### SystemStatus.healthStatus
- `'healthy'` - Sistema saludable
- `'degraded'` - Rendimiento degradado
- `'unhealthy'` - Sistema no saludable

### RiskState.riskMode
- `'Conservative'` - Conservador
- `'Normal'` - Normal
- `'Aggressive'` - Agresivo
- `'ControlledCrazy'` - Agresivo controlado

---

**Referencia creada**: 2025-11-16
**Versión**: 1.0.0
