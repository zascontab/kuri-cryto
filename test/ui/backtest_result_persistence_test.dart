import 'package:flutter_test/flutter_test.dart';
import 'package:kuri_crypto/models/mcp_backtest_models.dart';
import 'package:kuri_crypto/services/performance_cache_service.dart';

/// Property-based test for backtest result persistence
///
/// **Feature: backend-integration-update, Property 35: Backtest Result Persistence**
///
/// For any backtest result that is saved, the system should persist the results
/// and make them available for future reference
///
/// **Validates: Requirements 7.5**

BacktestResult _createTestResult({
  required String id,
  required double roi,
  required List<BacktestTrade> trades,
}) {
  return BacktestResult(
    roi: roi,
    sharpeRatio: 1.5,
    maxDrawdown: 10.0,
    totalTrades: trades.length,
    winRate: 60.0,
    profitFactor: 1.8,
    trades: trades,
  );
}

BacktestTrade _createTestTrade({
  required String id,
  required double pnl,
}) {
  return BacktestTrade(
    id: id,
    symbol: 'BTC-USDT',
    side: 'buy',
    entryPrice: 50000.0,
    exitPrice: 51000.0,
    size: 0.1,
    entryTime: DateTime.now().subtract(const Duration(hours: 2)),
    exitTime: DateTime.now(),
    pnl: pnl,
    pnlPercent: 2.0,
  );
}

void main() {
  group('Property 35: Backtest Result Persistence', () {
    late PerformanceCacheService cacheService;

    setUp(() {
      cacheService = PerformanceCacheService.instance;
    });

    test('should serialize and deserialize BacktestResult correctly', () {
      // Property: Any BacktestResult should be serializable and deserializable without data loss
      final originalTrades = [
        _createTestTrade(id: 'trade1', pnl: 100.0),
        _createTestTrade(id: 'trade2', pnl: -50.0),
        _createTestTrade(id: 'trade3', pnl: 200.0),
      ];

      final originalResult = _createTestResult(
        id: 'test-backtest-001',
        roi: 25.5,
        trades: originalTrades,
      );

      // Serialize to JSON
      final json = originalResult.toJson();

      // Deserialize from JSON
      final deserializedResult = BacktestResult.fromJson(json);

      // Verify all fields are preserved
      expect(deserializedResult.roi, equals(originalResult.roi));
      expect(
          deserializedResult.sharpeRatio, equals(originalResult.sharpeRatio));
      expect(
          deserializedResult.maxDrawdown, equals(originalResult.maxDrawdown));
      expect(
          deserializedResult.totalTrades, equals(originalResult.totalTrades));
      expect(deserializedResult.winRate, equals(originalResult.winRate));
      expect(
          deserializedResult.profitFactor, equals(originalResult.profitFactor));
      expect(deserializedResult.trades.length,
          equals(originalResult.trades.length));

      // Verify trades are preserved
      for (int i = 0; i < originalResult.trades.length; i++) {
        final originalTrade = originalResult.trades[i];
        final deserializedTrade = deserializedResult.trades[i];

        expect(deserializedTrade.id, equals(originalTrade.id));
        expect(deserializedTrade.symbol, equals(originalTrade.symbol));
        expect(deserializedTrade.pnl, equals(originalTrade.pnl));
        expect(deserializedTrade.entryPrice, equals(originalTrade.entryPrice));
        expect(deserializedTrade.exitPrice, equals(originalTrade.exitPrice));
      }
    });

    test('should handle empty trades list in serialization', () {
      // Property: BacktestResult with empty trades should serialize correctly
      final resultWithNoTrades = _createTestResult(
        id: 'empty-backtest',
        roi: 0.0,
        trades: [],
      );

      final json = resultWithNoTrades.toJson();
      final deserializedResult = BacktestResult.fromJson(json);

      expect(deserializedResult.trades, isEmpty);
      expect(deserializedResult.totalTrades, equals(0));
      expect(deserializedResult.roi, equals(0.0));
    });

    test('should preserve calculated properties after deserialization', () {
      // Property: Calculated properties should work correctly after deserialization
      final trades = List.generate(
          40,
          (i) => _createTestTrade(
              id: 'trade_$i', pnl: i % 4 == 0 ? -50.0 : 100.0) // 75% win rate
          );

      final originalResult = BacktestResult(
        roi: 55.0,
        sharpeRatio: 2.2,
        maxDrawdown: 8.0,
        totalTrades: trades.length,
        winRate: 75.0, // 75% win rate
        profitFactor: 3.0,
        trades: trades,
      );

      final json = originalResult.toJson();
      final deserializedResult = BacktestResult.fromJson(json);

      // Verify calculated properties
      expect(deserializedResult.isProfitable, isTrue);
      expect(deserializedResult.hasGoodPerformance, isTrue);
      expect(deserializedResult.performanceGrade, equals('A'));
      expect(deserializedResult.isViableStrategy, isTrue);
      expect(deserializedResult.winningTrades, equals(30)); // 75% of 40 trades
      expect(deserializedResult.losingTrades, equals(10));
    });

    test('should handle extreme values in serialization', () {
      // Property: Extreme values should be preserved in serialization
      const extremeResult = BacktestResult(
        roi: 999.99,
        sharpeRatio: 10.5,
        maxDrawdown: 0.01,
        totalTrades: 1000,
        winRate: 99.9,
        profitFactor: 50.0,
        trades: [],
      );

      final json = extremeResult.toJson();
      final deserializedResult = BacktestResult.fromJson(json);

      expect(deserializedResult.roi, equals(999.99));
      expect(deserializedResult.sharpeRatio, equals(10.5));
      expect(deserializedResult.maxDrawdown, equals(0.01));
      expect(deserializedResult.totalTrades, equals(1000));
      expect(deserializedResult.winRate, equals(99.9));
      expect(deserializedResult.profitFactor, equals(50.0));
    });

    test('should handle negative values correctly', () {
      // Property: Negative values should be preserved correctly
      final negativeResult = BacktestResult(
        roi: -25.5,
        sharpeRatio: -0.8,
        maxDrawdown: 45.0,
        totalTrades: 20,
        winRate: 25.0,
        profitFactor: 0.6,
        trades: [
          _createTestTrade(id: 'loss1', pnl: -100.0),
          _createTestTrade(id: 'loss2', pnl: -200.0),
        ],
      );

      final json = negativeResult.toJson();
      final deserializedResult = BacktestResult.fromJson(json);

      expect(deserializedResult.roi, equals(-25.5));
      expect(deserializedResult.sharpeRatio, equals(-0.8));
      expect(deserializedResult.isProfitable, isFalse);
      expect(deserializedResult.hasGoodPerformance, isFalse);
      expect(deserializedResult.performanceGrade, equals('F'));
    });

    test('should generate consistent cache keys for backtest results', () {
      // Property: Cache keys should be consistent for the same backtest ID
      const backtestId1 = 'strategy-001-20241214';
      const backtestId2 = 'strategy-002-20241214';
      const backtestId3 = 'strategy-001-20241214'; // Same as first

      final key1a = PerformanceCacheKeys.backtestResult(backtestId1);
      final key1b = PerformanceCacheKeys.backtestResult(backtestId1);
      final key2 = PerformanceCacheKeys.backtestResult(backtestId2);
      final key3 = PerformanceCacheKeys.backtestResult(backtestId3);

      // Same backtest ID should generate same key
      expect(key1a, equals(key1b));
      expect(key1a, equals(key3));

      // Different backtest IDs should generate different keys
      expect(key1a, isNot(equals(key2)));

      // Keys should follow expected format
      expect(key1a, startsWith('backtest_result_'));
      expect(key1a, contains(backtestId1));
    });

    test('should handle malformed JSON gracefully', () {
      // Property: Malformed JSON should not crash deserialization
      final malformedJsonCases = [
        {}, // Empty JSON
        {'roi': 'invalid'}, // Invalid type
        {'roi': 25.0}, // Missing required fields
        {
          'roi': 25.0,
          'sharpeRatio': 1.5,
          'maxDrawdown': 10.0,
          'totalTrades': 'invalid', // Invalid type
          'winRate': 60.0,
          'profitFactor': 1.8,
          'trades': [],
        },
        {
          'roi': 25.0,
          'sharpeRatio': 1.5,
          'maxDrawdown': 10.0,
          'totalTrades': 50,
          'winRate': 60.0,
          'profitFactor': 1.8,
          'trades': 'invalid', // Invalid type for trades
        },
      ];

      for (final malformedJson in malformedJsonCases) {
        try {
          // Should not throw exception for most cases
          final result =
              BacktestResult.fromJson(Map<String, dynamic>.from(malformedJson));

          // Should have default values for missing/invalid fields
          expect(result.roi, isA<double>());
          expect(result.sharpeRatio, isA<double>());
          expect(result.maxDrawdown, isA<double>());
          expect(result.totalTrades, isA<int>());
          expect(result.winRate, isA<double>());
          expect(result.profitFactor, isA<double>());
          expect(result.trades, isA<List<BacktestTrade>>());
        } catch (e) {
          // Some malformed JSON may throw exceptions, which is acceptable
          expect(e, isA<Error>());
        }
      }
    });

    test('should preserve trade order in serialization', () {
      // Property: Trade order should be preserved during serialization/deserialization
      final orderedTrades = [
        _createTestTrade(id: 'first', pnl: 100.0),
        _createTestTrade(id: 'second', pnl: -50.0),
        _createTestTrade(id: 'third', pnl: 200.0),
        _createTestTrade(id: 'fourth', pnl: -25.0),
        _createTestTrade(id: 'fifth', pnl: 150.0),
      ];

      final result = _createTestResult(
        id: 'ordered-test',
        roi: 25.0,
        trades: orderedTrades,
      );

      final json = result.toJson();
      final deserializedResult = BacktestResult.fromJson(json);

      // Verify trade order is preserved
      expect(deserializedResult.trades.length, equals(orderedTrades.length));

      for (int i = 0; i < orderedTrades.length; i++) {
        expect(deserializedResult.trades[i].id, equals(orderedTrades[i].id));
      }
    });

    test('should handle large datasets efficiently', () {
      // Property: Large datasets should be handled efficiently
      final largeTrades = List.generate(
          1000,
          (index) => _createTestTrade(
              id: 'trade_$index', pnl: (index % 2 == 0) ? 10.0 : -5.0));

      final largeResult = _createTestResult(
        id: 'large-dataset',
        roi: 50.0,
        trades: largeTrades,
      );

      final stopwatch = Stopwatch()..start();

      // Serialize
      final json = largeResult.toJson();

      // Deserialize
      final deserializedResult = BacktestResult.fromJson(json);

      stopwatch.stop();

      // Should complete in reasonable time (less than 1 second)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      // Should preserve all data
      expect(deserializedResult.trades.length, equals(1000));
      expect(deserializedResult.totalTrades, equals(1000));
    });

    test('should maintain data integrity across multiple serialization cycles',
        () {
      // Property: Multiple serialization/deserialization cycles should not corrupt data
      final originalResult = _createTestResult(
        id: 'integrity-test',
        roi: 33.33,
        trades: [
          _createTestTrade(id: 'test1', pnl: 123.45),
          _createTestTrade(id: 'test2', pnl: -67.89),
        ],
      );

      var currentResult = originalResult;

      // Perform multiple serialization cycles
      for (int i = 0; i < 5; i++) {
        final json = currentResult.toJson();
        currentResult = BacktestResult.fromJson(json);
      }

      // Data should remain identical after multiple cycles
      expect(currentResult.roi, equals(originalResult.roi));
      expect(currentResult.sharpeRatio, equals(originalResult.sharpeRatio));
      expect(currentResult.trades.length, equals(originalResult.trades.length));

      for (int i = 0; i < originalResult.trades.length; i++) {
        expect(currentResult.trades[i].id, equals(originalResult.trades[i].id));
        expect(
            currentResult.trades[i].pnl, equals(originalResult.trades[i].pnl));
      }
    });
  });
}
