import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';
import '../models/comprehensive_analysis.dart';
import '../models/market_type.dart';
import '../services/comprehensive_analysis_service.dart';
import '../services/logging_service.dart';
import '../utils/retry_helper.dart';

import '../exceptions/trading_api_exceptions.dart';
import 'services_provider.dart';

part 'comprehensive_analysis_provider.g.dart';

/// Provider for Comprehensive Analysis Service
@riverpod
ComprehensiveAnalysisService comprehensiveAnalysisService(
    ComprehensiveAnalysisServiceRef ref) {
  final dio = ref.watch(dioProvider);
  return ComprehensiveAnalysisService(dio);
}

/// Provider for comprehensive market analysis
///
/// This is a family provider that takes a symbol parameter
/// to fetch analysis for different trading pairs
@riverpod
class ComprehensiveAnalysisNotifier extends _$ComprehensiveAnalysisNotifier {
  Timer? _autoRefreshTimer;

  @override
  FutureOr<ComprehensiveAnalysis> build(String symbol) async {
    // Limpiar timer cuando el provider se destruya
    ref.onDispose(() {
      _autoRefreshTimer?.cancel();
    });

    return _fetchAnalysis(symbol);
  }

  Future<ComprehensiveAnalysis> _fetchAnalysis(
    String symbol, {
    MarketType? marketType,
    bool enableLLM = true,
    bool enableSentiment = true,
  }) async {
    LoggingService.instance.info(
      'Fetching comprehensive analysis',
      tag: 'ComprehensiveAnalysisProvider',
      context: {
        'symbol': symbol,
        'market_type': marketType?.value,
        'enable_llm': enableLLM,
        'enable_sentiment': enableSentiment,
      },
    );

    try {
      final service = ref.read(comprehensiveAnalysisServiceProvider);

      final analysis = await RetryHelper.execute(
        () => service.getAnalysis(
          symbol: symbol,
          marketType: marketType,
          enableLLM: enableLLM,
          enableSentiment: enableSentiment,
        ),
        maxRetries: 2,
        shouldRetry: (error) =>
            error is NetworkException ||
            error is TimeoutException ||
            error is ServerException,
      );

      LoggingService.instance.info(
        'Successfully fetched comprehensive analysis',
        tag: 'ComprehensiveAnalysisProvider',
        context: {
          'symbol': symbol,
          'recommendation': analysis.recommendation,
          'risk_assessment': analysis.riskAssessment?.level,
        },
      );

      return analysis;
    } catch (e) {
      LoggingService.instance.error(
        'Failed to fetch comprehensive analysis',
        tag: 'ComprehensiveAnalysisProvider',
        context: {
          'symbol': symbol,
          'market_type': marketType?.value,
        },
        error: e,
      );
      rethrow;
    }
  }

  /// Refresh analysis for the current symbol
  Future<void> refresh({
    MarketType? marketType,
    bool enableLLM = true,
    bool enableSentiment = true,
  }) async {
    LoggingService.instance.info(
      'Refreshing comprehensive analysis',
      tag: 'ComprehensiveAnalysisProvider',
      context: {'symbol': symbol},
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _fetchAnalysis(
        symbol,
        marketType: marketType,
        enableLLM: enableLLM,
        enableSentiment: enableSentiment,
      ),
    );

    // Log the result
    state.when(
      data: (analysis) => LoggingService.instance.info(
        'Analysis refresh completed successfully',
        tag: 'ComprehensiveAnalysisProvider',
        context: {'symbol': symbol},
      ),
      error: (error, stackTrace) => LoggingService.instance.error(
        'Analysis refresh failed',
        tag: 'ComprehensiveAnalysisProvider',
        context: {'symbol': symbol},
        error: error,
        stackTrace: stackTrace,
      ),
      loading: () => {},
    );
  }

  /// Fetch analysis for a different symbol
  Future<void> fetchForSymbol(
    String newSymbol, {
    MarketType? marketType,
    bool enableLLM = true,
    bool enableSentiment = true,
  }) async {
    LoggingService.instance.info(
      'Fetching analysis for new symbol',
      tag: 'ComprehensiveAnalysisProvider',
      context: {
        'old_symbol': symbol,
        'new_symbol': newSymbol,
      },
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _fetchAnalysis(
        newSymbol,
        marketType: marketType,
        enableLLM: enableLLM,
        enableSentiment: enableSentiment,
      ),
    );

    // Log the result
    state.when(
      data: (analysis) => LoggingService.instance.info(
        'Symbol analysis fetch completed successfully',
        tag: 'ComprehensiveAnalysisProvider',
        context: {'symbol': newSymbol},
      ),
      error: (error, stackTrace) => LoggingService.instance.error(
        'Symbol analysis fetch failed',
        tag: 'ComprehensiveAnalysisProvider',
        context: {'symbol': newSymbol},
        error: error,
        stackTrace: stackTrace,
      ),
      loading: () => {},
    );
  }

  /// Inicia auto-refresh
  void startAutoRefresh({
    Duration interval = const Duration(seconds: 30),
    MarketType? marketType,
    bool enableLLM = true,
    bool enableSentiment = true,
  }) {
    stopAutoRefresh();
    _autoRefreshTimer = Timer.periodic(interval, (_) {
      refresh(
        marketType: marketType,
        enableLLM: enableLLM,
        enableSentiment: enableSentiment,
      );
    });
  }

  /// Detiene auto-refresh
  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }
}

/// Provider for current selected symbol (defaults to DOGE-USDT)
@riverpod
class SelectedSymbol extends _$SelectedSymbol {
  @override
  String build() {
    return 'DOGE-USDT';
  }

  void setSymbol(String symbol) {
    state = symbol;
  }
}

/// Provider for available trading pairs
@riverpod
class AvailableSymbols extends _$AvailableSymbols {
  @override
  List<String> build() {
    return [
      'DOGE-USDT',
      'BTC-USDT',
      'ETH-USDT',
      'SOL-USDT',
      'XRP-USDT',
      'ADA-USDT',
      'MATIC-USDT',
      'DOT-USDT',
      'AVAX-USDT',
      'LINK-USDT',
    ];
  }

  void addSymbol(String symbol) {
    if (!state.contains(symbol)) {
      state = [...state, symbol];
    }
  }

  void removeSymbol(String symbol) {
    state = state.where((s) => s != symbol).toList();
  }
}
