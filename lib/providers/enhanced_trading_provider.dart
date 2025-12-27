import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/position.dart';
import '../models/technical_indicators.dart';
import '../services/enhanced_trading_service.dart';
import '../services/performance_cache_service.dart';
import '../services/logging_service.dart';

/// Enhanced Trading Provider with real-time updates and caching
class EnhancedTradingProvider extends StateNotifier<TradingState> {
  final EnhancedTradingService _tradingService;
  final PerformanceCacheService _cacheService;

  StreamSubscription<PositionUpdate>? _positionSubscription;
  Timer? _indicatorRefreshTimer;

  EnhancedTradingProvider(this._tradingService, this._cacheService)
      : super(const TradingState.initial()) {
    _initializeProvider();
  }

  void _initializeProvider() {
    _subscribeToPositionUpdates();
    _startIndicatorRefresh();

    LoggingService.instance.info(
      'Enhanced trading provider initialized',
      tag: 'EnhancedTradingProvider',
    );
  }

  /// Load positions with caching
  Future<void> loadPositions({
    String? exchange,
    String? marketType,
    String? symbol,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final cacheKey =
          'positions_${exchange ?? 'all'}_${marketType ?? 'all'}_${symbol ?? 'all'}';

      final positions = await _cacheService.getWithCaching<List<Position>>(
        key: cacheKey,
        fetchFunction: () => _tradingService.getPositions(
          exchange: exchange,
          marketType: marketType,
          symbol: symbol,
        ),
        customTtl: const Duration(minutes: 1),
      );

      state = state.copyWith(
        positions: positions,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Create a new position
  Future<void> createPosition(CreatePositionRequest request) async {
    try {
      state = state.copyWith(isCreatingPosition: true, error: null);

      final position = await _tradingService.createPosition(request);

      final updatedPositions = [...state.positions, position];
      state = state.copyWith(
        positions: updatedPositions,
        isCreatingPosition: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isCreatingPosition: false,
        error: e.toString(),
      );
    }
  }

  /// Load technical indicators
  Future<void> loadTechnicalIndicators(String symbol,
      {String exchange = 'kucoin'}) async {
    try {
      state = state.copyWith(isLoadingIndicators: true, indicatorError: null);

      final cacheKey = 'technical_indicators_${exchange}_$symbol';

      final analysis =
          await _cacheService.getWithCaching<TechnicalAnalysisResult>(
        key: cacheKey,
        fetchFunction: () =>
            _tradingService.getTechnicalAnalysis(exchange, symbol),
        customTtl: const Duration(minutes: 2),
      );

      final indicators = TechnicalIndicators(
        rsi: analysis.rsi.value,
        bollingerBands: BollingerBands(
          upper: analysis.bollingerBands.upper,
          middle: analysis.bollingerBands.middle,
          lower: analysis.bollingerBands.lower,
          bandwidth: analysis.bollingerBands.bandwidth,
          percentB: analysis.bollingerBands.percentB,
        ),
        macd: MACD(
          macd: analysis.macd.macd,
          signal: analysis.macd.signal,
          histogram: analysis.macd.histogram,
          trend: analysis.macd.signalType.toLowerCase(),
        ),
        timestamp: analysis.timestamp,
        symbol: symbol,
        timeframe: '1h',
      );

      state = state.copyWith(
        technicalIndicators: {
          ...state.technicalIndicators,
          symbol: indicators,
        },
        isLoadingIndicators: false,
        lastIndicatorUpdate: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingIndicators: false,
        indicatorError: e.toString(),
      );
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _indicatorRefreshTimer?.cancel();
    super.dispose();
  }

  void _subscribeToPositionUpdates() {
    // Implementation for real-time updates
  }

  void _startIndicatorRefresh() {
    // Implementation for indicator refresh
  }
}

/// Trading state
class TradingState {
  final List<Position> positions;
  final Map<String, TechnicalIndicators> technicalIndicators;
  final bool isLoading;
  final bool isCreatingPosition;
  final bool isLoadingIndicators;
  final String? error;
  final String? indicatorError;
  final DateTime? lastUpdated;
  final DateTime? lastIndicatorUpdate;

  const TradingState({
    required this.positions,
    required this.technicalIndicators,
    required this.isLoading,
    required this.isCreatingPosition,
    required this.isLoadingIndicators,
    this.error,
    this.indicatorError,
    this.lastUpdated,
    this.lastIndicatorUpdate,
  });

  const TradingState.initial()
      : positions = const [],
        technicalIndicators = const {},
        isLoading = false,
        isCreatingPosition = false,
        isLoadingIndicators = false,
        error = null,
        indicatorError = null,
        lastUpdated = null,
        lastIndicatorUpdate = null;

  TradingState copyWith({
    List<Position>? positions,
    Map<String, TechnicalIndicators>? technicalIndicators,
    bool? isLoading,
    bool? isCreatingPosition,
    bool? isLoadingIndicators,
    String? error,
    String? indicatorError,
    DateTime? lastUpdated,
    DateTime? lastIndicatorUpdate,
  }) {
    return TradingState(
      positions: positions ?? this.positions,
      technicalIndicators: technicalIndicators ?? this.technicalIndicators,
      isLoading: isLoading ?? this.isLoading,
      isCreatingPosition: isCreatingPosition ?? this.isCreatingPosition,
      isLoadingIndicators: isLoadingIndicators ?? this.isLoadingIndicators,
      error: error,
      indicatorError: indicatorError,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastIndicatorUpdate: lastIndicatorUpdate ?? this.lastIndicatorUpdate,
    );
  }

  bool get hasPositions => positions.isNotEmpty;
  bool get hasError => error != null;

  double get totalUnrealizedPnl =>
      positions.fold(0.0, (sum, pos) => sum + pos.unrealizedPnl);
}

/// Riverpod providers
final performanceCacheServiceProvider =
    Provider<PerformanceCacheService>((ref) {
  return PerformanceCacheService.instance;
});
