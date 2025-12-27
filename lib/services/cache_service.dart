import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'logging_service.dart';

/// Service for caching data with TTL (Time To Live) support
///
/// Features:
/// - In-memory cache for fast access
/// - Persistent cache using SharedPreferences
/// - TTL support for automatic expiration
/// - Cache invalidation
/// - Memory management
class CacheService {
  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService._();

  CacheService._();

  final Map<String, CacheEntry> _memoryCache = {};
  SharedPreferences? _prefs;
  static const int _maxMemoryCacheSize = 100;

  /// Initialize the cache service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      LoggingService.instance.info(
        'Cache service initialized',
        tag: 'CacheService',
      );
    } catch (e) {
      LoggingService.instance.error(
        'Failed to initialize cache service',
        tag: 'CacheService',
        error: e,
      );
    }
  }

  /// Store data in cache with TTL
  Future<void> set<T>(
    String key,
    T data, {
    Duration? ttl,
    bool persistToDisk = false,
  }) async {
    final entry = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl,
    );

    // Store in memory cache
    _memoryCache[key] = entry;
    _cleanupMemoryCache();

    // Store in persistent cache if requested
    if (persistToDisk && _prefs != null) {
      try {
        final serializedData = _serializeData(data);
        if (serializedData != null) {
          await _prefs!.setString(key, serializedData);
          if (ttl != null) {
            await _prefs!.setInt(
              '${key}_expires',
              DateTime.now().add(ttl).millisecondsSinceEpoch,
            );
          }
        }
      } catch (e) {
        LoggingService.instance.error(
          'Failed to persist cache entry',
          tag: 'CacheService',
          context: {'key': key},
          error: e,
        );
      }
    }

    LoggingService.instance.debug(
      'Cache entry stored',
      tag: 'CacheService',
      context: {
        'key': key,
        'ttl_seconds': ttl?.inSeconds,
        'persist_to_disk': persistToDisk,
      },
    );
  }

  /// Get data from cache
  T? get<T>(String key) {
    // Check memory cache first
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null && !memoryEntry.isExpired) {
      LoggingService.instance.debug(
        'Cache hit (memory)',
        tag: 'CacheService',
        context: {'key': key},
      );
      return memoryEntry.data as T?;
    }

    // Check persistent cache
    if (_prefs != null) {
      try {
        final serializedData = _prefs!.getString(key);
        if (serializedData != null) {
          // Check if expired
          final expiresAt = _prefs!.getInt('${key}_expires');
          if (expiresAt != null &&
              DateTime.now().millisecondsSinceEpoch > expiresAt) {
            // Expired, remove from persistent cache
            _prefs!.remove(key);
            _prefs!.remove('${key}_expires');
            LoggingService.instance.debug(
              'Cache entry expired (disk)',
              tag: 'CacheService',
              context: {'key': key},
            );
            return null;
          }

          final data = _deserializeData<T>(serializedData);
          if (data != null) {
            // Store back in memory cache for faster access
            _memoryCache[key] = CacheEntry(
              data: data,
              timestamp: DateTime.now(),
              ttl: expiresAt != null
                  ? Duration(
                      milliseconds:
                          expiresAt - DateTime.now().millisecondsSinceEpoch,
                    )
                  : null,
            );

            LoggingService.instance.debug(
              'Cache hit (disk)',
              tag: 'CacheService',
              context: {'key': key},
            );
            return data;
          }
        }
      } catch (e) {
        LoggingService.instance.error(
          'Failed to read from persistent cache',
          tag: 'CacheService',
          context: {'key': key},
          error: e,
        );
      }
    }

    LoggingService.instance.debug(
      'Cache miss',
      tag: 'CacheService',
      context: {'key': key},
    );
    return null;
  }

  /// Check if key exists and is not expired
  bool has(String key) {
    return get<dynamic>(key) != null;
  }

  /// Remove specific key from cache
  Future<void> remove(String key) async {
    _memoryCache.remove(key);

    if (_prefs != null) {
      await _prefs!.remove(key);
      await _prefs!.remove('${key}_expires');
    }

    LoggingService.instance.debug(
      'Cache entry removed',
      tag: 'CacheService',
      context: {'key': key},
    );
  }

  /// Clear all cache
  Future<void> clear() async {
    _memoryCache.clear();

    if (_prefs != null) {
      final keys = _prefs!.getKeys().where((key) => !key.endsWith('_expires'));
      for (final key in keys) {
        await _prefs!.remove(key);
        await _prefs!.remove('${key}_expires');
      }
    }

    LoggingService.instance.info(
      'All cache cleared',
      tag: 'CacheService',
    );
  }

  /// Get or set pattern - if key exists return it, otherwise compute and cache
  Future<T> getOrSet<T>(
    String key,
    Future<T> Function() compute, {
    Duration? ttl,
    bool persistToDisk = false,
  }) async {
    final cached = get<T>(key);
    if (cached != null) {
      return cached;
    }

    final computed = await compute();
    await set(key, computed, ttl: ttl, persistToDisk: persistToDisk);
    return computed;
  }

  /// Get cache statistics
  CacheStats getStats() {
    final memoryEntries = _memoryCache.length;
    final expiredEntries =
        _memoryCache.values.where((entry) => entry.isExpired).length;

    return CacheStats(
      memoryEntries: memoryEntries,
      expiredEntries: expiredEntries,
      hitRate: 0.0, // Would need to track hits/misses for accurate rate
    );
  }

  /// Clean up expired entries and manage memory usage
  void _cleanupMemoryCache() {
    // Remove expired entries
    _memoryCache.removeWhere((key, entry) => entry.isExpired);

    // If still over limit, remove oldest entries
    if (_memoryCache.length > _maxMemoryCacheSize) {
      final sortedEntries = _memoryCache.entries.toList()
        ..sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));

      final toRemove = sortedEntries.take(
        _memoryCache.length - _maxMemoryCacheSize,
      );

      for (final entry in toRemove) {
        _memoryCache.remove(entry.key);
      }

      LoggingService.instance.debug(
        'Memory cache cleaned up',
        tag: 'CacheService',
        context: {
          'removed_entries': toRemove.length,
          'current_size': _memoryCache.length,
        },
      );
    }
  }

  /// Serialize data for persistent storage
  String? _serializeData<T>(T data) {
    try {
      if (data is String) {
        return data;
      } else if (data is Map || data is List) {
        return jsonEncode(data);
      } else {
        // For custom objects, they should implement toJson()
        try {
          final dynamic obj = data;
          if (obj.toJson != null) {
            return jsonEncode(obj.toJson());
          }
        } catch (e) {
          // Object doesn't have toJson method
        }
      }
    } catch (e) {
      LoggingService.instance.error(
        'Failed to serialize data',
        tag: 'CacheService',
        error: e,
      );
    }
    return null;
  }

  /// Deserialize data from persistent storage
  T? _deserializeData<T>(String serializedData) {
    try {
      if (T == String) {
        return serializedData as T;
      } else {
        final decoded = jsonDecode(serializedData);
        return decoded as T;
      }
    } catch (e) {
      LoggingService.instance.error(
        'Failed to deserialize data',
        tag: 'CacheService',
        error: e,
      );
    }
    return null;
  }
}

/// Cache entry with TTL support
class CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  final Duration? ttl;

  CacheEntry({
    required this.data,
    required this.timestamp,
    this.ttl,
  });

  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().difference(timestamp) > ttl!;
  }
}

/// Cache statistics
class CacheStats {
  final int memoryEntries;
  final int expiredEntries;
  final double hitRate;

  CacheStats({
    required this.memoryEntries,
    required this.expiredEntries,
    required this.hitRate,
  });
}

/// Predefined cache keys for the application
class CacheKeys {
  static const String comprehensiveAnalysis = 'comprehensive_analysis';
  static const String botStatus = 'bot_status';
  static const String botConfig = 'bot_config';
  static const String botPositions = 'bot_positions';
  static const String healthCheck = 'health_check';

  /// Generate cache key for comprehensive analysis
  static String comprehensiveAnalysisKey(String symbol, {String? marketType}) {
    return '${comprehensiveAnalysis}_${symbol}_${marketType ?? 'all'}';
  }

  /// Generate cache key for bot positions
  static String botPositionsKey({String? marketType}) {
    return '${botPositions}_${marketType ?? 'all'}';
  }
}
