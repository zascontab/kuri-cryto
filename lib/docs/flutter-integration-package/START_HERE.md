# 🚀 START HERE - Market Types Support Integration

**¡Bienvenidos al paquete de integración de Market Types Support!**

---

## 📢 Mensaje Importante

**El soporte para múltiples tipos de mercado (Spot, Futures, Margin, Options) está 100% implementado y listo para usar AHORA MISMO.** 🎉

No necesitan esperar nada del backend. Pueden empezar a integrar inmediatamente.

---

## ⚡ Quick Summary (2 minutos)

### ¿Qué hay de nuevo?

Ahora pueden especificar el tipo de mercado en TODOS los endpoints:

```dart
// Antes (solo futures)
final ticker = await getTicker('kucoin', 'BTCUSDTM');

// Ahora (cualquier tipo)
final spotTicker = await getTicker(
  'kucoin', 
  'BTC-USDT',  // ← Formato estándar
  marketType: 'spot',  // ← NUEVO
);

final futuresTicker = await getTicker(
  'kucoin',
  'BTC-USDT',  // ← Mismo formato
  marketType: 'futures',  // ← Backend convierte a BTCUSDTM
);
```

### ¿Qué hace el backend?

1. **Convierte símbolos automáticamente**
   - `BTC-USDT` + `futures` → `BTCUSDTM` (internamente)
   - Retorna siempre formato estándar: `BTC-USDT`

2. **Valida según tipo**
   - Spot: No permite leverage
   - Futures: Leverage 1-100x
   - Margin: Leverage 1-10x

3. **Mantiene compatibilidad**
   - Código existente sigue funcionando
   - `market_type` es opcional

---

## 📋 Orden de Lectura (30 minutos total)

### 1️⃣ Este documento (5 min) ✅
Ya lo estás leyendo. Continúa abajo.

### 2️⃣ BACKEND_RESPONSE_TO_FLUTTER_TEAM.md (15 min)
**LEE ESTE PRIMERO** - Responde TODAS tus preguntas:
- ¿Cómo funciona?
- ¿Qué necesito cambiar?
- ¿Ejemplos de código?
- ¿Cómo migrar?

### 3️⃣ FLUTTER-API-INTEGRATION-GUIDE.md (10 min)
Busca la sección **"Market Type Support (v3.2)"**
- Tabla de tipos de mercado
- Ejemplos completos
- Best practices

### 4️⃣ QUICK_TEST_COMMANDS.md (5 min - opcional)
Si quieres probar los endpoints antes de integrar.

---

## 🎯 Respuestas Rápidas a Preguntas Clave

### ❓ ¿Necesitamos cambiar mucho código?

**R:** No mucho. Solo agregar un parámetro opcional:

```dart
// Cambio mínimo en servicios
Future<Ticker> getTicker(
  String exchange,
  String pair,
  {String? marketType}  // ← Solo agregar esto
) async {
  // ... resto igual
}
```

### ❓ ¿Quién convierte los símbolos?

**R:** El backend. Ustedes SIEMPRE usan formato estándar:

```dart
// ✅ CORRECTO - Siempre usar este formato
'BTC-USDT'
'ETH-USDT'
'DOGE-USDT'

// ❌ NO NECESITAN hacer esto
if (marketType == 'futures') {
  pair = pair.replaceAll('-', '') + 'M';  // ← NO NECESARIO
}
```

### ❓ ¿Funciona con código existente?

**R:** Sí, 100%. El parámetro `market_type` es opcional:

```dart
// Código viejo - SIGUE FUNCIONANDO
final ticker = await getTicker('kucoin', 'BTCUSDTM');

// Código nuevo - NUEVA FUNCIONALIDAD
final ticker = await getTicker(
  'kucoin',
  'BTC-USDT',
  marketType: 'futures',
);
```

### ❓ ¿Cuándo podemos empezar?

**R:** ¡AHORA MISMO! Todo está listo:
- ✅ Backend implementado
- ✅ Tests pasando (15/15)
- ✅ Documentación completa
- ✅ Ejemplos listos

---

## 🛠️ Pasos de Integración (1 hora)

### Paso 1: Actualizar Modelos (15 min)

```dart
// Agregar campo opcional a OrderRequest
class OrderRequest {
  final String exchange;
  final String pair;
  final String side;
  final String type;
  final double amount;
  final double? price;
  final double? leverage;
  final String? marketType;  // ← NUEVO

  OrderRequest({
    required this.exchange,
    required this.pair,
    required this.side,
    required this.type,
    required this.amount,
    this.price,
    this.leverage,
    this.marketType,  // ← NUEVO
  });

  Map<String, dynamic> toJson() => {
    'exchange': exchange,
    'pair': pair,
    'side': side,
    'type': type,
    'amount': amount,
    if (price != null) 'price': price,
    if (leverage != null) 'leverage': leverage,
    if (marketType != null) 'market_type': marketType,  // ← NUEVO
  };
}
```

### Paso 2: Actualizar Servicios (15 min)

```dart
// Agregar parámetro opcional a métodos
class TradingService {
  Future<Ticker> getTicker({
    required String exchange,
    required String pair,
    String? marketType,  // ← NUEVO
  }) async {
    final response = await dio.post(
      '${ApiConfig.mcpServerUrl}/api/v1/mcp/tools/execute',
      data: {
        'jsonrpc': '2.0',
        'method': 'tools/call',
        'params': {
          'name': 'get_ticker',
          'arguments': {
            'exchange': exchange,
            'pair': pair,
            if (marketType != null) 'market_type': marketType,  // ← NUEVO
          },
        },
        'id': 1,
      },
    );
    return Ticker.fromJson(response.data['result']);
  }
}
```

### Paso 3: Actualizar UI (30 min)

```dart
// Agregar selector de market type
enum MarketType { spot, futures, margin, options }

class TradingScreen extends StatefulWidget {
  @override
  _TradingScreenState createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  MarketType selectedMarketType = MarketType.futures;
  double leverage = 1;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Market Type Selector
        SegmentedButton<MarketType>(
          segments: [
            ButtonSegment(
              value: MarketType.spot,
              label: Text('Spot'),
            ),
            ButtonSegment(
              value: MarketType.futures,
              label: Text('Futures'),
            ),
            ButtonSegment(
              value: MarketType.margin,
              label: Text('Margin'),
            ),
          ],
          selected: {selectedMarketType},
          onSelectionChanged: (Set<MarketType> newSelection) {
            setState(() {
              selectedMarketType = newSelection.first;
              if (selectedMarketType == MarketType.spot) {
                leverage = 1;  // Reset leverage for spot
              }
            });
          },
        ),
        
        // Leverage slider (solo si no es spot)
        if (selectedMarketType != MarketType.spot)
          Column(
            children: [
              Text('Leverage: ${leverage.toInt()}x'),
              Slider(
                value: leverage,
                min: 1,
                max: selectedMarketType == MarketType.futures ? 100 : 10,
                divisions: selectedMarketType == MarketType.futures ? 99 : 9,
                onChanged: (value) => setState(() => leverage = value),
              ),
            ],
          ),
        
        // Place Order Button
        ElevatedButton(
          onPressed: () async {
            await tradingService.submitOrder(
              exchange: 'kucoin',
              pair: 'BTC-USDT',  // Siempre formato estándar
              side: 'buy',
              type: 'limit',
              amount: 0.001,
              price: 45000,
              leverage: selectedMarketType != MarketType.spot ? leverage : null,
              marketType: selectedMarketType.name,  // ← NUEVO
            );
          },
          child: Text('Place Order'),
        ),
      ],
    );
  }
}
```

---

## ✅ Checklist de Integración

### Modelos
- [ ] Agregar `marketType` a OrderRequest
- [ ] Agregar `marketType` a otros modelos relevantes
- [ ] Actualizar `toJson()` methods

### Servicios
- [ ] Agregar parámetro `marketType` a getTicker()
- [ ] Agregar parámetro `marketType` a getCandles()
- [ ] Agregar parámetro `marketType` a submitOrder()
- [ ] Agregar parámetro `marketType` a otros métodos

### UI
- [ ] Agregar selector de market type
- [ ] Mostrar/ocultar leverage según tipo
- [ ] Validar inputs según tipo
- [ ] Actualizar labels y textos

### Testing
- [ ] Probar Spot trading
- [ ] Probar Futures trading
- [ ] Probar validación de leverage
- [ ] Probar backwards compatibility

---

## 🧪 Probar Antes de Integrar (Opcional)

Si quieren verificar que todo funciona antes de empezar:

```bash
# Test 1: Get Ticker Spot
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
  }' | jq '.result'

# Test 2: Get Ticker Futures
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
  }' | jq '.result'
```

Más comandos en **QUICK_TEST_COMMANDS.md**

---

## 📚 Documentos Disponibles

| Documento | Para Quién | Tiempo | Prioridad |
|-----------|------------|--------|-----------|
| START_HERE.md | Todos | 5 min | ⭐⭐⭐ |
| BACKEND_RESPONSE_TO_FLUTTER_TEAM.md | Developers | 15 min | ⭐⭐⭐ |
| FLUTTER-API-INTEGRATION-GUIDE.md | Developers | 10 min | ⭐⭐ |
| MARKET_TYPES_TEST_RESULTS.md | QA/Testing | 10 min | ⭐ |
| QUICK_TEST_COMMANDS.md | Developers | 5 min | ⭐ |
| MARKET_TYPES_IMPLEMENTATION_SUMMARY.md | PM/Lead | 5 min | ⭐ |
| FINAL_IMPLEMENTATION_REPORT.md | Technical | 10 min | - |

---

## 🎯 Próximos Pasos

### Ahora Mismo:
1. ✅ Leer BACKEND_RESPONSE_TO_FLUTTER_TEAM.md
2. ✅ Revisar ejemplos de código
3. ✅ Probar con curl (opcional)

### Esta Semana:
1. ✅ Actualizar modelos
2. ✅ Actualizar servicios
3. ✅ Agregar UI selector
4. ✅ Testing básico

### Próxima Semana:
1. ✅ Testing completo
2. ✅ Deploy a staging
3. ✅ Deploy a production

---

## 💡 Tips Importantes

### ✅ DO:
- Usar siempre formato estándar: `BTC-USDT`
- Agregar `market_type` como parámetro opcional
- Validar leverage en UI según tipo
- Probar con datos reales

### ❌ DON'T:
- No convertir símbolos en Flutter (backend lo hace)
- No hacer breaking changes
- No asumir que market_type es requerido
- No hardcodear validaciones (usar features del backend)

---

## 🆘 ¿Necesitas Ayuda?

### Durante Integración:
1. Revisar **BACKEND_RESPONSE_TO_FLUTTER_TEAM.md** (tiene TODO)
2. Buscar ejemplos en **FLUTTER-API-INTEGRATION-GUIDE.md**
3. Probar con **QUICK_TEST_COMMANDS.md**
4. Contactar equipo backend

### Reportar Problemas:
- Incluir: endpoint, parámetros, respuesta esperada vs actual
- Usar ejemplos de QUICK_TEST_COMMANDS.md para reproducir
- Compartir código relevante

---

## 🎉 ¡Listo para Empezar!

**Todo está implementado y probado. Pueden empezar a integrar ahora mismo.**

### Siguiente Paso:
👉 **Leer BACKEND_RESPONSE_TO_FLUTTER_TEAM.md**

¡Éxito con la integración! 🚀

---

**Package Version**: 3.2  
**Last Updated**: 26 November 2025  
**Status**: ✅ Ready for Integration
