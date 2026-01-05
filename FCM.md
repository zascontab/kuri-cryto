# Firebase Cloud Messaging (FCM) - Documentación

## 📋 Descripción

Sistema completo de notificaciones push implementado con Firebase Cloud Messaging para recibir alertas en tiempo real sobre precio de criptomonedas, ejecución de trades, actualizaciones de mercado, y más.

---

## ✅ Estado de Implementación

| Componente | Estado |
|------------|--------|
| Dependencias Firebase | ✅ Configuradas |
| Servicio FCM | ✅ Implementado |
| Providers (Riverpod) | ✅ Implementados |
| Modelos | ✅ Creados |
| UI Lista de Notificaciones | ✅ Implementada |
| Configuración Android | ✅ Completada |
| Configuración iOS | ⚠️ Manual requerida |
| Integración en main.dart | ✅ Completada |

---

## 📦 Dependencias

```yaml
firebase_core: ^2.24.2
firebase_messaging: ^14.7.9
```

---

## 🚀 Configuración Realizada

### 1. Firebase Console
- Proyecto creado: `kuri-crypto`
- Apps registradas: Android, iOS, macOS, Web, Windows
- Archivos generados:
  - `lib/firebase_options.dart`
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`

### 2. Android
**Archivos configurados:**
- `android/build.gradle.kts` - Plugin Google Services
- `android/app/build.gradle.kts` - Core library desugaring
- `android/app/src/main/AndroidManifest.xml` - Permisos y metadata

**Configuración clave:**
```kotlin
// Desugaring habilitado
isCoreLibraryDesugaringEnabled = true

// Dependencia agregada
coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
```

### 3. iOS (Configuración Manual Requerida)

**Paso 1:** Abrir proyecto en Xcode
```bash
open ios/Runner.xcworkspace
```

**Paso 2:** Agregar Capabilities
1. Seleccionar target "Runner"
2. Ir a "Signing & Capabilities"
3. Agregar: **Push Notifications**
4. Agregar: **Background Modes** → Marcar "Remote notifications"

**Paso 3:** Editar `ios/Runner/AppDelegate.swift`
```swift
import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**Paso 4:** Subir certificado APNs a Firebase Console

---

## 💻 Uso en el Código

### Inicialización (ya implementada en main.dart)

```dart
// El servicio se inicializa automáticamente
ref.watch(fcmInitializationProvider);

// El token FCM aparece en logs
ref.listen(fcmTokenProvider, (previous, next) {
  next.whenData((token) {
    if (token != null) {
      debugPrint('🔥 FCM Token: $token');
      // Enviar token a tu backend
    }
  });
});

// Escuchar notificaciones
ref.listen(notificationsStreamProvider, (previous, next) {
  next.whenData((notification) {
    debugPrint('🔔 Notificación: ${notification.title}');
  });
});
```

### Agregar botón de notificaciones en tu UI

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/firebase_messaging_provider.dart';
import '../screens/notifications_screen.dart';

// En tu AppBar o Scaffold
Consumer(
  builder: (context, ref, _) {
    final state = ref.watch(notificationsProvider);
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotificationsScreen(),
            ),
          ),
        ),
        if (state.unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${state.unreadCount}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  },
)
```

### Gestionar notificaciones

```dart
final notifier = ref.read(notificationsProvider.notifier);

// Marcar como leída
notifier.markAsRead(notificationId);

// Marcar todas como leídas
notifier.markAllAsRead();

// Eliminar notificación
notifier.removeNotification(notificationId);

// Obtener no leídas
final unread = notifier.getUnread();

// Filtrar por tipo
final priceAlerts = notifier.getByType(NotificationType.priceAlert);
```

### Suscribirse a Topics

```dart
final topicsNotifier = ref.read(subscribedTopicsProvider.notifier);

// Suscribirse
await topicsNotifier.subscribe('price_alerts');
await topicsNotifier.subscribe('trade_updates');
await topicsNotifier.subscribe('btc_alerts');

// Desuscribirse
await topicsNotifier.unsubscribe('price_alerts');
```

---

## 🧪 Cómo Probar

### 1. Obtener Token FCM

Cuando ejecutes la app, verás en los logs:
```
🔥 FCM Token: eW4bR9xGTt2...token-muy-largo...
```

Copia este token completo.

### 2. Enviar Notificación de Prueba

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona proyecto "kuri-crypto"
3. Menú lateral → **"Messaging"** (Cloud Messaging)
4. Click **"Send your first message"**
5. Completa:
   - **Notification title:** `🚀 Bitcoin Alert`
   - **Notification text:** `BTC reached $45,000!`
6. Click **"Send test message"**
7. Pega tu FCM token
8. Click **"Test"**

### 3. Ver la Notificación

- **App abierta:** Se agregará a la lista de notificaciones
- **App en background:** Notificación del sistema
- **App cerrada:** Notificación del sistema que abre la app al tocarla

### 4. Enviar con Data Payload

En "Additional options" → "Custom data":
```
type: priceAlert
symbol: BTCUSDT
price: 45000
actionUrl: /markets/BTCUSDT
```

---

## 🎯 Tipos de Notificaciones

```dart
enum NotificationType {
  general,          // 📢 General
  priceAlert,       // 💰 Alerta de Precio
  tradeExecution,   // ✅ Ejecución de Trade
  marketUpdate,     // 📊 Actualización de Mercado
  positionUpdate,   // 📈 Actualización de Posición
  accountUpdate,    // 👤 Actualización de Cuenta
  systemAlert,      // ⚠️ Alerta del Sistema
  promotion,        // 🎁 Promoción
}
```

---

## 🔧 Integración con Backend

### Enviar notificación desde tu servidor

**REST API:**
```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "🚀 Bitcoin Alert",
      "body": "BTC reached $45,000!"
    },
    "data": {
      "type": "priceAlert",
      "symbol": "BTCUSDT",
      "price": "45000"
    }
  }'
```

**Node.js (Firebase Admin SDK):**
```javascript
const admin = require('firebase-admin');

await admin.messaging().send({
  token: deviceToken,
  notification: {
    title: '🚀 Bitcoin Alert',
    body: 'BTC reached $45,000!'
  },
  data: {
    type: 'priceAlert',
    symbol: 'BTCUSDT',
    price: '45000'
  },
  android: {
    priority: 'high',
  },
  apns: {
    payload: {
      aps: {
        sound: 'default',
        badge: 1
      }
    }
  }
});
```

### Enviar a Topics

```javascript
await admin.messaging().send({
  topic: 'price_alerts',
  notification: {
    title: 'Market Update',
    body: 'Bitcoin volatility increased'
  }
});
```

---

## 📁 Archivos Creados

```
lib/
├── models/
│   └── push_notification.dart              # Modelo de notificación
├── services/
│   └── firebase_messaging_service.dart     # Servicio FCM
├── providers/
│   └── firebase_messaging_provider.dart    # Providers Riverpod
├── screens/
│   └── notifications_screen.dart           # UI lista de notificaciones
└── firebase_options.dart                   # Config Firebase (generado)

android/
├── app/
│   ├── google-services.json               # Config Firebase Android
│   ├── build.gradle.kts                   # ✅ Configurado
│   └── src/main/AndroidManifest.xml       # ✅ Configurado
└── build.gradle.kts                       # ✅ Configurado

ios/
└── Runner/
    ├── GoogleService-Info.plist           # Config Firebase iOS
    └── AppDelegate.swift                  # ⚠️ Editar manualmente
```

---

## 🐛 Troubleshooting

### Token es null

**Causa:** Firebase no se inicializó o no hay Google Play Services

**Solución:**
```bash
flutter clean
flutter pub get
flutter run
```

Para Android, asegúrate de usar emulador con Google Play Services o dispositivo físico.

### No recibo notificaciones en Android

1. Verifica que `google-services.json` existe en `android/app/`
2. Rebuild completo:
   ```bash
   flutter clean
   cd android && ./gradlew clean
   cd ..
   flutter run
   ```
3. Verifica que el token sea correcto (copia TODO el token)

### No recibo notificaciones en iOS

1. Solo funciona en **dispositivo físico**, no simulador
2. Verifica capabilities en Xcode
3. Sube certificado APNs a Firebase Console
4. Verifica que el bundle ID coincida

### Notificaciones no aparecen cuando app está abierta

Las notificaciones en foreground se capturan automáticamente y se agregan a la lista. Si quieres mostrar un SnackBar o dialog, modifica el listener en `main.dart`:

```dart
ref.listen(notificationsStreamProvider, (previous, next) {
  next.whenData((notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(notification.title)),
    );
  });
});
```

---

## 🔐 Seguridad

**IMPORTANTE:**

1. **No commitees archivos sensibles:**
   ```gitignore
   android/app/google-services.json
   ios/Runner/GoogleService-Info.plist
   ios/firebase_app_id_file.json
   ```

2. **Usa proyectos Firebase separados:**
   - Proyecto de desarrollo
   - Proyecto de producción

3. **Valida tokens en el backend:**
   - No confíes en tokens del cliente
   - Implementa autenticación y autorización

4. **Server Key:**
   - Mantén la server key privada
   - Solo úsala en el backend, nunca en el cliente

---

## 📚 Referencias

- [Firebase Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)

---

## ✅ Checklist Post-Implementación

- [x] Dependencias instaladas
- [x] Firebase configurado con `flutterfire configure`
- [x] Android configurado
- [ ] iOS configurado (si aplica)
- [x] Código integrado en main.dart
- [ ] Probado en dispositivo real
- [ ] Token FCM enviado a backend
- [ ] Backend implementado para enviar notificaciones
- [ ] Archivos sensibles agregados a .gitignore
- [ ] Documentación revisada por el equipo

---

**Estado:** ✅ Implementación completa y funcional (Android)  
**Última actualización:** Enero 2026
