import 'package:flutter/material.dart';

/// Constantes de la aplicación
///
/// Este archivo contiene todas las constantes utilizadas en la aplicación,
/// incluyendo endpoints de API, timeframes, nombres de estrategias,
/// modos de riesgo, lados de posición, tipos de órdenes y colores de UI.

// ============================================================================
// API Endpoints
// ============================================================================

/// Endpoints de la API REST
class ApiEndpoints {
  ApiEndpoints._(); // Constructor privado para prevenir instanciación

  // Base URLs (via Gateway - deprecated, use ApiConfig instead)
  static const String baseUrl = 'http://localhost:9090/api/scalping/api/v1';
  static const String wsBaseUrl = 'ws://localhost:9090/ws';

  // Autenticación
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';

  // Mercado
  static const String marketTickers = '/market/tickers';
  static const String marketCandles = '/market/candles';
  static const String marketOrderbook = '/market/orderbook';
  static const String marketTrades = '/market/trades';
  static const String marketSymbols = '/market/symbols';

  // Trading
  static const String tradingOrders = '/trading/orders';
  static const String tradingPositions = '/trading/positions';
  static const String tradingBalance = '/trading/balance';
  static const String tradingHistory = '/trading/history';

  // Estrategias
  static const String strategies = '/strategies';
  static const String strategiesPerformance = '/strategies/performance';
  static const String strategiesBacktest = '/strategies/backtest';

  // Análisis
  static const String analysisSignals = '/analysis/signals';
  static const String analysisIndicators = '/analysis/indicators';
  static const String analysisPatterns = '/analysis/patterns';

  // Riesgo
  static const String riskLimits = '/risk/limits';
  static const String riskExposure = '/risk/exposure';
  static const String riskStatus = '/risk/status';

  // Sistema
  static const String systemStatus = '/system/status';
  static const String systemHealth = '/system/health';
  static const String systemMetrics = '/system/metrics';

  // Usuario
  static const String userProfile = '/user/profile';
  static const String userSettings = '/user/settings';
  static const String userHistory = '/user/history';
  static const String userPreferences = '/user/preferences';

  // WebSocket Channels
  static const String wsTicker = '/ticker';
  static const String wsOrderbook = '/orderbook';
  static const String wsTrades = '/trades';
  static const String wsUserUpdates = '/user';
  static const String wsPositions = '/positions';
  static const String wsOrders = '/orders';

  /// Construye una URL completa para un endpoint
  static String getUrl(String endpoint) => '$baseUrl$endpoint';

  /// Construye una URL de WebSocket completa
  static String getWsUrl(String channel) => '$wsBaseUrl$channel';
}

// ============================================================================
// Timeframes
// ============================================================================

/// Intervalos de tiempo para velas/candles
class Timeframes {
  Timeframes._();

  static const String oneMinute = '1m';
  static const String threeMinutes = '3m';
  static const String fiveMinutes = '5m';
  static const String fifteenMinutes = '15m';
  static const String thirtyMinutes = '30m';
  static const String oneHour = '1h';
  static const String twoHours = '2h';
  static const String fourHours = '4h';
  static const String sixHours = '6h';
  static const String twelveHours = '12h';
  static const String oneDay = '1d';
  static const String threeDays = '3d';
  static const String oneWeek = '1w';
  static const String oneMonth = '1M';

  /// Lista de todos los timeframes disponibles
  static const List<String> all = [
    oneMinute,
    threeMinutes,
    fiveMinutes,
    fifteenMinutes,
    thirtyMinutes,
    oneHour,
    twoHours,
    fourHours,
    sixHours,
    twelveHours,
    oneDay,
    threeDays,
    oneWeek,
    oneMonth,
  ];

  /// Timeframes comunes para trading
  static const List<String> common = [
    fiveMinutes,
    fifteenMinutes,
    oneHour,
    fourHours,
    oneDay,
  ];

  /// Timeframes para scalping
  static const List<String> scalping = [
    oneMinute,
    threeMinutes,
    fiveMinutes,
    fifteenMinutes,
  ];

  /// Timeframes para swing trading
  static const List<String> swing = [
    fourHours,
    oneDay,
    threeDays,
    oneWeek,
  ];

  /// Convierte timeframe a minutos
  static int toMinutes(String timeframe) {
    switch (timeframe) {
      case oneMinute:
        return 1;
      case threeMinutes:
        return 3;
      case fiveMinutes:
        return 5;
      case fifteenMinutes:
        return 15;
      case thirtyMinutes:
        return 30;
      case oneHour:
        return 60;
      case twoHours:
        return 120;
      case fourHours:
        return 240;
      case sixHours:
        return 360;
      case twelveHours:
        return 720;
      case oneDay:
        return 1440;
      case threeDays:
        return 4320;
      case oneWeek:
        return 10080;
      case oneMonth:
        return 43200;
      default:
        return 60; // Default to 1 hour
    }
  }

  /// Obtiene nombre legible del timeframe
  static String getDisplayName(String timeframe) {
    switch (timeframe) {
      case oneMinute:
        return '1 Minute';
      case threeMinutes:
        return '3 Minutes';
      case fiveMinutes:
        return '5 Minutes';
      case fifteenMinutes:
        return '15 Minutes';
      case thirtyMinutes:
        return '30 Minutes';
      case oneHour:
        return '1 Hour';
      case twoHours:
        return '2 Hours';
      case fourHours:
        return '4 Hours';
      case sixHours:
        return '6 Hours';
      case twelveHours:
        return '12 Hours';
      case oneDay:
        return '1 Day';
      case threeDays:
        return '3 Days';
      case oneWeek:
        return '1 Week';
      case oneMonth:
        return '1 Month';
      default:
        return timeframe;
    }
  }
}

// ============================================================================
// Strategy Names
// ============================================================================

/// Nombres de estrategias de trading
class StrategyNames {
  StrategyNames._();

  static const String scalping = 'scalping';
  static const String meanReversion = 'mean_reversion';
  static const String trendFollowing = 'trend_following';
  static const String breakout = 'breakout';
  static const String momentum = 'momentum';
  static const String arbitrage = 'arbitrage';
  static const String gridTrading = 'grid_trading';
  static const String martingale = 'martingale';
  static const String dca = 'dca'; // Dollar Cost Averaging
  static const String custom = 'custom';

  /// Lista de todas las estrategias
  static const List<String> all = [
    scalping,
    meanReversion,
    trendFollowing,
    breakout,
    momentum,
    arbitrage,
    gridTrading,
    martingale,
    dca,
    custom,
  ];

  /// Obtiene nombre legible de la estrategia
  static String getDisplayName(String strategy) {
    switch (strategy) {
      case scalping:
        return 'Scalping';
      case meanReversion:
        return 'Mean Reversion';
      case trendFollowing:
        return 'Trend Following';
      case breakout:
        return 'Breakout';
      case momentum:
        return 'Momentum';
      case arbitrage:
        return 'Arbitrage';
      case gridTrading:
        return 'Grid Trading';
      case martingale:
        return 'Martingale';
      case dca:
        return 'DCA (Dollar Cost Averaging)';
      case custom:
        return 'Custom';
      default:
        return strategy;
    }
  }

  /// Obtiene descripción de la estrategia
  static String getDescription(String strategy) {
    switch (strategy) {
      case scalping:
        return 'High-frequency trading strategy that captures small price movements';
      case meanReversion:
        return 'Exploits price deviations from historical averages';
      case trendFollowing:
        return 'Identifies and follows established market trends';
      case breakout:
        return 'Trades price breaks above/below key resistance/support levels';
      case momentum:
        return 'Captures strong price movements in trending markets';
      case arbitrage:
        return 'Exploits price differences between markets or exchanges';
      case gridTrading:
        return 'Places orders at regular intervals in a grid pattern';
      case martingale:
        return 'Doubles position size after losses to recover';
      case dca:
        return 'Invests fixed amounts at regular intervals';
      case custom:
        return 'User-defined custom trading strategy';
      default:
        return 'Trading strategy';
    }
  }
}

// ============================================================================
// Risk Modes
// ============================================================================

/// Modos de riesgo para gestión de capital
class RiskModes {
  RiskModes._();

  static const String conservative = 'conservative';
  static const String moderate = 'moderate';
  static const String aggressive = 'aggressive';
  static const String custom = 'custom';

  /// Lista de todos los modos de riesgo
  static const List<String> all = [
    conservative,
    moderate,
    aggressive,
    custom,
  ];

  /// Obtiene nombre legible del modo de riesgo
  static String getDisplayName(String mode) {
    switch (mode) {
      case conservative:
        return 'Conservative';
      case moderate:
        return 'Moderate';
      case aggressive:
        return 'Aggressive';
      case custom:
        return 'Custom';
      default:
        return mode;
    }
  }

  /// Obtiene el máximo drawdown permitido por modo (en porcentaje)
  static double getMaxDrawdown(String mode) {
    switch (mode) {
      case conservative:
        return 5.0; // 5%
      case moderate:
        return 10.0; // 10%
      case aggressive:
        return 20.0; // 20%
      default:
        return 10.0;
    }
  }

  /// Obtiene el máximo riesgo por operación (en porcentaje del capital)
  static double getMaxRiskPerTrade(String mode) {
    switch (mode) {
      case conservative:
        return 1.0; // 1%
      case moderate:
        return 2.0; // 2%
      case aggressive:
        return 5.0; // 5%
      default:
        return 2.0;
    }
  }
}

// ============================================================================
// Position Sides
// ============================================================================

/// Lados de posición (Long/Short)
class PositionSides {
  PositionSides._();

  static const String long = 'long';
  static const String short = 'short';

  /// Lista de todos los lados
  static const List<String> all = [long, short];

  /// Obtiene nombre legible del lado
  static String getDisplayName(String side) {
    switch (side) {
      case long:
        return 'Long (Buy)';
      case short:
        return 'Short (Sell)';
      default:
        return side;
    }
  }

  /// Obtiene el lado opuesto
  static String getOpposite(String side) {
    return side == long ? short : long;
  }
}

// ============================================================================
// Order Types
// ============================================================================

/// Tipos de órdenes
class OrderTypes {
  OrderTypes._();

  static const String market = 'market';
  static const String limit = 'limit';
  static const String stopLoss = 'stop_loss';
  static const String stopLimit = 'stop_limit';
  static const String takeProfit = 'take_profit';
  static const String takeProfitLimit = 'take_profit_limit';
  static const String trailingStop = 'trailing_stop';

  /// Lista de todos los tipos de órdenes
  static const List<String> all = [
    market,
    limit,
    stopLoss,
    stopLimit,
    takeProfit,
    takeProfitLimit,
    trailingStop,
  ];

  /// Obtiene nombre legible del tipo de orden
  static String getDisplayName(String type) {
    switch (type) {
      case market:
        return 'Market';
      case limit:
        return 'Limit';
      case stopLoss:
        return 'Stop Loss';
      case stopLimit:
        return 'Stop Limit';
      case takeProfit:
        return 'Take Profit';
      case takeProfitLimit:
        return 'Take Profit Limit';
      case trailingStop:
        return 'Trailing Stop';
      default:
        return type;
    }
  }

  /// Obtiene descripción del tipo de orden
  static String getDescription(String type) {
    switch (type) {
      case market:
        return 'Executes immediately at current market price';
      case limit:
        return 'Executes at specified price or better';
      case stopLoss:
        return 'Market order triggered when stop price is reached';
      case stopLimit:
        return 'Limit order triggered when stop price is reached';
      case takeProfit:
        return 'Market order to close position at profit target';
      case takeProfitLimit:
        return 'Limit order to close position at profit target';
      case trailingStop:
        return 'Stop loss that follows price at specified distance';
      default:
        return 'Order type';
    }
  }
}

// ============================================================================
// Order Status
// ============================================================================

/// Estados de órdenes
class OrderStatus {
  OrderStatus._();

  static const String pending = 'pending';
  static const String open = 'open';
  static const String filled = 'filled';
  static const String partiallyFilled = 'partially_filled';
  static const String cancelled = 'cancelled';
  static const String rejected = 'rejected';
  static const String expired = 'expired';

  /// Lista de todos los estados
  static const List<String> all = [
    pending,
    open,
    filled,
    partiallyFilled,
    cancelled,
    rejected,
    expired,
  ];

  /// Obtiene nombre legible del estado
  static String getDisplayName(String status) {
    switch (status) {
      case pending:
        return 'Pending';
      case open:
        return 'Open';
      case filled:
        return 'Filled';
      case partiallyFilled:
        return 'Partially Filled';
      case cancelled:
        return 'Cancelled';
      case rejected:
        return 'Rejected';
      case expired:
        return 'Expired';
      default:
        return status;
    }
  }

  /// Verifica si el estado es final (no puede cambiar)
  static bool isFinal(String status) {
    return [filled, cancelled, rejected, expired].contains(status);
  }
}

// ============================================================================
// Position Status
// ============================================================================

/// Estados de posiciones
class PositionStatus {
  PositionStatus._();

  static const String open = 'open';
  static const String closing = 'closing';
  static const String closed = 'closed';

  /// Lista de todos los estados
  static const List<String> all = [open, closing, closed];

  /// Obtiene nombre legible del estado
  static String getDisplayName(String status) {
    switch (status) {
      case open:
        return 'Open';
      case closing:
        return 'Closing';
      case closed:
        return 'Closed';
      default:
        return status;
    }
  }
}

// ============================================================================
// Color Constants
// ============================================================================

/// Colores de la UI
class AppColors {
  AppColors._();

  // Colores Principales
  static const Color primary = Color(0xFF2196F3); // Blue
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  static const Color secondary = Color(0xFFFF9800); // Orange
  static const Color secondaryDark = Color(0xFFF57C00);
  static const Color secondaryLight = Color(0xFFFFB74D);

  // Colores de Trading
  static const Color profit = Color(0xFF4CAF50); // Green
  static const Color loss = Color(0xFFF44336); // Red
  static const Color neutral = Color(0xFF9E9E9E); // Grey

  static const Color long = Color(0xFF4CAF50); // Green
  static const Color short = Color(0xFFF44336); // Red

  static const Color buyButton = Color(0xFF4CAF50);
  static const Color sellButton = Color(0xFFF44336);

  // Colores de Estado
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Colores de Fondo
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Colores de Texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Colores de Gráficos
  static const Color chartLine = Color(0xFF2196F3);
  static const Color chartGrid = Color(0xFFE0E0E0);
  static const Color chartBackground = Color(0xFFFFFFFF);

  static const List<Color> chartColors = [
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFFF44336), // Red
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFFE91E63), // Pink
  ];

  // Colores de Indicadores
  static const Color rsiOverbought = Color(0xFFF44336); // Red
  static const Color rsiOversold = Color(0xFF4CAF50); // Green
  static const Color macdBullish = Color(0xFF4CAF50);
  static const Color macdBearish = Color(0xFFF44336);

  // Gradientes
  static const LinearGradient profitGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lossGradient = LinearGradient(
    colors: [Color(0xFFF44336), Color(0xFFE57373)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Obtiene color según el PnL (positivo/negativo)
  static Color getPnLColor(double pnl) {
    return pnl >= 0 ? profit : loss;
  }

  /// Obtiene color según el lado de la posición
  static Color getPositionSideColor(String side) {
    return side.toLowerCase() == 'long' ? long : short;
  }

  /// Obtiene color según el porcentaje de cambio
  static Color getChangeColor(double changePercent) {
    if (changePercent > 0) return profit;
    if (changePercent < 0) return loss;
    return neutral;
  }
}

// ============================================================================
// App Constants
// ============================================================================

/// Constantes generales de la aplicación
class AppConstants {
  AppConstants._();

  // Nombres de la App
  static const String appName = 'Kuri Crypto';
  static const String appVersion = '1.0.0';

  // Preferencias
  static const String prefThemeMode = 'theme_mode';
  static const String prefLocale = 'locale';
  static const String prefLastSymbol = 'last_symbol';
  static const String prefDefaultTimeframe = 'default_timeframe';
  static const String prefChartType = 'chart_type';
  static const String prefNotifications = 'notifications_enabled';

  // Símbolos por defecto
  static const String defaultSymbol = 'BTC-USDT';
  static const String defaultQuoteCurrency = 'USDT';

  // Límites
  static const int maxPositions = 10;
  static const int maxOrdersPerSymbol = 5;
  static const double minTradeAmount = 10.0; // USDT
  static const double maxLeverage = 125.0;

  // Cache
  static const Duration cacheExpiration = Duration(minutes: 5);
  static const int maxCacheSize = 100; // MB

  // WebSocket
  static const Duration wsReconnectDelay = Duration(seconds: 5);
  static const int wsMaxReconnectAttempts = 5;
  static const Duration wsPingInterval = Duration(seconds: 30);

  // UI
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  static const double inputBorderRadius = 8.0;
  static const double dialogBorderRadius = 16.0;

  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 12.0,
  );

  // Animaciones
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Formato
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm:ss';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  // Símbolos Populares
  static const List<String> popularSymbols = [
    'BTC-USDT',
    'ETH-USDT',
    'BNB-USDT',
    'ADA-USDT',
    'SOL-USDT',
    'XRP-USDT',
    'DOT-USDT',
    'DOGE-USDT',
    'AVAX-USDT',
    'MATIC-USDT',
  ];
}
