import 'environment.dart';

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
  // Network Configuration - Using Environment Variables
  // ============================================================================

  /// ⭐ RECOMENDADO - API Gateway
  /// Enruta al Scalping API y MCP Server
  static String get gatewayBaseUrl => Environment.gatewayBaseUrl;

  /// MATP Kong Gateway base URL
  /// Sistema principal de trading con autenticación JWT y niveles progresivos
  static String get matpKongGatewayUrl => Environment.matpKongGatewayUrl;

  /// MATP API directa - para desarrollo
  static String get matpDirectUrl => Environment.matpDirectUrl;

  /// URL base del Scalping API (conexión directa)
  static String get scalpingDirectUrl => Environment.scalpingDirectUrl;

  /// URL base del MCP Server (conexión directa)
  static String get mcpDirectUrl => Environment.mcpDirectUrl;

  /// ⭐ URL base para ApiClient - Scalping API via Gateway
  /// Incluye el path completo hasta /scalping para que los servicios
  /// puedan usar paths relativos simples
  static String get apiBaseUrl =>
      '$gatewayBaseUrl/api/scalping/api/v1/scalping';

  // ============================================================================
  // MCP Server - AI Bot & Trading Tools Endpoints
  // ============================================================================

  /// URL base para MCP Server tools execution
  /// FIXED: El MCP Server usa JSON-RPC 2.0 en el endpoint raíz
  static String get mcpToolsUrl {
    return mcpDirectUrl; // Endpoint raíz del MCP Server
  }

  /// URL base para AI Bot endpoints (conexión directa al MCP Server)
  /// ✅ NO REQUIERE AUTENTICACIÓN - Todos los endpoints son públicos
  static String get aiBotBaseUrl => '$mcpDirectUrl/api/v1/ai-bot';

  /// URL para análisis comprehensivo con AI
  /// ✅ NO REQUIERE AUTENTICACIÓN
  static String get comprehensiveAnalysisUrl =>
      '$aiBotBaseUrl/comprehensive-analysis';

  /// Health check del MCP Server
  /// ✅ NO REQUIERE AUTENTICACIÓN
  static String get mcpHealthUrl => '$mcpDirectUrl/health';

  /// URL para control del AI Bot
  static String get aiBotControlUrl => aiBotBaseUrl;

  /// URL para configuración dinámica del bot
  static String get aiBotConfigUrl => '$aiBotBaseUrl/config';

  /// URL para estado del bot
  static String get aiBotStatusUrl => '$aiBotBaseUrl/status';

  /// URL para iniciar el bot
  static String get aiBotStartUrl => '$aiBotBaseUrl/start';

  /// URL para detener el bot
  static String get aiBotStopUrl => '$aiBotBaseUrl/stop';

  /// URL para obtener posiciones del bot
  static String get aiBotPositionsUrl => '$aiBotBaseUrl/positions';

  /// Alternativa: URL base para conexión directa (sin Gateway)
  static String get apiBaseUrlDirect => '$scalpingDirectUrl/api/v1/scalping';

  /// URL base de WebSocket (conexión directa - WebSocket aún no disponible vía Gateway)
  static String get wsBaseUrl => Environment.wsBaseUrl;

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

  /// Get MATP base URL for environment
  static String getMATPBaseUrl(String environment) {
    switch (environment) {
      case 'production':
        return matpKongGatewayUrl;
      case 'development':
      default:
        return matpKongGatewayUrl; // Use Kong Gateway by default
    }
  }

  /// Get MCP gateway URL for JSON-RPC calls
  static String getMCPGatewayUrl() {
    return gatewayBaseUrl; // Port 9090 gateway for MCP tools
  }

  /// Construye la URL completa para un WebSocket channel
  static String getWsUrl(String channel) {
    return wsBaseUrl; // Ya incluye /ws, no necesita channel
  }

  /// Calcula el delay de reintento con backoff exponencial
  static int getRetryDelay(int attemptNumber) {
    return (retryDelay.inMilliseconds *
            (retryBackoffMultiplier * attemptNumber))
        .round();
  }

  /// Valida que todas las URLs estén correctamente configuradas
  ///
  /// Retorna true si todas las URLs son válidas, false en caso contrario
  static bool validateConfiguration() {
    try {
      // Verificar que las URLs sean válidas
      Uri.parse(gatewayBaseUrl);
      Uri.parse(mcpDirectUrl);
      Uri.parse(scalpingDirectUrl);
      Uri.parse(comprehensiveAnalysisUrl);
      Uri.parse(aiBotConfigUrl);
      Uri.parse(aiBotBaseUrl);
      Uri.parse(mcpToolsUrl);
      Uri.parse(apiBaseUrl);

      // Verificar que el server IP no esté vacío
      if (Environment.serverIp.isEmpty) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Valida que las URLs del sistema MATP estén correctamente configuradas
  static bool validateMATPConfiguration() {
    try {
      Uri.parse(matpKongGatewayUrl);
      Uri.parse(matpDirectUrl);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene información de configuración para debugging
  static Map<String, String> getConfigInfo() {
    return {
      'serverIp': Environment.serverIp,
      'gatewayBaseUrl': gatewayBaseUrl,
      'mcpDirectUrl': mcpDirectUrl,
      'scalpingDirectUrl': scalpingDirectUrl,
      'comprehensiveAnalysisUrl': comprehensiveAnalysisUrl,
      'aiBotConfigUrl': aiBotConfigUrl,
      'mcpToolsUrl': mcpToolsUrl,
      'matpKongGatewayUrl': matpKongGatewayUrl,
      'matpDirectUrl': matpDirectUrl,
    };
  }
}
