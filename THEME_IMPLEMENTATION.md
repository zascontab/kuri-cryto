# Implementación de Modo Oscuro/Claro - Kuri Crypto

## 📋 Resumen

Esta implementación proporciona un sistema completo de temas (modo claro/oscuro) para la aplicación Kuri Crypto usando Flutter y Riverpod para la gestión de estado.

## 🎨 Características

### 1. **Sistema de Temas Completo**
- ✅ Modo Claro
- ✅ Modo Oscuro
- ✅ Modo Sistema (sigue la configuración del dispositivo)

### 2. **Persistencia de Preferencias**
- Las preferencias del usuario se guardan automáticamente usando `SharedPreferences`
- El tema seleccionado se mantiene entre sesiones de la aplicación

### 3. **Múltiples Widgets de Control**
- `ThemeToggleButton`: Botón simple para alternar entre claro/oscuro
- `ThemeSwitch`: Switch animado con iconos
- `ThemeModeSelector`: Selector completo con las tres opciones

### 4. **Colores Personalizados para Trading**
- Verde para ganancias: `#10B981`
- Rojo para pérdidas: `#EF4444`
- Amarillo para advertencias: `#F59E0B`
- Gris para neutral: `#6B7280`

## 📁 Estructura de Archivos

```
lib/
├── config/
│   └── app_theme.dart              # Definición de temas claro y oscuro
├── providers/
│   └── theme_provider.dart         # Gestión de estado del tema con Riverpod
├── widgets/
│   └── theme_toggle_button.dart    # Widgets para cambiar el tema
├── screens/
│   ├── home_screen.dart            # Pantalla principal con ejemplos
│   └── settings_screen.dart        # Pantalla de configuración
└── main.dart                       # Punto de entrada de la aplicación
```

## 🚀 Uso

### Cambiar el tema programáticamente

```dart
// En cualquier widget que sea ConsumerWidget o tenga acceso a WidgetRef

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/theme_provider.dart' as theme_provider;

// Cambiar a modo oscuro
ref.read(theme_provider.themeProvider.notifier).setThemeMode(
  theme_provider.ThemeMode.dark
);

// Cambiar a modo claro
ref.read(theme_provider.themeProvider.notifier).setThemeMode(
  theme_provider.ThemeMode.light
);

// Alternar entre claro/oscuro
ref.read(theme_provider.themeProvider.notifier).toggleTheme();
```

### Usar los widgets de control

#### 1. Botón de Toggle Simple
```dart
import 'package:kuri_crypto/widgets/theme_toggle_button.dart';

// En el AppBar o cualquier lugar
AppBar(
  actions: [
    ThemeToggleButton(),
  ],
)
```

#### 2. Switch Animado
```dart
import 'package:kuri_crypto/widgets/theme_toggle_button.dart';

ThemeSwitch()
```

#### 3. Selector Completo
```dart
import 'package:kuri_crypto/widgets/theme_toggle_button.dart';

ThemeModeSelector()
```

### Acceder al tema actual

```dart
// Obtener el modo de tema actual
final themeMode = ref.watch(theme_provider.themeProvider);

// Verificar si está en modo oscuro
final isDark = themeMode == theme_provider.ThemeMode.dark;
```

## 🎨 Personalización de Colores

### Modificar los colores del tema

Edita el archivo `lib/config/app_theme.dart`:

```dart
// Cambiar el color primario del modo claro
static const Color _lightPrimary = Color(0xFF2563EB); // Tu color aquí

// Cambiar el color primario del modo oscuro
static const Color _darkPrimary = Color(0xFF3B82F6); // Tu color aquí
```

### Usar colores específicos de trading

```dart
import 'package:kuri_crypto/config/app_theme.dart';

// En cualquier widget
Text(
  '+\$350.00',
  style: TextStyle(color: AppTheme.profitGreen),
)

Text(
  '-\$150.00',
  style: TextStyle(color: AppTheme.lossRed),
)
```

## 🧪 Características Demostradas

La aplicación incluye pantallas de ejemplo que demuestran:

1. **Dashboard (HomeScreen)**
   - Tarjetas de estadísticas con colores temáticos
   - Lista de posiciones con indicadores de ganancia/pérdida
   - Lista de estrategias activas
   - Alertas con diferentes niveles de importancia

2. **Configuración (SettingsScreen)**
   - Selector completo de modo de tema
   - Switch rápido para alternar temas
   - Configuraciones de trading con switches
   - Información de la cuenta

## 📦 Dependencias Requeridas

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  shared_preferences: ^2.2.2
```

## 🔧 Instalación

1. Asegúrate de tener todas las dependencias en `pubspec.yaml`
2. Ejecuta:
   ```bash
   flutter pub get
   ```
3. Ejecuta la aplicación:
   ```bash
   flutter run
   ```

## 💡 Buenas Prácticas Implementadas

1. **Separación de Responsabilidades**
   - Los temas están definidos en un archivo separado
   - La lógica de gestión de estado está en el provider
   - Los widgets de UI están separados

2. **Código Reutilizable**
   - Múltiples widgets para diferentes casos de uso
   - Colores personalizados accesibles desde cualquier parte

3. **Persistencia de Datos**
   - Las preferencias se guardan automáticamente
   - La experiencia del usuario se mantiene entre sesiones

4. **Accesibilidad**
   - Tooltips en los botones
   - Indicadores visuales claros del estado actual

## 🎯 Próximos Pasos

Para integrar con el backend de trading:

1. **Conectar con la API**
   - Implementar cliente HTTP con Dio
   - Configurar WebSocket para actualizaciones en tiempo real

2. **Gestión de Estado Real**
   - Providers para posiciones, estrategias, métricas
   - Sincronización con el backend

3. **Gráficos y Visualizaciones**
   - Integrar fl_chart para mostrar datos de trading
   - Implementar gráficos de rendimiento

4. **Notificaciones**
   - Sistema de alertas push
   - Notificaciones locales para eventos importantes

## 📝 Notas

- El tema se aplica automáticamente a toda la aplicación
- Los colores se ajustan automáticamente según el tema seleccionado
- Material 3 está habilitado para un diseño moderno
- El sistema respeta las preferencias del sistema operativo cuando está en modo "Sistema"

## 🐛 Troubleshooting

### El tema no se guarda
- Verifica que `shared_preferences` esté correctamente instalado
- Asegúrate de que la aplicación tenga permisos de escritura

### Los colores no se ven bien
- Revisa la configuración de colores en `app_theme.dart`
- Asegúrate de usar `Theme.of(context)` para acceder a los colores del tema

### El tema no cambia
- Verifica que estés usando `ConsumerWidget` o `Consumer` de Riverpod
- Asegúrate de que la app esté envuelta en `ProviderScope`

## 📞 Soporte

Para preguntas o problemas, consulta la documentación de:
- [Flutter](https://flutter.dev/docs)
- [Riverpod](https://riverpod.dev)
- [Material Design 3](https://m3.material.io)
