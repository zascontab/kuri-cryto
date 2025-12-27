import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/comprehensive_analysis.dart';
import '../models/llm_analysis.dart';
import '../models/sentiment_analysis.dart';
import '../models/ai_costs.dart';
import '../services/ai_analysis_service.dart';
import '../services/performance_cache_service.dart';
import '../services/logging_service.dart';

part 'ai_analysis_provider.g.dart';

/// AI Analysis Provider for AI-powered market analysis
class AIAnalysisProvider extends StateNotifier<AIAnalysisState> {
  final AIAnalysisService _aiService;
  final PerformanceCacheService _cacheService;

  Timer? _costMonitoringTimer;

  AIAnalysisProvider(this._aiService, this._cacheService)
      : super(const AIAnalysisState.initial()) {
    _initializeProvider();
  }

  void _initializeProvider() {
    _startCostMonitoring();

    LoggingService.instance.info(
      'AI analysis provider initialized',
      tag: 'AIAnalysisProvider',
    );
  }

  /// Request complete analysis for a symbol
  Future<void> requestCompleteAnalysis(String symbol,
      {String exchange = 'kucoin'}) async {
    try {
      state = state.copyWith(isLoadingAnalysis: true, analysisError: null);

      final request = AnalysisRequest(
        symbol: symbol,
        exchange: exchange,
        includeLLM: true,
        includeSentiment: true,
      );

      final cacheKey = 'complete_analysis_${exchange}_$symbol';

      final analysis =
          await _cacheService.getWithCaching<ComprehensiveAnalysis>(
        key: cacheKey,
        fetchFunction: () => _aiService.getCompleteAnalysis(request),
        customTtl:
            const Duration(minutes: 5), // AI analysis can be cached longer
      );

      state = state.copyWith(
        currentAnalysis: analysis,
        isLoadingAnalysis: false,
        lastAnalysisUpdate: DateTime.now(),
      );

      LoggingService.instance.info(
        'Complete analysis loaded for $symbol',
        tag: 'AIAnalysisProvider',
        context: {
          'symbol': symbol,
          'exchange': exchange,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingAnalysis: false,
        analysisError: e.toString(),
      );

      LoggingService.instance.error(
        'Failed to load complete analysis: $e',
        tag: 'AIAnalysisProvider',
        error: e,
      );
    }
  }

  /// Request sentiment analysis for a symbol
  Future<void> requestSentimentAnalysis(String symbol, {int hours = 24}) async {
    try {
      state = state.copyWith(isLoadingSentiment: true, sentimentError: null);

      final cacheKey = 'sentiment_analysis_${symbol}_${hours}h';

      final sentiment = await _cacheService.getWithCaching<SentimentAnalysis>(
        key: cacheKey,
        fetchFunction: () => _aiService.getSentimentAnalysis(symbol, hours),
        customTtl:
            const Duration(minutes: 10), // Sentiment updates less frequently
      );

      state = state.copyWith(
        sentimentAnalysis: {
          ...state.sentimentAnalysis,
          symbol: sentiment,
        },
        isLoadingSentiment: false,
        lastSentimentUpdate: DateTime.now(),
      );

      LoggingService.instance.info(
        'Sentiment analysis loaded for $symbol',
        tag: 'AIAnalysisProvider',
        context: {
          'symbol': symbol,
          'hours': hours,
          'sentiment_score': sentiment.overall,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingSentiment: false,
        sentimentError: e.toString(),
      );

      LoggingService.instance.error(
        'Failed to load sentiment analysis: $e',
        tag: 'AIAnalysisProvider',
        error: e,
      );
    }
  }

  /// Request LLM analysis
  Future<void> requestLLMAnalysis(LLMAnalysisRequest request) async {
    try {
      state = state.copyWith(isLoadingLLM: true, llmError: null);

      // Check cost limits before proceeding
      final costCheck =
          await _aiService.checkCostLimits('llm', 0.1); // Estimated cost
      if (!costCheck.approved) {
        state = state.copyWith(
          isLoadingLLM: false,
          llmError: 'Cost limit exceeded: ${costCheck.warning}',
        );
        return;
      }

      final cacheKey =
          'llm_analysis_${request.symbol}_${request.provider ?? 'default'}';

      final llmAnalysis = await _cacheService.getWithCaching<LLMAnalysis>(
        key: cacheKey,
        fetchFunction: () => _aiService.getLLMAnalysis(request),
        customTtl:
            const Duration(minutes: 15), // LLM analysis can be cached longer
      );

      state = state.copyWith(
        llmAnalysis: {
          ...state.llmAnalysis,
          request.symbol: llmAnalysis,
        },
        isLoadingLLM: false,
        lastLLMUpdate: DateTime.now(),
      );

      LoggingService.instance.info(
        'LLM analysis loaded for ${request.symbol}',
        tag: 'AIAnalysisProvider',
        context: {
          'symbol': request.symbol,
          'provider': request.provider,
          'risk_assessment': llmAnalysis.riskAssessment,
          'confidence': llmAnalysis.confidence,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingLLM: false,
        llmError: e.toString(),
      );

      LoggingService.instance.error(
        'Failed to load LLM analysis: $e',
        tag: 'AIAnalysisProvider',
        error: e,
      );
    }
  }

  /// Load AI costs and budget status
  Future<void> loadAICosts() async {
    try {
      state = state.copyWith(isLoadingCosts: true);

      final costs = await _aiService.getAICosts('day');
      final budgetStatus = await _aiService.getBudgetStatus();

      state = state.copyWith(
        aiCosts: costs,
        budgetStatus: budgetStatus,
        isLoadingCosts: false,
        lastCostUpdate: DateTime.now(),
      );

      LoggingService.instance.info(
        'AI costs loaded',
        tag: 'AIAnalysisProvider',
        context: {
          'total_cost': costs.today.total,
          'remaining_budget': budgetStatus.remainingBudget,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingCosts: false,
        costError: e.toString(),
      );

      LoggingService.instance.error(
        'Failed to load AI costs: $e',
        tag: 'AIAnalysisProvider',
        error: e,
      );
    }
  }

  /// Monitor cost limits
  void _startCostMonitoring() {
    _costMonitoringTimer?.cancel();

    _costMonitoringTimer = Timer.periodic(
      const Duration(minutes: 10), // Check costs every 10 minutes
      (_) => loadAICosts(),
    );
  }

  /// Check if operation would exceed cost limits
  Future<bool> checkCostLimits(String operation, double estimatedCost) async {
    try {
      final result = await _aiService.checkCostLimits(operation, estimatedCost);

      if (!result.approved && result.warning != null) {
        state = state.copyWith(costWarning: result.warning);
      }

      return result.approved;
    } catch (e) {
      LoggingService.instance.error(
        'Failed to check cost limits: $e',
        tag: 'AIAnalysisProvider',
        error: e,
      );
      return false;
    }
  }

  /// Load strategy performance
  Future<void> loadStrategyPerformance(String timeframe,
      {String? symbol}) async {
    try {
      final cacheKey = 'strategy_performance_${timeframe}_${symbol ?? 'all'}';

      final performance =
          await _cacheService.getWithCaching<StrategyPerformance>(
        key: cacheKey,
        fetchFunction: () =>
            _aiService.getStrategyPerformance(timeframe, symbol: symbol),
        customTtl: const Duration(
            minutes: 30), // Performance data updates less frequently
      );

      state = state.copyWith(
        strategyPerformance: performance,
        lastPerformanceUpdate: DateTime.now(),
      );

      LoggingService.instance.info(
        'Strategy performance loaded',
        tag: 'AIAnalysisProvider',
        context: {
          'timeframe': timeframe,
          'symbol': symbol,
          'accuracy': performance.accuracy,
        },
      );
    } catch (e) {
      LoggingService.instance.error(
        'Failed to load strategy performance: $e',
        tag: 'AIAnalysisProvider',
        error: e,
      );
    }
  }

  @override
  void dispose() {
    _costMonitoringTimer?.cancel();
    super.dispose();
  }
}

/// AI Analysis state
class AIAnalysisState {
  final ComprehensiveAnalysis? currentAnalysis;
  final Map<String, SentimentAnalysis> sentimentAnalysis;
  final Map<String, LLMAnalysis> llmAnalysis;
  final AICosts? aiCosts;
  final BudgetStatus? budgetStatus;
  final StrategyPerformance? strategyPerformance;
  final bool isLoadingAnalysis;
  final bool isLoadingSentiment;
  final bool isLoadingLLM;
  final bool isLoadingCosts;
  final String? analysisError;
  final String? sentimentError;
  final String? llmError;
  final String? costError;
  final String? costWarning;
  final DateTime? lastAnalysisUpdate;
  final DateTime? lastSentimentUpdate;
  final DateTime? lastLLMUpdate;
  final DateTime? lastCostUpdate;
  final DateTime? lastPerformanceUpdate;

  const AIAnalysisState({
    this.currentAnalysis,
    required this.sentimentAnalysis,
    required this.llmAnalysis,
    this.aiCosts,
    this.budgetStatus,
    this.strategyPerformance,
    required this.isLoadingAnalysis,
    required this.isLoadingSentiment,
    required this.isLoadingLLM,
    required this.isLoadingCosts,
    this.analysisError,
    this.sentimentError,
    this.llmError,
    this.costError,
    this.costWarning,
    this.lastAnalysisUpdate,
    this.lastSentimentUpdate,
    this.lastLLMUpdate,
    this.lastCostUpdate,
    this.lastPerformanceUpdate,
  });

  const AIAnalysisState.initial()
      : currentAnalysis = null,
        sentimentAnalysis = const {},
        llmAnalysis = const {},
        aiCosts = null,
        budgetStatus = null,
        strategyPerformance = null,
        isLoadingAnalysis = false,
        isLoadingSentiment = false,
        isLoadingLLM = false,
        isLoadingCosts = false,
        analysisError = null,
        sentimentError = null,
        llmError = null,
        costError = null,
        costWarning = null,
        lastAnalysisUpdate = null,
        lastSentimentUpdate = null,
        lastLLMUpdate = null,
        lastCostUpdate = null,
        lastPerformanceUpdate = null;

  AIAnalysisState copyWith({
    ComprehensiveAnalysis? currentAnalysis,
    Map<String, SentimentAnalysis>? sentimentAnalysis,
    Map<String, LLMAnalysis>? llmAnalysis,
    AICosts? aiCosts,
    BudgetStatus? budgetStatus,
    StrategyPerformance? strategyPerformance,
    bool? isLoadingAnalysis,
    bool? isLoadingSentiment,
    bool? isLoadingLLM,
    bool? isLoadingCosts,
    String? analysisError,
    String? sentimentError,
    String? llmError,
    String? costError,
    String? costWarning,
    DateTime? lastAnalysisUpdate,
    DateTime? lastSentimentUpdate,
    DateTime? lastLLMUpdate,
    DateTime? lastCostUpdate,
    DateTime? lastPerformanceUpdate,
  }) {
    return AIAnalysisState(
      currentAnalysis: currentAnalysis ?? this.currentAnalysis,
      sentimentAnalysis: sentimentAnalysis ?? this.sentimentAnalysis,
      llmAnalysis: llmAnalysis ?? this.llmAnalysis,
      aiCosts: aiCosts ?? this.aiCosts,
      budgetStatus: budgetStatus ?? this.budgetStatus,
      strategyPerformance: strategyPerformance ?? this.strategyPerformance,
      isLoadingAnalysis: isLoadingAnalysis ?? this.isLoadingAnalysis,
      isLoadingSentiment: isLoadingSentiment ?? this.isLoadingSentiment,
      isLoadingLLM: isLoadingLLM ?? this.isLoadingLLM,
      isLoadingCosts: isLoadingCosts ?? this.isLoadingCosts,
      analysisError: analysisError,
      sentimentError: sentimentError,
      llmError: llmError,
      costError: costError,
      costWarning: costWarning,
      lastAnalysisUpdate: lastAnalysisUpdate ?? this.lastAnalysisUpdate,
      lastSentimentUpdate: lastSentimentUpdate ?? this.lastSentimentUpdate,
      lastLLMUpdate: lastLLMUpdate ?? this.lastLLMUpdate,
      lastCostUpdate: lastCostUpdate ?? this.lastCostUpdate,
      lastPerformanceUpdate:
          lastPerformanceUpdate ?? this.lastPerformanceUpdate,
    );
  }

  bool get hasAnalysis => currentAnalysis != null;
  bool get hasErrors =>
      analysisError != null ||
      sentimentError != null ||
      llmError != null ||
      costError != null;
  bool get hasCostWarning => costWarning != null;
  bool get isNearBudgetLimit => budgetStatus?.isNearLimit ?? false;
}

/// Riverpod providers
@riverpod
class AIAnalysis extends _$AIAnalysis {
  @override
  AIAnalysisState build() {
    return const AIAnalysisState.initial();
  }

  Future<void> requestCompleteAnalysis(String symbol,
      {String exchange = 'kucoin'}) async {
    // Implementation would use the actual service
  }

  Future<void> requestSentimentAnalysis(String symbol, {int hours = 24}) async {
    // Implementation would use the actual service
  }

  Future<void> requestLLMAnalysis(LLMAnalysisRequest request) async {
    // Implementation would use the actual service
  }
}
