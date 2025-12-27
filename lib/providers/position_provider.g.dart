// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$positionsHash() => r'788d5dca80077974325679534d70d763255f49c1';

/// Provider for real-time positions stream via WebSocket
///
/// Provides live updates of open positions as they change.
/// Uses WebSocket connection for real-time updates with <1s latency.
///
/// Returns Stream<Position> that emits whenever a position changes.
///
/// NOTE: This returns individual position updates. If you need a list of all
/// current positions, use the REST API via positionServiceProvider.getPositions()
///
/// Copied from [positions].
@ProviderFor(positions)
final positionsProvider = AutoDisposeStreamProvider<Position>.internal(
  positions,
  name: r'positionsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$positionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PositionsRef = AutoDisposeStreamProviderRef<Position>;
String _$positionHistoryHash() => r'6f430e67d86cabd57d99dda582ceda82c07e6ef9';

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

/// Provider for position history with pagination support
///
/// Fetches closed positions with optional filtering:
/// - limit: Number of positions to fetch (default: 100)
/// - fromDate: Start date (ISO 8601 format, optional)
/// - toDate: End date (ISO 8601 format, optional)
///
/// Example usage:
/// ```dart
/// final history = ref.watch(positionHistoryProvider(limit: 50));
/// ```
///
/// Copied from [positionHistory].
@ProviderFor(positionHistory)
const positionHistoryProvider = PositionHistoryFamily();

/// Provider for position history with pagination support
///
/// Fetches closed positions with optional filtering:
/// - limit: Number of positions to fetch (default: 100)
/// - fromDate: Start date (ISO 8601 format, optional)
/// - toDate: End date (ISO 8601 format, optional)
///
/// Example usage:
/// ```dart
/// final history = ref.watch(positionHistoryProvider(limit: 50));
/// ```
///
/// Copied from [positionHistory].
class PositionHistoryFamily extends Family<AsyncValue<List<Position>>> {
  /// Provider for position history with pagination support
  ///
  /// Fetches closed positions with optional filtering:
  /// - limit: Number of positions to fetch (default: 100)
  /// - fromDate: Start date (ISO 8601 format, optional)
  /// - toDate: End date (ISO 8601 format, optional)
  ///
  /// Example usage:
  /// ```dart
  /// final history = ref.watch(positionHistoryProvider(limit: 50));
  /// ```
  ///
  /// Copied from [positionHistory].
  const PositionHistoryFamily();

  /// Provider for position history with pagination support
  ///
  /// Fetches closed positions with optional filtering:
  /// - limit: Number of positions to fetch (default: 100)
  /// - fromDate: Start date (ISO 8601 format, optional)
  /// - toDate: End date (ISO 8601 format, optional)
  ///
  /// Example usage:
  /// ```dart
  /// final history = ref.watch(positionHistoryProvider(limit: 50));
  /// ```
  ///
  /// Copied from [positionHistory].
  PositionHistoryProvider call({
    int? limit,
    String? fromDate,
    String? toDate,
  }) {
    return PositionHistoryProvider(
      limit: limit,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  @override
  PositionHistoryProvider getProviderOverride(
    covariant PositionHistoryProvider provider,
  ) {
    return call(
      limit: provider.limit,
      fromDate: provider.fromDate,
      toDate: provider.toDate,
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
  String? get name => r'positionHistoryProvider';
}

/// Provider for position history with pagination support
///
/// Fetches closed positions with optional filtering:
/// - limit: Number of positions to fetch (default: 100)
/// - fromDate: Start date (ISO 8601 format, optional)
/// - toDate: End date (ISO 8601 format, optional)
///
/// Example usage:
/// ```dart
/// final history = ref.watch(positionHistoryProvider(limit: 50));
/// ```
///
/// Copied from [positionHistory].
class PositionHistoryProvider
    extends AutoDisposeFutureProvider<List<Position>> {
  /// Provider for position history with pagination support
  ///
  /// Fetches closed positions with optional filtering:
  /// - limit: Number of positions to fetch (default: 100)
  /// - fromDate: Start date (ISO 8601 format, optional)
  /// - toDate: End date (ISO 8601 format, optional)
  ///
  /// Example usage:
  /// ```dart
  /// final history = ref.watch(positionHistoryProvider(limit: 50));
  /// ```
  ///
  /// Copied from [positionHistory].
  PositionHistoryProvider({
    int? limit,
    String? fromDate,
    String? toDate,
  }) : this._internal(
          (ref) => positionHistory(
            ref as PositionHistoryRef,
            limit: limit,
            fromDate: fromDate,
            toDate: toDate,
          ),
          from: positionHistoryProvider,
          name: r'positionHistoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$positionHistoryHash,
          dependencies: PositionHistoryFamily._dependencies,
          allTransitiveDependencies:
              PositionHistoryFamily._allTransitiveDependencies,
          limit: limit,
          fromDate: fromDate,
          toDate: toDate,
        );

  PositionHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
    required this.fromDate,
    required this.toDate,
  }) : super.internal();

  final int? limit;
  final String? fromDate;
  final String? toDate;

  @override
  Override overrideWith(
    FutureOr<List<Position>> Function(PositionHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PositionHistoryProvider._internal(
        (ref) => create(ref as PositionHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
        fromDate: fromDate,
        toDate: toDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Position>> createElement() {
    return _PositionHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PositionHistoryProvider &&
        other.limit == limit &&
        other.fromDate == fromDate &&
        other.toDate == toDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);
    hash = _SystemHash.combine(hash, fromDate.hashCode);
    hash = _SystemHash.combine(hash, toDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PositionHistoryRef on AutoDisposeFutureProviderRef<List<Position>> {
  /// The parameter `limit` of this provider.
  int? get limit;

  /// The parameter `fromDate` of this provider.
  String? get fromDate;

  /// The parameter `toDate` of this provider.
  String? get toDate;
}

class _PositionHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<Position>>
    with PositionHistoryRef {
  _PositionHistoryProviderElement(super.provider);

  @override
  int? get limit => (origin as PositionHistoryProvider).limit;
  @override
  String? get fromDate => (origin as PositionHistoryProvider).fromDate;
  @override
  String? get toDate => (origin as PositionHistoryProvider).toDate;
}

String _$selectedPositionHash() => r'f605056e612f9c6c107cc9df135b22a34eae40fc';

/// Provider for currently selected position in UI
///
/// State provider to track which position is selected for detailed view
/// or editing. Returns null if no position is selected.
///
/// Copied from [SelectedPosition].
@ProviderFor(SelectedPosition)
final selectedPositionProvider =
    AutoDisposeNotifierProvider<SelectedPosition, Position?>.internal(
  SelectedPosition.new,
  name: r'selectedPositionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedPositionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedPosition = AutoDisposeNotifier<Position?>;
String _$positionCloserHash() => r'dddd9b5ad40ff5a1acf12d3b9ae3b644d9fc4c31';

/// Provider for closing a position
///
/// Closes a position and invalidates related providers to trigger refresh.
///
/// Copied from [PositionCloser].
@ProviderFor(PositionCloser)
final positionCloserProvider =
    AutoDisposeAsyncNotifierProvider<PositionCloser, void>.internal(
  PositionCloser.new,
  name: r'positionCloserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$positionCloserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PositionCloser = AutoDisposeAsyncNotifier<void>;
String _$slTpUpdaterHash() => r'a49f94b003eec13eaa0997031b987a4b7a8ecbcf';

/// Provider for updating SL/TP of a position
///
/// Updates stop-loss and take-profit levels for an open position.
///
/// Copied from [SlTpUpdater].
@ProviderFor(SlTpUpdater)
final slTpUpdaterProvider =
    AutoDisposeAsyncNotifierProvider<SlTpUpdater, void>.internal(
  SlTpUpdater.new,
  name: r'slTpUpdaterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$slTpUpdaterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SlTpUpdater = AutoDisposeAsyncNotifier<void>;
String _$breakevenMoverHash() => r'0e638c4b941601fe90ab688a638e834ca444bea8';

/// Provider for moving position SL to breakeven
///
/// Automatically sets stop-loss to entry price to protect against losses
/// while keeping potential profits.
///
/// Copied from [BreakevenMover].
@ProviderFor(BreakevenMover)
final breakevenMoverProvider =
    AutoDisposeAsyncNotifierProvider<BreakevenMover, void>.internal(
  BreakevenMover.new,
  name: r'breakevenMoverProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$breakevenMoverHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BreakevenMover = AutoDisposeAsyncNotifier<void>;
String _$trailingStopEnablerHash() =>
    r'163a61d5272bcd9c2a25ee93e6def8eb691f9cde';

/// Provider for enabling trailing stop on a position
///
/// Activates trailing stop-loss that follows price movement,
/// protecting profits as the position moves in your favor.
///
/// Copied from [TrailingStopEnabler].
@ProviderFor(TrailingStopEnabler)
final trailingStopEnablerProvider =
    AutoDisposeAsyncNotifierProvider<TrailingStopEnabler, void>.internal(
  TrailingStopEnabler.new,
  name: r'trailingStopEnablerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$trailingStopEnablerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TrailingStopEnabler = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
