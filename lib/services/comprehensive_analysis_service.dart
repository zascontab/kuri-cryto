import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../config/api_config.dart';
import '../models/comprehensive_analysis.dart';
import '../models/market_type.dart';
import '../exceptions/trading_api_exceptions.dart';
import 'logging_service.dart';
import 'cache_service.dart';
import '../utils/retry_helper.dart';

/// Servicio para obtener análisis comprehensivo de mercado con AI
///
/// ✅ NO REQUIERE AUTENTICACIÓN
/// Todos los endpoints del MCP Server son públicos y no necesitan headers de auth.
///
/// Features:
/// - Análisis técnico completo
/// - Multi-timeframe analysis
/// - AI-enhanced analysis (LLM + Sentiment)
/// - Market type specific data
/// - Robust error handling
/// - Automatic retry logic
class ComprehensiveAnalysisService {
  final Dio _dio;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);

  ComprehensiveAnalysisService(this._dio);

  /// Obtiene análisis comprehensivo de un símbolo
  ///
  /// Incluye:
  /// - Precio actual y estadísticas 24h
  /// - Análisis técnico (RSI, MACD, Bollinger, EMAs)
  /// - Análisis multi-timeframe (1m, 5m, 15m, 1h)
  /// - Movimiento reciente (últimas 10 velas)
  /// - Niveles clave (soporte/resistencia)
  /// - Recomendación de trading (BUY/SELL/WAIT)
  /// - Escenarios de mercado posibles
  /// - Evaluación de riesgo
  ///
  /// NEW: AI-enhanced analysis (v5.0)
  /// - [enableLLM]: Habilita análisis con LLM (Gemini/GPT/Claude)
  /// - [enableSentiment]: Habilita análisis de sentimiento
  ///
  /// Caching: Results are cached for 30 seconds to improve performance
  ///
  /// Throws:
  /// - [TradingApiException] si hay error en la API
  /// - [ValidationException] si los parámetros son inválidos
  /// - [NetworkException] si hay problemas de conectividad
  /// - [ServerException] si el servidor devuelve error
  /// - [TimeoutException] si la operación tarda demasiado
  /// - [ParsingException] si no se puede parsear la respuesta
  Future<ComprehensiveAnalysis> getAnalysis({
    required String symbol,
    String exchange = 'kucoin',
    MarketType? marketType,
    bool enableLLM = true,
    bool enableSentiment = true,
    int retries = 0,
    bool useCache = true,
  }) async {
    // Validación de parámetros
    if (symbol.isEmpty) {
      throw ValidationException.required('symbol');
    }
    if (exchange.isEmpty) {
      throw ValidationException.required('exchange');
    }

    // Validar formato del símbolo
    if (!RegExp(r'^[A-Z0-9]+-[A-Z0-9]+$').hasMatch(symbol.toUpperCase())) {
      throw ValidationException.invalidSymbol(symbol);
    }

    // Check cache first (if enabled and not retrying)
    if (useCache && retries == 0) {
      final cacheKey = CacheKeys.comprehensiveAnalysisKey(
        symbol,
        marketType: marketType?.value,
      );
      final cached = CacheService.instance.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        try {
          LoggingService.instance.debug(
            'Returning cached analysis for $symbol',
            tag: 'ComprehensiveAnalysisService',
            context: {'symbol': symbol, 'cache_key': cacheKey},
          );
          return ComprehensiveAnalysis.fromJson(cached);
        } catch (e) {
          // If cached data is corrupted, remove it and continue
          LoggingService.instance.warning(
            'Cached data corrupted, removing from cache',
            tag: 'ComprehensiveAnalysisService',
            context: {'symbol': symbol, 'cache_key': cacheKey},
          );
          await CacheService.instance.remove(cacheKey);
        }
      }
    }

    try {
      LoggingService.instance.info(
        'Fetching comprehensive analysis for $symbol on $exchange',
        tag: 'ComprehensiveAnalysisService',
        context: {
          'symbol': symbol,
          'exchange': exchange,
          'market_type': marketType?.value,
          'enable_llm': enableLLM,
          'enable_sentiment': enableSentiment,
        },
      );

      final data = <String, dynamic>{
        'symbol': symbol,
        'exchange': exchange,
        'enable_llm': enableLLM,
        'enable_sentiment': enableSentiment,
      };

      // Add market_type if specified
      if (marketType != null) {
        data['market_type'] = marketType.value;
        developer.log(
          'Market type: ${marketType.value}',
          name: 'ComprehensiveAnalysisService',
        );
      }

      final response = await _dio.post(
        ApiConfig.comprehensiveAnalysisUrl,
        data: data,
      );

      LoggingService.instance.info(
        'Successfully fetched analysis for $symbol',
        tag: 'ComprehensiveAnalysisService',
        context: {
          'symbol': symbol,
          'response_size': response.data.toString().length
        },
      );

      try {
        final analysis = ComprehensiveAnalysis.fromJson(
          response.data as Map<String, dynamic>,
        );

        // Cache the result for 30 seconds
        if (useCache) {
          final cacheKey = CacheKeys.comprehensiveAnalysisKey(
            symbol,
            marketType: marketType?.value,
          );
          await CacheService.instance.set(
            cacheKey,
            response.data as Map<String, dynamic>,
            ttl: const Duration(seconds: 30),
          );

          LoggingService.instance.debug(
            'Analysis cached for $symbol',
            tag: 'ComprehensiveAnalysisService',
            context: {'symbol': symbol, 'cache_key': cacheKey},
          );
        }

        return analysis;
      } catch (parseError, stackTrace) {
        LoggingService.instance.error(
          'Failed to parse response for $symbol',
          tag: 'ComprehensiveAnalysisService',
          context: {
            'symbol': symbol,
            'response_data': response.data.toString(),
          },
          error: parseError,
          stackTrace: stackTrace,
        );
        throw ParsingException.model(
          'ComprehensiveAnalysis',
          parseError,
          data: response.data,
        );
      }
    } on DioException catch (e) {
      LoggingService.instance.error(
        'DioException fetching analysis for $symbol',
        tag: 'ComprehensiveAnalysisService',
        context: {
          'symbol': symbol,
          'exchange': exchange,
          'error_type': e.type.toString(),
          'status_code': e.response?.statusCode,
          'retry_attempt': retries,
        },
        error: e,
      );

      // Retry logic para errores de red
      if (retries < _maxRetries && _shouldRetry(e)) {
        LoggingService.instance.warning(
          'Retrying analysis request for $symbol (attempt ${retries + 1}/$_maxRetries)',
          tag: 'ComprehensiveAnalysisService',
          context: {
            'symbol': symbol,
            'retry_attempt': retries + 1,
            'max_retries': _maxRetries,
          },
        );
        await Future.delayed(_retryDelay * (retries + 1));
        return getAnalysis(
          symbol: symbol,
          exchange: exchange,
          marketType: marketType,
          enableLLM: enableLLM,
          enableSentiment: enableSentiment,
          retries: retries + 1,
        );
      }

      throw _handleDioError(e);
    } on TradingApiException {
      // Re-throw our custom exceptions
      rethrow;
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Unexpected error fetching analysis for $symbol',
        tag: 'ComprehensiveAnalysisService',
        context: {
          'symbol': symbol,
          'exchange': exchange,
          'error_type': e.runtimeType.toString(),
        },
        error: e,
        stackTrace: stackTrace,
      );
      throw _UnknownException(
        'Unexpected error occurred: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Obtiene análisis para múltiples símbolos
  ///
  /// Continúa con el siguiente símbolo si hay error en alguno
  Future<List<ComprehensiveAnalysis>> getMultipleAnalyses({
    required List<String> symbols,
    String exchange = 'kucoin',
    MarketType? marketType,
    bool enableLLM = true,
    bool enableSentiment = true,
  }) async {
    if (symbols.isEmpty) {
      return [];
    }

    LoggingService.instance.info(
      'Fetching analysis for ${symbols.length} symbols',
      tag: 'ComprehensiveAnalysisService',
      context: {
        'symbols_count': symbols.length,
        'symbols': symbols,
        'exchange': exchange,
        'market_type': marketType?.value,
      },
    );

    final results = <ComprehensiveAnalysis>[];
    final errors = <String, String>{};

    for (final symbol in symbols) {
      try {
        final analysis = await RetryHelper.execute(
          () => getAnalysis(
            symbol: symbol,
            exchange: exchange,
            marketType: marketType,
            enableLLM: enableLLM,
            enableSentiment: enableSentiment,
          ),
          maxRetries: 2,
          initialDelay: const Duration(milliseconds: 500),
        );
        results.add(analysis);
      } catch (e) {
        LoggingService.instance.log(
          'Failed to fetch analysis for $symbol, skipping',
          level: LogLevel.warning,
          tag: 'ComprehensiveAnalysisService',
          context: {
            'symbol': symbol,
            'error': e.toString(),
          },
          error: e,
        );
        errors[symbol] = e.toString();
        // Continuar con el siguiente símbolo si hay error
        continue;
      }
    }

    LoggingService.instance.info(
      'Completed batch analysis',
      tag: 'ComprehensiveAnalysisService',
      context: {
        'successful': results.length,
        'total': symbols.length,
        'failed': errors.length,
        'errors': errors,
      },
    );

    return results;
  }

  /// Verifica si se debe reintentar la petición
  bool _shouldRetry(DioException e) {
    // Reintentar solo en errores de red, timeouts o errores del servidor (5xx)
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        (e.response?.statusCode != null && e.response!.statusCode! >= 500);
  }

  /// Convierte DioException a nuestras excepciones personalizadas
  TradingApiException _handleDioError(DioException e) {
    LoggingService.instance.error(
      'Converting DioException to TradingApiException',
      tag: 'ComprehensiveAnalysisService',
      context: {
        'dio_error_type': e.type.toString(),
        'status_code': e.response?.statusCode,
        'request_path': e.requestOptions.path,
        'request_method': e.requestOptions.method,
      },
      error: e,
    );

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return TimeoutException.connection(const Duration(seconds: 30));

      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException.request(const Duration(seconds: 30));

      case DioExceptionType.connectionError:
        if (e.message?.toLowerCase().contains('network') == true) {
          return NetworkException.noConnection();
        }
        return NetworkException.fromDioError(e);

      case DioExceptionType.badResponse:
        if (e.response != null) {
          final statusCode = e.response!.statusCode!;
          final responseData = e.response!.data;

          // Handle rate limiting
          if (statusCode == 429) {
            return RateLimitException.fromHeaders(
              e.response!.headers.map,
            );
          }

          // Handle authentication errors
          if (statusCode == 401 || statusCode == 403) {
            return AuthenticationException.invalidCredentials();
          }

          // Handle server errors
          String message = 'Server error';
          String? details;

          if (responseData is Map<String, dynamic>) {
            message =
                responseData['error'] ?? responseData['message'] ?? message;
            details = responseData['details']?.toString();
          } else if (responseData is String) {
            details = responseData;
          }

          return ServerException(
            message,
            details: details,
            statusCode: statusCode,
            originalError: e,
          );
        }
        return ServerException(
          'Bad response from server',
          originalError: e,
        );

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
