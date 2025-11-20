// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comprehensive_analysis_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$comprehensiveAnalysisServiceHash() =>
    r'bfb2ef700251c6796261e425d578991a7fd85af3';

/// Provider for Comprehensive Analysis Service
///
/// Copied from [comprehensiveAnalysisService].
@ProviderFor(comprehensiveAnalysisService)
final comprehensiveAnalysisServiceProvider =
    AutoDisposeProvider<ComprehensiveAnalysisService>.internal(
  comprehensiveAnalysisService,
  name: r'comprehensiveAnalysisServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$comprehensiveAnalysisServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ComprehensiveAnalysisServiceRef
    = AutoDisposeProviderRef<ComprehensiveAnalysisService>;
String _$comprehensiveAnalysisNotifierHash() =>
    r'9befd648b392b66a79103b74a96ed55887740cee';

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

abstract class _$ComprehensiveAnalysisNotifier
    extends BuildlessAutoDisposeAsyncNotifier<ComprehensiveAnalysis> {
  late final String symbol;

  FutureOr<ComprehensiveAnalysis> build(
    String symbol,
  );
}

/// Provider for comprehensive market analysis
///
/// This is a family provider that takes a symbol parameter
/// to fetch analysis for different trading pairs
///
/// Copied from [ComprehensiveAnalysisNotifier].
@ProviderFor(ComprehensiveAnalysisNotifier)
const comprehensiveAnalysisNotifierProvider =
    ComprehensiveAnalysisNotifierFamily();

/// Provider for comprehensive market analysis
///
/// This is a family provider that takes a symbol parameter
/// to fetch analysis for different trading pairs
///
/// Copied from [ComprehensiveAnalysisNotifier].
class ComprehensiveAnalysisNotifierFamily
    extends Family<AsyncValue<ComprehensiveAnalysis>> {
  /// Provider for comprehensive market analysis
  ///
  /// This is a family provider that takes a symbol parameter
  /// to fetch analysis for different trading pairs
  ///
  /// Copied from [ComprehensiveAnalysisNotifier].
  const ComprehensiveAnalysisNotifierFamily();

  /// Provider for comprehensive market analysis
  ///
  /// This is a family provider that takes a symbol parameter
  /// to fetch analysis for different trading pairs
  ///
  /// Copied from [ComprehensiveAnalysisNotifier].
  ComprehensiveAnalysisNotifierProvider call(
    String symbol,
  ) {
    return ComprehensiveAnalysisNotifierProvider(
      symbol,
    );
  }

  @override
  ComprehensiveAnalysisNotifierProvider getProviderOverride(
    covariant ComprehensiveAnalysisNotifierProvider provider,
  ) {
    return call(
      provider.symbol,
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
  String? get name => r'comprehensiveAnalysisNotifierProvider';
}

/// Provider for comprehensive market analysis
///
/// This is a family provider that takes a symbol parameter
/// to fetch analysis for different trading pairs
///
/// Copied from [ComprehensiveAnalysisNotifier].
class ComprehensiveAnalysisNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ComprehensiveAnalysisNotifier,
        ComprehensiveAnalysis> {
  /// Provider for comprehensive market analysis
  ///
  /// This is a family provider that takes a symbol parameter
  /// to fetch analysis for different trading pairs
  ///
  /// Copied from [ComprehensiveAnalysisNotifier].
  ComprehensiveAnalysisNotifierProvider(
    String symbol,
  ) : this._internal(
          () => ComprehensiveAnalysisNotifier()..symbol = symbol,
          from: comprehensiveAnalysisNotifierProvider,
          name: r'comprehensiveAnalysisNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$comprehensiveAnalysisNotifierHash,
          dependencies: ComprehensiveAnalysisNotifierFamily._dependencies,
          allTransitiveDependencies:
              ComprehensiveAnalysisNotifierFamily._allTransitiveDependencies,
          symbol: symbol,
        );

  ComprehensiveAnalysisNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.symbol,
  }) : super.internal();

  final String symbol;

  @override
  FutureOr<ComprehensiveAnalysis> runNotifierBuild(
    covariant ComprehensiveAnalysisNotifier notifier,
  ) {
    return notifier.build(
      symbol,
    );
  }

  @override
  Override overrideWith(ComprehensiveAnalysisNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ComprehensiveAnalysisNotifierProvider._internal(
        () => create()..symbol = symbol,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        symbol: symbol,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ComprehensiveAnalysisNotifier,
      ComprehensiveAnalysis> createElement() {
    return _ComprehensiveAnalysisNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ComprehensiveAnalysisNotifierProvider &&
        other.symbol == symbol;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, symbol.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ComprehensiveAnalysisNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<ComprehensiveAnalysis> {
  /// The parameter `symbol` of this provider.
  String get symbol;
}

class _ComprehensiveAnalysisNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<
        ComprehensiveAnalysisNotifier,
        ComprehensiveAnalysis> with ComprehensiveAnalysisNotifierRef {
  _ComprehensiveAnalysisNotifierProviderElement(super.provider);

  @override
  String get symbol => (origin as ComprehensiveAnalysisNotifierProvider).symbol;
}

String _$selectedSymbolHash() => r'65edbd83e7f0f174d8d26e14ca29391717893142';

/// Provider for current selected symbol (defaults to DOGE-USDT)
///
/// Copied from [SelectedSymbol].
@ProviderFor(SelectedSymbol)
final selectedSymbolProvider =
    AutoDisposeNotifierProvider<SelectedSymbol, String>.internal(
  SelectedSymbol.new,
  name: r'selectedSymbolProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSymbolHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSymbol = AutoDisposeNotifier<String>;
String _$availableSymbolsHash() => r'09087cee4e8eb32b82041071357b51bbb73a4f52';

/// Provider for available trading pairs
///
/// Copied from [AvailableSymbols].
@ProviderFor(AvailableSymbols)
final availableSymbolsProvider =
    AutoDisposeNotifierProvider<AvailableSymbols, List<String>>.internal(
  AvailableSymbols.new,
  name: r'availableSymbolsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableSymbolsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AvailableSymbols = AutoDisposeNotifier<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
