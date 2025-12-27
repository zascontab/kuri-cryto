import 'dart:async';
import 'dart:collection';
import 'dart:developer' as developer;
import '../exceptions/matp_exceptions.dart';
import '../exceptions/mcp_exceptions.dart';

/// Enhanced rate limiting service with request queuing and intelligent throttling
///
/// This service provides:
/// - Token bucket algorithm for rate limiting
/// - Request queuing with priority support
/// - Adaptive rate limiting based on server responses
/// - Per-endpoint rate limit tracking
/// - Burst handling with queue management
class RateLimitService {
  // Rate limit configurations per endpoint type
  static const Map<String, RateLimitConfig> _defaultConfigs = {
    'matp_level_1': RateLimitConfig(requestsPerMinute: 100, burstSize: 10),
    'matp_level_2': RateLimitConfig(requestsPerMinute: 500, burstSize: 50),
    'matp_level_3': RateLimitConfig(requestsPerMinute: 2000, burstSize: 200),
    'matp_level_4':
        RateLimitConfig(requestsPerMinute: -1, burstSize: -1), // Unlimited
    'mcp_tools': RateLimitConfig(requestsPerMinute: 60, burstSize: 10),
    'mcp_analysis': RateLimitConfig(requestsPerMinute: 30, burstSize: 5),
  };

  final Map<String, TokenBucket> _buckets = {};
  final Map<String, Queue<QueuedRequest>> _requestQueues = {};
  final Map<String, RateLimitConfig> _configs = Map.from(_defaultConfigs);
  final Map<String, RateLimitState> _states = {};

  /// Execute a request with rate limiting
  Future<T> executeWithRateLimit<T>(
    Future<T> Function() operation, {
    required String endpoint,
    RequestPriority priority = RequestPriority.normal,
    Duration? timeout,
    String? userLevel,
  }) async {
    final effectiveEndpoint = _getEffectiveEndpoint(endpoint, userLevel);
    final config = _getConfig(effectiveEndpoint);

    // Check if rate limiting is disabled (unlimited)
    if (config.requestsPerMinute == -1) {
      return await operation();
    }

    final bucket = _getBucket(effectiveEndpoint, config);
    final state = _getState(effectiveEndpoint);

    // Check if we're currently rate limited
    if (state.isRateLimited &&
        DateTime.now().isBefore(state.rateLimitResetTime)) {
      return await _queueRequest(
        operation,
        effectiveEndpoint,
        priority,
        timeout ?? const Duration(seconds: 30),
      );
    }

    // Try to acquire token immediately
    if (bucket.tryConsume()) {
      try {
        final result = await operation();
        _recordSuccess(effectiveEndpoint);
        return result;
      } catch (e) {
        _handleError(e, effectiveEndpoint);
        rethrow;
      }
    }

    // No tokens available, queue the request
    return await _queueRequest(
      operation,
      effectiveEndpoint,
      priority,
      timeout ?? const Duration(seconds: 30),
    );
  }

  /// Queue a request when rate limited
  Future<T> _queueRequest<T>(
    Future<T> Function() operation,
    String endpoint,
    RequestPriority priority,
    Duration timeout,
  ) async {
    final completer = Completer<T>();
    final request = QueuedRequest<T>(
      operation: operation,
      completer: completer,
      priority: priority,
      queuedAt: DateTime.now(),
      timeout: timeout,
    );

    final queue =
        _requestQueues.putIfAbsent(endpoint, () => Queue<QueuedRequest>());

    // Insert request based on priority
    _insertByPriority(queue, request);

    developer.log(
      'Request queued for endpoint: $endpoint (queue size: ${queue.length}, priority: $priority)',
      name: 'RateLimitService',
    );

    // Start processing queue if not already running
    _processQueue(endpoint);

    // Set up timeout
    Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.completeError(
          MATPConfigException(
            message:
                'Request timeout in rate limit queue for endpoint: $endpoint',
            code: 'RATE_LIMIT_QUEUE_TIMEOUT',
          ),
        );
      }
    });

    return completer.future;
  }

  /// Process queued requests for an endpoint
  void _processQueue(String endpoint) async {
    final queue = _requestQueues[endpoint];
    if (queue == null || queue.isEmpty) return;

    final bucket = _buckets[endpoint];
    if (bucket == null) return;

    while (queue.isNotEmpty && bucket.tryConsume()) {
      final request = queue.removeFirst();

      // Check if request has timed out
      if (DateTime.now().difference(request.queuedAt) > request.timeout) {
        if (!request.completer.isCompleted) {
          request.completer.completeError(
            MATPConfigException(
              message: 'Request timeout in rate limit queue',
              code: 'RATE_LIMIT_QUEUE_TIMEOUT',
            ),
          );
        }
        continue;
      }

      // Execute the request
      _executeQueuedRequest(request, endpoint);
    }

    // Schedule next processing if queue is not empty
    if (queue.isNotEmpty) {
      final nextTokenTime = bucket.getNextTokenTime();
      if (nextTokenTime != null) {
        Timer(nextTokenTime, () => _processQueue(endpoint));
      }
    }
  }

  /// Execute a queued request
  void _executeQueuedRequest<T>(
      QueuedRequest<T> request, String endpoint) async {
    try {
      final result = await request.operation();
      _recordSuccess(endpoint);

      if (!request.completer.isCompleted) {
        request.completer.complete(result);
      }
    } catch (e) {
      _handleError(e, endpoint);

      if (!request.completer.isCompleted) {
        request.completer.completeError(e);
      }
    }

    // Continue processing queue
    _processQueue(endpoint);
  }

  /// Insert request into queue based on priority
  void _insertByPriority(Queue<QueuedRequest> queue, QueuedRequest request) {
    if (queue.isEmpty || request.priority == RequestPriority.normal) {
      queue.addLast(request);
      return;
    }

    // For high priority requests, insert before normal priority requests
    final list = queue.toList();
    queue.clear();

    bool inserted = false;
    for (final existing in list) {
      if (!inserted && request.priority.index > existing.priority.index) {
        queue.addLast(request);
        inserted = true;
      }
      queue.addLast(existing);
    }

    if (!inserted) {
      queue.addLast(request);
    }
  }

  /// Get or create token bucket for endpoint
  TokenBucket _getBucket(String endpoint, RateLimitConfig config) {
    return _buckets.putIfAbsent(
      endpoint,
      () => TokenBucket(
        capacity: config.burstSize,
        refillRate: config.requestsPerMinute / 60.0, // Convert to per-second
      ),
    );
  }

  /// Get or create rate limit state for endpoint
  RateLimitState _getState(String endpoint) {
    return _states.putIfAbsent(endpoint, () => RateLimitState());
  }

  /// Get configuration for endpoint
  RateLimitConfig _getConfig(String endpoint) {
    return _configs[endpoint] ?? _configs['matp_level_1']!;
  }

  /// Get effective endpoint based on user level
  String _getEffectiveEndpoint(String endpoint, String? userLevel) {
    if (endpoint.startsWith('mcp_')) {
      return endpoint;
    }

    // Map user level to MATP endpoint configuration
    switch (userLevel) {
      case '1':
        return 'matp_level_1';
      case '2':
        return 'matp_level_2';
      case '3':
        return 'matp_level_3';
      case '4':
        return 'matp_level_4';
      default:
        return 'matp_level_1';
    }
  }

  /// Handle errors and update rate limit state
  void _handleError(dynamic error, String endpoint) {
    final state = _getState(endpoint);

    if (error is MATPRateLimitException) {
      state.isRateLimited = true;

      if (error.resetTime != null) {
        state.rateLimitResetTime = error.resetTime!;
      } else if (error.retryAfterSeconds != null) {
        state.rateLimitResetTime = DateTime.now().add(
          Duration(seconds: error.retryAfterSeconds!),
        );
      } else {
        // Default backoff
        state.rateLimitResetTime = DateTime.now().add(const Duration(minutes: 1));
      }

      developer.log(
        'Rate limit detected for endpoint: $endpoint, reset at: ${state.rateLimitResetTime}',
        name: 'RateLimitService',
      );

      // Adjust rate limit configuration adaptively
      _adjustRateLimit(endpoint, decrease: true);
    } else if (error is MCPQuotaException) {
      state.isRateLimited = true;

      if (error.resetTime != null) {
        state.rateLimitResetTime = DateTime.now().add(error.resetTime!);
      } else {
        state.rateLimitResetTime = DateTime.now().add(const Duration(minutes: 5));
      }

      developer.log(
        'MCP quota exceeded for endpoint: $endpoint, reset at: ${state.rateLimitResetTime}',
        name: 'RateLimitService',
      );
    }
  }

  /// Record successful request
  void _recordSuccess(String endpoint) {
    final state = _getState(endpoint);
    state.consecutiveSuccesses++;

    // Reset rate limit state on success
    if (state.isRateLimited &&
        DateTime.now().isAfter(state.rateLimitResetTime)) {
      state.isRateLimited = false;
      state.consecutiveSuccesses = 0;

      // Gradually increase rate limit after recovery
      if (state.consecutiveSuccesses > 10) {
        _adjustRateLimit(endpoint, decrease: false);
        state.consecutiveSuccesses = 0;
      }
    }
  }

  /// Adaptively adjust rate limit configuration
  void _adjustRateLimit(String endpoint, {required bool decrease}) {
    final config = _configs[endpoint];
    if (config == null || config.requestsPerMinute == -1) return;

    if (decrease) {
      // Decrease rate limit by 20%
      final newRate = (config.requestsPerMinute * 0.8).round();
      final newBurst = (config.burstSize * 0.8).round();

      _configs[endpoint] = RateLimitConfig(
        requestsPerMinute: newRate.clamp(10, config.requestsPerMinute),
        burstSize: newBurst.clamp(1, config.burstSize),
      );

      developer.log(
        'Decreased rate limit for $endpoint: ${config.requestsPerMinute} -> $newRate req/min',
        name: 'RateLimitService',
      );
    } else {
      // Increase rate limit by 10%
      final originalConfig = _defaultConfigs[endpoint];
      if (originalConfig != null) {
        final newRate = (config.requestsPerMinute * 1.1).round();
        final newBurst = (config.burstSize * 1.1).round();

        _configs[endpoint] = RateLimitConfig(
          requestsPerMinute: newRate.clamp(
              config.requestsPerMinute, originalConfig.requestsPerMinute),
          burstSize: newBurst.clamp(config.burstSize, originalConfig.burstSize),
        );

        developer.log(
          'Increased rate limit for $endpoint: ${config.requestsPerMinute} -> $newRate req/min',
          name: 'RateLimitService',
        );
      }
    }

    // Update token bucket with new configuration
    final newConfig = _configs[endpoint]!;
    _buckets[endpoint] = TokenBucket(
      capacity: newConfig.burstSize,
      refillRate: newConfig.requestsPerMinute / 60.0,
    );
  }

  /// Update rate limit configuration for an endpoint
  void updateConfig(String endpoint, RateLimitConfig config) {
    _configs[endpoint] = config;

    // Update existing bucket
    if (_buckets.containsKey(endpoint)) {
      _buckets[endpoint] = TokenBucket(
        capacity: config.burstSize,
        refillRate: config.requestsPerMinute / 60.0,
      );
    }
  }

  /// Get current queue size for an endpoint
  int getQueueSize(String endpoint) {
    return _requestQueues[endpoint]?.length ?? 0;
  }

  /// Get current rate limit state for an endpoint
  Map<String, dynamic> getState(String endpoint) {
    final state = _states[endpoint];
    final config = _configs[endpoint];
    final bucket = _buckets[endpoint];

    return {
      'endpoint': endpoint,
      'is_rate_limited': state?.isRateLimited ?? false,
      'reset_time': state?.rateLimitResetTime.toIso8601String(),
      'queue_size': getQueueSize(endpoint),
      'config': config != null
          ? {
              'requests_per_minute': config.requestsPerMinute,
              'burst_size': config.burstSize,
            }
          : null,
      'available_tokens': bucket?.availableTokens ?? 0,
    };
  }

  /// Clear all rate limit state (useful for testing)
  void clearState() {
    _buckets.clear();
    _requestQueues.clear();
    _states.clear();
    _configs.clear();
    _configs.addAll(_defaultConfigs);
  }
}

/// Token bucket implementation for rate limiting
class TokenBucket {
  final int capacity;
  final double refillRate; // tokens per second

  double _tokens;
  DateTime _lastRefill;

  TokenBucket({
    required this.capacity,
    required this.refillRate,
  })  : _tokens = capacity.toDouble(),
        _lastRefill = DateTime.now();

  /// Try to consume a token
  bool tryConsume({int tokens = 1}) {
    _refill();

    if (_tokens >= tokens) {
      _tokens -= tokens;
      return true;
    }

    return false;
  }

  /// Refill tokens based on elapsed time
  void _refill() {
    final now = DateTime.now();
    final elapsed = now.difference(_lastRefill).inMilliseconds / 1000.0;

    _tokens = (_tokens + elapsed * refillRate).clamp(0.0, capacity.toDouble());
    _lastRefill = now;
  }

  /// Get number of available tokens
  int get availableTokens {
    _refill();
    return _tokens.floor();
  }

  /// Get time until next token is available
  Duration? getNextTokenTime() {
    _refill();

    if (_tokens >= 1) return null;

    final tokensNeeded = 1 - _tokens;
    final secondsToWait = tokensNeeded / refillRate;

    return Duration(milliseconds: (secondsToWait * 1000).ceil());
  }
}

/// Rate limit configuration
class RateLimitConfig {
  final int requestsPerMinute;
  final int burstSize;

  const RateLimitConfig({
    required this.requestsPerMinute,
    required this.burstSize,
  });
}

/// Rate limit state tracking
class RateLimitState {
  bool isRateLimited = false;
  DateTime rateLimitResetTime = DateTime.now();
  int consecutiveSuccesses = 0;
}

/// Queued request with priority
class QueuedRequest<T> {
  final Future<T> Function() operation;
  final Completer<T> completer;
  final RequestPriority priority;
  final DateTime queuedAt;
  final Duration timeout;

  QueuedRequest({
    required this.operation,
    required this.completer,
    required this.priority,
    required this.queuedAt,
    required this.timeout,
  });
}

/// Request priority levels
enum RequestPriority {
  low(0),
  normal(1),
  high(2),
  critical(3);

  const RequestPriority(this.value);
  final int value;
}
