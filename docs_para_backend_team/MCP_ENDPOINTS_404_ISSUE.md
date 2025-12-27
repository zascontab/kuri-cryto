# 🚨 ISSUE CRÍTICO: Endpoints MCP No Disponibles

**Fecha:** 15 de Diciembre, 2025  
**Prioridad:** ALTA  
**Afecta:** Funcionalidad de posiciones y herramientas MCP  
**Estado:** BLOQUEANTE para funcionalidad completa  

## 📋 Resumen del Problema

La aplicación Flutter no puede acceder a las herramientas MCP (Model Context Protocol) porque los endpoints no están disponibles o configurados correctamente en el backend.

## 🔍 Análisis Técnico

### Error Observado
```
DioException [bad response]: status code 404
URI: http://192.168.1.6:9090/api/mcp/tools/execute
Response: "404 page not found"
```

### Request Enviado por Flutter
```json
{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "params": {
    "name": "get_futures_positions",
    "arguments": {
      "exchange": "kucoin",
      "market_type": "futures"
    }
  },
  "id": 1765812095225
}
```

### Estado de Servicios
- ✅ **Gateway (Puerto 9090):** Funcionando
  - `GET /api/scalping/api/v1/scalping/status` → 200 OK
  - `GET /api/scalping/api/v1/scalping/metrics` → 200 OK
- ✅ **MCP Server (Puerto 10600):** Funcionando
  - `GET /health` → 200 OK
- ❌ **Endpoint MCP via Gateway:** NO DISPONIBLE
  - `POST /api/mcp/tools/execute` → 404 Not Found
- ❌ **Endpoint MCP Directo:** NO DISPONIBLE
  - `POST /tools/execute` → 404 Not Found

## 🎯 Herramientas MCP Requeridas

La aplicación Flutter necesita acceso a estas herramientas MCP:

### Posiciones y Trading
- `get_futures_positions` - Obtener posiciones de futuros
- `get_spot_positions` - Obtener posiciones spot
- `get_margin_positions` - Obtener posiciones margin
- `get_options_positions` - Obtener posiciones opciones

### Indicadores Técnicos
- `calculate_rsi` - Calcular RSI
- `calculate_macd` - Calcular MACD
- `calculate_bollinger_bands` - Calcular Bandas de Bollinger
- `get_technical_analysis` - Análisis técnico completo

### AI y Análisis
- `get_comprehensive_analysis` - Análisis comprehensivo con AI
- `get_sentiment_analysis` - Análisis de sentimiento
- `get_market_prediction` - Predicciones de mercado

### Bot Control
- `start_ai_bot` - Iniciar bot autónomo
- `stop_ai_bot` - Detener bot autónomo
- `get_bot_status` - Estado del bot
- `configure_bot` - Configurar bot

## 🛠️ Soluciones Requeridas

### Opción 1: Configurar Gateway (RECOMENDADA)
Configurar el gateway (puerto 9090) para proxy las requests MCP al servidor MCP (puerto 10600).

**Configuración necesaria en Gateway:**
```nginx
# Ejemplo para Nginx/Kong Gateway
location /api/mcp/ {
    proxy_pass http://localhost:10600/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

**Endpoints esperados:**
- `POST /api/mcp/tools/execute` → Proxy a `POST localhost:10600/tools/execute`
- `GET /api/mcp/health` → Proxy a `GET localhost:10600/health`
- `GET /api/mcp/tools/list` → Proxy a `GET localhost:10600/tools/list`

### Opción 2: Implementar Endpoints en MCP Server
Si el MCP Server no tiene los endpoints, implementarlos:

**Endpoints requeridos en MCP Server (puerto 10600):**
```
POST /tools/execute
GET /health
GET /tools/list
POST /ai-bot/start
POST /ai-bot/stop
GET /ai-bot/status
POST /ai-bot/configure
```

## 📊 Impacto en Funcionalidad

### Funcionalidades BLOQUEADAS:
- ❌ Ver posiciones abiertas (futures, spot, margin, options)
- ❌ Análisis técnico con indicadores
- ❌ Análisis AI comprehensivo
- ❌ Control del bot autónomo
- ❌ Predicciones de mercado
- ❌ Análisis de sentimiento

### Funcionalidades FUNCIONANDO:
- ✅ Estado del sistema scalping
- ✅ Métricas del sistema
- ✅ Navegación de la app
- ✅ Configuración

## 🔧 Testing y Verificación

### Para verificar la solución:

1. **Test básico de conectividad:**
```bash
curl -X POST http://192.168.1.6:9090/api/mcp/tools/execute \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"get_health","arguments":{}},"id":1}'
```

2. **Test de herramienta específica:**
```bash
curl -X POST http://192.168.1.6:9090/api/mcp/tools/execute \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"get_futures_positions","arguments":{"exchange":"kucoin","market_type":"futures"}},"id":1}'
```

3. **Respuesta esperada:**
```json
{
  "jsonrpc": "2.0",
  "result": {
    "positions": [...],
    "total_count": 0,
    "success": true
  },
  "id": 1
}
```

## 🛠️ Soluciones Requeridas

### Opción 1: Configurar Gateway (RECOMENDADA)
Configurar el gateway (puerto 9090) para proxy las requests MCP al servidor MCP (puerto 10600).

**Configuración necesaria en Gateway:**
```nginx
# Ejemplo para Nginx/Kong Gateway
location /api/mcp/ {
    proxy_pass http://localhost:10600/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

**Endpoints esperados:**
- `POST /api/mcp/tools/execute` → Proxy a `POST localhost:10600/tools/execute`
- `GET /api/mcp/health` → Proxy a `GET localhost:10600/health`
- `GET /api/mcp/tools/list` → Proxy a `GET localhost:10600/tools/list`

### Opción 2: Implementar Endpoints en MCP Server
Si el MCP Server no tiene los endpoints, implementarlos:

**Endpoints requeridos en MCP Server (puerto 10600):**
```
POST /tools/execute
GET /health
GET /tools/list
POST /ai-bot/start
POST /ai-bot/stop
GET /ai-bot/status
POST /ai-bot/configure
```

### Opción 3: Configuración Temporal (Flutter)
Mientras se implementa la solución backend, podemos configurar Flutter para usar endpoints alternativos o mocks.

## 📊 Impacto en Funcionalidad

### Funcionalidades BLOQUEADAS:
- ❌ Ver posiciones abiertas (futures, spot, margin, options)
- ❌ Análisis técnico con indicadores
- ❌ Análisis AI comprehensivo
- ❌ Control del bot autónomo
- ❌ Predicciones de mercado
- ❌ Análisis de sentimiento

### Funcionalidades FUNCIONANDO:
- ✅ Estado del sistema scalping
- ✅ Métricas del sistema
- ✅ Navegación de la app
- ✅ Configuración

## 🔧 Testing y Verificación

### Para verificar la solución:

1. **Test básico de conectividad:**
```bash
curl -X POST http://192.168.1.6:9090/api/mcp/tools/execute \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"get_health","arguments":{}},"id":1}'
```

2. **Test de herramienta específica:**
```bash
curl -X POST http://192.168.1.6:9090/api/mcp/tools/execute \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"get_futures_positions","arguments":{"exchange":"kucoin","market_type":"futures"}},"id":1}'
```

3. **Respuesta esperada:**
```json
{
  "jsonrpc": "2.0",
  "result": {
    "positions": [...],
    "total_count": 0,
    "success": true
  },
  "id": 1
}
```

## 📋 Checklist para Backend Team

### Investigación
- [ ] Verificar si MCP Server tiene endpoints implementados
- [ ] Verificar configuración del Gateway para rutas MCP
- [ ] Revisar logs del MCP Server para errores
- [ ] Verificar si hay autenticación requerida

### Implementación
- [ ] Configurar proxy en Gateway: `/api/mcp/*` → `localhost:10600/*`
- [ ] Implementar endpoint `POST /tools/execute` en MCP Server
- [ ] Implementar endpoint `GET /tools/list` en MCP Server
- [ ] Verificar formato JSON-RPC 2.0 en respuestas

### Testing
- [ ] Test de conectividad básica
- [ ] Test de herramientas específicas
- [ ] Test de manejo de errores
- [ ] Test de timeout y performance

### Documentación
- [ ] Documentar endpoints MCP disponibles
- [ ] Documentar formato de requests/responses
- [ ] Actualizar documentación de API Gateway

## 🚀 Próximos Pasos

1. **INMEDIATO:** Investigar configuración actual del MCP Server
2. **CORTO PLAZO:** Implementar proxy en Gateway o endpoints en MCP Server
3. **MEDIANO PLAZO:** Testing completo de todas las herramientas MCP
4. **LARGO PLAZO:** Documentación completa de la API MCP

## 📞 Información Técnica Adicional

### Configuración Actual Flutter
- **IP del servidor:** `192.168.1.6`
- **Puerto Gateway:** `9090`
- **Puerto MCP Server:** `10600`
- **Archivo de configuración:** `lib/config/api_config.dart`

### URLs Configuradas en Flutter
```dart
// Actual (NO FUNCIONA)
static String get mcpToolsUrl => '$gatewayBaseUrl/api/mcp/tools/execute';

// Alternativa directa (TEMPORAL)
static String get mcpToolsUrl => '$mcpDirectUrl/tools/execute';
```

### Logs de Error Completos
```
[API] *** DioException ***:
[API] uri: http://192.168.1.6:9090/api/mcp/tools/execute
[API] DioException [bad response]: status code 404
[API] Response Text: 404 page not found
```

---

**⚠️ NOTA IMPORTANTE:** Este issue está bloqueando funcionalidades críticas de la aplicación. Se requiere atención inmediata del equipo de backend para restaurar la funcionalidad completa.

**📧 Contacto:** Para dudas técnicas, revisar logs en Flutter o usar scripts de testing en `scripts/test_connection.dart`