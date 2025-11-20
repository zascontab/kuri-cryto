# API Summary for Flutter Team

**Date:** 2025-11-16  
**Project:** Trading MCP Server - Advanced Functions  
**Target:** Flutter Mobile App Development

---

## Executive Summary

El backend está desarrollando funciones avanzadas de trading en **4 fases** durante las próximas **6-8 semanas**. Este documento resume los endpoints disponibles y los que se agregarán para que el equipo de Flutter pueda comenzar el desarrollo en paralelo.

---

## 🚀 API Gateway - Endpoint Único (RECOMENDADO)

### ✅ Base URL (API Gateway)
```
http://192.168.100.145:9090
```

**Ventajas:**
- ✅ **Un solo puerto** - Simplifica la configuración
- ✅ **CORS habilitado** - Listo para aplicaciones móviles
- ✅ **Sin conflictos** - Puerto 9090 (evita Docker en 8080)
- ✅ **Proxy inteligente** - Enruta automáticamente a los servicios correctos
- ✅ **Logging centralizado** - Todos los requests en un lugar

### Rutas del Gateway

| Ruta | Servicio | Descripción |
|------|----------|-------------|
| `/health` | Gateway | Health check del gateway |
| `/api/gateway/info` | Gateway | Información del gateway |
| `/api/mcp/*` | MCP Server | Herramientas de trading MCP |
| `/api/scalping/*` | Scalping API | API de scalping REST |

### Configuración Flutter (Recomendada)

```dart
class ApiConfig {
  // ⭐ USAR ESTO - Un solo endpoint
  static const String baseUrl = 'http://192.168.100.145:9090';
  
  // Rutas
  static const String gatewayHealth = '/health';
  static const String gatewayInfo = '/api/gateway/info';
  static const String scalpingBase = '/api/scalping/api/v1/scalping';
  static const String mcpBase = '/api/mcp';
}
```

---

## Current Status (Available Now)

### ✅ REST API Endpoints

**Via Gateway (Recommended):**
```
http://192.168.100.145:9090/api/scalping/api/v1/scalping
```

**Direct (Alternative):**
```
http://192.168.100.145:8081/api/v1/scalping
```

### ✅ WebSocket URL
```
ws://192.168.100.145:8081/ws
```

**Note:** WebSocket aún no está disponible via Gateway. Usar conexión directa.

### ✅ Available Endpoints (Production Ready)

#### System Control
- `GET /status` - System status
- `GET /metrics` - Trading metrics
- `GET /health` - Health check
- `POST /start` - Start engine
- `POST /stop` - Stop engine

#### Positions
- `GET /positions` - Open positions
- `GET /positions/history` - Position history

#### Strategies
- `GET /strategies` - All strategies
- `GET /strategies/:name` - Strategy details
- `POST /strategies/:name/start` - Start strategy
- `POST /strategies/:name/stop` - Stop strategy
- `PUT /strategies/:name/config` - Update config
- `GET /strategies/:name/performance` - Performance metrics

#### Risk Management
- `GET /risk/limits` - Risk limits
- `PUT /risk/limits` - Update limits
- `GET /risk/exposure` - Current exposure

#### Risk Sentinel (✅ NEW - 2025-11-16)
- `GET /risk/sentinel/state` - Complete risk sentinel state
- `POST /risk/sentinel/kill-switch` - Activate emergency kill switch
- `DELETE /risk/sentinel/kill-switch` - Deactivate kill switch

#### Execution
- `GET /execution/latency` - Latency stats
- `GET /execution/history` - Execution history

#### Pairs
- `POST /pairs/add` - Add trading pair
- `POST /pairs/remove` - Remove trading pair

---

## Development Roadmap

### 📅 Phase 0: Critical Safety (Week 1-2)
**Status:** Starting Now  
**Priority:** CRITICAL

#### New Endpoints
```
GET  /api/v1/risk/sentinel/state          - Risk Sentinel state
POST /api/v1/risk/sentinel/kill-switch    - Activate kill switch
DELETE /api/v1/risk/sentinel/kill-switch  - Deactivate kill switch
GET  /api/v1/positions/manager/state      - Position Manager state
PUT  /api/v1/positions/:id/sltp           - Update SL/TP
POST /api/v1/positions/:id/breakeven      - Move to breakeven
POST /api/v1/positions/:id/trailing-stop  - Enable trailing stop
```

#### Flutter Tasks
- [ ] Implement Risk Monitor widget
- [ ] Add Kill Switch button
- [ ] Create SL/TP edit dialog
- [ ] Add position management actions

---

### 📅 Phase 1: Scalping Foundation (Week 3-4)
**Status:** Planned  
**Priority:** HIGH

#### New Endpoints
```
POST /api/v1/analysis/multi-timeframe  - Multi-timeframe analysis
POST /api/v1/backtest/run              - Run backtest
GET  /api/v1/backtest/results/:id      - Get backtest results
```

#### Flutter Tasks
- [ ] Create multi-timeframe chart widget
- [ ] Add backtest configuration screen
- [ ] Display backtest results
- [ ] Add signal visualization

---

### 📅 Phase 2: HFT Optimization (Week 5-6)
**Status:** Planned  
**Priority:** MEDIUM

#### New Endpoints
```
GET  /api/v1/execution/queue        - Order queue status
GET  /api/v1/execution/performance  - Execution metrics
POST /api/v1/monitoring/metrics/export - Export metrics
```

#### Flutter Tasks
- [ ] Add execution performance charts
- [ ] Create latency monitoring widget
- [ ] Add metrics export functionality

---

### 📅 Phase 3: Scaling & Production (Week 7-8)
**Status:** Planned  
**Priority:** MEDIUM

#### New Endpoints
```
GET  /api/v1/pairs/correlation         - Correlation matrix
POST /api/v1/optimization/run          - Run optimization
GET  /api/v1/optimization/results/:id  - Optimization results
POST /api/v1/alerts/configure          - Configure alerts
GET  /api/v1/alerts/history            - Alert history
POST /api/v1/alerts/:id/acknowledge    - Acknowledge alert
```

#### Flutter Tasks
- [ ] Add correlation heatmap
- [ ] Create optimization screen
- [ ] Implement alert notifications
- [ ] Add alert history view

---

## WebSocket Events

### Current Events
```dart
// Position updates
{
  "type": "position_update",
  "data": { /* position data */ }
}

// Trade executed
{
  "type": "trade_executed",
  "data": { /* trade data */ }
}

// Metrics update
{
  "type": "metrics_update",
  "data": { /* metrics data */ }
}

// Alert triggered
{
  "type": "alert",
  "data": { /* alert data */ }
}

// Kill switch (Phase 0 - New)
{
  "type": "kill_switch",
  "data": {
    "active": true,
    "reason": "Daily drawdown exceeded"
  }
}
```

---

## Priority Features for Flutter

### 🔴 Critical (Start Immediately)

1. **Dashboard Screen**
   - System status
   - Key metrics (P&L, win rate, positions)
   - Start/Stop engine button

2. **Positions Screen**
   - List of open positions
   - Position details
   - Close position action

3. **Strategies Screen**
   - List of strategies
   - Enable/Disable strategies
   - Strategy performance

### 🟡 High Priority (Week 1-2)

4. **Risk Monitor Widget** (Phase 0)
   - Drawdown indicators
   - Exposure bars
   - Kill switch button
   - Risk mode display

5. **Position Management** (Phase 0)
   - Edit SL/TP dialog
   - Move to breakeven button
   - Enable trailing stop

### 🟢 Medium Priority (Week 3-4)

6. **Multi-Timeframe Analysis** (Phase 1)
   - Timeframe selector
   - Indicator charts
   - Signal consensus display

7. **Backtesting** (Phase 1)
   - Backtest configuration
   - Results visualization
   - Performance metrics

### 🔵 Low Priority (Week 5-8)

8. **Advanced Features** (Phase 2-3)
   - Execution performance charts
   - Parameter optimization
   - Alert management
   - Correlation matrix

---

## Data Models (TypeScript → Dart)

### Position
```dart
class Position {
  final String id;
  final String symbol;
  final String side;           // 'long' | 'short'
  final double entryPrice;
  final double currentPrice;
  final double size;
  final double leverage;
  final double stopLoss;
  final double takeProfit;
  final double unrealizedPnl;
  final DateTime openTime;
  final String strategy;
  final String status;         // 'open' | 'closing' | 'closed'
}
```

### RiskState (Phase 0 - New)
```dart
class RiskState {
  final double currentDrawdownDaily;
  final double currentDrawdownWeekly;
  final double currentDrawdownMonthly;
  final double totalExposure;
  final Map<String, double> exposureBySymbol;
  final int consecutiveLosses;
  final String riskMode;       // 'Conservative' | 'Normal' | 'Aggressive'
  final bool killSwitchActive;
  final DateTime lastUpdate;
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
}
```

---

## Recommended Flutter Packages

```yaml
dependencies:
  # HTTP Client
  dio: ^5.4.0
  
  # State Management
  flutter_riverpod: ^2.4.9
  
  # WebSocket
  web_socket_channel: ^2.4.0
  
  # Charts
  fl_chart: ^0.65.0
  syncfusion_flutter_charts: ^24.1.41
  
  # UI Components
  flutter_slidable: ^3.0.1
  shimmer: ^3.0.0
  
  # Utils
  intl: ^0.18.1
  timeago: ^3.6.0
```

---

## API Client Implementation

### Complete API Client Example

```dart
import 'package:dio/dio.dart';

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
    
    // Logging interceptor
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print(obj),
    ));
  }
  
  // Gateway Health Check
  Future<Map<String, dynamic>> checkGatewayHealth() async {
    final response = await _dio.get(ApiConfig.gatewayHealth);
    return response.data;
  }
  
  // Gateway Info
  Future<Map<String, dynamic>> getGatewayInfo() async {
    final response = await _dio.get(ApiConfig.gatewayInfo);
    return response.data;
  }
  
  // Scalping Status
  Future<SystemStatus> getScalpingStatus() async {
    final response = await _dio.get('${ApiConfig.scalpingBase}/status');
    return SystemStatus.fromJson(response.data['data']);
  }
  
  // Scalping Metrics
  Future<Metrics> getMetrics() async {
    final response = await _dio.get('${ApiConfig.scalpingBase}/metrics');
    return Metrics.fromJson(response.data['data']);
  }
  
  // Get Positions
  Future<List<Position>> getPositions() async {
    final response = await _dio.get('${ApiConfig.scalpingBase}/positions');
    return (response.data['data'] as List)
        .map((json) => Position.fromJson(json))
        .toList();
  }
  
  // Start Engine
  Future<void> startEngine() async {
    await _dio.post('${ApiConfig.scalpingBase}/start');
  }
  
  // Stop Engine
  Future<void> stopEngine() async {
    await _dio.post('${ApiConfig.scalpingBase}/stop');
  }
  
  // Get Strategies
  Future<List<Strategy>> getStrategies() async {
    final response = await _dio.get('${ApiConfig.scalpingBase}/strategies');
    return (response.data['data'] as List)
        .map((json) => Strategy.fromJson(json))
        .toList();
  }
  
  // Update Risk Limits
  Future<void> updateRiskLimits(RiskParameters params) async {
    await _dio.put(
      '${ApiConfig.scalpingBase}/risk/limits',
      data: params.toJson(),
    );
  }
}
```

### Usage Example

```dart
class TradingService {
  final TradingApiClient _client = TradingApiClient();
  
  Future<void> initializeApp() async {
    try {
      // Check gateway health
      final health = await _client.checkGatewayHealth();
      print('Gateway status: ${health['status']}');
      
      // Get gateway info
      final info = await _client.getGatewayInfo();
      print('Gateway version: ${info['gateway_version']}');
      
      // Get scalping status
      final status = await _client.getScalpingStatus();
      print('Engine running: ${status.running}');
      
    } catch (e) {
      print('Error initializing: $e');
    }
  }
  
  Future<void> loadDashboard() async {
    try {
      final metrics = await _client.getMetrics();
      final positions = await _client.getPositions();
      final strategies = await _client.getStrategies();
      
      // Update UI...
      
    } catch (e) {
      print('Error loading dashboard: $e');
    }
  }
}
```

---

## Development Workflow

### Week 1-2: Foundation + Phase 0
```
Flutter Team:
✅ Setup project structure
✅ Implement API client
✅ Create basic screens (Dashboard, Positions, Strategies)
✅ Implement WebSocket connection
🔄 Add Risk Monitor (Phase 0)
🔄 Add Kill Switch functionality (Phase 0)

Backend Team:
🔄 Implement Risk Sentinel
🔄 Implement Position Manager
🔄 Implement Auto SL/TP
```

### Week 3-4: Phase 1
```
Flutter Team:
⏳ Multi-timeframe analysis UI
⏳ Backtesting screens
⏳ Signal visualization

Backend Team:
⏳ Multi-timeframe analyzer
⏳ Backtesting engine
⏳ Enhanced signals
```

### Week 5-6: Phase 2
```
Flutter Team:
⏳ Execution performance charts
⏳ Advanced monitoring

Backend Team:
⏳ HFT optimization
⏳ Performance tracking
```

### Week 7-8: Phase 3
```
Flutter Team:
⏳ Alerts & notifications
⏳ Parameter optimization UI
⏳ Production features

Backend Team:
⏳ Multi-pair support
⏳ Alert system
⏳ Production monitoring
```

---

## Testing Strategy

### 1. Mock Server (Immediate)
Create mock responses for current endpoints to start UI development:

```dart
// lib/services/mock_api_client.dart
class MockApiClient {
  Future<SystemStatus> getStatus() async {
    await Future.delayed(Duration(seconds: 1));
    return SystemStatus(
      running: true,
      uptime: '2h30m',
      pairsCount: 3,
      activeStrategies: 5,
      healthStatus: 'healthy',
    );
  }
}
```

### 2. Development Server (Week 1)
Connect to API Gateway:
```
http://192.168.100.145:9090
```

**Verificar conectividad:**
```bash
# Health check
curl http://192.168.100.145:9090/health

# Gateway info
curl http://192.168.100.145:9090/api/gateway/info

# Scalping health
curl http://192.168.100.145:9090/api/scalping/api/v1/scalping/health
```

### 3. Staging Server (Week 3)
Connect to staging environment:
```
https://staging-api.trading-mcp.com
```

### 4. Production (Week 8)
Production deployment

---

## Network Configuration

### IP Address
```
Local Network: 192.168.100.145
```

### Ports
```
API Gateway:    9090  ⭐ USAR ESTE
MCP Server:     10600 (directo, opcional)
Scalping API:   8081  (directo, opcional)
GoCryptoTrader: 9052  (interno, no accesible)
```

### Firewall Rules
Asegúrate de que tu dispositivo móvil/tablet pueda acceder al puerto 9090 en la red local.

### Testing from Mobile Device
```bash
# Desde tu dispositivo móvil (usando Termux o similar)
curl http://192.168.100.145:9090/health
```

---

## Communication Channels

### Daily Sync
- **Time:** 10:00 AM
- **Duration:** 15 minutes
- **Topics:** Progress, blockers, API changes

### API Changes Notification
- Backend team will notify 24h before any breaking changes
- New endpoints will be documented immediately
- Slack channel: `#trading-api-updates`

### Questions & Support
- **Slack:** `#flutter-backend-support`
- **Email:** backend-team@company.com
- **Documentation:** `/docs` folder in repository

---

## Quick Start Checklist

- [ ] Clone repository
- [ ] Read `API_DOCUMENTATION.md`
- [ ] Read `API-GATEWAY.md` ⭐ NEW
- [ ] Read `FLUTTER_INTEGRATION_GUIDE.md`
- [ ] Setup Flutter project with recommended packages
- [ ] Configure API Gateway endpoint: `http://192.168.100.145:9090`
- [ ] Test gateway connectivity from mobile device
- [ ] Implement API client with Dio
- [ ] Test gateway health check endpoint
- [ ] Create mock data for testing
- [ ] Implement Dashboard screen
- [ ] Implement Positions screen
- [ ] Implement Strategies screen
- [ ] Setup WebSocket connection (direct to port 8081)
- [ ] Test with API Gateway
- [ ] Prepare for Phase 0 features (Risk Monitor)

---

## Important Notes

### ⚠️ Breaking Changes
- All breaking changes will be versioned (v1, v2, etc.)
- Minimum 1 week notice before deprecation
- Backward compatibility maintained for 2 weeks

### 🔒 Security (Future)
- JWT authentication coming in Phase 3
- API keys for production
- Rate limiting: 100 req/min

### 📊 Performance
- WebSocket for real-time updates (< 100ms latency)
- REST API for queries (< 500ms response time)
- Pagination for large datasets

---

## 🛡️ Risk Sentinel Integration (NEW - 2025-11-16)

### Overview

El Risk Sentinel es un sistema de monitoreo y control de riesgo en tiempo real que protege el capital mediante:
- Tracking de drawdown (diario, semanal, mensual)
- Kill switch de emergencia
- Límites automáticos de exposición
- Detección de pérdidas consecutivas

### Endpoints

#### 1. GET /api/v1/scalping/risk/sentinel/state

Obtiene el estado completo del Risk Sentinel.

**Request:**
```dart
final response = await http.get(
  Uri.parse('$baseUrl/api/v1/scalping/risk/sentinel/state'),
);
```

**Response:**
```json
{
  "success": true,
  "data": {
    "current_drawdown_daily": 0.0,
    "current_drawdown_weekly": 0.0,
    "current_drawdown_monthly": 0.0,
    "total_exposure": 0.0,
    "exposure_by_symbol": {},
    "consecutive_losses": 0,
    "risk_mode": "Normal",
    "kill_switch_active": false,
    "last_update": "2025-11-16T17:04:18-05:00",
    "max_daily_drawdown": 50.0,
    "max_weekly_drawdown": 250.0,
    "max_monthly_drawdown": 1000.0,
    "max_consecutive_losses": 3,
    "max_total_exposure": 500.0,
    "daily_pnl": 0.0,
    "weekly_pnl": 0.0,
    "monthly_pnl": 0.0
  }
}
```

**Risk Modes:**
- `Normal`: Drawdown < 40% (🟢 Green)
- `Elevated`: Drawdown 40-60% (🟡 Yellow)
- `High`: Drawdown 60-80% (🟠 Orange)
- `Critical`: Drawdown > 80% (🔴 Red)

#### 2. POST /api/v1/scalping/risk/sentinel/kill-switch

Activa el kill switch de emergencia (detiene todo el trading).

**Request:**
```dart
final response = await http.post(
  Uri.parse('$baseUrl/api/v1/scalping/risk/sentinel/kill-switch'),
  headers: {'Content-Type': 'application/json'},
  body: json.encode({'reason': 'Manual activation by user'}),
);
```

**Response:**
```json
{
  "success": true,
  "message": "Kill switch activated",
  "data": {
    "active": true,
    "reason": "Manual activation by user",
    "activated_at": "2025-11-16T17:04:19-05:00"
  }
}
```

#### 3. DELETE /api/v1/scalping/risk/sentinel/kill-switch

Desactiva el kill switch (reanuda el trading).

**Request:**
```dart
final response = await http.delete(
  Uri.parse('$baseUrl/api/v1/scalping/risk/sentinel/kill-switch'),
);
```

**Response:**
```json
{
  "success": true,
  "message": "Kill switch deactivated",
  "data": {
    "active": false,
    "deactivated_at": "2025-11-16T17:04:21-05:00"
  }
}
```

### Flutter Model

```dart
class RiskSentinelState {
  final double currentDrawdownDaily;
  final double currentDrawdownWeekly;
  final double currentDrawdownMonthly;
  final double totalExposure;
  final Map<String, double> exposureBySymbol;
  final int consecutiveLosses;
  final String riskMode;
  final bool killSwitchActive;
  final DateTime lastUpdate;
  final double maxDailyDrawdown;
  final double maxWeeklyDrawdown;
  final double maxMonthlyDrawdown;
  final int maxConsecutiveLosses;
  final double maxTotalExposure;
  final double dailyPnl;
  final double weeklyPnl;
  final double monthlyPnl;
  final String? killSwitchReason;
  final DateTime? killSwitchTime;

  factory RiskSentinelState.fromJson(Map<String, dynamic> json) {
    return RiskSentinelState(
      currentDrawdownDaily: json['current_drawdown_daily'].toDouble(),
      currentDrawdownWeekly: json['current_drawdown_weekly'].toDouble(),
      currentDrawdownMonthly: json['current_drawdown_monthly'].toDouble(),
      totalExposure: json['total_exposure'].toDouble(),
      exposureBySymbol: Map<String, double>.from(
        json['exposure_by_symbol'].map((k, v) => MapEntry(k, v.toDouble()))
      ),
      consecutiveLosses: json['consecutive_losses'],
      riskMode: json['risk_mode'],
      killSwitchActive: json['kill_switch_active'],
      lastUpdate: DateTime.parse(json['last_update']),
      maxDailyDrawdown: json['max_daily_drawdown'].toDouble(),
      maxWeeklyDrawdown: json['max_weekly_drawdown'].toDouble(),
      maxMonthlyDrawdown: json['max_monthly_drawdown'].toDouble(),
      maxConsecutiveLosses: json['max_consecutive_losses'],
      maxTotalExposure: json['max_total_exposure'].toDouble(),
      dailyPnl: json['daily_pnl'].toDouble(),
      weeklyPnl: json['weekly_pnl'].toDouble(),
      monthlyPnl: json['monthly_pnl'].toDouble(),
      killSwitchReason: json['kill_switch_reason'],
      killSwitchTime: json['kill_switch_time'] != null 
        ? DateTime.parse(json['kill_switch_time']) 
        : null,
    );
  }
}
```

### UI Helper

```dart
Color getRiskModeColor(String riskMode) {
  switch (riskMode) {
    case 'Normal':
      return Colors.green;
    case 'Elevated':
      return Colors.yellow;
    case 'High':
      return Colors.orange;
    case 'Critical':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

IconData getRiskModeIcon(String riskMode) {
  switch (riskMode) {
    case 'Normal':
      return Icons.check_circle;
    case 'Elevated':
      return Icons.warning;
    case 'High':
      return Icons.error;
    case 'Critical':
      return Icons.dangerous;
    default:
      return Icons.help;
  }
}
```

### Testing

```bash
# Ejecutar tests automatizados
./test-scripts/test-risk-sentinel.sh

# Test manual
curl http://192.168.100.145:8081/api/v1/scalping/risk/sentinel/state
```

**Ver documentación completa:** `docs/RISK-SENTINEL-ENDPOINTS-FIXED.md`

---

## 🚨 CRÍTICO: Manejo de Errores de Red en Trading

### ⚠️ El Problema

Cuando ejecutas una orden y recibes un `NETWORK_ERROR`, **NO significa que la orden falló**. Puede estar:
- ✅ Ejecutada exitosamente (pero sin confirmación)
- ❌ Realmente fallada
- ⏳ Pendiente de ejecución

**Reintentar ciegamente puede duplicar órdenes y perder dinero real.**

### ✅ La Solución: Verificación de Estado

```dart
class OrderErrorHandler {
  final TradingApiClient _client;
  
  Future<OrderResult> handleOrderSubmission(
    Function orderFn,
    Map<String, dynamic> params,
  ) async {
    try {
      // Intentar ejecutar orden
      final result = await orderFn(params);
      return OrderResult.success(result);
      
    } catch (e) {
      final errorMsg = e.toString();
      
      // CRÍTICO: Network errors requieren verificación
      if (errorMsg.contains('NETWORK_ERROR') || 
          errorMsg.contains('timeout') ||
          errorMsg.contains('Connection')) {
        return await _verifyOrderState(params);
      }
      
      // Errores definitivos - NO reintentar
      if (errorMsg.contains('INSUFFICIENT_BALANCE')) {
        return OrderResult.error('Insufficient balance');
      }
      
      if (errorMsg.contains('INVALID_LEVERAGE')) {
        return OrderResult.error('Invalid leverage (1-100x)');
      }
      
      if (errorMsg.contains('MARGIN_MODE_MISMATCH')) {
        return OrderResult.error(
          'Margin mode mismatch. Close existing positions first.'
        );
      }
      
      // Error desconocido
      return OrderResult.error('Order failed: $errorMsg');
    }
  }
  
  Future<OrderResult> _verifyOrderState(Map<String, dynamic> params) async {
    // Mostrar estado de verificación
    showStatus('Network error. Verifying order status...');
    
    // Esperar 3 segundos para reconciliación automática del backend
    await Future.delayed(Duration(seconds: 3));
    
    // Verificar posiciones reales
    final positions = await _client.getPositions();
    
    // Buscar posición que coincida con los parámetros
    final matchingPosition = positions.firstWhereOrNull((p) =>
      p.symbol == params['pair'] &&
      p.side == params['side'] &&
      p.openTime.isAfter(DateTime.now().subtract(Duration(seconds: 10)))
    );
    
    if (matchingPosition != null) {
      // ⚠️ LA ORDEN SE EJECUTÓ PESE AL ERROR
      return OrderResult.executedDespiteError(matchingPosition);
    }
    
    // Verificar órdenes pendientes
    final orders = await _client.getOpenOrders();
    if (orders.isNotEmpty) {
      return OrderResult.pending('Order is pending confirmation');
    }
    
    // La orden NO se ejecutó - seguro reintentar
    return OrderResult.safeToRetry();
  }
}

// Modelo de resultado
class OrderResult {
  final OrderStatus status;
  final dynamic data;
  final String? message;
  
  OrderResult.success(this.data) 
    : status = OrderStatus.success, message = null;
    
  OrderResult.error(this.message) 
    : status = OrderStatus.error, data = null;
    
  OrderResult.executedDespiteError(this.data) 
    : status = OrderStatus.executedDespiteError, 
      message = 'Order was executed despite network error';
      
  OrderResult.pending(this.message) 
    : status = OrderStatus.pending, data = null;
      
  OrderResult.safeToRetry() 
    : status = OrderStatus.safeToRetry, 
      data = null, 
      message = 'Order was not executed - safe to retry';
}

enum OrderStatus {
  success,
  error,
  executedDespiteError,
  pending,
  safeToRetry,
}
```

### UI Implementation

```dart
class OrderButton extends StatefulWidget {
  final Map<String, dynamic> orderParams;
  
  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;
  String? _statusMessage;
  
  Future<void> _submitOrder() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Submitting order...';
    });
    
    final handler = OrderErrorHandler(_client);
    final result = await handler.handleOrderSubmission(
      _client.executeOrder,
      widget.orderParams,
    );
    
    setState(() => _isLoading = false);
    
    switch (result.status) {
      case OrderStatus.success:
        _showSuccess('Order executed successfully');
        break;
        
      case OrderStatus.executedDespiteError:
        _showWarning(
          'Order was executed despite network error. '
          'Position opened successfully.'
        );
        break;
        
      case OrderStatus.pending:
        _showInfo('Order is pending confirmation. Please wait...');
        // Continuar verificando cada 2 segundos
        _startStatusPolling();
        break;
        
      case OrderStatus.safeToRetry:
        final shouldRetry = await _showRetryDialog();
        if (shouldRetry) {
          _submitOrder(); // Reintentar
        }
        break;
        
      case OrderStatus.error:
        _showError(result.message!);
        break;
    }
  }
  
  void _startStatusPolling() {
    Timer.periodic(Duration(seconds: 2), (timer) async {
      final positions = await _client.getPositions();
      if (positions.any((p) => /* matches order */)) {
        timer.cancel();
        _showSuccess('Order confirmed!');
      } else if (timer.tick > 15) {
        timer.cancel();
        _showError('Order confirmation timeout');
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : _submitOrder,
          child: _isLoading 
            ? CircularProgressIndicator()
            : Text('Submit Order'),
        ),
        if (_statusMessage != null)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(_statusMessage!),
          ),
      ],
    );
  }
}
```

### Tipos de Errores

| Error | Significado | Acción |
|-------|-------------|--------|
| `NETWORK_ERROR` | ⚠️ Timeout/conexión | **Verificar posiciones** antes de reintentar |
| `INSUFFICIENT_BALANCE` | Balance insuficiente | Mostrar error, NO reintentar |
| `INVALID_LEVERAGE` | Leverage inválido (1-100x) | Mostrar error, NO reintentar |
| `MARGIN_MODE_MISMATCH` | Modo de margen incorrecto | Mostrar error con instrucciones |
| `FUTURES_PERMISSION_REQUIRED` | Permisos de API | Mostrar error con link a KuCoin |

### Best Practices

1. **NUNCA reintentar inmediatamente** después de un network error
2. **SIEMPRE verificar posiciones** antes de reintentar
3. **Usar IDs únicos** para cada orden (el backend los genera)
4. **Mostrar estado de verificación** al usuario
5. **Implementar polling** para órdenes pendientes
6. **Timeout apropiado**: 3 segundos para verificación inicial

### Testing

```dart
// Test de network error
test('handles network error correctly', () async {
  // Mock network error
  when(mockClient.executeOrder(any))
    .thenThrow(Exception('NETWORK_ERROR'));
  
  // Mock positions (orden se ejecutó)
  when(mockClient.getPositions())
    .thenAnswer((_) async => [mockPosition]);
  
  final handler = OrderErrorHandler(mockClient);
  final result = await handler.handleOrderSubmission(
    mockClient.executeOrder,
    orderParams,
  );
  
  expect(result.status, OrderStatus.executedDespiteError);
  expect(result.data, isNotNull);
});
```

### Documentación Adicional

- **Order Reconciliation System**: `docs/hft-implementation/ORDER-RECONCILIATION.md`
- **HFT Integration**: `docs/hft-implementation/HFT-INTEGRATION-COMPLETE.md`

---

## Resources

1. **Full API Documentation:** `docs/API_DOCUMENTATION.md`
2. **API Gateway Guide:** `API-GATEWAY.md` ⭐ NEW
3. **Flutter Integration Guide:** `docs/FLUTTER_INTEGRATION_GUIDE.md`
4. **Risk Sentinel Guide:** `docs/RISK-SENTINEL-ENDPOINTS-FIXED.md` ⭐ NEW
5. **Flutter Team Response:** `docs/FLUTTER-TEAM-RESPONSE.md` ⭐ NEW
6. **Network Info Script:** `./scripts/show-network-info.sh`
7. **Backend Repository:** https://github.com/rantipay/trading-mcp
8. **Postman Collection:** Coming soon
9. **Swagger UI:** Coming soon

### Quick Commands

```bash
# Ver información de red completa
./scripts/show-network-info.sh

# Verificar gateway
curl http://192.168.100.145:9090/health

# Ver logs del servidor
tail -f logs/mcp-server-gateway.log | grep -i gateway
```

---

## Contact

**Backend Lead:** [Name]  
**Flutter Lead:** [Name]  
**Project Manager:** [Name]

**Last Updated:** 2025-11-16  
**Next Review:** 2025-11-23
