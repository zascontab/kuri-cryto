import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/retry_service.dart';
import '../services/rate_limit_service.dart';
import '../services/fallback_service.dart';

/// Provider for RetryService with default configuration
final retryServiceProvider = Provider<RetryService>((ref) {
  return RetryService(
    maxRetries: 3,
    initialDelay: const Duration(milliseconds: 1000),
    backoffMultiplier: 2.0,
    jitterFactor: 0.1,
    maxDelay: const Duration(seconds: 30),
  );
});

/// Provider for RateLimitService with default configuration
final rateLimitServiceProvider = Provider<RateLimitService>((ref) {
  final service = RateLimitService();

  // Setup default configurations can be done here if needed
  // service.updateConfig('custom_endpoint', RateLimitConfig(...));

  return service;
});

/// Provider for FallbackService with default fallbacks
final fallbackServiceProvider = Provider<FallbackService>((ref) {
  final service = FallbackService();

  // Setup default fallback strategies
  service.setupDefaultFallbacks();

  return service;
});

/// Provider for MATP-specific retry configuration
final matpRetryConfigProvider = Provider<RetryConfig>((ref) {
  return RetryConfig.matp;
});

/// Provider for MCP-specific retry configuration
final mcpRetryConfigProvider = Provider<RetryConfig>((ref) {
  return RetryConfig.mcp;
});

/// Provider for critical operations retry configuration (no retries)
final criticalRetryConfigProvider = Provider<RetryConfig>((ref) {
  return RetryConfig.critical;
});

/// Provider for error handling statistics
final errorHandlingStatsProvider =
    StateNotifierProvider<ErrorHandlingStatsNotifier, ErrorHandlingStats>(
        (ref) {
  return ErrorHandlingStatsNotifier();
});

/// Error handling statistics state
class ErrorHandlingStats {
  final int totalRetries;
  final int circuitBreakerTrips;
  final int rateLimitHits;
  final int fallbacksUsed;
  final int cacheHits;
  final Map<String, int> errorCounts;
  final DateTime lastUpdated;

  const ErrorHandlingStats({
    this.totalRetries = 0,
    this.circuitBreakerTrips = 0,
    this.rateLimitHits = 0,
    this.fallbacksUsed = 0,
    this.cacheHits = 0,
    this.errorCounts = const {},
    required this.lastUpdated,
  });

  ErrorHandlingStats copyWith({
    int? totalRetries,
    int? circuitBreakerTrips,
    int? rateLimitHits,
    int? fallbacksUsed,
    int? cacheHits,
    Map<String, int>? errorCounts,
    DateTime? lastUpdated,
  }) {
    return ErrorHandlingStats(
      totalRetries: totalRetries ?? this.totalRetries,
      circuitBreakerTrips: circuitBreakerTrips ?? this.circuitBreakerTrips,
      rateLimitHits: rateLimitHits ?? this.rateLimitHits,
      fallbacksUsed: fallbacksUsed ?? this.fallbacksUsed,
      cacheHits: cacheHits ?? this.cacheHits,
      errorCounts: errorCounts ?? this.errorCounts,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_retries': totalRetries,
      'circuit_breaker_trips': circuitBreakerTrips,
      'rate_limit_hits': rateLimitHits,
      'fallbacks_used': fallbacksUsed,
      'cache_hits': cacheHits,
      'error_counts': errorCounts,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

/// State notifier for error handling statistics
class ErrorHandlingStatsNotifier extends StateNotifier<ErrorHandlingStats> {
  ErrorHandlingStatsNotifier()
      : super(ErrorHandlingStats(lastUpdated: DateTime.now()));

  void incrementRetries() {
    state = state.copyWith(
      totalRetries: state.totalRetries + 1,
      lastUpdated: DateTime.now(),
    );
  }

  void incrementCircuitBreakerTrips() {
    state = state.copyWith(
      circuitBreakerTrips: state.circuitBreakerTrips + 1,
      lastUpdated: DateTime.now(),
    );
  }

  void incrementRateLimitHits() {
    state = state.copyWith(
      rateLimitHits: state.rateLimitHits + 1,
      lastUpdated: DateTime.now(),
    );
  }

  void incrementFallbacksUsed() {
    state = state.copyWith(
      fallbacksUsed: state.fallbacksUsed + 1,
      lastUpdated: DateTime.now(),
    );
  }

  void incrementCacheHits() {
    state = state.copyWith(
      cacheHits: state.cacheHits + 1,
      lastUpdated: DateTime.now(),
    );
  }

  void incrementErrorCount(String errorType) {
    final newErrorCounts = Map<String, int>.from(state.errorCounts);
    newErrorCounts[errorType] = (newErrorCounts[errorType] ?? 0) + 1;

    state = state.copyWith(
      errorCounts: newErrorCounts,
      lastUpdated: DateTime.now(),
    );
  }

  void reset() {
    state = ErrorHandlingStats(lastUpdated: DateTime.now());
  }
}

/// Provider for system health status based on error handling metrics
final systemHealthProvider = Provider<SystemHealth>((ref) {
  final stats = ref.watch(errorHandlingStatsProvider);
  final retryService = ref.watch(retryServiceProvider);
  final rateLimitService = ref.watch(rateLimitServiceProvider);
  final fallbackService = ref.watch(fallbackServiceProvider);

  return SystemHealth.fromStats(
      stats, retryService, rateLimitService, fallbackService);
});

/// System health status
class SystemHealth {
  final HealthStatus overall;
  final HealthStatus connectivity;
  final HealthStatus rateLimiting;
  final HealthStatus fallbacks;
  final List<String> issues;
  final Map<String, dynamic> metrics;

  const SystemHealth({
    required this.overall,
    required this.connectivity,
    required this.rateLimiting,
    required this.fallbacks,
    required this.issues,
    required this.metrics,
  });

  factory SystemHealth.fromStats(
    ErrorHandlingStats stats,
    RetryService retryService,
    RateLimitService rateLimitService,
    FallbackService fallbackService,
  ) {
    final issues = <String>[];

    // Analyze connectivity health
    HealthStatus connectivityStatus = HealthStatus.healthy;
    if (stats.circuitBreakerTrips > 5) {
      connectivityStatus = HealthStatus.degraded;
      issues.add('Multiple circuit breaker trips detected');
    }
    if (stats.totalRetries > 50) {
      connectivityStatus = HealthStatus.unhealthy;
      issues.add('Excessive retry attempts');
    }

    // Analyze rate limiting health
    HealthStatus rateLimitingStatus = HealthStatus.healthy;
    if (stats.rateLimitHits > 10) {
      rateLimitingStatus = HealthStatus.degraded;
      issues.add('Frequent rate limiting');
    }

    // Analyze fallback health
    HealthStatus fallbacksStatus = HealthStatus.healthy;
    if (stats.fallbacksUsed > 20) {
      fallbacksStatus = HealthStatus.degraded;
      issues.add('High fallback usage');
    }

    // Determine overall health
    final statuses = [connectivityStatus, rateLimitingStatus, fallbacksStatus];
    HealthStatus overallStatus = HealthStatus.healthy;

    if (statuses.any((s) => s == HealthStatus.unhealthy)) {
      overallStatus = HealthStatus.unhealthy;
    } else if (statuses.any((s) => s == HealthStatus.degraded)) {
      overallStatus = HealthStatus.degraded;
    }

    return SystemHealth(
      overall: overallStatus,
      connectivity: connectivityStatus,
      rateLimiting: rateLimitingStatus,
      fallbacks: fallbacksStatus,
      issues: issues,
      metrics: {
        'total_retries': stats.totalRetries,
        'circuit_breaker_trips': stats.circuitBreakerTrips,
        'rate_limit_hits': stats.rateLimitHits,
        'fallbacks_used': stats.fallbacksUsed,
        'cache_hits': stats.cacheHits,
        'error_counts': stats.errorCounts,
        'last_updated': stats.lastUpdated.toIso8601String(),
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall': overall.name,
      'connectivity': connectivity.name,
      'rate_limiting': rateLimiting.name,
      'fallbacks': fallbacks.name,
      'issues': issues,
      'metrics': metrics,
    };
  }
}

/// Health status enumeration
enum HealthStatus {
  healthy,
  degraded,
  unhealthy;

  String get displayName {
    switch (this) {
      case HealthStatus.healthy:
        return 'Healthy';
      case HealthStatus.degraded:
        return 'Degraded';
      case HealthStatus.unhealthy:
        return 'Unhealthy';
    }
  }

  String get emoji {
    switch (this) {
      case HealthStatus.healthy:
        return '🟢';
      case HealthStatus.degraded:
        return '🟡';
      case HealthStatus.unhealthy:
        return '🔴';
    }
  }
}
