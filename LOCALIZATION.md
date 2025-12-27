# Guía de Localización (L10n) - Kuri Crypto

Esta guía explica cómo usar y mantener el sistema de localización (internacionalización) en la aplicación Kuri Crypto.

## 📋 Tabla de Contenidos

- [Introducción](#introducción)
- [Estructura de Archivos](#estructura-de-archivos)
- [Comandos Principales](#comandos-principales)
- [Cómo Usar las Traducciones](#cómo-usar-las-traducciones)
- [Agregar Nuevos Términos](#agregar-nuevos-términos)
- [Traducciones con Parámetros](#traducciones-con-parámetros)
- [Solución de Problemas](#solución-de-problemas)

---

## Introducción

El sistema de localización permite que la aplicación soporte múltiples idiomas. Actualmente soportamos:
- 🇺🇸 **Inglés (EN)** - Idioma por defecto
- 🇪🇸 **Español (ES)**

Los archivos de traducción se gestionan manualmente en formato Dart y NO se generan automáticamente desde archivos `.arb`.

## Estructura de Archivos

```
lib/l10n/
├── l10n.dart          # Clase abstracta con todas las claves de traducción
├── l10n_en.dart       # Implementación en inglés
├── l10n_es.dart       # Implementación en español
├── intl_en.arb        # [NO USADO] Archivo ARB de inglés
└── intl_es.arb        # [NO USADO] Archivo ARB de español
```

⚠️ **Nota importante**: Aunque existen archivos `.arb`, estos NO se utilizan. Las traducciones se gestionan directamente en los archivos `.dart`.

## Comandos Principales

### 1. Verificar Traducciones

Para verificar que no hay errores en los archivos de localización:

```bash
flutter analyze lib/l10n/
```

### 2. Verificar Uso en la Aplicación

Para verificar que todas las traducciones se usan correctamente:

```bash
flutter analyze lib/screens/
```

### 3. Ejecutar la Aplicación

```bash
flutter run
```

### 4. Ejecutar Tests

```bash
flutter test
```

## Cómo Usar las Traducciones

### En un Widget Stateless/Stateful

```dart
import 'package:kuri_crypto/l10n/l10n.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings), // "Settings" o "Configuración"
      ),
      body: Column(
        children: [
          Text(l10n.language),        // "Language" o "Idioma"
          Text(l10n.selectLanguage),  // "Select Language" o "Seleccionar Idioma"
        ],
      ),
    );
  }
}
```

### En un Consumer de Riverpod

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuri_crypto/l10n/l10n.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final status = ref.watch(systemStatusProvider);

    return Text(
      status.value?.running == true
        ? l10n.running    // "Running" o "En ejecución"
        : l10n.stopped,   // "Stopped" o "Detenido"
    );
  }
}
```

## Agregar Nuevos Términos

### Paso 1: Agregar la Declaración en `l10n.dart`

Abre `lib/l10n/l10n.dart` y agrega el nuevo getter en la clase abstracta:

```dart
abstract class L10n {
  // ... código existente ...

  // Settings Screen
  String get settings;
  String get language;

  // 👇 AGREGAR AQUÍ TU NUEVO TÉRMINO
  String get darkMode;              // Término simple
  String get notifications;
  String get enableNotifications;
}
```

**Ubicación**: Agrega los términos organizados por sección (Dashboard, Settings, etc.)

### Paso 2: Implementar en `l10n_en.dart`

Abre `lib/l10n/l10n_en.dart` y agrega la traducción en inglés:

```dart
class L10nEn extends L10n {
  // ... código existente ...

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  // 👇 AGREGAR LA TRADUCCIÓN EN INGLÉS
  @override
  String get darkMode => 'Dark Mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get enableNotifications => 'Enable Notifications';
}
```

### Paso 3: Implementar en `l10n_es.dart`

Abre `lib/l10n/l10n_es.dart` y agrega la traducción en español:

```dart
class L10nEs extends L10n {
  // ... código existente ...

  @override
  String get settings => 'Configuración';

  @override
  String get language => 'Idioma';

  // 👇 AGREGAR LA TRADUCCIÓN EN ESPAÑOL
  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get enableNotifications => 'Habilitar Notificaciones';
}
```

### Paso 4: Usar en tu Código

```dart
final l10n = L10n.of(context);

SwitchListTile(
  title: Text(l10n.darkMode),           // "Dark Mode" o "Modo Oscuro"
  subtitle: Text(l10n.enableNotifications),
  value: isDarkMode,
  onChanged: (value) { /* ... */ },
);
```

## Traducciones con Parámetros

### Ejemplo 1: Un Parámetro Simple

**En `l10n.dart`:**
```dart
abstract class L10n {
  // Parámetro requerido con nombre
  String strategyActivated({required String name});
}
```

**En `l10n_en.dart`:**
```dart
@override
String strategyActivated({required String name}) => 'Strategy "$name" activated';
```

**En `l10n_es.dart`:**
```dart
@override
String strategyActivated({required String name}) => 'Estrategia "$name" activada';
```

**Uso:**
```dart
final l10n = L10n.of(context);
final message = l10n.strategyActivated(name: 'Scalping Pro');
// EN: "Strategy "Scalping Pro" activated"
// ES: "Estrategia "Scalping Pro" activada"
```

### Ejemplo 2: Múltiples Parámetros

**En `l10n.dart`:**
```dart
abstract class L10n {
  String removePairConfirmation({
    required String exchange,
    required String symbol
  });
}
```

**En `l10n_en.dart`:**
```dart
@override
String removePairConfirmation({
  required String exchange,
  required String symbol
}) => 'Are you sure you want to remove $symbol from $exchange?';
```

**En `l10n_es.dart`:**
```dart
@override
String removePairConfirmation({
  required String exchange,
  required String symbol
}) => '¿Estás seguro de que quieres remover $symbol de $exchange?';
```

**Uso:**
```dart
final confirmation = l10n.removePairConfirmation(
  exchange: 'Binance',
  symbol: 'BTC/USDT',
);
// EN: "Are you sure you want to remove BTC/USDT from Binance?"
// ES: "¿Estás seguro de que quieres remover BTC/USDT de Binance?"
```

### Ejemplo 3: Parámetros Numéricos

**En `l10n.dart`:**
```dart
abstract class L10n {
  String cannotRemovePairWithPositions({required int count});
}
```

**En `l10n_en.dart`:**
```dart
@override
String cannotRemovePairWithPositions({required int count}) =>
    'Cannot remove pair with $count open position${count == 1 ? '' : 's'}';
```

**En `l10n_es.dart`:**
```dart
@override
String cannotRemovePairWithPositions({required int count}) =>
    'No se puede remover el par con $count posición${count == 1 ? '' : 'es'} abierta${count == 1 ? '' : 's'}';
```

**Uso:**
```dart
final message1 = l10n.cannotRemovePairWithPositions(count: 1);
// EN: "Cannot remove pair with 1 open position"
// ES: "No se puede remover el par con 1 posición abierta"

final message2 = l10n.cannotRemovePairWithPositions(count: 3);
// EN: "Cannot remove pair with 3 open positions"
// ES: "No se puede remover el par con 3 posiciones abiertas"
```

## Solución de Problemas

### Error: "The getter 'xxx' isn't defined for the type 'L10n'"

**Causa**: Agregaste el término en `l10n.dart` pero no en `l10n_en.dart` o `l10n_es.dart`

**Solución**:
1. Verifica que el término esté en `l10n.dart`
2. Verifica que esté implementado en AMBOS archivos: `l10n_en.dart` Y `l10n_es.dart`
3. Ejecuta `flutter analyze lib/l10n/`

### Error: "Class 'L10n' can't define static member 'of'"

**Causa**: Hay un conflicto con un getter de instancia llamado `of`

**Solución**: Este error ya está solucionado. El getter se llama `ofLabel` en lugar de `of`.

### Error: "The name 'xxx' is already defined"

**Causa**: Hay un getter duplicado en `l10n.dart`

**Solución**:
```bash
# Buscar duplicados
grep -n "String get yourTerm" lib/l10n/l10n.dart
```
Elimina la declaración duplicada.

### Las traducciones no aparecen

**Verifica**:
1. Que `L10n.localizationsDelegates` y `L10n.supportedLocales` estén en `main.dart`:

```dart
MaterialApp(
  localizationsDelegates: L10n.localizationsDelegates,
  supportedLocales: L10n.supportedLocales,
  // ...
)
```

2. Que estés usando `L10n.of(context)` correctamente:

```dart
final l10n = L10n.of(context); // ✅ Correcto
Text(l10n.settings)

// ❌ Incorrecto:
Text(L10n.settings) // Error: no es estático
```

## Convenciones de Nomenclatura

### Nombres de Claves

- **camelCase**: Usa camelCase para las claves
  ```dart
  String get darkMode;           // ✅ Correcto
  String get dark_mode;          // ❌ Incorrecto
  String get DarkMode;           // ❌ Incorrecto
  ```

- **Descriptivo**: Usa nombres descriptivos
  ```dart
  String get enableNotifications;     // ✅ Correcto
  String get en;                      // ❌ Muy corto
  String get notificationsEnabled;    // ✅ También correcto
  ```

### Organización por Sección

Agrupa las traducciones por pantalla o funcionalidad:

```dart
abstract class L10n {
  // Dashboard Screen
  String get scalpingEngine;
  String get keyMetrics;

  // Settings Screen
  String get settings;
  String get darkMode;
  String get language;

  // Positions Screen
  String get openPositions;
  String get history;
}
```

### Nombres Especiales

Si necesitas una palabra reservada de Dart, agrega un sufijo:

```dart
String get continue_;     // Palabra reservada: continue
String get ofLabel;       // Palabra reservada: of (conflicto con método estático)
String get switchMode;    // Palabra reservada: switch
```

## Ejemplo Completo: Agregar Nueva Funcionalidad

Supongamos que quieres agregar una pantalla de "Perfil de Usuario".

### 1. Planifica los Términos

```
- userProfile (título)
- editProfile (botón)
- username (campo)
- email (campo)
- saveChanges (botón)
- profileUpdated (mensaje de éxito)
- profileUpdateFailed (mensaje de error)
- confirmChanges (diálogo)
```

### 2. Agrega en `l10n.dart`

```dart
abstract class L10n {
  // ... código existente ...

  // User Profile Screen
  String get userProfile;
  String get editProfile;
  String get username;
  String get email;
  String get saveChanges;
  String get profileUpdated;
  String profileUpdateFailed({required String error});
  String get confirmChanges;
}
```

### 3. Implementa en `l10n_en.dart`

```dart
// User Profile Screen
@override
String get userProfile => 'User Profile';

@override
String get editProfile => 'Edit Profile';

@override
String get username => 'Username';

@override
String get email => 'Email';

@override
String get saveChanges => 'Save Changes';

@override
String get profileUpdated => 'Profile updated successfully';

@override
String profileUpdateFailed({required String error}) =>
    'Failed to update profile: $error';

@override
String get confirmChanges => 'Do you want to save these changes?';
```

### 4. Implementa en `l10n_es.dart`

```dart
// User Profile Screen
@override
String get userProfile => 'Perfil de Usuario';

@override
String get editProfile => 'Editar Perfil';

@override
String get username => 'Nombre de Usuario';

@override
String get email => 'Correo Electrónico';

@override
String get saveChanges => 'Guardar Cambios';

@override
String get profileUpdated => 'Perfil actualizado exitosamente';

@override
String profileUpdateFailed({required String error}) =>
    'Error al actualizar perfil: $error';

@override
String get confirmChanges => '¿Deseas guardar estos cambios?';
```

### 5. Usa en tu Pantalla

```dart
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.userProfile),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: l10n.editProfile,
            onPressed: () { /* ... */ },
          ),
        ],
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: l10n.username,
            ),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: l10n.email,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  content: Text(l10n.confirmChanges),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l10n.saveChanges),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                try {
                  // Guardar cambios...
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.profileUpdated)),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.profileUpdateFailed(error: e.toString()),
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(l10n.saveChanges),
          ),
        ],
      ),
    );
  }
}
```

---

## 📚 Referencias

- [Flutter Internationalization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB Format](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
- Archivo principal del proyecto: `CLAUDE.md`

---

**Última actualización**: 2025-01-16
