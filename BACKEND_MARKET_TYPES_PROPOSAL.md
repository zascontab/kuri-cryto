# 📋 Propuesta: Soporte Multi-Tipo de Mercado (Spot, Futures, Margin, Options)

## 🎯 Objetivo

Implementar soporte completo para diferentes tipos de mercado en el backend, permitiendo al frontend distinguir y operar con:
- **Spot Trading** (compra/venta directa)
- **Futures Trading** (contratos con apalancamiento)
- **Margin Trading** (trading con fondos prestados)
- **Options Trading** (contratos de opciones)

---

## 🤔 Preguntas para el Equipo de Backend

### 1. **Estructura de Endpoints**

**Opción A: Endpoints Separados por Tipo**
```
/api/v1/spot/...
/api/v1/futures/...
/api/v1/margin/...
/api/v1/options/...
```

**Opción B: Mismo Endpoint con Parámetro de Tipo**
```
/api/v1/trading/analysis?market_type=spot
/api/v1/trading/analysis?market_type=futures
/api/v1/ai-bot/positions?market_type=futures
```

**Opción C: Híbrido (algunos separados, otros con parámetro)**
```
/api/v1/futures/positions  (específico de futures)
/api/v1/trading/analysis?market_type=spot  (genérico con parámetro)
```

**❓ ¿Cuál opción prefieren implementar?**

---

### 2. **Pares Disponibles por Tipo de Mercado**

Cada tipo de mercado tiene diferentes pares disponibles:

**Spot:**
- `BTC-USDT`, `ETH-USDT`, `SOL-USDT`, etc.

**Futures:**
- `BTCUSDTM` (perpetual), `BTCUSDT-20241231` (quarterly)
- Formato KuCoin: sufijo `M` para perpetual

**Margin:**
- Mismos pares que Spot pero con capacidad de apalancamiento
- `BTC-USDT` (cross margin), `BTC-USDT` (isolated margin)

**Options:**
- `BTC-USDT-20241231-50000-C` (Call)
- `BTC-USDT-20241231-50000-P` (Put)

**❓ Preguntas:**
1. ¿Necesitamos un endpoint para obtener pares disponibles por tipo?
   ```
   GET /api/v1/markets/pairs?market_type=futures&exchange=kucoin
   Response: ["BTCUSDTM", "ETHUSDTM", ...]
   ```

2. ¿El backend maneja la conversión de formato de símbolos?
   - Frontend envía: `BTC-USDT` + `market_type=futures`
   - Backend convierte a: `BTCUSDTM` para KuCoin
   
   O el frontend debe enviar el símbolo ya formateado?

---

### 3. **Análisis Comprehensivo por Tipo**

Actualmente tenemos:
```
POST /api/v1/ai-bot/comprehensive-analysis
Body: { "symbol": "BTC-USDT", "exchange": "kucoin" }
```

**❓ ¿Debemos agregar `market_type`?**
```json
{
  "symbol": "BTC-USDT",
  "exchange": "kucoin",
  "market_type": "futures"  // ← NUEVO
}
```

**Consideraciones:**
- Indicadores técnicos pueden ser diferentes (funding rate en futures)
- Datos de precio diferentes (mark price vs spot price)
- Recomendaciones diferentes (leverage en futures, no en spot)

---

### 4. **AI Bot y Tipos de Mercado**

El AI Bot actualmente opera en futures. 

**❓ Preguntas:**
1. ¿El bot debe poder operar en múltiples tipos simultáneamente?
2. ¿La configuración del bot debe especificar el tipo de mercado?
   ```json
   {
     "market_type": "futures",
     "pair": "BTC-USDT",
     "leverage": 10,  // solo para futures/margin
     ...
   }
   ```

3. ¿Las posiciones deben filtrar por tipo?
   ```
   GET /api/v1/ai-bot/positions?market_type=futures
   ```

---

### 5. **Posiciones por Tipo de Mercado**

Actualmente:
```
GET /api/v1/futures/positions
```

**❓ ¿Cómo manejamos posiciones de otros tipos?**

**Opción A: Endpoints separados**
```
GET /api/v1/spot/positions
GET /api/v1/futures/positions
GET /api/v1/margin/positions
GET /api/v1/options/positions
```

**Opción B: Endpoint unificado**
```
GET /api/v1/positions?market_type=futures
GET /api/v1/positions  (retorna todas)
```

---

### 6. **Características Específicas por Tipo**

Cada tipo tiene características únicas:

**Futures:**
- Leverage (1x-100x)
- Funding rate
- Mark price vs Last price
- Liquidation price
- Position mode (one-way, hedge)

**Spot:**
- No leverage
- Solo last price
- No liquidation

**Margin:**
- Leverage (2x-10x típicamente)
- Interest rate
- Margin level
- Liquidation risk

**Options:**
- Strike price
- Expiration date
- Greeks (delta, gamma, theta, vega)
- Premium

**❓ ¿El backend ya maneja estas diferencias en los modelos de datos?**

---

## 💡 Propuesta de Implementación Frontend

### Fase 1: Estructura Base
```dart
enum MarketType {
  spot,
  futures,
  margin,
  options
}

class TradingContext {
  final String pair;
  final String exchange;
  final MarketType marketType;
  final String timeframe;
}
```

### Fase 2: Servicios Adaptados
```dart
// Servicio genérico que adapta según el tipo
class MarketService {
  Future<Analysis> getAnalysis({
    required String symbol,
    required String exchange,
    required MarketType marketType,
  }) {
    // Adapta el endpoint y formato según el tipo
  }
}
```

### Fase 3: UI Contextual
- Mostrar/ocultar controles según el tipo (leverage solo en futures)
- Indicadores específicos por tipo
- Validaciones diferentes por tipo

---

## 📊 Endpoints Propuestos (Sugerencia)

### Información de Mercados
```
GET /api/v1/markets/types
Response: ["spot", "futures", "margin", "options"]

GET /api/v1/markets/pairs?market_type=futures&exchange=kucoin
Response: {
  "market_type": "futures",
  "exchange": "kucoin",
  "pairs": ["BTCUSDTM", "ETHUSDTM", ...],
  "features": {
    "leverage": { "min": 1, "max": 100 },
    "has_funding_rate": true,
    "has_liquidation": true
  }
}
```

### Análisis
```
POST /api/v1/analysis/comprehensive
Body: {
  "symbol": "BTC-USDT",
  "exchange": "kucoin",
  "market_type": "futures",
  "timeframe": "1h"
}
```

### Posiciones
```
GET /api/v1/positions?market_type=futures&exchange=kucoin
GET /api/v1/positions  (todas)
```

### AI Bot
```
GET /api/v1/ai-bot/config
Response: {
  "market_type": "futures",
  "pair": "BTC-USDT",
  "exchange": "kucoin",
  ...
}

POST /api/v1/ai-bot/config
Body: {
  "market_type": "futures",  // ← NUEVO
  "pair": "BTC-USDT",
  ...
}
```

---

## 🚀 Plan de Migración

### Fase 1: Backwards Compatible (Recomendado)
1. Agregar parámetro opcional `market_type` a endpoints existentes
2. Si no se especifica, asumir `futures` (comportamiento actual)
3. Frontend puede empezar a enviar el parámetro gradualmente

### Fase 2: Nuevos Endpoints
1. Implementar endpoints específicos para spot, margin, options
2. Mantener endpoints de futures existentes

### Fase 3: Deprecación (Opcional)
1. Marcar endpoints antiguos como deprecated
2. Migrar completamente a nueva estructura

---

## ❓ Preguntas Finales para el Equipo

1. **¿Cuál es el timeline para implementar esto?**
   - ¿Podemos empezar con solo agregar el parámetro `market_type`?
   - ¿O prefieren diseñar toda la arquitectura primero?

2. **¿Qué tipos de mercado son prioritarios?**
   - Futures (ya existe) ✅
   - Spot (más simple, bueno para empezar)
   - Margin (similar a futures)
   - Options (más complejo, puede ser después)

3. **¿Hay limitaciones del exchange?**
   - ¿KuCoin soporta todos estos tipos?
   - ¿Necesitamos diferentes exchanges para diferentes tipos?

4. **¿Cómo afecta esto al AI Bot?**
   - ¿El bot debe poder operar en múltiples tipos?
   - ¿O un bot por tipo de mercado?

5. **¿Necesitan ayuda con el diseño de la API?**
   - Podemos hacer una sesión de diseño conjunto
   - Compartir ejemplos de otras APIs (Binance, Bybit)

---

## 📝 Notas Adicionales

### Ejemplos de Otras Plataformas

**Binance API:**
```
/api/v3/ticker/price  (spot)
/fapi/v1/ticker/price  (futures)
/sapi/v1/margin/...  (margin)
```

**Bybit API:**
```
/v5/market/tickers?category=spot
/v5/market/tickers?category=linear  (futures)
/v5/market/tickers?category=option
```

### Recomendación
Sugiero usar el enfoque de Bybit con parámetro `market_type` o `category`, es más flexible y escalable.

---

## 🤝 Próximos Pasos

1. **Revisar este documento** con el equipo de backend
2. **Responder las preguntas** marcadas con ❓
3. **Definir la estructura de API** que usaremos
4. **Crear un plan de implementación** conjunto
5. **Implementar en fases** para no romper lo existente

---

**Contacto Frontend:** [Tu nombre/equipo]
**Fecha:** 2024-11-26
**Versión:** 1.0

