V 📊 Scalping Endpoints Specification

**Fecha**: 2025-11-27  
**Estado**: ✅ Implementado  
**Base URL**: `http://192.168.100.145:9090/api/scalping/api/v1/scalping`

---

## Endpoints Disponibles

### 1. Get Status

**Endpoint**: `GET /status`  
**Full URL**: `http://192.168.100.145:9090/api/scalping/api/v1/scalping/status`

#### Response (200 OK)
```json
{
  "status": "running",
  "active": false,
  "total_bots": 0,
  "active_bots": 0,
  "paused_bots": 0,
  "stopped_bots": 0,
  "timestamp": "2025-11-27T23:46:45-05:00"
}
```

#### Dart Model
```dart
class ScalpingStatus {
  final String status;
  final bool active;
  final int totalBots;
  final int activeBots;
  final int pausedBots;
  final int stoppedBots;
  final String timestamp;
  
  ScalpingStatus({
    required this.status,
    required this.active,
    required this.totalBots,
    required this.activeBots,
    required this.pausedBots,
    required this.stoppedBots,
    required this.timestamp,
  });
  
  factory ScalpingStatus.fromJson(Map<String, dynamic> json) {
    return ScalpingStatus(
      status: json['status'] as String,
      active: json['active'] as bool,
      totalBots: json['total_bots'] as int,
      activeBots: json['active_bots'] as int,
      pausedBots: json['paused_bots'] as int,
      stoppedBots: json['stopped_bots'] as int,
      timestamp: json['timestamp'] as String,
    );
  }
}
```

---

### 2. Get Metrics

**Endpoint**: `GET /metrics`  
**Full URL**: `http://192.168.100.145:9090/api/scalping/api/v1/scalping/metrics`

#### Response (200 OK)
```json
{
  "total_trades": 0,
  "successful_trades": 0,
  "failed_trades": 0,
  "total_pnl": 0.0,
  "total_volume": 0.0,
  "win_rate": 0.0,
  "avg_profit": 0.0,
  "avg_loss": 0.0,
  "timestamp": "2025-11-27T23:46:45-05:00"
}
```

#### Dart Model
```dart
class ScalpingMetrics {
  final int totalTrades;
  final int successfulTrades;
  final int failedTrades;
  final double totalPnl;
  final double totalVolume;
  final double winRate;
  final double avgProfit;
  final double avgLoss;
  final String timestamp;
  
  ScalpingMetrics({
    required this.totalTrades,
    required this.successfulTrades,
    required this.failedTrades,
    required this.totalPnl,
    required this.totalVolume,
    required this.winRate,
    required this.avgProfit,
    required this.avgLoss,
    required this.timestamp,
  });
  
  factory ScalpingMetrics.fromJson(Map<String, dynamic> json) {
    return ScalpingMetrics(
      totalTrades: json['total_trades'] as int,
      successfulTrades: json['successful_trades'] as int,
      failedTrades: json['failed_trades'] as int,
      totalPnl: (json['total_pnl'] as num).toDouble(),
      totalVolume: (json['total_volume'] as num).toDouble(),
      winRate: (json['win_rate'] as num).toDouble(),
      avgProfit: (json['avg_profit'] as num).toDouble(),
      avgLoss: (json['avg_loss'] as num).toDouble(),
      timestamp: json['timestamp'] as String,
    );
  }
}
```

---

### 3. Get Health

**Endpoint**: `GET /health`  
**Full URL**: `http://192.168.100.145:9090/api/scalping/api/v1/scalping/health`

#### Response (200 OK)
```json
{
  "status": "healthy",
  "timestamp": "2025-11-27T23:46:45.919340446-05:00"
}
```

#### Dart Model
```dart
class ScalpingHealth {
  final String status;
  final String timestamp;
  
  ScalpingHealth({
    required this.status,
    required this.timestamp,
  });
  
  factory ScalpingHealth.fromJson(Map<String, dynamic> json) {
    return ScalpingHealth(
      status: json['status'] as String,
      timestamp: json['timestamp'] as String,
    );
  }
}
```

---

## Notas Importantes

### ⚠️ Campos Requeridos

Todos los campos en las respuestas son **requeridos** y siempre estarán presentes. No usar campos opcionales en los modelos Dart.

### 📝 Formato de Timestamp

Los timestamps están en formato **RFC3339** (ISO 8601):
```
2025-11-27T23:46:45-05:00
```

Para parsear en Dart:
```dart
DateTime.parse(json['timestamp'])
```

### 🔢 Tipos de Datos

- **Integers**: `total_bots`, `total_trades`, etc. → `int`
- **Floats**: `total_pnl`, `win_rate`, etc. → `double`
- **Booleans**: `active` → `bool`
- **Strings**: `status`, `timestamp` → `String`

### ⚡ Estado Actual

Todos los endpoints retornan valores en **0** o **false** porque el sistema de scalping aún no está activo. Esto es normal y esperado.

---

## Testing

### cURL Examples

```bash
# Status
curl http://192.168.100.145:9090/api/scalping/api/v1/scalping/status

# Metrics
curl http://192.168.100.145:9090/api/scalping/api/v1/scalping/metrics

# Health
curl http://192.168.100.145:9090/api/scalping/api/v1/scalping/health
```

### Expected Behavior

- ✅ **200 OK**: Todos los endpoints responden correctamente
- ✅ **JSON válido**: Todas las respuestas son JSON bien formado
- ✅ **Campos consistentes**: Los campos siempre están presentes
- ✅ **Sin errores 502**: Gateway funciona correctamente

---

## Troubleshooting

### "Invalid response format"

Si Flutter muestra este error, verificar:

1. **Parsing correcto**: Usar los modelos Dart proporcionados
2. **Tipos de datos**: Asegurar conversiones correctas (num → double)
3. **Campos requeridos**: No usar campos opcionales
4. **Timestamp**: Parsear como String, no como DateTime directamente en fromJson

### Ejemplo de Parsing Seguro

```dart
factory ScalpingMetrics.fromJson(Map<String, dynamic> json) {
  try {
    return ScalpingMetrics(
      totalTrades: json['total_trades'] as int? ?? 0,
      successfulTrades: json['successful_trades'] as int? ?? 0,
      failedTrades: json['failed_trades'] as int? ?? 0,
      totalPnl: (json['total_pnl'] as num?)?.toDouble() ?? 0.0,
      totalVolume: (json['total_volume'] as num?)?.toDouble() ?? 0.0,
      winRate: (json['win_rate'] as num?)?.toDouble() ?? 0.0,
      avgProfit: (json['avg_profit'] as num?)?.toDouble() ?? 0.0,
      avgLoss: (json['avg_loss'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] as String? ?? '',
    );
  } catch (e) {
    print('Error parsing ScalpingMetrics: $e');
    print('JSON: $json');
    rethrow;
  }
}
```

---

## Contacto

Si hay problemas con el formato de respuesta, contactar al backend team con:
- El endpoint específico
- La respuesta JSON recibida
- El error exacto de parsing

**Backend Team**: Disponible para ajustar el formato según necesidades de Flutter.
