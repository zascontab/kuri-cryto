// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'execution_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredExecutionHistoryHash() =>
    r'9e739db9722c11a824eba1ba9dbbae8efaa08878';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Filtered execution history provider
///
/// Returns filtered execution history based on selected filter
///
/// Copied from [filteredExecutionHistory].
@ProviderFor(filteredExecutionHistory)
const filteredExecutionHistoryProvider = FilteredExecutionHistoryFamily();

/// Filtered execution history provider
///
/// Returns filtered execution history based on selected filter
///
/// Copied from [filteredExecutionHistory].
class FilteredExecutionHistoryFamily
    extends Family<List<ExecutionHistoryEntry>> {
  /// Filtered execution history provider
  ///
  /// Returns filtered execution history based on selected filter
  ///
  /// Copied from [filteredExecutionHistory].
  const FilteredExecutionHistoryFamily();

  /// Filtered execution history provider
  ///
  /// Returns filtered execution history based on selected filter
  ///
  /// Copied from [filteredExecutionHistory].
  FilteredExecutionHistoryProvider call({
    int limit = 50,
  }) {
    return FilteredExecutionHistoryProvider(
      limit: limit,
    );
  }

  @override
  FilteredExecutionHistoryProvider getProviderOverride(
    covariant FilteredExecutionHistoryProvider provider,
  ) {
    return call(
      limit: provider.limit,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'filteredExecutionHistoryProvider';
}

/// Filtered execution history provider
///
/// Returns filtered execution history based on selected filter
///
/// Copied from [filteredExecutionHistory].
class FilteredExecutionHistoryProvider
    extends AutoDisposeProvider<List<ExecutionHistoryEntry>> {
  /// Filtered execution history provider
  ///
  /// Returns filtered execution history based on selected filter
  ///
  /// Copied from [filteredExecutionHistory].
  FilteredExecutionHistoryProvider({
    int limit = 50,
  }) : this._internal(
          (ref) => filteredExecutionHistory(
            ref as FilteredExecutionHistoryRef,
            limit: limit,
          ),
          from: filteredExecutionHistoryProvider,
          name: r'filteredExecutionHistoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$filteredExecutionHistoryHash,
          dependencies: FilteredExecutionHistoryFamily._dependencies,
          allTransitiveDependencies:
              FilteredExecutionHistoryFamily._allTransitiveDependencies,
          limit: limit,
        );

  FilteredExecutionHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
  }) : super.internal();

  final int limit;

  @override
  Override overrideWith(
    List<ExecutionHistoryEntry> Function(FilteredExecutionHistoryRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredExecutionHistoryProvider._internal(
        (ref) => create(ref as FilteredExecutionHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<ExecutionHistoryEntry>> createElement() {
    return _FilteredExecutionHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredExecutionHistoryProvider && other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FilteredExecutionHistoryRef
    on AutoDisposeProviderRef<List<ExecutionHistoryEntry>> {
  /// The parameter `limit` of this provider.
  int get limit;
}

class _FilteredExecutionHistoryProviderElement
    extends AutoDisposeProviderElement<List<ExecutionHistoryEntry>>
    with FilteredExecutionHistoryRef {
  _FilteredExecutionHistoryProviderElement(super.provider);

  @override
  int get limit => (origin as FilteredExecutionHistoryProvider).limit;
}

String _$latencyStatsNotifierHash() =>
    r'12a77b0437d9e12669b6cde956c8155795ba82b7';

/// Provider for latency statistics
///
/// Fetches and caches latency metrics including:
/// - Average latency
/// - Percentile distribution (P50, P95, P99)
/// - Min/Max latency values
/// - Total executions measured
///
/// Copied from [LatencyStatsNotifier].
@ProviderFor(LatencyStatsNotifier)
final latencyStatsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    LatencyStatsNotifier, LatencyStats>.internal(
  LatencyStatsNotifier.new,
  name: r'latencyStatsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$latencyStatsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LatencyStatsNotifier = AutoDisposeAsyncNotifier<LatencyStats>;
String _$executionHistoryNotifierHash() =>
    r'141afa9fc9b038a9c2ad13aec04a2cc9bc034d5e';

abstract class _$ExecutionHistoryNotifier
    extends BuildlessAutoDisposeAsyncNotifier<ExecutionHistory> {
  late final int limit;

  FutureOr<ExecutionHistory> build({
    int limit = 50,
  });
}

/// Provider for execution history
///
/// Fetches recent execution history with configurable limit.
/// Includes execution details, latency, status, and errors.
///
/// Parameters:
/// - limit: Maximum number of executions to fetch (default: 50)
///
/// Copied from [ExecutionHistoryNotifier].
@ProviderFor(ExecutionHistoryNotifier)
const executionHistoryNotifierProvider = ExecutionHistoryNotifierFamily();

/// Provider for execution history
///
/// Fetches recent execution history with configurable limit.
/// Includes execution details, latency, status, and errors.
///
/// Parameters:
/// - limit: Maximum number of executions to fetch (default: 50)
///
/// Copied from [ExecutionHistoryNotifier].
class ExecutionHistoryNotifierFamily
    extends Family<AsyncValue<ExecutionHistory>> {
  /// Provider for execution history
  ///
  /// Fetches recent execution history with configurable limit.
  /// Includes execution details, latency, status, and errors.
  ///
  /// Parameters:
  /// - limit: Maximum number of executions to fetch (default: 50)
  ///
  /// Copied from [ExecutionHistoryNotifier].
  const ExecutionHistoryNotifierFamily();

  /// Provider for execution history
  ///
  /// Fetches recent execution history with configurable limit.
  /// Includes execution details, latency, status, and errors.
  ///
  /// Parameters:
  /// - limit: Maximum number of executions to fetch (default: 50)
  ///
  /// Copied from [ExecutionHistoryNotifier].
  ExecutionHistoryNotifierProvider call({
    int limit = 50,
  }) {
    return ExecutionHistoryNotifierProvider(
      limit: limit,
    );
  }

  @override
  ExecutionHistoryNotifierProvider getProviderOverride(
    covariant ExecutionHistoryNotifierProvider provider,
  ) {
    return call(
      limit: provider.limit,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'executionHistoryNotifierProvider';
}

/// Provider for execution history
///
/// Fetches recent execution history with configurable limit.
/// Includes execution details, latency, status, and errors.
///
/// Parameters:
/// - limit: Maximum number of executions to fetch (default: 50)
///
/// Copied from [ExecutionHistoryNotifier].
class ExecutionHistoryNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ExecutionHistoryNotifier,
        ExecutionHistory> {
  /// Provider for execution history
  ///
  /// Fetches recent execution history with configurable limit.
  /// Includes execution details, latency, status, and errors.
  ///
  /// Parameters:
  /// - limit: Maximum number of executions to fetch (default: 50)
  ///
  /// Copied from [ExecutionHistoryNotifier].
  ExecutionHistoryNotifierProvider({
    int limit = 50,
  }) : this._internal(
          () => ExecutionHistoryNotifier()..limit = limit,
          from: executionHistoryNotifierProvider,
          name: r'executionHistoryNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$executionHistoryNotifierHash,
          dependencies: ExecutionHistoryNotifierFamily._dependencies,
          allTransitiveDependencies:
              ExecutionHistoryNotifierFamily._allTransitiveDependencies,
          limit: limit,
        );

  ExecutionHistoryNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
  }) : super.internal();

  final int limit;

  @override
  FutureOr<ExecutionHistory> runNotifierBuild(
    covariant ExecutionHistoryNotifier notifier,
  ) {
    return notifier.build(
      limit: limit,
    );
  }

  @override
  Override overrideWith(ExecutionHistoryNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ExecutionHistoryNotifierProvider._internal(
        () => create()..limit = limit,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ExecutionHistoryNotifier,
      ExecutionHistory> createElement() {
    return _ExecutionHistoryNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExecutionHistoryNotifierProvider && other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ExecutionHistoryNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<ExecutionHistory> {
  /// The parameter `limit` of this provider.
  int get limit;
}

class _ExecutionHistoryNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ExecutionHistoryNotifier,
        ExecutionHistory> with ExecutionHistoryNotifierRef {
  _ExecutionHistoryNotifierProviderElement(super.provider);

  @override
  int get limit => (origin as ExecutionHistoryNotifierProvider).limit;
}

String _$executionQueueNotifierHash() =>
    r'9e733e30e3ff0f84eaf9e6e52d0255acacc669b5';

/// Provider for execution queue state
///
/// Fetches current execution queue including:
/// - Pending orders
/// - Queue length
/// - Average wait time
/// - Queue health status
///
/// Copied from [ExecutionQueueNotifier].
@ProviderFor(ExecutionQueueNotifier)
final executionQueueNotifierProvider = AutoDisposeAsyncNotifierProvider<
    ExecutionQueueNotifier, ExecutionQueue>.internal(
  ExecutionQueueNotifier.new,
  name: r'executionQueueNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$executionQueueNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ExecutionQueueNotifier = AutoDisposeAsyncNotifier<ExecutionQueue>;
String _$executionPerformanceNotifierHash() =>
    r'6f84dcd4ebaab4f44b9bab7abbc7003e05522e95';

/// Provider for execution performance metrics
///
/// Fetches comprehensive performance data:
/// - Slippage statistics
/// - Fill rate
/// - Success/Failure counts
/// - Error rate
/// - Per-symbol metrics
///
/// Copied from [ExecutionPerformanceNotifier].
@ProviderFor(ExecutionPerformanceNotifier)
final executionPerformanceNotifierProvider = AutoDisposeAsyncNotifierProvider<
    ExecutionPerformanceNotifier, ExecutionPerformance>.internal(
  ExecutionPerformanceNotifier.new,
  name: r'executionPerformanceNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$executionPerformanceNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ExecutionPerformanceNotifier
    = AutoDisposeAsyncNotifier<ExecutionPerformance>;
String _$metricsExporterHash() => r'636e9159209570825c1994c77e23dafad2520270';

/// Provider for metrics export
///
/// Exports execution metrics in various formats.
///
/// Parameters:
/// - format: Export format ('csv', 'json', 'excel')
/// - period: Time period ('7d', '30d', '90d', 'all')
/// - metrics: List of metrics to export
///
/// Copied from [MetricsExporter].
@ProviderFor(MetricsExporter)
final metricsExporterProvider = AutoDisposeAsyncNotifierProvider<
    MetricsExporter, MetricsExportResult?>.internal(
  MetricsExporter.new,
  name: r'metricsExporterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$metricsExporterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MetricsExporter = AutoDisposeAsyncNotifier<MetricsExportResult?>;
String _$executionAutoRefreshHash() =>
    r'c0d35ff0b538935b392f6b6fe57fc719f0974080';

/// Provider for auto-refresh configuration
///
/// State provider for controlling auto-refresh behavior
///
/// Copied from [ExecutionAutoRefresh].
@ProviderFor(ExecutionAutoRefresh)
final executionAutoRefreshProvider =
    AutoDisposeNotifierProvider<ExecutionAutoRefresh, bool>.internal(
  ExecutionAutoRefresh.new,
  name: r'executionAutoRefreshProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$executionAutoRefreshHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ExecutionAutoRefresh = AutoDisposeNotifier<bool>;
String _$executionHistoryFilterHash() =>
    r'e85dc8a233c047add82ad1075b9311ea83173ff3';

/// Provider for selected history filter
///
/// Filters execution history by status
///
/// Copied from [ExecutionHistoryFilter].
@ProviderFor(ExecutionHistoryFilter)
final executionHistoryFilterProvider =
    AutoDisposeNotifierProvider<ExecutionHistoryFilter, String>.internal(
  ExecutionHistoryFilter.new,
  name: r'executionHistoryFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$executionHistoryFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ExecutionHistoryFilter = AutoDisposeNotifier<String>;
String _$executionStatsSummaryHash() =>
    r'6c80fe09b830940d145a812cf20bdf134cb36ceb';

/// Provider for execution statistics summary
///
/// Calculates aggregated statistics from execution history
///
/// Copied from [ExecutionStatsSummary].
@ProviderFor(ExecutionStatsSummary)
final executionStatsSummaryProvider = AutoDisposeNotifierProvider<
    ExecutionStatsSummary, ExecutionSummary>.internal(
  ExecutionStatsSummary.new,
  name: r'executionStatsSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$executionStatsSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ExecutionStatsSummary = AutoDisposeNotifier<ExecutionSummary>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
