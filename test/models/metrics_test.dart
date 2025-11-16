import 'package:test/test.dart';
import '../../lib/models/metrics.dart';

void main() {
  group('Metrics Model', () {
    test('should create Metrics with all fields', () {
      final metrics = Metrics(
        totalTrades: 145,
        winningTrades: 92,
        losingTrades: 53,
        winRate: 63.4,
        totalPnl: 125.50,
        dailyPnl: 15.25,
        weeklyPnl: 45.75,
        monthlyPnl: 125.50,
        avgWin: 2.50,
        avgLoss: -1.20,
        profitFactor: 2.08,
        sharpeRatio: 1.85,
        maxDrawdown: -8.5,
        activePositions: 2,
        avgLatencyMs: 45.0,
        avgSlippagePct: 0.05,
      );

      expect(metrics.totalTrades, 145);
      expect(metrics.winningTrades, 92);
      expect(metrics.losingTrades, 53);
      expect(metrics.winRate, 63.4);
      expect(metrics.totalPnl, 125.50);
      expect(metrics.dailyPnl, 15.25);
      expect(metrics.avgLatencyMs, 45.0);
    });

    test('should parse Metrics from JSON', () {
      final json = {
        'total_trades': 145,
        'winning_trades': 92,
        'losing_trades': 53,
        'win_rate': 62.5,
        'total_pnl': 125.50,
        'daily_pnl': 15.25,
        'avg_latency_ms': 45,
        'active_positions': 2,
      };

      final metrics = Metrics.fromJson(json);

      expect(metrics.totalTrades, 145);
      expect(metrics.winRate, 62.5);
      expect(metrics.totalPnl, 125.50);
      expect(metrics.dailyPnl, 15.25);
      expect(metrics.avgLatencyMs, 45.0);
      expect(metrics.activePositions, 2);
    });

    test('should handle missing fields in JSON', () {
      final json = {
        'total_trades': 100,
        'win_rate': 60.0,
        'total_pnl': 50.0,
      };

      final metrics = Metrics.fromJson(json);

      expect(metrics.totalTrades, 100);
      expect(metrics.winRate, 60.0);
      expect(metrics.totalPnl, 50.0);
      expect(metrics.dailyPnl, 0.0);
      expect(metrics.activePositions, 0);
      expect(metrics.avgLatencyMs, 0.0);
    });

    test('should convert Metrics to JSON', () {
      final metrics = Metrics(
        totalTrades: 145,
        winRate: 62.5,
        totalPnl: 125.50,
        dailyPnl: 15.25,
        activePositions: 2,
        avgLatencyMs: 45.0,
      );

      final json = metrics.toJson();

      expect(json['total_trades'], 145);
      expect(json['win_rate'], 62.5);
      expect(json['total_pnl'], 125.50);
      expect(json['daily_pnl'], 15.25);
      expect(json['active_positions'], 2);
      expect(json['avg_latency_ms'], 45.0);
    });

    test('should check if overall performance is profitable', () {
      final profitable = Metrics(
        totalPnl: 125.50,
      );

      final unprofitable = Metrics(
        totalPnl: -50.0,
      );

      expect(profitable.isProfitable, true);
      expect(unprofitable.isProfitable, false);
    });

    test('should check if daily performance is profitable', () {
      final profitable = Metrics(
        dailyPnl: 15.25,
      );

      final unprofitable = Metrics(
        dailyPnl: -5.0,
      );

      expect(profitable.isDailyProfitable, true);
      expect(unprofitable.isDailyProfitable, false);
    });

    test('should check if performing well', () {
      final performingWell = Metrics(
        winRate: 62.5,
        totalPnl: 125.50,
      );

      final lowWinRate = Metrics(
        winRate: 40.0,
        totalPnl: 50.0,
      );

      final negative = Metrics(
        winRate: 60.0,
        totalPnl: -20.0,
      );

      expect(performingWell.isPerformingWell, true);
      expect(lowWinRate.isPerformingWell, false);
      expect(negative.isPerformingWell, false);
    });

    test('should check if execution is fast', () {
      final fast = Metrics(
        avgLatencyMs: 45.0,
      );

      final slow = Metrics(
        avgLatencyMs: 150.0,
      );

      expect(fast.hasFastExecution, true);
      expect(slow.hasFastExecution, false);
    });

    test('should calculate win/loss ratio', () {
      final metrics = Metrics(
        avgWin: 2.50,
        avgLoss: -1.20,
      );

      // 2.50 / 1.20 ≈ 2.08
      expect(metrics.winLossRatio, closeTo(2.08, 0.01));
    });

    test('should handle zero avg loss in win/loss ratio', () {
      final metrics = Metrics(
        avgWin: 2.50,
        avgLoss: 0.0,
      );

      expect(metrics.winLossRatio, 0.0);
    });

    test('should create copy with modified fields', () {
      final original = Metrics(
        totalTrades: 100,
        winRate: 60.0,
        totalPnl: 50.0,
        dailyPnl: 5.0,
      );

      final copy = original.copyWith(
        totalTrades: 150,
        dailyPnl: 10.0,
      );

      expect(copy.totalTrades, 150);
      expect(copy.dailyPnl, 10.0);
      expect(copy.winRate, original.winRate);
      expect(copy.totalPnl, original.totalPnl);
    });

    test('should handle string numbers in JSON', () {
      final json = {
        'total_trades': '145',
        'win_rate': '62.5',
        'total_pnl': '125.50',
        'avg_latency_ms': '45',
      };

      final metrics = Metrics.fromJson(json);

      expect(metrics.totalTrades, 145);
      expect(metrics.winRate, 62.5);
      expect(metrics.totalPnl, 125.50);
      expect(metrics.avgLatencyMs, 45.0);
    });

    test('should handle equality correctly', () {
      final metrics1 = Metrics(
        totalTrades: 100,
        winRate: 60.0,
        totalPnl: 50.0,
      );

      final metrics2 = Metrics(
        totalTrades: 100,
        winRate: 60.0,
        totalPnl: 50.0,
      );

      final metrics3 = metrics1.copyWith(totalPnl: 75.0);

      expect(metrics1, equals(metrics2));
      expect(metrics1, isNot(equals(metrics3)));
    });

    test('should calculate correct values from trade data', () {
      final metrics = Metrics(
        totalTrades: 100,
        winningTrades: 60,
        losingTrades: 40,
        winRate: 60.0,
        avgWin: 10.0,
        avgLoss: -5.0,
      );

      // Verify win rate matches wins/total
      expect(metrics.winRate, 60.0);
      expect(metrics.winningTrades + metrics.losingTrades, metrics.totalTrades);
      expect(metrics.winLossRatio, 2.0);
    });

    test('should handle all period P&Ls', () {
      final metrics = Metrics(
        dailyPnl: 15.25,
        weeklyPnl: 45.75,
        monthlyPnl: 125.50,
        totalPnl: 500.0,
      );

      expect(metrics.dailyPnl, 15.25);
      expect(metrics.weeklyPnl, 45.75);
      expect(metrics.monthlyPnl, 125.50);
      expect(metrics.totalPnl, 500.0);
    });

    test('should handle performance ratios', () {
      final metrics = Metrics(
        profitFactor: 2.08,
        sharpeRatio: 1.85,
        maxDrawdown: -8.5,
      );

      expect(metrics.profitFactor, 2.08);
      expect(metrics.sharpeRatio, 1.85);
      expect(metrics.maxDrawdown, -8.5);
    });

    test('should handle slippage data', () {
      final metrics = Metrics(
        avgSlippagePct: 0.05,
      );

      expect(metrics.avgSlippagePct, 0.05);
    });

    test('should handle zero values', () {
      final metrics = Metrics();

      expect(metrics.totalTrades, 0);
      expect(metrics.winRate, 0.0);
      expect(metrics.totalPnl, 0.0);
      expect(metrics.isProfitable, false);
      expect(metrics.isPerformingWell, false);
    });
  });
}
