# 🧪 Quick Test Commands - Market Types Support

Comandos rápidos para probar el soporte de market types con datos reales de KuCoin.

---

## 🚀 Tests Básicos

### 1. Get Ticker - Spot
```bash
curl -s -X POST "http://localhost:10600/api/v1/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_ticker",
      "arguments": {
        "exchange": "kucoin",
        "pair": "BTC-USDT",
        "market_type": "spot"
      }
    },
    "id": 1
  }' | jq '.result | {pair, last, bid, ask}'
```

### 2. Get Ticker - Futures (con conversión automática)
```bash
curl -s -X POST "http://localhost:10600/api/v1/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_ticker",
      "arguments": {
        "exchange": "kucoin",
        "pair": "BTC-USDT",
        "market_type": "futures"
      }
    },
    "id": 2
  }' | jq '.result | {pair, last, bid, ask}'
```

### 3. Get Candles - Futures
```bash
curl -s -X POST "http://localhost:10600/api/v1/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_candles",
      "arguments": {
        "exchange": "kucoin",
        "pair": "BTC-USDT",
        "interval": "1h",
        "limit": 5,
        "market_type": "futures"
      }
    },
    "id": 3
  }' | jq '.result[0] | {timestamp, open, high, low, close}'
```

### 4. Calculate RSI - Spot
```bash
curl -s -X POST "http://localhost:10600/api/v1/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "calculate_rsi",
      "arguments": {
        "exchange": "kucoin",
        "pair": "BTC-USDT",
        "period": 14,
        "market_type": "spot"
      }
    },
    "id": 4
  }' | jq '.result'
```

### 5. Calculate RSI - Futures
```bash
curl -s -X POST "http://localhost:10600/api/v1/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "calculate_rsi",
      "arguments": {
        "exchange": "kucoin",
        "pair": "BTC-USDT",
        "period": 14,
        "market_type": "futures"
      }
    },
    "id": 5
  }' | jq '.result'
```

---

## 🎯 Tests de Diferentes Pares

### ETH Futures
```bash
curl -s -X POST "http://localhost:10600/api/v1/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_ticker",
      "arguments": {
        "exchange": "kucoin",
        "pair": "ETH-USDT",
        "market_type": "futures"
      }
    },
    "id": 6
  }' | jq '.result | {pair, last}'
```

### DOGE Futures
```bash
curl -s -X POST "http://localhost:10600/api/v1/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_ticker",
      "arguments": {
        "exchange": "kucoin",
        "pair": "DOGE-USDT",
        "market_type": "futures"
      }
    },
    "id": 7
  }' | jq '.result | {pair, last}'
```

### SOL Futures
```bash
curl -s -X POST "http://localhost:10600/api/v1/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_ticker",
      "arguments": {
        "exchange": "kucoin",
        "pair": "SOL-USDT",
        "market_type": "futures"
      }
    },
    "id": 8
  }' | jq '.result | {pair, last}'
```

---

## 📊 Tests de Análisis Técnico

### MACD - Futures
```bash
curl -s -X POST "http://localhost:10600/api/v1/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "calculate_macd",
      "arguments": {
        "exchange": "kucoin",
        "pair": "BTC-USDT",
        "market_type": "futures"
      }
    },
    "id": 9
  }' | jq '.result'
```

---

## 💼 Tests de Portfolio

### Get Positions - All
```bash
curl -s -X POST "http://localhost:10600/api/v1/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_positions",
      "arguments": {
        "exchange": "kucoin"
      }
    },
    "id": 10
  }' | jq '.result'
```

### Get Positions - Futures Only
```bash
curl -s -X POST "http://localhost:10600/api/v1/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_positions",
      "arguments": {
        "exchange": "kucoin",
        "market_type": "futures"
      }
    },
    "id": 11
  }' | jq '.result'
```

---

## 🔄 Test de Backwards Compatibility

### Sin market_type (formato antiguo)
```bash
curl -s -X POST "http://localhost:10600/api/v1/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_ticker",
      "arguments": {
        "exchange": "kucoin",
        "pair": "BTCUSDTM"
      }
    },
    "id": 12
  }' | jq '.result | {pair, last}'
```

---

## 🎯 Test Comparativo: Spot vs Futures

```bash
echo "=== BTC-USDT SPOT ===" && \
curl -s -X POST "http://localhost:10600/api/v1/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_ticker",
      "arguments": {
        "exchange": "kucoin",
        "pair": "BTC-USDT",
        "market_type": "spot"
      }
    },
    "id": 1
  }' | jq '.result | {market: "SPOT", last, bid, ask}' && \
echo "" && \
echo "=== BTC-USDT FUTURES ===" && \
curl -s -X POST "http://localhost:10600/api/v1/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_ticker",
      "arguments": {
        "exchange": "kucoin",
        "pair": "BTC-USDT",
        "market_type": "futures"
      }
    },
    "id": 2
  }' | jq '.result | {market: "FUTURES", last, bid, ask}'
```

---

## 📋 Verificar Health del Servidor

```bash
curl -s http://localhost:10600/health | jq '.'
```

---

## 💡 Tips

1. **Instalar jq** (si no lo tienes):
   ```bash
   # Ubuntu/Debian
   sudo apt-get install jq
   
   # macOS
   brew install jq
   ```

2. **Ver respuesta completa** (sin jq):
   ```bash
   # Remover | jq '...' del final del comando
   ```

3. **Guardar resultados**:
   ```bash
   # Agregar al final: > resultado.json
   curl ... | jq '.' > resultado.json
   ```

4. **Test rápido de todos los pares**:
   ```bash
   for pair in BTC ETH DOGE SOL; do
     echo "=== $pair-USDT ==="
     curl -s -X POST "http://localhost:10600/api/v1/mcp/tools/execute" \
       -H "Content-Type: application/json" \
       -d "{
         \"jsonrpc\": \"2.0\",
         \"method\": \"tools/call\",
         \"params\": {
           \"name\": \"get_ticker\",
           \"arguments\": {
             \"exchange\": \"kucoin\",
             \"pair\": \"$pair-USDT\",
             \"market_type\": \"futures\"
           }
         },
         \"id\": 1
       }" | jq '.result | {pair, last}'
     echo ""
   done
   ```

---

## ✅ Resultados Esperados

Todos los comandos deberían retornar:
- ✅ Status 200
- ✅ Datos en tiempo real de KuCoin
- ✅ Formato JSON válido
- ✅ Sin errores

Si ves errores, verifica:
1. Servidor corriendo en puerto 10600
2. Credenciales de KuCoin configuradas
3. Conexión a internet activa
