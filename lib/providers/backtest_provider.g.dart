// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backtest_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$backtestResultHash() => r'8437d8a7738d98c0ec0440baa0929ff148a93ad2';

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

/// Provider for backtest results
///
/// Fetches results for a specific backtest ID
///
/// Copied from [backtestResult].
@ProviderFor(backtestResult)
const backtestResultProvider = BacktestResultFamily();

/// Provider for backtest results
///
/// Fetches results for a specific backtest ID
///
/// Copied from [backtestResult].
class BacktestResultFamily extends Family<AsyncValue<BacktestResult>> {
  /// Provider for backtest results
  ///
  /// Fetches results for a specific backtest ID
  ///
  /// Copied from [backtestResult].
  const BacktestResultFamily();

  /// Provider for backtest results
  ///
  /// Fetches results for a specific backtest ID
  ///
  /// Copied from [backtestResult].
  BacktestResultProvider call(
    String backtestId,
  ) {
    return BacktestResultProvider(
      backtestId,
    );
  }

  @override
  BacktestResultProvider getProviderOverride(
    covariant BacktestResultProvider provider,
  ) {
    return call(
      provider.backtestId,
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
  String? get name => r'backtestResultProvider';
}

/// Provider for backtest results
///
/// Fetches results for a specific backtest ID
///
/// Copied from [backtestResult].
class BacktestResultProvider extends AutoDisposeFutureProvider<BacktestResult> {
  /// Provider for backtest results
  ///
  /// Fetches results for a specific backtest ID
  ///
  /// Copied from [backtestResult].
  BacktestResultProvider(
    String backtestId,
  ) : this._internal(
          (ref) => backtestResult(
            ref as BacktestResultRef,
            backtestId,
          ),
          from: backtestResultProvider,
          name: r'backtestResultProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$backtestResultHash,
          dependencies: BacktestResultFamily._dependencies,
          allTransitiveDependencies:
              BacktestResultFamily._allTransitiveDependencies,
          backtestId: backtestId,
        );

  BacktestResultProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.backtestId,
  }) : super.internal();

  final String backtestId;

  @override
  Override overrideWith(
    FutureOr<BacktestResult> Function(BacktestResultRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BacktestResultProvider._internal(
        (ref) => create(ref as BacktestResultRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        backtestId: backtestId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<BacktestResult> createElement() {
    return _BacktestResultProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BacktestResultProvider && other.backtestId == backtestId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, backtestId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BacktestResultRef on AutoDisposeFutureProviderRef<BacktestResult> {
  /// The parameter `backtestId` of this provider.
  String get backtestId;
}

class _BacktestResultProviderElement
    extends AutoDisposeFutureProviderElement<BacktestResult>
    with BacktestResultRef {
  _BacktestResultProviderElement(super.provider);

  @override
  String get backtestId => (origin as BacktestResultProvider).backtestId;
}

String _$backtestStatusHash() => r'4fd44418bc66325f7b0aa02068a8a692e3e4f320';

/// Provider for backtest status
///
/// Checks the status of a running backtest
///
/// Copied from [backtestStatus].
@ProviderFor(backtestStatus)
const backtestStatusProvider = BacktestStatusFamily();

/// Provider for backtest status
///
/// Checks the status of a running backtest
///
/// Copied from [backtestStatus].
class BacktestStatusFamily extends Family<AsyncValue<String>> {
  /// Provider for backtest status
  ///
  /// Checks the status of a running backtest
  ///
  /// Copied from [backtestStatus].
  const BacktestStatusFamily();

  /// Provider for backtest status
  ///
  /// Checks the status of a running backtest
  ///
  /// Copied from [backtestStatus].
  BacktestStatusProvider call(
    String backtestId,
  ) {
    return BacktestStatusProvider(
      backtestId,
    );
  }

  @override
  BacktestStatusProvider getProviderOverride(
    covariant BacktestStatusProvider provider,
  ) {
    return call(
      provider.backtestId,
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
  String? get name => r'backtestStatusProvider';
}

/// Provider for backtest status
///
/// Checks the status of a running backtest
///
/// Copied from [backtestStatus].
class BacktestStatusProvider extends AutoDisposeFutureProvider<String> {
  /// Provider for backtest status
  ///
  /// Checks the status of a running backtest
  ///
  /// Copied from [backtestStatus].
  BacktestStatusProvider(
    String backtestId,
  ) : this._internal(
          (ref) => backtestStatus(
            ref as BacktestStatusRef,
            backtestId,
          ),
          from: backtestStatusProvider,
          name: r'backtestStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$backtestStatusHash,
          dependencies: BacktestStatusFamily._dependencies,
          allTransitiveDependencies:
              BacktestStatusFamily._allTransitiveDependencies,
          backtestId: backtestId,
        );

  BacktestStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.backtestId,
  }) : super.internal();

  final String backtestId;

  @override
  Override overrideWith(
    FutureOr<String> Function(BacktestStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BacktestStatusProvider._internal(
        (ref) => create(ref as BacktestStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        backtestId: backtestId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _BacktestStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BacktestStatusProvider && other.backtestId == backtestId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, backtestId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BacktestStatusRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `backtestId` of this provider.
  String get backtestId;
}

class _BacktestStatusProviderElement
    extends AutoDisposeFutureProviderElement<String> with BacktestStatusRef {
  _BacktestStatusProviderElement(super.provider);

  @override
  String get backtestId => (origin as BacktestStatusProvider).backtestId;
}

String _$availableBacktestStrategiesHash() =>
    r'545e33f1da1ace5ff2789d65463621db120df037';

/// Provider for available strategies
///
/// Fetches list of strategies available for backtesting
///
/// Copied from [availableBacktestStrategies].
@ProviderFor(availableBacktestStrategies)
final availableBacktestStrategiesProvider =
    AutoDisposeFutureProvider<List<String>>.internal(
  availableBacktestStrategies,
  name: r'availableBacktestStrategiesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableBacktestStrategiesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AvailableBacktestStrategiesRef
    = AutoDisposeFutureProviderRef<List<String>>;
String _$isBacktestProfitableHash() =>
    r'83316b25f39314018da5f37be94c5043106200cb';

/// Provider to check if backtest is profitable
///
/// Copied from [isBacktestProfitable].
@ProviderFor(isBacktestProfitable)
const isBacktestProfitableProvider = IsBacktestProfitableFamily();

/// Provider to check if backtest is profitable
///
/// Copied from [isBacktestProfitable].
class IsBacktestProfitableFamily extends Family<bool> {
  /// Provider to check if backtest is profitable
  ///
  /// Copied from [isBacktestProfitable].
  const IsBacktestProfitableFamily();

  /// Provider to check if backtest is profitable
  ///
  /// Copied from [isBacktestProfitable].
  IsBacktestProfitableProvider call(
    BacktestResult result,
  ) {
    return IsBacktestProfitableProvider(
      result,
    );
  }

  @override
  IsBacktestProfitableProvider getProviderOverride(
    covariant IsBacktestProfitableProvider provider,
  ) {
    return call(
      provider.result,
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
  String? get name => r'isBacktestProfitableProvider';
}

/// Provider to check if backtest is profitable
///
/// Copied from [isBacktestProfitable].
class IsBacktestProfitableProvider extends AutoDisposeProvider<bool> {
  /// Provider to check if backtest is profitable
  ///
  /// Copied from [isBacktestProfitable].
  IsBacktestProfitableProvider(
    BacktestResult result,
  ) : this._internal(
          (ref) => isBacktestProfitable(
            ref as IsBacktestProfitableRef,
            result,
          ),
          from: isBacktestProfitableProvider,
          name: r'isBacktestProfitableProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isBacktestProfitableHash,
          dependencies: IsBacktestProfitableFamily._dependencies,
          allTransitiveDependencies:
              IsBacktestProfitableFamily._allTransitiveDependencies,
          result: result,
        );

  IsBacktestProfitableProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.result,
  }) : super.internal();

  final BacktestResult result;

  @override
  Override overrideWith(
    bool Function(IsBacktestProfitableRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsBacktestProfitableProvider._internal(
        (ref) => create(ref as IsBacktestProfitableRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        result: result,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsBacktestProfitableProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsBacktestProfitableProvider && other.result == result;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, result.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin IsBacktestProfitableRef on AutoDisposeProviderRef<bool> {
  /// The parameter `result` of this provider.
  BacktestResult get result;
}

class _IsBacktestProfitableProviderElement
    extends AutoDisposeProviderElement<bool> with IsBacktestProfitableRef {
  _IsBacktestProfitableProviderElement(super.provider);

  @override
  BacktestResult get result => (origin as IsBacktestProfitableProvider).result;
}

String _$backtestPerformanceRatingHash() =>
    r'febe46484c7fece152f144ba5cb8882aafe6dd61';

/// Provider to get performance rating
///
/// Copied from [backtestPerformanceRating].
@ProviderFor(backtestPerformanceRating)
const backtestPerformanceRatingProvider = BacktestPerformanceRatingFamily();

/// Provider to get performance rating
///
/// Copied from [backtestPerformanceRating].
class BacktestPerformanceRatingFamily extends Family<String> {
  /// Provider to get performance rating
  ///
  /// Copied from [backtestPerformanceRating].
  const BacktestPerformanceRatingFamily();

  /// Provider to get performance rating
  ///
  /// Copied from [backtestPerformanceRating].
  BacktestPerformanceRatingProvider call(
    BacktestResult result,
  ) {
    return BacktestPerformanceRatingProvider(
      result,
    );
  }

  @override
  BacktestPerformanceRatingProvider getProviderOverride(
    covariant BacktestPerformanceRatingProvider provider,
  ) {
    return call(
      provider.result,
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
  String? get name => r'backtestPerformanceRatingProvider';
}

/// Provider to get performance rating
///
/// Copied from [backtestPerformanceRating].
class BacktestPerformanceRatingProvider extends AutoDisposeProvider<String> {
  /// Provider to get performance rating
  ///
  /// Copied from [backtestPerformanceRating].
  BacktestPerformanceRatingProvider(
    BacktestResult result,
  ) : this._internal(
          (ref) => backtestPerformanceRating(
            ref as BacktestPerformanceRatingRef,
            result,
          ),
          from: backtestPerformanceRatingProvider,
          name: r'backtestPerformanceRatingProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$backtestPerformanceRatingHash,
          dependencies: BacktestPerformanceRatingFamily._dependencies,
          allTransitiveDependencies:
              BacktestPerformanceRatingFamily._allTransitiveDependencies,
          result: result,
        );

  BacktestPerformanceRatingProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.result,
  }) : super.internal();

  final BacktestResult result;

  @override
  Override overrideWith(
    String Function(BacktestPerformanceRatingRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BacktestPerformanceRatingProvider._internal(
        (ref) => create(ref as BacktestPerformanceRatingRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        result: result,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<String> createElement() {
    return _BacktestPerformanceRatingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BacktestPerformanceRatingProvider && other.result == result;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, result.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BacktestPerformanceRatingRef on AutoDisposeProviderRef<String> {
  /// The parameter `result` of this provider.
  BacktestResult get result;
}

class _BacktestPerformanceRatingProviderElement
    extends AutoDisposeProviderElement<String>
    with BacktestPerformanceRatingRef {
  _BacktestPerformanceRatingProviderElement(super.provider);

  @override
  BacktestResult get result =>
      (origin as BacktestPerformanceRatingProvider).result;
}

String _$backtestRunnerHash() => r'965f1df46147d8fc9ca7197cd1b2740059419e11';

/// Provider for running a backtest
///
/// Executes a backtest and returns the backtest ID
///
/// Copied from [BacktestRunner].
@ProviderFor(BacktestRunner)
final backtestRunnerProvider =
    AutoDisposeAsyncNotifierProvider<BacktestRunner, String?>.internal(
  BacktestRunner.new,
  name: r'backtestRunnerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$backtestRunnerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BacktestRunner = AutoDisposeAsyncNotifier<String?>;
String _$backtestListHash() => r'39617332c01a7a7e6da46b2384ce1d72bc11e19e';

abstract class _$BacktestList
    extends BuildlessAutoDisposeAsyncNotifier<List<BacktestResult>> {
  late final int limit;

  FutureOr<List<BacktestResult>> build({
    int limit = 50,
  });
}

/// Provider for list of all backtests
///
/// Fetches all backtests (recent first)
///
/// Copied from [BacktestList].
@ProviderFor(BacktestList)
const backtestListProvider = BacktestListFamily();

/// Provider for list of all backtests
///
/// Fetches all backtests (recent first)
///
/// Copied from [BacktestList].
class BacktestListFamily extends Family<AsyncValue<List<BacktestResult>>> {
  /// Provider for list of all backtests
  ///
  /// Fetches all backtests (recent first)
  ///
  /// Copied from [BacktestList].
  const BacktestListFamily();

  /// Provider for list of all backtests
  ///
  /// Fetches all backtests (recent first)
  ///
  /// Copied from [BacktestList].
  BacktestListProvider call({
    int limit = 50,
  }) {
    return BacktestListProvider(
      limit: limit,
    );
  }

  @override
  BacktestListProvider getProviderOverride(
    covariant BacktestListProvider provider,
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
  String? get name => r'backtestListProvider';
}

/// Provider for list of all backtests
///
/// Fetches all backtests (recent first)
///
/// Copied from [BacktestList].
class BacktestListProvider extends AutoDisposeAsyncNotifierProviderImpl<
    BacktestList, List<BacktestResult>> {
  /// Provider for list of all backtests
  ///
  /// Fetches all backtests (recent first)
  ///
  /// Copied from [BacktestList].
  BacktestListProvider({
    int limit = 50,
  }) : this._internal(
          () => BacktestList()..limit = limit,
          from: backtestListProvider,
          name: r'backtestListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$backtestListHash,
          dependencies: BacktestListFamily._dependencies,
          allTransitiveDependencies:
              BacktestListFamily._allTransitiveDependencies,
          limit: limit,
        );

  BacktestListProvider._internal(
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
  FutureOr<List<BacktestResult>> runNotifierBuild(
    covariant BacktestList notifier,
  ) {
    return notifier.build(
      limit: limit,
    );
  }

  @override
  Override overrideWith(BacktestList Function() create) {
    return ProviderOverride(
      origin: this,
      override: BacktestListProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<BacktestList, List<BacktestResult>>
      createElement() {
    return _BacktestListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BacktestListProvider && other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BacktestListRef
    on AutoDisposeAsyncNotifierProviderRef<List<BacktestResult>> {
  /// The parameter `limit` of this provider.
  int get limit;
}

class _BacktestListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<BacktestList,
        List<BacktestResult>> with BacktestListRef {
  _BacktestListProviderElement(super.provider);

  @override
  int get limit => (origin as BacktestListProvider).limit;
}

String _$selectedBacktestHash() => r'5b19c67a3a60065a7a718d9a7e201f2f73ea02f5';

/// Provider for selected backtest result
///
/// Manages the currently selected backtest for viewing
///
/// Copied from [SelectedBacktest].
@ProviderFor(SelectedBacktest)
final selectedBacktestProvider =
    AutoDisposeNotifierProvider<SelectedBacktest, BacktestResult?>.internal(
  SelectedBacktest.new,
  name: r'selectedBacktestProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedBacktestHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedBacktest = AutoDisposeNotifier<BacktestResult?>;
String _$backtestConfigFormHash() =>
    r'64d0d0352152b999d5fb8627727210b9ef22848d';

/// Provider for backtest configuration form state
///
/// Manages the state of the backtest configuration form
///
/// Copied from [BacktestConfigForm].
@ProviderFor(BacktestConfigForm)
final backtestConfigFormProvider =
    AutoDisposeNotifierProvider<BacktestConfigForm, BacktestConfig>.internal(
  BacktestConfigForm.new,
  name: r'backtestConfigFormProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$backtestConfigFormHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BacktestConfigForm = AutoDisposeNotifier<BacktestConfig>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
