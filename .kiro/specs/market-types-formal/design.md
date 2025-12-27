# Design Document - Market Types System

## Overview

The Market Types System is a comprehensive solution for managing different trading instruments within a unified Flutter application. It provides a type-safe enum-based architecture, multiple UI components, state management with Riverpod, and seamless backend integration.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     UI Layer                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Demo Screen  │  │ Config Screen│  │ Trading Hub  │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────────────────────────────────────┐
│                  Widget Layer                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │SegmentedBtn  │  │ FilterChips  │  │  Dropdown    │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────────────────────────────────────┐
│                 Provider Layer                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Market Type  │  │  Leverage    │  │   Selected   │  │
│  │  Provider    │  │  Provider    │  │   Provider   │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────────────────────────────────────┐
│                  Service Layer                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Market Type  │  │  AI Bot      │  │   Futures    │  │
│  │  Service     │  │  Service     │  │   Service    │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────────────────────────────────────┐
│                   Backend API                            │
│         (Receives market_type parameter)                 │
└─────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

**UI Layer**: Screens that compose widgets and handle user interactions
**Widget Layer**: Reusable components for market type selection and display
**Provider Layer**: State management using Riverpod
**Service Layer**: API communication and business logic
**Backend API**: Server-side processing of market-type-specific requests

## Components and Interfaces

### 1. MarketType Enum

```dart
enum MarketType {
  spot('spot', 'Spot', '💰', Colors.blue),
  futures('futures', 'Futures', '📈', Colors.purple),
  margin('margin', 'Margin', '⚡', Colors.orange),
  options('options', 'Options', '🎯', Colors.green);

  final String value;
  final String displayName;
  final String icon;
  final Color color;
  
  // Methods
  static MarketType fromString(String value);
  int get maxLeverage;
  bool get supportsLeverage;
  String get description;
}
```

### 2. UI Components

#### SegmentedButton Component
- **Purpose**: Modern mobile-first selector
- **Use Case**: Primary selection on mobile devices
- **Features**: Material 3 design, haptic feedback, smooth animations

#### FilterChips Component
- **Purpose**: Compact multi-select style
- **Use Case**: Tablet layouts, horizontal scrolling
- **Features**: Icon + text, tooltips, color coding

#### Dropdown Component
- **Purpose**: Space-efficient selector
- **Use Case**: Forms, limited space contexts
- **Features**: Standard dropdown, icon support

#### InfoCard Component
- **Purpose**: Detailed information display
- **Use Case**: Demo screen, educational contexts
- **Features**: Full description, features list, color coding

### 3. State Management

#### Providers

```dart
// Selected market type
final selectedMarketTypeProvider = StateProvider<MarketType>(
  (ref) => MarketType.spot,
);

// Leverage based on market type
final leverageProvider = StateProvider<double>((ref) {
  final marketType = ref.watch(selectedMarketTypeProvider);
  return marketType.supportsLeverage ? 1.0 : 1.0;
});

// Market type service
final marketTypeServiceProvider = Provider<MarketTypeService>(
  (ref) => MarketTypeService(),
);
```

### 4. Service Layer

#### MarketTypeService

```dart
class MarketTypeService {
  // Convert symbol based on market type
  String convertSymbol(String symbol, MarketType marketType);
  
  // Validate leverage for market type
  bool validateLeverage(double leverage, MarketType marketType);
  
  // Get market type configuration
  MarketTypeConfig getConfig(MarketType marketType);
}
```

#### Integration with Existing Services

All existing services (AiBotService, FuturesService, MCPService) accept optional `marketType` parameter:

```dart
Future<ComprehensiveAnalysis> getComprehensiveAnalysis({
  required String symbol,
  required String exchange,
  MarketType? marketType,
});
```

## Data Models

### MarketTypeConfig

```dart
class MarketTypeConfig {
  final MarketType type;
  final int maxLeverage;
  final bool supportsShort;
  final bool hasFundingRate;
  final String riskLevel;
  final List<String> features;
  
  MarketTypeConfig({...});
}
```

### Symbol Conversion Rules

- **Spot**: `BTC/USDT` → `BTC/USDT`
- **Futures**: `BTC/USDT` → `BTC/USDT:USDT`
- **Margin**: `BTC/USDT` → `BTC/USDT`
- **Options**: `BTC/USDT` → `BTC/USDT` (with expiry)

## Error Handling

### Validation Errors

```dart
class MarketTypeValidationException implements Exception {
  final String message;
  final MarketType marketType;
  final String field;
  
  MarketTypeValidationException({...});
}
```

### Error Messages (Spanish)

- Invalid leverage: "Apalancamiento inválido para {marketType}"
- Unsupported feature: "Característica no soportada en {marketType}"
- API error: "Error al procesar {marketType}: {details}"

## Testing Strategy

### Unit Tests

1. **MarketType Enum Tests**
   - Test fromString conversion
   - Test maxLeverage calculation
   - Test supportsLeverage logic
   - Test description generation

2. **Service Tests**
   - Test symbol conversion for each type
   - Test leverage validation
   - Test configuration retrieval

3. **Provider Tests**
   - Test state updates
   - Test leverage auto-adjustment
   - Test persistence

### Widget Tests

1. **Component Tests**
   - Test SegmentedButton selection
   - Test FilterChips interaction
   - Test Dropdown behavior
   - Test InfoCard display

2. **Screen Tests**
   - Test Demo screen navigation
   - Test Config screen validation
   - Test Trading Hub integration

### Integration Tests

1. **End-to-End Flows**
   - Select market type → Update leverage → Save config
   - Switch market type → Load analysis → Display results
   - Demo screen → Tutorial → Apply template

## Performance Considerations

### Optimization Strategies

1. **State Management**
   - Use Riverpod for efficient rebuilds
   - Implement computed providers for derived state
   - Cache market type configurations

2. **UI Rendering**
   - Use const constructors where possible
   - Implement AnimatedSwitcher for smooth transitions
   - Limit rebuild scope with Consumer widgets

3. **API Calls**
   - Include market_type in single request
   - Avoid redundant API calls on type change
   - Cache responses per market type

### Performance Targets

- Market type switch: < 300ms
- Animation duration: 300ms
- Component render: < 16ms per frame
- API response: < 2s

## Accessibility

### WCAG 2.1 Compliance

1. **Color Contrast**
   - All market type colors meet 4.5:1 contrast ratio
   - Provide text labels in addition to colors

2. **Keyboard Navigation**
   - All components support tab navigation
   - Enter key activates selection

3. **Screen Reader Support**
   - Semantic labels for all components
   - Announce market type changes

## Security Considerations

### Input Validation

- Validate leverage ranges before API calls
- Sanitize market type strings from external sources
- Prevent injection through symbol conversion

### API Security

- Include market_type in request validation
- Verify market type permissions on backend
- Log all market type changes for audit

## Deployment Strategy

### Rollout Plan

1. **Phase 1**: Deploy models and services (backend compatible)
2. **Phase 2**: Deploy UI components (feature flag)
3. **Phase 3**: Enable demo screen for all users
4. **Phase 4**: Enable full market type selection

### Feature Flags

```dart
class FeatureFlags {
  static const bool enableMarketTypes = true;
  static const bool enableDemoScreen = true;
  static const bool enableOptionsTrading = false; // Future
}
```

### Rollback Plan

- Market type parameter is optional (backwards compatible)
- Can disable feature flags without code changes
- Fallback to Spot trading if errors occur

## Documentation

### Developer Documentation

- **Architecture Guide**: `lib/docs/MARKET_TYPES_IMPLEMENTATION.md`
- **API Reference**: Generated from dartdoc comments
- **Migration Guide**: For updating existing code

### User Documentation

- **Tutorial**: In-app demo screen
- **Help Articles**: Market type comparison table
- **Video Guides**: Quick actions demonstration

## Future Enhancements

### Planned Features

1. **Custom Market Types**: Allow users to define custom types
2. **Market Type Strategies**: Pre-built strategies per type
3. **Performance Analytics**: Compare returns across types
4. **Auto-Switching**: Automatically switch based on conditions

### Technical Debt

1. Add comprehensive integration tests
2. Implement analytics tracking for market type usage
3. Create automated UI tests for all components
4. Add performance monitoring for type switches
