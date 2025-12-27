import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../config/api_config.dart';
import '../models/bot_status.dart';
import '../models/bot_config.dart';
import '../models/positions_response.dart';
import '../models/bot_action_response.dart';
import '../exceptions/trading_api_exceptions.dart';
import 'logging_service.dart';
import 'cache_service.dart';

/// Servicio para gestionar el bot de trading con IA
///
/// Endpoints:
/// - GET /api/v1/ai-bot/status - Obtener estado del bot
/// - POST /api/v1/ai-bot/start - Iniciar bot
/// - POST /api/v1/ai-bot/stop - Detener bot
/// - GET /api/v1/ai-bot/config - Obtener configuración
/// - POST /api/v1/ai-bot/config - Actualizar configuración
/// - GET /api/v1/ai-bot/positions - Obtener posiciones
class AIBotService {
  final Dio _dio;

  AIBotService(this._dio);

  /// Obtiene el estado actual del bot
  ///
  /// Returns: [BotStatus] con información del estado
  /// Throws: [TradingApiException] si hay error
  ///
  /// Caching: Results are cached for 5 seconds to improve performance
  Future<BotStatus> getStatus({bool useCache = true}) async {
    // Check cache first
    if (useCache) {
      final cached =
          CacheService.instance.get<Map<String, dynamic>>(CacheKeys.botStatus);
      if (cached != null) {
        try {
          LoggingService.instance.debug(
            'Returning cached bot status',
            tag: 'AIBotService',
          );
          return BotStatus.fromJson(cached);
        } catch (e) {
          // If cached data is corrupted, remove it and continue
          LoggingService.instance.warning(
            'Cached bot status corrupted, removing from cache',
            tag: 'AIBotService',
          );
          await CacheService.instance.remove(CacheKeys.botStatus);
        }
      }
    }

    try {
      LoggingService.instance.info(
        'Fetching bot status',
        tag: 'AIBotService',
      );

      final response = await _dio.get(ApiConfig.aiBotStatusUrl);

      LoggingService.instance.info(
        'Successfully fetched bot status',
        tag: 'AIBotService',
        context: {'status': response.data.toString()},
      );

      try {
        final botStatus =
            BotStatus.fromJson(response.data as Map<String, dynamic>);

        // Cache the result for 5 seconds
        if (useCache) {
          await CacheService.instance.set(
            CacheKeys.botStatus,
            response.data as Map<String, dynamic>,
            ttl: const Duration(seconds: 5),
          );

          LoggingService.instance.debug(
            'Bot status cached',
            tag: 'AIBotService',
          );
        }

        return botStatus;
      } catch (parseError, stackTrace) {
        developer.log(
          'Failed to parse bot status response',
          name: 'AIBotService',
          error: parseError,
          stackTrace: stackTrace,
        );
        throw ParsingException.model(
          'BotStatus',
          parseError,
          data: response.data,
        );
      }
    } on DioException catch (e) {
      developer.log(
        'Error fetching bot status: ${e.message}',
        name: 'AIBotService',
        error: e,
      );
      throw _handleDioError(e);
    } on TradingApiException {
      rethrow;
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error fetching bot status',
        name: 'AIBotService',
        error: e,
        stackTrace: stackTrace,
      );
      throw BotException(
        'Failed to get bot status',
        operation: 'get_status',
        details: e.toString(),
        originalError: e,
      );
    }
  }

  /// Inicia el bot de trading
  ///
  /// Returns: [BotStartResponse] con resultado de la operación
  /// Throws: [ApiException] si hay error
  Future<BotStartResponse> start() async {
    try {
      developer.log(
        'Starting bot',
        name: 'AIBotService',
      );

      final response = await _dio.post(ApiConfig.aiBotStartUrl);

      developer.log(
        'Bot started successfully',
        name: 'AIBotService',
      );

      final result =
          BotStartResponse.fromJson(response.data as Map<String, dynamic>);

      // Invalidate bot status cache since state changed
      await CacheService.instance.remove(CacheKeys.botStatus);

      return result;
    } on DioException catch (e) {
      LoggingService.instance.error(
        'Error starting bot',
        tag: 'AIBotService',
        error: e,
      );
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Unexpected error starting bot',
        tag: 'AIBotService',
        error: e,
        stackTrace: stackTrace,
      );
      throw BotException(
        'Unexpected error starting bot: ${e.toString()}',
        operation: 'start',
        originalError: e,
      );
    }
  }

  /// Detiene el bot de trading
  ///
  /// Returns: [BotStopResponse] con resultado de la operación
  /// Throws: [ApiException] si hay error
  Future<BotStopResponse> stop() async {
    try {
      developer.log(
        'Stopping bot',
        name: 'AIBotService',
      );

      final response = await _dio.post(ApiConfig.aiBotStopUrl);

      developer.log(
        'Bot stopped successfully',
        name: 'AIBotService',
      );

      final result =
          BotStopResponse.fromJson(response.data as Map<String, dynamic>);

      // Invalidate bot status cache since state changed
      await CacheService.instance.remove(CacheKeys.botStatus);

      return result;
    } on DioException catch (e) {
      LoggingService.instance.error(
        'Error stopping bot',
        tag: 'AIBotService',
        error: e,
      );
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Unexpected error stopping bot',
        tag: 'AIBotService',
        error: e,
        stackTrace: stackTrace,
      );
      throw BotException(
        'Unexpected error stopping bot: ${e.toString()}',
        operation: 'stop',
        originalError: e,
      );
    }
  }

  /// Obtiene la configuración actual del bot
  ///
  /// Returns: [BotConfig] con la configuración
  /// Throws: [ApiException] si hay error
  Future<BotConfig> getConfig() async {
    try {
      developer.log(
        'Fetching bot config',
        name: 'AIBotService',
      );

      final response = await _dio.get(ApiConfig.aiBotConfigUrl);

      developer.log(
        'Successfully fetched bot config',
        name: 'AIBotService',
      );

      return BotConfig.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      LoggingService.instance.error(
        'Error fetching bot config',
        tag: 'AIBotService',
        error: e,
      );
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Unexpected error fetching bot config',
        tag: 'AIBotService',
        error: e,
        stackTrace: stackTrace,
      );
      throw BotException(
        'Unexpected error fetching config: ${e.toString()}',
        operation: 'get_config',
        originalError: e,
      );
    }
  }

  /// Actualiza la configuración del bot
  ///
  /// [config]: Nueva configuración a aplicar
  /// Returns: [BotConfig] con la configuración actualizada
  /// Throws:
  /// - [ValidationException] si la configuración es inválida
  /// - [BotException] si hay error específico del bot
  /// - [TradingApiException] si hay error en la API
  Future<BotConfig> updateConfig(BotConfig config) async {
    // Validar configuración antes de enviar
    final errors = config.validate();
    if (errors.isNotEmpty) {
      throw BotException.invalidConfig('config', errors.join(', '));
    }

    try {
      developer.log(
        'Updating bot config',
        name: 'AIBotService',
      );

      final response = await _dio.post(
        ApiConfig.aiBotConfigUrl,
        data: config.toJson(),
      );

      developer.log(
        'Bot config updated successfully',
        name: 'AIBotService',
      );

      return BotConfig.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      LoggingService.instance.error(
        'Error updating bot config',
        tag: 'AIBotService',
        error: e,
      );
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Unexpected error updating bot config',
        tag: 'AIBotService',
        error: e,
        stackTrace: stackTrace,
      );
      throw BotException(
        'Unexpected error updating config: ${e.toString()}',
        operation: 'update_config',
        originalError: e,
      );
    }
  }

  /// Obtiene las posiciones abiertas del bot
  ///
  /// Returns: [PositionsResponse] con lista de posiciones
  /// Throws: [ApiException] si hay error
  Future<PositionsResponse> getPositions() async {
    try {
      developer.log(
        'Fetching bot positions',
        name: 'AIBotService',
      );

      final response = await _dio.get(ApiConfig.aiBotPositionsUrl);

      developer.log(
        'Successfully fetched bot positions',
        name: 'AIBotService',
      );

      return PositionsResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      LoggingService.instance.error(
        'Error fetching bot positions',
        tag: 'AIBotService',
        error: e,
      );
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Unexpected error fetching bot positions',
        tag: 'AIBotService',
        error: e,
        stackTrace: stackTrace,
      );
      throw BotException(
        'Unexpected error fetching positions: ${e.toString()}',
        operation: 'get_positions',
        originalError: e,
      );
    }
  }

  /// Maneja errores de Dio y los convierte a nuestras excepciones personalizadas
  TradingApiException _handleDioError(DioException e) {
    developer.log(
      'Handling DioException: ${e.type} - ${e.message}',
      name: 'AIBotService',
    );

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return TimeoutException.connection(const Duration(seconds: 30));

      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException.request(const Duration(seconds: 30));

      case DioExceptionType.connectionError:
        return NetworkException.fromDioError(e);

      case DioExceptionType.badResponse:
        if (e.response != null) {
          final statusCode = e.response!.statusCode!;
          final responseData = e.response!.data;

          // Handle bot-specific errors
          if (responseData is Map<String, dynamic>) {
            final errorMessage = responseData['error'] ??
                responseData['message'] ??
                'Bot operation failed';

            // Check for bot-specific error conditions
            if (errorMessage.toLowerCase().contains('not running') ||
                errorMessage.toLowerCase().contains('stopped')) {
              return BotException.notRunning();
            }

            if (errorMessage.toLowerCase().contains('insufficient funds')) {
              // Try to extract amounts if available
              return BotException.insufficientFunds(0.0, 0.0);
            }

            return BotException(
              errorMessage,
              operation: 'api_request',
              details: responseData['details']?.toString(),
              originalError: e,
            );
          }

          return ServerException.fromResponse(
              statusCode, responseData?.toString());
        }
        return ServerException('Bad response from server', originalError: e);

      case DioExceptionType.cancel:
        return _UnknownException(
          'Request was cancelled',
          originalError: e,
        );

      case DioExceptionType.unknown:
      default:
        return ExceptionFactory.fromDioError(e);
    }
  }
}

/// Internal exception for unknown errors
class _UnknownException extends TradingApiException {
  const _UnknownException(super.message, {super.originalError});
}
