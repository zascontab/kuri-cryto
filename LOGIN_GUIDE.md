# 🔐 Login con Google - Guía Completa

## ✅ ¿Qué hay implementado?

✅ Login con Google OAuth (sin Firebase)  
✅ Pantalla de login animada  
✅ Persistencia de sesión segura  
✅ Cerrar sesión desde configuración  

## 📦 Dependencias

```yaml
google_sign_in: ^6.2.1
flutter_secure_storage: ^9.0.0
```

## 🚀 Configuración (3 pasos)

### Paso 1: Google Cloud Console

1. Ve a [console.cloud.google.com](https://console.cloud.google.com/)
2. Crea un proyecto nuevo
3. **APIs & Services** → **Credentials** → **Create Credentials** → **OAuth 2.0 Client ID**

#### Para Android:
- Tipo: **Android**
- Package name: `com.example.kuri_crypto`  
  *(Lo encuentras en [android/app/build.gradle.kts](android/app/build.gradle.kts))*
- SHA-1 certificate fingerprint:
  ```bash
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
  ```
  Copia el SHA-1 y pégalo

#### Para iOS:
- Tipo: **iOS**
- Bundle ID: *(Lo obtienes de Xcode)*
- **Guarda el Client ID** que te da (algo como `123456-abc.apps.googleusercontent.com`)

### Paso 2: Configurar iOS

Edita [ios/Runner/Info.plist](ios/Runner/Info.plist) y agrega **antes del último `</dict>`**:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Si tu Client ID es: 123456-abc.apps.googleusercontent.com -->
            <!-- Invierte el dominio: com.googleusercontent.apps.123456-abc -->
            <string>com.googleusercontent.apps.123456-abc</string>
        </array>
    </dict>
</array>
```

### Paso 3: Ejecutar

```bash
flutter run
```

## 📱 Configurar tu Teléfono Android

1. **Habilitar modo desarrollador:**
   - Ajustes → Acerca del teléfono → Toca **Número de compilación** 7 veces

2. **Activar depuración USB:**
   - Ajustes → Opciones de desarrollador → Activa **Depuración USB**

3. **Conectar y autorizar:**
   - Conecta el cable USB
   - Acepta el popup "¿Permitir depuración USB?"
   - Marca "Permitir siempre desde este equipo"

## 🔧 Si no detecta tu dispositivo

```bash
# En PowerShell, ejecuta:
$env:Path += ";C:\Users\inti\AppData\Local\Android\sdk\platform-tools"
adb kill-server
adb start-server
adb devices
```

**Si aún no aparece:**
- Cambia el modo USB en el teléfono a **Transferencia de archivos**
- En Opciones de desarrollador → **Revocar autorizaciones USB**
- Desconecta y reconecta el cable

## 💻 Usar en tu Código

### Verificar si está autenticado
```dart
final isAuth = ref.watch(isAuthenticatedProvider);

if (isAuth) {
  // Usuario logueado
} else {
  // Mostrar login
}
```

### Obtener información del usuario
```dart
final userInfo = ref.watch(userInfoProvider);

print('Email: ${userInfo?['email']}');
print('Nombre: ${userInfo?['displayName']}');
print('Foto: ${userInfo?['photoUrl']}');
```

### Cerrar sesión
```dart
await ref.read(authNotifierProvider.notifier).signOut();

// Navegar al login
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => const LoginScreen()),
  (route) => false,
);
```

### Login manual (ya está en LoginScreen)
```dart
await ref.read(authNotifierProvider.notifier).signInWithGoogle();
```

## 📁 Archivos del Proyecto

### Creados:
- `lib/services/auth_service.dart` - Lógica de autenticación
- `lib/providers/auth_provider.dart` - Estado con Riverpod
- `lib/screens/login_screen.dart` - Pantalla de login
- `lib/widgets/user_info_widget.dart` - Widgets del usuario

### Modificados:
- `lib/main.dart` - Flujo de autenticación
- `lib/screens/settings_screen.dart` - Opción de cerrar sesión
- `pubspec.yaml` - Dependencias agregadas

## 🔒 Cómo Funciona

```
Usuario → Google Sign-In Nativo → Token de Google
                                         ↓
                              Flutter Secure Storage
                                         ↓
                              Sesión Persistente ✅
```

**Datos guardados (encriptados):**
- ID de usuario
- Email
- Nombre
- URL de foto de perfil

**Almacenamiento:**
- Android: SharedPreferences encriptadas
- iOS: Keychain del sistema

## ❓ Preguntas Frecuentes

**¿Necesito Firebase?**  
No. Esta implementación usa solo Google OAuth nativo.

**¿Dónde pongo el archivo JSON de Google?**  
No necesitas ningún archivo JSON. Todo funciona automáticamente con package name + SHA-1 (Android) y Client ID (iOS).

**¿La sesión persiste entre reinicios?**  
Sí, se guarda encriptada localmente y se restaura automáticamente al abrir la app.

**¿Es seguro?**  
Sí, usa OAuth 2.0 de Google (estándar de la industria) + almacenamiento encriptado local.

**¿Funciona offline?**  
La información del usuario sí (está guardada localmente). El login inicial necesita internet.

**¿Puedo agregar más métodos de login?**  
Sí, puedes agregar Apple, Facebook, etc. de forma similar sin Firebase.

## 🐛 Solución de Errores Comunes

### "PlatformException(sign_in_failed)"
**Causa:** SHA-1 no registrado o incorrecto

**Solución:**
1. Verifica que el SHA-1 esté correcto en Google Cloud Console
2. Asegúrate de que el package name coincida exactamente
3. Reconstruye: `flutter clean && flutter run`

### "Developer Error" (iOS)
**Causa:** Client ID no configurado correctamente

**Solución:**
1. Verifica que el REVERSED Client ID esté correcto en Info.plist
2. Formato correcto: `com.googleusercontent.apps.TU-CLIENT-ID`
3. Reconstruye: `flutter clean && flutter run`

### Sesión no persiste
**Solución:**
- Reinstala la app completamente: `flutter clean && flutter run`
- Verifica que `flutter_secure_storage` esté instalada

### El botón de login no hace nada
**Solución:**
1. Verifica los logs en la consola
2. Asegúrate de tener conexión a internet
3. Verifica que las credenciales OAuth estén creadas en Google Cloud Console

### Dispositivo no detectado
**Solución:**
```bash
# Agregar ADB al PATH
$env:Path += ";C:\Users\inti\AppData\Local\Android\sdk\platform-tools"

# Reiniciar ADB
adb kill-server
adb start-server
adb devices
```

Si no aparece tu dispositivo:
- Verifica que Depuración USB esté activada
- Cambia el modo USB a "Transferencia de archivos"
- Revoca autorizaciones USB y reconecta

## 📊 Comparación con Firebase

| Característica | Sin Firebase ✅ | Con Firebase |
|---------------|-----------------|--------------|
| Configuración | 5 minutos | 20+ minutos |
| Dependencias | 1 paquete | 3+ paquetes |
| Backend | No necesario | Firebase required |
| Costo | Gratis | Gratis (con límites) |
| Archivos config | Solo Info.plist (iOS) | JSON por plataforma |
| Complejidad | ⭐ Baja | ⭐⭐⭐ Alta |

## 🎨 Personalización

### Cambiar colores del gradiente
En `lib/screens/login_screen.dart`:
```dart
colors: [
  const Color(0xFF667eea),  // Cambiar
  const Color(0xFF764ba2),  // Cambiar
  const Color(0xFFf093fb),  // Cambiar
]
```

### Agregar logo personalizado
1. Agrega tu logo en `assets/google_logo.png`
2. En `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/google_logo.png
   ```

## 🔄 Flujo de la App

```
Inicio
  ↓
Splash Screen (verifica sesión guardada)
  ↓
¿Hay sesión? ─── NO → Login Screen → Google OAuth → Main Screen
  ↓
  SÍ
  ↓
Main Screen
```

## 🎯 Siguiente Paso

1. Configura Google Cloud Console (5 minutos)
2. Ejecuta `flutter run`
3. ¡Listo! 🚀

---

**Actualizado:** 27 de diciembre de 2025
