# ✅ Next Steps Checklist - Market Types Implementation

**Estado actual**: Services actualizados ✅ | UI pendiente ⏳

---

## 🎯 Quick Start

Si quieres continuar con la implementación de Market Types, sigue estos pasos en orden:

---

## 📋 Checklist de Implementación

### Fase 1: Preparación (5 min)

- [ ] Leer `MARKET_TYPES_IMPLEMENTATION.md` para entender los cambios
- [ ] Revisar `MARKET_TYPES_USAGE_EXAMPLES.md` para ver ejemplos de código
- [ ] Verificar que los servicios compilan sin errores:
  ```bash
  flutter analyze lib/services/market_service.dart \
                 lib/services/market_data_service.dart \
                 lib/services/technical_indicators_service.dart
  ```

---

### Fase 2: Provider (30-60 min)

- [ ] Crear `lib/providers/market_type_provider.dart`
  - Copiar código del Ejemplo 1 en `MARKET_TYPES_USAGE_EXAMPLES.md`
  - Ajustar imports según tu estructura
  - Agregar al provider tree en `main.dart`

- [ ] Probar el provider:
  ```dart
  // En cualquier screen
  final provider = Provider.of<MarketTypeProvider>(context);
  print(provider.selectedMarketType); // Debe imprimir: MarketType.futures
  ```

---

### Fase 3: UI - Selector de Market Type (1-2 horas)

#### 3.1 Crear Widget Reutilizable

- [ ] Crear `lib/widgets/market_type_selector.dart`
  - Copiar código del Ejemplo 2 en `MARKET_TYPES_USAGE_EXAMPLES.md`
  - Implementar `SegmentedButton` con los 4 tipos
  - Agregar iconos y colores por tipo

- [ ] Crear `lib/widgets/market_type_indicator.dart`
  - Copiar código del Ejemplo 6 en `MARKET_TYPES_USAGE_EXAMPLES.md`
  - Badge pequeño para mostrar tipo actual

#### 3.2 Actualizar TradingHubScreen

- [ ] Abrir `lib/screens/trading_hub_screen.dart`
- [ ] Agregar `MarketTypeSelector` en la parte superior
- [ ] Conectar con `MarketTypeProvider`
- [ ] Actualizar llamadas a servicios para incluir `marketType`:
  ```dart
  // ANTES
  final ticker = await marketDataService.getTicker(
    exchange: 'kucoin',
    pair: selectedPair,
  );
  
  // DESPUÉS
  final ticker = await marketDataService.getTicker(
    exchange: 'kucoin',
    pair: selectedPair,
    marketType: provider.selectedMarketType.name,  // NUEVO
  );
  ```

#### 3.3 Agregar Leverage Slider Condicional

- [ ] Obtener features del market type actual:
  ```dart
  final features = await marketService.getMarketFeatures(
    marketType: provider.selectedMarketType,
    exchange: 'kucoin',
  );
  ```

- [ ] Mostrar slider solo si `features.hasLeverage == true`
- [ ] Configurar min/max según `features.minLeverage` y `features.maxLeverage`
- [ ] Ocultar para spot trading

#### 3.4 Actualizar Pair Selector

- [ ] Cargar pares disponibles según market type:
  ```dart
  final pairs = await marketService.getAvailablePairs(
    marketType: provider.selectedMarketType,
    exchange: 'kucoin',
  );
  ```

- [ ] Actualizar dropdown cuando cambia market type
- [ ] Seleccionar primer par si el actual no está disponible

---

### Fase 4: UI - Pantallas Existentes (1-2 horas)

#### 4.1 FuturesPositionsScreen

- [ ] Abrir `lib/screens/futures_positions_screen.dart`
- [ ] Agregar filtro por market type
- [ ] Mostrar `MarketTypeIndicator` en cada posición
- [ ] Agregar botón "Ver solo Futures" / "Ver todos"

#### 4.2 ComprehensiveAnalysisScreen

- [ ] Abrir `lib/screens/comprehensive_analysis_screen.dart`
- [ ] Mostrar market type actual en AppBar
- [ ] Agregar `MarketTypeIndicator` junto al símbolo
- [ ] Pasar `marketType` al servicio de análisis

#### 4.3 AiBotConfigScreen

- [ ] Abrir `lib/screens/ai_bot_config_screen.dart`
- [ ] Agregar selector de market type para el bot
- [ ] Validar leverage según market type seleccionado
- [ ] Mostrar warning si se selecciona spot con leverage

---

### Fase 5: Validación (30 min)

#### 5.1 Crear OrderValidator

- [ ] Crear `lib/services/order_validator.dart`
- [ ] Copiar código del Ejemplo 5 en `MARKET_TYPES_USAGE_EXAMPLES.md`
- [ ] Integrar en formularios de trading

#### 5.2 Probar Validaciones

- [ ] Intentar usar leverage en spot → Debe mostrar error
- [ ] Intentar leverage > 100 en futures → Debe mostrar error
- [ ] Intentar leverage > 10 en margin → Debe mostrar error
- [ ] Verificar warnings para leverage alto

---

### Fase 6: Testing (1-2 horas)

#### 6.1 Tests Manuales

- [ ] Cambiar entre market types y verificar que:
  - Pares disponibles se actualizan
  - Leverage slider aparece/desaparece correctamente
  - Límites de leverage son correctos
  - Llamadas a API incluyen market_type

- [ ] Probar cada market type:
  - [ ] Spot: Sin leverage, sin funding rate
  - [ ] Futures: Leverage 1-100x, con funding rate
  - [ ] Margin: Leverage 1-10x, sin funding rate
  - [ ] Options: Sin leverage

#### 6.2 Tests Unitarios (Opcional)

- [ ] Crear `test/services/market_service_test.dart`
- [ ] Crear `test/services/order_validator_test.dart`
- [ ] Crear `test/providers/market_type_provider_test.dart`

---

### Fase 7: Refinamiento (30 min)

#### 7.1 UX Improvements

- [ ] Agregar animaciones al cambiar market type
- [ ] Agregar tooltips explicando cada tipo
- [ ] Agregar confirmación al cambiar de spot a futures
- [ ] Mostrar características del mercado en un card

#### 7.2 Error Handling

- [ ] Manejar errores al cargar pares
- [ ] Manejar errores al cargar features
- [ ] Mostrar mensajes user-friendly
- [ ] Agregar retry buttons

---

### Fase 8: Documentación (15 min)

- [ ] Actualizar README con nueva funcionalidad
- [ ] Agregar screenshots de la UI
- [ ] Documentar cómo usar market types
- [ ] Actualizar CHANGELOG

---

## 🚀 Quick Commands

```bash
# Verificar que no hay errores
flutter analyze

# Correr tests
flutter test

# Correr app en debug
flutter run

# Build para release
flutter build apk --release
```

---

## 📚 Archivos de Referencia

### Documentación
- `MARKET_TYPES_IMPLEMENTATION.md` - Guía técnica completa
- `MARKET_TYPES_USAGE_EXAMPLES.md` - 6 ejemplos de código
- `BACKEND_RESPONSE_TO_FLUTTER_TEAM.md` - Especificación del backend
- `FLUTTER-API-INTEGRATION-GUIDE.md` - Guía de API completa

### Código Actualizado
- `lib/services/market_service.dart` - ✅ Actualizado
- `lib/services/market_data_service.dart` - ✅ Actualizado
- `lib/services/technical_indicators_service.dart` - ✅ Actualizado

### Código Existente (Referencia)
- `lib/screens/trading_hub_screen.dart` - Ya tiene enum MarketType
- `lib/models/futures_position.dart` - Modelo de posición

---

## ⚡ Fast Track (Si tienes prisa)

Si solo quieres lo mínimo funcional:

1. **Crear provider** (30 min)
   - Copiar Ejemplo 1 de `MARKET_TYPES_USAGE_EXAMPLES.md`

2. **Agregar selector en TradingHubScreen** (30 min)
   - Copiar Ejemplo 2 de `MARKET_TYPES_USAGE_EXAMPLES.md`
   - Solo implementar el selector, sin leverage slider

3. **Actualizar llamadas a servicios** (15 min)
   - Agregar `marketType: provider.selectedMarketType.name` a getTicker, getCandles

**Total: ~1 hora para funcionalidad básica**

---

## 🎯 Prioridades

### Must Have (Crítico)
- ✅ Services actualizados (YA HECHO)
- ⏳ Provider para market type
- ⏳ Selector de market type en UI
- ⏳ Leverage slider condicional

### Should Have (Importante)
- ⏳ Validación de órdenes
- ⏳ Filtros por market type en posiciones
- ⏳ Indicadores visuales por tipo

### Nice to Have (Opcional)
- ⏳ Comparación entre market types
- ⏳ Análisis multi-market
- ⏳ Tests unitarios completos

---

## 🐛 Troubleshooting

### Error: "market_type not recognized"
- Verificar que estás enviando string, no enum: `marketType.name`
- Verificar que el backend está en v3.2 o superior

### Error: "Leverage not allowed"
- Verificar que no estás enviando leverage para spot
- Verificar que leverage está dentro del rango permitido

### UI no se actualiza al cambiar market type
- Verificar que estás llamando `notifyListeners()` en el provider
- Verificar que estás usando `Consumer` o `Provider.of` con `listen: true`

### Pares no se cargan
- Verificar conexión con backend
- Verificar que el exchange soporta ese market type
- Revisar logs del backend para errores

---

## 📞 Ayuda

Si te atascas:
1. Revisar ejemplos en `MARKET_TYPES_USAGE_EXAMPLES.md`
2. Revisar documentación del backend en `BACKEND_RESPONSE_TO_FLUTTER_TEAM.md`
3. Buscar TODOs en el código (ya no deberían quedar)
4. Revisar logs del backend para errores de API

---

## ✅ Checklist Final

Antes de considerar la implementación completa:

- [ ] Selector de market type funciona
- [ ] Leverage slider aparece/desaparece correctamente
- [ ] Validaciones funcionan
- [ ] No hay errores de compilación
- [ ] No hay warnings importantes
- [ ] UI es responsive
- [ ] Errores se manejan gracefully
- [ ] Documentación está actualizada
- [ ] Tests pasan (si los hay)
- [ ] App funciona en debug y release

---

**¡Buena suerte con la implementación!** 🚀

Si completas todo esto, habrás implementado completamente el soporte de Market Types en la app Flutter.

**Tiempo estimado total**: 4-6 horas para implementación completa
**Tiempo mínimo**: 1 hora para funcionalidad básica

---

**Última actualización**: 26 Noviembre 2025  
**Siguiente paso recomendado**: Crear `MarketTypeProvider` (Fase 2)
