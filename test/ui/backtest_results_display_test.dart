import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:kuri_crypto/screens/backtest_results_screen.dart';
import 'package:kuri_crypto/models/mcp_backtest_models.dart';

/// Property-based test for backtest results display
///
/// **Feature: backend-integration-update, Property 32: Backtest Results Display**
///
/// For any completed backtest, the system should display comprehensive results
/// including ROI, Sharpe ratio, and other key metrics
///
/// **Validates: Requirements 7.2**

Widget _buildTestWidget(BacktestResult result) {
  return MaterialApp(
    home: BacktestResultsScreen(
      backtestId: 'test-backtest-001',
      initialResult: result,
    ),
  );
}

BacktestTrade _createTestTrade({
  required String id,
  required double pnl,
  required double pnlPercent,
  String symbol = 'BTC-USDT',
  String side = 'buy',
}) {
  return BacktestTrade(
    id: id,
    symbol: symbol,
    side: side,
    entryPrice: 50000.0,
    exitPrice: 50000.0 + (pnl * 100), // Approximate exit price
    size: 0.1,
    entryTime: DateTime.now().subtract(const Duration(hours: 2)),
    exitTime: DateTime.now(),
    pnl: pnl,
    pnlPercent: pnlPercent,
  );
}

void main() {
  group('Property 32: Backtest Results Display', () {
    testWidgets('should display ROI correctly for profitable backtests',
        (WidgetTester tester) async {
      // Property: For any profitable backtest, ROI should be displayed as positive percentage
      final profitableResults = [
        BacktestResult(
          roi: 15.5,
          sharpeRatio: 1.2,
          maxDrawdown: 8.5,
          totalTrades: 50,
          winRate: 65.0,
          profitFactor: 1.8,
          trades: [
            _createTestTrade(id: '1', pnl: 100, pnlPercent: 2.0),
            _createTestTrade(id: '2', pnl: 200, pnlPercent: 4.0),
          ],
        ),
        BacktestResult(
          roi: 45.2,
          sharpeRatio: 2.1,
          maxDrawdown: 12.3,
          totalTrades: 100,
          winRate: 72.0,
          profitFactor: 2.5,
          trades: [
            _createTestTrade(id: '1', pnl: 500, pnlPercent: 10.0),
          ],
        ),
      ];

      for (final result in profitableResults) {
        final widget = _buildTestWidget(result);
        await tester.pumpWidget(widget);

        // Should display ROI as positive percentage
        expect(find.text('${result.roi.toStringAsFixed(2)}%'),
            findsAtLeastNWidgets(1),
            reason: 'ROI ${result.roi}% should be displayed');

        // Should show green color for positive ROI
        expect(find.byWidgetPredicate((widget) {
          return widget is Text &&
              widget.data == '${result.roi.toStringAsFixed(2)}%' &&
              widget.style?.color == Colors.green;
        }), findsAtLeastNWidgets(1));
      }
    });

    testWidgets('should display ROI correctly for losing backtests',
        (WidgetTester tester) async {
      // Property: For any losing backtest, ROI should be displayed as negative percentage
      final losingResults = [
        BacktestResult(
          roi: -12.5,
          sharpeRatio: -0.5,
          maxDrawdown: 25.0,
          totalTrades: 30,
          winRate: 35.0,
          profitFactor: 0.7,
          trades: [
            _createTestTrade(id: '1', pnl: -100, pnlPercent: -2.0),
            _createTestTrade(id: '2', pnl: -200, pnlPercent: -4.0),
          ],
        ),
      ];

      for (final result in losingResults) {
        final widget = _buildTestWidget(result);
        await tester.pumpWidget(widget);

        // Should display ROI as negative percentage
        expect(find.text('${result.roi.toStringAsFixed(2)}%'),
            findsAtLeastNWidgets(1),
            reason: 'ROI ${result.roi}% should be displayed');

        // Should show red color for negative ROI
        expect(find.byWidgetPredicate((widget) {
          return widget is Text &&
              widget.data == '${result.roi.toStringAsFixed(2)}%' &&
              widget.style?.color == Colors.red;
        }), findsAtLeastNWidgets(1));
      }
    });

    testWidgets('should display Sharpe ratio with appropriate formatting',
        (WidgetTester tester) async {
      // Property: Sharpe ratio should be displayed with 2 decimal places
      final testResults = [
        const BacktestResult(
          roi: 20.0,
          sharpeRatio: 1.234567,
          maxDrawdown: 10.0,
          totalTrades: 50,
          winRate: 60.0,
          profitFactor: 1.5,
          trades: [],
        ),
        const BacktestResult(
          roi: 15.0,
          sharpeRatio: 2.987654,
          maxDrawdown: 8.0,
          totalTrades: 75,
          winRate: 70.0,
          profitFactor: 2.0,
          trades: [],
        ),
      ];

      for (final result in testResults) {
        final widget = _buildTestWidget(result);
        await tester.pumpWidget(widget);

        // Should display Sharpe ratio with 2 decimal places
        final expectedSharpe = result.sharpeRatio.toStringAsFixed(2);
        expect(find.text(expectedSharpe), findsAtLeastNWidgets(1),
            reason:
                'Sharpe ratio should be formatted to 2 decimal places: $expectedSharpe');
      }
    });

    testWidgets('should display performance grade correctly',
        (WidgetTester tester) async {
      // Property: Performance grade should be calculated and displayed based on metrics
      final gradeTestCases = [
        {
          'result': const BacktestResult(
            roi: 55.0,
            sharpeRatio: 2.2,
            maxDrawdown: 8.0,
            totalTrades: 100,
            winRate: 75.0,
            profitFactor: 3.0,
            trades: [],
          ),
          'expectedGrade': 'A',
        },
        {
          'result': const BacktestResult(
            roi: 35.0,
            sharpeRatio: 1.6,
            maxDrawdown: 12.0,
            totalTrades: 80,
            winRate: 65.0,
            profitFactor: 2.2,
            trades: [],
          ),
          'expectedGrade': 'B',
        },
        {
          'result': const BacktestResult(
            roi: -5.0,
            sharpeRatio: -0.2,
            maxDrawdown: 35.0,
            totalTrades: 20,
            winRate: 30.0,
            profitFactor: 0.5,
            trades: [],
          ),
          'expectedGrade': 'F',
        },
      ];

      for (final testCase in gradeTestCases) {
        final result = testCase['result'] as BacktestResult;
        final expectedGrade = testCase['expectedGrade'] as String;

        final widget = _buildTestWidget(result);
        await tester.pumpWidget(widget);

        // Should display the correct performance grade
        expect(find.text(expectedGrade), findsAtLeastNWidgets(1),
            reason: 'Performance grade $expectedGrade should be displayed');
      }
    });

    testWidgets('should display trade statistics correctly',
        (WidgetTester tester) async {
      // Property: Trade statistics should be calculated and displayed accurately
      final trades = [
        _createTestTrade(id: '1', pnl: 100, pnlPercent: 2.0),
        _createTestTrade(id: '2', pnl: -50, pnlPercent: -1.0),
        _createTestTrade(id: '3', pnl: 200, pnlPercent: 4.0),
        _createTestTrade(id: '4', pnl: -25, pnlPercent: -0.5),
        _createTestTrade(id: '5', pnl: 150, pnlPercent: 3.0),
      ];

      final result = BacktestResult(
        roi: 25.0,
        sharpeRatio: 1.5,
        maxDrawdown: 5.0,
        totalTrades: trades.length,
        winRate: 60.0, // 3 out of 5 trades are profitable
        profitFactor: 2.0,
        trades: trades,
      );

      final widget = _buildTestWidget(result);
      await tester.pumpWidget(widget);

      // Should display total trades
      expect(find.text(trades.length.toString()), findsAtLeastNWidgets(1),
          reason: 'Total trades count should be displayed');

      // Should display winning trades count
      final winningTrades = result.winningTrades;
      expect(find.text(winningTrades.toString()), findsAtLeastNWidgets(1),
          reason: 'Winning trades count should be displayed');

      // Should display losing trades count
      final losingTrades = result.losingTrades;
      expect(find.text(losingTrades.toString()), findsAtLeastNWidgets(1),
          reason: 'Losing trades count should be displayed');
    });

    testWidgets('should handle empty trade list gracefully',
        (WidgetTester tester) async {
      // Property: Empty trade list should not crash the display
      const result = BacktestResult(
        roi: 0.0,
        sharpeRatio: 0.0,
        maxDrawdown: 0.0,
        totalTrades: 0,
        winRate: 0.0,
        profitFactor: 0.0,
        trades: [], // Empty trades list
      );

      final widget = _buildTestWidget(result);

      // Should not throw exception
      await tester.pumpWidget(widget);

      // Should display zero values
      expect(find.text('0.00%'), findsAtLeastNWidgets(1));
      expect(find.text('0'), findsAtLeastNWidgets(1));

      // Should handle empty trades in trades tab
      await tester.tap(find.text('Trades'));
      await tester.pumpAndSettle();

      expect(find.text('No trades to display'), findsOneWidget);
    });

    testWidgets('should display risk metrics with appropriate warnings',
        (WidgetTester tester) async {
      // Property: Risk metrics should be displayed with visual indicators
      const highRiskResult = BacktestResult(
        roi: 10.0,
        sharpeRatio: 0.3,
        maxDrawdown: 35.0, // High drawdown
        totalTrades: 15, // Insufficient trades
        winRate: 45.0,
        profitFactor: 1.1,
        trades: [],
      );

      final widget = _buildTestWidget(highRiskResult);
      await tester.pumpWidget(widget);

      // Navigate to Analytics tab
      await tester.tap(find.text('Analytics'));
      await tester.pumpAndSettle();

      // Should show warning icons for poor risk metrics
      expect(find.byIcon(Icons.warning), findsAtLeastNWidgets(1),
          reason: 'Warning icons should be displayed for poor risk metrics');

      // Should display max drawdown
      expect(find.text('${highRiskResult.maxDrawdown.toStringAsFixed(2)}%'),
          findsAtLeastNWidgets(1));
    });

    testWidgets('should display viable strategy indicators correctly',
        (WidgetTester tester) async {
      // Property: Strategy viability should be clearly indicated
      const viableStrategy = BacktestResult(
        roi: 25.0,
        sharpeRatio: 1.8,
        maxDrawdown: 12.0,
        totalTrades: 50,
        winRate: 68.0,
        profitFactor: 2.2,
        trades: [],
      );

      const nonViableStrategy = BacktestResult(
        roi: 5.0,
        sharpeRatio: 0.3,
        maxDrawdown: 30.0,
        totalTrades: 10,
        winRate: 40.0,
        profitFactor: 0.8,
        trades: [],
      );

      // Test viable strategy
      final viableWidget = _buildTestWidget(viableStrategy);
      await tester.pumpWidget(viableWidget);

      expect(find.text('Viable Strategy'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.check_circle), findsAtLeastNWidgets(1));

      // Test non-viable strategy
      final nonViableWidget = _buildTestWidget(nonViableStrategy);
      await tester.pumpWidget(nonViableWidget);

      expect(find.text('Needs Improvement'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.warning), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle extreme metric values',
        (WidgetTester tester) async {
      // Property: Extreme values should be displayed without errors
      const extremeResult = BacktestResult(
        roi: 999.99,
        sharpeRatio: 10.5,
        maxDrawdown: 0.01,
        totalTrades: 1000,
        winRate: 99.9,
        profitFactor: 50.0,
        trades: [],
      );

      final widget = _buildTestWidget(extremeResult);

      // Should not throw exception with extreme values
      await tester.pumpWidget(widget);

      // Should display extreme values correctly
      expect(find.text('999.99%'), findsAtLeastNWidgets(1));
      expect(find.text('10.50'), findsAtLeastNWidgets(1));
      expect(find.text('0.01%'), findsAtLeastNWidgets(1));
    });
  });
}
