# 🐛 Bug Report - MCP Server Timeout Issue

**Fecha**: 27 de Noviembre, 2025  
**Reportado por**: Flutter Team  
**Severidad**: 🔴 **ALTA** - Bloquea funcionalidad crítica  
**Componente**: MCP Server - `get_futures_positions` tool

---

## 📋 Resumen

El tool `get_futures_positions` causa **timeout** cuando se envía el parámetro `market_type`, bloqueando completamente la pantalla de posiciones en la app móvil.

---

## 🔍 Descripción del Problema

### Comportamiento Esperado:
```json
POST http://192.168.1.6:9090/api/mcp/tools/execute
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
  "id": 1
}
```
**Debería responder en < 2 segundos** con la lista de posiciones.

### Comportamiento Actual:
- ❌ **Timeout después de 10+ segundos**
- ❌ **No hay respuesta del servidor**
- ❌ **Request se queda colgado**
- ❌ **App móvil se queda en loading infinito**

---

## ✅ Pruebas Realizadas

### Test 1: Health Check del Gateway
```bash
curl http://192.168.1.6:9090/health
```
**Resultado**: ✅ **OK** (200, 0.85ms)
```json
{
  "gateway": "running",
  "services": {
    "mcp_server": "http://localhost:10600",
    "scalping_api": "http://localhost:8081"
  },
  "status": "ok"
}
```

### Test 2: Health Check del MCP Server
```bash
curl http://192.168.1.6:10600/health
```
**Resultado**: ✅ **OK** (200, 1.07ms)
```json
{
  "error_count": 34,
  "gct_connected": true,
  "request_count": 76,
  "status": "ok",
  "tools_count": 67
}
```

### Test 3: get_futures_positions CON market_type
```bash
curl -X POST http://192.168.1.6:9090/api/mcp/tools/execute \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_futures_positions",
      "arguments": {
        "exchange": "kucoin",
        "market_type": "futures"
      }
    },
    "id": 1
  }' \
  -m 10
```
**Resultado**: ❌ **TIMEOUT** (10+ segundos, 0 bytes recibidos)

### Test 4: get_futures_positions SIN market_type
```bash
curl -X POST http://192.168.1.6:10600/mcp \
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
  }' \
  -m 10
```
**Resultado**: ✅ **OK** (200, 0.44s)
```json
{
  "jsonrpc": "2.0",
  "result": {
    "count": 1,
    "exchange": "kucoin",
    "positions": [
      {
        "symbol": "DOGEUSDTM",
        "side": "short",
        "size": 2,
        "entry_price": 0.14997,
        "current_price": 0.15288,
        "unrealized_pnl": -0.582,
        "realized_pnl": -0.01390043,
        "leverage": 1,
        "margin": -29.994,
        "margin_mode": "ISOLATED",
        "liquidation_price": 0.29769,
        "pnl_percent": 1.940388077615523,
        "updated_at": "2025-11-27T10:20:00-05:00"
      }
    ],
    "total_unrealized_pnl": -0.582
  },
  "id": 1
}
```

### Test 5: Otros tools (get_ticker)
```bash
curl -X POST http://192.168.1.6:10600/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_ticker",
      "arguments": {
        "exchange": "kucoin",
        "pair": "BTC/USDT"
      }
    },
    "id": 1
  }'
```
**Resultado**: ✅ **OK** (responde rápido)

---

## 🎯 Conclusión

### El Bug:
El parámetro `market_type` en `get_futures_positions` causa que el tool:
1. Se quede esperando indefinidamente
2. No retorne respuesta
3. No genere timeout del lado del servidor
4. Bloquee el request completamente

### Impacto:
- 🔴 **CRÍTICO**: App móvil no puede cargar posiciones
- 🔴 **UX**: Usuario ve loading infinito
- 🔴 **Funcionalidad**: Feature de posiciones inutilizable

---

## 🔧 Workaround Temporal (Aplicado en Flutter)

Removimos el parámetro `market_type` del request:

```dart
// ANTES (causa timeout):
return await service.getPositions(
  exchange: exchange,
  marketType: 'futures',
);

// DESPUÉS (funciona):
return await service.getPositions(
  exchange: exchange,
  // marketType omitido
);
```

**Resultado**: ✅ App funciona correctamente ahora

---

## 🛠️ Acción Requerida del Backend Team

### 1. Investigar el Tool `get_futures_positions`

**Ubicación probable**: 
- `mcp_server/tools/get_futures_positions.py` (o similar)
- Handler del parámetro `market_type`

**Revisar**:
```python
# Buscar código similar a:
if 'market_type' in arguments:
    market_type = arguments['market_type']
    # ¿Hay algún loop infinito aquí?
    # ¿Hay algún await sin timeout?
    # ¿Hay alguna llamada a API externa que se cuelga?
```

### 2. Agregar Timeout

El tool debería tener un timeout máximo:
```python
import asyncio

async def get_futures_positions(exchange, market_type=None):
    try:
        # Agregar timeout de 5 segundos
        result = await asyncio.wait_for(
            fetch_positions(exchange, market_type),
            timeout=5.0
        )
        return result
    except asyncio.TimeoutError:
        return {
            "error": "Timeout fetching positions",
            "exchange": exchange,
            "market_type": market_type
        }
```

### 3. Logging

Agregar logs para diagnosticar:
```python
logger.info(f"get_futures_positions called: exchange={exchange}, market_type={market_type}")
# ... código ...
logger.info(f"get_futures_positions completed in {elapsed}s")
```

### 4. Validar Parámetro

Si `market_type` no es soportado, retornar error inmediatamente:
```python
if market_type and market_type not in ['spot', 'futures', 'margin', 'options']:
    return {
        "error": f"Invalid market_type: {market_type}",
        "valid_types": ['spot', 'futures', 'margin', 'options']
    }
```

---

## 📊 Datos de Reproducción

### Request que FALLA:
```bash
curl -X POST http://192.168.1.6:9090/api/mcp/tools/execute \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_futures_positions",
      "arguments": {
        "exchange": "kucoin",
        "market_type": "futures"
      }
    },
    "id": 1
  }' \
  -m 10
```
**Resultado**: Timeout después de 10 segundos

### Request que FUNCIONA:
```bash
curl -X POST http://192.168.1.6:10600/mcp \
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
**Resultado**: Respuesta exitosa en 0.44s

---

## 🎯 Prioridad

**ALTA** - Este bug bloquea una funcionalidad crítica de la app móvil.

### Impacto en Usuarios:
- No pueden ver sus posiciones de futures
- Experiencia de usuario degradada
- Pérdida de confianza en la app

### Impacto en Desarrollo:
- Tuvimos que remover el parámetro `market_type`
- No podemos filtrar por tipo de mercado
- Workaround temporal aplicado

---

## ✅ Verificación Post-Fix

Una vez corregido el bug, verificar que:

1. **Request con market_type responde en < 2s**:
```bash
curl -X POST http://192.168.1.6:10600/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_futures_positions",
      "arguments": {
        "exchange": "kucoin",
        "market_type": "futures"
      }
    },
    "id": 1
  }' \
  -w "\nTime: %{time_total}s\n"
```

2. **Respuesta incluye las posiciones correctamente**

3. **No hay timeouts en logs del servidor**

---

## 📞 Contacto

**Reportado por**: Flutter Team  
**Fecha**: 2025-11-27  
**Hora**: 10:12 AM (COT)

**Para más información o aclaraciones, contactar al equipo de Flutter.**

---

## 📎 Archivos Relacionados

**Backend** (probablemente):
- `mcp_server/tools/get_futures_positions.py`
- `mcp_server/handlers/futures_handler.py`
- `mcp_server/routes/tools.py`

**Flutter** (workaround aplicado):
- `lib/providers/futures_provider.dart` (línea 47)
- `lib/services/futures_service.dart` (línea 30-40)

---

## 🔄 Estado

- [x] Bug identificado
- [x] Workaround aplicado en Flutter
- [x] **RESUELTO**: Fix aplicado en backend ✅
- [x] **COMPLETADO**: Verificación post-fix ✅
- [x] **COMPLETADO**: Re-habilitado market_type en Flutter ✅
- [x] **VERIFICADO**: Confirmación oficial del equipo de backend ✅

---

## 🎯 Verificación Oficial del Backend Team

**Fecha**: 2025-11-27 10:45 AM (COT)  
**Reporte completo**: [BUG_VERIFICATION_REPORT.md](lib/docs/bug/BUG_VERIFICATION_REPORT.md)

### ✅ Tests Realizados por Backend:

1. **WITH market_type** (antes causaba timeout) ✅
   - Tiempo: 0.675 segundos (antes: 10+ seg timeout)
   - Status: 200 OK
   - Mejora: **15x más rápido**

2. **WITHOUT market_type** (backwards compatibility) ✅
   - Funciona como antes
   - Sin breaking changes

3. **Invalid market_type** (validación) ✅
   - Error inmediato (no timeout)
   - Mensaje claro de validación

4. **Through Gateway** (como lo usa Flutter) ✅
   - Tiempo: 0.526 segundos
   - Funciona correctamente

### 🔧 Causa Raíz Identificada:

El parámetro `market_type` estaba **documentado** pero **NO implementado** en el código.

### 🛠️ Solución Aplicada:

1. ✅ Agregado `market_type` al InputSchema
2. ✅ Agregada validación de valores
3. ✅ Implementada lógica de filtrado
4. ✅ Agregado manejo de errores
5. ✅ Mantenida backwards compatibility

### 📊 Comparativa de Rendimiento:

| Escenario | Antes | Después | Mejora |
|-----------|-------|---------|--------|
| WITH market_type | 10+ seg (timeout) | 0.675 seg | ✅ 15x |
| WITHOUT market_type | 0.44 seg | < 1 seg | ✅ OK |
| Invalid market_type | 10+ seg (timeout) | Error inmediato | ✅ Instant |
| Through Gateway | Timeout | 0.526 seg | ✅ Fixed |

### 📱 Para Flutter Team:

El parámetro `market_type` ya está completamente funcional y puede ser usado sin problemas:

```dart
// ✅ FUNCIONA CORRECTAMENTE:
return await service.getPositions(
  exchange: exchange,
  marketType: 'futures',  // ✅ Backend fixed!
);
```

---

**¡Bug completamente resuelto y verificado en producción!** ✅

---

*Generado automáticamente por Kiro AI Assistant*  
*Timestamp inicial: 2025-11-27T10:12:00-05:00*  
*Actualizado: 2025-11-27T10:45:00-05:00*
