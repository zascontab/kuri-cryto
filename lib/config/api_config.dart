/// Configuración de la API y constantes de la aplicación
///
/// Este archivo contiene todas las configuraciones relacionadas con la API,
/// WebSockets, timeouts y políticas de reintentos.
class ApiConfig {
  // Constructor privado para prevenir instanciación
  ApiConfig._();

  // ============================================================================
  // URLs Base
  // ============================================================================

  /// URL base de la API REST
  static const String apiBaseUrl = 'http://localhost:8081/api/v1';

  /// URL base de WebSocket
  static const String wsBaseUrl = 'ws://localhost:8081/ws';

  // ============================================================================
  // Endpoints de la API
  // ============================================================================

  /// Endpoints de autenticación
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';

  /// Endpoints de mercado
  static const String marketTickers = '/market/tickers';
  static const String marketCandles = '/market/candles';
  static const String marketOrderbook = '/market/orderbook';
  static const String marketTrades = '/market/trades';

  /// Endpoints de trading
  static const String tradingOrders = '/trading/orders';
  static const String tradingPositions = '/trading/positions';
  static const String tradingBalance = '/trading/balance';

  /// Endpoints de usuario
  static const String userProfile = '/user/profile';
  static const String userHistory = '/user/history';
  static const String userSettings = '/user/settings';

  // ============================================================================
  // WebSocket Channels
  // ============================================================================

  /// Canal de tickers en tiempo real
  static const String wsTicker = '/ticker';

  /// Canal de libro de órdenes
  static const String wsOrderbook = '/orderbook';

  /// Canal de trades
  static const String wsTrades = '/trades';

  /// Canal de actualizaciones de usuario
  static const String wsUserUpdates = '/user';

  // ============================================================================
  // Configuración de Timeouts
  // ============================================================================

  /// Timeout para conexión (en milisegundos)
  static const int connectTimeout = 30000; // 30 segundos

  /// Timeout para recepción de datos (en milisegundos)
  static const int receiveTimeout = 30000; // 30 segundos

  /// Timeout para envío de datos (en milisegundos)
  static const int sendTimeout = 30000; // 30 segundos

  /// Timeout para reconexión de WebSocket (en segundos)
  static const int wsReconnectTimeout = 5; // 5 segundos

  // ============================================================================
  // Políticas de Reintentos
  // ============================================================================

  /// Número máximo de reintentos para peticiones HTTP
  static const int maxRetries = 3;

  /// Delay inicial entre reintentos (en milisegundos)
  static const int retryDelay = 1000; // 1 segundo

  /// Factor multiplicador para backoff exponencial
  static const double retryBackoffMultiplier = 2.0;

  /// Número máximo de reintentos de reconexión de WebSocket
  static const int wsMaxReconnectAttempts = 5;

  // ============================================================================
  // Configuración de Caché
  // ============================================================================

  /// Duración de caché para datos de mercado (en minutos)
  static const int marketDataCacheDuration = 5;

  /// Duración de caché para datos de usuario (en minutos)
  static const int userDataCacheDuration = 10;

  /// Tamaño máximo de caché en MB
  static const int maxCacheSize = 50;

  // ============================================================================
  // Configuración de Paginación
  // ============================================================================

  /// Número de elementos por página por defecto
  static const int defaultPageSize = 20;

  /// Número máximo de elementos por página
  static const int maxPageSize = 100;

  // ============================================================================
  // Headers HTTP
  // ============================================================================

  /// Headers por defecto para todas las peticiones
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ============================================================================
  // Configuración de Logging
  // ============================================================================

  /// Habilitar logs de peticiones HTTP en desarrollo
  static const bool enableHttpLogs = true;

  /// Habilitar logs de WebSocket en desarrollo
  static const bool enableWsLogs = true;

  // ============================================================================
  // Intervalos de Actualización
  // ============================================================================

  /// Intervalo de actualización de tickers (en segundos)
  static const int tickerUpdateInterval = 1;

  /// Intervalo de actualización de orderbook (en segundos)
  static const int orderbookUpdateInterval = 1;

  /// Intervalo de actualización de balance (en segundos)
  static const int balanceUpdateInterval = 5;

  // ============================================================================
  // Métodos Auxiliares
  // ============================================================================

  /// Construye la URL completa para un endpoint
  static String getApiUrl(String endpoint) {
    return '$apiBaseUrl$endpoint';
  }

  /// Construye la URL completa para un WebSocket channel
  static String getWsUrl(String channel) {
    return '$wsBaseUrl$channel';
  }

  /// Calcula el delay de reintento con backoff exponencial
  static int getRetryDelay(int attemptNumber) {
    return (retryDelay *
            (retryBackoffMultiplier * attemptNumber)).round();
  }
}
