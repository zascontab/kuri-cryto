# Kuri Crypto - Proyecto Flutter

Aplicación móvil de trading de criptomonedas desarrollada con Flutter, utilizando arquitectura limpia y las mejores prácticas de desarrollo.

## Estructura del Proyecto

```
kuri_crypto/
├── lib/
│   ├── config/           # Configuración y constantes
│   │   └── api_config.dart
│   ├── models/           # Modelos de datos (DTOs, Entities)
│   │   ├── user/
│   │   ├── market/
│   │   ├── trading/
│   │   └── wallet/
│   ├── services/         # Servicios de API y lógica de negocio
│   │   ├── api/
│   │   ├── websocket/
│   │   ├── storage/
│   │   └── auth/
│   ├── providers/        # Riverpod providers (State Management)
│   │   ├── auth_provider.dart
│   │   ├── market_provider.dart
│   │   ├── trading_provider.dart
│   │   └── theme_provider.dart
│   ├── screens/          # Pantallas principales
│   │   ├── auth/
│   │   ├── home/
│   │   ├── trading/
│   │   ├── portfolio/
│   │   └── settings/
│   ├── widgets/          # Widgets reutilizables
│   │   ├── common/
│   │   ├── charts/
│   │   ├── cards/
│   │   └── dialogs/
│   ├── utils/            # Utilidades y helpers
│   │   ├── formatters/
│   │   ├── validators/
│   │   └── constants/
│   └── main.dart         # Punto de entrada de la aplicación
├── test/                 # Tests unitarios y de integración
├── assets/               # Recursos estáticos
│   ├── images/
│   └── icons/
└── pubspec.yaml          # Dependencias y configuración
```

## Arquitectura

El proyecto sigue los principios de **Clean Architecture** y **Domain-Driven Design (DDD)** con las siguientes capas:

### 1. Capa de Presentación (UI)
- **Screens**: Pantallas completas de la aplicación
- **Widgets**: Componentes reutilizables de UI
- **Providers**: Gestión de estado con Riverpod

### 2. Capa de Dominio
- **Models**: Entidades del dominio y DTOs
- **Use Cases**: Lógica de negocio (implementada como providers)

### 3. Capa de Datos
- **Services**: Servicios para comunicación con APIs, WebSockets y almacenamiento local
- **Repositories**: Abstracciones para acceso a datos (a implementar)

## Dependencias Principales

### State Management
- **flutter_riverpod** (^2.4.9): Gestión de estado reactiva y robusta

### Networking
- **dio** (^5.4.0): Cliente HTTP potente con interceptores
- **web_socket_channel** (^2.4.0): Conexiones WebSocket para datos en tiempo real

### Almacenamiento Local
- **hive** (^2.2.3): Base de datos local rápida y ligera
- **hive_flutter** (^1.1.0): Extensiones de Hive para Flutter
- **flutter_secure_storage** (^9.0.0): Almacenamiento seguro para tokens
- **shared_preferences** (^2.2.2): Preferencias simples de usuario

### UI Components
- **fl_chart** (^0.65.0): Gráficos interactivos para trading
- **flutter_slidable** (^3.0.1): Widgets deslizables
- **shimmer** (^3.0.0): Efectos de carga skeleton

### Utilidades
- **intl** (^0.18.1): Internacionalización y formateo
- **timeago** (^3.6.0): Formateo de fechas relativas

## Configuración de la API

La configuración de endpoints está centralizada en `lib/config/api_config.dart`:

```dart
// URLs Base
API_BASE_URL = "http://localhost:8081/api/v1"
WS_BASE_URL = "ws://localhost:8081/ws"

// Timeouts
connectTimeout = 30000 ms
receiveTimeout = 30000 ms
sendTimeout = 30000 ms

// Retry Logic
maxRetries = 3
retryDelay = 1000 ms (con backoff exponencial)
```

### Endpoints Principales

#### Autenticación
- `POST /auth/login` - Iniciar sesión
- `POST /auth/register` - Registrar usuario
- `POST /auth/refresh` - Refrescar token
- `POST /auth/logout` - Cerrar sesión

#### Mercado
- `GET /market/tickers` - Listado de tickers
- `GET /market/candles` - Datos de velas (OHLCV)
- `GET /market/orderbook` - Libro de órdenes
- `GET /market/trades` - Historial de trades

#### Trading
- `GET/POST /trading/orders` - Gestión de órdenes
- `GET /trading/positions` - Posiciones abiertas
- `GET /trading/balance` - Balance de cuenta

#### WebSocket Channels
- `/ws/ticker` - Actualizaciones de precios
- `/ws/orderbook` - Libro de órdenes en tiempo real
- `/ws/trades` - Trades en tiempo real
- `/ws/user` - Actualizaciones de usuario

## Guía de Inicio

### Prerrequisitos
- Flutter SDK >=3.0.0
- Dart SDK >=3.0.0
- Backend API ejecutándose en `http://localhost:8081`

### Instalación

1. Clonar el repositorio:
```bash
git clone <repository-url>
cd kuri-crypto
```

2. Instalar dependencias:
```bash
flutter pub get
```

3. Generar código de Hive (adaptadores):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Ejecutar la aplicación:
```bash
flutter run
```

## Convenciones de Código

### Nomenclatura
- **Archivos**: `snake_case` (ej: `user_profile.dart`)
- **Clases**: `PascalCase` (ej: `UserProfile`)
- **Variables/Funciones**: `camelCase` (ej: `getUserProfile()`)
- **Constantes**: `camelCase` o `UPPER_CASE` (ej: `apiBaseUrl` o `API_BASE_URL`)

### Organización de Imports
```dart
// 1. Paquetes de Dart
import 'dart:async';

// 2. Paquetes de Flutter
import 'package:flutter/material.dart';

// 3. Paquetes externos
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 4. Imports locales
import 'package:kuri_crypto/models/user.dart';
```

### Comentarios
- Usar `///` para documentación de clases y métodos públicos
- Usar `//` para comentarios inline
- Documentar parámetros complejos y casos especiales

## Temas y Estilos

La aplicación soporta **Material Design 3** con temas claro y oscuro:

- **Color principal**: Indigo (#6366F1)
- **Modo automático**: Sigue la preferencia del sistema
- **Personalización**: Modifica `_buildLightTheme()` y `_buildDarkTheme()` en `main.dart`

## Próximos Pasos

### Implementación Inmediata
1. [ ] Crear modelos de datos (User, Ticker, Order, etc.)
2. [ ] Implementar servicio HTTP con Dio
3. [ ] Implementar servicio WebSocket
4. [ ] Crear providers de autenticación
5. [ ] Implementar pantallas de Login/Register

### Funcionalidades Core
1. [ ] Dashboard de mercado con precios en tiempo real
2. [ ] Pantalla de trading con gráficos interactivos
3. [ ] Gestión de órdenes (crear, cancelar, modificar)
4. [ ] Visualización de portafolio
5. [ ] Historial de transacciones

### Mejoras Futuras
1. [ ] Notificaciones push
2. [ ] Alertas de precio personalizadas
3. [ ] Análisis técnico avanzado
4. [ ] Trading automatizado (bots)
5. [ ] Modo offline con sincronización

## Testing

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests con cobertura
flutter test --coverage

# Ejecutar tests de integración
flutter test integration_test
```

## Build

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Recursos Adicionales

- [Documentación de Flutter](https://docs.flutter.dev/)
- [Riverpod Docs](https://riverpod.dev/)
- [API Documentation](./API-DOCUMENTATION.md)
- [API Summary for Flutter](./API-SUMMARY-FOR-FLUTTER-TEAM.md)
- [SRS Document](./srs.md)

## Licencia

Este proyecto es privado y confidencial.

---

**Versión**: 1.0.0
**Última actualización**: 2025-11-16
