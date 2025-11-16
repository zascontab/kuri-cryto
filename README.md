# Kuri Crypto - Trading App

Aplicación móvil de trading de criptomonedas con análisis avanzado y gestión de riesgo.

## ✨ Características

### 🎨 Modo Oscuro/Claro
- ✅ **Modo Claro**: Interfaz luminosa optimizada para uso diurno
- ✅ **Modo Oscuro**: Interfaz oscura que reduce el cansancio visual
- ✅ **Modo Sistema**: Se adapta automáticamente a las preferencias del dispositivo
- ✅ **Persistencia**: Recuerda tu preferencia entre sesiones

### 📊 Trading (En Desarrollo)
- Dashboard con métricas en tiempo real
- Gestión de posiciones abiertas
- Múltiples estrategias de trading
- Sistema de alertas inteligente
- Análisis multi-timeframe
- Backtesting integrado

### 🛡️ Gestión de Riesgo
- Stop Loss automático
- Trailing Stop
- Kill Switch para protección de capital
- Monitoreo de drawdown

## 🚀 Inicio Rápido

### Prerrequisitos
- Flutter SDK >=3.0.0
- Dart SDK
- Android Studio / Xcode (para desarrollo móvil)

### Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/zascontab/kuri-cryto.git
   cd kuri-cryto
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## 📱 Capturas de Pantalla

*Próximamente...*

## 🎨 Sistema de Temas

La aplicación incluye un sistema completo de temas con soporte para modo claro y oscuro.

### Cambiar el Tema

**Método 1: Desde el AppBar**
- Toca el icono de sol/luna en la parte superior derecha

**Método 2: Desde Configuración**
- Ve a Configuración (ícono de engranaje)
- Selecciona tu modo preferido: Claro, Oscuro o Sistema

### Para Desarrolladores

Consulta [THEME_IMPLEMENTATION.md](./THEME_IMPLEMENTATION.md) para detalles completos sobre la implementación del sistema de temas.

Ejemplo rápido:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/theme_provider.dart' as theme_provider;

// Cambiar a modo oscuro
ref.read(theme_provider.themeProvider.notifier).setThemeMode(
  theme_provider.ThemeMode.dark
);
```

## 📦 Tecnologías

- **Flutter**: Framework de UI multiplataforma
- **Riverpod**: Gestión de estado reactiva
- **Dio**: Cliente HTTP para la API REST
- **WebSocket**: Comunicación en tiempo real
- **fl_chart**: Gráficos y visualizaciones
- **SharedPreferences**: Persistencia local

## 🏗️ Arquitectura

```
lib/
├── config/          # Configuración (temas, constantes)
├── providers/       # Gestión de estado con Riverpod
├── screens/         # Pantallas de la aplicación
├── widgets/         # Widgets reutilizables
├── services/        # Servicios (API, WebSocket)
└── models/          # Modelos de datos
```

## 🔗 Integración con Backend

La aplicación está diseñada para conectarse con el Trading MCP Server.

### Endpoints Disponibles
- `GET /api/v1/scalping/status` - Estado del sistema
- `GET /api/v1/scalping/positions` - Posiciones abiertas
- `GET /api/v1/scalping/strategies` - Estrategias disponibles
- `WebSocket ws://localhost:8081/ws` - Actualizaciones en tiempo real

Para más detalles, consulta:
- [API-DOCUMENTATION.md](./API-DOCUMENTATION.md)
- [API-SUMMARY-FOR-FLUTTER-TEAM.md](./API-SUMMARY-FOR-FLUTTER-TEAM.md)

## 📅 Roadmap

### Fase 0: Critical Safety ✅
- [x] Implementación de temas (modo claro/oscuro)
- [ ] Risk Monitor Widget
- [ ] Kill Switch UI
- [ ] Position Management

### Fase 1: Scalping Foundation
- [ ] Multi-timeframe Analysis UI
- [ ] Backtesting Screens
- [ ] Signal Visualization

### Fase 2: HFT Optimization
- [ ] Execution Performance Charts
- [ ] Advanced Monitoring

### Fase 3: Scaling & Production
- [ ] Alerts & Notifications
- [ ] Parameter Optimization UI
- [ ] Production Features

## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto es privado y está en desarrollo.

## 👥 Equipo

- **Backend Team**: Trading MCP Server
- **Flutter Team**: Mobile App Development

## 📞 Contacto

Para preguntas o soporte, contacta al equipo de desarrollo.

---

**Versión**: 1.0.0
**Última Actualización**: 2025-11-16
