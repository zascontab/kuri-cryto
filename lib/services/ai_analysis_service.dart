import 'dart:developer' as developer;
import '../models/comprehensive_analysis.dart';
import '../models/llm_analysis.dart';
import '../models/sentiment_analysis.dart';
import '../models/ai_costs.dart';
import '../models/ai_status.dart';
import 'matp_api_client.dart';

/// AI Analysis Service for comprehensive market analysis
///
/// This service provides AI-powered market analysis capabilities including:
/// - Complete market analysis with LLM insights
/// - LLM analysis with reasoning and confidence scores
/// - Sentiment analysis from multiple data sources
/// - AI cost monitoring and budget constraint warnings
///
/// Features:
/// - Comprehensive market analysis via MATP AI endpoints
/// - LLM analysis with detailed explanations
/// - Multi-source sentiment analysis
/// - Cost tracking and budget warnings
/// - Strategy performance analysis
///
/// Example usage:
/// ```dart
/// final aiService = AIAnalysisService(matpClient);
///
/// // Get complete analysis
/// final analysis = await aiService.getCompleteAnalysis(
///   AnalysisRequest(symbol: 'BTC-USDT', exchange: 'kucoin')
/// );
///
/// // Get LLM analysis
/// final llmAnalysis = await aiService.getLLMAnalysis(
///   LLMAnalysisRequest(symbol: 'BTC-USDT', provider: 'gemini')
/// );
///
/// // Get sentiment analysis
/// final sentiment = await aiService.getSentimentAnalysis('BTC-USDT', 24);
/// ```
class AIAnalysisService {
  final MATPApiClient _matpClient;

  AIAnalysisService(this._matpClient);

  // ============================================================================
  // COMPREHENSIVE AI ANALYSIS
  // ============================================================================

  /// Get complete AI-powered market analysis
  ///
  /// [request]: Analysis request with symbol, exchange, and optional parameters
  ///
  /// Returns: [ComprehensiveAnalysis] with complete market analysis including
  /// technical indicators, scenarios, recommendations, and AI insights
  Future<ComprehensiveAnalysis> getCompleteAnalysis(
    AnalysisRequest request,
  ) async {
    try {
      developer.log(
        'Requesting complete analysis for ${request.symbol}',
        name: 'AIAnalysisService',
      );

      final response = await _matpClient.post(
        '/api/v1/ai/analysis/complete',
        data: request.toJson(),
      );

      return ComprehensiveAnalysis.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      developer.log(
        'Failed to get complete analysis for ${request.symbol} - $e',
        name: 'AIAnalysisService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get formatted analysis for display
  ///
  /// [request]: Analysis request
  ///
  /// Returns: [FormattedAnalysis] with formatted text for UI display
  Future<FormattedAnalysis> getFormattedAnalysis(
    AnalysisRequest request,
  ) async {
    try {
      developer.log(
        'Requesting formatted analysis for ${request.symbol}',
        name: 'AIAnalysisService',
      );

      final response = await _matpClient.post(
        '/api/v1/ai/analysis/formatted',
        data: request.toJson(),
      );

      return FormattedAnalysis.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      developer.log(
        'Failed to get formatted analysis for ${request.symbol} - $e',
        name: 'AIAnalysisService',
        error: e,
      );
      rethrow;
    }
  }

  // ============================================================================
  // LLM ANALYSIS
  // ============================================================================

  /// Get LLM analysis with reasoning and confidence scores
  ///
  /// [request]: LLM analysis request with symbol and provider preferences
  ///
  /// Returns: [LLMAnalysis] with detailed explanations and reasoning
  Future<LLMAnalysis> getLLMAnalysis(LLMAnalysisRequest request) async {
    try {
      developer.log(
        'Requesting LLM analysis for ${request.symbol} with ${request.provider}',
        name: 'AIAnalysisService',
      );

      final response = await _matpClient.post(
        '/api/v1/ai/llm/analyze',
        data: request.toJson(),
      );

      return LLMAnalysis.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to get LLM analysis for ${request.symbol} - $e',
        name: 'AIAnalysisService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get LLM explanation for a specific trading signal
  ///
  /// [symbol]: Trading pair symbol
  /// [action]: Trading action ('BUY', 'SELL', 'WAIT')
  /// [confidence]: Confidence level
  /// [provider]: Optional LLM provider preference
  ///
  /// Returns: [LLMAnalysis] with explanation for the signal
  Future<LLMAnalysis> explainTradingSignal(
    String symbol,
    String action,
    double confidence, {
    String? provider,
  }) async {
    try {
      final request = LLMAnalysisRequest(
        symbol: symbol,
        action: action,
        confidence: confidence,
        provider: provider,
      );

      final response = await _matpClient.post(
        '/api/v1/ai/llm/explain-signal',
        data: request.toJson(),
      );

      return LLMAnalysis.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to explain trading signal for $symbol - $e',
        name: 'AIAnalysisService',
        error: e,
      );
      rethrow;
    }
  }

  // ============================================================================
  // SENTIMENT ANALYSIS
  // ============================================================================

  /// Get sentiment analysis from multiple data sources
  ///
  /// [symbol]: Trading pair symbol
  /// [hours]: Time window in hours for sentiment analysis
  /// [sources]: Optional list of sources to analyze
  ///
  /// Returns: [SentimentAnalysis] with market sentiment data
  Future<SentimentAnalysis> getSentimentAnalysis(
    String symbol,
    int hours, {
    List<String>? sources,
  }) async {
    try {
      developer.log(
        'Requesting sentiment analysis for $symbol (${hours}h)',
        name: 'AIAnalysisService',
      );

      final data = {
        'symbol': symbol,
        'hours': hours,
        if (sources != null) 'sources': sources,
      };

      final response = await _matpClient.post(
        '/api/v1/ai/sentiment/analyze',
        data: data,
      );

      return SentimentAnalysis.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      developer.log(
        'Failed to get sentiment analysis for $symbol - $e',
        name: 'AIAnalysisService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get sentiment trend over time
  ///
  /// [symbol]: Trading pair symbol
  /// [days]: Number of days to analyze
  ///
  /// Returns: List of sentiment data points over time
  Future<List<SentimentDataPoint>> getSentimentTrend(
    String symbol,
    int days,
  ) async {
    try {
      final response = await _matpClient.get(
        '/api/v1/ai/sentiment/trend',
        queryParameters: {
          'symbol': symbol,
          'days': days,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final trend = data['trend'] as List;

      return trend
          .map((point) =>
              SentimentDataPoint.fromJson(point as Map<String, dynamic>))
          .toList();
    } catch (e) {
      developer.log(
        'Failed to get sentiment trend for $symbol - $e',
        name: 'AIAnalysisService',
        error: e,
      );
      rethrow;
    }
  }

  // ============================================================================
  // AI COST MONITORING
  // ============================================================================

  /// Get AI costs and usage statistics
  ///
  /// [period]: Time period ('day', 'week', 'month')
  /// [provider]: Optional provider filter
  ///
  /// Returns: [AICosts] with cost breakdown and usage statistics
  Future<AICosts> getAICosts(String period, {String? provider}) async {
    try {
      final queryParams = {
        'period': period,
        if (provider != null) 'provider': provider,
      };

      final response = await _matpClient.get(
        '/api/v1/ai/costs',
        queryParameters: queryParams,
      );

      return AICosts.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to get AI costs for period $period - $e',
        name: 'AIAnalysisService',
        error: e,
      );
      rethrow;
    }
  }

  /// Check if operation would exceed cost limits
  ///
  /// [operation]: Type of operation ('analysis', 'llm', 'sentiment')
  /// [estimatedCost]: Estimated cost of the operation
  ///
  /// Returns: [CostCheckResult] with approval status and warnings
  Future<CostCheckResult> checkCostLimits(
    String operation,
    double estimatedCost,
  ) async {
    try {
      final response = await _matpClient.post(
        '/api/v1/ai/costs/check',
        data: {
          'operation': operation,
          'estimated_cost': estimatedCost,
        },
      );

      return CostCheckResult.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to check cost limits for $operation - $e',
        name: 'AIAnalysisService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get AI budget status and remaining limits
  ///
  /// Returns: [BudgetStatus] with current budget information
  Future<BudgetStatus> getBudgetStatus() async {
    try {
      final response = await _matpClient.get('/api/v1/ai/budget/status');

      return BudgetStatus.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to get budget status - $e',
        name: 'AIAnalysisService',
        error: e,
      );
      rethrow;
    }
  }

  // ============================================================================
  // STRATEGY PERFORMANCE
  // ============================================================================

  /// Get AI strategy performance analysis
  ///
  /// [timeframe]: Analysis timeframe ('1d', '7d', '30d')
  /// [symbol]: Optional symbol filter
  ///
  /// Returns: [StrategyPerformance] with performance metrics
  Future<StrategyPerformance> getStrategyPerformance(
    String timeframe, {
    String? symbol,
  }) async {
    try {
      final queryParams = {
        'timeframe': timeframe,
        if (symbol != null) 'symbol': symbol,
      };

      final response = await _matpClient.get(
        '/api/v1/ai/strategy/performance',
        queryParameters: queryParams,
      );

      return StrategyPerformance.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      developer.log(
        'Failed to get strategy performance for $timeframe - $e',
        name: 'AIAnalysisService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get AI model performance metrics
  ///
  /// Returns: [ModelPerformance] with accuracy and reliability metrics
  Future<ModelPerformance> getModelPerformance() async {
    try {
      final response = await _matpClient.get('/api/v1/ai/model/performance');

      return ModelPerformance.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to get model performance - $e',
        name: 'AIAnalysisService',
        error: e,
      );
      rethrow;
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get AI system status
  ///
  /// Returns: [AIStatus] with current system status
  Future<AIStatus> getAIStatus() async {
    try {
      final response = await _matpClient.get('/api/v1/ai-bot/status');

      return AIStatus.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to get AI status - $e',
        name: 'AIAnalysisService',
        error: e,
      );
      rethrow;
    }
  }

  /// Validate analysis request before processing
  ///
  /// [request]: Analysis request to validate
  ///
  /// Returns: [ValidationResult] with validation status
  Future<ValidationResult> validateAnalysisRequest(
    AnalysisRequest request,
  ) async {
    try {
      final response = await _matpClient.post(
        '/api/v1/ai/validate',
        data: request.toJson(),
      );

      return ValidationResult.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to validate analysis request - $e',
        name: 'AIAnalysisService',
        error: e,
      );
      rethrow;
    }
  }
}

// ============================================================================
// REQUEST/RESPONSE MODELS
// ============================================================================

/// Request model for comprehensive analysis
class AnalysisRequest {
  final String symbol;
  final String exchange;
  final List<String>? timeframes;
  final bool includeLLM;
  final bool includeSentiment;
  final String? provider;

  AnalysisRequest({
    required this.symbol,
    required this.exchange,
    this.timeframes,
    this.includeLLM = true,
    this.includeSentiment = true,
    this.provider,
  });

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'exchange': exchange,
      if (timeframes != null) 'timeframes': timeframes,
      'include_llm': includeLLM,
      'include_sentiment': includeSentiment,
      if (provider != null) 'provider': provider,
    };
  }
}

/// Request model for LLM analysis
class LLMAnalysisRequest {
  final String symbol;
  final String? action;
  final double? confidence;
  final String? provider;
  final String? context;

  LLMAnalysisRequest({
    required this.symbol,
    this.action,
    this.confidence,
    this.provider,
    this.context,
  });

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      if (action != null) 'action': action,
      if (confidence != null) 'confidence': confidence,
      if (provider != null) 'provider': provider,
      if (context != null) 'context': context,
    };
  }
}

/// Formatted analysis for UI display
class FormattedAnalysis {
  final String systemStatus;
  final String marketAnalysis;
  final String positionAnalysis;
  final String aiAnalysis;
  final String riskAssessment;
  final String recommendations;

  FormattedAnalysis({
    required this.systemStatus,
    required this.marketAnalysis,
    required this.positionAnalysis,
    required this.aiAnalysis,
    required this.riskAssessment,
    required this.recommendations,
  });

  factory FormattedAnalysis.fromJson(Map<String, dynamic> json) {
    return FormattedAnalysis(
      systemStatus: json['system_status'] as String? ?? '',
      marketAnalysis: json['market_analysis'] as String? ?? '',
      positionAnalysis: json['position_analysis'] as String? ?? '',
      aiAnalysis: json['ai_analysis'] as String? ?? '',
      riskAssessment: json['risk_assessment'] as String? ?? '',
      recommendations: json['recommendations'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'system_status': systemStatus,
      'market_analysis': marketAnalysis,
      'position_analysis': positionAnalysis,
      'ai_analysis': aiAnalysis,
      'risk_assessment': riskAssessment,
      'recommendations': recommendations,
    };
  }
}

/// Sentiment data point for trend analysis
class SentimentDataPoint {
  final DateTime timestamp;
  final double sentiment;
  final String trend;
  final double confidence;

  SentimentDataPoint({
    required this.timestamp,
    required this.sentiment,
    required this.trend,
    required this.confidence,
  });

  factory SentimentDataPoint.fromJson(Map<String, dynamic> json) {
    return SentimentDataPoint(
      timestamp: DateTime.parse(json['timestamp'] as String),
      sentiment: (json['sentiment'] as num).toDouble(),
      trend: json['trend'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'sentiment': sentiment,
      'trend': trend,
      'confidence': confidence,
    };
  }
}

/// Cost check result
class CostCheckResult {
  final bool approved;
  final String? warning;
  final double remainingBudget;
  final double estimatedTotal;

  CostCheckResult({
    required this.approved,
    this.warning,
    required this.remainingBudget,
    required this.estimatedTotal,
  });

  factory CostCheckResult.fromJson(Map<String, dynamic> json) {
    return CostCheckResult(
      approved: json['approved'] as bool? ?? false,
      warning: json['warning'] as String?,
      remainingBudget: (json['remaining_budget'] as num?)?.toDouble() ?? 0.0,
      estimatedTotal: (json['estimated_total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'approved': approved,
      if (warning != null) 'warning': warning,
      'remaining_budget': remainingBudget,
      'estimated_total': estimatedTotal,
    };
  }
}

/// Budget status
class BudgetStatus {
  final double totalBudget;
  final double usedBudget;
  final double remainingBudget;
  final double dailyLimit;
  final double dailyUsed;
  final List<String> warnings;

  BudgetStatus({
    required this.totalBudget,
    required this.usedBudget,
    required this.remainingBudget,
    required this.dailyLimit,
    required this.dailyUsed,
    required this.warnings,
  });

  factory BudgetStatus.fromJson(Map<String, dynamic> json) {
    return BudgetStatus(
      totalBudget: (json['total_budget'] as num?)?.toDouble() ?? 0.0,
      usedBudget: (json['used_budget'] as num?)?.toDouble() ?? 0.0,
      remainingBudget: (json['remaining_budget'] as num?)?.toDouble() ?? 0.0,
      dailyLimit: (json['daily_limit'] as num?)?.toDouble() ?? 0.0,
      dailyUsed: (json['daily_used'] as num?)?.toDouble() ?? 0.0,
      warnings: (json['warnings'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_budget': totalBudget,
      'used_budget': usedBudget,
      'remaining_budget': remainingBudget,
      'daily_limit': dailyLimit,
      'daily_used': dailyUsed,
      'warnings': warnings,
    };
  }

  bool get isNearLimit => remainingBudget < (totalBudget * 0.1);
  bool get isDailyNearLimit => (dailyLimit - dailyUsed) < (dailyLimit * 0.1);
}

/// Strategy performance metrics
class StrategyPerformance {
  final double accuracy;
  final double profitability;
  final int totalSignals;
  final int successfulSignals;
  final double averageReturn;
  final double sharpeRatio;

  StrategyPerformance({
    required this.accuracy,
    required this.profitability,
    required this.totalSignals,
    required this.successfulSignals,
    required this.averageReturn,
    required this.sharpeRatio,
  });

  factory StrategyPerformance.fromJson(Map<String, dynamic> json) {
    return StrategyPerformance(
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      profitability: (json['profitability'] as num?)?.toDouble() ?? 0.0,
      totalSignals: json['total_signals'] as int? ?? 0,
      successfulSignals: json['successful_signals'] as int? ?? 0,
      averageReturn: (json['average_return'] as num?)?.toDouble() ?? 0.0,
      sharpeRatio: (json['sharpe_ratio'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accuracy': accuracy,
      'profitability': profitability,
      'total_signals': totalSignals,
      'successful_signals': successfulSignals,
      'average_return': averageReturn,
      'sharpe_ratio': sharpeRatio,
    };
  }

  double get successRate =>
      totalSignals > 0 ? successfulSignals / totalSignals : 0.0;
}

/// Model performance metrics
class ModelPerformance {
  final Map<String, double> providerAccuracy;
  final Map<String, int> providerUsage;
  final String bestProvider;
  final double overallAccuracy;

  ModelPerformance({
    required this.providerAccuracy,
    required this.providerUsage,
    required this.bestProvider,
    required this.overallAccuracy,
  });

  factory ModelPerformance.fromJson(Map<String, dynamic> json) {
    return ModelPerformance(
      providerAccuracy: (json['provider_accuracy'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
          {},
      providerUsage: (json['provider_usage'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      bestProvider: json['best_provider'] as String? ?? '',
      overallAccuracy: (json['overall_accuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider_accuracy': providerAccuracy,
      'provider_usage': providerUsage,
      'best_provider': bestProvider,
      'overall_accuracy': overallAccuracy,
    };
  }
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  factory ValidationResult.fromJson(Map<String, dynamic> json) {
    return ValidationResult(
      isValid: json['is_valid'] as bool? ?? false,
      errors: (json['errors'] as List?)?.cast<String>() ?? [],
      warnings: (json['warnings'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_valid': isValid,
      'errors': errors,
      'warnings': warnings,
    };
  }
}
