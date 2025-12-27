# ⚠️ Pendiente: Integración de Pares en UI

**Fecha**: 27 de Noviembre, 2025  
**Estado**: ⚠️ **PARCIALMENTE IMPLEMENTADO**

---

## 📋 Problema Identificado

Los pares de trading están **hardcodeados** en varias pantallas en lugar de obtenerse dinámicamente de los endpoints del backend.

---

## 🔍 Pantallas Afectadas

### 1. `lib/screens/trading_hub_screen.dart` ⚠️

**Problema**:
```dart
// Línea ~40
final List<String> _popularPairs = [
  'BTC-USDT',
  'ETH-USDT',
  'SOL-USDT',
  'BNB-USDT',
  'XRP-USDT',
];
```

**Solución Requerida**:
```dart
// Remover _popularPairs hardcodeado

// En _showPairSelector(), cambiar a:
showModalBottomSheet(
  builder: (context) => Consumer(
    builder: (context, ref, _) {
      final pairsAsync = ref.watch(
        availablePairsProvider(
          marketType: _selectedMarketType,
          exchange: _selectedExchange,
        ),
      );
      
      return pairsAsync.when(
        data: (pairs) => _PairSelectorSheet(
          selectedPair: _selectedPair,
          pairs: pairs,
          onPairSelected: (pair) {
            _onPairSelected(pair);
            Navigator.pop(context);
          },
        ),
        loading: () => CircularProgressIndicator(),
        error: (e, s) => Text('Error: $e'),
      );
    },
  ),
);
```

---

### 2. `lib/screens/mcp_main_screen.dart` ⚠️

**Problema**:
```dart
// Línea ~22
final List<String> _pairs = [
  'BTC-USDT',
  'ETH-USDT',
  'SOL-USDT',
  'BNB-USDT',
  'XRP-USDT',
];
```

**Solución Requerida**:
```dart
// Remover _pairs hardcodeado

// Agregar provider watch en build():
@override
Widget build(BuildContext context) {
  final pairsAsync = ref.watch(
    availablePairsProvider(
      marketType: MarketType.futures, // o el tipo seleccionado
      exchange: _selectedExchange,
    ),
  );
  
  return pairsAsync.when(
    data: (pairs) => Scaffold(
      // Usar pairs dinámicamente en PopupMenuButton
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _selectedPair = value),
            itemBuilder: (context) => pairs.map((pair) {
              return PopupMenuItem(value: pair, child: Text(pair));
            }).toList(),
          ),
        ],
      ),
      // ...
    ),
    loading: () => CircularProgressIndicator(),
    error: (e, s) => Text('Error: $e'),
  );
}
```

---

### 3. `lib/screens/ai_bot_config_screen.dart` ✅

**Estado**: Ya usa `availablePairsProvider` correctamente

```dart
// Línea ~310
final pairsAsync = ref.watch(
  availablePairsProvider(
    marketType: MarketType.fromString(_selectedMarketType),
    exchange: 'kucoin',
  ),
);
```

**Acción**: Ninguna, ya está implementado correctamente

---

### 4. `lib/screens/trading_pairs_screen.dart` ✅

**Estado**: Ya usa `availablePairsProvider` correctamente

```dart
// Línea ~560
final pairsAsync = ref.watch(availablePairsProvider(_selectedExchange!));
```

**Acción**: Ninguna, ya está implementado correctamente

---

## 🔧 Cambios Necesarios

### Paso 1: Actualizar `trading_hub_screen.dart`

```dart
// 1. Agregar import
import '../providers/market_provider.dart';

// 2. Cambiar clase a ConsumerStatefulWidget
class TradingHubScreen extends ConsumerStatefulWidget {
  const TradingHubScreen({super.key});

  @override
  ConsumerState<TradingHubScreen> createState() => _TradingHubScreenState();
}

class _TradingHubScreenState extends ConsumerState<TradingHubScreen>
    with SingleTickerProviderStateMixin {
  
  // 3. Remover _popularPairs hardcodeado
  // final List<String> _popularPairs = [...]; // ❌ REMOVER
  
  // 4. Actualizar _showPairSelector()
  void _showPairSelector() {
    HapticFeedback.mediumImpact();
    
    // Obtener pares del provider
    final pairsAsync = ref.read(
      availablePairsProvider(
        marketType: _selectedMarketType,
        exchange: _selectedExchange,
      ).future,
    );
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FutureBuilder<List<String>>(
        future: pairsAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.hasError) {
            return Container(
              height: 200,
              child: Center(child: Text('Error loading pairs')),
            );
          }
          
          final pairs = snapshot.data ?? [];
          
          return _PairSelectorSheet(
            selectedPair: _selectedPair,
            pairs: pairs,
            onPairSelected: (pair) {
              _onPairSelected(pair);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}

// 5. Actualizar _PairSelectorSheet
class _PairSelectorSheet extends StatelessWidget {
  final String selectedPair;
  final List<String> pairs; // ✅ Dinámico
  final Function(String) onPairSelected;

  const _PairSelectorSheet({
    required this.selectedPair,
    required this.pairs,
    required this.onPairSelected,
  });

  @override
  Widget build(BuildContext context) {
    // ... usar pairs dinámicamente
  }
}
```

---

### Paso 2: Actualizar `mcp_main_screen.dart`

```dart
// 1. Agregar import
import '../providers/market_provider.dart';

// 2. Cambiar clase a ConsumerStatefulWidget
class McpMainScreen extends ConsumerStatefulWidget {
  const McpMainScreen({super.key});

  @override
  ConsumerState<McpMainScreen> createState() => _McpMainScreenState();
}

class _McpMainScreenState extends ConsumerState<McpMainScreen>
    with SingleTickerProviderStateMixin {
  
  // 3. Remover _pairs hardcodeado
  // final List<String> _pairs = [...]; // ❌ REMOVER
  
  // 4. Usar provider en build()
  @override
  Widget build(BuildContext context) {
    final pairsAsync = ref.watch(
      availablePairsProvider(
        marketType: MarketType.futures,
        exchange: _selectedExchange,
      ),
    );
    
    return pairsAsync.when(
      data: (pairs) => Scaffold(
        appBar: AppBar(
          actions: [
            // Pair selector
            PopupMenuButton<String>(
              onSelected: (value) => setState(() => _selectedPair = value),
              itemBuilder: (context) => pairs.map((pair) {
                return PopupMenuItem(
                  value: pair,
                  child: Text(pair),
                );
              }).toList(),
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            ComprehensiveAnalysisScreen(
              symbol: _selectedPair,
              exchange: _selectedExchange,
            ),
            // ... otros tabs
          ],
        ),
      ),
      loading: () => Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

---

## 📊 Impacto

### Antes (Hardcodeado):
- ❌ Solo 5 pares disponibles
- ❌ Pares fijos, no dinámicos
- ❌ No refleja pares reales del backend
- ❌ No se actualiza automáticamente

### Después (Con Provider):
- ✅ Todos los pares disponibles del backend
- ✅ Pares dinámicos según market type
- ✅ Refleja pares reales
- ✅ Se actualiza automáticamente
- ✅ Funciona con caché del backend

---

## ✅ Checklist de Implementación

### trading_hub_screen.dart:
- [ ] Agregar import de `market_provider.dart`
- [ ] Cambiar a `ConsumerStatefulWidget`
- [ ] Remover `_popularPairs` hardcodeado
- [ ] Actualizar `_showPairSelector()` para usar provider
- [ ] Actualizar `_PairSelectorSheet` para recibir pairs dinámicos
- [ ] Manejar estados loading/error
- [ ] Testing

### mcp_main_screen.dart:
- [ ] Agregar import de `market_provider.dart`
- [ ] Cambiar a `ConsumerStatefulWidget`
- [ ] Remover `_pairs` hardcodeado
- [ ] Usar `availablePairsProvider` en build()
- [ ] Actualizar `PopupMenuButton` para usar pairs dinámicos
- [ ] Manejar estados loading/error
- [ ] Testing

---

## 🚀 Beneficios de la Implementación

1. **Más Pares Disponibles**:
   - Antes: 5 pares hardcodeados
   - Después: 22+ pares por market type (74 total)

2. **Dinámico**:
   - Pares se actualizan automáticamente
   - Refleja cambios del backend
   - Funciona con caché

3. **Filtrado por Market Type**:
   - Spot: 22 pares
   - Futures: 22 pares
   - Margin: 20 pares
   - Options: 10 pares

4. **Mejor UX**:
   - Usuarios ven todos los pares disponibles
   - Información actualizada
   - Loading states apropiados

---

## ⚠️ Notas Importantes

1. **Esperar Reinicio del Backend**:
   - El backend necesita reiniciarse para retornar 74 pares
   - Actualmente retorna solo 3 pares (sample data)
   - Una vez reiniciado, la UI mostrará todos los pares automáticamente

2. **Adaptador Temporal**:
   - El código actual tiene un adaptador que funciona con ambos formatos
   - Cuando backend reinicie, funcionará automáticamente
   - No se necesitan cambios adicionales en el servicio

3. **Testing**:
   - Probar con backend actual (3 pares)
   - Probar después del reinicio (74 pares)
   - Verificar loading states
   - Verificar error handling

---

## 📞 Coordinación

### Backend Team:
- ⏳ Reiniciar servidor para activar formato enhanced
- ✅ Notificar cuando esté listo

### Flutter Team:
- ⏳ Implementar cambios en UI (este documento)
- ⏳ Testing con backend actual
- ⏳ Verificar después del reinicio
- ⏳ Deploy a producción

---

## 🎯 Prioridad

**ALTA** - Los usuarios actualmente solo ven 5 pares hardcodeados cuando deberían ver 74 pares disponibles.

**Tiempo Estimado**: 2-3 horas de desarrollo + testing

---

**Documento generado por**: Flutter Team  
**Fecha**: 2025-11-27  
**Estado**: ⚠️ **PENDIENTE IMPLEMENTACIÓN**  
**Bloqueado por**: Ninguno (puede implementarse ahora)

