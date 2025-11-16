// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strategy_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$strategyDetailsHash() => r'99f220c4a42e26fce4f38526268ea2c511d3022a';

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

/// Provider for detailed strategy information
///
/// Fetches comprehensive details for a specific strategy including:
/// - Full configuration
/// - Performance metrics
///
/// Takes strategy name as parameter.
///
/// Copied from [strategyDetails].
@ProviderFor(strategyDetails)
const strategyDetailsProvider = StrategyDetailsFamily();

/// Provider for detailed strategy information
///
/// Fetches comprehensive details for a specific strategy including:
/// - Full configuration
/// - Performance metrics
///
/// Takes strategy name as parameter.
///
/// Copied from [strategyDetails].
class StrategyDetailsFamily extends Family<AsyncValue<Strategy>> {
  /// Provider for detailed strategy information
  ///
  /// Fetches comprehensive details for a specific strategy including:
  /// - Full configuration
  /// - Performance metrics
  ///
  /// Takes strategy name as parameter.
  ///
  /// Copied from [strategyDetails].
  const StrategyDetailsFamily();

  /// Provider for detailed strategy information
  ///
  /// Fetches comprehensive details for a specific strategy including:
  /// - Full configuration
  /// - Performance metrics
  ///
  /// Takes strategy name as parameter.
  ///
  /// Copied from [strategyDetails].
  StrategyDetailsProvider call(
    String strategyName,
  ) {
    return StrategyDetailsProvider(
      strategyName,
    );
  }

  @override
  StrategyDetailsProvider getProviderOverride(
    covariant StrategyDetailsProvider provider,
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
  String? get name => r'strategyDetailsProvider';
}

/// Provider for detailed strategy information
///
/// Fetches comprehensive details for a specific strategy including:
/// - Full configuration
/// - Performance metrics
///
/// Takes strategy name as parameter.
///
/// Copied from [strategyDetails].
class StrategyDetailsProvider extends AutoDisposeFutureProvider<Strategy> {
  /// Provider for detailed strategy information
  ///
  /// Fetches comprehensive details for a specific strategy including:
  /// - Full configuration
  /// - Performance metrics
  ///
  /// Takes strategy name as parameter.
  ///
  /// Copied from [strategyDetails].
  StrategyDetailsProvider(
    String strategyName,
  ) : this._internal(
          (ref) => strategyDetails(
            ref as StrategyDetailsRef,
            strategyName,
          ),
          from: strategyDetailsProvider,
          name: r'strategyDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$strategyDetailsHash,
          dependencies: StrategyDetailsFamily._dependencies,
          allTransitiveDependencies:
              StrategyDetailsFamily._allTransitiveDependencies,
          strategyName: strategyName,
        );

  StrategyDetailsProvider._internal(
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
    FutureOr<Strategy> Function(StrategyDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StrategyDetailsProvider._internal(
        (ref) => create(ref as StrategyDetailsRef),
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
  AutoDisposeFutureProviderElement<Strategy> createElement() {
    return _StrategyDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StrategyDetailsProvider &&
        other.strategyName == strategyName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, strategyName.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StrategyDetailsRef on AutoDisposeFutureProviderRef<Strategy> {
  /// The parameter `strategyName` of this provider.
  String get strategyName;
}

class _StrategyDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Strategy> with StrategyDetailsRef {
  _StrategyDetailsProviderElement(super.provider);

  @override
  String get strategyName => (origin as StrategyDetailsProvider).strategyName;
}

String _$strategyPerformanceHash() =>
    r'8fdb76060ff4b1321ad7c846fb317a549c6fe02f';

/// Provider for strategy performance metrics
///
/// Fetches performance data for a specific strategy:
/// - Total trades
/// - Win rate
/// - Total P&L
/// - Average win/loss
/// - Sharpe ratio
/// - Max drawdown
/// - Profit factor
///
/// Parameters:
/// - strategyName: Name of the strategy
///
/// Copied from [strategyPerformance].
@ProviderFor(strategyPerformance)
const strategyPerformanceProvider = StrategyPerformanceFamily();

/// Provider for strategy performance metrics
///
/// Fetches performance data for a specific strategy:
/// - Total trades
/// - Win rate
/// - Total P&L
/// - Average win/loss
/// - Sharpe ratio
/// - Max drawdown
/// - Profit factor
///
/// Parameters:
/// - strategyName: Name of the strategy
///
/// Copied from [strategyPerformance].
class StrategyPerformanceFamily
    extends Family<AsyncValue<StrategyPerformance>> {
  /// Provider for strategy performance metrics
  ///
  /// Fetches performance data for a specific strategy:
  /// - Total trades
  /// - Win rate
  /// - Total P&L
  /// - Average win/loss
  /// - Sharpe ratio
  /// - Max drawdown
  /// - Profit factor
  ///
  /// Parameters:
  /// - strategyName: Name of the strategy
  ///
  /// Copied from [strategyPerformance].
  const StrategyPerformanceFamily();

  /// Provider for strategy performance metrics
  ///
  /// Fetches performance data for a specific strategy:
  /// - Total trades
  /// - Win rate
  /// - Total P&L
  /// - Average win/loss
  /// - Sharpe ratio
  /// - Max drawdown
  /// - Profit factor
  ///
  /// Parameters:
  /// - strategyName: Name of the strategy
  ///
  /// Copied from [strategyPerformance].
  StrategyPerformanceProvider call(
    String strategyName,
  ) {
    return StrategyPerformanceProvider(
      strategyName,
    );
  }

  @override
  StrategyPerformanceProvider getProviderOverride(
    covariant StrategyPerformanceProvider provider,
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
  String? get name => r'strategyPerformanceProvider';
}

/// Provider for strategy performance metrics
///
/// Fetches performance data for a specific strategy:
/// - Total trades
/// - Win rate
/// - Total P&L
/// - Average win/loss
/// - Sharpe ratio
/// - Max drawdown
/// - Profit factor
///
/// Parameters:
/// - strategyName: Name of the strategy
///
/// Copied from [strategyPerformance].
class StrategyPerformanceProvider
    extends AutoDisposeFutureProvider<StrategyPerformance> {
  /// Provider for strategy performance metrics
  ///
  /// Fetches performance data for a specific strategy:
  /// - Total trades
  /// - Win rate
  /// - Total P&L
  /// - Average win/loss
  /// - Sharpe ratio
  /// - Max drawdown
  /// - Profit factor
  ///
  /// Parameters:
  /// - strategyName: Name of the strategy
  ///
  /// Copied from [strategyPerformance].
  StrategyPerformanceProvider(
    String strategyName,
  ) : this._internal(
          (ref) => strategyPerformance(
            ref as StrategyPerformanceRef,
            strategyName,
          ),
          from: strategyPerformanceProvider,
          name: r'strategyPerformanceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$strategyPerformanceHash,
          dependencies: StrategyPerformanceFamily._dependencies,
          allTransitiveDependencies:
              StrategyPerformanceFamily._allTransitiveDependencies,
          strategyName: strategyName,
        );

  StrategyPerformanceProvider._internal(
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
    FutureOr<StrategyPerformance> Function(StrategyPerformanceRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StrategyPerformanceProvider._internal(
        (ref) => create(ref as StrategyPerformanceRef),
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
  AutoDisposeFutureProviderElement<StrategyPerformance> createElement() {
    return _StrategyPerformanceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StrategyPerformanceProvider &&
        other.strategyName == strategyName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, strategyName.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StrategyPerformanceRef
    on AutoDisposeFutureProviderRef<StrategyPerformance> {
  /// The parameter `strategyName` of this provider.
  String get strategyName;
}

class _StrategyPerformanceProviderElement
    extends AutoDisposeFutureProviderElement<StrategyPerformance>
    with StrategyPerformanceRef {
  _StrategyPerformanceProviderElement(super.provider);

  @override
  String get strategyName =>
      (origin as StrategyPerformanceProvider).strategyName;
}

String _$activeStrategiesCountHash() =>
    r'ec8c1cbaad19ddfe8abad722f7a3e3b6f9d4a6f2';

/// Provider for active strategies count
///
/// Returns the number of currently active strategies.
/// Derived from strategies list.
///
/// Copied from [activeStrategiesCount].
@ProviderFor(activeStrategiesCount)
final activeStrategiesCountProvider = AutoDisposeProvider<int>.internal(
  activeStrategiesCount,
  name: r'activeStrategiesCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeStrategiesCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ActiveStrategiesCountRef = AutoDisposeProviderRef<int>;
String _$strategiesByStatusHash() =>
    r'5f54f2fc472d90884996dad91df374e3eaa590b6';

/// Provider for strategies by status
///
/// Filters strategies by active/inactive status.
///
/// Parameters:
/// - active: true for active strategies, false for inactive
///
/// Copied from [strategiesByStatus].
@ProviderFor(strategiesByStatus)
const strategiesByStatusProvider = StrategiesByStatusFamily();

/// Provider for strategies by status
///
/// Filters strategies by active/inactive status.
///
/// Parameters:
/// - active: true for active strategies, false for inactive
///
/// Copied from [strategiesByStatus].
class StrategiesByStatusFamily extends Family<List<Strategy>> {
  /// Provider for strategies by status
  ///
  /// Filters strategies by active/inactive status.
  ///
  /// Parameters:
  /// - active: true for active strategies, false for inactive
  ///
  /// Copied from [strategiesByStatus].
  const StrategiesByStatusFamily();

  /// Provider for strategies by status
  ///
  /// Filters strategies by active/inactive status.
  ///
  /// Parameters:
  /// - active: true for active strategies, false for inactive
  ///
  /// Copied from [strategiesByStatus].
  StrategiesByStatusProvider call({
    required bool active,
  }) {
    return StrategiesByStatusProvider(
      active: active,
    );
  }

  @override
  StrategiesByStatusProvider getProviderOverride(
    covariant StrategiesByStatusProvider provider,
  ) {
    return call(
      active: provider.active,
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
  String? get name => r'strategiesByStatusProvider';
}

/// Provider for strategies by status
///
/// Filters strategies by active/inactive status.
///
/// Parameters:
/// - active: true for active strategies, false for inactive
///
/// Copied from [strategiesByStatus].
class StrategiesByStatusProvider extends AutoDisposeProvider<List<Strategy>> {
  /// Provider for strategies by status
  ///
  /// Filters strategies by active/inactive status.
  ///
  /// Parameters:
  /// - active: true for active strategies, false for inactive
  ///
  /// Copied from [strategiesByStatus].
  StrategiesByStatusProvider({
    required bool active,
  }) : this._internal(
          (ref) => strategiesByStatus(
            ref as StrategiesByStatusRef,
            active: active,
          ),
          from: strategiesByStatusProvider,
          name: r'strategiesByStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$strategiesByStatusHash,
          dependencies: StrategiesByStatusFamily._dependencies,
          allTransitiveDependencies:
              StrategiesByStatusFamily._allTransitiveDependencies,
          active: active,
        );

  StrategiesByStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.active,
  }) : super.internal();

  final bool active;

  @override
  Override overrideWith(
    List<Strategy> Function(StrategiesByStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StrategiesByStatusProvider._internal(
        (ref) => create(ref as StrategiesByStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        active: active,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<Strategy>> createElement() {
    return _StrategiesByStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StrategiesByStatusProvider && other.active == active;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, active.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StrategiesByStatusRef on AutoDisposeProviderRef<List<Strategy>> {
  /// The parameter `active` of this provider.
  bool get active;
}

class _StrategiesByStatusProviderElement
    extends AutoDisposeProviderElement<List<Strategy>>
    with StrategiesByStatusRef {
  _StrategiesByStatusProviderElement(super.provider);

  @override
  bool get active => (origin as StrategiesByStatusProvider).active;
}

String _$strategiesHash() => r'03f37339913b83c66642df1c98f3db90b79743c8';

/// Provider for all available strategies
///
/// Fetches and manages the list of all trading strategies:
/// - RSI Scalping
/// - MACD Scalping
/// - Bollinger Scalping
/// - Volume Scalping
/// - AI Scalping
///
/// Each strategy includes:
/// - Name and status (active/inactive)
/// - Weight in ensemble
/// - Basic performance metrics
///
/// Copied from [Strategies].
@ProviderFor(Strategies)
final strategiesProvider =
    AutoDisposeAsyncNotifierProvider<Strategies, List<Strategy>>.internal(
  Strategies.new,
  name: r'strategiesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$strategiesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Strategies = AutoDisposeAsyncNotifier<List<Strategy>>;
String _$selectedStrategyHash() => r'f4ea8e7b9d508f7896394832cb53a3f00218f868';

/// Provider for selected strategy in UI
///
/// State provider to track which strategy is selected for detailed view
/// or configuration. Returns null if no strategy is selected.
///
/// Copied from [SelectedStrategy].
@ProviderFor(SelectedStrategy)
final selectedStrategyProvider =
    AutoDisposeNotifierProvider<SelectedStrategy, Strategy?>.internal(
  SelectedStrategy.new,
  name: r'selectedStrategyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedStrategyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedStrategy = AutoDisposeNotifier<Strategy?>;
String _$strategyStarterHash() => r'609ff4b0de8946353b1f57f1f2492d615bcfb0fa';

/// Provider for starting a strategy
///
/// Starts an inactive strategy and triggers refresh of strategies list.
///
/// Copied from [StrategyStarter].
@ProviderFor(StrategyStarter)
final strategyStarterProvider =
    AutoDisposeAsyncNotifierProvider<StrategyStarter, void>.internal(
  StrategyStarter.new,
  name: r'strategyStarterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$strategyStarterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StrategyStarter = AutoDisposeAsyncNotifier<void>;
String _$strategyStopperHash() => r'b62d506cbb2e96db9f511179c328c98d59fc46a9';

/// Provider for stopping a strategy
///
/// Stops an active strategy and triggers refresh of strategies list.
///
/// Copied from [StrategyStopper].
@ProviderFor(StrategyStopper)
final strategyStopperProvider =
    AutoDisposeAsyncNotifierProvider<StrategyStopper, void>.internal(
  StrategyStopper.new,
  name: r'strategyStopperProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$strategyStopperHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StrategyStopper = AutoDisposeAsyncNotifier<void>;
String _$strategyConfigUpdaterHash() =>
    r'9e761d6c61d33dc5dc7c0a8e70e4512980876dcd';

/// Provider for updating strategy configuration
///
/// Updates parameters for a specific strategy.
/// Configuration varies by strategy type:
/// - RSI: period, oversold, overbought
/// - MACD: fast, slow, signal periods
/// - Bollinger: period, stdDev
/// - Volume: threshold, period
/// - AI: model parameters
///
/// Copied from [StrategyConfigUpdater].
@ProviderFor(StrategyConfigUpdater)
final strategyConfigUpdaterProvider =
    AutoDisposeAsyncNotifierProvider<StrategyConfigUpdater, void>.internal(
  StrategyConfigUpdater.new,
  name: r'strategyConfigUpdaterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$strategyConfigUpdaterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StrategyConfigUpdater = AutoDisposeAsyncNotifier<void>;
String _$strategyTogglerHash() => r'ad8486fb96cb772875382454b1b873e77d6acfbc';

/// Provider for strategy toggle action
///
/// Convenience provider that starts inactive strategies
/// and stops active strategies.
///
/// Copied from [StrategyToggler].
@ProviderFor(StrategyToggler)
final strategyTogglerProvider =
    AutoDisposeAsyncNotifierProvider<StrategyToggler, void>.internal(
  StrategyToggler.new,
  name: r'strategyTogglerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$strategyTogglerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StrategyToggler = AutoDisposeAsyncNotifier<void>;
String _$strategyStatsHash() => r'acd7582d326c4fd3004def30e3be4cbff7073336';

/// Provider for aggregated strategy statistics
///
/// Calculates summary statistics across all strategies:
/// - Total strategies
/// - Active strategies
/// - Combined win rate
/// - Combined P&L
///
/// Copied from [StrategyStats].
@ProviderFor(StrategyStats)
final strategyStatsProvider =
    AutoDisposeNotifierProvider<StrategyStats, StrategyStatistics>.internal(
  StrategyStats.new,
  name: r'strategyStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$strategyStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StrategyStats = AutoDisposeNotifier<StrategyStatistics>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
