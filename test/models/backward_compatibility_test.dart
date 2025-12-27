import 'package:flutter_test/flutter_test.dart';
import 'package:kuri_crypto/models/models.dart';

/// **Feature: backend-integration-update, Property 45: Data Model Backward Compatibility**
///
/// Property: For any data model update, the system should provide backward
/// compatibility adapters for existing data structures
///
/// This test validates that existing data can be converted to new enhanced models
/// without data loss and maintains functional compatibility.
void main() {
  group('Property 45: Data Model Backward Compatibility', () {
    test('should convert legacy LLM analysis to enhanced format', () {
      // Arrange: Create legacy LLM analysis data
      final legacyData = {
        'provider': 'openai',
        'explanation': 'Market shows bullish signals',
        'keyFactors': ['Strong volume', 'Breaking resistance'],
        'confidence': 0.85,
        'recommendation': 'BUY',
      };

      // Act: Convert using backward compatibility adapter
      final enhanced =
          BackwardCompatibilityAdapter.convertLLMAnalysis(legacyData);

      // Assert: Verify conversion maintains data integrity
      expect(enhanced.action, equals('BUY'));
      expect(enhanced.confidence, equals(0.85));
      expect(enhanced.reasoning, contains('Strong volume'));
      expect(enhanced.reasoning, contains('Breaking resistance'));
      expect(enhanced.provider, equals('openai'));
    });

    test('should convert legacy bot config to enhanced format', () {
      // Arrange: Create legacy bot config data
      final legacyConfig = {
        'dryRun': false,
        'maxPositions': 3,
        'positionSizeUsd': 500.0,
        'stopLossPercent': 2.5,
        'takeProfitPercent': 5.0,
        'symbols': ['BTC-USDT', 'ETH-USDT'],
      };

      // Act: Convert using backward compatibility adapter
      final enhanced =
          BackwardCompatibilityAdapter.convertBotConfig(legacyConfig);

      // Assert: Verify conversion maintains configuration
      expect(enhanced.dryRun, isFalse);
      expect(enhanced.maxPositions, equals(3));
      expect(enhanced.positionSizeUsd, equals(500.0));
      expect(enhanced.stopLossPercent, equals(2.5));
      expect(enhanced.takeProfitPercent, equals(5.0));
      expect(enhanced.symbols, contains('BTC-USDT'));
      expect(enhanced.symbols, contains('ETH-USDT'));
    });

    test('should convert legacy bot status to enhanced format', () {
      // Arrange: Create legacy bot status data
      final legacyStatus = {
        'state': 'running',
        'autonomousMode': true,
        'positions': {
          'total': 2,
          'open': 1,
          'totalValue': 1000.0,
          'unrealizedPnl': 50.0,
        },
        'performance': {
          'totalPnl': 150.0,
          'winRate': 65.0,
          'totalTrades': 10,
          'sharpeRatio': 1.2,
        },
        'risk': {
          'currentRisk': 25.0,
          'maxRisk': 100.0,
          'riskLevel': 'medium',
        },
      };

      // Act: Convert using backward compatibility adapter
      final enhanced =
          BackwardCompatibilityAdapter.convertBotStatus(legacyStatus);

      // Assert: Verify conversion maintains status information
      expect(enhanced.state, equals('running'));
      expect(enhanced.autonomousMode, isTrue);
      expect(enhanced.positions.total, equals(2));
      expect(enhanced.positions.open, equals(1));
      expect(enhanced.performance.totalPnl, equals(150.0));
      expect(enhanced.performance.winRate, equals(65.0));
      expect(enhanced.risk.currentRisk, equals(25.0));
      expect(enhanced.risk.riskLevel, equals('medium'));
    });

    test('should convert legacy sentiment analysis to enhanced format', () {
      // Arrange: Create legacy sentiment analysis data
      final legacyAnalysis = {
        'symbol': 'BTC-USDT',
        'sentiment': {
          'score': 0.7,
          'label': 'positive',
          'breakdown': {
            'news': 0.8,
            'social': 0.6,
          },
        },
        'interpretation': {
          'summary': 'Overall positive sentiment',
          'impact': 'bullish',
          'keyFactors': ['Positive news', 'Strong social sentiment'],
        },
        'dataCounts': {
          'news': 150,
          'social': 300,
        },
      };

      // Act: Convert using backward compatibility adapter
      final enhanced =
          BackwardCompatibilityAdapter.convertSentimentAnalysis(legacyAnalysis);

      // Assert: Verify conversion maintains sentiment data
      expect(enhanced.symbol, equals('BTC-USDT'));
      expect(enhanced.sentiment.score, equals(0.7));
      expect(enhanced.sentiment.label, equals('positive'));
      expect(enhanced.interpretation.summary,
          equals('Overall positive sentiment'));
      expect(enhanced.interpretation.impact, equals('bullish'));
      expect(enhanced.dataCounts['news'], equals(150));
      expect(enhanced.dataCounts['social'], equals(300));
    });

    test('should migrate legacy position data with enhanced fields', () {
      // Arrange: Create legacy position data
      final legacyPosition = {
        'id': 'pos_123',
        'symbol': 'BTC-USDT',
        'side': 'long',
        'size': 0.1,
        'entryPrice': 50000.0,
        'currentPrice': 51000.0,
        'unrealizedPnl': 100.0,
        'pnlPercent': 2.0,
        'createdAt': '2024-01-01T00:00:00Z',
      };

      // Act: Migrate using backward compatibility adapter
      final migrated =
          BackwardCompatibilityAdapter.migratePosition(legacyPosition);

      // Assert: Verify migration adds enhanced fields with defaults
      expect(migrated['id'], equals('pos_123'));
      expect(migrated['symbol'], equals('BTC-USDT'));
      expect(migrated['side'], equals('long'));
      expect(migrated['size'], equals(0.1));
      expect(migrated['entryPrice'], equals(50000.0));
      expect(migrated['currentPrice'], equals(51000.0));
      expect(migrated['unrealizedPnl'], equals(100.0));
      expect(migrated['pnlPercent'], equals(2.0));

      // Enhanced fields should have defaults
      expect(migrated['leverage'], equals(1.0));
      expect(migrated['marginUsed'], equals(0.0));
      expect(migrated['fees'], equals(0.0));
      expect(migrated.containsKey('liquidationPrice'), isTrue);
    });

    test('should migrate legacy technical analysis to technical indicators',
        () {
      // Arrange: Create legacy technical analysis data
      final legacyAnalysis = {
        'symbol': 'BTC-USDT',
        'timeframe': '1h',
        'rsi': 65.5,
        'bollingerBands': {
          'upper': 52000.0,
          'middle': 51000.0,
          'lower': 50000.0,
          'bandwidth': 0.04,
          'percentB': 0.6,
        },
        'macd': {
          'macd': 150.0,
          'signal': 120.0,
          'histogram': 30.0,
          'trend': 'bullish',
        },
        'timestamp': '2024-01-01T12:00:00Z',
      };

      // Act: Migrate using backward compatibility adapter
      final migrated =
          BackwardCompatibilityAdapter.migrateTechnicalAnalysis(legacyAnalysis);

      // Assert: Verify migration maintains technical data
      expect(migrated.symbol, equals('BTC-USDT'));
      expect(migrated.timeframe, equals('1h'));
      expect(migrated.rsi, equals(65.5));
      expect(migrated.bollingerBands?.upper, equals(52000.0));
      expect(migrated.bollingerBands?.middle, equals(51000.0));
      expect(migrated.bollingerBands?.lower, equals(50000.0));
      expect(migrated.macd?.macd, equals(150.0));
      expect(migrated.macd?.signal, equals(120.0));
      expect(migrated.macd?.trend, equals('bullish'));
    });

    test('should convert legacy API response format', () {
      // Arrange: Create legacy API response with snake_case
      final legacyResponse = {
        'user_id': 'user_123',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T12:00:00Z',
        'entry_price': 50000.0,
        'current_price': 51000.0,
        'unrealized_pnl': 100.0,
        'pnl_percent': 2.0,
        'stop_loss': 49000.0,
        'take_profit': 52000.0,
        'position_size': 0.1,
        'max_positions': 5,
        'risk_level': 'medium',
        'win_rate': 65.0,
        'total_trades': 10,
        'sharpe_ratio': 1.2,
        'max_drawdown': 5.0,
        'profit_factor': 1.8,
      };

      // Act: Convert using backward compatibility adapter
      final converted =
          BackwardCompatibilityAdapter.convertLegacyApiResponse(legacyResponse);

      // Assert: Verify snake_case is converted to camelCase
      expect(converted['userId'], equals('user_123'));
      expect(converted['createdAt'], equals('2024-01-01T00:00:00Z'));
      expect(converted['updatedAt'], equals('2024-01-01T12:00:00Z'));
      expect(converted['entryPrice'], equals(50000.0));
      expect(converted['currentPrice'], equals(51000.0));
      expect(converted['unrealizedPnl'], equals(100.0));
      expect(converted['pnlPercent'], equals(2.0));
      expect(converted['stopLoss'], equals(49000.0));
      expect(converted['takeProfit'], equals(52000.0));
      expect(converted['positionSize'], equals(0.1));
      expect(converted['maxPositions'], equals(5));
      expect(converted['riskLevel'], equals('medium'));
      expect(converted['winRate'], equals(65.0));
      expect(converted['totalTrades'], equals(10));
      expect(converted['sharpeRatio'], equals(1.2));
      expect(converted['maxDrawdown'], equals(5.0));
      expect(converted['profitFactor'], equals(1.8));

      // Original snake_case keys should be removed
      expect(converted.containsKey('user_id'), isFalse);
      expect(converted.containsKey('created_at'), isFalse);
      expect(converted.containsKey('entry_price'), isFalse);
    });

    test('should validate and sanitize position data', () {
      // Arrange: Create position data with invalid values
      final invalidData = {
        'size': -0.1, // Negative size should be made positive
        'entryPrice': -50000.0, // Negative price should be made positive
        'currentPrice': 'invalid', // Invalid type should default to 0
      };

      // Act: Validate and sanitize
      final sanitized = BackwardCompatibilityAdapter.validateAndSanitize(
          invalidData, 'position');

      // Assert: Verify sanitization fixes invalid values
      expect(sanitized['size'], equals(0.1)); // Made positive
      expect(sanitized['entryPrice'], equals(50000.0)); // Made positive
      expect(sanitized['currentPrice'], equals(0.0)); // Invalid type defaulted
    });

    test('should validate and sanitize bot config data', () {
      // Arrange: Create bot config with invalid values
      final invalidData = {
        'maxPositions': -5, // Negative should be made positive
        'positionSizeUsd': -100.0, // Negative should be made positive
        'stopLossPercent': 'invalid', // Invalid type should default to 0
        'takeProfitPercent': -2.0, // Negative should be made positive
      };

      // Act: Validate and sanitize
      final sanitized = BackwardCompatibilityAdapter.validateAndSanitize(
          invalidData, 'botConfig');

      // Assert: Verify sanitization fixes invalid values
      expect(sanitized['maxPositions'], equals(5)); // Made positive
      expect(sanitized['positionSizeUsd'], equals(100.0)); // Made positive
      expect(
          sanitized['stopLossPercent'], equals(0.0)); // Invalid type defaulted
      expect(sanitized['takeProfitPercent'], equals(2.0)); // Made positive
    });

    test('should validate and sanitize backtest data', () {
      // Arrange: Create backtest data with invalid values
      final invalidData = {
        'roi': 'invalid', // Invalid type should default to 0
        'sharpeRatio': -1.5, // Negative is valid for Sharpe ratio
        'maxDrawdown': -10.0, // Negative should be made positive
        'totalTrades': -20, // Negative should be made positive
        'winRate': 150.0, // Over 100% should be clamped
      };

      // Act: Validate and sanitize
      final sanitized = BackwardCompatibilityAdapter.validateAndSanitize(
          invalidData, 'backtest');

      // Assert: Verify sanitization fixes invalid values
      expect(sanitized['roi'], equals(0.0)); // Invalid type defaulted
      expect(
          sanitized['sharpeRatio'], equals(-1.5)); // Negative preserved (valid)
      expect(sanitized['maxDrawdown'], equals(10.0)); // Made positive
      expect(sanitized['totalTrades'], equals(20)); // Made positive
      expect(sanitized['winRate'], equals(100.0)); // Clamped to max 100%
    });

    test('should handle null and missing data gracefully', () {
      // Arrange: Create data with null and missing values
      final incompleteData = <String, dynamic>{
        'symbol': null,
        'confidence': null,
        // Missing required fields
      };

      // Act: Convert using backward compatibility adapter
      final enhanced =
          BackwardCompatibilityAdapter.convertLLMAnalysis(incompleteData);

      // Assert: Verify graceful handling with defaults
      expect(enhanced.action, equals('HOLD')); // Default action
      expect(enhanced.confidence, equals(0.5)); // Default confidence
      expect(enhanced.reasoning, isNotEmpty); // Default reasoning provided
      expect(enhanced.provider, isEmpty); // Empty string for null
      expect(enhanced.entryPrice, equals(0.0)); // Default price
      expect(enhanced.stopLoss, equals(0.0)); // Default price
      expect(enhanced.takeProfit, equals(0.0)); // Default price
      expect(enhanced.cost, equals(0.0)); // Default cost
    });

    test('should preserve existing enhanced models unchanged', () {
      // Arrange: Create already enhanced LLM analysis
      const existingEnhanced = EnhancedLLMAnalysis(
        action: 'BUY',
        confidence: 0.8,
        reasoning: ['Strong technical signals'],
        entryPrice: 50000.0,
        stopLoss: 49000.0,
        takeProfit: 52000.0,
        provider: 'openai',
        cost: 0.05,
      );

      // Act: Convert using backward compatibility adapter
      final result =
          BackwardCompatibilityAdapter.convertLLMAnalysis(existingEnhanced);

      // Assert: Verify enhanced model is returned unchanged
      expect(result, equals(existingEnhanced));
      expect(result.action, equals('BUY'));
      expect(result.confidence, equals(0.8));
      expect(result.reasoning, equals(['Strong technical signals']));
      expect(result.entryPrice, equals(50000.0));
      expect(result.stopLoss, equals(49000.0));
      expect(result.takeProfit, equals(52000.0));
      expect(result.provider, equals('openai'));
      expect(result.cost, equals(0.05));
    });
  });
}
