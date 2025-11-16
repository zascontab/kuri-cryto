// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'optimization_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$optimizationResultHash() =>
    r'4ee4e659bff72ca39af07b4ce19e8a898e6803d2';

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

/// Provider for optimization results
///
/// Fetches results for a specific optimization ID
///
/// Copied from [optimizationResult].
@ProviderFor(optimizationResult)
const optimizationResultProvider = OptimizationResultFamily();

/// Provider for optimization results
///
/// Fetches results for a specific optimization ID
///
/// Copied from [optimizationResult].
class OptimizationResultFamily extends Family<AsyncValue<OptimizationResult>> {
  /// Provider for optimization results
  ///
  /// Fetches results for a specific optimization ID
  ///
  /// Copied from [optimizationResult].
  const OptimizationResultFamily();

  /// Provider for optimization results
  ///
  /// Fetches results for a specific optimization ID
  ///
  /// Copied from [optimizationResult].
  OptimizationResultProvider call(
    String optimizationId,
  ) {
    return OptimizationResultProvider(
      optimizationId,
    );
  }

  @override
  OptimizationResultProvider getProviderOverride(
    covariant OptimizationResultProvider provider,
  ) {
    return call(
      provider.optimizationId,
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
  String? get name => r'optimizationResultProvider';
}

/// Provider for optimization results
///
/// Fetches results for a specific optimization ID
///
/// Copied from [optimizationResult].
class OptimizationResultProvider
    extends AutoDisposeFutureProvider<OptimizationResult> {
  /// Provider for optimization results
  ///
  /// Fetches results for a specific optimization ID
  ///
  /// Copied from [optimizationResult].
  OptimizationResultProvider(
    String optimizationId,
  ) : this._internal(
          (ref) => optimizationResult(
            ref as OptimizationResultRef,
            optimizationId,
          ),
          from: optimizationResultProvider,
          name: r'optimizationResultProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$optimizationResultHash,
          dependencies: OptimizationResultFamily._dependencies,
          allTransitiveDependencies:
              OptimizationResultFamily._allTransitiveDependencies,
          optimizationId: optimizationId,
        );

  OptimizationResultProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.optimizationId,
  }) : super.internal();

  final String optimizationId;

  @override
  Override overrideWith(
    FutureOr<OptimizationResult> Function(OptimizationResultRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OptimizationResultProvider._internal(
        (ref) => create(ref as OptimizationResultRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        optimizationId: optimizationId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<OptimizationResult> createElement() {
    return _OptimizationResultProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OptimizationResultProvider &&
        other.optimizationId == optimizationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, optimizationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin OptimizationResultRef
    on AutoDisposeFutureProviderRef<OptimizationResult> {
  /// The parameter `optimizationId` of this provider.
  String get optimizationId;
}

class _OptimizationResultProviderElement
    extends AutoDisposeFutureProviderElement<OptimizationResult>
    with OptimizationResultRef {
  _OptimizationResultProviderElement(super.provider);

  @override
  String get optimizationId =>
      (origin as OptimizationResultProvider).optimizationId;
}

String _$availableOptimizationStrategiesHash() =>
    r'be5df8d517abec682c393abe7ed2f0d7fc509593';

/// Provider for available optimization strategies
///
/// Fetches list of strategies available for optimization
///
/// Copied from [availableOptimizationStrategies].
@ProviderFor(availableOptimizationStrategies)
final availableOptimizationStrategiesProvider =
    AutoDisposeFutureProvider<List<String>>.internal(
  availableOptimizationStrategies,
  name: r'availableOptimizationStrategiesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableOptimizationStrategiesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AvailableOptimizationStrategiesRef
    = AutoDisposeFutureProviderRef<List<String>>;
String _$defaultParameterRangesHash() =>
    r'701cb4199c06f7435f36a79da09b185a42ac8de7';

/// Provider for default parameter ranges
///
/// Fetches default parameter ranges for a specific strategy
///
/// Copied from [defaultParameterRanges].
@ProviderFor(defaultParameterRanges)
const defaultParameterRangesProvider = DefaultParameterRangesFamily();

/// Provider for default parameter ranges
///
/// Fetches default parameter ranges for a specific strategy
///
/// Copied from [defaultParameterRanges].
class DefaultParameterRangesFamily
    extends Family<AsyncValue<List<ParameterRange>>> {
  /// Provider for default parameter ranges
  ///
  /// Fetches default parameter ranges for a specific strategy
  ///
  /// Copied from [defaultParameterRanges].
  const DefaultParameterRangesFamily();

  /// Provider for default parameter ranges
  ///
  /// Fetches default parameter ranges for a specific strategy
  ///
  /// Copied from [defaultParameterRanges].
  DefaultParameterRangesProvider call(
    String strategyName,
  ) {
    return DefaultParameterRangesProvider(
      strategyName,
    );
  }

  @override
  DefaultParameterRangesProvider getProviderOverride(
    covariant DefaultParameterRangesProvider provider,
  ) {
    return call(
      provider.strategyName,
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
  String? get name => r'defaultParameterRangesProvider';
}

/// Provider for default parameter ranges
///
/// Fetches default parameter ranges for a specific strategy
///
/// Copied from [defaultParameterRanges].
class DefaultParameterRangesProvider
    extends AutoDisposeFutureProvider<List<ParameterRange>> {
  /// Provider for default parameter ranges
  ///
  /// Fetches default parameter ranges for a specific strategy
  ///
  /// Copied from [defaultParameterRanges].
  DefaultParameterRangesProvider(
    String strategyName,
  ) : this._internal(
          (ref) => defaultParameterRanges(
            ref as DefaultParameterRangesRef,
            strategyName,
          ),
          from: defaultParameterRangesProvider,
          name: r'defaultParameterRangesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$defaultParameterRangesHash,
          dependencies: DefaultParameterRangesFamily._dependencies,
          allTransitiveDependencies:
              DefaultParameterRangesFamily._allTransitiveDependencies,
          strategyName: strategyName,
        );

  DefaultParameterRangesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.strategyName,
  }) : super.internal();

  final String strategyName;

  @override
  Override overrideWith(
    FutureOr<List<ParameterRange>> Function(DefaultParameterRangesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DefaultParameterRangesProvider._internal(
        (ref) => create(ref as DefaultParameterRangesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        strategyName: strategyName,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ParameterRange>> createElement() {
    return _DefaultParameterRangesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DefaultParameterRangesProvider &&
        other.strategyName == strategyName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, strategyName.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DefaultParameterRangesRef
    on AutoDisposeFutureProviderRef<List<ParameterRange>> {
  /// The parameter `strategyName` of this provider.
  String get strategyName;
}

class _DefaultParameterRangesProviderElement
    extends AutoDisposeFutureProviderElement<List<ParameterRange>>
    with DefaultParameterRangesRef {
  _DefaultParameterRangesProviderElement(super.provider);

  @override
  String get strategyName =>
      (origin as DefaultParameterRangesProvider).strategyName;
}

String _$estimatedCombinationsHash() =>
    r'37cc6a7dbaf0f542bbe1917656a66cafb8604d89';

/// Provider to calculate total combinations
///
/// Estimates total parameter combinations for current config
///
/// Copied from [estimatedCombinations].
@ProviderFor(estimatedCombinations)
final estimatedCombinationsProvider = AutoDisposeProvider<int>.internal(
  estimatedCombinations,
  name: r'estimatedCombinationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$estimatedCombinationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef EstimatedCombinationsRef = AutoDisposeProviderRef<int>;
String _$isOptimizationConfigValidHash() =>
    r'406a1324f242e53138457e2f3cad19a077482ea4';

/// Provider to check if configuration is valid
///
/// Copied from [isOptimizationConfigValid].
@ProviderFor(isOptimizationConfigValid)
final isOptimizationConfigValidProvider = AutoDisposeProvider<bool>.internal(
  isOptimizationConfigValid,
  name: r'isOptimizationConfigValidProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isOptimizationConfigValidHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsOptimizationConfigValidRef = AutoDisposeProviderRef<bool>;
String _$optimizationRunnerHash() =>
    r'8264b7bc39d792374fe15ee4ea3e5605c9277db6';

/// Provider for running an optimization
///
/// Executes an optimization and returns the optimization ID
///
/// Copied from [OptimizationRunner].
@ProviderFor(OptimizationRunner)
final optimizationRunnerProvider =
    AutoDisposeAsyncNotifierProvider<OptimizationRunner, String?>.internal(
  OptimizationRunner.new,
  name: r'optimizationRunnerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$optimizationRunnerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OptimizationRunner = AutoDisposeAsyncNotifier<String?>;
String _$optimizationHistoryHash() =>
    r'5e582206265995dc27cd9069505e0146025398d3';

abstract class _$OptimizationHistory
    extends BuildlessAutoDisposeAsyncNotifier<List<OptimizationSummary>> {
  late final int limit;

  FutureOr<List<OptimizationSummary>> build({
    int limit = 50,
  });
}

/// Provider for optimization history
///
/// Fetches all past optimizations
///
/// Copied from [OptimizationHistory].
@ProviderFor(OptimizationHistory)
const optimizationHistoryProvider = OptimizationHistoryFamily();

/// Provider for optimization history
///
/// Fetches all past optimizations
///
/// Copied from [OptimizationHistory].
class OptimizationHistoryFamily
    extends Family<AsyncValue<List<OptimizationSummary>>> {
  /// Provider for optimization history
  ///
  /// Fetches all past optimizations
  ///
  /// Copied from [OptimizationHistory].
  const OptimizationHistoryFamily();

  /// Provider for optimization history
  ///
  /// Fetches all past optimizations
  ///
  /// Copied from [OptimizationHistory].
  OptimizationHistoryProvider call({
    int limit = 50,
  }) {
    return OptimizationHistoryProvider(
      limit: limit,
    );
  }

  @override
  OptimizationHistoryProvider getProviderOverride(
    covariant OptimizationHistoryProvider provider,
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
  String? get name => r'optimizationHistoryProvider';
}

/// Provider for optimization history
///
/// Fetches all past optimizations
///
/// Copied from [OptimizationHistory].
class OptimizationHistoryProvider extends AutoDisposeAsyncNotifierProviderImpl<
    OptimizationHistory, List<OptimizationSummary>> {
  /// Provider for optimization history
  ///
  /// Fetches all past optimizations
  ///
  /// Copied from [OptimizationHistory].
  OptimizationHistoryProvider({
    int limit = 50,
  }) : this._internal(
          () => OptimizationHistory()..limit = limit,
          from: optimizationHistoryProvider,
          name: r'optimizationHistoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$optimizationHistoryHash,
          dependencies: OptimizationHistoryFamily._dependencies,
          allTransitiveDependencies:
              OptimizationHistoryFamily._allTransitiveDependencies,
          limit: limit,
        );

  OptimizationHistoryProvider._internal(
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
  FutureOr<List<OptimizationSummary>> runNotifierBuild(
    covariant OptimizationHistory notifier,
  ) {
    return notifier.build(
      limit: limit,
    );
  }

  @override
  Override overrideWith(OptimizationHistory Function() create) {
    return ProviderOverride(
      origin: this,
      override: OptimizationHistoryProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<OptimizationHistory,
      List<OptimizationSummary>> createElement() {
    return _OptimizationHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OptimizationHistoryProvider && other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin OptimizationHistoryRef
    on AutoDisposeAsyncNotifierProviderRef<List<OptimizationSummary>> {
  /// The parameter `limit` of this provider.
  int get limit;
}

class _OptimizationHistoryProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<OptimizationHistory,
        List<OptimizationSummary>> with OptimizationHistoryRef {
  _OptimizationHistoryProviderElement(super.provider);

  @override
  int get limit => (origin as OptimizationHistoryProvider).limit;
}

String _$selectedOptimizationHash() =>
    r'00d517a9806732dee1c4fd2cfed697360b29cb31';

/// Provider for currently selected optimization
///
/// Manages the currently selected optimization for viewing
///
/// Copied from [SelectedOptimization].
@ProviderFor(SelectedOptimization)
final selectedOptimizationProvider = AutoDisposeNotifierProvider<
    SelectedOptimization, OptimizationResult?>.internal(
  SelectedOptimization.new,
  name: r'selectedOptimizationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedOptimizationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedOptimization = AutoDisposeNotifier<OptimizationResult?>;
String _$optimizationConfigFormHash() =>
    r'4e6fa003816a87936507d687d71118e40220afec';

/// Provider for optimization configuration form state
///
/// Manages the state of the optimization configuration form
///
/// Copied from [OptimizationConfigForm].
@ProviderFor(OptimizationConfigForm)
final optimizationConfigFormProvider = AutoDisposeNotifierProvider<
    OptimizationConfigForm, OptimizationConfig>.internal(
  OptimizationConfigForm.new,
  name: r'optimizationConfigFormProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$optimizationConfigFormHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OptimizationConfigForm = AutoDisposeNotifier<OptimizationConfig>;
String _$currentOptimizationHash() =>
    r'8a387338d64e5fc95f20d8afe0bbb0e3e16fd5a3';

/// Provider for currently running optimization
///
/// Tracks the current optimization in progress
///
/// Copied from [CurrentOptimization].
@ProviderFor(CurrentOptimization)
final currentOptimizationProvider =
    AutoDisposeNotifierProvider<CurrentOptimization, String?>.internal(
  CurrentOptimization.new,
  name: r'currentOptimizationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentOptimizationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentOptimization = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
