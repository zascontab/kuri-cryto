# Quick Start Guide - Flutter UI

## 🚀 Inicio Rápido

### Requisitos Previos
```bash
Flutter SDK: 3.0+
Dart: 3.0+
```

### 1. Instalar Dependencias

Primero, agrega las dependencias necesarias a `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.9

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # HTTP & WebSocket (para integración backend)
  dio: ^5.4.0
  web_socket_channel: ^2.4.0

  # UI Components (opcional, para mejoras futuras)
  flutter_slidable: ^3.0.1
  shimmer: ^3.0.0
```

Luego ejecuta:
```bash
flutter pub get
```

### 2. Ejecutar la Aplicación

```bash
# Modo debug
flutter run

# Modo release
flutter run --release

# Seleccionar dispositivo específico
flutter run -d <device-id>
```

### 3. Ver Dispositivos Disponibles
```bash
flutter devices
```

---

## 📱 Navegación de la App

### Estructura de Tabs
1. **Home** (Dashboard)
   - System status
   - Key metrics (P&L, Win Rate, Positions, Latency)
   - Start/Stop engine FAB

2. **Positions**
   - Open Positions tab
   - History tab
   - Actions: Close, Edit SL/TP, Breakeven, Trailing

3. **Strategies**
   - Overview con métricas totales
   - Lista de 5 estrategias
   - Toggle enable/disable
   - Configure parameters

4. **Risk**
   - Risk Sentinel card
   - Drawdown monitors
   - Kill Switch
   - Risk limits editor
   - Exposure breakdown

5. **More**
   - Execution Stats
   - Trading Pairs
   - Alerts
   - Settings
   - About

---

## 🧪 Testing con Mock Data

Actualmente todas las pantallas usan **datos mock** para desarrollo. Los datos están hardcoded en cada screen:

### Dashboard Mock Data
```dart
_uptime = '2h 30m';
_totalPnl = 125.50;
_winRate = 65.5;
_activePositions = 3;
_avgLatency = 45.2;
```

### Positions Mock Data
- 3 posiciones abiertas (BTC, ETH, DOGE)
- 2 posiciones cerradas en history

### Strategies Mock Data
- RSI Scalping (active, 68.5% win rate)
- MACD Scalping (active, 62.3% win rate)
- Bollinger Scalping (active, 71.2% win rate)
- Volume Scalping (inactive, 58.9% win rate)
- AI Scalping (active, 75.6% win rate)

### Risk Mock Data
```dart
_dailyDrawdown = 2.3;
_totalExposure = 3500.0;
_consecutiveLosses = 2;
_riskMode = 'Normal';
_killSwitchActive = false;
```

---

## 🔌 Integración con Backend

### Paso 1: Conectar Servicios

Reemplazar los mock data con llamadas a servicios reales:

```dart
// Antes (Mock)
double _totalPnl = 125.50;

// Después (Real API)
final metrics = await ref.read(scalpingServiceProvider).getMetrics();
double _totalPnl = metrics.totalPnl;
```

### Paso 2: Agregar WebSocket

Para actualizaciones en tiempo real:

```dart
@override
void initState() {
  super.initState();

  // Conectar WebSocket
  ref.read(websocketServiceProvider).connect();

  // Escuchar eventos
  ref.read(websocketServiceProvider).stream.listen((event) {
    if (event.type == 'position_update') {
      _updatePosition(event.data);
    }
  });
}
```

### Paso 3: Endpoints a Conectar

Según el SRS, estos son los endpoints principales:

**Dashboard:**
- `GET /api/v1/scalping/status`
- `GET /api/v1/scalping/metrics`
- `POST /api/v1/scalping/start`
- `POST /api/v1/scalping/stop`

**Positions:**
- `GET /api/v1/scalping/positions`
- `POST /api/v1/positions/:id/close`
- `PUT /api/v1/positions/:id/sltp`

**Strategies:**
- `GET /api/v1/scalping/strategies`
- `POST /api/v1/scalping/strategies/:name/start`
- `POST /api/v1/scalping/strategies/:name/stop`

**Risk:**
- `GET /api/v1/risk/sentinel/state`
- `POST /api/v1/risk/sentinel/kill-switch`
- `PUT /api/v1/scalping/risk/limits`

---

## 🎨 Personalización de UI

### Cambiar Colores

Editar `lib/main.dart`:

```dart
ThemeData _buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1), // ← Cambiar aquí
      brightness: Brightness.light,
    ),
    // ...
  );
}
```

### Colores Actuales
- Profit/Long: #4CAF50 (Verde)
- Loss/Short: #F44336 (Rojo)
- Info/Neutral: Blue (sistema)
- Warning: Orange (sistema)

### Cambiar Refresh Interval

```dart
// dashboard_screen.dart
void _startAutoRefresh() {
  _refreshTimer = Timer.periodic(
    const Duration(seconds: 5), // ← Cambiar aquí
    (timer) => _loadData(),
  );
}
```

---

## 🐛 Debugging

### Ver Logs
```dart
print('Position closed: $positionId');
debugPrint('Error loading data: $error');
```

### Flutter DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Hot Reload
Durante el desarrollo, usa:
- `r` - Hot reload
- `R` - Hot restart
- `q` - Quit

---

## 📦 Build para Producción

### Android
```bash
flutter build apk --release
# APK en: build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
flutter build ios --release
# Luego abrir Xcode para signing y archiving
```

---

## ✅ Checklist de Integración

Antes de conectar con backend real:

- [ ] Verificar que el backend esté corriendo en `http://localhost:8081`
- [ ] Probar endpoints con Postman o curl
- [ ] Configurar `api_config.dart` con la URL correcta
- [ ] Implementar manejo de errores en servicios
- [ ] Agregar retry logic con exponential backoff
- [ ] Configurar WebSocket connection
- [ ] Implementar persistencia con Hive (cache offline)
- [ ] Agregar loading states (Shimmer)
- [ ] Testing de widgets
- [ ] Testing de integración

---

## 🔧 Troubleshooting

### Error: "Cannot find package"
```bash
flutter pub get
flutter clean
flutter pub get
```

### Error: "Gradle build failed" (Android)
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter build apk
```

### Error: "CocoaPods" (iOS)
```bash
cd ios
pod install
cd ..
flutter clean
flutter build ios
```

---

## 📚 Recursos Adicionales

### Documentación del Proyecto
- `srs.md` - Especificación completa de requisitos
- `API-DOCUMENTATION.md` - Documentación de API backend
- `API-SUMMARY-FOR-FLUTTER-TEAM.md` - Resumen para Flutter team
- `IMPLEMENTATION_SUMMARY.md` - Este resumen de implementación

### Enlaces Útiles
- [Flutter Docs](https://docs.flutter.dev)
- [Riverpod Docs](https://riverpod.dev)
- [Material 3 Guidelines](https://m3.material.io)
- [Dio Package](https://pub.dev/packages/dio)

---

## 🎯 Próximos Pasos

1. **Fase 0 (Esta semana)**
   - [x] Crear UI de pantallas principales
   - [ ] Conectar con backend real
   - [ ] Implementar WebSocket
   - [ ] Testing básico

2. **Fase 1 (Próxima semana)**
   - [ ] Multi-timeframe analysis UI
   - [ ] Backtesting screens
   - [ ] Advanced charts

3. **Fase 2-3 (Siguientes semanas)**
   - [ ] Alerts & notifications
   - [ ] Parameter optimization UI
   - [ ] Production features

---

## 💡 Tips

### Performance
- Usa `const` constructors donde sea posible
- Dispose de controllers y timers
- Evita rebuilds innecesarios con `Consumer` en lugar de `ConsumerWidget` cuando corresponda

### UX
- Siempre muestra feedback al usuario (SnackBar, Toast)
- Usa haptic feedback en acciones importantes
- Confirma acciones destructivas (close position, kill switch)
- Mantén loading states claros

### Code Quality
- Comenta código complejo
- Sigue convenciones de naming de Dart
- Usa linter (analysis_options.yaml)
- Escribe tests para widgets críticos

---

**¿Necesitas ayuda?** Revisa el SRS o la documentación de API para más detalles.

**Ready to Code!** 🚀
