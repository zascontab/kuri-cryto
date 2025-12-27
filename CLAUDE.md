# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Kuri Crypto is a Flutter mobile application for cryptocurrency trading automation. It connects to a backend Trading MCP Server (localhost:8081) that provides advanced trading features including scalping strategies, risk management, position monitoring, and real-time WebSocket updates.

## Architecture

### State Management
- **Riverpod** is used throughout the app for state management and dependency injection
- Providers are code-generated using `riverpod_annotation` - run `flutter pub run build_runner build` after modifying provider files
- All providers are in `lib/providers/` with `.g.dart` generated counterparts
- Main providers:
  - `services_provider.dart` - HTTP client (Dio) and service instances (API, WebSocket, Position, Strategy, Risk)
  - `system_provider.dart` - System status and metrics
  - `position_provider.dart` - Active positions management
  - `strategy_provider.dart` - Trading strategies state
  - `risk_provider.dart` - Risk limits and sentinel state
  - `websocket_provider.dart` - WebSocket connection state

### Services Layer
All backend communication is handled through service classes in `lib/services/`:
- `api_client.dart` - Base HTTP client with Dio, automatic retry logic, error handling, and logging interceptors
- `websocket_service.dart` - WebSocket connection with auto-reconnect, heartbeat, event streams, and subscription management
- `scalping_service.dart` - System control (start/stop/status/metrics)
- `position_service.dart` - Position operations (list, close, update SL/TP, breakeven, trailing stop)
- `strategy_service.dart` - Strategy management (list, start/stop, config updates, performance)
- `risk_service.dart` - Risk limits and Risk Sentinel operations
- `api_exception.dart` - Custom exception hierarchy for API errors

### Models
Data models are in `lib/models/` with immutable classes using freezed/json_serializable patterns:
- `position.dart` - Trading position data
- `strategy.dart` - Strategy configuration and state
- `risk_state.dart` - Risk Sentinel state and drawdown tracking
- `metrics.dart` - Trading performance metrics
- `system_status.dart` - System health and status
- `trade.dart` - Executed trade records
- `websocket_event.dart` - WebSocket event types (Position, Trade, Metrics, Alert, KillSwitchEvent)

### Screens
Main screens in `lib/screens/`:
- `main_screen.dart` - Bottom navigation with PageView controller (Dashboard, Positions, Strategies, Risk, More)
- `dashboard_screen.dart` - Trading overview with metrics cards and system controls
- `positions_screen.dart` - Active positions list with management actions
- `strategies_screen.dart` - Strategy cards with start/stop controls
- `risk_screen.dart` - Risk Sentinel monitoring and kill switch

### Widgets
Reusable components in `lib/widgets/`:
- `custom_app_bar.dart` - AppBar with system status indicator
- `metric_card.dart` - Metric display cards
- `position_card.dart` - Position list item
- `strategy_card.dart` - Strategy configuration card
- `risk_sentinel_card.dart` - Risk monitoring widget

### Configuration
- `lib/config/api_config.dart` - API URLs, timeouts, retry policies, WebSocket config, caching, pagination

## Backend Integration

### REST API
Base URL: `http://localhost:8081/api/v1/scalping`

Available endpoints (see `API-SUMMARY-FOR-FLUTTER-TEAM.md` for complete details):
- System: `/status`, `/metrics`, `/health`, `/start`, `/stop`
- Positions: `/positions`, `/positions/history`, `/positions/:id/sltp`, `/positions/:id/breakeven`, `/positions/:id/trailing-stop`
- Strategies: `/strategies`, `/strategies/:name`, `/strategies/:name/start`, `/strategies/:name/stop`, `/strategies/:name/config`, `/strategies/:name/performance`
- Risk: `/risk/limits`, `/risk/exposure`, `/risk/sentinel/state`, `/risk/sentinel/kill-switch`
- Execution: `/execution/latency`, `/execution/history`
- Pairs: `/pairs/add`, `/pairs/remove`

### WebSocket
URL: `ws://localhost:8081/ws`

Event types:
- `position_update` - Position state changes
- `trade_executed` - New trade executions
- `metrics_update` - Performance metrics updates
- `alert` - System alerts
- `kill_switch` - Kill switch activation/deactivation

Connection features:
- Auto-reconnection with exponential backoff (1s → 30s max)
- Heartbeat ping every 30 seconds
- Automatic channel resubscription on reconnect
- Typed event streams via StreamControllers

## Development Commands

### Setup
```bash
# Get dependencies
flutter pub get

# Generate code (Riverpod providers, JSON serialization)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for continuous generation during development
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/models/position_test.dart
```

### Running
```bash
# Run on connected device/emulator
flutter run

# Run with specific device
flutter run -d <device-id>

# Run in release mode
flutter run --release
```

### Linting & Analysis
```bash
# Analyze code
flutter analyze

# Format code
flutter format .
```

### Building
```bash
# Build APK (Android)
flutter build apk

# Build App Bundle (Android)
flutter build appbundle

# Build iOS
flutter build ios
```

## Key Dependencies

- **flutter_riverpod** ^2.4.9 - State management
- **dio** ^5.4.0 - HTTP client with interceptors
- **web_socket_channel** ^2.4.0 - WebSocket communication
- **hive** ^2.2.3 / **hive_flutter** ^1.1.0 - Local storage (configured but adapters not yet registered)
- **flutter_secure_storage** ^9.0.0 - Secure credential storage
- **fl_chart** ^0.65.0 - Chart visualizations
- **logger** ^2.0.2+1 - Structured logging
- **intl** ^0.18.1 - Internationalization and formatting

## Important Patterns

### Error Handling
- All API errors are converted to typed `ApiException` subclasses in `api_client.dart`
- Trading-specific errors: `InsufficientBalanceException`, `RiskLimitExceededException`, `KillSwitchActiveException`, `PositionNotFoundException`, `StrategyNotFoundException`, `OrderExecutionException`
- HTTP errors: `UnauthorizedException`, `ForbiddenException`, `NotFoundException`, `RateLimitException`
- Retry logic is automatic for 5xx errors (max 3 retries with exponential backoff)

### WebSocket Reconnection
- Connection state tracked via `WebSocketConnectionState` enum (disconnected, connecting, connected, error)
- Auto-reconnect on error/disconnect with exponential backoff
- Subscribed channels are preserved and automatically resubscribed after reconnection
- Use `websocketService.connectionStateStream` to monitor connection status in UI

### Provider Usage
```dart
// Reading in build method
final systemStatus = ref.watch(systemStatusProvider);

// Reading once (e.g., in event handlers)
final positionService = ref.read(positionServiceProvider);

// Watching specific field
final isRunning = ref.watch(systemStatusProvider.select((s) => s.value?.running));
```

### Adding New Models
1. Create immutable model class with `fromJson`/`toJson`
2. Add tests in `test/models/`
3. Update `lib/models/models.dart` if needed for barrel exports
4. Regenerate code if using codegen

### Adding New API Endpoints
1. Add method to appropriate service class (e.g., `position_service.dart`)
2. Use `ApiClient` methods: `get()`, `post()`, `put()`, `delete()`, `patch()`
3. Handle errors with try-catch and throw `ApiException`
4. Add provider in `services_provider.dart` if creating new service
5. Update this document with new endpoint information

## Backend Development Roadmap

The backend is being developed in phases (see `API-SUMMARY-FOR-FLUTTER-TEAM.md`):
- **Phase 0** (Week 1-2): Risk Sentinel, Position Manager, Auto SL/TP - CURRENT
- **Phase 1** (Week 3-4): Multi-timeframe analysis, Backtesting
- **Phase 2** (Week 5-6): HFT optimization, Performance tracking
- **Phase 3** (Week 7-8): Multi-pair support, Alerts, Production features

When backend adds new endpoints, update service classes and providers accordingly.

## Configuration Notes

- API base URL configured in `lib/config/api_config.dart` and `lib/providers/services_provider.dart` (currently localhost:8081)
- Timeouts: 10s connect, 30s receive/send
- Retry policy: 3 attempts with 2x exponential backoff
- WebSocket heartbeat: 30s interval
- Logging enabled in development via `ApiConfig.enableLogging`

## TODO Items in Code

Several areas marked with TODO comments for future implementation:
- Hive adapter registration in `main.dart`
- Authentication flow (login/register screens)
- Named route configuration
- User profile management
- Settings screen implementation
- Alert history and notifications

## Testing Strategy

- Unit tests for all models with sample JSON data
- Models tested: Position, Strategy, RiskState, Metrics, SystemStatus, Trade
- Mock server capability mentioned in API docs but not yet implemented
- Test coverage available via `flutter test --coverage`
