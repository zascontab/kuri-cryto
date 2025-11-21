import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'api_exception.dart';

/// Base API Client using Dio
///
/// Provides a configured Dio instance with:
/// - Automatic retry logic with exponential backoff
/// - Request/response logging
/// - Error handling and transformation
/// - Timeout configuration
class ApiClient {
  late final Dio _dio;
  final String environment;

  ApiClient({this.environment = 'development'}) {
    _dio = Dio(_buildBaseOptions());
    _setupInterceptors();
  }

  /// Build base options for Dio
  BaseOptions _buildBaseOptions() {
    return BaseOptions(
      baseUrl: ApiConfig.getBaseUrl(environment),
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: ApiConfig.defaultHeaders,
      validateStatus: (status) => status != null && status < 500,
    );
  }

  /// Setup Dio interceptors
  void _setupInterceptors() {
    _dio.interceptors.addAll([
      _LoggingInterceptor(),
      _RetryInterceptor(dio: _dio),
      _ErrorInterceptor(),
    ]);
  }

  /// Get the Dio instance
  Dio get dio => _dio;

  /// Generic GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Generic POST request
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Generic PUT request
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Generic DELETE request
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Generic PATCH request
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Set authentication token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear authentication token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Update base URL (useful for switching environments)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  /// Close the client and clean up resources
  void close({bool force = false}) {
    _dio.close(force: force);
  }
}

/// Logging Interceptor
///
/// Logs all requests and responses for debugging purposes
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (ApiConfig.enableLogging) {
      developer.log(
        '┌── Request ────────────────────────────────────────',
        name: 'ApiClient',
      );
      developer.log('│ ${options.method} ${options.uri}', name: 'ApiClient');
      developer.log('│ Headers: ${options.headers}', name: 'ApiClient');

      if (ApiConfig.logRequestBody && options.data != null) {
        developer.log('│ Body: ${options.data}', name: 'ApiClient');
      }

      developer.log(
        '└────────────────────────────────────────────────────',
        name: 'ApiClient',
      );
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (ApiConfig.enableLogging) {
      developer.log(
        '┌── Response ───────────────────────────────────────',
        name: 'ApiClient',
      );
      developer.log(
        '│ ${response.statusCode} ${response.requestOptions.uri}',
        name: 'ApiClient',
      );

      if (ApiConfig.logResponseBody && response.data != null) {
        developer.log('│ Body: ${response.data}', name: 'ApiClient');
      }

      developer.log(
        '└────────────────────────────────────────────────────',
        name: 'ApiClient',
      );
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (ApiConfig.enableLogging) {
      developer.log(
        '┌── Error ──────────────────────────────────────────',
        name: 'ApiClient',
        error: err,
      );
      developer.log('│ ${err.type}', name: 'ApiClient');
      developer.log('│ ${err.message}', name: 'ApiClient');
      if (err.response != null) {
        developer.log(
          '│ Status: ${err.response?.statusCode}',
          name: 'ApiClient',
        );
        developer.log('│ Data: ${err.response?.data}', name: 'ApiClient');
      }
      developer.log(
        '└────────────────────────────────────────────────────',
        name: 'ApiClient',
      );
    }
    super.onError(err, handler);
  }
}

/// Retry Interceptor
///
/// Automatically retries failed requests with exponential backoff
class _RetryInterceptor extends Interceptor {
  final Dio dio;

  _RetryInterceptor({required this.dio});

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;

    // Don't retry if it's a client error (4xx) or if retries are disabled
    if (err.response?.statusCode != null &&
        err.response!.statusCode! >= 400 &&
        err.response!.statusCode! < 500) {
      return handler.next(err);
    }

    // Don't retry if max retries exceeded
    final retriesLeft = options.extra['retries_left'] as int? ?? ApiConfig.maxRetries;
    if (retriesLeft <= 0) {
      return handler.next(err);
    }

    // Calculate delay with exponential backoff
    final attemptNumber = ApiConfig.maxRetries - retriesLeft + 1;
    final delayMs = ApiConfig.retryDelay.inMilliseconds *
        (ApiConfig.retryBackoffMultiplier * attemptNumber);

    developer.log(
      'Retrying request (attempt $attemptNumber/${ApiConfig.maxRetries})...',
      name: 'ApiClient',
    );

    // Wait before retrying
    await Future.delayed(Duration(milliseconds: delayMs.toInt()));

    // Update retries left
    options.extra['retries_left'] = retriesLeft - 1;

    try {
      // Retry the request
      final response = await dio.fetch(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }
}

/// Error Interceptor
///
/// Transforms DioExceptions into custom ApiExceptions
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Transform specific HTTP status codes to custom exceptions
    if (err.response != null) {
      final statusCode = err.response!.statusCode;
      final data = err.response!.data;

      switch (statusCode) {
        case 401:
          return handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              response: err.response,
              type: err.type,
              error: UnauthorizedException(),
            ),
          );

        case 403:
          return handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              response: err.response,
              type: err.type,
              error: ForbiddenException(),
            ),
          );

        case 404:
          // Check if it's a specific resource not found
          if (data is Map<String, dynamic>) {
            final code = data['code'] as String?;
            if (code == 'POSITION_NOT_FOUND') {
              return handler.reject(
                DioException(
                  requestOptions: err.requestOptions,
                  response: err.response,
                  type: err.type,
                  error: PositionNotFoundException(
                    positionId: data['details']?['position_id'],
                  ),
                ),
              );
            } else if (code == 'STRATEGY_NOT_FOUND') {
              return handler.reject(
                DioException(
                  requestOptions: err.requestOptions,
                  response: err.response,
                  type: err.type,
                  error: StrategyNotFoundException(
                    strategyName: data['details']?['strategy_name'],
                  ),
                ),
              );
            }
          }
          return handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              response: err.response,
              type: err.type,
              error: NotFoundException(),
            ),
          );

        case 429:
          final retryAfter = err.response!.headers.value('X-RateLimit-Reset');
          return handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              response: err.response,
              type: err.type,
              error: RateLimitException(
                retryAfter: retryAfter != null ? int.tryParse(retryAfter) : null,
              ),
            ),
          );

        default:
          // Check for trading-specific errors
          if (data is Map<String, dynamic>) {
            final code = data['code'] as String?;

            switch (code) {
              case 'INSUFFICIENT_BALANCE':
                return handler.reject(
                  DioException(
                    requestOptions: err.requestOptions,
                    response: err.response,
                    type: err.type,
                    error: InsufficientBalanceException(
                      required: data['details']?['required']?.toDouble(),
                      available: data['details']?['available']?.toDouble(),
                    ),
                  ),
                );

              case 'RISK_LIMIT_EXCEEDED':
                return handler.reject(
                  DioException(
                    requestOptions: err.requestOptions,
                    response: err.response,
                    type: err.type,
                    error: RiskLimitExceededException(
                      currentValue: data['details']?['current_drawdown']?.toDouble(),
                      maxValue: data['details']?['max_drawdown']?.toDouble(),
                    ),
                  ),
                );

              case 'KILL_SWITCH_ACTIVE':
                return handler.reject(
                  DioException(
                    requestOptions: err.requestOptions,
                    response: err.response,
                    type: err.type,
                    error: KillSwitchActiveException(
                      reason: data['details']?['reason'],
                      activatedAt: data['details']?['activated_at'] != null
                          ? DateTime.parse(data['details']['activated_at'])
                          : null,
                    ),
                  ),
                );

              case 'ENGINE_NOT_RUNNING':
                return handler.reject(
                  DioException(
                    requestOptions: err.requestOptions,
                    response: err.response,
                    type: err.type,
                    error: EngineNotRunningException(),
                  ),
                );

              case 'ORDER_FAILED':
                return handler.reject(
                  DioException(
                    requestOptions: err.requestOptions,
                    response: err.response,
                    type: err.type,
                    error: OrderExecutionException(
                      orderId: data['details']?['order_id'],
                    ),
                  ),
                );

              case 'MARKET_CLOSED':
                return handler.reject(
                  DioException(
                    requestOptions: err.requestOptions,
                    response: err.response,
                    type: err.type,
                    error: MarketClosedException(
                      market: data['details']?['market'],
                    ),
                  ),
                );

              case 'VALIDATION_ERROR':
                return handler.reject(
                  DioException(
                    requestOptions: err.requestOptions,
                    response: err.response,
                    type: err.type,
                    error: ValidationException(
                      fieldErrors: data['details']?['field_errors'] != null
                          ? Map<String, List<String>>.from(
                              (data['details']['field_errors'] as Map).map(
                                (key, value) => MapEntry(
                                  key.toString(),
                                  List<String>.from(value as List),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                );
            }
          }
      }
    }

    super.onError(err, handler);
  }
}
