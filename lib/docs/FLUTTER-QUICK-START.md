# Flutter Quick Start Guide - API Gateway

**Última actualización:** 2025-11-16  
**Versión:** 1.0.0

---

## 🚀 Inicio Rápido

### Endpoint Único

```dart
static const String baseUrl = 'http://192.168.100.145:9090';
```

**¡Eso es todo!** Un solo endpoint para toda la aplicación.

---

## ✅ Verificar Conectividad

### Desde Terminal

```bash
# Health check del gateway
curl http://192.168.100.145:9090/health

# Información del gateway
curl http://192.168.100.145:9090/api/gateway/info

# Health del scalping
curl http://192.168.100.145:9090/api/scalping/api/v1/scalping/health
```

### Desde Flutter

```dart
import 'package:dio/dio.dart';

final dio = Dio(BaseOptions(
  baseUrl: 'http://192.168.100.145:9090',
));

// Test de conectividad
final response = await dio.get('/health');
print(response.data); // {"status": "ok", "gateway": "running"}
```

---

## 📱 Configuración Completa

### 1. Agregar Dependencias

```yaml
# pubspec.yaml
dependencies:
  dio: ^5.4.0
  flutter_riverpod: ^2.4.9
  web_socket_channel: ^2.4.0
  fl_chart: ^0.65.0
```

### 2. Crear Configuración

```dart
// lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'http://192.168.100.145:9090';
  
  // Gateway endpoints
  static const String gatewayHealth = '/health';
  static const String gatewayInfo = '/api/gateway/info';
  
  // Scalping endpoints
  static const String scalpingBase = '/api/scalping/api/v1/scalping';
  static const String scalpingStatus = '$scalpingBase/status';
  static const String scalpingMetrics = '$scalpingBase/metrics';
  static const String scalpingPositions = '$scalpingBase/positions';
  static const String scalpingStrategies = '$scalpingBase/strategies';
  
  // MCP endpoints
  static const String mcpBase = '/api/mcp';
  static const String mcpTools = '$mcpBase/tools';
}
```

### 3. Crear Cliente API

```dart
// lib/services/trading_api_client.dart
import 'package:dio/dio.dart';
import '../config/api_config.dart';

class TradingApiClient {
  late final Dio _dio;
  
  TradingApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    
    // Logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }
  
  // Gateway
  Future<Map<String, dynamic>> checkHealth() async {
    final response = await _dio.get(ApiConfig.gatewayHealth);
    return response.data;
  }
  
  Future<Map<String, dynamic>> getGatewayInfo() async {
    final response = await _dio.get(ApiConfig.gatewayInfo);
    return response.data;
  }
  
  // Scalping
  Future<Map<String, dynamic>> getScalpingStatus() async {
    final response = await _dio.get(ApiConfig.scalpingStatus);
    return response.data['data'];
  }
  
  Future<Map<String, dynamic>> getMetrics() async {
    final response = await _dio.get(ApiConfig.scalpingMetrics);
    return response.data['data'];
  }
  
  Future<List<dynamic>> getPositions() async {
    final response = await _dio.get(ApiConfig.scalpingPositions);
    return response.data['data'];
  }
  
  Future<List<dynamic>> getStrategies() async {
    final response = await _dio.get(ApiConfig.scalpingStrategies);
    return response.data['data'];
  }
  
  Future<void> startEngine() async {
    await _dio.post('${ApiConfig.scalpingBase}/start');
  }
  
  Future<void> stopEngine() async {
    await _dio.post('${ApiConfig.scalpingBase}/stop');
  }
}
```

### 4. Crear Modelos

```dart
// lib/models/system_status.dart
class SystemStatus {
  final bool running;
  final String uptime;
  final int pairsCount;
  final int activeStrategies;
  final String healthStatus;
  
  SystemStatus({
    required this.running,
    required this.uptime,
    required this.pairsCount,
    required this.activeStrategies,
    required this.healthStatus,
  });
  
  factory SystemStatus.fromJson(Map<String, dynamic> json) {
    return SystemStatus(
      running: json['running'] ?? false,
      uptime: json['uptime'] ?? '0s',
      pairsCount: json['pairs_count'] ?? 0,
      activeStrategies: json['active_strategies'] ?? 0,
      healthStatus: json['health_status'] ?? 'unknown',
    );
  }
}

// lib/models/metrics.dart
class Metrics {
  final int totalTrades;
  final double winRate;
  final double totalPnl;
  final double dailyPnl;
  final int activePositions;
  
  Metrics({
    required this.totalTrades,
    required this.winRate,
    required this.totalPnl,
    required this.dailyPnl,
    required this.activePositions,
  });
  
  factory Metrics.fromJson(Map<String, dynamic> json) {
    return Metrics(
      totalTrades: json['total_trades'] ?? 0,
      winRate: (json['win_rate'] ?? 0).toDouble(),
      totalPnl: (json['total_pnl'] ?? 0).toDouble(),
      dailyPnl: (json['daily_pnl'] ?? 0).toDouble(),
      activePositions: json['active_positions'] ?? 0,
    );
  }
}
```

### 5. Usar en la App

```dart
// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../services/trading_api_client.dart';
import '../models/system_status.dart';
import '../models/metrics.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _client = TradingApiClient();
  bool _loading = true;
  SystemStatus? _status;
  Metrics? _metrics;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    try {
      setState(() => _loading = true);
      
      // Verificar gateway
      final health = await _client.checkHealth();
      print('Gateway: ${health['status']}');
      
      // Cargar datos
      final statusData = await _client.getScalpingStatus();
      final metricsData = await _client.getMetrics();
      
      setState(() {
        _status = SystemStatus.fromJson(statusData);
        _metrics = Metrics.fromJson(metricsData);
        _loading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => _loading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(title: Text('Trading Dashboard')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Status Card
            Card(
              child: ListTile(
                title: Text('Engine Status'),
                subtitle: Text(_status?.running == true ? 'Running' : 'Stopped'),
                trailing: Icon(
                  _status?.running == true ? Icons.check_circle : Icons.cancel,
                  color: _status?.running == true ? Colors.green : Colors.red,
                ),
              ),
            ),
            
            // Metrics Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Metrics', style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 8),
                    Text('Total Trades: ${_metrics?.totalTrades ?? 0}'),
                    Text('Win Rate: ${_metrics?.winRate.toStringAsFixed(1) ?? 0}%'),
                    Text('Total P&L: \$${_metrics?.totalPnl.toStringAsFixed(2) ?? 0}'),
                    Text('Daily P&L: \$${_metrics?.dailyPnl.toStringAsFixed(2) ?? 0}'),
                    Text('Active Positions: ${_metrics?.activePositions ?? 0}'),
                  ],
                ),
              ),
            ),
            
            // Control Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _client.startEngine();
                      _loadData();
                    },
                    child: Text('Start Engine'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _client.stopEngine();
                      _loadData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text('Stop Engine'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🌐 Información de Red

### Configuración Actual

```
IP Local:        192.168.100.145
Puerto Gateway:  9090
```

### Verificar desde Dispositivo Móvil

1. Conecta tu dispositivo a la misma red WiFi
2. Abre un navegador en el dispositivo
3. Visita: `http://192.168.100.145:9090/health`
4. Deberías ver: `{"status":"ok","gateway":"running"}`

### Troubleshooting

**No puedo conectar desde el móvil:**

1. Verifica que estés en la misma red WiFi
2. Verifica el firewall del servidor:
   ```bash
   sudo ufw allow 9090
   ```
3. Ping al servidor:
   ```bash
   ping 192.168.100.145
   ```

---

## 📋 Endpoints Disponibles

### Gateway

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/health` | GET | Health check del gateway |
| `/api/gateway/info` | GET | Información del gateway |

### Scalping API

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/scalping/api/v1/scalping/status` | GET | Estado del sistema |
| `/api/scalping/api/v1/scalping/metrics` | GET | Métricas de trading |
| `/api/scalping/api/v1/scalping/positions` | GET | Posiciones abiertas |
| `/api/scalping/api/v1/scalping/strategies` | GET | Estrategias disponibles |
| `/api/scalping/api/v1/scalping/start` | POST | Iniciar engine |
| `/api/scalping/api/v1/scalping/stop` | POST | Detener engine |

---

## 📚 Documentación Completa

1. **API Gateway:** `API-GATEWAY.md`
2. **API Completa:** `docs/API_DOCUMENTATION.md`
3. **Resumen Flutter:** `docs/API_SUMMARY_FOR_FLUTTER_TEAM.md`
4. **Red:** `NETWORK-ACCESS.md`

---

## 🆘 Soporte

**Problemas comunes:**

1. **Error de conexión:** Verifica la IP y el puerto
2. **CORS error:** El gateway ya tiene CORS habilitado
3. **Timeout:** Aumenta el timeout en Dio a 30 segundos

**Comandos útiles:**

```bash
# Ver información de red
./scripts/show-network-info.sh

# Ver logs del servidor
tail -f logs/mcp-server-gateway.log

# Verificar que el servidor esté corriendo
ps aux | grep trading-mcp-server
```

---

## ✅ Checklist de Implementación

- [ ] Agregar dependencias (dio, riverpod, etc.)
- [ ] Crear ApiConfig con baseUrl
- [ ] Implementar TradingApiClient
- [ ] Crear modelos (SystemStatus, Metrics, etc.)
- [ ] Probar conectividad desde dispositivo móvil
- [ ] Implementar DashboardScreen
- [ ] Implementar PositionsScreen
- [ ] Implementar StrategiesScreen
- [ ] Agregar manejo de errores
- [ ] Agregar loading states
- [ ] Agregar pull-to-refresh

---

**¡Listo para empezar!** 🚀
