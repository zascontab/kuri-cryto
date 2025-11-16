import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/position.dart';
import 'services_provider.dart';

part 'position_provider.g.dart';

/// Provider for real-time positions stream via WebSocket
///
/// Provides live updates of open positions as they change.
/// Uses WebSocket connection for real-time updates with <1s latency.
///
/// Returns Stream<Position> that emits whenever a position changes.
///
/// NOTE: This returns individual position updates. If you need a list of all
/// current positions, use the REST API via positionServiceProvider.getPositions()
@riverpod
Stream<Position> positions(PositionsRef ref) {
  final wsService = ref.watch(websocketServiceProvider);

  // Ensure connection
  wsService.connect();

  // Transform WebSocket Position to model Position
  return wsService.positionUpdates.map((wsPosition) {
    return Position(
      id: wsPosition.id,
      symbol: wsPosition.symbol,
      side: wsPosition.side,
      entryPrice: wsPosition.entryPrice,
      currentPrice: wsPosition.currentPrice,
      size: wsPosition.size,
      leverage: wsPosition.leverage,
      stopLoss: wsPosition.stopLoss,
      takeProfit: wsPosition.takeProfit,
      unrealizedPnl: wsPosition.unrealizedPnl,
      realizedPnl: wsPosition.realizedPnl ?? 0.0,
      openTime: wsPosition.openTime,
      closeTime: wsPosition.closeTime,
      strategy: wsPosition.strategy,
      status: wsPosition.status,
    );
  });
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
@riverpod
Future<List<Position>> positionHistory(
  PositionHistoryRef ref, {
  int? limit,
  String? fromDate,
  String? toDate,
}) async {
  final service = ref.watch(positionServiceProvider);

  return await service.getPositionHistory(
    limit: limit,
    from: fromDate,
    to: toDate,
  );
}

/// Provider for currently selected position in UI
///
/// State provider to track which position is selected for detailed view
/// or editing. Returns null if no position is selected.
@riverpod
class SelectedPosition extends _$SelectedPosition {
  @override
  Position? build() {
    return null;
  }

  /// Select a position
  void select(Position position) {
    state = position;
  }

  /// Clear selection
  void clear() {
    state = null;
  }

  /// Update the selected position with new data
  /// Used when receiving WebSocket updates
  void update(Position position) {
    if (state?.id == position.id) {
      state = position;
    }
  }
}

/// Provider for closing a position
///
/// Closes a position and invalidates related providers to trigger refresh.
@riverpod
class PositionCloser extends _$PositionCloser {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Close a position by ID
  ///
  /// Returns true if successful, throws exception on error.
  Future<bool> closePosition(String positionId) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(positionServiceProvider);
      final result = await service.closePosition(positionId);

      state = const AsyncValue.data(null);

      // Invalidate positions to trigger refresh
      ref.invalidate(positionsProvider);

      // Clear selected position if it was the closed one
      final selected = ref.read(selectedPositionProvider);
      if (selected?.id == positionId) {
        ref.read(selectedPositionProvider.notifier).clear();
      }

      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for updating SL/TP of a position
///
/// Updates stop-loss and take-profit levels for an open position.
@riverpod
class SlTpUpdater extends _$SlTpUpdater {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Update SL/TP for a position
  ///
  /// Parameters:
  /// - positionId: ID of the position to update
  /// - stopLoss: New stop-loss price (optional)
  /// - takeProfit: New take-profit price (optional)
  ///
  /// At least one of stopLoss or takeProfit must be provided.
  Future<bool> updateSlTp({
    required String positionId,
    double? stopLoss,
    double? takeProfit,
  }) async {
    if (stopLoss == null && takeProfit == null) {
      throw ArgumentError('At least one of stopLoss or takeProfit must be provided');
    }

    state = const AsyncValue.loading();

    try {
      final service = ref.read(positionServiceProvider);
      final result = await service.updateSlTp(
        positionId,
        stopLoss: stopLoss,
        takeProfit: takeProfit,
      );

      state = const AsyncValue.data(null);

      // Invalidate positions to trigger refresh
      ref.invalidate(positionsProvider);

      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for moving position SL to breakeven
///
/// Automatically sets stop-loss to entry price to protect against losses
/// while keeping potential profits.
@riverpod
class BreakevenMover extends _$BreakevenMover {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Move stop-loss to breakeven for a position
  ///
  /// Sets SL = entry price, ensuring no loss if SL is hit.
  /// Returns the new stop-loss price.
  Future<double> moveToBreakeven(String positionId) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(positionServiceProvider);
      final newStopLoss = await service.moveToBreakeven(positionId);

      state = const AsyncValue.data(null);

      // Invalidate positions to trigger refresh
      ref.invalidate(positionsProvider);

      return newStopLoss;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for enabling trailing stop on a position
///
/// Activates trailing stop-loss that follows price movement,
/// protecting profits as the position moves in your favor.
@riverpod
class TrailingStopEnabler extends _$TrailingStopEnabler {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Enable trailing stop for a position
  ///
  /// Parameters:
  /// - positionId: ID of the position
  /// - distancePercent: Trailing distance as percentage (e.g., 0.5 for 0.5%)
  ///   Valid range: 0.1% - 1.0%
  Future<bool> enableTrailingStop({
    required String positionId,
    required double distancePercent,
  }) async {
    if (distancePercent < 0.1 || distancePercent > 1.0) {
      throw ArgumentError('Distance must be between 0.1% and 1.0%');
    }

    state = const AsyncValue.loading();

    try {
      final service = ref.read(positionServiceProvider);
      final result = await service.enableTrailingStop(
        positionId,
        distancePercent,
      );

      state = const AsyncValue.data(null);

      // Invalidate positions to trigger refresh
      ref.invalidate(positionsProvider);

      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for aggregated position statistics
///
/// NOTE: Temporarily disabled. Needs to be refactored to work with Stream<Position>
/// instead of List<Position>.
///
/// TODO: Implement using StreamProvider that accumulates positions
/*
@riverpod
class PositionStats extends _$PositionStats {
  @override
  PositionStatistics build() {
    final positionsAsync = ref.watch(positionsProvider);

    return positionsAsync.when(
      data: (positions) => _calculateStats(positions),
      loading: () => PositionStatistics.empty(),
      error: (_, __) => PositionStatistics.empty(),
    );
  }

  PositionStatistics _calculateStats(List<Position> positions) {
    if (positions.isEmpty) {
      return PositionStatistics.empty();
    }

    final totalPnl = positions.fold<double>(
      0,
      (sum, pos) => sum + pos.unrealizedPnl,
    );

    final totalExposure = positions.fold<double>(
      0,
      (sum, pos) => sum + (pos.size * pos.currentPrice * pos.leverage),
    );

    final positionsByStrategy = <String, int>{};
    for (final pos in positions) {
      positionsByStrategy[pos.strategy] =
          (positionsByStrategy[pos.strategy] ?? 0) + 1;
    }

    return PositionStatistics(
      totalPositions: positions.length,
      totalUnrealizedPnl: totalPnl,
      totalExposure: totalExposure,
      positionsByStrategy: positionsByStrategy,
    );
  }
}
*/

/// Position statistics model
class PositionStatistics {
  final int totalPositions;
  final double totalUnrealizedPnl;
  final double totalExposure;
  final Map<String, int> positionsByStrategy;

  PositionStatistics({
    required this.totalPositions,
    required this.totalUnrealizedPnl,
    required this.totalExposure,
    required this.positionsByStrategy,
  });

  factory PositionStatistics.empty() {
    return PositionStatistics(
      totalPositions: 0,
      totalUnrealizedPnl: 0,
      totalExposure: 0,
      positionsByStrategy: {},
    );
  }
}
