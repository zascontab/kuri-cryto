# 🔧 Deployment Troubleshooting - get_markets Enhanced

**Fecha**: 27 de Noviembre, 2025  
**Propósito**: Guía para diagnosticar y resolver problemas de deployment

---

## 🎯 Síntomas del Problema

### Síntoma 1: get_markets devuelve formato viejo
```json
{
  "result": {
    "count": 3,
    "exchange": "kucoin",
    "markets": ["BTC-USDT", "ETH-USDT", "SHIB-USDT"]
  }
}
```

**Causa**: Servidor ejecutando código viejo

### Síntoma 2: get_markets no filtra por market_type
```bash
# Spot y futures devuelven lo mismo
curl ... -d '{"market_type":"spot"}'    # ["BTC-USDT", "ETH-USDT", "SHIB-USDT"]
curl ... -d '{"market_type":"futures"}' # ["BTC-USDT", "ETH-USDT", "SHIB-USDT"]
```

**Causa**: Código enhanced no está desplegado

### Síntoma 3: get_pairs_by_type funciona pero get_markets no
**Causa**: Deployment parcial o binario viejo

---

## 🔍 Diagnóstico Paso a Paso

### Paso 1: Verificar Archivos del Código

```bash
# Verificar que los archivos nuevos existen
ls -la internal/mcp-trading/tools/marketdata/static_pairs.go
ls -la internal/mcp-trading/tools/marketdata/pairs_provider.go
ls -la internal/mcp-trading/tools/marketdata/pairs_cache.go
ls -la internal/mcp-trading/tools/marketdata/market_features.go
```

**Esperado**: Todos los archivos deben existir

**Si faltan archivos**:
```bash
# Verificar que estás en la rama correcta
git branch

# Verificar últimos commits
git log --oneline -5

# Pull últimos cambios
git pull origin <branch>
```

### Paso 2: Verificar Compilación

```bash
# Compilar con verbose
go build -v -o bin/trading-mcp-test ./cmd/mcp-server 2>&1 | grep marketdata
```

**Esperado**: Debe mostrar que compila los archivos nuevos:
```
github.com/rantipay/trading-mcp/internal/mcp-trading/tools/marketdata
```

**Si no compila los archivos nuevos**:
```bash
# Limpiar cache
go clean -cache
go clean -modcache

# Actualizar dependencias
go mod tidy

# Recompilar
go build -v -o bin/trading-mcp-test ./cmd/mcp-server
```

### Paso 3: Verificar Binario Desplegado

```bash
# Ver qué proceso está corriendo
ps aux | grep trading-mcp

# Ver la fecha del binario
ls -la bin/trading-mcp

# Ver la fecha de los archivos fuente
ls -la internal/mcp-trading/tools/marketdata/*.go
```

**Problema común**: El binario es más viejo que los archivos fuente

**Solución**:
```bash
# Recompilar
go build -o bin/trading-mcp-new ./cmd/mcp-server

# Verificar que es diferente
ls -la bin/trading-mcp*

# Si son diferentes, reemplazar
mv bin/trading-mcp bin/trading-mcp-old
mv bin/trading-mcp-new bin/trading-mcp
```

### Paso 4: Verificar Proceso en Ejecución

```bash
# Ver todos los procesos de trading-mcp
ps aux | grep trading-mcp

# Ver cuándo se inició el proceso
ps -eo pid,lstart,cmd | grep trading-mcp
```

**Problema común**: Proceso se inició antes de la última compilación

**Solución**:
```bash
# Detener todos los procesos
pkill -9 -f trading-mcp

# Verificar que no hay procesos
ps aux | grep trading-mcp

# Iniciar nuevo proceso
./bin/trading-mcp &

# Verificar que inició
ps aux | grep trading-mcp
```

### Paso 5: Verificar Endpoint

```bash
# Ejecutar script de verificación
./scripts/verify-markets-deployment.sh
```

**Esperado**: Todos los tests deben pasar

---

## 🚀 Soluciones Comunes

### Solución 1: Recompilación Limpia

```bash
# 1. Detener servidor
pkill -f trading-mcp

# 2. Limpiar todo
go clean -cache
go clean -modcache
rm -f bin/trading-mcp

# 3. Actualizar dependencias
go mod tidy

# 4. Recompilar
go build -o bin/trading-mcp ./cmd/mcp-server

# 5. Verificar compilación
ls -la bin/trading-mcp

# 6. Iniciar servidor
./bin/trading-mcp &

# 7. Esperar 5 segundos
sleep 5

# 8. Verificar
./scripts/verify-markets-deployment.sh
```

### Solución 2: Verificar Path del Main

```bash
# Buscar el archivo main.go
find . -name "main.go" -type f

# Intentar compilar desde cada ubicación
go build -o bin/trading-mcp ./cmd/mcp-server/main.go
# O
go build -o bin/trading-mcp ./main.go
# O
go build -o bin/trading-mcp .
```

### Solución 3: Verificar Imports

```bash
# Verificar que get_markets.go importa los paquetes correctos
grep "import" internal/mcp-trading/tools/marketdata/get_markets.go

# Verificar que register.go inicializa correctamente
grep "NewGetMarketsTool" internal/mcp-trading/tools/marketdata/register.go
```

**Esperado en register.go**:
```go
NewGetMarketsTool(client, pairsProvider)
```

**NO debe ser**:
```go
NewGetMarketsTool(client)  // ❌ Falta pairsProvider
```

### Solución 4: Verificar Logs

```bash
# Ver logs del servidor
tail -f logs/trading-mcp.log

# O si está en systemd
journalctl -u trading-mcp -f

# Buscar errores
grep -i error logs/trading-mcp.log
grep -i panic logs/trading-mcp.log
```

---

## 🔬 Debugging Avanzado

### Debug 1: Verificar que PairsProvider se inicializa

Agregar logs temporales en `register.go`:

```go
func RegisterAll(srv *server.MCPServer, client *gctclient.Client) error {
    pairsCache := NewPairsCache()
    pairsProvider := NewPairsProvider(client, pairsCache, nil)
    
    // DEBUG: Verificar que se inicializó
    fmt.Printf("DEBUG: PairsProvider initialized: %v\n", pairsProvider != nil)
    
    tools := []server.Tool{
        // ...
        NewGetMarketsTool(client, pairsProvider),
        // ...
    }
    
    return nil
}
```

### Debug 2: Verificar que Execute se llama

Agregar logs temporales en `get_markets.go`:

```go
func (t *GetMarketsTool) Execute(ctx context.Context, params map[string]interface{}) (interface{}, error) {
    // DEBUG: Verificar parámetros
    fmt.Printf("DEBUG: get_markets called with params: %+v\n", params)
    fmt.Printf("DEBUG: pairsProvider is nil: %v\n", t.pairsProvider == nil)
    
    // ... resto del código
}
```

### Debug 3: Verificar Static Pairs

```bash
# Crear un test simple
cat > test_static_pairs.go << 'EOF'
package main

import (
    "fmt"
    "github.com/rantipay/trading-mcp/internal/mcp-trading/tools/marketdata"
)

func main() {
    // Test spot
    spotType := "spot"
    spotPairs := marketdata.GetStaticPairs("kucoin", &spotType)
    fmt.Printf("Spot pairs: %d\n", len(spotPairs))
    
    // Test futures
    futuresType := "futures"
    futuresPairs := marketdata.GetStaticPairs("kucoin", &futuresType)
    fmt.Printf("Futures pairs: %d\n", len(futuresPairs))
    
    // Verificar que son diferentes
    if len(spotPairs) > 0 && len(futuresPairs) > 0 {
        fmt.Printf("First spot: %s\n", spotPairs[0].Symbol)
        fmt.Printf("First futures: %s\n", futuresPairs[0].Symbol)
    }
}
EOF

# Ejecutar test
go run test_static_pairs.go

# Limpiar
rm test_static_pairs.go
```

**Esperado**:
```
Spot pairs: 22
Futures pairs: 22
First spot: BTC-USDT
First futures: BTCUSDTM
```

---

## 📋 Checklist de Verificación

Antes de reportar que el problema persiste, verificar:

- [ ] Los archivos nuevos existen en el filesystem
- [ ] Los archivos se compilaron (go build -v muestra los archivos)
- [ ] El binario es más nuevo que los archivos fuente
- [ ] No hay procesos viejos corriendo
- [ ] El servidor se reinició después de recompilar
- [ ] El script de verificación se ejecutó
- [ ] Los logs no muestran errores
- [ ] get_pairs_by_type funciona (para confirmar que el servidor responde)

---

## 🆘 Si Todo Falla

### Opción 1: Deployment desde Cero

```bash
# 1. Backup del código actual
cp -r . ../trading-mcp-backup

# 2. Clonar repositorio fresco
cd ..
git clone <repo-url> trading-mcp-fresh
cd trading-mcp-fresh

# 3. Checkout a la rama correcta
git checkout <branch>

# 4. Compilar
go mod download
go build -o bin/trading-mcp ./cmd/mcp-server

# 5. Copiar configuración
cp ../trading-mcp/.env .
cp -r ../trading-mcp/config .

# 6. Iniciar
./bin/trading-mcp &

# 7. Verificar
./scripts/verify-markets-deployment.sh
```

### Opción 2: Usar Docker

```bash
# Crear Dockerfile
cat > Dockerfile << 'EOF'
FROM golang:1.21-alpine

WORKDIR /app
COPY . .

RUN go mod download
RUN go build -o trading-mcp ./cmd/mcp-server

CMD ["./trading-mcp"]
EOF

# Build
docker build -t trading-mcp .

# Run
docker run -p 9090:9090 trading-mcp
```

### Opción 3: Contactar al Equipo

Si después de seguir todos los pasos el problema persiste:

1. Recopilar información:
```bash
# Crear reporte
cat > deployment-issue-report.txt << EOF
Fecha: $(date)
Sistema: $(uname -a)
Go Version: $(go version)

Archivos:
$(ls -la internal/mcp-trading/tools/marketdata/*.go)

Binario:
$(ls -la bin/trading-mcp)

Proceso:
$(ps aux | grep trading-mcp)

Logs (últimas 50 líneas):
$(tail -50 logs/trading-mcp.log)

Test Results:
$(./scripts/verify-markets-deployment.sh)
EOF
```

2. Enviar reporte al equipo con el archivo `deployment-issue-report.txt`

---

## ✅ Verificación Final

Una vez resuelto el problema, verificar:

```bash
# 1. Ejecutar script de verificación
./scripts/verify-markets-deployment.sh

# 2. Verificar manualmente
curl -X POST http://192.168.100.145:9090/api/mcp/tools/execute \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_markets",
      "arguments": {"exchange": "kucoin", "market_type": "futures"}
    },
    "id": 1
  }' | jq '.'

# 3. Verificar que tiene formato enhanced
# Debe tener: pairs, features, total_count, version: "2.0"
# NO debe tener: markets (formato viejo)
```

---

**Documento generado por**: Backend Team  
**Fecha**: 2025-11-27  
**Propósito**: Troubleshooting de deployment
