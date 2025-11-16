// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availableSymbolsHash() => r'a8df3bd3c372b1a7022f228961e02b8a20543575';

/// Provider for available symbols
///
/// Fetches list of symbols available for analysis
///
/// Copied from [availableSymbols].
@ProviderFor(availableSymbols)
final availableSymbolsProvider =
    AutoDisposeFutureProvider<List<String>>.internal(
  availableSymbols,
  name: r'availableSymbolsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableSymbolsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AvailableSymbolsRef = AutoDisposeFutureProviderRef<List<String>>;
String _$supportedTimeframesHash() =>
    r'85ac581f8ba56b14602bf6a782bc68da30aaf99d';

/// Provider for supported timeframes
///
/// Fetches list of timeframes supported by the analysis service
///
/// Copied from [supportedTimeframes].
@ProviderFor(supportedTimeframes)
final supportedTimeframesProvider =
    AutoDisposeFutureProvider<List<String>>.internal(
  supportedTimeframes,
  name: r'supportedTimeframesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$supportedTimeframesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SupportedTimeframesRef = AutoDisposeFutureProviderRef<List<String>>;
String _$timeframeAnalysisHash() => r'2d71ef86f432a7a8b051fd52d487eb702fc6667e';

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

/// Provider for timeframe-specific analysis
///
/// Fetches analysis for a specific symbol and timeframe
///
/// Copied from [timeframeAnalysis].
@ProviderFor(timeframeAnalysis)
const timeframeAnalysisProvider = TimeframeAnalysisFamily();

/// Provider for timeframe-specific analysis
///
/// Fetches analysis for a specific symbol and timeframe
///
/// Copied from [timeframeAnalysis].
class TimeframeAnalysisFamily extends Family<AsyncValue<TimeframeAnalysis>> {
  /// Provider for timeframe-specific analysis
  ///
  /// Fetches analysis for a specific symbol and timeframe
  ///
  /// Copied from [timeframeAnalysis].
  const TimeframeAnalysisFamily();

  /// Provider for timeframe-specific analysis
  ///
  /// Fetches analysis for a specific symbol and timeframe
  ///
  /// Copied from [timeframeAnalysis].
  TimeframeAnalysisProvider call(
    String symbol,
    String timeframe,
  ) {
    return TimeframeAnalysisProvider(
      symbol,
      timeframe,
    );
  }

  @override
  TimeframeAnalysisProvider getProviderOverride(
    covariant TimeframeAnalysisProvider provider,
  ) {
    return call(
      provider.symbol,
      provider.timeframe,
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
  String? get name => r'timeframeAnalysisProvider';
}

/// Provider for timeframe-specific analysis
///
/// Fetches analysis for a specific symbol and timeframe
///
/// Copied from [timeframeAnalysis].
class TimeframeAnalysisProvider
    extends AutoDisposeFutureProvider<TimeframeAnalysis> {
  /// Provider for timeframe-specific analysis
  ///
  /// Fetches analysis for a specific symbol and timeframe
  ///
  /// Copied from [timeframeAnalysis].
  TimeframeAnalysisProvider(
    String symbol,
    String timeframe,
  ) : this._internal(
          (ref) => timeframeAnalysis(
            ref as TimeframeAnalysisRef,
            symbol,
            timeframe,
          ),
          from: timeframeAnalysisProvider,
          name: r'timeframeAnalysisProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$timeframeAnalysisHash,
          dependencies: TimeframeAnalysisFamily._dependencies,
          allTransitiveDependencies:
              TimeframeAnalysisFamily._allTransitiveDependencies,
          symbol: symbol,
          timeframe: timeframe,
        );

  TimeframeAnalysisProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.symbol,
    required this.timeframe,
  }) : super.internal();

  final String symbol;
  final String timeframe;

  @override
  Override overrideWith(
    FutureOr<TimeframeAnalysis> Function(TimeframeAnalysisRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TimeframeAnalysisProvider._internal(
        (ref) => create(ref as TimeframeAnalysisRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        symbol: symbol,
        timeframe: timeframe,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<TimeframeAnalysis> createElement() {
    return _TimeframeAnalysisProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TimeframeAnalysisProvider &&
        other.symbol == symbol &&
        other.timeframe == timeframe;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, symbol.hashCode);
    hash = _SystemHash.combine(hash, timeframe.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TimeframeAnalysisRef on AutoDisposeFutureProviderRef<TimeframeAnalysis> {
  /// The parameter `symbol` of this provider.
  String get symbol;

  /// The parameter `timeframe` of this provider.
  String get timeframe;
}

class _TimeframeAnalysisProviderElement
    extends AutoDisposeFutureProviderElement<TimeframeAnalysis>
    with TimeframeAnalysisRef {
  _TimeframeAnalysisProviderElement(super.provider);

  @override
  String get symbol => (origin as TimeframeAnalysisProvider).symbol;
  @override
  String get timeframe => (origin as TimeframeAnalysisProvider).timeframe;
}

String _$isBullishSignalHash() => r'a7faa98a1cf16f11d087f7fc24f8c6f7fdd27927';

/// Provider to check if a signal is bullish
///
/// Copied from [isBullishSignal].
@ProviderFor(isBullishSignal)
const isBullishSignalProvider = IsBullishSignalFamily();

/// Provider to check if a signal is bullish
///
/// Copied from [isBullishSignal].
class IsBullishSignalFamily extends Family<bool> {
  /// Provider to check if a signal is bullish
  ///
  /// Copied from [isBullishSignal].
  const IsBullishSignalFamily();

  /// Provider to check if a signal is bullish
  ///
  /// Copied from [isBullishSignal].
  IsBullishSignalProvider call(
    SignalType signal,
  ) {
    return IsBullishSignalProvider(
      signal,
    );
  }

  @override
  IsBullishSignalProvider getProviderOverride(
    covariant IsBullishSignalProvider provider,
  ) {
    return call(
      provider.signal,
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
  String? get name => r'isBullishSignalProvider';
}

/// Provider to check if a signal is bullish
///
/// Copied from [isBullishSignal].
class IsBullishSignalProvider extends AutoDisposeProvider<bool> {
  /// Provider to check if a signal is bullish
  ///
  /// Copied from [isBullishSignal].
  IsBullishSignalProvider(
    SignalType signal,
  ) : this._internal(
          (ref) => isBullishSignal(
            ref as IsBullishSignalRef,
            signal,
          ),
          from: isBullishSignalProvider,
          name: r'isBullishSignalProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isBullishSignalHash,
          dependencies: IsBullishSignalFamily._dependencies,
          allTransitiveDependencies:
              IsBullishSignalFamily._allTransitiveDependencies,
          signal: signal,
        );

  IsBullishSignalProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.signal,
  }) : super.internal();

  final SignalType signal;

  @override
  Override overrideWith(
    bool Function(IsBullishSignalRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsBullishSignalProvider._internal(
        (ref) => create(ref as IsBullishSignalRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        signal: signal,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsBullishSignalProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsBullishSignalProvider && other.signal == signal;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, signal.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin IsBullishSignalRef on AutoDisposeProviderRef<bool> {
  /// The parameter `signal` of this provider.
  SignalType get signal;
}

class _IsBullishSignalProviderElement extends AutoDisposeProviderElement<bool>
    with IsBullishSignalRef {
  _IsBullishSignalProviderElement(super.provider);

  @override
  SignalType get signal => (origin as IsBullishSignalProvider).signal;
}

String _$isBearishSignalHash() => r'b4c5d2d219d01de9bc5b08cc8482645cc2bac688';

/// Provider to check if a signal is bearish
///
/// Copied from [isBearishSignal].
@ProviderFor(isBearishSignal)
const isBearishSignalProvider = IsBearishSignalFamily();

/// Provider to check if a signal is bearish
///
/// Copied from [isBearishSignal].
class IsBearishSignalFamily extends Family<bool> {
  /// Provider to check if a signal is bearish
  ///
  /// Copied from [isBearishSignal].
  const IsBearishSignalFamily();

  /// Provider to check if a signal is bearish
  ///
  /// Copied from [isBearishSignal].
  IsBearishSignalProvider call(
    SignalType signal,
  ) {
    return IsBearishSignalProvider(
      signal,
    );
  }

  @override
  IsBearishSignalProvider getProviderOverride(
    covariant IsBearishSignalProvider provider,
  ) {
    return call(
      provider.signal,
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
  String? get name => r'isBearishSignalProvider';
}

/// Provider to check if a signal is bearish
///
/// Copied from [isBearishSignal].
class IsBearishSignalProvider extends AutoDisposeProvider<bool> {
  /// Provider to check if a signal is bearish
  ///
  /// Copied from [isBearishSignal].
  IsBearishSignalProvider(
    SignalType signal,
  ) : this._internal(
          (ref) => isBearishSignal(
            ref as IsBearishSignalRef,
            signal,
          ),
          from: isBearishSignalProvider,
          name: r'isBearishSignalProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isBearishSignalHash,
          dependencies: IsBearishSignalFamily._dependencies,
          allTransitiveDependencies:
              IsBearishSignalFamily._allTransitiveDependencies,
          signal: signal,
        );

  IsBearishSignalProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.signal,
  }) : super.internal();

  final SignalType signal;

  @override
  Override overrideWith(
    bool Function(IsBearishSignalRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsBearishSignalProvider._internal(
        (ref) => create(ref as IsBearishSignalRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        signal: signal,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsBearishSignalProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsBearishSignalProvider && other.signal == signal;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, signal.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin IsBearishSignalRef on AutoDisposeProviderRef<bool> {
  /// The parameter `signal` of this provider.
  SignalType get signal;
}

class _IsBearishSignalProviderElement extends AutoDisposeProviderElement<bool>
    with IsBearishSignalRef {
  _IsBearishSignalProviderElement(super.provider);

  @override
  SignalType get signal => (origin as IsBearishSignalProvider).signal;
}

String _$signalColorHash() => r'd4fdf38fe2434153a96c8dd697f5afb57dbb1142';

/// Provider to get signal color based on type
///
/// Copied from [signalColor].
@ProviderFor(signalColor)
const signalColorProvider = SignalColorFamily();

/// Provider to get signal color based on type
///
/// Copied from [signalColor].
class SignalColorFamily extends Family<int> {
  /// Provider to get signal color based on type
  ///
  /// Copied from [signalColor].
  const SignalColorFamily();

  /// Provider to get signal color based on type
  ///
  /// Copied from [signalColor].
  SignalColorProvider call(
    SignalType signal,
  ) {
    return SignalColorProvider(
      signal,
    );
  }

  @override
  SignalColorProvider getProviderOverride(
    covariant SignalColorProvider provider,
  ) {
    return call(
      provider.signal,
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
  String? get name => r'signalColorProvider';
}

/// Provider to get signal color based on type
///
/// Copied from [signalColor].
class SignalColorProvider extends AutoDisposeProvider<int> {
  /// Provider to get signal color based on type
  ///
  /// Copied from [signalColor].
  SignalColorProvider(
    SignalType signal,
  ) : this._internal(
          (ref) => signalColor(
            ref as SignalColorRef,
            signal,
          ),
          from: signalColorProvider,
          name: r'signalColorProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$signalColorHash,
          dependencies: SignalColorFamily._dependencies,
          allTransitiveDependencies:
              SignalColorFamily._allTransitiveDependencies,
          signal: signal,
        );

  SignalColorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.signal,
  }) : super.internal();

  final SignalType signal;

  @override
  Override overrideWith(
    int Function(SignalColorRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SignalColorProvider._internal(
        (ref) => create(ref as SignalColorRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        signal: signal,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<int> createElement() {
    return _SignalColorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SignalColorProvider && other.signal == signal;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, signal.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SignalColorRef on AutoDisposeProviderRef<int> {
  /// The parameter `signal` of this provider.
  SignalType get signal;
}

class _SignalColorProviderElement extends AutoDisposeProviderElement<int>
    with SignalColorRef {
  _SignalColorProviderElement(super.provider);

  @override
  SignalType get signal => (origin as SignalColorProvider).signal;
}

String _$confidenceLevelHash() => r'e67823ca9d374c1328ec31fbb0bad7640b7ff799';

/// Provider to get confidence level description
///
/// Copied from [confidenceLevel].
@ProviderFor(confidenceLevel)
const confidenceLevelProvider = ConfidenceLevelFamily();

/// Provider to get confidence level description
///
/// Copied from [confidenceLevel].
class ConfidenceLevelFamily extends Family<String> {
  /// Provider to get confidence level description
  ///
  /// Copied from [confidenceLevel].
  const ConfidenceLevelFamily();

  /// Provider to get confidence level description
  ///
  /// Copied from [confidenceLevel].
  ConfidenceLevelProvider call(
    double confidence,
  ) {
    return ConfidenceLevelProvider(
      confidence,
    );
  }

  @override
  ConfidenceLevelProvider getProviderOverride(
    covariant ConfidenceLevelProvider provider,
  ) {
    return call(
      provider.confidence,
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
  String? get name => r'confidenceLevelProvider';
}

/// Provider to get confidence level description
///
/// Copied from [confidenceLevel].
class ConfidenceLevelProvider extends AutoDisposeProvider<String> {
  /// Provider to get confidence level description
  ///
  /// Copied from [confidenceLevel].
  ConfidenceLevelProvider(
    double confidence,
  ) : this._internal(
          (ref) => confidenceLevel(
            ref as ConfidenceLevelRef,
            confidence,
          ),
          from: confidenceLevelProvider,
          name: r'confidenceLevelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$confidenceLevelHash,
          dependencies: ConfidenceLevelFamily._dependencies,
          allTransitiveDependencies:
              ConfidenceLevelFamily._allTransitiveDependencies,
          confidence: confidence,
        );

  ConfidenceLevelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.confidence,
  }) : super.internal();

  final double confidence;

  @override
  Override overrideWith(
    String Function(ConfidenceLevelRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConfidenceLevelProvider._internal(
        (ref) => create(ref as ConfidenceLevelRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        confidence: confidence,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<String> createElement() {
    return _ConfidenceLevelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConfidenceLevelProvider && other.confidence == confidence;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, confidence.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ConfidenceLevelRef on AutoDisposeProviderRef<String> {
  /// The parameter `confidence` of this provider.
  double get confidence;
}

class _ConfidenceLevelProviderElement extends AutoDisposeProviderElement<String>
    with ConfidenceLevelRef {
  _ConfidenceLevelProviderElement(super.provider);

  @override
  double get confidence => (origin as ConfidenceLevelProvider).confidence;
}

String _$multiTimeframeAnalysisNotifierHash() =>
    r'cc37a18207d39b555390809a721323ae45f3a0d6';

/// Provider for multi-timeframe analysis
///
/// Fetches and manages multi-timeframe analysis for a symbol
///
/// Copied from [MultiTimeframeAnalysisNotifier].
@ProviderFor(MultiTimeframeAnalysisNotifier)
final multiTimeframeAnalysisNotifierProvider = AutoDisposeAsyncNotifierProvider<
    MultiTimeframeAnalysisNotifier, MultiTimeframeAnalysis?>.internal(
  MultiTimeframeAnalysisNotifier.new,
  name: r'multiTimeframeAnalysisNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$multiTimeframeAnalysisNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MultiTimeframeAnalysisNotifier
    = AutoDisposeAsyncNotifier<MultiTimeframeAnalysis?>;
String _$selectedSymbolHash() => r'531a91f23bad165775ba3c2637f2e7627623f463';

/// Provider for selected symbol state
///
/// Manages the currently selected symbol for analysis
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
String _$selectedTimeframesHash() =>
    r'9ebf37cc68d16f4a45b7cc066fab33c505081bdb';

/// Provider for selected timeframes
///
/// Manages which timeframes are selected for analysis
///
/// Copied from [SelectedTimeframes].
@ProviderFor(SelectedTimeframes)
final selectedTimeframesProvider =
    AutoDisposeNotifierProvider<SelectedTimeframes, List<String>>.internal(
  SelectedTimeframes.new,
  name: r'selectedTimeframesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedTimeframesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedTimeframes = AutoDisposeNotifier<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
