# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-11-27

### Added - Market Types System 🎉

#### Core Features
- **Market Type Enum**: Type-safe enum with 4 market types (Spot, Futures, Margin, Options)
- **Market Type Service**: API integration for market type operations
- **State Management**: Riverpod providers for market type and leverage state
- **Automatic Validation**: Leverage validation based on selected market type

#### UI Components
- **MarketTypeSelector**: Modern segmented button for mobile
- **MarketTypeChips**: Compact filter chips for tablets
- **MarketTypeDropdown**: Space-efficient dropdown selector
- **MarketTypeInfoCard**: Detailed information card with features

#### Screens
- **Market Type Demo Screen**: Interactive demo with:
  - Multiple selector styles
  - Real-time leverage adjustment
  - Risk assessment indicator
  - Key features display
  - Use cases section
  - Order simulation

#### Educational Features
- **Interactive Tutorial**: Full tutorial dialog with:
  - Detailed explanations for each market type
  - Key characteristics and features
  - Best practices and use cases
  - Visual examples
- **Comparison Table**: Side-by-side comparison of all market types
- **Risk Indicator**: Dynamic risk assessment based on type and leverage

#### Documentation
- **User Guides**:
  - Understanding Market Types (comprehensive guide)
  - Choosing the Right Market Type (decision guide)
  - Leverage and Risk Management (safety guide)
- **Developer Documentation**:
  - Complete API documentation with dartdoc comments
  - Implementation guide
  - Integration examples
- **Help Articles**: 3 detailed markdown guides in `lib/docs/help/`

#### Backend Integration
- Added `market_type` parameter to all trading APIs
- Automatic symbol conversion based on market type
- Leverage validation on backend calls
- Backwards compatible (optional parameter)

#### Technical Improvements
- Fixed deprecation warnings (MaterialState → WidgetState)
- Comprehensive dartdoc comments on all public APIs
- Type-safe market type handling
- Efficient state management with Riverpod

### Changed
- Updated README.md with Market Types section
- Enhanced architecture documentation
- Updated roadmap with completed features

### Migration Notes
- Market type parameter is optional - existing code continues to work
- Default market type is Futures if not specified
- No breaking changes to existing APIs

---

## [1.0.0] - 2025-11-16

### Added
- **Theme System**: Complete light/dark mode implementation
  - Light mode optimized for daytime use
  - Dark mode to reduce eye strain
  - System mode that follows device preferences
  - Theme persistence across sessions
- **Theme Provider**: Riverpod-based state management for themes
- **Theme Toggle**: UI controls in AppBar and Settings

### Features
- Initial project setup
- Basic navigation structure
- Trading dashboard foundation
- Position management screens
- Settings screen

### Documentation
- THEME_IMPLEMENTATION.md
- API-DOCUMENTATION.md
- API-SUMMARY-FOR-FLUTTER-TEAM.md

---

## [Unreleased]

### Planned
- Risk Monitor Widget
- Kill Switch UI
- Position Management enhancements
- Multi-timeframe Analysis UI
- Backtesting Screens
- Signal Visualization
- Alerts & Notifications

---

## Version History

- **1.1.0** (2025-11-27): Market Types System
- **1.0.0** (2025-11-16): Initial Release with Theme System

---

*For more details on each release, see the commit history and pull requests.*
