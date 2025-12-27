import '../technical_indicators.dart';
import '../enhanced_llm_analysis.dart';
import '../enhanced_bot_state.dart';

/// Backward compatibility adapter for enhanced data models
///
/// This adapter ensures that existing models can work with new enhanced models
/// and provides migration utilities for data transformation.
class BackwardCompatibilityAdapter {
  /// Convert existing LLMAnalysis to EnhancedLLMAnalysis
  static EnhancedLLMAnalysis convertLLMAnalysis(dynamic existingAnalysis) {
    if (existingAnalysis is Map<String, dynamic>) {
      return EnhancedLLMAnalysis(
        action: _extractAction(existingAnalysis),
        confidence: _extractConfidence(existingAnalysis),
        reasoning: _extractReasoning(existingAnalysis),
        entryPrice: _extractPrice(existingAnalysis, 'entryPrice'),
        stopLoss: _extractPrice(existingAnalysis, 'stopLoss'),
        takeProfit: _extractPrice(existingAnalysis, 'takeProfit'),
        provider: existingAnalysis['provider'] ?? '',
        cost: _extractPrice(existingAnalysis, 'cost'),
      );
    }

    // If it's already an enhanced analysis, return as is
    if (existingAnalysis is EnhancedLLMAnalysis) {
      return existingAnalysis;
    }

    // Default fallback
    return const EnhancedLLMAnalysis(
      action: 'HOLD',
      confidence: 0.5,
      reasoning: ['Legacy analysis converted'],
      entryPrice: 0.0,
      stopLoss: 0.0,
      takeProfit: 0.0,
      provider: 'legacy',
      cost: 0.0,
    );
  }

  /// Convert existing BotConfig to EnhancedBotConfig
  static EnhancedBotConfig convertBotConfig(dynamic existingConfig) {
    if (existingConfig is Map<String, dynamic>) {
      return EnhancedBotConfig(
        dryRun: existingConfig['dryRun'] ?? true,
        autoExecute: existingConfig['autoExecute'] ?? false,
        maxPositions: existingConfig['maxPositions'] ?? 5,
        positionSizeUsd: existingConfig['positionSizeUsd']?.toDouble() ?? 100.0,
        stopLossPercent: existingConfig['stopLossPercent']?.toDouble() ?? 2.0,
        takeProfitPercent:
            existingConfig['takeProfitPercent']?.toDouble() ?? 4.0,
        symbols: List<String>.from(existingConfig['symbols'] ?? []),
        timeframes: List<String>.from(existingConfig['timeframes'] ?? ['1h']),
        strategies: List<String>.from(existingConfig['strategies'] ?? []),
        riskManagement: RiskManagementConfig.fromJson(
            existingConfig['riskManagement'] ?? {}),
      );
    }

    if (existingConfig is EnhancedBotConfig) {
      return existingConfig;
    }

    // Default fallback
    return const EnhancedBotConfig(
      dryRun: true,
      autoExecute: false,
      maxPositions: 5,
      positionSizeUsd: 100.0,
      stopLossPercent: 2.0,
      takeProfitPercent: 4.0,
      symbols: [],
      timeframes: ['1h'],
      strategies: [],
      riskManagement: RiskManagementConfig(
        maxDailyLoss: 100.0,
        maxPositionSize: 1000.0,
        maxDrawdown: 10.0,
        useStopLoss: true,
        useTakeProfit: true,
      ),
    );
  }

  /// Convert existing BotStatus to EnhancedBotStatus
  static EnhancedBotStatus convertBotStatus(dynamic existingStatus) {
    if (existingStatus is Map<String, dynamic>) {
      return EnhancedBotStatus(
        state: existingStatus['state'] ?? 'stopped',
        autonomousMode: existingStatus['autonomousMode'] ?? false,
        positions: PositionSummary.fromJson(existingStatus['positions'] ?? {}),
        performance:
            PerformanceSummary.fromJson(existingStatus['performance'] ?? {}),
        risk: RiskSummary.fromJson(existingStatus['risk'] ?? {}),
        lastAction: existingStatus['lastAction'] != null
            ? BotAction.fromJson(existingStatus['lastAction'])
            : null,
      );
    }

    if (existingStatus is EnhancedBotStatus) {
      return existingStatus;
    }

    // Default fallback
    return const EnhancedBotStatus(
      state: 'stopped',
      autonomousMode: false,
      positions: PositionSummary(
        total: 0,
        open: 0,
        totalValue: 0.0,
        unrealizedPnl: 0.0,
      ),
      performance: PerformanceSummary(
        totalPnl: 0.0,
        winRate: 0.0,
        totalTrades: 0,
        sharpeRatio: 0.0,
      ),
      risk: RiskSummary(
        currentRisk: 0.0,
        maxRisk: 100.0,
        riskLevel: 'low',
      ),
    );
  }

  /// Convert existing SentimentAnalysis to EnhancedSentimentAnalysis
  static EnhancedSentimentAnalysis convertSentimentAnalysis(
      dynamic existingAnalysis) {
    if (existingAnalysis is Map<String, dynamic>) {
      return EnhancedSentimentAnalysis(
        symbol: existingAnalysis['symbol'] ?? '',
        sentiment: SentimentData.fromJson(existingAnalysis['sentiment'] ?? {}),
        interpretation: SentimentInterpretation.fromJson(
            existingAnalysis['interpretation'] ?? {}),
        dataCounts: Map<String, int>.from(existingAnalysis['dataCounts'] ?? {}),
      );
    }

    if (existingAnalysis is EnhancedSentimentAnalysis) {
      return existingAnalysis;
    }

    // Default fallback
    return const EnhancedSentimentAnalysis(
      symbol: '',
      sentiment: SentimentData(
        score: 0.0,
        label: 'neutral',
        breakdown: {},
      ),
      interpretation: SentimentInterpretation(
        summary: 'Legacy sentiment analysis',
        impact: 'neutral',
        keyFactors: [],
      ),
      dataCounts: {},
    );
  }

  /// Migrate existing Position model to enhanced version
  static Map<String, dynamic> migratePosition(
      Map<String, dynamic> existingPosition) {
    // Ensure all required fields are present with defaults
    return {
      'id': existingPosition['id'] ?? '',
      'symbol': existingPosition['symbol'] ?? '',
      'side': existingPosition['side'] ?? 'long',
      'size': existingPosition['size']?.toDouble() ?? 0.0,
      'entryPrice': existingPosition['entryPrice']?.toDouble() ?? 0.0,
      'currentPrice': existingPosition['currentPrice']?.toDouble() ?? 0.0,
      'unrealizedPnl': existingPosition['unrealizedPnl']?.toDouble() ?? 0.0,
      'pnlPercent': existingPosition['pnlPercent']?.toDouble() ?? 0.0,
      'createdAt':
          existingPosition['createdAt'] ?? DateTime.now().toIso8601String(),
      'updatedAt': existingPosition['updatedAt'],
      // Add enhanced fields with defaults
      'leverage': existingPosition['leverage']?.toDouble() ?? 1.0,
      'marginUsed': existingPosition['marginUsed']?.toDouble() ?? 0.0,
      'liquidationPrice': existingPosition['liquidationPrice']?.toDouble(),
      'fees': existingPosition['fees']?.toDouble() ?? 0.0,
    };
  }

  /// Migrate existing TechnicalAnalysis to TechnicalIndicators
  static TechnicalIndicators migrateTechnicalAnalysis(
      Map<String, dynamic> existingAnalysis) {
    return TechnicalIndicators(
      rsi: existingAnalysis['rsi']?.toDouble(),
      bollingerBands: existingAnalysis['bollingerBands'] != null
          ? BollingerBands.fromJson(existingAnalysis['bollingerBands'])
          : null,
      macd: existingAnalysis['macd'] != null
          ? MACD.fromJson(existingAnalysis['macd'])
          : null,
      timestamp: existingAnalysis['timestamp'] != null
          ? DateTime.parse(existingAnalysis['timestamp'])
          : DateTime.now(),
      symbol: existingAnalysis['symbol'] ?? '',
      timeframe: existingAnalysis['timeframe'] ?? '1h',
    );
  }

  /// Convert legacy API response to new format
  static Map<String, dynamic> convertLegacyApiResponse(
      Map<String, dynamic> legacyResponse) {
    final converted = Map<String, dynamic>.from(legacyResponse);

    // Convert snake_case to camelCase for consistency
    final keysToConvert = {
      'user_id': 'userId',
      'created_at': 'createdAt',
      'updated_at': 'updatedAt',
      'entry_price': 'entryPrice',
      'current_price': 'currentPrice',
      'unrealized_pnl': 'unrealizedPnl',
      'pnl_percent': 'pnlPercent',
      'stop_loss': 'stopLoss',
      'take_profit': 'takeProfit',
      'position_size': 'positionSize',
      'max_positions': 'maxPositions',
      'risk_level': 'riskLevel',
      'win_rate': 'winRate',
      'total_trades': 'totalTrades',
      'sharpe_ratio': 'sharpeRatio',
      'max_drawdown': 'maxDrawdown',
      'profit_factor': 'profitFactor',
    };

    for (final entry in keysToConvert.entries) {
      if (converted.containsKey(entry.key)) {
        converted[entry.value] = converted.remove(entry.key);
      }
    }

    return converted;
  }

  /// Validate and sanitize model data
  static Map<String, dynamic> validateAndSanitize(
      Map<String, dynamic> data, String modelType) {
    final sanitized = Map<String, dynamic>.from(data);

    switch (modelType) {
      case 'position':
        sanitized['size'] = _ensurePositiveDouble(sanitized['size']);
        sanitized['entryPrice'] =
            _ensurePositiveDouble(sanitized['entryPrice']);
        sanitized['currentPrice'] =
            _ensurePositiveDouble(sanitized['currentPrice']);
        break;

      case 'botConfig':
        sanitized['maxPositions'] =
            _ensurePositiveInt(sanitized['maxPositions']);
        sanitized['positionSizeUsd'] =
            _ensurePositiveDouble(sanitized['positionSizeUsd']);
        sanitized['stopLossPercent'] =
            _ensurePositiveDouble(sanitized['stopLossPercent']);
        sanitized['takeProfitPercent'] =
            _ensurePositiveDouble(sanitized['takeProfitPercent']);
        break;

      case 'backtest':
        sanitized['roi'] = _ensureDouble(sanitized['roi']);
        sanitized['sharpeRatio'] = _ensureDouble(sanitized['sharpeRatio']);
        sanitized['maxDrawdown'] =
            _ensurePositiveDouble(sanitized['maxDrawdown']);
        sanitized['totalTrades'] = _ensurePositiveInt(sanitized['totalTrades']);
        sanitized['winRate'] = _ensurePercentage(sanitized['winRate']);
        break;
    }

    return sanitized;
  }

  // Helper methods for data extraction and validation

  static String _extractAction(Map<String, dynamic> data) {
    final action = data['action'] ?? data['recommendation'] ?? 'HOLD';
    return action.toString().toUpperCase();
  }

  static double _extractConfidence(Map<String, dynamic> data) {
    final confidence = data['confidence'] ?? 0.5;
    return (confidence is num) ? confidence.toDouble() : 0.5;
  }

  static List<String> _extractReasoning(Map<String, dynamic> data) {
    final reasoning =
        data['reasoning'] ?? data['keyFactors'] ?? data['explanation'];

    if (reasoning is List) {
      return List<String>.from(reasoning);
    } else if (reasoning is String && reasoning.isNotEmpty) {
      return [reasoning];
    }

    return ['No reasoning provided'];
  }

  static double _extractPrice(Map<String, dynamic> data, String key) {
    final value = data[key] ?? 0.0;
    return (value is num) ? value.toDouble() : 0.0;
  }

  static double _ensurePositiveDouble(dynamic value) {
    if (value is num) {
      return value.toDouble().abs();
    }
    return 0.0;
  }

  static double _ensureDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return 0.0;
  }

  static int _ensurePositiveInt(dynamic value) {
    if (value is num) {
      return value.toInt().abs();
    }
    return 0;
  }

  static double _ensurePercentage(dynamic value) {
    if (value is num) {
      return value.toDouble().clamp(0.0, 100.0);
    }
    return 0.0;
  }
}
