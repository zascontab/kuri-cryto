import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../services/api_exception.dart';

/// Manejador centralizado de errores
///
/// Este archivo proporciona funciones para manejar errores de forma centralizada,
/// mostrar mensajes amigables al usuario y registrar errores para debugging.
///
/// Ejemplos de uso:
/// ```dart
/// try {
///   await apiCall();
/// } catch (e, stackTrace) {
///   handleApiError(e);
///   showErrorSnackbar(context, e);
///   logError(e, stackTrace);
/// }
/// ```

// ============================================================================
// Manejo de Errores de API
// ============================================================================

/// Maneja errores de la API de forma centralizada
///
/// [error]: Error a manejar
/// [onError]: Callback opcional para manejar el error de forma personalizada
///
/// Ejemplo:
/// ```dart
/// try {
///   await api.getData();
/// } catch (e) {
///   handleApiError(e, onError: (message) {
///     print('Error: $message');
///   });
/// }
/// ```
void handleApiError(
  dynamic error, {
  void Function(String message)? onError,
}) {
  final errorMessage = getErrorMessage(error);

  // Logging
  developer.log(
    'API Error: $errorMessage',
    name: 'ErrorHandler',
    error: error,
  );

  // Callback personalizado
  if (onError != null) {
    onError(errorMessage);
  }
}

/// Obtiene un mensaje de error amigable para el usuario
///
/// [error]: Error del cual extraer el mensaje
///
/// Retorna un mensaje legible para mostrar al usuario
///
/// Ejemplo:
/// ```dart
/// final message = getErrorMessage(error);
/// print(message); // "Connection timeout. Please try again."
/// ```
String getErrorMessage(dynamic error) {
  // Errores de API personalizados
  if (error is ApiException) {
    return _getApiExceptionMessage(error);
  }

  // Errores de Dio
  if (error is DioException) {
    return _getDioExceptionMessage(error);
  }

  // Errores de formato
  if (error is FormatException) {
    return 'Invalid data format: ${error.message}';
  }

  // Errores de tipo
  if (error is TypeError) {
    return 'Data type error. Please contact support.';
  }

  // Errores genéricos
  if (error is Exception) {
    return error.toString().replaceAll('Exception: ', '');
  }

  // Errores desconocidos
  return error?.toString() ?? 'An unexpected error occurred';
}

/// Obtiene mensaje para excepciones de API personalizadas
String _getApiExceptionMessage(ApiException exception) {
  if (exception is UnauthorizedException) {
    return 'Session expired. Please login again.';
  }

  if (exception is ForbiddenException) {
    return 'You do not have permission to perform this action.';
  }

  if (exception is NotFoundException) {
    return 'Resource not found.';
  }

  if (exception is PositionNotFoundException) {
    final posId = exception.positionId;
    return posId != null
        ? 'Position $posId not found.'
        : 'Position not found.';
  }

  if (exception is StrategyNotFoundException) {
    final strategyName = exception.strategyName;
    return strategyName != null
        ? 'Strategy "$strategyName" not found.'
        : 'Strategy not found.';
  }

  if (exception is RateLimitException) {
    final retryAfter = exception.retryAfter;
    return retryAfter != null
        ? 'Too many requests. Please try again in $retryAfter seconds.'
        : 'Too many requests. Please wait a moment.';
  }

  if (exception is InsufficientBalanceException) {
    final required = exception.required;
    final available = exception.available;

    if (required != null && available != null) {
      return 'Insufficient balance. Required: \$${required.toStringAsFixed(2)}, Available: \$${available.toStringAsFixed(2)}';
    }
    return 'Insufficient balance to complete this operation.';
  }

  if (exception is RiskLimitExceededException) {
    final current = exception.currentValue;
    final max = exception.maxValue;

    if (current != null && max != null) {
      return 'Risk limit exceeded. Current: ${current.toStringAsFixed(2)}%, Max: ${max.toStringAsFixed(2)}%';
    }
    return 'Risk limit exceeded. Cannot open new positions.';
  }

  if (exception is KillSwitchActiveException) {
    final reason = exception.reason;
    return reason != null
        ? 'Trading is currently disabled. Reason: $reason'
        : 'Trading is currently disabled.';
  }

  if (exception is EngineNotRunningException) {
    return 'Trading engine is not running. Please contact support.';
  }

  if (exception is OrderExecutionException) {
    final orderId = exception.orderId;
    return orderId != null
        ? 'Failed to execute order $orderId.'
        : 'Failed to execute order.';
  }

  if (exception is MarketClosedException) {
    final market = exception.market;
    return market != null
        ? 'Market $market is currently closed.'
        : 'Market is currently closed.';
  }

  if (exception is ValidationException) {
    final fieldErrors = exception.fieldErrors;

    if (fieldErrors != null && fieldErrors.isNotEmpty) {
      // Mostrar el primer error de campo
      final firstField = fieldErrors.keys.first;
      final firstError = fieldErrors[firstField]!.first;
      return '$firstField: $firstError';
    }

    return 'Validation error. Please check your input.';
  }

  // Mensaje genérico de API Exception
  return exception.message;
}

/// Obtiene mensaje para excepciones de Dio
String _getDioExceptionMessage(DioException exception) {
  switch (exception.type) {
    case DioExceptionType.connectionTimeout:
      return 'Connection timeout. Please check your internet connection.';

    case DioExceptionType.sendTimeout:
      return 'Request timeout. Please try again.';

    case DioExceptionType.receiveTimeout:
      return 'Server response timeout. Please try again.';

    case DioExceptionType.badCertificate:
      return 'Security certificate error. Please contact support.';

    case DioExceptionType.badResponse:
      final statusCode = exception.response?.statusCode;
      final data = exception.response?.data;

      if (statusCode != null) {
        // Mensajes específicos por código de estado
        switch (statusCode) {
          case 400:
            return data is Map && data['message'] != null
                ? data['message']
                : 'Invalid request. Please check your input.';

          case 401:
            return 'Unauthorized. Please login again.';

          case 403:
            return 'Access forbidden. You do not have permission.';

          case 404:
            return 'Resource not found.';

          case 409:
            return 'Conflict. The resource already exists.';

          case 422:
            return 'Validation error. Please check your input.';

          case 429:
            return 'Too many requests. Please wait a moment.';

          case 500:
            return 'Server error. Please try again later.';

          case 502:
            return 'Bad gateway. Please try again later.';

          case 503:
            return 'Service unavailable. Please try again later.';

          case 504:
            return 'Gateway timeout. Please try again later.';

          default:
            return 'Server error ($statusCode). Please try again.';
        }
      }
      return 'Server error. Please try again.';

    case DioExceptionType.cancel:
      return 'Request was cancelled.';

    case DioExceptionType.connectionError:
      return 'No internet connection. Please check your network.';

    case DioExceptionType.unknown:
    default:
      return 'Network error. Please check your connection.';
  }
}

// ============================================================================
// UI Helpers
// ============================================================================

/// Muestra un SnackBar con el mensaje de error
///
/// [context]: BuildContext para mostrar el SnackBar
/// [error]: Error a mostrar
/// [duration]: Duración del SnackBar (por defecto 4 segundos)
/// [action]: Acción opcional (botón) en el SnackBar
///
/// Ejemplo:
/// ```dart
/// try {
///   await api.getData();
/// } catch (e) {
///   showErrorSnackbar(
///     context,
///     e,
///     action: SnackBarAction(
///       label: 'Retry',
///       onPressed: () => loadData(),
///     ),
///   );
/// }
/// ```
void showErrorSnackbar(
  BuildContext context,
  dynamic error, {
  Duration duration = const Duration(seconds: 4),
  SnackBarAction? action,
}) {
  final message = getErrorMessage(error);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message),
          ),
        ],
      ),
      backgroundColor: Colors.red[700],
      duration: duration,
      action: action,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

/// Muestra un SnackBar de éxito
///
/// [context]: BuildContext para mostrar el SnackBar
/// [message]: Mensaje a mostrar
/// [duration]: Duración del SnackBar (por defecto 3 segundos)
///
/// Ejemplo:
/// ```dart
/// showSuccessSnackbar(context, 'Position closed successfully!');
/// ```
void showSuccessSnackbar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message),
          ),
        ],
      ),
      backgroundColor: Colors.green[700],
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

/// Muestra un SnackBar de información
///
/// [context]: BuildContext para mostrar el SnackBar
/// [message]: Mensaje a mostrar
/// [duration]: Duración del SnackBar (por defecto 3 segundos)
///
/// Ejemplo:
/// ```dart
/// showInfoSnackbar(context, 'Loading data...');
/// ```
void showInfoSnackbar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message),
          ),
        ],
      ),
      backgroundColor: Colors.blue[700],
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

/// Muestra un SnackBar de advertencia
///
/// [context]: BuildContext para mostrar el SnackBar
/// [message]: Mensaje a mostrar
/// [duration]: Duración del SnackBar (por defecto 4 segundos)
///
/// Ejemplo:
/// ```dart
/// showWarningSnackbar(context, 'Risk limit is close to maximum!');
/// ```
void showWarningSnackbar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 4),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.warning_outlined,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message),
          ),
        ],
      ),
      backgroundColor: Colors.orange[700],
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

/// Muestra un diálogo de error
///
/// [context]: BuildContext para mostrar el diálogo
/// [error]: Error a mostrar
/// [title]: Título del diálogo (por defecto 'Error')
/// [onRetry]: Callback opcional para reintentar la acción
///
/// Ejemplo:
/// ```dart
/// showErrorDialog(
///   context,
///   error,
///   title: 'Failed to Load Data',
///   onRetry: () => loadData(),
/// );
/// ```
Future<void> showErrorDialog(
  BuildContext context,
  dynamic error, {
  String title = 'Error',
  VoidCallback? onRetry,
}) async {
  final message = getErrorMessage(error);

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry();
            },
            child: const Text('Retry'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}

// ============================================================================
// Logging
// ============================================================================

/// Registra un error en los logs
///
/// [error]: Error a registrar
/// [stackTrace]: Stack trace del error (opcional)
/// [name]: Nombre del logger (por defecto 'AppError')
/// [context]: Contexto adicional del error (opcional)
///
/// Ejemplo:
/// ```dart
/// try {
///   await riskyOperation();
/// } catch (e, stackTrace) {
///   logError(
///     e,
///     stackTrace,
///     name: 'DataLoader',
///     context: {'userId': '123', 'action': 'loadData'},
///   );
/// }
/// ```
void logError(
  dynamic error, [
  StackTrace? stackTrace,
  String name = 'AppError',
  Map<String, dynamic>? context,
]) {
  final errorMessage = getErrorMessage(error);

  // Log básico
  developer.log(
    errorMessage,
    name: name,
    error: error,
    stackTrace: stackTrace,
  );

  // Log de contexto adicional si existe
  if (context != null && context.isNotEmpty) {
    developer.log(
      'Error Context: $context',
      name: name,
    );
  }

  // Aquí puedes agregar integración con servicios de logging como:
  // - Firebase Crashlytics
  // - Sentry
  // - Bugsnag
  // etc.
}

/// Registra información general
///
/// [message]: Mensaje a registrar
/// [name]: Nombre del logger (por defecto 'AppInfo')
///
/// Ejemplo:
/// ```dart
/// logInfo('User logged in successfully', name: 'Auth');
/// ```
void logInfo(String message, {String name = 'AppInfo'}) {
  developer.log(message, name: name);
}

/// Registra una advertencia
///
/// [message]: Mensaje a registrar
/// [name]: Nombre del logger (por defecto 'AppWarning')
///
/// Ejemplo:
/// ```dart
/// logWarning('API response time is high', name: 'Performance');
/// ```
void logWarning(String message, {String name = 'AppWarning'}) {
  developer.log(
    message,
    name: name,
    level: 900, // Warning level
  );
}

/// Registra debug info
///
/// [message]: Mensaje a registrar
/// [name]: Nombre del logger (por defecto 'AppDebug')
///
/// Ejemplo:
/// ```dart
/// logDebug('Current state: ${state.toString()}', name: 'StateManager');
/// ```
void logDebug(String message, {String name = 'AppDebug'}) {
  developer.log(
    message,
    name: name,
    level: 500, // Debug level
  );
}

// ============================================================================
// Error Recovery
// ============================================================================

/// Ejecuta una función con manejo automático de errores
///
/// [fn]: Función a ejecutar
/// [onError]: Callback cuando ocurre un error
/// [onSuccess]: Callback cuando la función se ejecuta exitosamente
/// [showSnackbar]: Si mostrar SnackBar en caso de error (requiere context)
/// [context]: BuildContext para mostrar SnackBar (opcional)
///
/// Ejemplo:
/// ```dart
/// await withErrorHandling(
///   () async => await api.loadData(),
///   onError: () => print('Error loading data'),
///   onSuccess: (data) => print('Data loaded: $data'),
///   showSnackbar: true,
///   context: context,
/// );
/// ```
Future<T?> withErrorHandling<T>(
  Future<T> Function() fn, {
  void Function()? onError,
  void Function(T result)? onSuccess,
  bool showSnackbar = false,
  BuildContext? context,
}) async {
  try {
    final result = await fn();
    onSuccess?.call(result);
    return result;
  } catch (e, stackTrace) {
    logError(e, stackTrace);

    if (showSnackbar && context != null) {
      showErrorSnackbar(context, e);
    }

    onError?.call();
    return null;
  }
}

/// Ejecuta una función con reintentos automáticos
///
/// [fn]: Función a ejecutar
/// [maxRetries]: Número máximo de reintentos (por defecto 3)
/// [delay]: Delay entre reintentos (por defecto 1 segundo)
/// [onRetry]: Callback cuando se reintenta
///
/// Ejemplo:
/// ```dart
/// final data = await withRetry(
///   () => api.loadData(),
///   maxRetries: 3,
///   delay: Duration(seconds: 2),
///   onRetry: (attempt) => print('Retry attempt $attempt'),
/// );
/// ```
Future<T> withRetry<T>(
  Future<T> Function() fn, {
  int maxRetries = 3,
  Duration delay = const Duration(seconds: 1),
  void Function(int attempt)? onRetry,
}) async {
  var lastError;

  for (var attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (e) {
      lastError = e;

      if (attempt < maxRetries) {
        onRetry?.call(attempt + 1);
        await Future.delayed(delay);
      }
    }
  }

  throw lastError;
}
