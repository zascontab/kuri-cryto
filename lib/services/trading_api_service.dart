import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../config/api_config.dart';
import 'api_exception.dart';

/// Cliente unificado para la Trading API
///
/// Centraliza la configuración de Dio y proporciona métodos
/// helper para todas las peticiones HTTP
class TradingApiService {
  late final Dio _dio;

  TradingApiService() {
    _dio = _createDio();
  }

  /// Crea y configura la instancia de Dio
  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: ApiConfig.defaultHeaders,
      ),
    );

    // Agregar interceptors
    if (ApiConfig.enableHttpLogs) {
      dio.interceptors.add(_createLoggingInterceptor());
    }

    dio.interceptors.add(_createRetryInterceptor());

    return dio;
  }

  /// Crea interceptor para logging
  Interceptor _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        developer.log(
          '→ ${options.method} ${options.uri}',
          name: 'TradingApiService',
        );
        if (ApiConfig.logRequestBody && options.data != null) {
          developer.log(
            'Request body: ${options.data}',
            name: 'TradingApiService',
          );
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        developer.log(
          '← ${response.statusCode} ${response.requestOptions.uri}',
          name: 'TradingApiService',
        );
        if (ApiConfig.logResponseBody && response.data != null) {
          developer.log(
            'Response body: ${response.data}',
            name: 'TradingApiService',
          );
        }
        handler.next(response);
      },
      onError: (error, handler) {
        developer.log(
          '✗ ${error.requestOptions.method} ${error.requestOptions.uri}',
          name: 'TradingApiService',
          error: error,
        );
        handler.next(error);
      },
    );
  }

  /// Crea interceptor para retry con exponential backoff
  Interceptor _createRetryInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (_shouldRetry(error)) {
          final retryCount =
              error.requestOptions.extra['retryCount'] as int? ?? 0;

          if (retryCount < ApiConfig.maxRetries) {
            developer.log(
              'Retrying request (attempt ${retryCount + 1}/${ApiConfig.maxRetries})',
              name: 'TradingApiService',
            );

            // Calcular delay con exponential backoff
            final delay = Duration(
              milliseconds: ApiConfig.getRetryDelay(retryCount),
            );
            await Future.delayed(delay);

            // Incrementar contador de reintentos
            error.requestOptions.extra['retryCount'] = retryCount + 1;

            // Reintentar la petición
            try {
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
        }
        handler.next(error);
      },
    );
  }

  /// Verifica si se debe reintentar la petición
  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500);
  }

  /// Obtiene la instancia de Dio configurada
  Dio get dio => _dio;

  /// Realiza una petición GET
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Realiza una petición POST
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Realiza una petición PUT
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Realiza una petición DELETE
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Maneja errores de Dio y los convierte a ApiException
  ApiException _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      String message = 'Unknown error';

      if (data is Map<String, dynamic>) {
        message = data['error'] ?? data['message'] ?? message;
      } else if (data is String) {
        message = data;
      }

      return ApiException(
        message: message,
        details: data is Map<String, dynamic> ? data['details'] : null,
        statusCode: e.response!.statusCode,
      );
    }

    // Errores de red
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        message: 'Connection timeout. Please check your internet connection.',
        statusCode: null,
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'Cannot connect to server. Please try again later.',
        statusCode: null,
      );
    }

    if (e.type == DioExceptionType.cancel) {
      return ApiException(
        message: 'Request cancelled',
        statusCode: null,
      );
    }

    return ApiException(
      message: 'Network error: ${e.message}',
      statusCode: null,
    );
  }
}
