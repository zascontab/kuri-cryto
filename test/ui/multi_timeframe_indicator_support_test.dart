import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:kuri_crypto/widgets/multi_timeframe_widget.dart';
import 'package:kuri_crypto/models/technical_indicators.dart';

/// Property-based test for multi-timeframe indicator support
///
/// **Feature: backend-integration-update, Property 15: Multi-Timeframe Indicator Support**
///
/// For any selection of multiple timeframes, the system should calculate
/// indicators for each timeframe independently
///
/// **Validates: Requirements 3.5**

Widget _buildTestWidget(Map<String, TechnicalIndicators> indicators) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        height: 1200, // Larger height to accommodate many timeframes
        child: SingleChildScrollView(
          child: MultiTimeframeWidget(
            technicalIndicators: indicators,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('Property 15: Multi-Timeframe Indicator Support', () {
    testWidgets('should display indicators for all provided timeframes',
        (WidgetTester tester) async {
      // Property: Each timeframe should have independent indicator calculations
      final timeframes = ['1m', '5m', '15m', '1h', '4h', '1d'];
      final indicators = <String, TechnicalIndicators>{};

      // Create different indicator values for each timeframe
      for (int i = 0; i < timeframes.length; i++) {
        final tf = timeframes[i];
        indicators[tf] = TechnicalIndicators(
          rsi: 30.0 + (i * 10.0), // Different RSI for each timeframe
          macd: MACD(
            macd: i % 2 == 0 ? 0.2 : -0.2,
            signal: i % 2 == 0 ? 0.1 : -0.1,
            histogram: i % 2 == 0 ? 0.1 : -0.1,
            trend: i % 2 == 0 ? 'bullish' : 'bearish',
          ),
          bollingerBands: BollingerBands(
            upper: 50000.0 + (i * 1000),
            middle: 45000.0 + (i * 1000),
            lower: 40000.0 + (i * 1000),
            bandwidth: 0.2,
            percentB: 0.3 + (i * 0.1),
          ),
          timestamp: DateTime.now(),
          symbol: 'BTC-USDT',
          timeframe: tf,
        );
      }

      final widget = _buildTestWidget(indicators);
      await tester.pumpWidget(widget);

      // Verify all timeframes are displayed
      for (final tf in timeframes) {
        expect(find.text(tf.toUpperCase()), findsOneWidget,
            reason: 'Timeframe $tf should be displayed');
      }

      // Verify each timeframe has independent RSI values
      for (int i = 0; i < timeframes.length; i++) {
        final expectedRSI = (30.0 + (i * 10.0)).toStringAsFixed(1);
        expect(find.text(expectedRSI), findsOneWidget,
            reason:
                'RSI value $expectedRSI should be displayed for timeframe ${timeframes[i]}');
      }

      // Verify MACD signals are independent - should have both BUY and SELL
      expect(find.text('BUY'), findsAtLeastNWidgets(1));
      expect(find.text('SELL'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle different indicator combinations per timeframe',
        (WidgetTester tester) async {
      // Property: Different timeframes can have different available indicators
      final indicators = <String, TechnicalIndicators>{
        '1m': TechnicalIndicators(
          rsi: 45.0, // Only RSI
          timestamp: DateTime.now(),
          symbol: 'BTC-USDT',
          timeframe: '1m',
        ),
        '5m': TechnicalIndicators(
          macd: const MACD(
              macd: 0.2,
              signal: 0.1,
              histogram: 0.1,
              trend: 'bullish'), // Only MACD
          timestamp: DateTime.now(),
          symbol: 'BTC-USDT',
          timeframe: '5m',
        ),
        '1h': TechnicalIndicators(
          rsi: 65.0,
          macd:
              const MACD(macd: -0.2, signal: -0.1, histogram: -0.1, trend: 'bearish'),
          bollingerBands: const BollingerBands(
              upper: 52000,
              middle: 47000,
              lower: 42000,
              bandwidth: 0.25,
              percentB: 0.8), // All indicators
          timestamp: DateTime.now(),
          symbol: 'BTC-USDT',
          timeframe: '1h',
        ),
      };

      final widget = _buildTestWidget(indicators);
      await tester.pumpWidget(widget);

      // Verify 1m timeframe shows only RSI
      expect(find.text('1M'), findsOneWidget);
      expect(find.text('45.0'), findsOneWidget);

      // Verify 5m timeframe shows only MACD
      expect(find.text('5M'), findsOneWidget);
      expect(find.text('BUY'), findsAtLeastNWidgets(1)); // MACD signal

      // Verify 1h timeframe shows all indicators
      expect(find.text('1H'), findsOneWidget);
      expect(find.text('65.0'), findsOneWidget); // RSI
      expect(find.text('SELL'), findsAtLeastNWidgets(1)); // MACD signal
      expect(find.text('BB'), findsOneWidget); // Bollinger Bands
    });

    testWidgets('should maintain timeframe independence with same symbols',
        (WidgetTester tester) async {
      // Property: Same symbol across timeframes should show independent calculations
      const symbol = 'ETH-USDT';
      final indicators = <String, TechnicalIndicators>{
        '15m': TechnicalIndicators(
          rsi: 25.0, // Oversold in 15m
          timestamp: DateTime.now(),
          symbol: symbol,
          timeframe: '15m',
        ),
        '1h': TechnicalIndicators(
          rsi: 75.0, // Overbought in 1h
          timestamp: DateTime.now(),
          symbol: symbol,
          timeframe: '1h',
        ),
        '4h': TechnicalIndicators(
          rsi: 50.0, // Neutral in 4h
          timestamp: DateTime.now(),
          symbol: symbol,
          timeframe: '4h',
        ),
      };

      final widget = _buildTestWidget(indicators);
      await tester.pumpWidget(widget);

      // Verify all RSI values are displayed independently
      expect(find.text('25.0'), findsOneWidget); // 15m oversold
      expect(find.text('75.0'), findsOneWidget); // 1h overbought
      expect(find.text('50.0'), findsOneWidget); // 4h neutral

      // Verify different color coding for different RSI levels
      // Should have green (oversold), red (overbought), and blue (neutral) containers
      expect(find.byWidgetPredicate((widget) {
        return widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color != null;
      }), findsAtLeastNWidgets(3));
    });

    testWidgets('should handle large number of timeframes efficiently',
        (WidgetTester tester) async {
      // Property: System should handle many timeframes without performance issues
      final manyTimeframes = [
        '1m',
        '3m',
        '5m',
        '15m',
        '30m',
        '1h',
        '2h',
        '4h',
        '6h',
        '8h',
        '12h',
        '1d'
      ];

      final indicators = <String, TechnicalIndicators>{};
      for (int i = 0; i < manyTimeframes.length; i++) {
        final tf = manyTimeframes[i];
        indicators[tf] = TechnicalIndicators(
          rsi: 20.0 + (i * 5.0), // Spread RSI values
          timestamp: DateTime.now(),
          symbol: 'BTC-USDT',
          timeframe: tf,
        );
      }

      final widget = _buildTestWidget(indicators);

      // Should render without performance issues
      final stopwatch = Stopwatch()..start();
      await tester.pumpWidget(widget);
      stopwatch.stop();

      // Should render in reasonable time (less than 1 second)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000),
          reason: 'Should render many timeframes efficiently');

      // Verify all timeframes are present
      for (final tf in manyTimeframes) {
        expect(find.text(tf.toUpperCase()), findsOneWidget,
            reason: 'Timeframe $tf should be displayed');
      }
    });

    testWidgets('should handle mixed fresh and stale data across timeframes',
        (WidgetTester tester) async {
      // Property: Each timeframe can have different data freshness
      final now = DateTime.now();
      final indicators = <String, TechnicalIndicators>{
        '1m': TechnicalIndicators(
          rsi: 40.0,
          timestamp: now, // Fresh data
          symbol: 'BTC-USDT',
          timeframe: '1m',
        ),
        '5m': TechnicalIndicators(
          rsi: 50.0,
          timestamp: now.subtract(const Duration(minutes: 10)), // Stale data
          symbol: 'BTC-USDT',
          timeframe: '5m',
        ),
        '1h': TechnicalIndicators(
          rsi: 60.0,
          timestamp: now.subtract(const Duration(hours: 2)), // Very stale data
          symbol: 'BTC-USDT',
          timeframe: '1h',
        ),
      };

      final widget = _buildTestWidget(indicators);
      await tester.pumpWidget(widget);

      // All timeframes should be displayed regardless of data freshness
      expect(find.text('1M'), findsOneWidget);
      expect(find.text('5M'), findsOneWidget);
      expect(find.text('1H'), findsOneWidget);

      // All RSI values should be displayed
      expect(find.text('40.0'), findsOneWidget);
      expect(find.text('50.0'), findsOneWidget);
      expect(find.text('60.0'), findsOneWidget);
    });

    testWidgets('should support custom timeframe formats',
        (WidgetTester tester) async {
      // Property: System should handle various timeframe format conventions
      final customTimeframes = {
        '1MIN': TechnicalIndicators(
          rsi: 35.0,
          timestamp: DateTime.now(),
          symbol: 'BTC-USDT',
          timeframe: '1MIN',
        ),
        '5_MINUTES': TechnicalIndicators(
          rsi: 45.0,
          timestamp: DateTime.now(),
          symbol: 'BTC-USDT',
          timeframe: '5_MINUTES',
        ),
        '1HOUR': TechnicalIndicators(
          rsi: 55.0,
          timestamp: DateTime.now(),
          symbol: 'BTC-USDT',
          timeframe: '1HOUR',
        ),
      };

      final widget = _buildTestWidget(customTimeframes);
      await tester.pumpWidget(widget);

      // Should display custom timeframe formats
      expect(find.text('1MIN'), findsOneWidget);
      expect(find.text('5_MINUTES'), findsOneWidget);
      expect(find.text('1HOUR'), findsOneWidget);

      // Should display corresponding RSI values
      expect(find.text('35.0'), findsOneWidget);
      expect(find.text('45.0'), findsOneWidget);
      expect(find.text('55.0'), findsOneWidget);
    });

    testWidgets('should handle timeframe updates independently',
        (WidgetTester tester) async {
      // Property: Updating one timeframe should not affect others
      var indicators = <String, TechnicalIndicators>{
        '1m': TechnicalIndicators(
          rsi: 30.0,
          timestamp: DateTime.now(),
          symbol: 'BTC-USDT',
          timeframe: '1m',
        ),
        '1h': TechnicalIndicators(
          rsi: 70.0,
          timestamp: DateTime.now(),
          symbol: 'BTC-USDT',
          timeframe: '1h',
        ),
      };

      final widget = _buildTestWidget(indicators);
      await tester.pumpWidget(widget);

      // Verify initial state
      expect(find.text('30.0'), findsOneWidget);
      expect(find.text('70.0'), findsOneWidget);

      // Update only 1m timeframe
      indicators = Map.from(indicators);
      indicators['1m'] = TechnicalIndicators(
        rsi: 35.0, // Updated value
        timestamp: DateTime.now(),
        symbol: 'BTC-USDT',
        timeframe: '1m',
      );

      final updatedWidget = _buildTestWidget(indicators);
      await tester.pumpWidget(updatedWidget);

      // 1m should show updated value
      expect(find.text('35.0'), findsOneWidget);
      // 1h should remain unchanged
      expect(find.text('70.0'), findsOneWidget);
      // Old 1m value should not be present
      expect(find.text('30.0'), findsNothing);
    });
  });
}
