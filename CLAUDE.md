# CLAUDE.md - AI Assistant Guide

**Project**: Kuri Crypto Trading App
**Version**: 1.0.0
**Last Updated**: 2025-11-16
**Purpose**: Documentation for AI assistants (Claude, GPT, etc.) to understand and work effectively with this codebase

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Repository Structure](#repository-structure)
3. [Technology Stack](#technology-stack)
4. [Architecture](#architecture)
5. [Development Workflow](#development-workflow)
6. [API Documentation](#api-documentation)
7. [Coding Conventions](#coding-conventions)
8. [Key Concepts](#key-concepts)
9. [Testing Strategy](#testing-strategy)
10. [Common Tasks](#common-tasks)
11. [Troubleshooting](#troubleshooting)

---

## Project Overview

### What is Kuri Crypto?

Kuri Crypto is a **cross-platform mobile application** (Flutter) for **cryptocurrency trading** with a focus on:
- **High-Frequency Scalping**: Trading with positions lasting minutes
- **Automated Strategies**: 5 AI/indicator-based strategies running simultaneously
- **Risk Management**: Built-in Risk Sentinel with kill switch and automatic safety controls
- **Real-Time Monitoring**: WebSocket-based live updates for positions and metrics

### Key Differentiators

1. **Safety-First**: Risk Sentinel monitors drawdown, exposure, and consecutive losses with automatic kill switch
2. **HFT Optimized**: Sub-100ms latency for trade execution
3. **Multi-Strategy**: RSI, MACD, Bollinger Bands, Volume, and AI strategies running in parallel
4. **Auto SL/TP**: Automatic stop-loss and take-profit management with trailing stops
5. **Mobile-Native**: Built for traders on the go with offline-first architecture

### Target Platforms

- Android 8.0+ (API 26)
- iOS 12.0+
- (Future: Web, Desktop)

---

## Repository Structure

### Current State

```
kuri-cryto/
├── .git/                          # Git version control
├── .gitignore                     # Git ignore rules (Flutter-focused)
├── README.md                      # Project introduction
├── CLAUDE.md                      # This file - AI assistant guide
├── srs.md                         # Software Requirements Specification (IEEE 830-1998)
├── API-DOCUMENTATION.md           # Complete REST API + MCP Tools documentation
├── API-SUMMARY-FOR-FLUTTER-TEAM.md # Quick reference for Flutter developers
└── (Flutter app code - to be created)
```

### Expected Flutter Structure (To Be Created)

```
lib/
├── config/                        # Configuration files
│   ├── api_config.dart           # API endpoints, timeouts
│   ├── app_config.dart           # App-wide constants
│   └── theme_config.dart         # Material Design 3 theme
├── models/                        # Data models
│   ├── position.dart             # Position model
│   ├── strategy.dart             # Strategy model
│   ├── risk_state.dart           # Risk Sentinel state
│   ├── metrics.dart              # Trading metrics
│   └── alert.dart                # Alert model
├── services/                      # API services
│   ├── api_client.dart           # Dio HTTP client
│   ├── websocket_service.dart    # WebSocket manager
│   ├── scalping_service.dart     # Scalping engine API
│   ├── position_service.dart     # Position management API
│   ├── strategy_service.dart     # Strategy management API
│   └── risk_service.dart         # Risk management API
├── providers/                     # Riverpod providers
│   ├── system_provider.dart      # System status state
│   ├── position_provider.dart    # Position state
│   ├── strategy_provider.dart    # Strategy state
│   └── risk_provider.dart        # Risk state
├── screens/                       # Main screens
│   ├── dashboard_screen.dart     # Home dashboard
│   ├── positions_screen.dart     # Positions list
│   ├── strategies_screen.dart    # Strategies management
│   ├── risk_screen.dart          # Risk monitor
│   └── settings_screen.dart      # App settings
├── widgets/                       # Reusable widgets
│   ├── position_card.dart        # Position display card
│   ├── strategy_card.dart        # Strategy display card
│   ├── metrics_dashboard.dart    # Metrics grid
│   ├── risk_monitor.dart         # Risk sentinel widget
│   └── kill_switch_button.dart   # Emergency stop button
└── utils/                         # Utilities and helpers
    ├── formatters.dart           # Number, date formatters
    ├── validators.dart           # Input validators
    └── constants.dart            # App constants
```

---

## Technology Stack

### Frontend (Flutter)

| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| Framework | Flutter | 3.0+ | Cross-platform UI |
| Language | Dart | 3.0+ | Programming language |
| State Management | Riverpod | 2.4+ | Reactive state management |
| HTTP Client | Dio | 5.4+ | REST API communication |
| WebSocket | web_socket_channel | 2.4+ | Real-time updates |
| Local Storage | Hive | 2.2+ | Offline data caching |
| Secure Storage | flutter_secure_storage | 9.0+ | JWT tokens, credentials |
| Charts | fl_chart | 0.65+ | Technical analysis charts |
| Charts (Advanced) | syncfusion_flutter_charts | 24.1+ | Performance charts |
| UI Components | flutter_slidable | 3.0+ | Swipe actions |
| Loading States | shimmer | 3.0+ | Skeleton loaders |
| Internationalization | intl | 0.18+ | Number/date formatting |
| Time Formatting | timeago | 3.6+ | Relative time display |

### Backend (Trading MCP Server)

| Component | Technology | Port | Purpose |
|-----------|-----------|------|---------|
| Server | Go 1.21+ | 8081 | Trading engine |
| Exchange Connector | GoCryptoTrader | 9052 | Multi-exchange support |
| Exchange | KuCoin | - | SPOT + Futures trading |
| Protocol (AI) | MCP (Model Context Protocol) | stdio | AI agent integration |
| Protocol (App) | REST + WebSocket | 8081 | Mobile app integration |

---

## Architecture

### System Architecture

```
┌─────────────────────────────────────────────────────┐
│                 Flutter Mobile App                   │
│  (Android / iOS)                                     │
│                                                       │
│  ┌──────────────────────────────────────────────┐  │
│  │  Presentation Layer                           │  │
│  │  • Screens (Riverpod ConsumerWidget)         │  │
│  │  • Widgets (Reusable components)             │  │
│  └──────────────────────────────────────────────┘  │
│                       ↓                              │
│  ┌──────────────────────────────────────────────┐  │
│  │  State Management (Riverpod)                  │  │
│  │  • Providers (StateNotifierProvider)         │  │
│  │  • State classes (StateNotifier)             │  │
│  └──────────────────────────────────────────────┘  │
│                       ↓                              │
│  ┌──────────────────────────────────────────────┐  │
│  │  Data Layer                                   │  │
│  │  • Services (API abstraction)                │  │
│  │  • Models (Data classes)                     │  │
│  │  • Local Storage (Hive)                      │  │
│  └──────────────────────────────────────────────┘  │
└─────────────────────┬───────────────────────────────┘
                       │
                       ↓ REST API (HTTP) + WebSocket
┌─────────────────────────────────────────────────────┐
│        Trading MCP Server (Go Backend)               │
│        http://localhost:8081                         │
│                                                       │
│  ┌──────────────────────────────────────────────┐  │
│  │  Scalping Engine                              │  │
│  │  • 5 Strategies (RSI, MACD, Bollinger, etc.) │  │
│  │  • Signal Generation                         │  │
│  │  • Order Execution                           │  │
│  └──────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────┐  │
│  │  Risk Sentinel                                │  │
│  │  • Drawdown monitoring                       │  │
│  │  • Exposure limits                           │  │
│  │  • Kill switch                               │  │
│  └──────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────┐  │
│  │  Position Manager                             │  │
│  │  • SL/TP automation                          │  │
│  │  • Trailing stops                            │  │
│  │  • Conflict detection                        │  │
│  └──────────────────────────────────────────────┘  │
└─────────────────────┬───────────────────────────────┘
                       │
                       ↓ gRPC
┌─────────────────────────────────────────────────────┐
│          GoCryptoTrader (GCT)                        │
│          Port 9052                                   │
└─────────────────────┬───────────────────────────────┘
                       │
                       ↓ REST API + WebSocket
┌─────────────────────────────────────────────────────┐
│          KuCoin Exchange                             │
│          • SPOT Trading                              │
│          • Futures Trading                           │
└─────────────────────────────────────────────────────┘
```

### Data Flow

#### REST API Flow (Queries)
```
User Action → Widget → Provider → Service → Dio → Backend → Database
                  ↓
           UI Update ← State Change ← Response
```

#### WebSocket Flow (Real-time Updates)
```
Backend Event → WebSocket Service → Provider → Widget → UI Update
     ↑                                            ↓
Exchange API                              User sees update (<1s)
```

### State Management Pattern

This app uses **Riverpod** with the following pattern:

```dart
// 1. State class
class PositionsState {
  final List<Position> positions;
  final bool isLoading;
  final String? error;
}

// 2. StateNotifier
class PositionsNotifier extends StateNotifier<PositionsState> {
  final PositionService _service;

  Future<void> fetchPositions() async {
    state = state.copyWith(isLoading: true);
    final positions = await _service.getPositions();
    state = state.copyWith(positions: positions, isLoading: false);
  }
}

// 3. Provider
final positionsProvider = StateNotifierProvider<PositionsNotifier, PositionsState>((ref) {
  return PositionsNotifier(ref.read(positionServiceProvider));
});

// 4. Widget consumption
class PositionsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(positionsProvider);
    // Use state.positions, state.isLoading, etc.
  }
}
```

---

## Development Workflow

### Phase-Based Development (8 Weeks)

#### Phase 0: Critical Safety (Week 1-2) - **CURRENT PRIORITY**
**Status**: Starting Now
**Focus**: Risk management and position safety

**Tasks**:
- [ ] Setup Flutter project with dependencies
- [ ] Implement API client with Dio
- [ ] Create WebSocket service
- [ ] Build Dashboard screen
- [ ] Build Positions screen
- [ ] Build Strategies screen
- [ ] **NEW**: Risk Monitor widget
- [ ] **NEW**: Kill Switch button
- [ ] **NEW**: Edit SL/TP dialog
- [ ] **NEW**: Move to breakeven action
- [ ] **NEW**: Trailing stop toggle

**Backend Endpoints (NEW)**:
- `GET /api/v1/risk/sentinel/state` - Risk Sentinel state
- `POST /api/v1/risk/sentinel/kill-switch` - Activate kill switch
- `DELETE /api/v1/risk/sentinel/kill-switch` - Deactivate kill switch
- `PUT /api/v1/positions/:id/sltp` - Update SL/TP
- `POST /api/v1/positions/:id/breakeven` - Move to breakeven
- `POST /api/v1/positions/:id/trailing-stop` - Enable trailing stop

#### Phase 1: Scalping Foundation (Week 3-4)
**Focus**: Multi-timeframe analysis and backtesting

**Tasks**:
- [ ] Multi-timeframe chart widget
- [ ] Backtest configuration screen
- [ ] Backtest results visualization
- [ ] Signal consensus display

#### Phase 2: HFT Optimization (Week 5-6)
**Focus**: Execution performance and monitoring

**Tasks**:
- [ ] Execution performance charts
- [ ] Latency monitoring widget
- [ ] Metrics export functionality

#### Phase 3: Scaling & Production (Week 7-8)
**Focus**: Alerts, optimization, and production features

**Tasks**:
- [ ] Correlation heatmap
- [ ] Parameter optimization screen
- [ ] Alert configuration
- [ ] Push notifications (Telegram)

### Git Workflow

**Current Branch**: `claude/claude-md-mi1e2mm9bbtrdcd8-01Rho2X5qQD8EvSCsBPahyco`

**Branch Naming**:
- `main` - Production-ready code
- `develop` - Development integration branch
- `feature/[feature-name]` - New features
- `fix/[bug-name]` - Bug fixes
- `claude/[session-id]` - AI assistant work branches

**Commit Message Convention**:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Example**:
```
feat(risk): add kill switch button to dashboard

- Added prominent red kill switch button
- Implemented confirmation dialog
- Added haptic feedback on activation
- Connected to /api/v1/risk/sentinel/kill-switch endpoint

Closes #123
```

---

## API Documentation

### Base URLs

**REST API**: `http://localhost:8081/api/v1/scalping`
**WebSocket**: `ws://localhost:8081/ws`

### Authentication

**Current**: No authentication (development mode)
**Planned** (Phase 3): JWT tokens with Bearer authentication

### Key Endpoints

#### System Control
```
GET  /status                    - System status
GET  /metrics                   - Trading metrics
GET  /health                    - Health check
POST /start                     - Start scalping engine
POST /stop                      - Stop scalping engine
```

#### Positions
```
GET  /positions                 - Open positions
GET  /positions/history         - Position history
POST /positions/:id/close       - Close position
PUT  /positions/:id/sltp        - Update SL/TP (Phase 0)
POST /positions/:id/breakeven   - Move to breakeven (Phase 0)
POST /positions/:id/trailing-stop - Enable trailing stop (Phase 0)
```

#### Strategies
```
GET  /strategies                - All strategies
GET  /strategies/:name          - Strategy details
POST /strategies/:name/start    - Start strategy
POST /strategies/:name/stop     - Stop strategy
PUT  /strategies/:name/config   - Update configuration
GET  /strategies/:name/performance - Performance metrics
```

#### Risk Management
```
GET  /risk/limits               - Risk limits
PUT  /risk/limits               - Update limits
GET  /risk/exposure             - Current exposure
GET  /risk/sentinel/state       - Risk Sentinel state (Phase 0)
POST /risk/sentinel/kill-switch - Activate kill switch (Phase 0)
DELETE /risk/sentinel/kill-switch - Deactivate kill switch (Phase 0)
```

#### Execution
```
GET  /execution/latency         - Latency statistics
GET  /execution/history         - Execution history
```

### WebSocket Events

Subscribe to channels:
```json
{
  "action": "subscribe",
  "channels": ["positions", "trades", "metrics", "alerts"]
}
```

Receive events:
```json
{
  "type": "position_update",
  "data": { /* position data */ },
  "timestamp": "2025-11-16T10:30:00Z"
}
```

Event types:
- `position_update` - Position price/PnL update
- `trade_executed` - Order filled
- `metrics_update` - System metrics update
- `alert` - Alert triggered
- `kill_switch` - Kill switch activated/deactivated

### Error Handling

All responses follow:
```json
{
  "success": true/false,
  "data": { /* response data */ },
  "error": "Error message",
  "code": "ERROR_CODE"
}
```

Common error codes:
- `RISK_LIMIT_EXCEEDED` - Risk limit breached
- `KILL_SWITCH_ACTIVE` - Trading disabled
- `INSUFFICIENT_BALANCE` - Not enough funds
- `POSITION_NOT_FOUND` - Position doesn't exist

**Full API Reference**: See `API-DOCUMENTATION.md`

---

## Coding Conventions

### Dart/Flutter Style

#### File Naming
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables**: `camelCase`
- **Constants**: `UPPER_SNAKE_CASE`
- **Private**: `_leadingUnderscore`

#### Examples
```dart
// File: position_service.dart
class PositionService {
  static const int MAX_RETRY_ATTEMPTS = 3;
  final Dio _client;

  Future<List<Position>> getPositions() async { }
}
```

#### Widget Structure
```dart
class PositionCard extends StatelessWidget {
  final Position position;
  final VoidCallback? onTap;

  const PositionCard({
    Key? key,
    required this.position,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(position.symbol),
        subtitle: Text('\$${position.unrealizedPnl.toStringAsFixed(2)}'),
        onTap: onTap,
      ),
    );
  }
}
```

#### Riverpod Provider Naming
```dart
// Service provider
final positionServiceProvider = Provider<PositionService>((ref) {
  return PositionService(ref.read(dioProvider));
});

// State provider
final positionsProvider = StateNotifierProvider<PositionsNotifier, PositionsState>((ref) {
  return PositionsNotifier(ref.read(positionServiceProvider));
});

// Future provider
final positionsFutureProvider = FutureProvider<List<Position>>((ref) {
  return ref.read(positionServiceProvider).getPositions();
});

// Stream provider
final positionsStreamProvider = StreamProvider<List<Position>>((ref) {
  return ref.read(websocketServiceProvider).positionsStream;
});
```

### Code Organization

#### Model Classes
```dart
// Use freezed for immutable data classes
@freezed
class Position with _$Position {
  const factory Position({
    required String id,
    required String symbol,
    required String side,
    required double entryPrice,
    required double currentPrice,
    required double size,
    required double leverage,
    required double stopLoss,
    required double takeProfit,
    required double unrealizedPnl,
    required DateTime openTime,
    required String strategy,
    required String status,
  }) = _Position;

  factory Position.fromJson(Map<String, dynamic> json) => _$PositionFromJson(json);
}
```

#### Service Classes
```dart
class PositionService {
  final Dio _client;
  static const String _basePath = '/api/v1/scalping';

  PositionService(this._client);

  Future<List<Position>> getPositions() async {
    try {
      final response = await _client.get('$_basePath/positions');
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => Position.fromJson(json))
            .toList();
      }
      throw ApiException(response.data['error']);
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioError error) {
    // Error handling logic
  }
}
```

### UI/UX Conventions

#### Material Design 3
- **Theme**: Follow Material Design 3 guidelines
- **Colors**:
  - Profit: `#4CAF50` (Green 500)
  - Loss: `#F44336` (Red 500)
  - Neutral: `#2196F3` (Blue 500)
  - Warning: `#FF9800` (Orange 500)
  - Critical: `#D32F2F` (Red 700)

#### Button Sizes
- Minimum tap target: 48x48 dp
- Icon buttons: 48x48 dp
- FAB: 56x56 dp
- Extended FAB: 48 dp height

#### Spacing
- Extra small: 4 dp
- Small: 8 dp
- Medium: 16 dp
- Large: 24 dp
- Extra large: 32 dp

#### Typography
- Display Large: 57 sp
- Headline Large: 32 sp
- Title Large: 22 sp
- Body Large: 16 sp
- Label Large: 14 sp
- Body Small: 12 sp

---

## Key Concepts

### Trading Concepts

#### Scalping
**Definition**: High-frequency trading strategy with positions lasting minutes
**Goal**: Capture small price movements repeatedly
**Characteristics**:
- High trade frequency (10-50 trades/day)
- Small profit targets (0.5-1.5% per trade)
- Tight stop losses (0.3-0.5%)
- Low latency requirements (<100ms)

#### Position Types
- **LONG**: Buy low, sell high (profit when price increases)
- **SHORT**: Sell high, buy low (profit when price decreases)

#### Risk Management
- **Stop Loss (SL)**: Exit price to limit losses
- **Take Profit (TP)**: Exit price to lock in profits
- **Trailing Stop**: SL that follows price movement
- **Breakeven**: Moving SL to entry price (zero-loss position)
- **Kill Switch**: Emergency stop for all trading

#### Leverage
**Definition**: Borrowed capital to increase position size
**Example**: 2x leverage with $100 = $200 position
**Risk**: Amplifies both gains AND losses

### Technical Indicators

#### RSI (Relative Strength Index)
- **Range**: 0-100
- **Oversold**: < 30 (potential buy signal)
- **Overbought**: > 70 (potential sell signal)
- **Period**: Typically 14 candles

#### MACD (Moving Average Convergence Divergence)
- **Components**: MACD line, Signal line, Histogram
- **Signal**: MACD crosses above signal = bullish
- **Signal**: MACD crosses below signal = bearish

#### Bollinger Bands
- **Components**: Upper band, Middle (SMA), Lower band
- **Signal**: Price at lower band = potential buy
- **Signal**: Price at upper band = potential sell

### System Concepts

#### Risk Sentinel
**Purpose**: Monitor and enforce risk limits
**Monitors**:
- Daily/weekly/monthly drawdown
- Total exposure
- Per-symbol exposure
- Consecutive losses
- Position conflicts

**Actions**:
- Automatic kill switch activation
- Position size reduction
- Strategy disabling
- Alert generation

#### Risk Modes
- **Conservative**: Lowest risk, smallest positions
- **Normal**: Balanced risk/reward
- **Aggressive**: Higher risk, larger positions
- **ControlledCrazy**: Maximum risk (use with caution)

#### Kill Switch
**Purpose**: Emergency stop for all trading
**Triggers**:
- Manual activation by user
- Drawdown limit exceeded
- Exposure limit exceeded
- Consecutive loss limit reached

**Actions**:
- Stop all strategies immediately
- Close all open positions (market orders)
- Disable new position opening
- Require manual deactivation

---

## Testing Strategy

### Unit Tests
**Coverage Goal**: 80% minimum

**What to test**:
- Model serialization/deserialization
- Service API calls (mocked)
- State management logic
- Utility functions
- Validators

**Example**:
```dart
test('Position.fromJson creates Position correctly', () {
  final json = {
    'id': 'pos_123',
    'symbol': 'BTC-USDT',
    'side': 'long',
    // ... other fields
  };

  final position = Position.fromJson(json);

  expect(position.id, 'pos_123');
  expect(position.symbol, 'BTC-USDT');
  expect(position.side, 'long');
});
```

### Widget Tests
**What to test**:
- Widget rendering
- User interactions
- State updates
- Navigation

**Example**:
```dart
testWidgets('PositionCard displays position data', (tester) async {
  final position = Position(/* ... */);

  await tester.pumpWidget(
    MaterialApp(home: PositionCard(position: position)),
  );

  expect(find.text('BTC-USDT'), findsOneWidget);
  expect(find.text('\$15.00'), findsOneWidget);
});
```

### Integration Tests
**What to test**:
- End-to-end user flows
- API integration (with mock server)
- WebSocket connection
- Navigation between screens

### Mock Data Strategy

**Phase 1**: Use mock API client
```dart
class MockApiClient implements ApiClient {
  @override
  Future<List<Position>> getPositions() async {
    await Future.delayed(Duration(seconds: 1));
    return [
      Position(id: 'pos_1', /* ... */),
      Position(id: 'pos_2', /* ... */),
    ];
  }
}
```

**Phase 2**: Connect to local backend (http://localhost:8081)

**Phase 3**: Use staging environment

**Phase 4**: Production

---

## Common Tasks

### Task 1: Adding a New Screen

1. **Create screen file**: `lib/screens/my_screen.dart`
2. **Define state model**: In `lib/models/` if needed
3. **Create service**: In `lib/services/` if new API needed
4. **Create provider**: In `lib/providers/`
5. **Implement UI**: Use ConsumerWidget
6. **Add navigation**: In main navigation

**Example**:
```dart
// lib/screens/my_screen.dart
class MyScreen extends ConsumerWidget {
  static const routeName = '/my-screen';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myProvider);

    return Scaffold(
      appBar: AppBar(title: Text('My Screen')),
      body: /* ... */,
    );
  }
}
```

### Task 2: Adding a New API Endpoint

1. **Document endpoint** in API-DOCUMENTATION.md
2. **Create/update model**: In `lib/models/`
3. **Add method to service**: In `lib/services/`
4. **Update provider**: In `lib/providers/`
5. **Update UI**: In relevant screen/widget

**Example**:
```dart
// lib/services/position_service.dart
Future<void> moveToBreakeven(String positionId) async {
  try {
    final response = await _client.post(
      '/api/v1/positions/$positionId/breakeven',
    );
    if (response.data['success'] != true) {
      throw ApiException(response.data['error']);
    }
  } on DioError catch (e) {
    throw _handleError(e);
  }
}
```

### Task 3: Adding WebSocket Support for New Event

1. **Update WebSocket service**: Add event handler
2. **Update provider**: Listen to new stream
3. **Update UI**: React to state changes

**Example**:
```dart
// lib/services/websocket_service.dart
void _handleMessage(dynamic message) {
  final data = jsonDecode(message);

  switch (data['type']) {
    case 'new_event':
      _newEventController.add(NewEvent.fromJson(data['data']));
      break;
    // ... other cases
  }
}
```

### Task 4: Adding a New Strategy to UI

1. **Verify backend support**: Check API-DOCUMENTATION.md
2. **Update Strategy model**: Add new strategy name constant
3. **Update Strategy service**: No changes needed (generic)
4. **Update UI**: Strategy will appear automatically in list
5. **Add strategy-specific config**: If needed, create custom config form

### Task 5: Implementing Offline Support

1. **Define what should work offline**:
   - ✅ View cached positions
   - ✅ View cached metrics
   - ✅ View cached strategy performance
   - ❌ Execute trades
   - ❌ Modify positions

2. **Use Hive for caching**:
```dart
// Cache positions
await Hive.box('positions').put('list', positions.map((p) => p.toJson()).toList());

// Retrieve cached positions
final cached = Hive.box('positions').get('list', defaultValue: []);
```

3. **Handle connectivity**:
```dart
final connectivity = ref.watch(connectivityProvider);
if (connectivity.isOffline) {
  // Load from cache
} else {
  // Fetch from API
}
```

---

## Troubleshooting

### Common Issues

#### Issue 1: API Connection Failed
**Symptoms**: `DioError: Connection refused`
**Causes**:
- Backend not running
- Wrong port (should be 8081)
- Firewall blocking connection

**Solutions**:
1. Check backend is running: `curl http://localhost:8081/api/v1/scalping/status`
2. Verify port in `lib/config/api_config.dart`
3. Check firewall settings
4. Use correct IP (not 127.0.0.1 on Android emulator, use 10.0.2.2)

#### Issue 2: WebSocket Disconnecting
**Symptoms**: WebSocket connects then immediately disconnects
**Causes**:
- Backend WebSocket not enabled
- Network instability
- No ping/pong heartbeat

**Solutions**:
1. Check backend WebSocket endpoint: `ws://localhost:8081/ws`
2. Implement heartbeat:
```dart
Timer.periodic(Duration(seconds: 30), (_) {
  if (_channel != null) {
    _channel!.sink.add(jsonEncode({'action': 'ping'}));
  }
});
```
3. Add reconnection logic with exponential backoff

#### Issue 3: Positions Not Updating
**Symptoms**: Position list shows stale data
**Causes**:
- WebSocket not connected
- Provider not listening to stream
- UI not rebuilding

**Solutions**:
1. Check WebSocket connection status
2. Verify provider setup:
```dart
ref.listen(websocketServiceProvider, (previous, next) {
  // Handle WebSocket events
});
```
3. Ensure widget is using `ref.watch()` not `ref.read()`

#### Issue 4: Kill Switch Not Working
**Symptoms**: Kill switch button doesn't stop trading
**Causes**:
- API endpoint not implemented in backend
- Request failing silently
- Backend not respecting kill switch

**Solutions**:
1. Check backend supports endpoint (Phase 0 feature)
2. Add error logging:
```dart
try {
  await _riskService.activateKillSwitch();
} catch (e) {
  print('Kill switch error: $e');
  // Show error to user
}
```
3. Verify backend logs for kill switch activation

#### Issue 5: High Memory Usage
**Symptoms**: App crashes or slows down after running
**Causes**:
- WebSocket events not disposed
- Large lists not paginated
- Images/charts not released

**Solutions**:
1. Dispose controllers:
```dart
@override
void dispose() {
  _controller.dispose();
  _subscription.cancel();
  super.dispose();
}
```
2. Limit list size:
```dart
final recentPositions = allPositions.take(100).toList();
```
3. Use `AutoDisposeStateNotifierProvider` for auto cleanup

---

## AI Assistant Instructions

### When Working on This Codebase

#### DO:
- ✅ Read `srs.md` for full requirements
- ✅ Check `API-DOCUMENTATION.md` for endpoint details
- ✅ Follow the phase-based development plan
- ✅ Use Riverpod for state management
- ✅ Write tests for new features
- ✅ Use Material Design 3 components
- ✅ Handle errors gracefully with user-friendly messages
- ✅ Implement offline-first where appropriate
- ✅ Add loading states and shimmer effects
- ✅ Follow Dart style guide and conventions
- ✅ Document complex business logic
- ✅ Ask for clarification on ambiguous requirements

#### DON'T:
- ❌ Skip error handling
- ❌ Hardcode API endpoints (use config)
- ❌ Bypass risk validations
- ❌ Create new state management patterns (use Riverpod)
- ❌ Ignore WebSocket disconnections
- ❌ Store sensitive data in plain text
- ❌ Skip input validation
- ❌ Create tightly-coupled components
- ❌ Ignore accessibility guidelines
- ❌ Commit secrets or API keys

### Recommended Development Order

**Week 1**:
1. Setup Flutter project with dependencies
2. Create folder structure
3. Setup API client and WebSocket service
4. Create basic models (Position, Strategy, Metrics)
5. Implement Dashboard screen (read-only)

**Week 2**:
1. Implement Positions screen with WebSocket updates
2. Implement Strategies screen with toggle controls
3. **Add Risk Monitor widget (Phase 0)**
4. **Add Kill Switch button (Phase 0)**
5. Basic error handling and offline support

**Week 3-4**:
1. Multi-timeframe analysis (Phase 1)
2. Backtesting UI (Phase 1)
3. Advanced charts and indicators

**Week 5-6**:
1. Execution performance monitoring (Phase 2)
2. Advanced metrics and exports

**Week 7-8**:
1. Alerts and notifications (Phase 3)
2. Parameter optimization UI (Phase 3)
3. Production polish

### Testing Checklist

Before submitting code:
- [ ] All unit tests pass
- [ ] Widget tests cover new UI
- [ ] Manual testing on Android
- [ ] Manual testing on iOS
- [ ] Offline mode tested
- [ ] Error scenarios tested
- [ ] WebSocket reconnection tested
- [ ] Kill switch tested (Phase 0+)
- [ ] No console errors
- [ ] No memory leaks
- [ ] Performance profiled (60fps)

---

## Resources

### Internal Documentation
- `srs.md` - Software Requirements Specification (IEEE 830-1998)
- `API-DOCUMENTATION.md` - Complete REST API + MCP Tools reference
- `API-SUMMARY-FOR-FLUTTER-TEAM.md` - Quick API summary for Flutter devs

### External Resources
- [Flutter Documentation](https://docs.flutter.dev)
- [Riverpod Documentation](https://riverpod.dev)
- [Dio Documentation](https://pub.dev/packages/dio)
- [Material Design 3](https://m3.material.io)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)

### Backend
- Trading MCP Server Repository: https://github.com/rantipay/trading-mcp
- GoCryptoTrader: https://github.com/thrasher-corp/gocryptotrader
- KuCoin API: https://docs.kucoin.com

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-11-16 | Initial CLAUDE.md creation |

---

## Contact & Support

**Backend Team**: See `API-SUMMARY-FOR-FLUTTER-TEAM.md` for contact info
**Slack Channels**:
- `#trading-api-updates` - API changes and announcements
- `#flutter-backend-support` - Questions and help

**Daily Standup**: 10:00 AM (15 minutes)

---

**Last Updated**: 2025-11-16
**Maintained By**: Development Team
**Next Review**: 2025-11-23
