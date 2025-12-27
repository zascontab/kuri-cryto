# 📚 API Endpoints Guide - Trading MCP Server

**Fecha**: 28 de Noviembre, 2025  
**Estado**: ✅ Producción

---

## 🎯 Información General

**Base URL**: `http://192.168.1.6:10600`  
**Autenticación**: ❌ NO requerida  
**Formato**: JSON  
**Protocolo**: HTTP

---

## 🚀 Endpoints Disponibles

### 1. Health Check

```bash
GET /health
```

**Respuesta**:
```json
{
  "status": "healthy",
  "uptime": "1h0m0s",
  "version": "1.0.0"
}
```

---

### 2. AI Bot Status

```bash
GET /api/v1/ai-bot/status
```

**Respuesta**:
```json
{
  "ai_enabled": true,
  "status": "ok"
}
```

---

### 3. Comprehensive Analysis ⭐

```bash
POST /api/v1/ai-bot/comprehensive-analysis
Content-Type: application/json

{
  "symbol": "DOGE-USDT",
  "exchange": "kucoin"
}
```

**Respuesta**:
```json
{
  "symbol": "DOGE-USDT",
  "exchange": "kucoin",
  "recommendation": {
    "action": "WAIT",
    "confidence": 0.5,
    "reasoning": [
      "RSI en zona neutral",
      "MACD sin dirección clara"
    ]
  },
  "technical_analysis": {
    "rsi": {
      "value": 65.7,
      "signal": "neutral"
    },
    "macd": {
      "value": 0.00023,
      "trend": "neutral"
    }
  },
  "current_price": {
    "current": 0.15712,
    "high_24h": 0.161,
    "low_24h": 0.15595
  },
  "futures_data": {
    "mark_price": 0.15712,
    "funding_rate": 0.0001
  },
  "scenarios": [...]
}
```

---

### 4. List Tools

```bash
GET /tools/list
```

**Respuesta**: Lista de 63+ herramientas MCP disponibles

---

### 5. Get Bot Config

```bash
GET /api/v1/ai-bot/config
```

---

### 6. Update Bot Config

```bash
POST /api/v1/ai-bot/config
Content-Type: application/json

{
  "confidence_threshold": 0.75,
  "dry_run": false
}
```

---

### 7. Start Bot

```bash
POST /api/v1/ai-bot/start
```

---

### 8. Stop Bot

```bash
POST /api/v1/ai-bot/stop
```

---

### 9. Get Positions

```bash
GET /api/v1/ai-bot/positions
```

---

## 📱 Integración con Flutter

### Setup del Cliente

```dart
import 'package:dio/dio.dart';

class TradingApiClient {
  final Dio dio = Dio();
  final String baseUrl = 'http://192.168.1.6:10600';

  // Constructor
  TradingApiClient() {
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  // Health Check
  Future<Map<String, dynamic>> getHealth() async {
    final response = await dio.get('/health');
    return response.data;
  }

  // AI Bot Status
  Future<Map<String, dynamic>> getAIBotStatus() async {
    final response = await dio.get('/api/v1/ai-bot/status');
    return response.data;
  }

  // Comprehensive Analysis
  Future<Map<String, dynamic>> getComprehensiveAnalysis({
    required String symbol,
    required String exchange,
  }) async {
    final response = await dio.post(
      '/api/v1/ai-bot/comprehensive-analysis',
      data: {
        'symbol': symbol,
        'exchange': exchange,
      },
    );
    return response.data;
  }

  // Start Bot
  Future<Map<String, dynamic>> startBot() async {
    final response = await dio.post('/api/v1/ai-bot/start');
    return response.data;
  }

  // Stop Bot
  Future<Map<String, dynamic>> stopBot() async {
    final response = await dio.post('/api/v1/ai-bot/stop');
    return response.data;
  }

  // Get Positions
  Future<Map<String, dynamic>> getPositions() async {
    final response = await dio.get('/api/v1/ai-bot/positions');
    return response.data;
  }

  // List Tools
  Future<List<dynamic>> listTools() async {
    final response = await dio.get('/tools/list');
    return response.data['categories']['trading'];
  }
}
```

### Ejemplo de Uso

```dart
void main() async {
  final client = TradingApiClient();

  try {
    // 1. Verificar health
    final health = await client.getHealth();
    print('Server Status: ${health['status']}');

    // 2. Obtener status del bot
    final status = await client.getAIBotStatus();
    print('Bot Status: ${status['status']}');

    // 3. Obtener análisis completo
    final analysis = await client.getComprehensiveAnalysis(
      symbol: 'DOGE-USDT',
      exchange: 'kucoin',
    );
    
    print('Symbol: ${analysis['symbol']}');
    print('Action: ${analysis['recommendation']['action']}');
    print('Confidence: ${analysis['recommendation']['confidence']}');
    print('Current Price: ${analysis['current_price']['current']}');

    // 4. Iniciar bot
    final startResult = await client.startBot();
    print('Bot Started: ${startResult['message']}');

    // 5. Obtener posiciones
    final positions = await client.getPositions();
    print('Open Positions: ${positions['count']}');

  } catch (e) {
    print('Error: $e');
  }
}
```

### Manejo de Errores

```dart
try {
  final analysis = await client.getComprehensiveAnalysis(
    symbol: 'DOGE-USDT',
    exchange: 'kucoin',
  );
} on DioException catch (e) {
  if (e.response != null) {
    print('Error ${e.response?.statusCode}: ${e.response?.data}');
  } else {
    print('Connection Error: ${e.message}');
  }
}
```

---

## 🧪 Testing con cURL

### Test Completo

```bash
#!/bin/bash

BASE_URL="http://192.168.1.6:10600"

echo "1. Health Check"
curl -s "$BASE_URL/health" | jq '.status'

echo -e "\n2. AI Bot Status"
curl -s "$BASE_URL/api/v1/ai-bot/status" | jq '.'

echo -e "\n3. Comprehensive Analysis"
curl -s -X POST "$BASE_URL/api/v1/ai-bot/comprehensive-analysis" \
  -H "Content-Type: application/json" \
  -d '{"symbol":"DOGE-USDT","exchange":"kucoin"}' \
  | jq '{symbol, recommendation, current_price}'

echo -e "\n4. List Tools"
curl -s "$BASE_URL/tools/list" | jq '.categories | keys'
```

---

## 📊 Respuestas de Error

### 400 Bad Request
```json
{
  "error": "Invalid request format",
  "details": "Missing required field: symbol"
}
```

### 404 Not Found
```json
{
  "error": "Endpoint not found"
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal server error",
  "details": "..."
}
```

---

## 🔧 Mantenimiento

### Verificar que el Servidor está Corriendo

```bash
systemctl status trading-mcp-server
```

### Ver Logs

```bash
journalctl -u trading-mcp-server -f
```

### Reiniciar Servidor

```bash
sudo systemctl restart trading-mcp-server
```

---

## 📝 Notas Importantes

1. ✅ **No se requiere autenticación** - Todos los endpoints son públicos
2. ✅ **Formato JSON** - Todas las peticiones y respuestas usan JSON
3. ✅ **CORS habilitado** - Puede ser accedido desde cualquier origen
4. ✅ **Timeout**: 30 segundos por defecto
5. ✅ **Puerto**: 10600 (MCP Server) y 9090 (Gateway)

---

## 🚨 Troubleshooting

### Problema: Connection Refused

**Solución**: Verificar que el servidor está corriendo
```bash
systemctl status trading-mcp-server
```

### Problema: Timeout

**Solución**: Verificar conectividad de red
```bash
ping 192.168.1.6
curl http://192.168.1.6:10600/health
```

### Problema: 500 Error

**Solución**: Ver logs del servidor
```bash
journalctl -u trading-mcp-server -n 50
```

---

**Documento generado por**: Backend Team  
**Fecha**: 2025-11-28  
**Estado**: ✅ **PRODUCCIÓN**
