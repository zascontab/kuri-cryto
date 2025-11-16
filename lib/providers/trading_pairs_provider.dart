import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/trading_pair.dart';
import 'services_provider.dart';

part 'trading_pairs_provider.g.dart';

/// Provider for active trading pairs
///
/// Fetches the list of currently active trading pairs being monitored
/// by the scalping engine.
///
/// Example usage:
/// ```dart
/// final pairs = ref.watch(activePairsProvider);
/// ```
@riverpod
Future<List<TradingPair>> activePairs(ActivePairsRef ref) async {
  final service = ref.watch(scalpingServiceProvider);

  try {
    final pairsData = await service.getActivePairs();
    return pairsData.map((data) => TradingPair.fromJson(data)).toList();
  } catch (e) {
    rethrow;
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
@riverpod
Future<List<TradingPair>> availablePairs(
  AvailablePairsRef ref,
  String exchange,
) async {
  final service = ref.watch(scalpingServiceProvider);

  try {
    final pairsData = await service.getAvailablePairs(exchange);
    return pairsData.map((data) => TradingPair.fromJson(data)).toList();
  } catch (e) {
    rethrow;
  }
}

/// Provider for adding a trading pair
///
/// Adds a new trading pair to the scalping engine and invalidates
/// the active pairs list to trigger a refresh.
@riverpod
class PairAdder extends _$PairAdder {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Add a trading pair
  ///
  /// Parameters:
  /// - exchange: Exchange name (e.g., 'kucoin')
  /// - symbol: Trading pair symbol (e.g., 'BTC-USDT')
  ///
  /// Returns true if successful, throws exception on error.
  Future<bool> addPair({
    required String exchange,
    required String symbol,
  }) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(scalpingServiceProvider);
      final result = await service.addPair(exchange, symbol);

      state = const AsyncValue.data(null);

      // Invalidate active pairs to trigger refresh
      ref.invalidate(activePairsProvider);

      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for removing a trading pair
///
/// Removes a trading pair from the scalping engine and invalidates
/// the active pairs list to trigger a refresh.
@riverpod
class PairRemover extends _$PairRemover {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Remove a trading pair
  ///
  /// Parameters:
  /// - exchange: Exchange name (e.g., 'kucoin')
  /// - symbol: Trading pair symbol (e.g., 'BTC-USDT')
  /// - hasOpenPositions: Whether the pair has open positions (for validation)
  ///
  /// Returns true if successful, throws exception on error.
  /// Throws ArgumentError if trying to remove a pair with open positions.
  Future<bool> removePair({
    required String exchange,
    required String symbol,
    bool hasOpenPositions = false,
  }) async {
    // Validation: don't allow removing pairs with open positions
    if (hasOpenPositions) {
      throw ArgumentError(
        'Cannot remove pair with open positions. Please close all positions first.',
      );
    }

    state = const AsyncValue.loading();

    try {
      final service = ref.read(scalpingServiceProvider);
      final result = await service.removePair(exchange, symbol);

      state = const AsyncValue.data(null);

      // Invalidate active pairs to trigger refresh
      ref.invalidate(activePairsProvider);

      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for currently selected trading pair in UI
///
/// State provider to track which pair is selected for detailed view.
/// Returns null if no pair is selected.
@riverpod
class SelectedTradingPair extends _$SelectedTradingPair {
  @override
  TradingPair? build() {
    return null;
  }

  /// Select a trading pair
  void select(TradingPair pair) {
    state = pair;
  }

  /// Clear selection
  void clear() {
    state = null;
  }
}

/// Provider for exchange list
///
/// Returns a list of supported exchanges.
/// This could be fetched from an API endpoint in the future.
@riverpod
List<String> supportedExchanges(SupportedExchangesRef ref) {
  return [
    'kucoin',
    'binance',
    'bybit',
    'okx',
  ];
}
