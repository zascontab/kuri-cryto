// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trading_pairs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activePairsHash() => r'ce8f1eed15d61e2659ace88c882dbe0c7abc1bc5';

/// Provider for active trading pairs
///
/// Fetches the list of currently active trading pairs being monitored
/// by the scalping engine.
///
/// Example usage:
/// ```dart
/// final pairs = ref.watch(activePairsProvider);
/// ```
///
/// Copied from [activePairs].
@ProviderFor(activePairs)
final activePairsProvider =
    AutoDisposeFutureProvider<List<TradingPair>>.internal(
  activePairs,
  name: r'activePairsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$activePairsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ActivePairsRef = AutoDisposeFutureProviderRef<List<TradingPair>>;
String _$availablePairsHash() => r'08aaaffeae2b9ab94ab70523af52423377a5d24e';

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

/// Provider for available trading pairs by exchange
///
/// Fetches available pairs that can be added for a specific exchange.
///
/// Parameters:
/// - exchange: Exchange name (e.g., 'kucoin', 'binance')
///
/// Example usage:
/// ```dart
/// final pairs = ref.watch(availablePairsProvider('kucoin'));
/// ```
///
/// Copied from [availablePairs].
@ProviderFor(availablePairs)
const availablePairsProvider = AvailablePairsFamily();

/// Provider for available trading pairs by exchange
///
/// Fetches available pairs that can be added for a specific exchange.
///
/// Parameters:
/// - exchange: Exchange name (e.g., 'kucoin', 'binance')
///
/// Example usage:
/// ```dart
/// final pairs = ref.watch(availablePairsProvider('kucoin'));
/// ```
///
/// Copied from [availablePairs].
class AvailablePairsFamily extends Family<AsyncValue<List<TradingPair>>> {
  /// Provider for available trading pairs by exchange
  ///
  /// Fetches available pairs that can be added for a specific exchange.
  ///
  /// Parameters:
  /// - exchange: Exchange name (e.g., 'kucoin', 'binance')
  ///
  /// Example usage:
  /// ```dart
  /// final pairs = ref.watch(availablePairsProvider('kucoin'));
  /// ```
  ///
  /// Copied from [availablePairs].
  const AvailablePairsFamily();

  /// Provider for available trading pairs by exchange
  ///
  /// Fetches available pairs that can be added for a specific exchange.
  ///
  /// Parameters:
  /// - exchange: Exchange name (e.g., 'kucoin', 'binance')
  ///
  /// Example usage:
  /// ```dart
  /// final pairs = ref.watch(availablePairsProvider('kucoin'));
  /// ```
  ///
  /// Copied from [availablePairs].
  AvailablePairsProvider call(
    String exchange,
  ) {
    return AvailablePairsProvider(
      exchange,
    );
  }

  @override
  AvailablePairsProvider getProviderOverride(
    covariant AvailablePairsProvider provider,
  ) {
    return call(
      provider.exchange,
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

/// Provider for available trading pairs by exchange
///
/// Fetches available pairs that can be added for a specific exchange.
///
/// Parameters:
/// - exchange: Exchange name (e.g., 'kucoin', 'binance')
///
/// Example usage:
/// ```dart
/// final pairs = ref.watch(availablePairsProvider('kucoin'));
/// ```
///
/// Copied from [availablePairs].
class AvailablePairsProvider
    extends AutoDisposeFutureProvider<List<TradingPair>> {
  /// Provider for available trading pairs by exchange
  ///
  /// Fetches available pairs that can be added for a specific exchange.
  ///
  /// Parameters:
  /// - exchange: Exchange name (e.g., 'kucoin', 'binance')
  ///
  /// Example usage:
  /// ```dart
  /// final pairs = ref.watch(availablePairsProvider('kucoin'));
  /// ```
  ///
  /// Copied from [availablePairs].
  AvailablePairsProvider(
    String exchange,
  ) : this._internal(
          (ref) => availablePairs(
            ref as AvailablePairsRef,
            exchange,
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
          exchange: exchange,
        );

  AvailablePairsProvider._internal(
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
    FutureOr<List<TradingPair>> Function(AvailablePairsRef provider) create,
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
        exchange: exchange,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TradingPair>> createElement() {
    return _AvailablePairsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AvailablePairsProvider && other.exchange == exchange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, exchange.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AvailablePairsRef on AutoDisposeFutureProviderRef<List<TradingPair>> {
  /// The parameter `exchange` of this provider.
  String get exchange;
}

class _AvailablePairsProviderElement
    extends AutoDisposeFutureProviderElement<List<TradingPair>>
    with AvailablePairsRef {
  _AvailablePairsProviderElement(super.provider);

  @override
  String get exchange => (origin as AvailablePairsProvider).exchange;
}

String _$supportedExchangesHash() =>
    r'ec0b4b74c3c244300e2d13e935b46dd72a367b37';

/// Provider for exchange list
///
/// Returns a list of supported exchanges.
/// This could be fetched from an API endpoint in the future.
///
/// Copied from [supportedExchanges].
@ProviderFor(supportedExchanges)
final supportedExchangesProvider = AutoDisposeProvider<List<String>>.internal(
  supportedExchanges,
  name: r'supportedExchangesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$supportedExchangesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SupportedExchangesRef = AutoDisposeProviderRef<List<String>>;
String _$pairAdderHash() => r'fcaf740b1ae2eebea7a51633f79b4a1c2d9d8f2b';

/// Provider for adding a trading pair
///
/// Adds a new trading pair to the scalping engine and invalidates
/// the active pairs list to trigger a refresh.
///
/// Copied from [PairAdder].
@ProviderFor(PairAdder)
final pairAdderProvider =
    AutoDisposeAsyncNotifierProvider<PairAdder, void>.internal(
  PairAdder.new,
  name: r'pairAdderProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$pairAdderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PairAdder = AutoDisposeAsyncNotifier<void>;
String _$pairRemoverHash() => r'553ca36a82a44681c4182f918a6f7d34b05f473d';

/// Provider for removing a trading pair
///
/// Removes a trading pair from the scalping engine and invalidates
/// the active pairs list to trigger a refresh.
///
/// Copied from [PairRemover].
@ProviderFor(PairRemover)
final pairRemoverProvider =
    AutoDisposeAsyncNotifierProvider<PairRemover, void>.internal(
  PairRemover.new,
  name: r'pairRemoverProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$pairRemoverHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PairRemover = AutoDisposeAsyncNotifier<void>;
String _$selectedTradingPairHash() =>
    r'3bd815d7ca6fcd9054eb0478d760a057214a77cc';

/// Provider for currently selected trading pair in UI
///
/// State provider to track which pair is selected for detailed view.
/// Returns null if no pair is selected.
///
/// Copied from [SelectedTradingPair].
@ProviderFor(SelectedTradingPair)
final selectedTradingPairProvider =
    AutoDisposeNotifierProvider<SelectedTradingPair, TradingPair?>.internal(
  SelectedTradingPair.new,
  name: r'selectedTradingPairProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedTradingPairHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedTradingPair = AutoDisposeNotifier<TradingPair?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
