# 🔧 Configuración de IP para Dispositivos Físicos

## Problema
Cuando ejecutas la app en un dispositivo físico, `localhost` no funciona porque se refiere al dispositivo mismo, no a tu servidor de desarrollo.

## Solución Rápida

### 1. Encuentra tu IP de desarrollo

**Windows:**
```cmd
ipconfig
```
Busca "Dirección IPv4" en tu adaptador de red activo.

**macOS/Linux:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```
o
```bash
ip addr show | grep "inet " | grep -v 127.0.0.1
```

**Ejemplo de salida:**
```
inet 192.168.1.105/24 brd 192.168.1.255 scope global dynamic
```
Tu IP sería: `192.168.1.105`

### 2. Configura la IP en la app

Edita el archivo `lib/config/dev_config.dart`:

```dart
static const String developmentServerIp = '192.168.1.105'; // Tu IP aquí
```

### 3. Verifica que tu servidor esté corriendo

Asegúrate de que tu servidor backend esté corriendo en:
- Puerto 9090 (Gateway)
- Puerto 10600 (MCP Server)
- Puerto 8081 (Scalping API)
- Puerto 10000 (MATP Kong Gateway)

### 4. Verifica conectividad

Desde tu dispositivo, abre un navegador y ve a:
```
http://TU_IP:9090/health
```

Si ves una respuesta, la conectividad está funcionando.

## Configuración Avanzada

### Variables de Entorno
Puedes configurar la IP usando variables de entorno:

```bash
flutter run --dart-define=SERVER_IP=192.168.1.105
```

### IPs Comunes por Red
- **Redes domésticas:** 192.168.1.xxx o 192.168.0.xxx
- **Redes corporativas:** 10.0.0.xxx o 172.16.0.xxx
- **Android Emulator:** 10.0.2.2 (para acceder al host)
- **iOS Simulator:** localhost funciona

## Troubleshooting

### Error "Connection refused"
1. Verifica que el servidor esté corriendo
2. Verifica que la IP sea correcta
3. Verifica que no haya firewall bloqueando los puertos
4. Verifica que estés en la misma red

### Error "Network unreachable"
1. Verifica que el dispositivo esté en la misma red WiFi
2. Verifica que la IP sea de la red correcta

### Para desarrollo con múltiples IPs
Edita `alternativeIps` en `dev_config.dart` con todas tus IPs posibles.

## Configuración Automática (Próximamente)
Estamos trabajando en detección automática de IP para simplificar este proceso.