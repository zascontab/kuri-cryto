# Design Document - UI/UX Redesign

## Overview

Este documento describe el diseño de la nueva arquitectura UI/UX para Kuri Crypto. El rediseño se enfoca en crear una experiencia profesional, intuitiva y de alto rendimiento que integre todas las funcionalidades existentes de manera coherente.

## Architecture

### Navigation Structure

```
Main Navigation (Bottom Bar - 5 tabs)
├── 1. Home (Dashboard)
│   ├── System Status
│   ├── Key Metrics (P&L, Win Rate, Positions, Latency)
│   ├── Quick Actions
│   └── Recent Activity
│
├── 2. Trading
│   ├── Positions (All Markets)
│   ├── Orders
│   ├── Trading Hub
│   └── Market Analysis
│
├── 3. AI
│   ├── AI Dashboard
│   ├── Recommendations
│   ├── Notifications
│   ├── Costs & Usage
│   └── Settings
│
├── 4. Strategies
│   ├── Active Strategies
│   ├── Backtesting
│   ├── Optimization
│   └── Performance
│
└── 5. More
    ├── Risk Monitor
    ├── Alerts
    ├── Analytics
    ├── Settings
    └── About
```

### Screen Hierarchy

**Primary Screens** (Bottom Navigation):
- Home Dashboard
- Trading Hub
- AI Center
- Strategies
- More

**Secondary Screens** (Accessible from primary):
- Position Details
- Strategy Configuration
- AI Analysis Details
- Risk Assessment
- Settings & Preferences

## Components and Interfaces

### 1. Home Dashboard

**Purpose**: Pantalla principal con overview del sistema y métricas clave

**Components**:
- `SystemStatusCard`: Estado del motor de trading
- `MetricsGrid`: Grid 2x2 con métricas principales
- `QuickActionsCard`: Acciones rápidas (Start/Stop, Refresh)
- `RecentActivityList`: Últimas operaciones y alertas
- `AIInsightsCard`: Resumen de recomendaciones de IA

**Layout**:
```
┌─────────────────────────────────┐
│ AppBar (Status + Settings)      │
├─────────────────────────────────┤
│ System Status Card              │
│ ┌─────────┐ ┌─────────┐        │
│ │ Running │ │ Healthy │        │
│ └─────────┘ └─────────┘        │
├─────────────────────────────────┤
│ Metrics Grid                    │
│ ┌──────┐ ┌──────┐              │
│ │ P&L  │ │ Win% │              │
│ ├──────┤ ├──────┤              │
│ │ Pos  │ │ Lat  │              │
│ └──────┘ └──────┘              │
├─────────────────────────────────┤
│ AI Insights                     │
│ • BUY BTC: Strong signal        │
│ • HOLD ETH: Consolidating       │
├─────────────────────────────────┤
│ Recent Activity                 │
│ • Trade executed: BTC +$350     │
│ • Alert: Drawdown 3.5%          │
└─────────────────────────────────┘
```

### 2. Trading Hub

**Purpose**: Gestión unificada de posiciones y órdenes

**Components**:
- `MarketTypeSelector`: Tabs para Spot/Futures/Margin/Options
- `PositionsList`: Lista de posiciones abiertas
- `PositionCard`: Card individual con detalles
- `OrdersPanel`: Panel de órdenes activas
- `QuickTradeButton`: FAB para trading rápido

**Features**:
- Filtrado por market type
- Ordenamiento por P&L, tamaño, fecha
- Swipe actions para cerrar posiciones
- Pull-to-refresh
- Real-time updates

### 3. AI Center

**Purpose**: Hub central para todas las funcionalidades de IA

**Components**:
- `AIStatusIndicator`: Estado y costos de IA
- `RecommendationsCarousel`: Carrusel de recomendaciones
- `NotificationsList`: Lista de notificaciones con IA
- `CostTracker`: Tracking de costos diarios/mensuales
- `AISettingsPanel`: Configuración de IA

**Layout**:
```
┌─────────────────────────────────┐
│ AI Status                       │
│ ┌─────────────────────────────┐ │
│ │ Active • $0.12/day          │ │
│ │ 47 calls • Gemini (66%)     │ │
│ └─────────────────────────────┘ │
├─────────────────────────────────┤
│ Recommendations                 │
│ ┌─────────────────────────────┐ │
│ │ BUY BTC @ $43,250           │ │
│ │ Strong bullish signal...    │ │
│ └─────────────────────────────┘ │
├─────────────────────────────────┤
│ Recent Notifications            │
│ • Trade executed: BTC           │
│ • Alert: ETH consolidating      │
│ [View All]                      │
└─────────────────────────────────┘
```

### 4. Strategies Center

**Purpose**: Gestión y monitoreo de estrategias de trading

**Components**:
- `StrategyCard`: Card con estado y métricas
- `PerformanceChart`: Gráfico de rendimiento
- `BacktestPanel`: Panel de backtesting
- `OptimizationResults`: Resultados de optimización

**Features**:
- Enable/disable strategies con switch
- Ver detalles de cada estrategia
- Ejecutar backtests
- Optimizar parámetros
- Ver historial de trades

### 5. More Section

**Purpose**: Acceso a funcionalidades adicionales y configuración

**Components**:
- `FeaturesList`: Lista de features adicionales
- `SettingsPanel`: Panel de configuración
- `RiskMonitor`: Monitor de riesgo
- `AnalyticsPanel`: Panel de analytics

## Data Models

### Dashboard State
```dart
class DashboardState {
  final SystemStatus systemStatus;
  final Metrics metrics;
  final HealthStatus health;
  final List<RecentActivity> recentActivity;
  final AIInsights? aiInsights;
  final bool isLoading;
  final String? error;
}
```

### Trading State
```dart
class TradingState {
  final MarketType selectedMarketType;
  final List<Position> positions;
  final List<Order> orders;
  final Map<String, double> prices;
  final bool isLoading;
  final String? error;
}
```

### AI State
```dart
class AIState {
  final AIStatus status;
  final AICosts costs;
  final List<AINotification> notifications;
  final List<AIRecommendation> recommendations;
  final AIConfig config;
  final bool isLoading;
  final String? error;
}
```

## Error Handling

### Error Types
1. **NetworkError**: Problemas de conectividad
2. **APIError**: Errores del backend
3. **ValidationError**: Errores de validación
4. **StateError**: Errores de estado inconsistente

### Error Display Strategy
- **Snackbar**: Para errores transitorios y recuperables
- **Error Widget**: Para errores que bloquean una sección
- **Dialog**: Para errores críticos que requieren acción del usuario
- **Inline Error**: Para errores de validación en formularios

### Retry Logic
- Exponential backoff para requests fallidos
- Máximo 3 intentos automáticos
- Botón manual de retry para el usuario
- Cache fallback cuando sea posible

## Testing Strategy

### Unit Tests
- Modelos de datos (fromJson/toJson)
- Lógica de negocio en providers
- Helpers y utilidades
- Validaciones

### Widget Tests
- Componentes individuales
- Interacciones de usuario
- Estados de loading/error
- Responsive behavior

### Integration Tests
- Flujos completos de usuario
- Navegación entre pantallas
- Actualización de datos en tiempo real
- Manejo de errores end-to-end

### Performance Tests
- Tiempo de renderizado
- Memoria utilizada
- Smooth scrolling (60 FPS)
- Tiempo de carga inicial

## Performance Optimization

### State Management
- Usar Riverpod con providers granulares
- Evitar rebuilds innecesarios con `select`
- Implementar `AutoDispose` para providers temporales
- Cache de datos con TTL apropiado

### Rendering Optimization
- Usar `const` constructors donde sea posible
- Implementar `RepaintBoundary` para widgets complejos
- Lazy loading de listas largas con `ListView.builder`
- Pagination para datos extensos

### Data Loading
- Parallel loading de datos independientes
- Optimistic updates para mejor UX
- Background refresh sin bloquear UI
- Debouncing de búsquedas y filtros

### Asset Optimization
- Usar SVG para iconos cuando sea posible
- Optimizar imágenes (WebP, compresión)
- Lazy loading de assets pesados
- Precaching de assets críticos

## Accessibility

### Visual
- Contrast ratio mínimo 4.5:1 (WCAG AA)
- Tamaño de fuente escalable
- Iconos con labels descriptivos
- Color no como único indicador

### Interaction
- Touch targets mínimo 48x48dp
- Feedback háptico para acciones importantes
- Keyboard navigation support
- Screen reader support

### Content
- Textos descriptivos para imágenes
- Labels claros para formularios
- Mensajes de error comprensibles
- Instrucciones claras para acciones

## Responsive Design

### Breakpoints
- **Mobile**: < 600dp (1 columna)
- **Tablet**: 600-840dp (2 columnas)
- **Desktop**: > 840dp (3+ columnas)

### Adaptive Layouts
- Grid adapta número de columnas según breakpoint
- Navigation bar se convierte en rail en tablet/desktop
- Modals se convierten en side sheets en pantallas grandes
- Tipografía escala según tamaño de pantalla

## Theme System

### Color Palette
```dart
// Light Theme
primary: #2196F3 (Blue)
secondary: #4CAF50 (Green)
error: #F44336 (Red)
warning: #FF9800 (Orange)
success: #4CAF50 (Green)

// Dark Theme
primary: #64B5F6 (Light Blue)
secondary: #81C784 (Light Green)
error: #EF5350 (Light Red)
warning: #FFB74D (Light Orange)
success: #81C784 (Light Green)
```

### Typography
```dart
displayLarge: 57sp, Regular
displayMedium: 45sp, Regular
displaySmall: 36sp, Regular
headlineLarge: 32sp, Regular
headlineMedium: 28sp, Regular
headlineSmall: 24sp, Regular
titleLarge: 22sp, Medium
titleMedium: 16sp, Medium
titleSmall: 14sp, Medium
bodyLarge: 16sp, Regular
bodyMedium: 14sp, Regular
bodySmall: 12sp, Regular
```

### Spacing System
```dart
xs: 4dp
sm: 8dp
md: 16dp
lg: 24dp
xl: 32dp
xxl: 48dp
```

## Animation Guidelines

### Transitions
- Page transitions: 300ms, easeInOut
- Card expansions: 200ms, easeOut
- Fade in/out: 150ms, linear
- Slide animations: 250ms, easeInOut

### Micro-interactions
- Button press: Scale 0.95, 100ms
- Switch toggle: 200ms, easeInOut
- Checkbox: 150ms, easeOut
- Loading indicators: Continuous, smooth

### Performance
- Mantener animaciones a 60 FPS
- Usar `AnimatedBuilder` para animaciones complejas
- Evitar animaciones durante scroll
- Cancelar animaciones cuando widget se desmonta
