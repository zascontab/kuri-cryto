// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$marketServiceHash() => r'35a152b44f432625a385ea4e1f701261c9f039e7';

/// Provider for Market Service
///
/// Copied from [marketService].
@ProviderFor(marketService)
final marketServiceProvider = AutoDisposeProvider<MarketService>.internal(
  marketService,
  name: r'marketServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$marketServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MarketServiceRef = AutoDisposeProviderRef<MarketService>;
String _$availableMarketTypesHash() =>
    r'1a4a062ed87be34d3f2fde498b489011549664bc';

/// Provider for available market types
///
/// Copied from [availableMarketTypes].
@ProviderFor(availableMarketTypes)
final availableMarketTypesProvider =
    AutoDisposeFutureProvider<List<MarketType>>.internal(
  availableMarketTypes,
  name: r'availableMarketTypesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableMarketTypesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AvailableMarketTypesRef
    = AutoDisposeFutureProviderRef<List<MarketType>>;
String _$availablePairsHash() => r'347d9f4b267092718816f830d1f19f0eae7eb7c6';

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

/// Provider for available pairs by market type
///
/// Copied from [availablePairs].
@ProviderFor(availablePairs)
const availablePairsProvider = AvailablePairsFamily();

/// Provider for available pairs by market type
///
/// Copied from [availablePairs].
class AvailablePairsFamily extends Family<AsyncValue<List<String>>> {
  /// Provider for available pairs by market type
  ///
  /// Copied from [availablePairs].
  const AvailablePairsFamily();

  /// Provider for available pairs by market type
  ///
  /// Copied from [availablePairs].
  AvailablePairsProvider call({
    required MarketType marketType,
    required String exchange,
  }) {
    return AvailablePairsProvider(
      marketType: marketType,
      exchange: exchange,
    );
  }

  @override
  AvailablePairsProvider getProviderOverride(
    covariant AvailablePairsProvider provider,
  ) {
    return call(
      marketType: provider.marketType,
      exchange: provider.exchange,
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
  String? get name => r'availablePairsProvider';
}

/// Provider for available pairs by market type
///
/// Copied from [availablePairs].
class AvailablePairsProvider extends AutoDisposeFutureProvider<List<String>> {
  /// Provider for available pairs by market type
  ///
  /// Copied from [availablePairs].
  AvailablePairsProvider({
    required MarketType marketType,
    required String exchange,
  }) : this._internal(
          (ref) => availablePairs(
            ref as AvailablePairsRef,
            marketType: marketType,
            exchange: exchange,
          ),
          from: availablePairsProvider,
          name: r'availablePairsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$availablePairsHash,
          dependencies: AvailablePairsFamily._dependencies,
          allTransitiveDependencies:
              AvailablePairsFamily._allTransitiveDependencies,
          marketType: marketType,
          exchange: exchange,
        );

  AvailablePairsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.marketType,
    required this.exchange,
  }) : super.internal();

  final MarketType marketType;
  final String exchange;

  @override
  Override overrideWith(
    FutureOr<List<String>> Function(AvailablePairsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AvailablePairsProvider._internal(
        (ref) => create(ref as AvailablePairsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        marketType: marketType,
        exchange: exchange,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<String>> createElement() {
    return _AvailablePairsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AvailablePairsProvider &&
        other.marketType == marketType &&
        other.exchange == exchange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, marketType.hashCode);
    hash = _SystemHash.combine(hash, exchange.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AvailablePairsRef on AutoDisposeFutureProviderRef<List<String>> {
  /// The parameter `marketType` of this provider.
  MarketType get marketType;

  /// The parameter `exchange` of this provider.
  String get exchange;
}

class _AvailablePairsProviderElement
    extends AutoDisposeFutureProviderElement<List<String>>
    with AvailablePairsRef {
  _AvailablePairsProviderElement(super.provider);

  @override
  MarketType get marketType => (origin as AvailablePairsProvider).marketType;
  @override
  String get exchange => (origin as AvailablePairsProvider).exchange;
}

String _$marketFeaturesHash() => r'77b45695cb9f692461bc18351473be9b71e4abdb';

/// Provider for market features
///
/// Copied from [marketFeatures].
@ProviderFor(marketFeatures)
const marketFeaturesProvider = MarketFeaturesFamily();

/// Provider for market features
///
/// Copied from [marketFeatures].
class MarketFeaturesFamily extends Family<AsyncValue<MarketFeatures>> {
  /// Provider for market features
  ///
  /// Copied from [marketFeatures].
  const MarketFeaturesFamily();

  /// Provider for market features
  ///
  /// Copied from [marketFeatures].
  MarketFeaturesProvider call({
    required MarketType marketType,
    required String exchange,
  }) {
    return MarketFeaturesProvider(
      marketType: marketType,
      exchange: exchange,
    );
  }

  @override
  MarketFeaturesProvider getProviderOverride(
    covariant MarketFeaturesProvider provider,
  ) {
    return call(
      marketType: provider.marketType,
      exchange: provider.exchange,
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
  String? get name => r'marketFeaturesProvider';
}

/// Provider for market features
///
/// Copied from [marketFeatures].
class MarketFeaturesProvider extends AutoDisposeFutureProvider<MarketFeatures> {
  /// Provider for market features
  ///
  /// Copied from [marketFeatures].
  MarketFeaturesProvider({
    required MarketType marketType,
    required String exchange,
  }) : this._internal(
          (ref) => marketFeatures(
            ref as MarketFeaturesRef,
            marketType: marketType,
            exchange: exchange,
          ),
          from: marketFeaturesProvider,
          name: r'marketFeaturesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$marketFeaturesHash,
          dependencies: MarketFeaturesFamily._dependencies,
          allTransitiveDependencies:
              MarketFeaturesFamily._allTransitiveDependencies,
          marketType: marketType,
          exchange: exchange,
        );

  MarketFeaturesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.marketType,
    required this.exchange,
  }) : super.internal();

  final MarketType marketType;
  final String exchange;

  @override
  Override overrideWith(
    FutureOr<MarketFeatures> Function(MarketFeaturesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MarketFeaturesProvider._internal(
        (ref) => create(ref as MarketFeaturesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        marketType: marketType,
        exchange: exchange,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MarketFeatures> createElement() {
    return _MarketFeaturesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MarketFeaturesProvider &&
        other.marketType == marketType &&
        other.exchange == exchange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, marketType.hashCode);
    hash = _SystemHash.combine(hash, exchange.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MarketFeaturesRef on AutoDisposeFutureProviderRef<MarketFeatures> {
  /// The parameter `marketType` of this provider.
  MarketType get marketType;

  /// The parameter `exchange` of this provider.
  String get exchange;
}

class _MarketFeaturesProviderElement
    extends AutoDisposeFutureProviderElement<MarketFeatures>
    with MarketFeaturesRef {
  _MarketFeaturesProviderElement(super.provider);

  @override
  MarketType get marketType => (origin as MarketFeaturesProvider).marketType;
  @override
  String get exchange => (origin as MarketFeaturesProvider).exchange;
}

String _$marketsHash() => r'3ce02efe11838cf209d50d2bd9003fa3885cb63b';

/// Provider for enhanced markets endpoint
///
/// Gets trading pairs with optional filtering by market type.
/// Returns rich information including features, counts, and metadata.
///
/// Example:
/// ```dart
/// // Get all pairs
/// final allMarkets = ref.watch(marketsProvider(exchange: 'kucoin'));
///
/// // Get only futures pairs
/// final futuresMarkets = ref.watch(
///   marketsProvider(exchange: 'kucoin', marketType: 'futures'),
/// );
/// ```
///
/// Copied from [markets].
@ProviderFor(markets)
const marketsProvider = MarketsFamily();

/// Provider for enhanced markets endpoint
///
/// Gets trading pairs with optional filtering by market type.
/// Returns rich information including features, counts, and metadata.
///
/// Example:
/// ```dart
/// // Get all pairs
/// final allMarkets = ref.watch(marketsProvider(exchange: 'kucoin'));
///
/// // Get only futures pairs
/// final futuresMarkets = ref.watch(
///   marketsProvider(exchange: 'kucoin', marketType: 'futures'),
/// );
/// ```
///
/// Copied from [markets].
class MarketsFamily extends Family<AsyncValue<MarketsResponse>> {
  /// Provider for enhanced markets endpoint
  ///
  /// Gets trading pairs with optional filtering by market type.
  /// Returns rich information including features, counts, and metadata.
  ///
  /// Example:
  /// ```dart
  /// // Get all pairs
  /// final allMarkets = ref.watch(marketsProvider(exchange: 'kucoin'));
  ///
  /// // Get only futures pairs
  /// final futuresMarkets = ref.watch(
  ///   marketsProvider(exchange: 'kucoin', marketType: 'futures'),
  /// );
  /// ```
  ///
  /// Copied from [markets].
  const MarketsFamily();

  /// Provider for enhanced markets endpoint
  ///
  /// Gets trading pairs with optional filtering by market type.
  /// Returns rich information including features, counts, and metadata.
  ///
  /// Example:
  /// ```dart
  /// // Get all pairs
  /// final allMarkets = ref.watch(marketsProvider(exchange: 'kucoin'));
  ///
  /// // Get only futures pairs
  /// final futuresMarkets = ref.watch(
  ///   marketsProvider(exchange: 'kucoin', marketType: 'futures'),
  /// );
  /// ```
  ///
  /// Copied from [markets].
  MarketsProvider call({
    required String exchange,
    String? marketType,
  }) {
    return MarketsProvider(
      exchange: exchange,
      marketType: marketType,
    );
  }

  @override
  MarketsProvider getProviderOverride(
    covariant MarketsProvider provider,
  ) {
    return call(
      exchange: provider.exchange,
      marketType: provider.marketType,
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
  String? get name => r'marketsProvider';
}

/// Provider for enhanced markets endpoint
///
/// Gets trading pairs with optional filtering by market type.
/// Returns rich information including features, counts, and metadata.
///
/// Example:
/// ```dart
/// // Get all pairs
/// final allMarkets = ref.watch(marketsProvider(exchange: 'kucoin'));
///
/// // Get only futures pairs
/// final futuresMarkets = ref.watch(
///   marketsProvider(exchange: 'kucoin', marketType: 'futures'),
/// );
/// ```
///
/// Copied from [markets].
class MarketsProvider extends AutoDisposeFutureProvider<MarketsResponse> {
  /// Provider for enhanced markets endpoint
  ///
  /// Gets trading pairs with optional filtering by market type.
  /// Returns rich information including features, counts, and metadata.
  ///
  /// Example:
  /// ```dart
  /// // Get all pairs
  /// final allMarkets = ref.watch(marketsProvider(exchange: 'kucoin'));
  ///
  /// // Get only futures pairs
  /// final futuresMarkets = ref.watch(
  ///   marketsProvider(exchange: 'kucoin', marketType: 'futures'),
  /// );
  /// ```
  ///
  /// Copied from [markets].
  MarketsProvider({
    required String exchange,
    String? marketType,
  }) : this._internal(
          (ref) => markets(
            ref as MarketsRef,
            exchange: exchange,
            marketType: marketType,
          ),
          from: marketsProvider,
          name: r'marketsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$marketsHash,
          dependencies: MarketsFamily._dependencies,
          allTransitiveDependencies: MarketsFamily._allTransitiveDependencies,
          exchange: exchange,
          marketType: marketType,
        );

  MarketsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.exchange,
    required this.marketType,
  }) : super.internal();

  final String exchange;
  final String? marketType;

  @override
  Override overrideWith(
    FutureOr<MarketsResponse> Function(MarketsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MarketsProvider._internal(
        (ref) => create(ref as MarketsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        exchange: exchange,
        marketType: marketType,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MarketsResponse> createElement() {
    return _MarketsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MarketsProvider &&
        other.exchange == exchange &&
        other.marketType == marketType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, exchange.hashCode);
    hash = _SystemHash.combine(hash, marketType.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MarketsRef on AutoDisposeFutureProviderRef<MarketsResponse> {
  /// The parameter `exchange` of this provider.
  String get exchange;

  /// The parameter `marketType` of this provider.
  String? get marketType;
}

class _MarketsProviderElement
    extends AutoDisposeFutureProviderElement<MarketsResponse> with MarketsRef {
  _MarketsProviderElement(super.provider);

  @override
  String get exchange => (origin as MarketsProvider).exchange;
  @override
  String? get marketType => (origin as MarketsProvider).marketType;
}

String _$allMarketsHash() => r'225d5b28e83a5068ab939c383cf33a7d1cf86eb1';

/// Provider for all markets (no filtering)
///
/// Convenience provider to get all pairs from all market types.
///
/// Example:
/// ```dart
/// final allMarkets = ref.watch(allMarketsProvider(exchange: 'kucoin'));
/// print('Total pairs: ${allMarkets.value?.totalCount}');
/// ```
///
/// Copied from [allMarkets].
@ProviderFor(allMarkets)
const allMarketsProvider = AllMarketsFamily();

/// Provider for all markets (no filtering)
///
/// Convenience provider to get all pairs from all market types.
///
/// Example:
/// ```dart
/// final allMarkets = ref.watch(allMarketsProvider(exchange: 'kucoin'));
/// print('Total pairs: ${allMarkets.value?.totalCount}');
/// ```
///
/// Copied from [allMarkets].
class AllMarketsFamily extends Family<AsyncValue<MarketsResponse>> {
  /// Provider for all markets (no filtering)
  ///
  /// Convenience provider to get all pairs from all market types.
  ///
  /// Example:
  /// ```dart
  /// final allMarkets = ref.watch(allMarketsProvider(exchange: 'kucoin'));
  /// print('Total pairs: ${allMarkets.value?.totalCount}');
  /// ```
  ///
  /// Copied from [allMarkets].
  const AllMarketsFamily();

  /// Provider for all markets (no filtering)
  ///
  /// Convenience provider to get all pairs from all market types.
  ///
  /// Example:
  /// ```dart
  /// final allMarkets = ref.watch(allMarketsProvider(exchange: 'kucoin'));
  /// print('Total pairs: ${allMarkets.value?.totalCount}');
  /// ```
  ///
  /// Copied from [allMarkets].
  AllMarketsProvider call({
    required String exchange,
  }) {
    return AllMarketsProvider(
      exchange: exchange,
    );
  }

  @override
  AllMarketsProvider getProviderOverride(
    covariant AllMarketsProvider provider,
  ) {
    return call(
      exchange: provider.exchange,
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
  String? get name => r'allMarketsProvider';
}

/// Provider for all markets (no filtering)
///
/// Convenience provider to get all pairs from all market types.
///
/// Example:
/// ```dart
/// final allMarkets = ref.watch(allMarketsProvider(exchange: 'kucoin'));
/// print('Total pairs: ${allMarkets.value?.totalCount}');
/// ```
///
/// Copied from [allMarkets].
class AllMarketsProvider extends AutoDisposeFutureProvider<MarketsResponse> {
  /// Provider for all markets (no filtering)
  ///
  /// Convenience provider to get all pairs from all market types.
  ///
  /// Example:
  /// ```dart
  /// final allMarkets = ref.watch(allMarketsProvider(exchange: 'kucoin'));
  /// print('Total pairs: ${allMarkets.value?.totalCount}');
  /// ```
  ///
  /// Copied from [allMarkets].
  AllMarketsProvider({
    required String exchange,
  }) : this._internal(
          (ref) => allMarkets(
            ref as AllMarketsRef,
            exchange: exchange,
          ),
          from: allMarketsProvider,
          name: r'allMarketsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$allMarketsHash,
          dependencies: AllMarketsFamily._dependencies,
          allTransitiveDependencies:
              AllMarketsFamily._allTransitiveDependencies,
          exchange: exchange,
        );

  AllMarketsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.exchange,
  }) : super.internal();

  final String exchange;

  @override
  Override overrideWith(
    FutureOr<MarketsResponse> Function(AllMarketsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AllMarketsProvider._internal(
        (ref) => create(ref as AllMarketsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        exchange: exchange,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MarketsResponse> createElement() {
    return _AllMarketsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AllMarketsProvider && other.exchange == exchange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, exchange.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AllMarketsRef on AutoDisposeFutureProviderRef<MarketsResponse> {
  /// The parameter `exchange` of this provider.
  String get exchange;
}

class _AllMarketsProviderElement
    extends AutoDisposeFutureProviderElement<MarketsResponse>
    with AllMarketsRef {
  _AllMarketsProviderElement(super.provider);

  @override
  String get exchange => (origin as AllMarketsProvider).exchange;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
