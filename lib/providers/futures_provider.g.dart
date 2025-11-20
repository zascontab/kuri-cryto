// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'futures_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$futuresServiceHash() => r'01afa1a3b0f5b16ab1cd3339ce71a87d617f0a9b';

/// Provider for Futures Service
///
/// Handles futures trading operations on KuCoin:
/// - Get open positions
/// - Close positions (single/all/filtered)
/// - Stop loss and take profit management
/// - Price information (mark/index prices)
/// - Symbol conversion helpers
///
/// Copied from [futuresService].
@ProviderFor(futuresService)
final futuresServiceProvider = AutoDisposeProvider<FuturesService>.internal(
  futuresService,
  name: r'futuresServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$futuresServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FuturesServiceRef = AutoDisposeProviderRef<FuturesService>;
String _$futuresPositionHash() => r'a70ecf77a29c742ffa025a15962719f5e2f4aae1';

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

/// Provider for a specific futures position
///
/// Returns details for a single position by symbol.
///
/// Parameters:
/// - symbol: Futures symbol (e.g., 'BTCUSDTM')
/// - exchange: Exchange name (default: 'kucoin')
///
/// Copied from [futuresPosition].
@ProviderFor(futuresPosition)
const futuresPositionProvider = FuturesPositionFamily();

/// Provider for a specific futures position
///
/// Returns details for a single position by symbol.
///
/// Parameters:
/// - symbol: Futures symbol (e.g., 'BTCUSDTM')
/// - exchange: Exchange name (default: 'kucoin')
///
/// Copied from [futuresPosition].
class FuturesPositionFamily extends Family<AsyncValue<FuturesPosition?>> {
  /// Provider for a specific futures position
  ///
  /// Returns details for a single position by symbol.
  ///
  /// Parameters:
  /// - symbol: Futures symbol (e.g., 'BTCUSDTM')
  /// - exchange: Exchange name (default: 'kucoin')
  ///
  /// Copied from [futuresPosition].
  const FuturesPositionFamily();

  /// Provider for a specific futures position
  ///
  /// Returns details for a single position by symbol.
  ///
  /// Parameters:
  /// - symbol: Futures symbol (e.g., 'BTCUSDTM')
  /// - exchange: Exchange name (default: 'kucoin')
  ///
  /// Copied from [futuresPosition].
  FuturesPositionProvider call({
    required String symbol,
    String exchange = 'kucoin',
  }) {
    return FuturesPositionProvider(
      symbol: symbol,
      exchange: exchange,
    );
  }

  @override
  FuturesPositionProvider getProviderOverride(
    covariant FuturesPositionProvider provider,
  ) {
    return call(
      symbol: provider.symbol,
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
  String? get name => r'futuresPositionProvider';
}

/// Provider for a specific futures position
///
/// Returns details for a single position by symbol.
///
/// Parameters:
/// - symbol: Futures symbol (e.g., 'BTCUSDTM')
/// - exchange: Exchange name (default: 'kucoin')
///
/// Copied from [futuresPosition].
class FuturesPositionProvider
    extends AutoDisposeFutureProvider<FuturesPosition?> {
  /// Provider for a specific futures position
  ///
  /// Returns details for a single position by symbol.
  ///
  /// Parameters:
  /// - symbol: Futures symbol (e.g., 'BTCUSDTM')
  /// - exchange: Exchange name (default: 'kucoin')
  ///
  /// Copied from [futuresPosition].
  FuturesPositionProvider({
    required String symbol,
    String exchange = 'kucoin',
  }) : this._internal(
          (ref) => futuresPosition(
            ref as FuturesPositionRef,
            symbol: symbol,
            exchange: exchange,
          ),
          from: futuresPositionProvider,
          name: r'futuresPositionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$futuresPositionHash,
          dependencies: FuturesPositionFamily._dependencies,
          allTransitiveDependencies:
              FuturesPositionFamily._allTransitiveDependencies,
          symbol: symbol,
          exchange: exchange,
        );

  FuturesPositionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.symbol,
    required this.exchange,
  }) : super.internal();

  final String symbol;
  final String exchange;

  @override
  Override overrideWith(
    FutureOr<FuturesPosition?> Function(FuturesPositionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FuturesPositionProvider._internal(
        (ref) => create(ref as FuturesPositionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        symbol: symbol,
        exchange: exchange,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<FuturesPosition?> createElement() {
    return _FuturesPositionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FuturesPositionProvider &&
        other.symbol == symbol &&
        other.exchange == exchange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, symbol.hashCode);
    hash = _SystemHash.combine(hash, exchange.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FuturesPositionRef on AutoDisposeFutureProviderRef<FuturesPosition?> {
  /// The parameter `symbol` of this provider.
  String get symbol;

  /// The parameter `exchange` of this provider.
  String get exchange;
}

class _FuturesPositionProviderElement
    extends AutoDisposeFutureProviderElement<FuturesPosition?>
    with FuturesPositionRef {
  _FuturesPositionProviderElement(super.provider);

  @override
  String get symbol => (origin as FuturesPositionProvider).symbol;
  @override
  String get exchange => (origin as FuturesPositionProvider).exchange;
}

String _$markPriceHash() => r'31d1480ddc41faa9d6183d7274a4acb60cedc2b1';

/// Provider for mark price
///
/// Gets the mark price (price of mark) for a futures symbol.
///
/// Parameters:
/// - symbol: Futures symbol (e.g., 'BTCUSDTM')
/// - exchange: Exchange name (default: 'kucoin')
///
/// Copied from [markPrice].
@ProviderFor(markPrice)
const markPriceProvider = MarkPriceFamily();

/// Provider for mark price
///
/// Gets the mark price (price of mark) for a futures symbol.
///
/// Parameters:
/// - symbol: Futures symbol (e.g., 'BTCUSDTM')
/// - exchange: Exchange name (default: 'kucoin')
///
/// Copied from [markPrice].
class MarkPriceFamily extends Family<AsyncValue<double>> {
  /// Provider for mark price
  ///
  /// Gets the mark price (price of mark) for a futures symbol.
  ///
  /// Parameters:
  /// - symbol: Futures symbol (e.g., 'BTCUSDTM')
  /// - exchange: Exchange name (default: 'kucoin')
  ///
  /// Copied from [markPrice].
  const MarkPriceFamily();

  /// Provider for mark price
  ///
  /// Gets the mark price (price of mark) for a futures symbol.
  ///
  /// Parameters:
  /// - symbol: Futures symbol (e.g., 'BTCUSDTM')
  /// - exchange: Exchange name (default: 'kucoin')
  ///
  /// Copied from [markPrice].
  MarkPriceProvider call({
    required String symbol,
    String exchange = 'kucoin',
  }) {
    return MarkPriceProvider(
      symbol: symbol,
      exchange: exchange,
    );
  }

  @override
  MarkPriceProvider getProviderOverride(
    covariant MarkPriceProvider provider,
  ) {
    return call(
      symbol: provider.symbol,
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
  String? get name => r'markPriceProvider';
}

/// Provider for mark price
///
/// Gets the mark price (price of mark) for a futures symbol.
///
/// Parameters:
/// - symbol: Futures symbol (e.g., 'BTCUSDTM')
/// - exchange: Exchange name (default: 'kucoin')
///
/// Copied from [markPrice].
class MarkPriceProvider extends AutoDisposeFutureProvider<double> {
  /// Provider for mark price
  ///
  /// Gets the mark price (price of mark) for a futures symbol.
  ///
  /// Parameters:
  /// - symbol: Futures symbol (e.g., 'BTCUSDTM')
  /// - exchange: Exchange name (default: 'kucoin')
  ///
  /// Copied from [markPrice].
  MarkPriceProvider({
    required String symbol,
    String exchange = 'kucoin',
  }) : this._internal(
          (ref) => markPrice(
            ref as MarkPriceRef,
            symbol: symbol,
            exchange: exchange,
          ),
          from: markPriceProvider,
          name: r'markPriceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$markPriceHash,
          dependencies: MarkPriceFamily._dependencies,
          allTransitiveDependencies: MarkPriceFamily._allTransitiveDependencies,
          symbol: symbol,
          exchange: exchange,
        );

  MarkPriceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.symbol,
    required this.exchange,
  }) : super.internal();

  final String symbol;
  final String exchange;

  @override
  Override overrideWith(
    FutureOr<double> Function(MarkPriceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MarkPriceProvider._internal(
        (ref) => create(ref as MarkPriceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        symbol: symbol,
        exchange: exchange,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<double> createElement() {
    return _MarkPriceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MarkPriceProvider &&
        other.symbol == symbol &&
        other.exchange == exchange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, symbol.hashCode);
    hash = _SystemHash.combine(hash, exchange.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MarkPriceRef on AutoDisposeFutureProviderRef<double> {
  /// The parameter `symbol` of this provider.
  String get symbol;

  /// The parameter `exchange` of this provider.
  String get exchange;
}

class _MarkPriceProviderElement extends AutoDisposeFutureProviderElement<double>
    with MarkPriceRef {
  _MarkPriceProviderElement(super.provider);

  @override
  String get symbol => (origin as MarkPriceProvider).symbol;
  @override
  String get exchange => (origin as MarkPriceProvider).exchange;
}

String _$indexPriceHash() => r'f98d2a32c45041b0d9b61bdf34dda520f2d9743c';

/// Provider for index price
///
/// Gets the index price for a futures symbol.
///
/// Parameters:
/// - symbol: Futures symbol (e.g., 'BTCUSDTM')
/// - exchange: Exchange name (default: 'kucoin')
///
/// Copied from [indexPrice].
@ProviderFor(indexPrice)
const indexPriceProvider = IndexPriceFamily();

/// Provider for index price
///
/// Gets the index price for a futures symbol.
///
/// Parameters:
/// - symbol: Futures symbol (e.g., 'BTCUSDTM')
/// - exchange: Exchange name (default: 'kucoin')
///
/// Copied from [indexPrice].
class IndexPriceFamily extends Family<AsyncValue<double>> {
  /// Provider for index price
  ///
  /// Gets the index price for a futures symbol.
  ///
  /// Parameters:
  /// - symbol: Futures symbol (e.g., 'BTCUSDTM')
  /// - exchange: Exchange name (default: 'kucoin')
  ///
  /// Copied from [indexPrice].
  const IndexPriceFamily();

  /// Provider for index price
  ///
  /// Gets the index price for a futures symbol.
  ///
  /// Parameters:
  /// - symbol: Futures symbol (e.g., 'BTCUSDTM')
  /// - exchange: Exchange name (default: 'kucoin')
  ///
  /// Copied from [indexPrice].
  IndexPriceProvider call({
    required String symbol,
    String exchange = 'kucoin',
  }) {
    return IndexPriceProvider(
      symbol: symbol,
      exchange: exchange,
    );
  }

  @override
  IndexPriceProvider getProviderOverride(
    covariant IndexPriceProvider provider,
  ) {
    return call(
      symbol: provider.symbol,
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
  String? get name => r'indexPriceProvider';
}

/// Provider for index price
///
/// Gets the index price for a futures symbol.
///
/// Parameters:
/// - symbol: Futures symbol (e.g., 'BTCUSDTM')
/// - exchange: Exchange name (default: 'kucoin')
///
/// Copied from [indexPrice].
class IndexPriceProvider extends AutoDisposeFutureProvider<double> {
  /// Provider for index price
  ///
  /// Gets the index price for a futures symbol.
  ///
  /// Parameters:
  /// - symbol: Futures symbol (e.g., 'BTCUSDTM')
  /// - exchange: Exchange name (default: 'kucoin')
  ///
  /// Copied from [indexPrice].
  IndexPriceProvider({
    required String symbol,
    String exchange = 'kucoin',
  }) : this._internal(
          (ref) => indexPrice(
            ref as IndexPriceRef,
            symbol: symbol,
            exchange: exchange,
          ),
          from: indexPriceProvider,
          name: r'indexPriceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$indexPriceHash,
          dependencies: IndexPriceFamily._dependencies,
          allTransitiveDependencies:
              IndexPriceFamily._allTransitiveDependencies,
          symbol: symbol,
          exchange: exchange,
        );

  IndexPriceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.symbol,
    required this.exchange,
  }) : super.internal();

  final String symbol;
  final String exchange;

  @override
  Override overrideWith(
    FutureOr<double> Function(IndexPriceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IndexPriceProvider._internal(
        (ref) => create(ref as IndexPriceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        symbol: symbol,
        exchange: exchange,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<double> createElement() {
    return _IndexPriceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IndexPriceProvider &&
        other.symbol == symbol &&
        other.exchange == exchange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, symbol.hashCode);
    hash = _SystemHash.combine(hash, exchange.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin IndexPriceRef on AutoDisposeFutureProviderRef<double> {
  /// The parameter `symbol` of this provider.
  String get symbol;

  /// The parameter `exchange` of this provider.
  String get exchange;
}

class _IndexPriceProviderElement
    extends AutoDisposeFutureProviderElement<double> with IndexPriceRef {
  _IndexPriceProviderElement(super.provider);

  @override
  String get symbol => (origin as IndexPriceProvider).symbol;
  @override
  String get exchange => (origin as IndexPriceProvider).exchange;
}

String _$totalFuturesPositionsHash() =>
    r'bea571e0e04692e8e8bb75110c0854669d054e47';

/// Provider for total positions count
///
/// Returns the number of open futures positions.
/// Derived from positions response.
///
/// Copied from [totalFuturesPositions].
@ProviderFor(totalFuturesPositions)
const totalFuturesPositionsProvider = TotalFuturesPositionsFamily();

/// Provider for total positions count
///
/// Returns the number of open futures positions.
/// Derived from positions response.
///
/// Copied from [totalFuturesPositions].
class TotalFuturesPositionsFamily extends Family<int> {
  /// Provider for total positions count
  ///
  /// Returns the number of open futures positions.
  /// Derived from positions response.
  ///
  /// Copied from [totalFuturesPositions].
  const TotalFuturesPositionsFamily();

  /// Provider for total positions count
  ///
  /// Returns the number of open futures positions.
  /// Derived from positions response.
  ///
  /// Copied from [totalFuturesPositions].
  TotalFuturesPositionsProvider call({
    String exchange = 'kucoin',
  }) {
    return TotalFuturesPositionsProvider(
      exchange: exchange,
    );
  }

  @override
  TotalFuturesPositionsProvider getProviderOverride(
    covariant TotalFuturesPositionsProvider provider,
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
  String? get name => r'totalFuturesPositionsProvider';
}

/// Provider for total positions count
///
/// Returns the number of open futures positions.
/// Derived from positions response.
///
/// Copied from [totalFuturesPositions].
class TotalFuturesPositionsProvider extends AutoDisposeProvider<int> {
  /// Provider for total positions count
  ///
  /// Returns the number of open futures positions.
  /// Derived from positions response.
  ///
  /// Copied from [totalFuturesPositions].
  TotalFuturesPositionsProvider({
    String exchange = 'kucoin',
  }) : this._internal(
          (ref) => totalFuturesPositions(
            ref as TotalFuturesPositionsRef,
            exchange: exchange,
          ),
          from: totalFuturesPositionsProvider,
          name: r'totalFuturesPositionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$totalFuturesPositionsHash,
          dependencies: TotalFuturesPositionsFamily._dependencies,
          allTransitiveDependencies:
              TotalFuturesPositionsFamily._allTransitiveDependencies,
          exchange: exchange,
        );

  TotalFuturesPositionsProvider._internal(
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
    int Function(TotalFuturesPositionsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TotalFuturesPositionsProvider._internal(
        (ref) => create(ref as TotalFuturesPositionsRef),
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
  AutoDisposeProviderElement<int> createElement() {
    return _TotalFuturesPositionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TotalFuturesPositionsProvider && other.exchange == exchange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, exchange.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TotalFuturesPositionsRef on AutoDisposeProviderRef<int> {
  /// The parameter `exchange` of this provider.
  String get exchange;
}

class _TotalFuturesPositionsProviderElement
    extends AutoDisposeProviderElement<int> with TotalFuturesPositionsRef {
  _TotalFuturesPositionsProviderElement(super.provider);

  @override
  String get exchange => (origin as TotalFuturesPositionsProvider).exchange;
}

String _$totalUnrealizedPnlHash() =>
    r'57a852716ccf4badd00c8271998a4b039adaeff6';

/// Provider for total unrealized P&L
///
/// Returns the total unrealized profit/loss across all positions.
/// Derived from positions response.
///
/// Copied from [totalUnrealizedPnl].
@ProviderFor(totalUnrealizedPnl)
const totalUnrealizedPnlProvider = TotalUnrealizedPnlFamily();

/// Provider for total unrealized P&L
///
/// Returns the total unrealized profit/loss across all positions.
/// Derived from positions response.
///
/// Copied from [totalUnrealizedPnl].
class TotalUnrealizedPnlFamily extends Family<double> {
  /// Provider for total unrealized P&L
  ///
  /// Returns the total unrealized profit/loss across all positions.
  /// Derived from positions response.
  ///
  /// Copied from [totalUnrealizedPnl].
  const TotalUnrealizedPnlFamily();

  /// Provider for total unrealized P&L
  ///
  /// Returns the total unrealized profit/loss across all positions.
  /// Derived from positions response.
  ///
  /// Copied from [totalUnrealizedPnl].
  TotalUnrealizedPnlProvider call({
    String exchange = 'kucoin',
  }) {
    return TotalUnrealizedPnlProvider(
      exchange: exchange,
    );
  }

  @override
  TotalUnrealizedPnlProvider getProviderOverride(
    covariant TotalUnrealizedPnlProvider provider,
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
  String? get name => r'totalUnrealizedPnlProvider';
}

/// Provider for total unrealized P&L
///
/// Returns the total unrealized profit/loss across all positions.
/// Derived from positions response.
///
/// Copied from [totalUnrealizedPnl].
class TotalUnrealizedPnlProvider extends AutoDisposeProvider<double> {
  /// Provider for total unrealized P&L
  ///
  /// Returns the total unrealized profit/loss across all positions.
  /// Derived from positions response.
  ///
  /// Copied from [totalUnrealizedPnl].
  TotalUnrealizedPnlProvider({
    String exchange = 'kucoin',
  }) : this._internal(
          (ref) => totalUnrealizedPnl(
            ref as TotalUnrealizedPnlRef,
            exchange: exchange,
          ),
          from: totalUnrealizedPnlProvider,
          name: r'totalUnrealizedPnlProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$totalUnrealizedPnlHash,
          dependencies: TotalUnrealizedPnlFamily._dependencies,
          allTransitiveDependencies:
              TotalUnrealizedPnlFamily._allTransitiveDependencies,
          exchange: exchange,
        );

  TotalUnrealizedPnlProvider._internal(
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
    double Function(TotalUnrealizedPnlRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TotalUnrealizedPnlProvider._internal(
        (ref) => create(ref as TotalUnrealizedPnlRef),
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
  AutoDisposeProviderElement<double> createElement() {
    return _TotalUnrealizedPnlProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TotalUnrealizedPnlProvider && other.exchange == exchange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, exchange.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TotalUnrealizedPnlRef on AutoDisposeProviderRef<double> {
  /// The parameter `exchange` of this provider.
  String get exchange;
}

class _TotalUnrealizedPnlProviderElement
    extends AutoDisposeProviderElement<double> with TotalUnrealizedPnlRef {
  _TotalUnrealizedPnlProviderElement(super.provider);

  @override
  String get exchange => (origin as TotalUnrealizedPnlProvider).exchange;
}

String _$profitablePositionsCountHash() =>
    r'27d65856d5f94cb1819fbc7b0b230a21ba9777a4';

/// Provider for profitable positions count
///
/// Returns the number of positions with positive P&L.
/// Derived from positions list.
///
/// Copied from [profitablePositionsCount].
@ProviderFor(profitablePositionsCount)
const profitablePositionsCountProvider = ProfitablePositionsCountFamily();

/// Provider for profitable positions count
///
/// Returns the number of positions with positive P&L.
/// Derived from positions list.
///
/// Copied from [profitablePositionsCount].
class ProfitablePositionsCountFamily extends Family<int> {
  /// Provider for profitable positions count
  ///
  /// Returns the number of positions with positive P&L.
  /// Derived from positions list.
  ///
  /// Copied from [profitablePositionsCount].
  const ProfitablePositionsCountFamily();

  /// Provider for profitable positions count
  ///
  /// Returns the number of positions with positive P&L.
  /// Derived from positions list.
  ///
  /// Copied from [profitablePositionsCount].
  ProfitablePositionsCountProvider call({
    String exchange = 'kucoin',
  }) {
    return ProfitablePositionsCountProvider(
      exchange: exchange,
    );
  }

  @override
  ProfitablePositionsCountProvider getProviderOverride(
    covariant ProfitablePositionsCountProvider provider,
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
  String? get name => r'profitablePositionsCountProvider';
}

/// Provider for profitable positions count
///
/// Returns the number of positions with positive P&L.
/// Derived from positions list.
///
/// Copied from [profitablePositionsCount].
class ProfitablePositionsCountProvider extends AutoDisposeProvider<int> {
  /// Provider for profitable positions count
  ///
  /// Returns the number of positions with positive P&L.
  /// Derived from positions list.
  ///
  /// Copied from [profitablePositionsCount].
  ProfitablePositionsCountProvider({
    String exchange = 'kucoin',
  }) : this._internal(
          (ref) => profitablePositionsCount(
            ref as ProfitablePositionsCountRef,
            exchange: exchange,
          ),
          from: profitablePositionsCountProvider,
          name: r'profitablePositionsCountProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$profitablePositionsCountHash,
          dependencies: ProfitablePositionsCountFamily._dependencies,
          allTransitiveDependencies:
              ProfitablePositionsCountFamily._allTransitiveDependencies,
          exchange: exchange,
        );

  ProfitablePositionsCountProvider._internal(
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
    int Function(ProfitablePositionsCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProfitablePositionsCountProvider._internal(
        (ref) => create(ref as ProfitablePositionsCountRef),
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
  AutoDisposeProviderElement<int> createElement() {
    return _ProfitablePositionsCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfitablePositionsCountProvider &&
        other.exchange == exchange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, exchange.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ProfitablePositionsCountRef on AutoDisposeProviderRef<int> {
  /// The parameter `exchange` of this provider.
  String get exchange;
}

class _ProfitablePositionsCountProviderElement
    extends AutoDisposeProviderElement<int> with ProfitablePositionsCountRef {
  _ProfitablePositionsCountProviderElement(super.provider);

  @override
  String get exchange => (origin as ProfitablePositionsCountProvider).exchange;
}

String _$losingPositionsCountHash() =>
    r'69d1e8211490d2d6bec26c4eeb8a8c3b8d6a2fbd';

/// Provider for losing positions count
///
/// Returns the number of positions with negative P&L.
/// Derived from positions list.
///
/// Copied from [losingPositionsCount].
@ProviderFor(losingPositionsCount)
const losingPositionsCountProvider = LosingPositionsCountFamily();

/// Provider for losing positions count
///
/// Returns the number of positions with negative P&L.
/// Derived from positions list.
///
/// Copied from [losingPositionsCount].
class LosingPositionsCountFamily extends Family<int> {
  /// Provider for losing positions count
  ///
  /// Returns the number of positions with negative P&L.
  /// Derived from positions list.
  ///
  /// Copied from [losingPositionsCount].
  const LosingPositionsCountFamily();

  /// Provider for losing positions count
  ///
  /// Returns the number of positions with negative P&L.
  /// Derived from positions list.
  ///
  /// Copied from [losingPositionsCount].
  LosingPositionsCountProvider call({
    String exchange = 'kucoin',
  }) {
    return LosingPositionsCountProvider(
      exchange: exchange,
    );
  }

  @override
  LosingPositionsCountProvider getProviderOverride(
    covariant LosingPositionsCountProvider provider,
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
  String? get name => r'losingPositionsCountProvider';
}

/// Provider for losing positions count
///
/// Returns the number of positions with negative P&L.
/// Derived from positions list.
///
/// Copied from [losingPositionsCount].
class LosingPositionsCountProvider extends AutoDisposeProvider<int> {
  /// Provider for losing positions count
  ///
  /// Returns the number of positions with negative P&L.
  /// Derived from positions list.
  ///
  /// Copied from [losingPositionsCount].
  LosingPositionsCountProvider({
    String exchange = 'kucoin',
  }) : this._internal(
          (ref) => losingPositionsCount(
            ref as LosingPositionsCountRef,
            exchange: exchange,
          ),
          from: losingPositionsCountProvider,
          name: r'losingPositionsCountProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$losingPositionsCountHash,
          dependencies: LosingPositionsCountFamily._dependencies,
          allTransitiveDependencies:
              LosingPositionsCountFamily._allTransitiveDependencies,
          exchange: exchange,
        );

  LosingPositionsCountProvider._internal(
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
    int Function(LosingPositionsCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LosingPositionsCountProvider._internal(
        (ref) => create(ref as LosingPositionsCountRef),
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
  AutoDisposeProviderElement<int> createElement() {
    return _LosingPositionsCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LosingPositionsCountProvider && other.exchange == exchange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, exchange.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin LosingPositionsCountRef on AutoDisposeProviderRef<int> {
  /// The parameter `exchange` of this provider.
  String get exchange;
}

class _LosingPositionsCountProviderElement
    extends AutoDisposeProviderElement<int> with LosingPositionsCountRef {
  _LosingPositionsCountProviderElement(super.provider);

  @override
  String get exchange => (origin as LosingPositionsCountProvider).exchange;
}

String _$longPositionsHash() => r'ad1fc388aa8cff923f2df4af34e3dd5c8be337d4';

/// Provider for long positions
///
/// Returns only long positions.
/// Filtered from positions list.
///
/// Copied from [longPositions].
@ProviderFor(longPositions)
const longPositionsProvider = LongPositionsFamily();

/// Provider for long positions
///
/// Returns only long positions.
/// Filtered from positions list.
///
/// Copied from [longPositions].
class LongPositionsFamily extends Family<List<FuturesPosition>> {
  /// Provider for long positions
  ///
  /// Returns only long positions.
  /// Filtered from positions list.
  ///
  /// Copied from [longPositions].
  const LongPositionsFamily();

  /// Provider for long positions
  ///
  /// Returns only long positions.
  /// Filtered from positions list.
  ///
  /// Copied from [longPositions].
  LongPositionsProvider call({
    String exchange = 'kucoin',
  }) {
    return LongPositionsProvider(
      exchange: exchange,
    );
  }

  @override
  LongPositionsProvider getProviderOverride(
    covariant LongPositionsProvider provider,
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
  String? get name => r'longPositionsProvider';
}

/// Provider for long positions
///
/// Returns only long positions.
/// Filtered from positions list.
///
/// Copied from [longPositions].
class LongPositionsProvider extends AutoDisposeProvider<List<FuturesPosition>> {
  /// Provider for long positions
  ///
  /// Returns only long positions.
  /// Filtered from positions list.
  ///
  /// Copied from [longPositions].
  LongPositionsProvider({
    String exchange = 'kucoin',
  }) : this._internal(
          (ref) => longPositions(
            ref as LongPositionsRef,
            exchange: exchange,
          ),
          from: longPositionsProvider,
          name: r'longPositionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$longPositionsHash,
          dependencies: LongPositionsFamily._dependencies,
          allTransitiveDependencies:
              LongPositionsFamily._allTransitiveDependencies,
          exchange: exchange,
        );

  LongPositionsProvider._internal(
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
    List<FuturesPosition> Function(LongPositionsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LongPositionsProvider._internal(
        (ref) => create(ref as LongPositionsRef),
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
  AutoDisposeProviderElement<List<FuturesPosition>> createElement() {
    return _LongPositionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LongPositionsProvider && other.exchange == exchange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, exchange.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin LongPositionsRef on AutoDisposeProviderRef<List<FuturesPosition>> {
  /// The parameter `exchange` of this provider.
  String get exchange;
}

class _LongPositionsProviderElement
    extends AutoDisposeProviderElement<List<FuturesPosition>>
    with LongPositionsRef {
  _LongPositionsProviderElement(super.provider);

  @override
  String get exchange => (origin as LongPositionsProvider).exchange;
}

String _$shortPositionsHash() => r'8f78d220952821b003493a33ebe5b0b63cf21040';

/// Provider for short positions
///
/// Returns only short positions.
/// Filtered from positions list.
///
/// Copied from [shortPositions].
@ProviderFor(shortPositions)
const shortPositionsProvider = ShortPositionsFamily();

/// Provider for short positions
///
/// Returns only short positions.
/// Filtered from positions list.
///
/// Copied from [shortPositions].
class ShortPositionsFamily extends Family<List<FuturesPosition>> {
  /// Provider for short positions
  ///
  /// Returns only short positions.
  /// Filtered from positions list.
  ///
  /// Copied from [shortPositions].
  const ShortPositionsFamily();

  /// Provider for short positions
  ///
  /// Returns only short positions.
  /// Filtered from positions list.
  ///
  /// Copied from [shortPositions].
  ShortPositionsProvider call({
    String exchange = 'kucoin',
  }) {
    return ShortPositionsProvider(
      exchange: exchange,
    );
  }

  @override
  ShortPositionsProvider getProviderOverride(
    covariant ShortPositionsProvider provider,
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
  String? get name => r'shortPositionsProvider';
}

/// Provider for short positions
///
/// Returns only short positions.
/// Filtered from positions list.
///
/// Copied from [shortPositions].
class ShortPositionsProvider
    extends AutoDisposeProvider<List<FuturesPosition>> {
  /// Provider for short positions
  ///
  /// Returns only short positions.
  /// Filtered from positions list.
  ///
  /// Copied from [shortPositions].
  ShortPositionsProvider({
    String exchange = 'kucoin',
  }) : this._internal(
          (ref) => shortPositions(
            ref as ShortPositionsRef,
            exchange: exchange,
          ),
          from: shortPositionsProvider,
          name: r'shortPositionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shortPositionsHash,
          dependencies: ShortPositionsFamily._dependencies,
          allTransitiveDependencies:
              ShortPositionsFamily._allTransitiveDependencies,
          exchange: exchange,
        );

  ShortPositionsProvider._internal(
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
    List<FuturesPosition> Function(ShortPositionsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShortPositionsProvider._internal(
        (ref) => create(ref as ShortPositionsRef),
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
  AutoDisposeProviderElement<List<FuturesPosition>> createElement() {
    return _ShortPositionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShortPositionsProvider && other.exchange == exchange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, exchange.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ShortPositionsRef on AutoDisposeProviderRef<List<FuturesPosition>> {
  /// The parameter `exchange` of this provider.
  String get exchange;
}

class _ShortPositionsProviderElement
    extends AutoDisposeProviderElement<List<FuturesPosition>>
    with ShortPositionsRef {
  _ShortPositionsProviderElement(super.provider);

  @override
  String get exchange => (origin as ShortPositionsProvider).exchange;
}

String _$positionsSortedByPnlHash() =>
    r'1e5d0579e179071ef54c5295a4cb197ca3f07bee';

/// Provider for positions sorted by P&L
///
/// Returns positions sorted by P&L percentage (highest first).
///
/// Parameters:
/// - ascending: Sort order (true = lowest first, false = highest first)
/// - exchange: Exchange name (default: 'kucoin')
///
/// Copied from [positionsSortedByPnl].
@ProviderFor(positionsSortedByPnl)
const positionsSortedByPnlProvider = PositionsSortedByPnlFamily();

/// Provider for positions sorted by P&L
///
/// Returns positions sorted by P&L percentage (highest first).
///
/// Parameters:
/// - ascending: Sort order (true = lowest first, false = highest first)
/// - exchange: Exchange name (default: 'kucoin')
///
/// Copied from [positionsSortedByPnl].
class PositionsSortedByPnlFamily extends Family<List<FuturesPosition>> {
  /// Provider for positions sorted by P&L
  ///
  /// Returns positions sorted by P&L percentage (highest first).
  ///
  /// Parameters:
  /// - ascending: Sort order (true = lowest first, false = highest first)
  /// - exchange: Exchange name (default: 'kucoin')
  ///
  /// Copied from [positionsSortedByPnl].
  const PositionsSortedByPnlFamily();

  /// Provider for positions sorted by P&L
  ///
  /// Returns positions sorted by P&L percentage (highest first).
  ///
  /// Parameters:
  /// - ascending: Sort order (true = lowest first, false = highest first)
  /// - exchange: Exchange name (default: 'kucoin')
  ///
  /// Copied from [positionsSortedByPnl].
  PositionsSortedByPnlProvider call({
    bool ascending = false,
    String exchange = 'kucoin',
  }) {
    return PositionsSortedByPnlProvider(
      ascending: ascending,
      exchange: exchange,
    );
  }

  @override
  PositionsSortedByPnlProvider getProviderOverride(
    covariant PositionsSortedByPnlProvider provider,
  ) {
    return call(
      ascending: provider.ascending,
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
  String? get name => r'positionsSortedByPnlProvider';
}

/// Provider for positions sorted by P&L
///
/// Returns positions sorted by P&L percentage (highest first).
///
/// Parameters:
/// - ascending: Sort order (true = lowest first, false = highest first)
/// - exchange: Exchange name (default: 'kucoin')
///
/// Copied from [positionsSortedByPnl].
class PositionsSortedByPnlProvider
    extends AutoDisposeProvider<List<FuturesPosition>> {
  /// Provider for positions sorted by P&L
  ///
  /// Returns positions sorted by P&L percentage (highest first).
  ///
  /// Parameters:
  /// - ascending: Sort order (true = lowest first, false = highest first)
  /// - exchange: Exchange name (default: 'kucoin')
  ///
  /// Copied from [positionsSortedByPnl].
  PositionsSortedByPnlProvider({
    bool ascending = false,
    String exchange = 'kucoin',
  }) : this._internal(
          (ref) => positionsSortedByPnl(
            ref as PositionsSortedByPnlRef,
            ascending: ascending,
            exchange: exchange,
          ),
          from: positionsSortedByPnlProvider,
          name: r'positionsSortedByPnlProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$positionsSortedByPnlHash,
          dependencies: PositionsSortedByPnlFamily._dependencies,
          allTransitiveDependencies:
              PositionsSortedByPnlFamily._allTransitiveDependencies,
          ascending: ascending,
          exchange: exchange,
        );

  PositionsSortedByPnlProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.ascending,
    required this.exchange,
  }) : super.internal();

  final bool ascending;
  final String exchange;

  @override
  Override overrideWith(
    List<FuturesPosition> Function(PositionsSortedByPnlRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PositionsSortedByPnlProvider._internal(
        (ref) => create(ref as PositionsSortedByPnlRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        ascending: ascending,
        exchange: exchange,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<FuturesPosition>> createElement() {
    return _PositionsSortedByPnlProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PositionsSortedByPnlProvider &&
        other.ascending == ascending &&
        other.exchange == exchange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, ascending.hashCode);
    hash = _SystemHash.combine(hash, exchange.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PositionsSortedByPnlRef on AutoDisposeProviderRef<List<FuturesPosition>> {
  /// The parameter `ascending` of this provider.
  bool get ascending;

  /// The parameter `exchange` of this provider.
  String get exchange;
}

class _PositionsSortedByPnlProviderElement
    extends AutoDisposeProviderElement<List<FuturesPosition>>
    with PositionsSortedByPnlRef {
  _PositionsSortedByPnlProviderElement(super.provider);

  @override
  bool get ascending => (origin as PositionsSortedByPnlProvider).ascending;
  @override
  String get exchange => (origin as PositionsSortedByPnlProvider).exchange;
}

String _$positionsBySymbolHash() => r'2672753b733f4716425c1e29dd92e2f7f3e4e23f';

/// Provider for positions by symbol filter
///
/// Returns positions filtered by symbol pattern.
/// Useful for filtering by base currency (e.g., all BTC positions).
///
/// Parameters:
/// - pattern: Symbol pattern to match (case-insensitive)
/// - exchange: Exchange name (default: 'kucoin')
///
/// Copied from [positionsBySymbol].
@ProviderFor(positionsBySymbol)
const positionsBySymbolProvider = PositionsBySymbolFamily();

/// Provider for positions by symbol filter
///
/// Returns positions filtered by symbol pattern.
/// Useful for filtering by base currency (e.g., all BTC positions).
///
/// Parameters:
/// - pattern: Symbol pattern to match (case-insensitive)
/// - exchange: Exchange name (default: 'kucoin')
///
/// Copied from [positionsBySymbol].
class PositionsBySymbolFamily extends Family<List<FuturesPosition>> {
  /// Provider for positions by symbol filter
  ///
  /// Returns positions filtered by symbol pattern.
  /// Useful for filtering by base currency (e.g., all BTC positions).
  ///
  /// Parameters:
  /// - pattern: Symbol pattern to match (case-insensitive)
  /// - exchange: Exchange name (default: 'kucoin')
  ///
  /// Copied from [positionsBySymbol].
  const PositionsBySymbolFamily();

  /// Provider for positions by symbol filter
  ///
  /// Returns positions filtered by symbol pattern.
  /// Useful for filtering by base currency (e.g., all BTC positions).
  ///
  /// Parameters:
  /// - pattern: Symbol pattern to match (case-insensitive)
  /// - exchange: Exchange name (default: 'kucoin')
  ///
  /// Copied from [positionsBySymbol].
  PositionsBySymbolProvider call({
    required String pattern,
    String exchange = 'kucoin',
  }) {
    return PositionsBySymbolProvider(
      pattern: pattern,
      exchange: exchange,
    );
  }

  @override
  PositionsBySymbolProvider getProviderOverride(
    covariant PositionsBySymbolProvider provider,
  ) {
    return call(
      pattern: provider.pattern,
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
  String? get name => r'positionsBySymbolProvider';
}

/// Provider for positions by symbol filter
///
/// Returns positions filtered by symbol pattern.
/// Useful for filtering by base currency (e.g., all BTC positions).
///
/// Parameters:
/// - pattern: Symbol pattern to match (case-insensitive)
/// - exchange: Exchange name (default: 'kucoin')
///
/// Copied from [positionsBySymbol].
class PositionsBySymbolProvider
    extends AutoDisposeProvider<List<FuturesPosition>> {
  /// Provider for positions by symbol filter
  ///
  /// Returns positions filtered by symbol pattern.
  /// Useful for filtering by base currency (e.g., all BTC positions).
  ///
  /// Parameters:
  /// - pattern: Symbol pattern to match (case-insensitive)
  /// - exchange: Exchange name (default: 'kucoin')
  ///
  /// Copied from [positionsBySymbol].
  PositionsBySymbolProvider({
    required String pattern,
    String exchange = 'kucoin',
  }) : this._internal(
          (ref) => positionsBySymbol(
            ref as PositionsBySymbolRef,
            pattern: pattern,
            exchange: exchange,
          ),
          from: positionsBySymbolProvider,
          name: r'positionsBySymbolProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$positionsBySymbolHash,
          dependencies: PositionsBySymbolFamily._dependencies,
          allTransitiveDependencies:
              PositionsBySymbolFamily._allTransitiveDependencies,
          pattern: pattern,
          exchange: exchange,
        );

  PositionsBySymbolProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pattern,
    required this.exchange,
  }) : super.internal();

  final String pattern;
  final String exchange;

  @override
  Override overrideWith(
    List<FuturesPosition> Function(PositionsBySymbolRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PositionsBySymbolProvider._internal(
        (ref) => create(ref as PositionsBySymbolRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pattern: pattern,
        exchange: exchange,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<FuturesPosition>> createElement() {
    return _PositionsBySymbolProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PositionsBySymbolProvider &&
        other.pattern == pattern &&
        other.exchange == exchange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pattern.hashCode);
    hash = _SystemHash.combine(hash, exchange.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PositionsBySymbolRef on AutoDisposeProviderRef<List<FuturesPosition>> {
  /// The parameter `pattern` of this provider.
  String get pattern;

  /// The parameter `exchange` of this provider.
  String get exchange;
}

class _PositionsBySymbolProviderElement
    extends AutoDisposeProviderElement<List<FuturesPosition>>
    with PositionsBySymbolRef {
  _PositionsBySymbolProviderElement(super.provider);

  @override
  String get pattern => (origin as PositionsBySymbolProvider).pattern;
  @override
  String get exchange => (origin as PositionsBySymbolProvider).exchange;
}

String _$futuresPositionsHash() => r'18e3582f4fcd4a0378d1b92e9368c77d990dff6b';

abstract class _$FuturesPositions
    extends BuildlessAutoDisposeAsyncNotifier<FuturesPositionsResponse> {
  late final String exchange;

  FutureOr<FuturesPositionsResponse> build({
    String exchange = 'kucoin',
  });
}

/// Provider for Futures Positions
///
/// Fetches and manages open futures positions.
/// Returns FuturesPositionsResponse with:
/// - List of positions
/// - Total positions count
/// - Total unrealized P&L
///
/// Parameters:
/// - exchange: Exchange name (default: 'kucoin')
///
/// Copied from [FuturesPositions].
@ProviderFor(FuturesPositions)
const futuresPositionsProvider = FuturesPositionsFamily();

/// Provider for Futures Positions
///
/// Fetches and manages open futures positions.
/// Returns FuturesPositionsResponse with:
/// - List of positions
/// - Total positions count
/// - Total unrealized P&L
///
/// Parameters:
/// - exchange: Exchange name (default: 'kucoin')
///
/// Copied from [FuturesPositions].
class FuturesPositionsFamily
    extends Family<AsyncValue<FuturesPositionsResponse>> {
  /// Provider for Futures Positions
  ///
  /// Fetches and manages open futures positions.
  /// Returns FuturesPositionsResponse with:
  /// - List of positions
  /// - Total positions count
  /// - Total unrealized P&L
  ///
  /// Parameters:
  /// - exchange: Exchange name (default: 'kucoin')
  ///
  /// Copied from [FuturesPositions].
  const FuturesPositionsFamily();

  /// Provider for Futures Positions
  ///
  /// Fetches and manages open futures positions.
  /// Returns FuturesPositionsResponse with:
  /// - List of positions
  /// - Total positions count
  /// - Total unrealized P&L
  ///
  /// Parameters:
  /// - exchange: Exchange name (default: 'kucoin')
  ///
  /// Copied from [FuturesPositions].
  FuturesPositionsProvider call({
    String exchange = 'kucoin',
  }) {
    return FuturesPositionsProvider(
      exchange: exchange,
    );
  }

  @override
  FuturesPositionsProvider getProviderOverride(
    covariant FuturesPositionsProvider provider,
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
  String? get name => r'futuresPositionsProvider';
}

/// Provider for Futures Positions
///
/// Fetches and manages open futures positions.
/// Returns FuturesPositionsResponse with:
/// - List of positions
/// - Total positions count
/// - Total unrealized P&L
///
/// Parameters:
/// - exchange: Exchange name (default: 'kucoin')
///
/// Copied from [FuturesPositions].
class FuturesPositionsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    FuturesPositions, FuturesPositionsResponse> {
  /// Provider for Futures Positions
  ///
  /// Fetches and manages open futures positions.
  /// Returns FuturesPositionsResponse with:
  /// - List of positions
  /// - Total positions count
  /// - Total unrealized P&L
  ///
  /// Parameters:
  /// - exchange: Exchange name (default: 'kucoin')
  ///
  /// Copied from [FuturesPositions].
  FuturesPositionsProvider({
    String exchange = 'kucoin',
  }) : this._internal(
          () => FuturesPositions()..exchange = exchange,
          from: futuresPositionsProvider,
          name: r'futuresPositionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$futuresPositionsHash,
          dependencies: FuturesPositionsFamily._dependencies,
          allTransitiveDependencies:
              FuturesPositionsFamily._allTransitiveDependencies,
          exchange: exchange,
        );

  FuturesPositionsProvider._internal(
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
  FutureOr<FuturesPositionsResponse> runNotifierBuild(
    covariant FuturesPositions notifier,
  ) {
    return notifier.build(
      exchange: exchange,
    );
  }

  @override
  Override overrideWith(FuturesPositions Function() create) {
    return ProviderOverride(
      origin: this,
      override: FuturesPositionsProvider._internal(
        () => create()..exchange = exchange,
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
  AutoDisposeAsyncNotifierProviderElement<FuturesPositions,
      FuturesPositionsResponse> createElement() {
    return _FuturesPositionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FuturesPositionsProvider && other.exchange == exchange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, exchange.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FuturesPositionsRef
    on AutoDisposeAsyncNotifierProviderRef<FuturesPositionsResponse> {
  /// The parameter `exchange` of this provider.
  String get exchange;
}

class _FuturesPositionsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<FuturesPositions,
        FuturesPositionsResponse> with FuturesPositionsRef {
  _FuturesPositionsProviderElement(super.provider);

  @override
  String get exchange => (origin as FuturesPositionsProvider).exchange;
}

String _$futuresStatsHash() => r'44e8d105fcb5e0503480960b81f4634d6078adc2';

abstract class _$FuturesStats
    extends BuildlessAutoDisposeNotifier<FuturesStatistics> {
  late final String exchange;

  FuturesStatistics build({
    String exchange = 'kucoin',
  });
}

/// Provider for futures statistics
///
/// Calculates summary statistics for futures positions:
/// - Total positions
/// - Long/short count
/// - Profitable/losing count
/// - Total unrealized P&L
/// - Average P&L percentage
/// - Largest gain/loss
///
/// Parameters:
/// - exchange: Exchange name (default: 'kucoin')
///
/// Copied from [FuturesStats].
@ProviderFor(FuturesStats)
const futuresStatsProvider = FuturesStatsFamily();

/// Provider for futures statistics
///
/// Calculates summary statistics for futures positions:
/// - Total positions
/// - Long/short count
/// - Profitable/losing count
/// - Total unrealized P&L
/// - Average P&L percentage
/// - Largest gain/loss
///
/// Parameters:
/// - exchange: Exchange name (default: 'kucoin')
///
/// Copied from [FuturesStats].
class FuturesStatsFamily extends Family<FuturesStatistics> {
  /// Provider for futures statistics
  ///
  /// Calculates summary statistics for futures positions:
  /// - Total positions
  /// - Long/short count
  /// - Profitable/losing count
  /// - Total unrealized P&L
  /// - Average P&L percentage
  /// - Largest gain/loss
  ///
  /// Parameters:
  /// - exchange: Exchange name (default: 'kucoin')
  ///
  /// Copied from [FuturesStats].
  const FuturesStatsFamily();

  /// Provider for futures statistics
  ///
  /// Calculates summary statistics for futures positions:
  /// - Total positions
  /// - Long/short count
  /// - Profitable/losing count
  /// - Total unrealized P&L
  /// - Average P&L percentage
  /// - Largest gain/loss
  ///
  /// Parameters:
  /// - exchange: Exchange name (default: 'kucoin')
  ///
  /// Copied from [FuturesStats].
  FuturesStatsProvider call({
    String exchange = 'kucoin',
  }) {
    return FuturesStatsProvider(
      exchange: exchange,
    );
  }

  @override
  FuturesStatsProvider getProviderOverride(
    covariant FuturesStatsProvider provider,
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
  String? get name => r'futuresStatsProvider';
}

/// Provider for futures statistics
///
/// Calculates summary statistics for futures positions:
/// - Total positions
/// - Long/short count
/// - Profitable/losing count
/// - Total unrealized P&L
/// - Average P&L percentage
/// - Largest gain/loss
///
/// Parameters:
/// - exchange: Exchange name (default: 'kucoin')
///
/// Copied from [FuturesStats].
class FuturesStatsProvider
    extends AutoDisposeNotifierProviderImpl<FuturesStats, FuturesStatistics> {
  /// Provider for futures statistics
  ///
  /// Calculates summary statistics for futures positions:
  /// - Total positions
  /// - Long/short count
  /// - Profitable/losing count
  /// - Total unrealized P&L
  /// - Average P&L percentage
  /// - Largest gain/loss
  ///
  /// Parameters:
  /// - exchange: Exchange name (default: 'kucoin')
  ///
  /// Copied from [FuturesStats].
  FuturesStatsProvider({
    String exchange = 'kucoin',
  }) : this._internal(
          () => FuturesStats()..exchange = exchange,
          from: futuresStatsProvider,
          name: r'futuresStatsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$futuresStatsHash,
          dependencies: FuturesStatsFamily._dependencies,
          allTransitiveDependencies:
              FuturesStatsFamily._allTransitiveDependencies,
          exchange: exchange,
        );

  FuturesStatsProvider._internal(
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
  FuturesStatistics runNotifierBuild(
    covariant FuturesStats notifier,
  ) {
    return notifier.build(
      exchange: exchange,
    );
  }

  @override
  Override overrideWith(FuturesStats Function() create) {
    return ProviderOverride(
      origin: this,
      override: FuturesStatsProvider._internal(
        () => create()..exchange = exchange,
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
  AutoDisposeNotifierProviderElement<FuturesStats, FuturesStatistics>
      createElement() {
    return _FuturesStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FuturesStatsProvider && other.exchange == exchange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, exchange.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FuturesStatsRef on AutoDisposeNotifierProviderRef<FuturesStatistics> {
  /// The parameter `exchange` of this provider.
  String get exchange;
}

class _FuturesStatsProviderElement
    extends AutoDisposeNotifierProviderElement<FuturesStats, FuturesStatistics>
    with FuturesStatsRef {
  _FuturesStatsProviderElement(super.provider);

  @override
  String get exchange => (origin as FuturesStatsProvider).exchange;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
