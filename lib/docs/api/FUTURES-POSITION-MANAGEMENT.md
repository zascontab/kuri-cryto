# 📊 Gestión de Posiciones de Futuros

**Guía completa para manejar posiciones de futuros en KuCoin**

---

## 🎯 Resumen Ejecutivo

El sistema de gestión de posiciones de futuros funciona correctamente. Esta guía explica:
- Cómo obtener posiciones abiertas
- Cómo cerrar posiciones completamente
- Comportamiento esperado de la API
- Casos de uso comunes

---

## 📋 Endpoints Disponibles

### 1. Ver Posiciones Abiertas

**Endpoint**: `get_futures_positions`

```bash
curl -X POST http://192.168.100.145:9090/api/mcp/tools/execute \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_futures_positions",
      "arguments": {
        "exchange": "kucoin"
      }
    },
    "id": 1
  }'
```

**Respuesta**:
```json
{
  "jsonrpc": "2.0",
  "result": {
    "count": 1,
    "exchange": "kucoin",
    "positions": [
      {
        "symbol": "DOGEUSDTM",
        "side": "long",
        "size": 4,
        "entry_price": 0.15759,
        "current_price": 0.15752,
        "unrealized_pnl": -0.027,
        "realized_pnl": -0.037821,
        "leverage": 5,
        "margin": 63.035,
        "margin_mode": "ISOLATED",
        "liquidation_price": 0.12704,
        "pnl_percent": -0.04,
        "updated_at": "2025-11-19T23:10:53-05:00"
      }
    ],
    "total_unrealized_pnl": -0.027
  },
  "id": 1
}
```

**Campos Importantes**:
- `symbol`: Símbolo del contrato (formato futuros: `DOGEUSDTM`)
- `side`: Dirección de la posición (`long` o `short`)
- `size`: Tamaño en contratos
- `entry_price`: Precio de entrada promedio
- `current_price`: Precio actual (mark price)
- `unrealized_pnl`: PnL no realizado en USDT
- `leverage`: Apalancamiento actual
- `margin`: Margen usado en USDT
- `liquidation_price`: Precio de liquidación

---

### 2. Cerrar Posición

**Endpoint**: `close_futures_position`

```bash
curl -X POST http://192.168.100.145:9090/api/mcp/tools/execute \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "close_futures_position",
      "arguments": {
        "exchange": "kucoin",
        "symbol": "DOGEUSDTM"
      }
    },
    "id": 1
  }'
```

**Respuesta**:
```json
{
  "jsonrpc": "2.0",
  "result": {
    "exchange": "kucoin",
    "symbol": "DOGEUSDTM",
    "status": "closed",
    "side": "long",
    "size": 4,
    "entry_price": 0.15759,
    "exit_price": 0.15752,
    "unrealized_pnl": -0.027,
    "realized_pnl": -0.037821,
    "total_pnl": -0.064821,
    "pnl_percent": -0.04,
    "leverage": 5,
    "margin_mode": "ISOLATED"
  },
  "id": 1
}
```

---

## ✅ Comportamiento Correcto

### Cierre Completo de Posición

**El endpoint `close_futures_position` cierra TODA la posición en una sola llamada.**

**Proceso interno**:
1. Obtiene la posición actual de KuCoin
2. Lee el tamaño total (`size`)
3. Coloca una orden de mercado opuesta con flag `reduce-only`
4. Cierra todos los contratos de una vez

**Ejemplo**:
```
Posición inicial: 4 contratos LONG
↓
Llamada a close_futures_position
↓
Orden: SELL 4 contratos (reduce-only)
↓
Resultado: Posición cerrada completamente
```

---

## ⚠️ Casos Especiales

### Múltiples Llamadas

Si llamas `close_futures_position` múltiples veces seguidas:

**Primera llamada**:
- Posición: 4 contratos
- Cierra: 4 contratos
- Resultado: Posición cerrada ✅

**Segunda llamada** (si la haces inmediatamente):
- Error: "No open position found" ❌

**Esto es correcto** - la posición ya fue cerrada.

---

### Actualización en Tiempo Real

KuCoin actualiza las posiciones en tiempo real. Si tienes:

```
Posición inicial: 4 contratos
```

Y cierras manualmente 1 contrato desde otro lugar (web, app móvil), entonces:

```
get_futures_positions → size: 3 contratos
close_futures_position → cierra los 3 restantes
```

**Esto es el comportamiento esperado** - el sistema siempre cierra el tamaño actual.

---

## 🔧 Implementación en Flutter

### Obtener Posiciones

```dart
Future<List<Map<String, dynamic>>> getFuturesPositions() async {
  final dio = Dio();
  final response = await dio.post(
    'http://192.168.100.145:9090/api/mcp/tools/execute',
    data: {
      'jsonrpc': '2.0',
      'method': 'tools/call',
      'params': {
        'name': 'get_futures_positions',
        'arguments': {
          'exchange': 'kucoin',
        }
      },
      'id': 1,
    },
  );
  
  return List<Map<String, dynamic>>.from(
    response.data['result']['positions']
  );
}
```

### Cerrar Posición

```dart
Future<Map<String, dynamic>> closeFuturesPosition(String symbol) async {
  final dio = Dio();
  final response = await dio.post(
    'http://192.168.100.145:9090/api/mcp/tools/execute',
    data: {
      'jsonrpc': '2.0',
      'method': 'tools/call',
      'params': {
        'name': 'close_futures_position',
        'arguments': {
          'exchange': 'kucoin',
          'symbol': symbol,
        }
      },
      'id': 1,
    },
  );
  
  return response.data['result'];
}
```

### Widget de Posiciones

```dart
class PositionsWidget extends StatefulWidget {
  @override
  State<PositionsWidget> createState() => _PositionsWidgetState();
}

class _PositionsWidgetState extends State<PositionsWidget> {
  List<Map<String, dynamic>> positions = [];
  bool loading = true;
  
  @override
  void initState() {
    super.initState();
    loadPositions();
  }
  
  Future<void> loadPositions() async {
    setState(() => loading = true);
    try {
      positions = await getFuturesPositions();
    } catch (e) {
      print('Error: $e');
    }
    setState(() => loading = false);
  }
  
  Future<void> closePosition(String symbol) async {
    try {
      final result = await closeFuturesPosition(symbol);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Position closed: PnL \$${result['total_pnl'].toStringAsFixed(2)}'
          ),
        ),
      );
      
      // Recargar posiciones
      await loadPositions();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (positions.isEmpty) {
      return Center(child: Text('No open positions'));
    }
    
    return ListView.builder(
      itemCount: positions.length,
      itemBuilder: (context, index) {
        final pos = positions[index];
        final pnl = pos['unrealized_pnl'] as double;
        final pnlColor = pnl >= 0 ? Colors.green : Colors.red;
        
        return Card(
          child: ListTile(
            title: Text(
              '${pos['symbol']} - ${pos['side'].toUpperCase()}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Size: ${pos['size']} contracts'),
                Text('Entry: \$${pos['entry_price']}'),
                Text('Current: \$${pos['current_price']}'),
                Text('Leverage: ${pos['leverage']}x'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\$${pnl.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: pnlColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${pos['pnl_percent'].toStringAsFixed(2)}%',
                  style: TextStyle(color: pnlColor, fontSize: 12),
                ),
              ],
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Close Position?'),
                  content: Text(
                    'Close ${pos['symbol']} position?\n'
                    'Current PnL: \$${pnl.toStringAsFixed(2)}'
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        closePosition(pos['symbol']);
                      },
                      child: Text('Close'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
```

---

## 🎯 Casos de Uso

### 1. Cerrar Todas las Posiciones

```dart
Future<void> closeAllPositions() async {
  final positions = await getFuturesPositions();
  
  for (var pos in positions) {
    try {
      await closeFuturesPosition(pos['symbol']);
      print('Closed ${pos['symbol']}');
    } catch (e) {
      print('Error closing ${pos['symbol']}: $e');
    }
  }
}
```

### 2. Cerrar Posiciones con Pérdida

```dart
Future<void> closeLosingPositions() async {
  final positions = await getFuturesPositions();
  
  for (var pos in positions) {
    if (pos['unrealized_pnl'] < 0) {
      await closeFuturesPosition(pos['symbol']);
      print('Closed losing position: ${pos['symbol']}');
    }
  }
}
```

### 3. Cerrar Posiciones con Ganancia

```dart
Future<void> closeProfitablePositions() async {
  final positions = await getFuturesPositions();
  
  for (var pos in positions) {
    if (pos['unrealized_pnl'] > 0) {
      await closeFuturesPosition(pos['symbol']);
      print('Closed profitable position: ${pos['symbol']}');
    }
  }
}
```

### 4. Stop Loss Automático

```dart
Future<void> checkStopLoss(double maxLossPercent) async {
  final positions = await getFuturesPositions();
  
  for (var pos in positions) {
    final pnlPercent = pos['pnl_percent'] as double;
    
    if (pnlPercent < -maxLossPercent) {
      await closeFuturesPosition(pos['symbol']);
      print('Stop loss triggered for ${pos['symbol']}: ${pnlPercent}%');
    }
  }
}

// Uso:
await checkStopLoss(5.0); // Cierra si pérdida > 5%
```

---

## 🔍 Troubleshooting

### Error: "No open position found"

**Causa**: La posición ya fue cerrada o no existe.

**Solución**: Verifica primero con `get_futures_positions`.

```dart
final positions = await getFuturesPositions();
if (positions.any((p) => p['symbol'] == 'DOGEUSDTM')) {
  await closeFuturesPosition('DOGEUSDTM');
} else {
  print('Position not found');
}
```

### Error: "Insufficient balance"

**Causa**: No hay suficiente balance para pagar las comisiones.

**Solución**: Asegúrate de tener al menos $1 USDT disponible en la cuenta de futuros.

### Símbolo Incorrecto

**❌ Incorrecto**: `DOGE-USDT` (formato spot)
**✅ Correcto**: `DOGEUSDTM` (formato futuros)

**Conversión**:
```dart
String convertToFuturesSymbol(String spotPair) {
  // DOGE-USDT → DOGEUSDTM
  return spotPair.replaceAll('-', '') + 'M';
}
```

---

## 📊 Resumen

| Característica | Comportamiento |
|---------------|----------------|
| Cierre de posición | ✅ Completo en una llamada |
| Orden usada | Market con reduce-only |
| Seguridad | ✅ No puede abrir nueva posición |
| Actualización | Tiempo real desde KuCoin |
| Formato símbolo | `DOGEUSDTM`, `BTCUSDTM` |
| PnL retornado | Total (realizado + no realizado) |

---

## 🎓 Conclusión

El sistema de gestión de posiciones funciona correctamente:
- ✅ `get_futures_positions` obtiene todas las posiciones actuales
- ✅ `close_futures_position` cierra completamente la posición en una llamada
- ✅ Usa órdenes seguras (reduce-only)
- ✅ Retorna PnL final y detalles de ejecución

**No hay bugs en el código** - el comportamiento observado es el esperado cuando se hacen múltiples llamadas manuales.

---

**Última actualización**: 19 Nov 2025, 23:30 hrs


---

## 🆕 Troubleshooting (Updated 2025-11-21)

### Problemas Comunes con Futuros

Si encuentras problemas al operar futuros en KuCoin:

📁 **Ver:** [Troubleshooting KuCoin Auth](troubleshooting-kucoin-auth-2025-11-21/)

**Problemas resueltos:**
1. **"Insufficient balance"** → Fondos en spot, no en futures
   - Solución: Transferir de spot a futures con `./scripts/check_balance.py`

2. **"Trading pair not enabled"** → Par no habilitado en configuración
   - Solución: Verificar con `./scripts/pre_trading_check.sh`

3. **Orden rechazada por tamaño** → Cálculo incorrecto del multiplicador
   - Solución: Usar `./scripts/calculate_order_size.py DOGEUSDTM 30 --leverage 5`

4. **GoCryptoTrader no conecta** → Proceso no está corriendo
   - Solución: `./scripts/start_gocryptotrader.sh`

**Scripts útiles para futuros:**
```bash
# Verificar sistema
./scripts/pre_trading_check.sh

# Ver balance en futuros
./scripts/check_balance.py

# Calcular orden segura
./scripts/calculate_order_size.py SYMBOL BALANCE --leverage X

# Monitorear posiciones
./scripts/monitor_positions.py --interval 60
```

---

**Last Updated**: 21 November 2025, 22:45 hrs
