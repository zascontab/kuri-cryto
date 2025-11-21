import 'package:test/test.dart';
import '../../lib/models/strategy.dart';

void main() {
  group('StrategyPerformance Model', () {
    test('should create StrategyPerformance with all fields', () {
      final performance = StrategyPerformance(
        totalTrades: 50,
        winningTrades: 32,
        losingTrades: 18,
        winRate: 64.0,
        totalPnl: 125.50,
        avgWin: 5.5,
        avgLoss: -2.2,
        sharpeRatio: 1.8,
        maxDrawdown: -8.5,
        profitFactor: 2.5,
      );

      expect(performance.totalTrades, 50);
      expect(performance.winningTrades, 32);
      expect(performance.losingTrades, 18);
      expect(performance.winRate, 64.0);
      expect(performance.totalPnl, 125.50);
      expect(performance.avgWin, 5.5);
      expect(performance.avgLoss, -2.2);
      expect(performance.sharpeRatio, 1.8);
      expect(performance.maxDrawdown, -8.5);
      expect(performance.profitFactor, 2.5);
    });

    test('should parse StrategyPerformance from JSON', () {
      final json = {
        'total_trades': 50,
        'winning_trades': 32,
        'losing_trades': 18,
        'win_rate': 64.0,
        'total_pnl': 125.50,
        'avg_win': 5.5,
        'avg_loss': -2.2,
        'sharpe_ratio': 1.8,
        'max_drawdown': -8.5,
        'profit_factor': 2.5,
      };

      final performance = StrategyPerformance.fromJson(json);

      expect(performance.totalTrades, 50);
      expect(performance.winRate, 64.0);
      expect(performance.totalPnl, 125.50);
      expect(performance.sharpeRatio, 1.8);
    });

    test('should convert StrategyPerformance to JSON', () {
      final performance = StrategyPerformance(
        totalTrades: 50,
        winRate: 64.0,
        totalPnl: 125.50,
        sharpeRatio: 1.8,
      );

      final json = performance.toJson();

      expect(json['total_trades'], 50);
      expect(json['win_rate'], 64.0);
      expect(json['total_pnl'], 125.50);
      expect(json['sharpe_ratio'], 1.8);
    });

    test('should handle string numbers in JSON', () {
      final json = {
        'total_trades': '50',
        'win_rate': '64.0',
        'total_pnl': '125.50',
      };

      final performance = StrategyPerformance.fromJson(json);

      expect(performance.totalTrades, 50);
      expect(performance.winRate, 64.0);
      expect(performance.totalPnl, 125.50);
    });
  });

  group('Strategy Model', () {
    test('should create Strategy with all fields', () {
      final performance = StrategyPerformance(
        totalTrades: 50,
        winRate: 64.0,
        totalPnl: 125.50,
        sharpeRatio: 1.8,
      );

      final strategy = Strategy(
        name: 'rsi_scalping',
        active: true,
        weight: 0.25,
        performance: performance,
      );

      expect(strategy.name, 'rsi_scalping');
      expect(strategy.active, true);
      expect(strategy.weight, 0.25);
      expect(strategy.performance, performance);
    });

    test('should parse Strategy from JSON', () {
      final json = {
        'name': 'rsi_scalping',
        'active': true,
        'weight': 0.25,
        'performance': {
          'total_trades': 50,
          'win_rate': 65.0,
          'total_pnl': 45.50,
          'sharpe_ratio': 1.8,
        },
      };

      final strategy = Strategy.fromJson(json);

      expect(strategy.name, 'rsi_scalping');
      expect(strategy.active, true);
      expect(strategy.weight, 0.25);
      expect(strategy.performance.totalTrades, 50);
      expect(strategy.performance.winRate, 65.0);
      expect(strategy.performance.totalPnl, 45.50);
    });

    test('should handle missing performance in JSON', () {
      final json = {
        'name': 'test_strategy',
        'active': false,
        'weight': 0.1,
      };

      final strategy = Strategy.fromJson(json);

      expect(strategy.name, 'test_strategy');
      expect(strategy.performance.totalTrades, 0);
      expect(strategy.performance.winRate, 0.0);
    });

    test('should convert Strategy to JSON', () {
      final performance = StrategyPerformance(
        totalTrades: 50,
        winRate: 65.0,
        totalPnl: 45.50,
      );

      final strategy = Strategy(
        name: 'rsi_scalping',
        active: true,
        weight: 0.25,
        performance: performance,
      );

      final json = strategy.toJson();

      expect(json['name'], 'rsi_scalping');
      expect(json['active'], true);
      expect(json['weight'], 0.25);
      expect(json['performance']['total_trades'], 50);
      expect(json['performance']['win_rate'], 65.0);
      expect(json['performance']['total_pnl'], 45.50);
    });

    test('should create copy with modified fields', () {
      final performance = StrategyPerformance(
        totalTrades: 50,
        winRate: 65.0,
        totalPnl: 45.50,
      );

      final original = Strategy(
        name: 'rsi_scalping',
        active: true,
        weight: 0.25,
        performance: performance,
      );

      final copy = original.copyWith(
        active: false,
        weight: 0.5,
      );

      expect(copy.name, original.name);
      expect(copy.active, false);
      expect(copy.weight, 0.5);
      expect(copy.performance, original.performance);
    });

    test('should check if strategy is performing well', () {
      final goodPerformance = StrategyPerformance(
        totalTrades: 50,
        winRate: 65.0,
        totalPnl: 45.50,
      );

      final badPerformance = StrategyPerformance(
        totalTrades: 50,
        winRate: 40.0,
        totalPnl: -20.0,
      );

      final goodStrategy = Strategy(
        name: 'good',
        active: true,
        weight: 0.25,
        performance: goodPerformance,
      );

      final badStrategy = Strategy(
        name: 'bad',
        active: true,
        weight: 0.25,
        performance: badPerformance,
      );

      expect(goodStrategy.isPerformingWell, true);
      expect(badStrategy.isPerformingWell, false);
    });

    test('should check if strategy has sufficient data', () {
      final withData = Strategy(
        name: 'test',
        active: true,
        weight: 0.25,
        performance: StrategyPerformance(totalTrades: 50),
      );

      final withoutData = Strategy(
        name: 'test',
        active: true,
        weight: 0.25,
        performance: StrategyPerformance(totalTrades: 5),
      );

      expect(withData.hasSufficientData, true);
      expect(withoutData.hasSufficientData, false);
    });

    test('should handle config field', () {
      final config = {
        'rsi_period': 14,
        'rsi_oversold': 30,
        'rsi_overbought': 70,
      };

      final strategy = Strategy(
        name: 'rsi_scalping',
        active: true,
        weight: 0.25,
        performance: const StrategyPerformance(),
        config: config,
      );

      expect(strategy.config, config);
      expect(strategy.config!['rsi_period'], 14);
    });

    test('should handle equality correctly', () {
      final performance = StrategyPerformance(
        totalTrades: 50,
        winRate: 65.0,
        totalPnl: 45.50,
      );

      final strategy1 = Strategy(
        name: 'rsi_scalping',
        active: true,
        weight: 0.25,
        performance: performance,
      );

      final strategy2 = Strategy(
        name: 'rsi_scalping',
        active: true,
        weight: 0.25,
        performance: performance,
      );

      final strategy3 = strategy1.copyWith(active: false);

      expect(strategy1, equals(strategy2));
      expect(strategy1, isNot(equals(strategy3)));
    });
  });
}
