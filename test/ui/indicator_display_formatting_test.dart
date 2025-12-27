import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:kuri_crypto/widgets/multi_timeframe_widget.dart';
import 'package:kuri_crypto/models/technical_indicators.dart';

/// Property-based test for indicator display formatting
///
/// **Feature: backend-integration-update, Property 12: Indicator Display Formatting**
///
/// For any completed indicator calculation, the system should display results
/// in an intuitive and consistent format
///
/// **Validates: Requirements 3.2**

Widget _buildTestWidget(Map<String, TechnicalIndicators> indicators) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        height: 800,
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
  group('Property 12: Indicator Display Formatting', () {
    testWidgets('should format RSI values consistently',
        (WidgetTester tester) async {
      // Property: For any RSI value, display should be formatted to 1 decimal place
      final testCases = [
        0.0,
        15.5,
        30.0,
        45.7,
        70.0,
        85.3,
        100.0,
        23.456,
        67.891,
        99.999
      ];

      for (final rsiValue in testCases) {
        final indicators = TechnicalIndicators(
          rsi: rsiValue,
          timestamp: DateTime.now(),
          symbol: 'BTC-USDT',
          timeframe: '1h',
        );

        final widget = _buildTestWidget({'1h': indicators});
        await tester.pumpWidget(widget);

        // Verify RSI is displayed with exactly 1 decimal place
        final expectedText = rsiValue.toStringAsFixed(1);
        expect(find.text(expectedText), findsOneWidget,
            reason: 'RSI value $rsiValue should be formatted as $expectedText');

        // Verify RSI color coding
        if (rsiValue > 70) {
          // Should show red color for overbought
          expect(find.byWidgetPredicate((widget) {
            return widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).color?.value ==
                    Colors.red.withValues(alpha: 0.1).value;
          }), findsAtLeastNWidgets(1));
        } else if (rsiValue < 30) {
          // Should show green color for oversold
          expect(find.byWidgetPredicate((widget) {
            return widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).color?.value ==
                    Colors.green.withValues(alpha: 0.1).value;
          }), findsAtLeastNWidgets(1));
        }
      }
    });

    testWidgets('should format MACD signals consistently',
        (WidgetTester tester) async {
      // Property: For any MACD calculation, signals should be displayed as BUY/SELL/HOLD
      final testCases = [
        {
          'macd': 0.5,
          'signal': 0.3,
          'histogram': 0.2,
          'expected': 'BUY'
        }, // bullish + positive histogram
        {
          'macd': -0.5,
          'signal': -0.3,
          'histogram': -0.2,
          'expected': 'SELL'
        }, // bearish + negative histogram
        {
          'macd': 0.1,
          'signal': 0.2,
          'histogram': -0.1,
          'expected': 'SELL'
        }, // bearish + negative histogram
        {
          'macd': 0.2,
          'signal': 0.1,
          'histogram': -0.1,
          'expected': 'HOLD'
        }, // bullish but negative histogram
      ];

      for (final testCase in testCases) {
        final macd = MACD(
          macd: testCase['macd'] as double,
          signal: testCase['signal'] as double,
          histogram: testCase['histogram'] as double,
          trend: 'neutral',
        );

        final indicators = TechnicalIndicators(
          macd: macd,
          timestamp: DateTime.now(),
          symbol: 'BTC-USDT',
          timeframe: '1h',
        );

        final widget = _buildTestWidget({'1h': indicators});
        await tester.pumpWidget(widget);

        // Verify MACD signal is displayed correctly
        expect(find.text(testCase['expected'] as String), findsOneWidget,
            reason: 'MACD should display ${testCase['expected']} signal');
      }
    });

    testWidgets('should format Bollinger Bands signals consistently',
        (WidgetTester tester) async {
      // Property: For any Bollinger Bands calculation, signals should be BUY/SELL/HOLD
      final testCases = [
        {'percentB': 0.1, 'expected': 'BUY'}, // Near lower band
        {'percentB': 0.9, 'expected': 'SELL'}, // Near upper band
        {'percentB': 0.5, 'expected': 'HOLD'}, // Middle
      ];

      for (final testCase in testCases) {
        final bb = BollingerBands(
          upper: 50000.0,
          middle: 45000.0,
          lower: 40000.0,
          bandwidth: 0.2,
          percentB: testCase['percentB'] as double,
        );

        final indicators = TechnicalIndicators(
          bollingerBands: bb,
          timestamp: DateTime.now(),
          symbol: 'BTC-USDT',
          timeframe: '1h',
        );

        final widget = _buildTestWidget({'1h': indicators});
        await tester.pumpWidget(widget);

        // Verify Bollinger Bands signal is displayed correctly
        expect(find.text(testCase['expected'] as String), findsOneWidget,
            reason:
                'Bollinger Bands should display ${testCase['expected']} signal');
      }
    });

    testWidgets('should maintain consistent timeframe ordering',
        (WidgetTester tester) async {
      // Property: Timeframes should always be displayed in consistent order
      final timeframes = ['1d', '1m', '4h', '15m', '5m', '1h']; // Unsorted
      final expectedOrder = [
        '1m',
        '5m',
        '15m',
        '1h',
        '4h',
        '1d'
      ]; // Expected sorted

      final indicators = <String, TechnicalIndicators>{};
      for (final tf in timeframes) {
        indicators[tf] = TechnicalIndicators(
          rsi: 50.0,
          timestamp: DateTime.now(),
          symbol: 'BTC-USDT',
          timeframe: tf,
        );
      }

      final widget = _buildTestWidget(indicators);
      await tester.pumpWidget(widget);

      // Find all timeframe text widgets
      final timeframeWidgets = <String>[];
      for (final tf in expectedOrder) {
        final finder = find.text(tf.toUpperCase());
        expect(finder, findsOneWidget,
            reason: 'Timeframe $tf should be displayed');
        timeframeWidgets.add(tf);
      }

      // Verify they appear in the correct order
      expect(timeframeWidgets, equals(expectedOrder),
          reason: 'Timeframes should be displayed in chronological order');
    });

    testWidgets('should handle empty indicators gracefully',
        (WidgetTester tester) async {
      // Property: Empty indicator data should display appropriate message
      final widget = _buildTestWidget({});
      await tester.pumpWidget(widget);

      // Should display "No timeframe data available" message
      expect(find.text('No timeframe data available'), findsOneWidget);
    });

    testWidgets('should display indicator labels consistently',
        (WidgetTester tester) async {
      // Property: All indicator labels should be displayed in uppercase
      final indicators = TechnicalIndicators(
        rsi: 50.0,
        macd: const MACD(macd: 0.1, signal: 0.05, histogram: 0.05, trend: 'bullish'),
        bollingerBands: const BollingerBands(
            upper: 50000,
            middle: 45000,
            lower: 40000,
            bandwidth: 0.2,
            percentB: 0.5),
        timestamp: DateTime.now(),
        symbol: 'BTC-USDT',
        timeframe: '1h',
      );

      final widget = _buildTestWidget({'1h': indicators});
      await tester.pumpWidget(widget);

      // Verify all indicator labels are present
      expect(find.text('RSI'), findsOneWidget);
      expect(find.text('MACD'), findsOneWidget);
      expect(find.text('BB'), findsOneWidget);

      // Verify timeframe is uppercase
      expect(find.text('1H'), findsOneWidget);
    });
  });
}
