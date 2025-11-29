# 📊 Flutter - Gestión de Posiciones y Análisis Probabilístico

**Fecha:** 26 Noviembre 2025 | **Versión:** 1.0 | **Estado:** ✅ Producción

---

## 🎯 Qué Puedes Hacer

- ✅ Ver posiciones abiertas en tiempo real
- ✅ Análisis probabilístico de mercado (RSI, MACD, EMAs)
- ✅ Cerrar posiciones (total o parcial)
- ✅ Monitorear PnL en tiempo real
- ✅ Alertas de Stop Loss y Take Profit
- ✅ Análisis multi-timeframe

---

## 🔌 Endpoints Clave

### 1. Ver Posiciones Abiertas
```dart
POST /api/mcp/tools/execute
Tool: get_futures_positions
Exchange: kucoin
```

### 2. Cerrar Posición
```dart
POST /api/mcp/tools/execute
Tool: close_futures_position
Symbol: DOGEUSDTM
```

### 3. Análisis de Mercado
```dart
POST /api/mcp/tools/execute
Tool: calculate_rsi, calculate_macd, calculate_ema
```

---

## 📱 Código Flutter Listo para Usar

### Servicio de Posiciones

```dart
class PositionService {
  final Dio dio;
  static const baseUrl = 'http://192.168.100.145:10600';
  
  PositionService(this.dio);
  
  // Obtener posiciones abiertas
  Future<List<Position>> getPositions() async {
    final response = await dio.post(
      '$baseUrl/tools/call',
      data: {
        'jsonrpc': '2.0',
        'method': 'tools/call',
        'params': {
          'name': 'get_futures_positions',
          'arguments': {'exchange': 'kucoin'}
        },
        'id': 1,
      },
    );
    
    final positions = response.data['result']['positions'] as List;
    return positions.map((p) => Position.fromJson(p)).toList();
  }
  
  // Cerrar posición
  Future<void> closePosition(String symbol) async {
    await dio.post(
      '$baseUrl/tools/call',
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
  }
}
```

