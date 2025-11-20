import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/futures_position.dart';
import '../services/futures_service.dart';
import 'services_provider.dart';

part 'futures_provider.g.dart';

/// Provider for Futures Service
///
/// Handles futures trading operations on KuCoin:
/// - Get open positions
/// - Close positions (single/all/filtered)
/// - Stop loss and take profit management
/// - Price information (mark/index prices)
/// - Symbol conversion helpers
@riverpod
FuturesService futuresService(FuturesServiceRef ref) {
  final dio = ref.watch(dioProvider);
  return FuturesService(dio);
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
@riverpod
class FuturesPositions extends _$FuturesPositions {
  @override
  FutureOr<FuturesPositionsResponse> build({
    String exchange = 'kucoin',
  }) async {
    return _fetchPositions(exchange);
  }

  Future<FuturesPositionsResponse> _fetchPositions(String exchange) async {
    final service = ref.read(futuresServiceProvider);
    return await service.getPositions(exchange: exchange);
  }

  /// Manual refresh of futures positions
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPositions(exchange));
  }

  /// Close a specific position
  ///
  /// Parameters:
  /// - symbol: Futures symbol (e.g., 'BTCUSDTM')
  ///
  /// Returns close position response with P&L and execution details.
  Future<CloseFuturesPositionResponse> closePosition(String symbol) async {
    try {
      final service = ref.read(futuresServiceProvider);
      final result = await service.closePosition(
        symbol: symbol,
        exchange: exchange,
      );

      // Refresh positions after closing
      await refresh();

      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Close all open positions
  ///
  /// Closes all futures positions one by one.
  /// Returns list of close responses for each position.
  Future<List<CloseFuturesPositionResponse>> closeAll() async {
    try {
      final service = ref.read(futuresServiceProvider);
      final results = await service.closeAllPositions(exchange: exchange);

      // Refresh positions after closing all
      await refresh();

      return results;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Close all losing positions
  ///
  /// Closes only positions with negative P&L.
  /// Returns list of close responses.
  Future<List<CloseFuturesPositionResponse>> closeLosingPositions() async {
    try {
      final service = ref.read(futuresServiceProvider);
      final results = await service.closeLosingPositions(exchange: exchange);

      // Refresh positions after closing
      await refresh();

      return results;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Close all profitable positions
  ///
  /// Closes only positions with positive P&L.
  /// Returns list of close responses.
  Future<List<CloseFuturesPositionResponse>> closeProfitablePositions() async {
    try {
      final service = ref.read(futuresServiceProvider);
      final results = await service.closeProfitablePositions(exchange: exchange);

      // Refresh positions after closing
      await refresh();

      return results;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Apply stop loss to positions
  ///
  /// Closes positions that exceed the maximum loss percentage.
  ///
  /// Parameters:
  /// - maxLossPercent: Maximum loss percentage (e.g., 5.0 = 5%)
  ///
  /// Returns list of close responses for positions that hit stop loss.
  Future<List<CloseFuturesPositionResponse>> applyStopLoss({
    required double maxLossPercent,
  }) async {
    try {
      final service = ref.read(futuresServiceProvider);
      final results = await service.applyStopLoss(
        maxLossPercent: maxLossPercent,
        exchange: exchange,
      );

      // Refresh positions after applying stop loss
      await refresh();

      return results;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Apply take profit to positions
  ///
  /// Closes positions that reach the minimum profit percentage.
  ///
  /// Parameters:
  /// - minProfitPercent: Minimum profit percentage (e.g., 2.0 = 2%)
  ///
  /// Returns list of close responses for positions that hit take profit.
  Future<List<CloseFuturesPositionResponse>> applyTakeProfit({
    required double minProfitPercent,
  }) async {
    try {
      final service = ref.read(futuresServiceProvider);
      final results = await service.applyTakeProfit(
        minProfitPercent: minProfitPercent,
        exchange: exchange,
      );

      // Refresh positions after applying take profit
      await refresh();

      return results;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for a specific futures position
///
/// Returns details for a single position by symbol.
///
/// Parameters:
/// - symbol: Futures symbol (e.g., 'BTCUSDTM')
/// - exchange: Exchange name (default: 'kucoin')
@riverpod
Future<FuturesPosition?> futuresPosition(
  FuturesPositionRef ref, {
  required String symbol,
  String exchange = 'kucoin',
}) async {
  final positionsResponse = await ref.watch(
    futuresPositionsProvider(exchange: exchange).future,
  );

  return positionsResponse.positions.firstWhere(
    (p) => p.symbol == symbol,
    orElse: () => throw Exception('Position not found: $symbol'),
  );
}

/// Provider for mark price
///
/// Gets the mark price (price of mark) for a futures symbol.
///
/// Parameters:
/// - symbol: Futures symbol (e.g., 'BTCUSDTM')
/// - exchange: Exchange name (default: 'kucoin')
@riverpod
Future<double> markPrice(
  MarkPriceRef ref, {
  required String symbol,
  String exchange = 'kucoin',
}) async {
  final service = ref.watch(futuresServiceProvider);
  return await service.getMarkPrice(
    symbol: symbol,
    exchange: exchange,
  );
}

/// Provider for index price
///
/// Gets the index price for a futures symbol.
///
/// Parameters:
/// - symbol: Futures symbol (e.g., 'BTCUSDTM')
/// - exchange: Exchange name (default: 'kucoin')
@riverpod
Future<double> indexPrice(
  IndexPriceRef ref, {
  required String symbol,
  String exchange = 'kucoin',
}) async {
  final service = ref.watch(futuresServiceProvider);
  return await service.getIndexPrice(
    symbol: symbol,
    exchange: exchange,
  );
}

/// Provider for total positions count
///
/// Returns the number of open futures positions.
/// Derived from positions response.
@riverpod
int totalFuturesPositions(
  TotalFuturesPositionsRef ref, {
  String exchange = 'kucoin',
}) {
  final positionsAsync = ref.watch(
    futuresPositionsProvider(exchange: exchange),
  );

  return positionsAsync.when(
    data: (response) => response.count,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

/// Provider for total unrealized P&L
///
/// Returns the total unrealized profit/loss across all positions.
/// Derived from positions response.
@riverpod
double totalUnrealizedPnl(
  TotalUnrealizedPnlRef ref, {
  String exchange = 'kucoin',
}) {
  final positionsAsync = ref.watch(
    futuresPositionsProvider(exchange: exchange),
  );

  return positionsAsync.when(
    data: (response) => response.totalUnrealizedPnl,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
}

/// Provider for profitable positions count
///
/// Returns the number of positions with positive P&L.
/// Derived from positions list.
@riverpod
int profitablePositionsCount(
  ProfitablePositionsCountRef ref, {
  String exchange = 'kucoin',
}) {
  final positionsAsync = ref.watch(
    futuresPositionsProvider(exchange: exchange),
  );

  return positionsAsync.when(
    data: (response) => response.positions.where((p) => p.isProfit).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

/// Provider for losing positions count
///
/// Returns the number of positions with negative P&L.
/// Derived from positions list.
@riverpod
int losingPositionsCount(
  LosingPositionsCountRef ref, {
  String exchange = 'kucoin',
}) {
  final positionsAsync = ref.watch(
    futuresPositionsProvider(exchange: exchange),
  );

  return positionsAsync.when(
    data: (response) => response.positions.where((p) => p.isLoss).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

/// Provider for long positions
///
/// Returns only long positions.
/// Filtered from positions list.
@riverpod
List<FuturesPosition> longPositions(
  LongPositionsRef ref, {
  String exchange = 'kucoin',
}) {
  final positionsAsync = ref.watch(
    futuresPositionsProvider(exchange: exchange),
  );

  return positionsAsync.when(
    data: (response) => response.positions.where((p) => p.side == 'LONG').toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for short positions
///
/// Returns only short positions.
/// Filtered from positions list.
@riverpod
List<FuturesPosition> shortPositions(
  ShortPositionsRef ref, {
  String exchange = 'kucoin',
}) {
  final positionsAsync = ref.watch(
    futuresPositionsProvider(exchange: exchange),
  );

  return positionsAsync.when(
    data: (response) => response.positions.where((p) => p.side == 'SHORT').toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for positions sorted by P&L
///
/// Returns positions sorted by P&L percentage (highest first).
///
/// Parameters:
/// - ascending: Sort order (true = lowest first, false = highest first)
/// - exchange: Exchange name (default: 'kucoin')
@riverpod
List<FuturesPosition> positionsSortedByPnl(
  PositionsSortedByPnlRef ref, {
  bool ascending = false,
  String exchange = 'kucoin',
}) {
  final positionsAsync = ref.watch(
    futuresPositionsProvider(exchange: exchange),
  );

  return positionsAsync.when(
    data: (response) {
      final sorted = [...response.positions];
      sorted.sort((a, b) {
        final comparison = a.pnlPercent.compareTo(b.pnlPercent);
        return ascending ? comparison : -comparison;
      });
      return sorted;
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for positions by symbol filter
///
/// Returns positions filtered by symbol pattern.
/// Useful for filtering by base currency (e.g., all BTC positions).
///
/// Parameters:
/// - pattern: Symbol pattern to match (case-insensitive)
/// - exchange: Exchange name (default: 'kucoin')
@riverpod
List<FuturesPosition> positionsBySymbol(
  PositionsBySymbolRef ref, {
  required String pattern,
  String exchange = 'kucoin',
}) {
  final positionsAsync = ref.watch(
    futuresPositionsProvider(exchange: exchange),
  );

  return positionsAsync.when(
    data: (response) => response.positions
        .where((p) => p.symbol.toUpperCase().contains(pattern.toUpperCase()))
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
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
@riverpod
class FuturesStats extends _$FuturesStats {
  @override
  FuturesStatistics build({String exchange = 'kucoin'}) {
    final positionsAsync = ref.watch(
      futuresPositionsProvider(exchange: exchange),
    );

    return positionsAsync.when(
      data: (response) => _calculateStats(response),
      loading: () => FuturesStatistics.empty(),
      error: (_, __) => FuturesStatistics.empty(),
    );
  }

  FuturesStatistics _calculateStats(FuturesPositionsResponse response) {
    if (response.positions.isEmpty) {
      return FuturesStatistics.empty();
    }

    final positions = response.positions;

    final longCount = positions.where((p) => p.side == 'LONG').length;
    final shortCount = positions.where((p) => p.side == 'SHORT').length;
    final profitableCount = positions.where((p) => p.isProfit).length;
    final losingCount = positions.where((p) => p.isLoss).length;

    final avgPnlPercent = positions.isEmpty
        ? 0.0
        : positions.fold<double>(0, (sum, p) => sum + p.pnlPercent) /
            positions.length;

    final largestGain = positions.isEmpty
        ? 0.0
        : positions.map((p) => p.pnlPercent).reduce((a, b) => a > b ? a : b);

    final largestLoss = positions.isEmpty
        ? 0.0
        : positions.map((p) => p.pnlPercent).reduce((a, b) => a < b ? a : b);

    return FuturesStatistics(
      totalPositions: response.count,
      longPositions: longCount,
      shortPositions: shortCount,
      profitablePositions: profitableCount,
      losingPositions: losingCount,
      totalUnrealizedPnl: response.totalUnrealizedPnl,
      averagePnlPercent: avgPnlPercent,
      largestGain: largestGain,
      largestLoss: largestLoss,
    );
  }
}

/// Futures statistics model
class FuturesStatistics {
  final int totalPositions;
  final int longPositions;
  final int shortPositions;
  final int profitablePositions;
  final int losingPositions;
  final double totalUnrealizedPnl;
  final double averagePnlPercent;
  final double largestGain;
  final double largestLoss;

  FuturesStatistics({
    required this.totalPositions,
    required this.longPositions,
    required this.shortPositions,
    required this.profitablePositions,
    required this.losingPositions,
    required this.totalUnrealizedPnl,
    required this.averagePnlPercent,
    required this.largestGain,
    required this.largestLoss,
  });

  factory FuturesStatistics.empty() {
    return FuturesStatistics(
      totalPositions: 0,
      longPositions: 0,
      shortPositions: 0,
      profitablePositions: 0,
      losingPositions: 0,
      totalUnrealizedPnl: 0.0,
      averagePnlPercent: 0.0,
      largestGain: 0.0,
      largestLoss: 0.0,
    );
  }
}
