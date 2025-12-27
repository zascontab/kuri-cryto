#!/bin/bash
# Script de Verificación - Market Service Híbrido

echo "🧪 Verificando Market Service - Solución Híbrida"
echo "================================================"

# Test get_pairs_by_type - Futures
echo ""
echo "📊 Test: get_pairs_by_type - Futures"
curl -s -X POST "http://192.168.1.6:9090/api/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_pairs_by_type",
      "arguments": {"exchange": "kucoin", "market_type": "futures"}
    },
    "id": 1
  }' | jq '.result | {count, first_pair: .pairs[0], has_leverage: .features.has_leverage}'

echo ""
echo "📊 Test: get_pairs_by_type - Spot"
curl -s -X POST "http://192.168.1.6:9090/api/mcp/tools/execute" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_pairs_by_type",
      "arguments": {"exchange": "kucoin", "market_type": "spot"}
    },
    "id": 1
  }' | jq '.result | {count, first_pair: .pairs[0], has_leverage: .features.has_leverage}'

echo ""
echo "✅ Si ves 8 pares y diferentes símbolos, Fase 2 funciona correctamente"
