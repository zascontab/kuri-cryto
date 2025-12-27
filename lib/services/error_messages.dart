import '../config/environment.dart';

/// User-friendly error messages for common error codes
class ErrorMessages {
  // Constructor privado para prevenir instanciación
  ErrorMessages._();

  /// Map of error codes to user-friendly Spanish messages
  static const Map<String, String> userFriendly = {
    // Network errors
    'TIMEOUT': 'La conexión tardó demasiado. Verifica tu red.',
    'RECEIVE_TIMEOUT':
        'El servidor tardó demasiado en responder. Intenta de nuevo.',
    'CONNECTION_ERROR':
        'No se pudo conectar al servidor. Verifica que esté corriendo.',
    'NETWORK_ERROR': 'Error de red. Verifica tu conexión a internet.',
    'EMPTY_RESPONSE': 'El servidor no respondió. Intenta de nuevo.',
    'NO_RESULT': 'El servidor no retornó datos. Intenta de nuevo.',

    // Trading errors
    'INSUFFICIENT_BALANCE': 'Balance insuficiente para ejecutar la operación.',
    'RISK_LIMIT_EXCEEDED': 'Límite de riesgo excedido. Operación bloqueada.',
    'KILL_SWITCH_ACTIVE': 'Sistema de emergencia activado. Trading pausado.',
    'POSITION_NOT_FOUND': 'La posición no existe o ya fue cerrada.',
    'ORDER_FAILED': 'La orden no pudo ser ejecutada. Intenta de nuevo.',
    'MARKET_CLOSED': 'El mercado está cerrado en este momento.',

    // Bot configuration errors
    'INVALID_THRESHOLD': 'El umbral de confianza debe estar entre 0.5 y 1.0.',
    'INVALID_LEVERAGE': 'El apalancamiento debe estar entre 1 y 100.',
    'INVALID_TRADE_SIZE': 'El tamaño de trade debe ser positivo.',
    'BOT_RUNNING':
        'No se puede cambiar la configuración mientras el bot está corriendo.',
    'ENGINE_NOT_RUNNING': 'El motor de trading no está corriendo.',

    // Validation errors
    'VALIDATION_ERROR': 'Error de validación. Verifica los datos ingresados.',
    'INVALID_PARAMETER': 'Parámetro inválido. Verifica los valores.',

    // MCP errors
    'MCP_ERROR': 'Error en el servidor MCP. Intenta de nuevo.',
    'MCP_TOOL_NOT_FOUND': 'Herramienta no encontrada en el servidor.',

    // Authentication errors
    'UNAUTHORIZED': 'Sesión expirada. Por favor inicia sesión nuevamente.',
    'FORBIDDEN': 'No tienes permisos para realizar esta acción.',
    'NOT_FOUND': 'Recurso no encontrado.',

    // Server errors
    'INTERNAL_SERVER_ERROR': 'Error interno del servidor. Intenta más tarde.',
    'SERVICE_UNAVAILABLE': 'Servicio no disponible. Intenta más tarde.',
  };

  /// Get user-friendly message for error code
  ///
  /// Returns the friendly message if found, otherwise returns the fallback
  /// or a generic message.
  static String getFriendlyMessage(String? code, {String? fallback}) {
    if (code == null) {
      return fallback ?? 'Error desconocido. Intenta de nuevo.';
    }

    return userFriendly[code] ?? fallback ?? 'Error: $code';
  }

  /// Get hint for error code
  ///
  /// Returns a helpful hint for resolving the error
  static String? getHint(String? code) {
    switch (code) {
      case 'TIMEOUT':
      case 'CONNECTION_ERROR':
        return 'Verifica que el servidor esté corriendo en ${_getServerInfo()}';

      case 'INSUFFICIENT_BALANCE':
        return 'Verifica tu balance en la cuenta de futuros';

      case 'BOT_RUNNING':
        return 'Detén el bot primero usando el botón "Stop"';

      case 'INVALID_THRESHOLD':
        return 'Usa un valor entre 50% y 100%';

      case 'INVALID_LEVERAGE':
        return 'Usa un valor entre 1x y 100x';

      case 'POSITION_NOT_FOUND':
        return 'La posición puede haber sido cerrada automáticamente';

      case 'MARKET_CLOSED':
        return 'Espera a que el mercado abra para operar';

      default:
        return null;
    }
  }

  /// Get combined error message with hint
  static String getFullMessage(String? code, {String? fallback}) {
    final message = getFriendlyMessage(code, fallback: fallback);
    final hint = getHint(code);

    if (hint != null) {
      return '$message\n\n💡 $hint';
    }

    return message;
  }

  static String _getServerInfo() {
    return '${Environment.serverIp} (Gateway: ${Environment.gatewayPort}, MCP: ${Environment.mcpPort})';
  }

  /// Check if error is recoverable (user can retry)
  static bool isRecoverable(String? code) {
    const recoverableErrors = {
      'TIMEOUT',
      'RECEIVE_TIMEOUT',
      'NETWORK_ERROR',
      'EMPTY_RESPONSE',
      'NO_RESULT',
      'ORDER_FAILED',
      'MCP_ERROR',
    };

    return code != null && recoverableErrors.contains(code);
  }

  /// Check if error requires user action
  static bool requiresUserAction(String? code) {
    const actionRequiredErrors = {
      'INSUFFICIENT_BALANCE',
      'BOT_RUNNING',
      'INVALID_THRESHOLD',
      'INVALID_LEVERAGE',
      'INVALID_TRADE_SIZE',
      'VALIDATION_ERROR',
      'INVALID_PARAMETER',
      'UNAUTHORIZED',
      'FORBIDDEN',
    };

    return code != null && actionRequiredErrors.contains(code);
  }

  /// Get suggested action for error
  static String? getSuggestedAction(String? code) {
    switch (code) {
      case 'TIMEOUT':
      case 'NETWORK_ERROR':
        return 'Reintentar';

      case 'INSUFFICIENT_BALANCE':
        return 'Ver Balance';

      case 'BOT_RUNNING':
        return 'Detener Bot';

      case 'UNAUTHORIZED':
        return 'Iniciar Sesión';

      case 'POSITION_NOT_FOUND':
        return 'Actualizar Posiciones';

      default:
        return isRecoverable(code) ? 'Reintentar' : null;
    }
  }
}
