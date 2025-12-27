import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import 'api_client.dart';
import 'api_exception.dart';
import '../exceptions/matp_exceptions.dart';
import 'retry_service.dart';
import 'rate_limit_service.dart';

/// MATP API Client extending base ApiClient
///
/// Provides specialized configuration for MATP system with Kong Gateway:
/// - Kong Gateway integration (port 10000)
/// - JWT token management (to be integrated later)
/// - Progressive access level handling
/// - MATP-specific error handling
class MATPApiClient extends ApiClient {
  String? _jwtToken;
  String? _refreshToken;
  int _userLevel = 1;
  DateTime? _tokenExpiry;

  // Enhanced error handling and resilience services
  late final RetryService _retryService;
  late final RateLimitService _rateLimitService;

  MATPApiClient({super.environment}) {
    _retryService = RetryService(
      maxRetries: ApiConfig.maxRetries,
      initialDelay: ApiConfig.retryDelay,
      backoffMultiplier: ApiConfig.retryBackoffMultiplier,
    );
    _rateLimitService = RateLimitService();
    _configureKongGateway();
  }

  /// Configure Kong Gateway specific settings
  void _configureKongGateway() {
    final matpBaseUrl = ApiConfig.getMATPBaseUrl(environment);

    // Update base URL to Kong Gateway
    dio.options.baseUrl = matpBaseUrl;

    // Add MATP-specific headers
    dio.options.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });

    // Add MATP-specific interceptors
    dio.interceptors.add(_MATPInterceptor());

    developer.log(
      'MATP API Client configured with Kong Gateway: $matpBaseUrl',
      name: 'MATPApiClient',
    );
  }

  /// Set JWT token for authentication (to be used when auth is integrated)
  void setJWTToken(String token, {String? refreshToken, DateTime? expiry}) {
    _jwtToken = token;
    _refreshToken = refreshToken;
    _tokenExpiry = expiry;

    // Add Authorization header
    dio.options.headers['Authorization'] = 'Bearer $token';

    developer.log('JWT token set for MATP client', name: 'MATPApiClient');
  }

  /// Clear JWT token
  void clearJWTToken() {
    _jwtToken = null;
    _refreshToken = null;
    _tokenExpiry = null;

    dio.options.headers.remove('Authorization');

    developer.log('JWT token cleared from MATP client', name: 'MATPApiClient');
  }

  /// Set user access level for progressive access control
  void setUserLevel(int level) {
    _userLevel = level;
    dio.options.headers['X-User-Level'] = level.toString();

    developer.log('User level set to: $level', name: 'MATPApiClient');
  }

  /// Get current user level
  int get userLevel => _userLevel;

  /// Check if user has required access level
  bool hasAccessLevel(int requiredLevel) {
    return _userLevel >= requiredLevel;
  }

  /// Get current JWT token
  String? get jwtToken => _jwtToken;

  /// Get refresh token
  String? get refreshToken => _refreshToken;

  /// Check if token is expired
  bool get isTokenExpired {
    if (_tokenExpiry == null) return false;
    return DateTime.now().isAfter(_tokenExpiry!);
  }

  /// Refresh JWT token using refresh token
  Future<void> refreshJWTToken() async {
    if (_refreshToken == null) {
      throw MATPAuthException.noRefreshToken();
    }

    try {
      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': _refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            // Don't include Authorization header for refresh
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newToken = data['access_token'] as String;
        final newRefreshToken = data['refresh_token'] as String?;
        final expiresIn = data['expires_in'] as int? ?? 3600;

        // Update tokens
        setJWTToken(
          newToken,
          refreshToken: newRefreshToken ?? _refreshToken,
          expiry: DateTime.now().add(Duration(seconds: expiresIn)),
        );

        // Update user level if provided
        if (data.containsKey('user_level')) {
          setUserLevel(data['user_level'] as int);
        }

        developer.log('JWT token refreshed successfully',
            name: 'MATPApiClient');
      } else {
        throw MATPAuthException.refreshFailed(
          statusCode: response.statusCode,
          message: 'Token refresh failed with status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Clear tokens on refresh failure
      clearJWTToken();

      if (e.response?.statusCode == 401) {
        throw MATPAuthException.invalidRefreshToken();
      } else {
        throw MATPAuthException.refreshFailed(
          statusCode: e.response?.statusCode,
          message: e.message ?? 'Token refresh failed',
        );
      }
    }
  }

  /// Check if token needs refresh and refresh if necessary
  Future<void> _ensureValidToken() async {
    if (isTokenExpired && _refreshToken != null) {
      await refreshJWTToken();
    }
  }

  /// MATP-specific GET request with access level validation and enhanced error handling
  Future<T> matpGet<T>(
    String path, {
    int? requiredLevel,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    // Ensure token is valid before making request
    await _ensureValidToken();

    if (requiredLevel != null && !hasAccessLevel(requiredLevel)) {
      throw MATPAuthException.insufficientLevel(
        currentLevel: _userLevel,
        requiredLevel: requiredLevel,
      );
    }

    return await _rateLimitService.executeWithRateLimit<T>(
      () => _retryService.executeWithRetry<T>(
        () => get<T>(
          path,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ),
        operationId: 'matp_get_$path',
        enableCircuitBreaker: true,
        enableDeduplication: true,
      ),
      endpoint: 'matp_level_$_userLevel',
      priority: priority,
      userLevel: _userLevel.toString(),
    );
  }

  /// MATP-specific POST request with access level validation and enhanced error handling
  Future<T> matpPost<T>(
    String path, {
    int? requiredLevel,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    // Ensure token is valid before making request
    await _ensureValidToken();

    if (requiredLevel != null && !hasAccessLevel(requiredLevel)) {
      throw MATPAuthException.insufficientLevel(
        currentLevel: _userLevel,
        requiredLevel: requiredLevel,
      );
    }

    return await _rateLimitService.executeWithRateLimit<T>(
      () => _retryService.executeWithRetry<T>(
        () => post<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ),
        operationId: 'matp_post_$path',
        enableCircuitBreaker: true,
        enableDeduplication: false, // Don't deduplicate POST requests
      ),
      endpoint: 'matp_level_$_userLevel',
      priority: priority,
      userLevel: _userLevel.toString(),
    );
  }

  /// MATP-specific PUT request with access level validation and enhanced error handling
  Future<T> matpPut<T>(
    String path, {
    int? requiredLevel,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    // Ensure token is valid before making request
    await _ensureValidToken();

    if (requiredLevel != null && !hasAccessLevel(requiredLevel)) {
      throw MATPAuthException.insufficientLevel(
        currentLevel: _userLevel,
        requiredLevel: requiredLevel,
      );
    }

    return await _rateLimitService.executeWithRateLimit<T>(
      () => _retryService.executeWithRetry<T>(
        () => put<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ),
        operationId: 'matp_put_$path',
        enableCircuitBreaker: true,
        enableDeduplication: false, // Don't deduplicate PUT requests
      ),
      endpoint: 'matp_level_$_userLevel',
      priority: priority,
      userLevel: _userLevel.toString(),
    );
  }

  /// MATP-specific DELETE request with access level validation and enhanced error handling
  Future<T> matpDelete<T>(
    String path, {
    int? requiredLevel,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    // Ensure token is valid before making request
    await _ensureValidToken();

    if (requiredLevel != null && !hasAccessLevel(requiredLevel)) {
      throw MATPAuthException.insufficientLevel(
        currentLevel: _userLevel,
        requiredLevel: requiredLevel,
      );
    }

    return await _rateLimitService.executeWithRateLimit<T>(
      () => _retryService.executeWithRetry<T>(
        () => delete<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ),
        operationId: 'matp_delete_$path',
        enableCircuitBreaker: true,
        enableDeduplication: false, // Don't deduplicate DELETE requests
      ),
      endpoint: 'matp_level_$_userLevel',
      priority: priority,
      userLevel: _userLevel.toString(),
    );
  }

  /// Get rate limit status for debugging
  Map<String, dynamic> getRateLimitStatus() {
    return _rateLimitService.getState('matp_level_$_userLevel');
  }

  /// Clear retry and rate limit state (useful for testing)
  void clearState() {
    _retryService.clearCircuitBreakers();
    _retryService.clearPendingRequests();
    _rateLimitService.clearState();
  }

  /// Test-only dio instance for mocking
  @visibleForTesting
  Dio? _testDio;

  /// Override dio getter to return test instance when available
  @override
  Dio get dio => _testDio ?? super.dio;

  /// Set dio instance for testing
  @visibleForTesting
  set dioInstance(Dio testDio) => _testDio = testDio;
}

/// MATP-specific interceptor for Kong Gateway integration
class _MATPInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add request ID for tracking
    options.headers['X-Request-ID'] =
        DateTime.now().millisecondsSinceEpoch.toString();

    if (ApiConfig.enableLogging) {
      developer.log(
        '→ MATP ${options.method} ${options.uri}',
        name: 'MATPApiClient',
      );
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (ApiConfig.enableLogging) {
      developer.log(
        '← MATP ${response.statusCode} ${response.requestOptions.uri}',
        name: 'MATPApiClient',
      );
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (ApiConfig.enableLogging) {
      developer.log(
        '✗ MATP ${err.requestOptions.method} ${err.requestOptions.uri}',
        name: 'MATPApiClient',
        error: err,
      );
    }

    // Handle MATP-specific errors
    if (err.response != null) {
      final statusCode = err.response!.statusCode;
      final data = err.response!.data;

      switch (statusCode) {
        case 429:
          // Rate limiting - create structured exception
          final headers = <String, dynamic>{};
          err.response!.headers.forEach((name, values) {
            if (values.isNotEmpty) {
              headers[name] = values.first;
            }
          });

          final rateLimitException =
              MATPRateLimitException.fromHeaders(headers);

          developer.log(
            'Rate limit exceeded: ${rateLimitException.message}',
            name: 'MATPApiClient',
          );

          // Let the error bubble up to be handled by rate limit service
          break;

        case 403:
          // Check if it's access level related
          if (data is Map<String, dynamic> &&
              data['code'] == 'INSUFFICIENT_ACCESS_LEVEL') {
            final requiredLevel = data['details']?['required_level'] ?? 0;
            final currentLevel = data['details']?['current_level'] ?? 0;

            developer.log(
              'Insufficient access level. Required: $requiredLevel, Current: $currentLevel',
              name: 'MATPApiClient',
            );
          }
          break;

        case 502:
        case 503:
        case 504:
          // Gateway errors
          developer.log(
            'Gateway error: ${err.response!.statusCode} - ${err.message}',
            name: 'MATPApiClient',
          );
          break;
      }
    }

    super.onError(err, handler);
  }
}
