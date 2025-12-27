# WebSocket Service - Documentación Completa

## Descripción General

Sistema robusto de WebSocket para recibir actualizaciones en tiempo real del backend del Trading MCP Server. Implementa reconexión automática, manejo de eventos tipado, broadcasting, y gestión completa del ciclo de vida de la conexión.

---

## Características Principales

### 1. Conexión WebSocket Robusta
- **URL por defecto**: `ws://localhost:8081/ws`
- **Reconexión automática** con exponential backoff (1s, 2s, 4s, 8s... máx 30s)
- **Heartbeat/ping** cada 30 segundos para mantener la conexión activa
- **Estados de conexión**: `connecting`, `connected`, `disconnected`, `error`

### 2. Manejo de Eventos Tipado
Soporte completo para todos los eventos del backend:
- `position_update` → `Stream<Position>`
- `trade_executed` → `Stream<Trade>`
- `metrics_update` → `Stream<Metrics>`
- `alert` → `Stream<Alert>`
- `kill_switch` → `Stream<KillSwitchEvent>`

### 3. Subscription Management
- Suscripción a canales específicos
- Desuscripción dinámica
- Re-suscripción automática después de reconexión
- Gestión persistente de suscripciones

### 4. Broadcasting con Streams
- `StreamController` broadcast para cada tipo de evento
- Soporte para múltiples listeners simultáneos
- Dispose correcto de todos los streams

### 5. Error Handling Avanzado
- Reconexión automática en caso de desconexión
- Backoff exponencial: 1s → 2s → 4s → 8s → 16s → 30s (máximo)
- Logging detallado de todos los eventos
- Notificación de errores a través de streams

### 6. Lifecycle Management
- `connect()` - Establecer conexión
- `disconnect()` - Desconectar manualmente
- `reconnect()` - Reconectar forzosamente
- `dispose()` - Limpiar todos los recursos
- `isConnected` - Verificar estado de conexión

---

## Arquitectura

### Componentes Principales

```
WebSocketService
├── Connection Management
│   ├── WebSocketChannel
│   ├── Connection State
│   └── Auto-reconnection
├── Event Handling
│   ├── Message Parser
│   ├── Type Router
│   └── Stream Controllers
├── Subscription Management
│   ├── Subscribe/Unsubscribe
│   └── Channel Tracking
└── Lifecycle
    ├── Heartbeat Timer
    ├── Reconnect Timer
    └── Cleanup
```

### Flujo de Datos

```
Backend WebSocket Server
         ↓
WebSocketChannel (web_socket_channel)
         ↓
Message Handler (JSON parsing)
         ↓
Type Router (switch by message type)
         ↓
Stream Controllers (broadcast)
         ↓
UI Widgets (listeners)
```

---

## Instalación y Setup

### 1. Dependencias

El archivo `pubspec.yaml` ya incluye todas las dependencias necesarias:

```yaml
dependencies:
  web_socket_channel: ^2.4.0  # WebSocket communication
  logger: ^2.0.2+1             # Logging
```

### 2. Inicialización

#### Opción A: Usar la instancia singleton (recomendado)

```dart
import 'package:kuri_crypto/services/websocket_service.dart';

void main() {
  // Inicializar con URL personalizada (opcional)
  WebSocketServiceProvider.initialize(
    url: 'ws://your-server.com/ws',
  );

  runApp(MyApp());
}

// Usar en cualquier parte de la app
final wsService = WebSocketServiceProvider.instance;
```

#### Opción B: Crear instancia propia

```dart
final wsService = WebSocketService(
  url: 'ws://localhost:8081/ws',
);
```

---

## Uso Básico

### 1. Conectar al WebSocket

```dart
import 'package:kuri_crypto/services/websocket_service.dart';

final wsService = WebSocketServiceProvider.instance;

// Conectar
await wsService.connect();

// Verificar estado
if (wsService.isConnected) {
  print('Conectado exitosamente');
}
```

### 2. Suscribirse a Canales

```dart
// Suscribirse a múltiples canales
await wsService.subscribe([
  'positions',
  'trades',
  'metrics',
  'alerts',
  'kill_switch',
]);

// Verificar canales suscritos
final channels = wsService.getSubscribedChannels();
print('Canales: $channels');
```

### 3. Escuchar Eventos

```dart
// Position Updates
wsService.positionUpdates.listen((position) {
  print('Position: ${position.symbol}');
  print('PnL: ${position.unrealizedPnl}');
  print('Status: ${position.status}');
});

// Trade Executions
wsService.tradeExecuted.listen((trade) {
  print('Trade: ${trade.symbol} ${trade.side} @ ${trade.price}');
  print('Latency: ${trade.latencyMs}ms');
});

// Metrics Updates
wsService.metricsUpdates.listen((metrics) {
  print('Total PnL: ${metrics.totalPnl}');
  print('Win Rate: ${metrics.winRate}%');
  print('Active Positions: ${metrics.activePositions}');
});

// Alerts
wsService.alerts.listen((alert) {
  if (alert.isCritical) {
    showCriticalAlertDialog(alert);
  } else if (alert.isWarning) {
    showWarningNotification(alert);
  }
});

// Kill Switch Events
wsService.killSwitchEvents.listen((event) {
  if (event.active) {
    print('⚠️ KILL SWITCH ACTIVATED: ${event.reason}');
    showKillSwitchAlert(event);
  }
});

// Connection State Changes
wsService.connectionStateStream.listen((state) {
  print('Connection: ${state.displayName}');
  updateConnectionIndicator(state);
});
```

### 4. Desconectar

```dart
// Desconectar (mantiene suscripciones para reconexión)
await wsService.disconnect();

// Desuscribirse de canales
await wsService.unsubscribe(['positions', 'trades']);

// Limpiar completamente (al cerrar la app)
await wsService.dispose();
```

---

## Uso Avanzado

### 1. Reconexión Automática

El servicio se reconecta automáticamente con exponential backoff:

```dart
// La reconexión es automática, pero puedes forzarla:
await wsService.reconnect();

// Monitorear intentos de reconexión
wsService.connectionStateStream.listen((state) {
  if (state == WebSocketConnectionState.connecting) {
    print('Reconectando...');
  } else if (state == WebSocketConnectionState.error) {
    print('Error - se reintentará en breve');
  }
});
```

### 2. Manejo de Errores

```dart
wsService.connectionStateStream.listen((state) {
  if (state == WebSocketConnectionState.error) {
    // Mostrar indicador de error
    showErrorSnackbar('Conexión perdida. Reconectando...');
  } else if (state == WebSocketConnectionState.connected) {
    // Ocultar indicador de error
    hideErrorSnackbar();
  }
});
```

### 3. Suscripciones Dinámicas

```dart
// Cambiar suscripciones en tiempo real
void updateSubscriptions(bool showAlerts, bool showMetrics) {
  final currentChannels = wsService.getSubscribedChannels();

  if (showAlerts && !currentChannels.contains('alerts')) {
    wsService.subscribe(['alerts']);
  } else if (!showAlerts && currentChannels.contains('alerts')) {
    wsService.unsubscribe(['alerts']);
  }

  // Similar para metrics...
}
```

### 4. Integración con Riverpod

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider del servicio
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketServiceProvider.instance;

  // Conectar al inicializar
  service.connect();

  // Cleanup al dispose
  ref.onDispose(() {
    service.disconnect();
  });

  return service;
});

// Provider de estado de conexión
final connectionStateProvider = StreamProvider<WebSocketConnectionState>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  return wsService.connectionStateStream;
});

// Provider de positions
final positionsStreamProvider = StreamProvider<Position>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  return wsService.positionUpdates;
});

// Uso en widget
class PositionsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionAsync = ref.watch(positionsStreamProvider);

    return positionAsync.when(
      data: (position) => PositionCard(position: position),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => ErrorWidget(err),
    );
  }
}
```

---

## Modelos de Datos

### Position

```dart
class Position {
  final String id;
  final String symbol;           // 'DOGE-USDT', 'BTC-USDT'
  final String side;             // 'long' | 'short'
  final double entryPrice;
  final double currentPrice;
  final double size;
  final double leverage;
  final double stopLoss;
  final double takeProfit;
  final double unrealizedPnl;
  final DateTime openTime;
  final String strategy;
  final String status;           // 'open' | 'closing' | 'closed'

  // Helpers
  double get pnlPercentage;      // PnL en porcentaje
  bool get isProfitable;         // Si tiene ganancia
  bool get isOpen;               // Si está abierta
}
```

### Trade

```dart
class Trade {
  final String id;
  final String orderId;
  final String symbol;
  final String side;             // 'buy' | 'sell'
  final String type;             // 'market' | 'limit' | 'stop'
  final double price;
  final double size;
  final String status;           // 'pending' | 'filled' | 'cancelled'
  final double latencyMs;
  final DateTime timestamp;

  // Helpers
  bool get isFilled;
  bool get isPending;
}
```

### Metrics

```dart
class Metrics {
  final int totalTrades;
  final double winRate;
  final double totalPnl;
  final double dailyPnl;
  final int activePositions;
  final double avgLatencyMs;
  final double? sharpeRatio;
  final double? maxDrawdown;
}
```

### Alert

```dart
class Alert {
  final String id;
  final String type;
  final String severity;         // 'info' | 'warning' | 'critical'
  final String message;
  final String trigger;
  final double? value;
  final DateTime timestamp;
  final bool acknowledged;

  // Helpers
  bool get isCritical;
  bool get isWarning;
  bool get isInfo;
}
```

### KillSwitchEvent

```dart
class KillSwitchEvent {
  final bool active;
  final String reason;
  final DateTime timestamp;
}
```

---

## Estados de Conexión

```dart
enum WebSocketConnectionState {
  connecting,    // Intentando conectar
  connected,     // Conectado exitosamente
  disconnected,  // Desconectado (no reintenta)
  error,         // Error (reintentará automáticamente)
}
```

### Indicadores de Estado

```dart
Widget buildConnectionIndicator(WebSocketConnectionState state) {
  Color color;
  String text;
  IconData icon;

  switch (state) {
    case WebSocketConnectionState.connected:
      color = Colors.green;
      text = 'Conectado';
      icon = Icons.check_circle;
      break;
    case WebSocketConnectionState.connecting:
      color = Colors.orange;
      text = 'Conectando...';
      icon = Icons.sync;
      break;
    case WebSocketConnectionState.error:
      color = Colors.red;
      text = 'Error - Reconectando...';
      icon = Icons.error;
      break;
    case WebSocketConnectionState.disconnected:
      color = Colors.grey;
      text = 'Desconectado';
      icon = Icons.cloud_off;
      break;
  }

  return Row(
    children: [
      Icon(icon, color: color, size: 16),
      SizedBox(width: 8),
      Text(text, style: TextStyle(color: color)),
    ],
  );
}
```

---

## Logging

El servicio usa el paquete `logger` para logging detallado:

### Niveles de Log

- **INFO** (i): Eventos importantes (conexión, desconexión, suscripciones)
- **DEBUG** (d): Detalles de mensajes (útil para debugging)
- **WARNING** (w): Advertencias (ya conectado, canales vacíos)
- **ERROR** (e): Errores con stack trace

### Ejemplo de Logs

```
[INFO] WebSocketService initialized with URL: ws://localhost:8081/ws
[INFO] Connecting to WebSocket: ws://localhost:8081/ws
[INFO] WebSocket connection established
[INFO] Connection state changed: Connected
[DEBUG] Heartbeat started (interval: 30s)
[INFO] Subscription message sent for channels: positions, trades, metrics
[DEBUG] Received message: {"type":"position_update"...}
[DEBUG] Position update: pos_123 - DOGE-USDT
[DEBUG] Heartbeat ping sent
[WARNING] WebSocket connection closed
[ERROR] WebSocket error: SocketException...
[INFO] Scheduling reconnection in 2s
```

---

## Testing

### Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kuri_crypto/services/websocket_service.dart';

void main() {
  group('WebSocketService', () {
    late WebSocketService wsService;

    setUp(() {
      wsService = WebSocketService(url: 'ws://localhost:8081/ws');
    });

    tearDown(() async {
      await wsService.dispose();
    });

    test('Initial state is disconnected', () {
      expect(wsService.isConnected, false);
      expect(
        wsService.connectionState,
        WebSocketConnectionState.disconnected,
      );
    });

    test('Subscribe adds channels', () async {
      await wsService.subscribe(['positions', 'trades']);
      final channels = wsService.getSubscribedChannels();
      expect(channels, contains('positions'));
      expect(channels, contains('trades'));
    });

    test('Position stream emits events', () async {
      expectLater(
        wsService.positionUpdates,
        emitsInOrder([
          isA<Position>(),
          isA<Position>(),
        ]),
      );

      // Simulate position updates...
    });
  });
}
```

### Mock WebSocket Server

```dart
import 'dart:io';

Future<void> startMockWebSocketServer() async {
  final server = await HttpServer.bind('localhost', 8081);

  await for (var request in server) {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      var socket = await WebSocketTransformer.upgrade(request);

      // Handle subscriptions
      socket.listen((message) {
        final data = jsonDecode(message);
        if (data['action'] == 'subscribe') {
          // Send mock position update
          socket.add(jsonEncode({
            'type': 'position_update',
            'data': {
              'id': 'pos_123',
              'symbol': 'BTC-USDT',
              'unrealized_pnl': 15.50,
              // ... más campos
            },
            'timestamp': DateTime.now().toIso8601String(),
          }));
        }
      });
    }
  }
}
```

---

## Mejores Prácticas

### 1. Singleton Pattern

Usar el provider singleton para toda la app:

```dart
// ✅ CORRECTO
final wsService = WebSocketServiceProvider.instance;

// ❌ EVITAR (crear múltiples instancias)
final wsService1 = WebSocketService();
final wsService2 = WebSocketService();
```

### 2. Dispose Correcto

```dart
class _MyWidgetState extends State<MyWidget> {
  StreamSubscription? _positionSub;

  @override
  void initState() {
    super.initState();
    _positionSub = wsService.positionUpdates.listen((position) {
      // Handle position
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();  // ✅ Cancelar suscripción
    super.dispose();
  }
}
```

### 3. Error Handling

```dart
wsService.positionUpdates.listen(
  (position) {
    // Handle position
  },
  onError: (error) {
    print('Error receiving position: $error');
    showErrorSnackbar('Error al recibir posiciones');
  },
);
```

### 4. Connection State Monitoring

```dart
class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();

    wsService.connectionStateStream.listen((state) {
      if (state == WebSocketConnectionState.connected) {
        // Refresh data
        _loadPositions();
        _loadMetrics();
      }
    });
  }
}
```

---

## Troubleshooting

### Problema: No se reciben eventos

**Solución**:
```dart
// 1. Verificar conexión
print('Connected: ${wsService.isConnected}');

// 2. Verificar suscripciones
print('Channels: ${wsService.getSubscribedChannels()}');

// 3. Conectar si es necesario
if (!wsService.isConnected) {
  await wsService.connect();
}

// 4. Suscribirse si es necesario
if (wsService.getSubscribedChannels().isEmpty) {
  await wsService.subscribe(['positions', 'trades']);
}
```

### Problema: Reconexión infinita

**Solución**: Verificar que el servidor WebSocket esté corriendo:
```bash
# Verificar si el servidor está activo
curl -i -N -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  http://localhost:8081/ws
```

### Problema: Memory leaks

**Solución**: Asegurarse de cancelar suscripciones:
```dart
StreamSubscription? _sub;

@override
void dispose() {
  _sub?.cancel();  // ✅ IMPORTANTE
  super.dispose();
}
```

---

## Roadmap

### Versión Actual (1.0.0)
- ✅ Conexión WebSocket básica
- ✅ Reconexión automática con exponential backoff
- ✅ Heartbeat cada 30 segundos
- ✅ Streams tipados para todos los eventos
- ✅ Subscription management
- ✅ Logging completo

### Versión 1.1.0 (Planeada)
- [ ] Compresión de mensajes (gzip)
- [ ] Métricas de performance
- [ ] Retry policies configurables
- [ ] Offline queue para mensajes

### Versión 1.2.0 (Planeada)
- [ ] Autenticación JWT
- [ ] Encriptación end-to-end
- [ ] Multi-server support
- [ ] Load balancing

---

## Recursos

- **API Documentation**: `/API-DOCUMENTATION.md`
- **Flutter Integration Guide**: `/API-SUMMARY-FOR-FLUTTER-TEAM.md`
- **Example Usage**: `/lib/services/websocket_service_example.dart`
- **Backend Repository**: https://github.com/rantipay/trading-mcp

---

## Soporte

Para preguntas o problemas:
- **Issues**: GitHub Issues
- **Email**: backend-team@company.com
- **Slack**: #flutter-backend-support

---

**Versión**: 1.0.0
**Última Actualización**: 2025-11-16
**Autor**: Trading MCP Team
