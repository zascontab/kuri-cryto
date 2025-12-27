# 🎛️ Guía de Configuración Dinámica del Bot

**Versión**: 1.0  
**Fecha**: 19 Noviembre 2025  
**Feature**: Cambio de configuración sin reiniciar

---

## 🎯 Descripción

El bot ahora permite **cambiar la configuración en tiempo real** sin necesidad de recompilar o reiniciar el servidor. Esto incluye cambiar entre modo DRY RUN y LIVE dinámicamente.

---

## 🔧 Endpoints Disponibles

### 1. Obtener Configuración Actual

**Endpoint**: `GET /api/v1/ai-bot/config`

```bash
curl http://192.168.1.6:10600/api/v1/ai-bot/config
```

**Respuesta**:
```json
{
  "pair": "DOGE-USDT",
  "exchange": "kucoin",
  "confidence_threshold": 0.70,
  "trade_size_usd": 3.0,
  "leverage": 5,
  "dry_run": true,
  "auto_execute": false,
  "max_daily_loss_usd": 50.0,
  "max_daily_trades": 20,
  "max_consecutive_errors": 3,
  "max_open_positions": 2
}
```

### 2. Actualizar Configuración

**Endpoint**: `POST /api/v1/ai-bot/config`

⚠️ **IMPORTANTE**: El bot debe estar detenido para cambiar la configuración.

```bash
curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/config \
  -H "Content-Type: application/json" \
  -d '{
    "dry_run": false,
    "auto_execute": true,
    "confidence_threshold": 0.75
  }'
```

**Respuesta**:
```json
{
  "message": "Configuration updated successfully",
  "config": {
    "dry_run": false,
    "auto_execute": true,
    "confidence_threshold": 0.75,
    ...
  }
}
```

---

## 🎮 Casos de Uso

### Caso 1: Cambiar de DRY RUN a LIVE

```bash
# 1. Detener el bot si está corriendo
curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/stop

# 2. Cambiar a modo LIVE
curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/config \
  -H "Content-Type: application/json" \
  -d '{
    "dry_run": false,
    "auto_execute": true
  }'

# 3. Verificar configuración
curl http://192.168.1.6:10600/api/v1/ai-bot/config | jq '{dry_run, auto_execute}'

# 4. Iniciar bot en modo LIVE
curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/start
```

### Caso 2: Ajustar Parámetros de Trading

```bash
# Detener bot
curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/stop

# Ajustar parámetros
curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/config \
  -H "Content-Type: application/json" \
  -d '{
    "confidence_threshold": 0.80,
    "trade_size_usd": 5.0,
    "leverage": 3,
    "max_daily_loss_usd": 30.0
  }'

# Reiniciar bot con nueva configuración
curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/start
```

### Caso 3: Cambiar Par de Trading

```bash
# Detener bot
curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/stop

# Cambiar a BTC-USDT
curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/config \
  -H "Content-Type: application/json" \
  -d '{
    "pair": "BTC-USDT"
  }'

# Iniciar bot con nuevo par
curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/start
```

### Caso 4: Modo Conservador

```bash
curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/stop

curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/config \
  -H "Content-Type: application/json" \
  -d '{
    "confidence_threshold": 0.85,
    "trade_size_usd": 3.0,
    "leverage": 3,
    "max_daily_loss_usd": 20.0,
    "max_daily_trades": 5
  }'

curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/start
```

### Caso 5: Modo Agresivo

```bash
curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/stop

curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/config \
  -H "Content-Type: application/json" \
  -d '{
    "confidence_threshold": 0.65,
    "trade_size_usd": 10.0,
    "leverage": 10,
    "max_daily_loss_usd": 100.0,
    "max_daily_trades": 30
  }'

curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/start
```

---

## 📋 Parámetros Configurables

| Parámetro | Tipo | Rango | Descripción |
|-----------|------|-------|-------------|
| `dry_run` | boolean | true/false | Modo simulación (true) o real (false) |
| `auto_execute` | boolean | true/false | Ejecutar automáticamente (true) o solo señales (false) |
| `confidence_threshold` | float | 0.5 - 1.0 | Confianza mínima para operar (70% = 0.70) |
| `trade_size_usd` | float | > 0 | Tamaño de cada trade en USD |
| `leverage` | int | 1 - 100 | Apalancamiento (5 = 5x) |
| `max_daily_loss_usd` | float | > 0 | Pérdida máxima diaria en USD |
| `max_daily_trades` | int | > 0 | Número máximo de trades por día |
| `pair` | string | - | Par de trading (ej: "DOGE-USDT") |

---

## ⚠️ Validaciones

### El sistema valida automáticamente:

1. **Bot debe estar detenido**: No se puede cambiar config mientras corre
2. **Confidence threshold**: Debe estar entre 0.5 y 1.0
3. **Trade size**: Debe ser positivo
4. **Leverage**: Debe estar entre 1 y 100
5. **Valores positivos**: max_daily_loss, max_daily_trades deben ser > 0

### Errores Comunes

**Error: "cannot update config while bot is running"**
```bash
# Solución: Detener el bot primero
curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/stop
```

**Error: "confidence_threshold must be between 0.5 and 1.0"**
```bash
# Solución: Usar valor válido
curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/config \
  -d '{"confidence_threshold": 0.75}'
```

---

## 🔒 Seguridad

### Recomendaciones

1. **Siempre probar en DRY RUN primero**
   ```bash
   # Configurar DRY RUN
   curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/config \
     -d '{"dry_run": true, "auto_execute": false}'
   ```

2. **Cambiar a LIVE gradualmente**
   ```bash
   # Paso 1: DRY RUN con auto_execute
   {"dry_run": true, "auto_execute": true}
   
   # Paso 2: LIVE con cantidades pequeñas
   {"dry_run": false, "auto_execute": true, "trade_size_usd": 3}
   
   # Paso 3: Aumentar gradualmente
   {"trade_size_usd": 5, "leverage": 5}
   ```

3. **Configurar límites conservadores**
   ```bash
   curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/config \
     -d '{
       "max_daily_loss_usd": 20.0,
       "max_daily_trades": 10,
       "max_consecutive_errors": 3
     }'
   ```

---

## 📊 Flujo Recomendado

### Para Activar Trading Real

```bash
# 1. Verificar configuración actual
curl http://192.168.1.6:10600/api/v1/ai-bot/config | jq

# 2. Detener bot si está corriendo
curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/stop

# 3. Configurar modo LIVE con límites conservadores
curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/config \
  -H "Content-Type: application/json" \
  -d '{
    "dry_run": false,
    "auto_execute": true,
    "confidence_threshold": 0.75,
    "trade_size_usd": 3.0,
    "leverage": 5,
    "max_daily_loss_usd": 30.0,
    "max_daily_trades": 10
  }'

# 4. Verificar que se aplicó
curl http://192.168.1.6:10600/api/v1/ai-bot/config | jq '{dry_run, auto_execute}'

# 5. Iniciar bot
curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/start

# 6. Monitorear logs
tail -f /var/log/trading/mcp-server.log | grep -E "Analysis|Signal|Trade"
```

### Para Volver a DRY RUN

```bash
# 1. Detener bot
curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/stop

# 2. Volver a DRY RUN
curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/config \
  -d '{"dry_run": true, "auto_execute": false}'

# 3. Reiniciar en modo seguro
curl -X POST http://192.168.1.6:10600/api/v1/ai-bot/start
```

---

## 🎓 Ejemplos de Configuraciones

### Principiante (Conservador)
```json
{
  "dry_run": false,
  "auto_execute": true,
  "confidence_threshold": 0.85,
  "trade_size_usd": 3.0,
  "leverage": 3,
  "max_daily_loss_usd": 15.0,
  "max_daily_trades": 5
}
```

### Intermedio
```json
{
  "dry_run": false,
  "auto_execute": true,
  "confidence_threshold": 0.75,
  "trade_size_usd": 5.0,
  "leverage": 5,
  "max_daily_loss_usd": 30.0,
  "max_daily_trades": 10
}
```

### Avanzado (Más Riesgo)
```json
{
  "dry_run": false,
  "auto_execute": true,
  "confidence_threshold": 0.65,
  "trade_size_usd": 10.0,
  "leverage": 10,
  "max_daily_loss_usd": 50.0,
  "max_daily_trades": 20
}
```

---

## 📱 Integración Flutter

```dart
// Obtener configuración
Future<BotConfig> getConfig() async {
  final response = await dio.get(
    '${ApiConfig.mcpServerUrl}/api/v1/ai-bot/config',
  );
  return BotConfig.fromJson(response.data);
}

// Actualizar configuración
Future<void> updateConfig(Map<String, dynamic> updates) async {
  // Detener bot primero
  await dio.post('${ApiConfig.mcpServerUrl}/api/v1/ai-bot/stop');
  
  // Actualizar config
  await dio.post(
    '${ApiConfig.mcpServerUrl}/api/v1/ai-bot/config',
    data: updates,
  );
  
  // Reiniciar bot
  await dio.post('${ApiConfig.mcpServerUrl}/api/v1/ai-bot/start');
}

// Cambiar a modo LIVE
Future<void> enableLiveMode() async {
  await updateConfig({
    'dry_run': false,
    'auto_execute': true,
  });
}

// Cambiar a modo DRY RUN
Future<void> enableDryRunMode() async {
  await updateConfig({
    'dry_run': true,
    'auto_execute': false,
  });
}
```

---

## ✅ Ventajas

1. **Sin recompilación**: Cambios instantáneos
2. **Sin reinicio de servidor**: Mantiene uptime
3. **Flexible**: Ajusta parámetros sobre la marcha
4. **Seguro**: Validaciones automáticas
5. **Auditable**: Todos los cambios se registran en logs

---

**Versión**: 1.0  
**Última Actualización**: 19 Noviembre 2025  
**Estado**: ✅ Funcional y Probado
