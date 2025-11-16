# API Summary for Flutter Team

**Date:** 2025-11-16  
**Project:** Trading MCP Server - Advanced Functions  
**Target:** Flutter Mobile App Development

---

## Executive Summary

El backend está desarrollando funciones avanzadas de trading en **4 fases** durante las próximas **6-8 semanas**. Este documento resume los endpoints disponibles y los que se agregarán para que el equipo de Flutter pueda comenzar el desarrollo en paralelo.

---

## Current Status (Available Now)

### ✅ REST API Base URL
```
http://localhost:8081/api/v1/scalping
```

### ✅ WebSocket URL
```
ws://localhost:8081/ws
```

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
Connect to local backend:
```
http://localhost:8081
```

### 3. Staging Server (Week 3)
Connect to staging environment:
```
https://staging-api.trading-mcp.com
```

### 4. Production (Week 8)
Production deployment

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
- [ ] Read `FLUTTER_INTEGRATION_GUIDE.md`
- [ ] Setup Flutter project with recommended packages
- [ ] Implement API client with Dio
- [ ] Create mock data for testing
- [ ] Implement Dashboard screen
- [ ] Implement Positions screen
- [ ] Implement Strategies screen
- [ ] Setup WebSocket connection
- [ ] Test with local backend
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

## Resources

1. **Full API Documentation:** `docs/API_DOCUMENTATION.md`
2. **Flutter Integration Guide:** `docs/FLUTTER_INTEGRATION_GUIDE.md`
3. **Backend Repository:** https://github.com/rantipay/trading-mcp
4. **Postman Collection:** Coming soon
5. **Swagger UI:** Coming soon

---

## Contact

**Backend Lead:** [Name]  
**Flutter Lead:** [Name]  
**Project Manager:** [Name]

**Last Updated:** 2025-11-16  
**Next Review:** 2025-11-23
