/// Configuración de la API y constantes de la aplicación
///
/// Este archivo contiene todas las configuraciones relacionadas con la API,
/// WebSockets, timeouts y políticas de reintentos.
class ApiConfig {
  // Constructor privado para prevenir instanciación
  ApiConfig._();

  // ============================================================================
  // URLs Base - API Gateway
  // ============================================================================

  // ============================================================================
  // Network Configuration
  // ============================================================================

  /// IP del servidor backend
  static const String serverIp = '192.168.100.145';

  /// ⭐ RECOMENDADO - API Gateway (puerto 9090)
  /// Enruta al Scalping API (8081) y MCP Server (10600)
  static const String gatewayBaseUrl = 'http://$serverIp:9090';

  /// URL base del Scalping API (conexión directa al puerto 8081)
  static const String scalpingDirectUrl = 'http://$serverIp:8081';

  /// URL base del MCP Server (conexión directa al puerto 10600)
  static const String mcpDirectUrl = 'http://$serverIp:10600';

  /// ⭐ URL base para ApiClient - Scalping API via Gateway
  /// Incluye el path completo hasta /scalping para que los servicios
  /// puedan usar paths relativos simples
  static const String apiBaseUrl = '$gatewayBaseUrl/api/scalping/api/v1/scalping';

  // ============================================================================
  // MCP Server - AI Bot & Trading Tools Endpoints
  // ============================================================================

  /// URL base para MCP Server tools execution (via Gateway)
  static const String mcpToolsUrl = '$gatewayBaseUrl/api/mcp/tools/execute';

  /// URL base para AI Bot endpoints (conexión directa al MCP Server)
  static const String aiBotBaseUrl = '$mcpDirectUrl/api/v1/ai-bot';

  /// URL para análisis comprehensivo con AI
  static const String comprehensiveAnalysisUrl = '$aiBotBaseUrl/comprehensive-analysis';

  /// URL para control del AI Bot
  static const String aiBotControlUrl = '$aiBotBaseUrl';

  /// URL para configuración dinámica del bot
  static const String aiBotConfigUrl = '$aiBotBaseUrl/config';

  /// Alternativa: URL base para conexión directa (sin Gateway)
  static const String apiBaseUrlDirect = '$scalpingDirectUrl/api/v1/scalping';

  /// URL base de WebSocket (conexión directa - WebSocket aún no disponible vía Gateway)
  static const String wsBaseUrl = 'ws://$serverIp:8081/ws';

  // ============================================================================
  // Gateway Endpoints (paths absolutos desde gateway root)
  // ============================================================================

  /// Gateway health check
  static const String gatewayHealth = '/health';

  /// Gateway information
  static const String gatewayInfo = '/api/gateway/info';

  /// Scalping API base path (desde gateway root)
  static const String scalpingBase = '/api/scalping/api/v1/scalping';

  /// MCP Server base path (desde gateway root)
  static const String mcpBase = '/api/mcp';

  // ============================================================================
  // Configuración de Timeouts
  // ============================================================================

  /// Timeout para conexión
  static const Duration connectTimeout = Duration(seconds: 30);

  /// Timeout para recepción de datos
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Timeout para envío de datos
  static const Duration sendTimeout = Duration(seconds: 30);

  /// Timeout para reconexión de WebSocket (en segundos)
  static const int wsReconnectTimeout = 5; // 5 segundos

  // ============================================================================
  // Políticas de Reintentos
  // ============================================================================

  /// Número máximo de reintentos para peticiones HTTP
  static const int maxRetries = 3;

  /// Delay inicial entre reintentos
  static const Duration retryDelay = Duration(seconds: 1);

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

  /// Alias for enableHttpLogs (for compatibility)
  static const bool enableLogging = enableHttpLogs;

  /// Habilitar logs del body de las peticiones
  static const bool logRequestBody = true;

  /// Habilitar logs del body de las respuestas
  static const bool logResponseBody = true;

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

  /// Get base URL for environment
  static String getBaseUrl(String environment) {
    // For now, we use the API Gateway
    // In the future, you can add staging, production URLs here
    switch (environment) {
      case 'production':
        return apiBaseUrl;
      case 'development':
      default:
        return apiBaseUrl;
    }
  }

  /// Construye la URL completa para un WebSocket channel
  static String getWsUrl(String channel) {
    return wsBaseUrl; // Ya incluye /ws, no necesita channel
  }

  /// Calcula el delay de reintento con backoff exponencial
  static int getRetryDelay(int attemptNumber) {
    return (retryDelay.inMilliseconds *
            (retryBackoffMultiplier * attemptNumber)).round();
  }
}
