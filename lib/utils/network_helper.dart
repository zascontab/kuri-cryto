import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'constants.dart';

/// Helpers para operaciones de red
///
/// Este archivo proporciona funciones para verificar conectividad,
/// obtener información de red, y configurar URLs según el ambiente.
///
/// Ejemplos de uso:
/// ```dart
/// // Verificar conectividad
/// final isConnected = await NetworkHelper.isOnline();
///
/// // Obtener IP del dispositivo
/// final ip = await NetworkHelper.getDeviceIP();
///
/// // Configurar URL según ambiente
/// final apiUrl = NetworkHelper.configureApiUrl(isProduction: true);
/// ```
class NetworkHelper {
  NetworkHelper._(); // Constructor privado para prevenir instanciación

  // ==========================================================================
  // Verificación de Conectividad
  // ==========================================================================

  /// Verifica si hay conexión a internet
  ///
  /// [timeout]: Timeout para la verificación (por defecto 10 segundos)
  ///
  /// Retorna true si hay conexión, false en caso contrario
  ///
  /// Ejemplo:
  /// ```dart
  /// final isConnected = await NetworkHelper.isOnline();
  /// if (!isConnected) {
  ///   print('No internet connection');
  /// }
  /// ```
  static Future<bool> isOnline({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      // Intenta hacer lookup a un DNS confiable
      final result = await InternetAddress.lookup('google.com')
          .timeout(timeout);

      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (e) {
      developer.log(
        'Error checking internet connection',
        name: 'NetworkHelper',
        error: e,
      );
      return false;
    }
  }

  /// Verifica conectividad usando múltiples hosts
  ///
  /// [hosts]: Lista de hosts a verificar (por defecto Google y Cloudflare DNS)
  /// [timeout]: Timeout por host (por defecto 5 segundos)
  ///
  /// Retorna true si al menos uno de los hosts responde
  ///
  /// Ejemplo:
  /// ```dart
  /// final isConnected = await NetworkHelper.isOnlineMultiple();
  /// ```
  static Future<bool> isOnlineMultiple({
    List<String> hosts = const ['google.com', 'cloudflare.com', '1.1.1.1'],
    Duration timeout = const Duration(seconds: 5),
  }) async {
    for (final host in hosts) {
      try {
        final result = await InternetAddress.lookup(host).timeout(timeout);
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        }
      } catch (_) {
        continue;
      }
    }

    return false;
  }

  /// Verifica si puede conectar al servidor de la API
  ///
  /// [baseUrl]: URL base de la API (opcional, usa la configurada por defecto)
  /// [timeout]: Timeout para la conexión (por defecto 10 segundos)
  ///
  /// Retorna true si puede conectar al servidor
  ///
  /// Ejemplo:
  /// ```dart
  /// final canConnect = await NetworkHelper.canConnectToApi();
  /// ```
  static Future<bool> canConnectToApi({
    String? baseUrl,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final url = baseUrl ?? ApiEndpoints.baseUrl;
      final dio = Dio();

      dio.options.connectTimeout = timeout;
      dio.options.receiveTimeout = timeout;

      // Intenta hacer una petición simple (health check o ping)
      final response = await dio.get(
        '$url/health',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      return response.statusCode != null && response.statusCode! < 500;
    } catch (e) {
      developer.log(
        'Cannot connect to API',
        name: 'NetworkHelper',
        error: e,
      );
      return false;
    }
  }

  // ==========================================================================
  // Información de Red
  // ==========================================================================

  /// Obtiene la dirección IP del dispositivo
  ///
  /// [type]: Tipo de IP a obtener (IPv4 o IPv6, por defecto IPv4)
  ///
  /// Retorna la IP del dispositivo o null si no se puede obtener
  ///
  /// Ejemplo:
  /// ```dart
  /// final ip = await NetworkHelper.getDeviceIP();
  /// print('Device IP: $ip'); // "192.168.1.100"
  /// ```
  static Future<String?> getDeviceIP({
    InternetAddressType type = InternetAddressType.IPv4,
  }) async {
    try {
      // Obtiene todas las interfaces de red
      final interfaces = await NetworkInterface.list(
        type: type,
        includeLinkLocal: false,
      );

      // Busca la primera interfaz activa
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          // Ignora loopback
          if (!address.isLoopback) {
            return address.address;
          }
        }
      }

      return null;
    } catch (e) {
      developer.log(
        'Error getting device IP',
        name: 'NetworkHelper',
        error: e,
      );
      return null;
    }
  }

  /// Obtiene todas las direcciones IP del dispositivo
  ///
  /// Retorna un mapa con el nombre de la interfaz y sus IPs
  ///
  /// Ejemplo:
  /// ```dart
  /// final ips = await NetworkHelper.getAllDeviceIPs();
  /// print(ips); // {'en0': ['192.168.1.100'], 'lo0': ['127.0.0.1']}
  /// ```
  static Future<Map<String, List<String>>> getAllDeviceIPs() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLinkLocal: true,
        includeLoopback: true,
      );

      final ipMap = <String, List<String>>{};

      for (final interface in interfaces) {
        final addresses = interface.addresses
            .map((addr) => addr.address)
            .toList();

        ipMap[interface.name] = addresses;
      }

      return ipMap;
    } catch (e) {
      developer.log(
        'Error getting all device IPs',
        name: 'NetworkHelper',
        error: e,
      );
      return {};
    }
  }

  /// Obtiene información de la red WiFi (Android/iOS)
  ///
  /// Retorna un mapa con información de la red
  ///
  /// Nota: En producción, deberías usar un plugin como connectivity_plus
  /// para obtener información más detallada
  ///
  /// Ejemplo:
  /// ```dart
  /// final info = await NetworkHelper.getNetworkInfo();
  /// print(info['type']); // 'wifi', 'mobile', etc.
  /// ```
  static Future<Map<String, dynamic>> getNetworkInfo() async {
    try {
      final isConnected = await isOnline();

      return {
        'isConnected': isConnected,
        'ip': await getDeviceIP(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      developer.log(
        'Error getting network info',
        name: 'NetworkHelper',
        error: e,
      );

      return {
        'isConnected': false,
        'ip': null,
        'error': e.toString(),
      };
    }
  }

  // ==========================================================================
  // Configuración de URLs
  // ==========================================================================

  /// Configura la URL de la API según el ambiente
  ///
  /// [isProduction]: Si está en producción
  /// [productionUrl]: URL de producción (opcional)
  /// [stagingUrl]: URL de staging (opcional)
  /// [developmentUrl]: URL de desarrollo (opcional)
  ///
  /// Retorna la URL configurada para el ambiente
  ///
  /// Ejemplo:
  /// ```dart
  /// final apiUrl = NetworkHelper.configureApiUrl(
  ///   isProduction: true,
  ///   productionUrl: 'https://api.example.com',
  /// );
  /// ```
  static String configureApiUrl({
    required bool isProduction,
    String? productionUrl,
    String? stagingUrl,
    String? developmentUrl,
  }) {
    if (isProduction) {
      return productionUrl ?? 'https://api.production.com';
    }

    // Staging o desarrollo
    return developmentUrl ??
        stagingUrl ??
        ApiEndpoints.baseUrl;
  }

  /// Configura la URL de WebSocket según el ambiente
  ///
  /// [isProduction]: Si está en producción
  /// [productionUrl]: URL de producción (opcional)
  /// [developmentUrl]: URL de desarrollo (opcional)
  ///
  /// Retorna la URL de WebSocket configurada
  ///
  /// Ejemplo:
  /// ```dart
  /// final wsUrl = NetworkHelper.configureWsUrl(
  ///   isProduction: true,
  ///   productionUrl: 'wss://api.example.com/ws',
  /// );
  /// ```
  static String configureWsUrl({
    required bool isProduction,
    String? productionUrl,
    String? developmentUrl,
  }) {
    if (isProduction) {
      return productionUrl ?? 'wss://api.production.com/ws';
    }

    return developmentUrl ?? ApiEndpoints.wsBaseUrl;
  }

  /// Detecta el ambiente actual según la URL base
  ///
  /// [baseUrl]: URL base a analizar (opcional, usa la configurada por defecto)
  ///
  /// Retorna 'production', 'staging', o 'development'
  ///
  /// Ejemplo:
  /// ```dart
  /// final env = NetworkHelper.detectEnvironment();
  /// print(env); // "development"
  /// ```
  static String detectEnvironment({String? baseUrl}) {
    final url = baseUrl ?? ApiEndpoints.baseUrl;

    if (url.contains('localhost') || url.contains('127.0.0.1')) {
      return 'development';
    } else if (url.contains('staging') || url.contains('dev.')) {
      return 'staging';
    } else {
      return 'production';
    }
  }

  /// Verifica si está en ambiente de desarrollo
  ///
  /// [baseUrl]: URL base a analizar (opcional)
  ///
  /// Ejemplo:
  /// ```dart
  /// if (NetworkHelper.isDevelopment()) {
  ///   print('Running in development mode');
  /// }
  /// ```
  static bool isDevelopment({String? baseUrl}) {
    return detectEnvironment(baseUrl: baseUrl) == 'development';
  }

  /// Verifica si está en ambiente de staging
  ///
  /// [baseUrl]: URL base a analizar (opcional)
  ///
  /// Ejemplo:
  /// ```dart
  /// if (NetworkHelper.isStaging()) {
  ///   print('Running in staging mode');
  /// }
  /// ```
  static bool isStaging({String? baseUrl}) {
    return detectEnvironment(baseUrl: baseUrl) == 'staging';
  }

  /// Verifica si está en ambiente de producción
  ///
  /// [baseUrl]: URL base a analizar (opcional)
  ///
  /// Ejemplo:
  /// ```dart
  /// if (NetworkHelper.isProduction()) {
  ///   print('Running in production mode');
  /// }
  /// ```
  static bool isProduction({String? baseUrl}) {
    return detectEnvironment(baseUrl: baseUrl) == 'production';
  }

  // ==========================================================================
  // Utilidades HTTP
  // ==========================================================================

  /// Mide la latencia a un servidor
  ///
  /// [url]: URL del servidor a medir
  /// [samples]: Número de muestras (por defecto 3)
  ///
  /// Retorna la latencia promedio en milisegundos
  ///
  /// Ejemplo:
  /// ```dart
  /// final latency = await NetworkHelper.measureLatency(
  ///   'https://api.example.com',
  /// );
  /// print('Latency: ${latency}ms');
  /// ```
  static Future<int> measureLatency(
    String url, {
    int samples = 3,
  }) async {
    final latencies = <int>[];
    final dio = Dio();

    for (var i = 0; i < samples; i++) {
      try {
        final startTime = DateTime.now();

        await dio.head(
          url,
          options: Options(
            receiveTimeout: const Duration(seconds: 5),
            sendTimeout: const Duration(seconds: 5),
          ),
        );

        final endTime = DateTime.now();
        final latency = endTime.difference(startTime).inMilliseconds;
        latencies.add(latency);

        // Pequeño delay entre muestras
        if (i < samples - 1) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      } catch (e) {
        developer.log(
          'Error measuring latency',
          name: 'NetworkHelper',
          error: e,
        );
      }
    }

    if (latencies.isEmpty) return -1;

    // Retorna la latencia promedio
    return latencies.reduce((a, b) => a + b) ~/ latencies.length;
  }

  /// Verifica el estado de un servidor
  ///
  /// [url]: URL del servidor
  /// [timeout]: Timeout para la verificación (por defecto 10 segundos)
  ///
  /// Retorna un mapa con información del estado
  ///
  /// Ejemplo:
  /// ```dart
  /// final status = await NetworkHelper.checkServerStatus(
  ///   'https://api.example.com/health',
  /// );
  /// print(status['isOnline']); // true/false
  /// print(status['statusCode']); // 200, 500, etc.
  /// ```
  static Future<Map<String, dynamic>> checkServerStatus(
    String url, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = timeout;
      dio.options.receiveTimeout = timeout;

      final startTime = DateTime.now();
      final response = await dio.get(
        url,
        options: Options(
          validateStatus: (status) => true, // Accept any status code
        ),
      );
      final endTime = DateTime.now();

      final latency = endTime.difference(startTime).inMilliseconds;

      return {
        'isOnline': true,
        'statusCode': response.statusCode,
        'latency': latency,
        'timestamp': DateTime.now().toIso8601String(),
        'message': 'Server is reachable',
      };
    } catch (e) {
      return {
        'isOnline': false,
        'statusCode': null,
        'latency': -1,
        'timestamp': DateTime.now().toIso8601String(),
        'message': 'Server is unreachable',
        'error': e.toString(),
      };
    }
  }

  /// Descarga el tamaño de un archivo sin descargarlo completamente
  ///
  /// [url]: URL del archivo
  ///
  /// Retorna el tamaño en bytes o -1 si no se puede obtener
  ///
  /// Ejemplo:
  /// ```dart
  /// final size = await NetworkHelper.getFileSize(
  ///   'https://example.com/file.zip',
  /// );
  /// print('File size: $size bytes');
  /// ```
  static Future<int> getFileSize(String url) async {
    try {
      final dio = Dio();
      final response = await dio.head(url);

      final contentLength = response.headers.value('content-length');
      if (contentLength != null) {
        return int.parse(contentLength);
      }

      return -1;
    } catch (e) {
      developer.log(
        'Error getting file size',
        name: 'NetworkHelper',
        error: e,
      );
      return -1;
    }
  }

  // ==========================================================================
  // Diagnóstico de Red
  // ==========================================================================

  /// Ejecuta un diagnóstico completo de red
  ///
  /// [apiUrl]: URL de la API a diagnosticar (opcional)
  ///
  /// Retorna un reporte completo de diagnóstico
  ///
  /// Ejemplo:
  /// ```dart
  /// final report = await NetworkHelper.runNetworkDiagnostics();
  /// print(report);
  /// ```
  static Future<Map<String, dynamic>> runNetworkDiagnostics({
    String? apiUrl,
  }) async {
    final url = apiUrl ?? ApiEndpoints.baseUrl;

    developer.log('Running network diagnostics...', name: 'NetworkHelper');

    final diagnostics = <String, dynamic>{};

    // 1. Verificar conectividad a Internet
    diagnostics['internetConnection'] = await isOnline();

    // 2. Obtener IP del dispositivo
    diagnostics['deviceIP'] = await getDeviceIP();

    // 3. Verificar conexión a la API
    diagnostics['apiConnection'] = await canConnectToApi(baseUrl: url);

    // 4. Medir latencia a la API
    if (diagnostics['apiConnection'] == true) {
      diagnostics['apiLatency'] = await measureLatency(url);
    } else {
      diagnostics['apiLatency'] = -1;
    }

    // 5. Verificar estado del servidor
    diagnostics['serverStatus'] = await checkServerStatus(
      '$url/health',
    );

    // 6. Detectar ambiente
    diagnostics['environment'] = detectEnvironment(baseUrl: url);

    // 7. Timestamp del diagnóstico
    diagnostics['timestamp'] = DateTime.now().toIso8601String();

    developer.log(
      'Network diagnostics completed',
      name: 'NetworkHelper',
    );

    return diagnostics;
  }

  /// Imprime un reporte de diagnóstico legible
  ///
  /// [diagnostics]: Resultado de runNetworkDiagnostics
  ///
  /// Ejemplo:
  /// ```dart
  /// final report = await NetworkHelper.runNetworkDiagnostics();
  /// NetworkHelper.printDiagnosticReport(report);
  /// ```
  static void printDiagnosticReport(Map<String, dynamic> diagnostics) {
    developer.log('========================================', name: 'NetworkHelper');
    developer.log('Network Diagnostic Report', name: 'NetworkHelper');
    developer.log('========================================', name: 'NetworkHelper');

    developer.log(
      'Internet Connection: ${diagnostics['internetConnection'] ? 'OK' : 'FAILED'}',
      name: 'NetworkHelper',
    );

    developer.log(
      'Device IP: ${diagnostics['deviceIP'] ?? 'Unknown'}',
      name: 'NetworkHelper',
    );

    developer.log(
      'API Connection: ${diagnostics['apiConnection'] ? 'OK' : 'FAILED'}',
      name: 'NetworkHelper',
    );

    final latency = diagnostics['apiLatency'] as int;
    developer.log(
      'API Latency: ${latency >= 0 ? '${latency}ms' : 'N/A'}',
      name: 'NetworkHelper',
    );

    final serverStatus = diagnostics['serverStatus'] as Map<String, dynamic>;
    developer.log(
      'Server Status: ${serverStatus['isOnline'] ? 'Online' : 'Offline'}',
      name: 'NetworkHelper',
    );

    developer.log(
      'Environment: ${diagnostics['environment']}',
      name: 'NetworkHelper',
    );

    developer.log(
      'Timestamp: ${diagnostics['timestamp']}',
      name: 'NetworkHelper',
    );

    developer.log('========================================', name: 'NetworkHelper');
  }
}
