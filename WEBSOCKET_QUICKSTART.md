# WebSocket Service - Quick Start Guide

Guía rápida para empezar a usar el WebSocket Service en 5 minutos.

---

## 1. Instalación (Ya completado)

El servicio ya está implementado con todas sus dependencias:

```yaml
dependencies:
  web_socket_channel: ^2.4.0
  logger: ^2.0.2+1
```

---

## 2. Uso Básico en 3 Pasos

### Paso 1: Importar el servicio

```dart
import 'package:kuri_crypto/services/websocket_service.dart';
import 'package:kuri_crypto/models/websocket_event.dart';
```

### Paso 2: Obtener instancia y conectar

```dart
final wsService = WebSocketServiceProvider.instance;

// Conectar al servidor
await wsService.connect();

// Suscribirse a eventos
await wsService.subscribe([
  'positions',
  'trades',
  'metrics',
  'alerts',
]);
```

### Paso 3: Escuchar eventos

```dart
// Escuchar actualizaciones de posiciones
wsService.positionUpdates.listen((position) {
  print('Nueva posición: ${position.symbol}');
  print('PnL: ${position.unrealizedPnl}');
});

// Escuchar trades ejecutados
wsService.tradeExecuted.listen((trade) {
  print('Trade ejecutado: ${trade.symbol} @ ${trade.price}');
});

// Escuchar métricas
wsService.metricsUpdates.listen((metrics) {
  print('PnL Total: ${metrics.totalPnl}');
  print('Win Rate: ${metrics.winRate}%');
});

// Escuchar alertas
wsService.alerts.listen((alert) {
  if (alert.isCritical) {
    // Mostrar alerta crítica
    showDialog(/* ... */);
  }
});
```

---

## 3. Ejemplo Completo en Widget

```dart
import 'package:flutter/material.dart';
import 'package:kuri_crypto/services/websocket_service.dart';
import 'package:kuri_crypto/models/websocket_event.dart';

class TradingDashboard extends StatefulWidget {
  @override
  State<TradingDashboard> createState() => _TradingDashboardState();
}

class _TradingDashboardState extends State<TradingDashboard> {
  final wsService = WebSocketServiceProvider.instance;
  Position? _lastPosition;
  Metrics? _lastMetrics;
  WebSocketConnectionState _connectionState =
      WebSocketConnectionState.disconnected;

  @override
  void initState() {
    super.initState();
    _setupWebSocket();
  }

  Future<void> _setupWebSocket() async {
    // Conectar
    await wsService.connect();

    // Suscribirse
    await wsService.subscribe(['positions', 'metrics', 'alerts']);

    // Escuchar estado de conexión
    wsService.connectionStateStream.listen((state) {
      setState(() => _connectionState = state);
    });

    // Escuchar posiciones
    wsService.positionUpdates.listen((position) {
      setState(() => _lastPosition = position);
    });

    // Escuchar métricas
    wsService.metricsUpdates.listen((metrics) {
      setState(() => _lastMetrics = metrics);
    });

    // Escuchar alertas críticas
    wsService.alerts.listen((alert) {
      if (alert.isCritical) {
        _showCriticalAlert(alert);
      }
    });
  }

  void _showCriticalAlert(Alert alert) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('⚠️ Alerta Crítica'),
        content: Text(alert.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trading Dashboard'),
        actions: [
          // Indicador de conexión
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Icon(
                  _connectionState.isConnected
                      ? Icons.cloud_done
                      : Icons.cloud_off,
                  color: _connectionState.isConnected
                      ? Colors.green
                      : Colors.red,
                ),
                SizedBox(width: 8),
                Text(_connectionState.displayName),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Métricas
            if (_lastMetrics != null) ...[
              Text('Total PnL: ${_lastMetrics!.totalPnl}'),
              Text('Win Rate: ${_lastMetrics!.winRate}%'),
              Text('Active Positions: ${_lastMetrics!.activePositions}'),
              SizedBox(height: 24),
            ],

            // Última posición
            if (_lastPosition != null) ...[
              Text('Última Posición:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Symbol: ${_lastPosition!.symbol}'),
              Text('Side: ${_lastPosition!.side}'),
              Text('PnL: ${_lastPosition!.unrealizedPnl}'),
              Text('Status: ${_lastPosition!.status}'),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // No dispose del servicio si es singleton usado en toda la app
    super.dispose();
  }
}
```

---

## 4. Integración con Riverpod (Recomendado)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuri_crypto/services/websocket_service.dart';

// Provider del servicio
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketServiceProvider.instance;
  service.connect();

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

// Provider de posiciones
final positionsStreamProvider = StreamProvider<Position>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  return wsService.positionUpdates;
});

// Provider de métricas
final metricsStreamProvider = StreamProvider<Metrics>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  return wsService.metricsUpdates;
});

// Uso en Widget
class MetricsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(metricsStreamProvider);

    return metricsAsync.when(
      data: (metrics) => Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Total PnL: ${metrics.totalPnl}'),
              Text('Win Rate: ${metrics.winRate}%'),
            ],
          ),
        ),
      ),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

---

## 5. Inicialización en main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuri_crypto/services/websocket_service.dart';

void main() {
  // Opcional: Configurar URL personalizada
  WebSocketServiceProvider.initialize(
    url: 'ws://localhost:8081/ws', // o tu URL de servidor
  );

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kuri Crypto',
      home: TradingDashboard(),
    );
  }
}
```

---

## 6. Canales Disponibles

Suscríbete a los canales que necesites:

```dart
await wsService.subscribe([
  'positions',      // Actualizaciones de posiciones
  'trades',         // Trades ejecutados
  'metrics',        // Métricas del sistema
  'alerts',         // Alertas
  'kill_switch',    // Eventos de kill switch
]);
```

---

## 7. Manejo de Errores

```dart
// Monitorear estado de conexión
wsService.connectionStateStream.listen((state) {
  switch (state) {
    case WebSocketConnectionState.connected:
      print('✅ Conectado');
      break;
    case WebSocketConnectionState.connecting:
      print('🔄 Conectando...');
      break;
    case WebSocketConnectionState.error:
      print('❌ Error - Reconectando automáticamente');
      break;
    case WebSocketConnectionState.disconnected:
      print('⚫ Desconectado');
      break;
  }
});

// Error en streams individuales
wsService.positionUpdates.listen(
  (position) {
    // Manejar posición
  },
  onError: (error) {
    print('Error en posiciones: $error');
  },
);
```

---

## 8. Verificar Estado de Conexión

```dart
// Getter simple
if (wsService.isConnected) {
  print('Conectado al servidor');
} else {
  print('No conectado');
}

// Canales suscritos
final channels = wsService.getSubscribedChannels();
print('Canales: $channels');

// Reconectar manualmente si es necesario
await wsService.reconnect();
```

---

## 9. Cleanup

```dart
// En el dispose de tu widget principal o app
@override
void dispose() {
  // Solo si tu widget es el dueño del servicio
  wsService.dispose();
  super.dispose();
}

// Normalmente solo desconectas
wsService.disconnect();
```

---

## 10. Demo Widget

Ejecuta el widget de ejemplo incluido:

```dart
import 'package:kuri_crypto/services/websocket_service_example.dart';

// En tu app
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => WebSocketExample(),
  ),
);
```

---

## Troubleshooting Rápido

### No recibo eventos

```dart
// 1. Verificar conexión
print('Connected: ${wsService.isConnected}');

// 2. Verificar suscripciones
print('Channels: ${wsService.getSubscribedChannels()}');

// 3. Reconectar y suscribir
await wsService.connect();
await wsService.subscribe(['positions', 'trades']);
```

### Servidor no responde

```bash
# Verificar que el servidor esté corriendo
curl http://localhost:8081/api/v1/scalping/health
```

### Ver logs detallados

Los logs del servicio se muestran automáticamente en la consola con el paquete `logger`. Busca mensajes con:

- [INFO] - Eventos importantes
- [DEBUG] - Detalles de mensajes
- [WARNING] - Advertencias
- [ERROR] - Errores

---

## Recursos

- **Documentación Completa**: `/WEBSOCKET_DOCUMENTATION.md`
- **Resumen del Sistema**: `/WEBSOCKET_README.md`
- **Ejemplo Interactivo**: `/lib/services/websocket_service_example.dart`
- **Modelos de Datos**: `/lib/models/websocket_event.dart`

---

## Soporte

Si tienes problemas:

1. Revisa `/WEBSOCKET_DOCUMENTATION.md` sección "Troubleshooting"
2. Verifica que el servidor esté corriendo
3. Revisa los logs en consola
4. Ejecuta el widget de ejemplo para confirmar funcionamiento

---

**LISTO! Ya puedes empezar a usar el WebSocket Service.**

Recuerda: El servicio se reconecta automáticamente si se pierde la conexión.
