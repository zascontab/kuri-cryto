import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/health_response.dart';
import '../services/health_service.dart';
import '../services/logging_service.dart';
import '../utils/retry_helper.dart';

import 'api_client_provider.dart';

/// Provider del servicio Health
final healthServiceProvider = Provider<HealthService>((ref) {
  final dio = ref.watch(dioProvider);
  final service = HealthService(dio);

  // Limpiar recursos cuando el provider se destruya
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider del estado de salud del servidor
final healthProvider = StreamProvider<HealthResponse>((ref) {
  final service = ref.watch(healthServiceProvider);

  // Iniciar monitoreo
  service.startMonitoring(interval: const Duration(seconds: 30));

  return service.healthStream;
});

/// Provider para verificar si el servidor está saludable
final isServerHealthyProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(healthServiceProvider);

  try {
    return await RetryHelper.execute(
      () => service.isServerHealthy(),
      maxRetries: 2,
      initialDelay: const Duration(seconds: 1),
    );
  } catch (error, stackTrace) {
    LoggingService.instance.error(
      'Failed to check server health',
      tag: 'HealthProvider',
      error: error,
      stackTrace: stackTrace,
    );

    // Return false instead of throwing to prevent UI crashes
    return false;
  }
});

/// Provider para obtener el último health check
final latestHealthProvider = Provider<HealthResponse?>((ref) {
  final healthAsync = ref.watch(healthProvider);
  return healthAsync.maybeWhen(
    data: (health) => health,
    orElse: () => null,
  );
});

/// Provider para verificar conectividad
final connectivityStatusProvider = Provider<ConnectivityStatus>((ref) {
  final healthAsync = ref.watch(healthProvider);

  return healthAsync.when(
    data: (health) {
      LoggingService.instance.debug(
        'Health check result: ${health.isHealthy ? 'healthy' : 'unhealthy'}',
        tag: 'ConnectivityStatus',
        context: {
          'is_healthy': health.isHealthy,
          'is_degraded': health.isDegraded,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (health.isHealthy) {
        return ConnectivityStatus.connected;
      } else if (health.isDegraded) {
        return ConnectivityStatus.degraded;
      } else {
        return ConnectivityStatus.disconnected;
      }
    },
    loading: () => ConnectivityStatus.checking,
    error: (error, stackTrace) {
      LoggingService.instance.error(
        'Health check failed',
        tag: 'ConnectivityStatus',
        error: error,
        stackTrace: stackTrace,
      );
      return ConnectivityStatus.disconnected;
    },
  );
});

/// Estado de conectividad
enum ConnectivityStatus {
  connected,
  degraded,
  disconnected,
  checking,
}

/// Extension para obtener información del estado
extension ConnectivityStatusX on ConnectivityStatus {
  String get displayName {
    switch (this) {
      case ConnectivityStatus.connected:
        return 'Connected';
      case ConnectivityStatus.degraded:
        return 'Degraded';
      case ConnectivityStatus.disconnected:
        return 'Disconnected';
      case ConnectivityStatus.checking:
        return 'Checking...';
    }
  }

  String get colorHex {
    switch (this) {
      case ConnectivityStatus.connected:
        return '#10B981'; // Green
      case ConnectivityStatus.degraded:
        return '#F59E0B'; // Orange
      case ConnectivityStatus.disconnected:
        return '#EF4444'; // Red
      case ConnectivityStatus.checking:
        return '#6B7280'; // Gray
    }
  }

  bool get isConnected => this == ConnectivityStatus.connected;
  bool get isDisconnected => this == ConnectivityStatus.disconnected;
  bool get needsAttention =>
      this == ConnectivityStatus.degraded ||
      this == ConnectivityStatus.disconnected;
}
