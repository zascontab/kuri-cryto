# 🧪 Comandos de Verificación - Endpoints de Markets

**Fecha**: 27 de Noviembre, 2025  
**Propósito**: Comandos para verificar el comportamiento de los endpoints

---

## 📋 Endpoint: get_markets (NO funciona correctamente)

### Test 1: Futures
```bash
curl -s -X POST "http://192.168.100.145:9090/api/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_markets",
      "arguments": {
        "exchange": "kucoin",
        "market_type": "futures"
      }
    },
    "id": 1
  }' | jq '.'
```

**Resultado Esperado**: Pares de futures (BTCUSDTM, ETHUSDTM, etc.)  
**Resultado Actual**: ❌ ["BTC-USDT", "ETH-USDT", "SHIB-USDT"]

---

### Test 2: Spot
```bash
curl -s -X POST "http://192.168.100.145:9090/api/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_markets",
      "arguments": {
        "exchange": "kucoin",
        "market_type": "spot"
      }
    },
    "id": 1
  }' | jq '.'
```

**Resultado Esperado**: Pares de spot (BTC-USDT, ETH-USDT, etc.)  
**Resultado Actual**: ❌ ["BTC-USDT", "ETH-USDT", "SHIB-USDT"] (MISMO QUE FUTURES)

---

### Test 3: Comparar Respuestas
```bash
# Guardar respuesta de futures
curl -s -X POST "http://192.168.100.145:9090/api/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"get_markets","arguments":{"exchange":"kucoin","market_type":"futures"}},"id":1}' \
  > /tmp/futures_response.json

# Guardar respuesta de spot
curl -s -X POST "http://192.168.100.145:9090/api/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"get_markets","arguments":{"exchange":"kucoin","market_type":"spot"}},"id":1}' \
  > /tmp/spot_response.json

# Comparar
diff /tmp/futures_response.json /tmp/spot_response.json
```

**Resultado Esperado**: Archivos diferentes  
**Resultado Actual**: ❌ Sin diferencias (archivos idénticos)

---

## ✅ Endpoint: get_pairs_by_type (SÍ funciona correctamente)

### Test 1: Futures
```bash
curl -s -X POST "http://192.168.100.145:9090/api/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_pairs_by_type",
      "arguments": {
        "exchange": "kucoin",
        "market_type": "futures"
      }
    },
    "id": 1
  }' | jq '.'
```

**Resultado Esperado**: Pares de futures con sufijo M  
**Resultado Actual**: ✅ ["BTCUSDTM", "ETHUSDTM", "BNBUSDTM", "SOLUSDTM", ...]

---

### Test 2: Spot
```bash
curl -s -X POST "http://192.168.100.145:9090/api/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_pairs_by_type",
      "arguments": {
        "exchange": "kucoin",
        "market_type": "spot"
      }
    },
    "id": 1
  }' | jq '.'
```

**Resultado Esperado**: Pares de spot sin sufijo  
**Resultado Actual**: ✅ ["BTC-USDT", "ETH-USDT", "BNB-USDT", "SOL-USDT", ...]

---

### Test 3: Comparar Respuestas
```bash
# Guardar respuesta de futures
curl -s -X POST "http://192.168.100.145:9090/api/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"get_pairs_by_type","arguments":{"exchange":"kucoin","market_type":"futures"}},"id":1}' \
  > /tmp/futures_pbt_response.json

# Guardar respuesta de spot
curl -s -X POST "http://192.168.100.145:9090/api/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"get_pairs_by_type","arguments":{"exchange":"kucoin","market_type":"spot"}},"id":1}' \
  > /tmp/spot_pbt_response.json

# Comparar
diff /tmp/futures_pbt_response.json /tmp/spot_pbt_response.json
```

**Resultado Esperado**: Archivos diferentes  
**Resultado Actual**: ✅ Diferencias encontradas (archivos diferentes)

---

### Test 4: Verificar Features
```bash
# Futures features
curl -s -X POST "http://192.168.100.145:9090/api/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"get_pairs_by_type","arguments":{"exchange":"kucoin","market_type":"futures"}},"id":1}' \
  | jq '.result.features'
```

**Resultado Esperado**:
```json
{
  "has_leverage": true,
  "leverage_min": 1,
  "leverage_max": 100,
  "has_funding_rate": true,
  "has_liquidation": true
}
```

**Resultado Actual**: ✅ Correcto

---

```bash
# Spot features
curl -s -X POST "http://192.168.100.145:9090/api/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"get_pairs_by_type","arguments":{"exchange":"kucoin","market_type":"spot"}},"id":1}' \
  | jq '.result.features'
```

**Resultado Esperado**:
```json
{
  "has_leverage": false,
  "has_funding_rate": false,
  "has_liquidation": false
}
```

**Resultado Actual**: ✅ Correcto

---

## 📊 Resumen de Verificación

| Endpoint | Test | Resultado | Estado |
|----------|------|-----------|--------|
| **get_markets** | Futures | Devuelve BTC-USDT, ETH-USDT, SHIB-USDT | ❌ Incorrecto |
| **get_markets** | Spot | Devuelve BTC-USDT, ETH-USDT, SHIB-USDT | ❌ Incorrecto |
| **get_markets** | Comparación | Sin diferencias | ❌ Filtrado no funciona |
| **get_pairs_by_type** | Futures | Devuelve BTCUSDTM, ETHUSDTM, etc. | ✅ Correcto |
| **get_pairs_by_type** | Spot | Devuelve BTC-USDT, ETH-USDT, etc. | ✅ Correcto |
| **get_pairs_by_type** | Comparación | Archivos diferentes | ✅ Filtrado funciona |
| **get_pairs_by_type** | Features Futures | has_leverage: true | ✅ Correcto |
| **get_pairs_by_type** | Features Spot | has_leverage: false | ✅ Correcto |

---

## 🔧 Comandos Útiles

### Ver solo los pares (sin formato)
```bash
# get_markets - futures
curl -s -X POST "http://192.168.100.145:9090/api/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"get_markets","arguments":{"exchange":"kucoin","market_type":"futures"}},"id":1}' \
  | jq -r '.result.markets[]'

# get_pairs_by_type - futures
curl -s -X POST "http://192.168.100.145:9090/api/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"get_pairs_by_type","arguments":{"exchange":"kucoin","market_type":"futures"}},"id":1}' \
  | jq -r '.result.pairs[]'
```

### Contar pares
```bash
# get_markets
curl -s -X POST "http://192.168.100.145:9090/api/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"get_markets","arguments":{"exchange":"kucoin","market_type":"futures"}},"id":1}' \
  | jq '.result.count'

# get_pairs_by_type
curl -s -X POST "http://192.168.100.145:9090/api/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"get_pairs_by_type","arguments":{"exchange":"kucoin","market_type":"futures"}},"id":1}' \
  | jq '.result.count'
```

### Verificar si tiene formato enhanced
```bash
curl -s -X POST "http://192.168.100.145:9090/api/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"get_markets","arguments":{"exchange":"kucoin","market_type":"futures"}},"id":1}' \
  | jq 'has("result") and (.result | has("pairs"))'
```

**Resultado Esperado**: `true` (tiene campo "pairs")  
**Resultado Actual**: `false` (NO tiene campo "pairs", tiene "markets")

---

## 📝 Notas

- Todos los comandos usan `jq` para formatear JSON (instalar con `apt install jq` o `brew install jq`)
- La IP `192.168.100.145` es la del servidor backend
- El puerto `9090` es el API Gateway
- Todos los tests fueron verificados el 2025-11-27

---

**Generado por**: Flutter Team  
**Fecha**: 2025-11-27  
**Propósito**: Reproducir verificaciones
