# ⚡ Referencia Rápida - API Trading MCP

**Para consulta rápida durante desarrollo**

---

## 🌐 URLs

```dart
const BASE_URL = 'http://192.168.1.6:10600';
const GATEWAY_URL = 'http://192.168.1.6:9090';
```

---

## 🔥 Endpoints Más Usados

### Health Check
```dart
GET /health
// Response: {"status": "ok"}
```

### Análisis Completo ⭐
```dart
POST /api/v1/ai-bot/comprehensive-analysis
Body: {"symbol": "BTC-USDT", "exchange": "kucoin"}
```

### Estado del Bot
```dart
GET /api/v1/ai-bot/status
// Response: {"ai_enabled": true, "status": "ok"}
```

### Posiciones
```dart
GET /api/v1/ai-bot/positions
// Response: {"positions": [], "count": 0}
```

---

## 💻 Código Mínimo

```dart
import 'package:dio/dio.dart';

final dio = Dio()..options.baseUrl = 'http://192.168.1.6:10600';

// Health
final health = await dio.get('/health');

// Análisis
final analysis = await dio.post(
  '/api/v1/ai-bot/comprehensive-analysis',
  data: {'symbol': 'BTC-USDT', 'exchange': 'kucoin'},
);

print(analysis.data['recommendation']['action']); // BUY/SELL/WAIT
```

---

## 📊 Estructura de Respuesta - Análisis

```dart
{
  "symbol": "BTC-USDT",
  "current_price": {
    "current": 90873.0,
    "high_24h": 93259.62,
    "low_24h": 88710.37
  },
  "recommendation": {
    "action": "SELL",        // BUY, SELL, WAIT
    "confidence": 0.9,       // 0.0 - 1.0
    "reasoning": [...]
  },
  "multi_timeframe": {
    "15m": {"rsi": 74.45, "trend": "bearish"},
    "5m": {"rsi": 74.45, "trend": "bearish"}
  }
}
```

---

## 🎨 Ejemplo de UI

```dart
class AnalysisCard extends StatelessWidget {
  final Map<String, dynamic> analysis;

  @override
  Widget build(BuildContext context) {
    final rec = analysis['recommendation'];
    final price = analysis['current_price'];
    
    return Card(
      child: Column(
        children: [
          Text('\$${price['current']}',
            style: TextStyle(fontSize: 32)),
          
          Container(
            color: rec['action'] == 'BUY' ? Colors.green : 
                   rec['action'] == 'SELL' ? Colors.red : Colors.grey,
            child: Text(rec['action']),
          ),
          
          Text('Confianza: ${(rec['confidence'] * 100).toInt()}%'),
        ],
      ),
    );
  }
}
```

---

## 🚨 Manejo de Errores

```dart
try {
  final response = await dio.post(...);
} on DioException catch (e) {
  if (e.type == DioExceptionType.connectionTimeout) {
    print('Timeout');
  } else if (e.response?.statusCode == 500) {
    print('Error del servidor');
  } else {
    print('Error: ${e.message}');
  }
}
```

---

## 🧪 Test Rápido

```bash
# Health
curl http://192.168.1.6:10600/health

# Análisis
curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/comprehensive-analysis \
  -H "Content-Type: application/json" \
  -d '{"symbol":"BTC-USDT","exchange":"kucoin"}'
```

---

## 📱 Símbolos Soportados

- BTC-USDT
- ETH-USDT
- DOGE-USDT
- SOL-USDT
- XRP-USDT
- Y más...

---

## ⚙️ Configuración Dio

```dart
final dio = Dio()
  ..options.baseUrl = 'http://192.168.1.6:10600'
  ..options.connectTimeout = Duration(seconds: 30)
  ..options.receiveTimeout = Duration(seconds: 30)
  ..options.headers = {'Content-Type': 'application/json'};
```

---

## 🔍 Debug

```dart
// Agregar interceptor para ver requests
dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
));
```

---

**Más detalles**: Ver documentos completos en esta carpeta
