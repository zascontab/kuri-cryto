import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_config.dart';

/// Provider de Dio configurado
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: ApiConfig.defaultHeaders,
    ),
  );

  // Agregar logging interceptor en desarrollo
  if (ApiConfig.enableHttpLogs) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: ApiConfig.logRequestBody,
        responseBody: ApiConfig.logResponseBody,
        error: true,
        requestHeader: false,
        responseHeader: false,
      ),
    );
  }

  return dio;
});
