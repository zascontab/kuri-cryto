import 'package:flutter_test/flutter_test.dart';
import 'package:kuri_crypto/models/ai_bot_status.dart';
import 'package:kuri_crypto/models/ai_bot_config.dart';

void main() {
  group('AiBotStatus', () {
    test('fromJson with all fields', () {
      final json = {
        'running': true,
        'paused': false,
        'emergency_stop': false,
        'uptime_seconds': 3600,
        'analysis_count': 100,
        'execution_count': 25,
        'error_count': 2,
        'consecutive_errors': 0,
        'daily_loss': -50.0,
        'daily_trades': 10,
        'open_positions': 3,
        'config': {
          'dry_run': false,
          'auto_execute': true,
          'confidence_threshold': 0.7,
          'trade_size_usd': 100.0,
          'leverage': 10,
          'max_daily_loss_usd': 500.0,
          'max_daily_trades': 50,
        },
      };

      final status = AiBotStatus.fromJson(json);

      expect(status.running, true);
      expect(status.uptimeSeconds, 3600);
      expect(status.analysisCount, 100);
      expect(status.executionCount, 25);
      expect(status.errorCount, 2);
    });

    test('computed properties - uptime', () {
      const status = AiBotStatus(
        running: true,
        paused: false,
        emergencyStop: false,
        uptimeSeconds: 7265, // 2h 1m 5s
        analysisCount: 0,
        executionCount: 0,
        errorCount: 0,
        consecutiveErrors: 0,
        dailyLoss: 0,
        dailyTrades: 0,
        openPositions: 0,
        config: AiBotConfig(
          pair: 'DOGE-USDT',
          exchange: 'kucoin',
          dryRun: true,
          autoExecute: false,
          confidenceThreshold: 0.7,
          tradeSizeUsd: 100,
          leverage: 10,
          maxDailyLossUsd: 500,
          maxDailyTrades: 50,
          maxConsecutiveErrors: 3,
          maxOpenPositions: 2,
        ),
      );

      expect(status.uptime.inHours, 2);
      expect(status.uptimeFormatted, '2h 1m');
    });

    test('computed properties - isHealthy', () {
      const healthyStatus = AiBotStatus(
        running: true,
        paused: false,
        emergencyStop: false,
        uptimeSeconds: 0,
        analysisCount: 100,
        executionCount: 25,
        errorCount: 2,
        consecutiveErrors: 1,
        dailyLoss: 0,
        dailyTrades: 0,
        openPositions: 0,
        config: AiBotConfig(
          pair: 'DOGE-USDT',
          exchange: 'kucoin',
          dryRun: true,
          autoExecute: false,
          confidenceThreshold: 0.7,
          tradeSizeUsd: 100,
          leverage: 10,
          maxDailyLossUsd: 500,
          maxDailyTrades: 50,
          maxConsecutiveErrors: 3,
          maxOpenPositions: 2,
        ),
      );

      expect(healthyStatus.isHealthy, true);

      final unhealthyStatus = healthyStatus.copyWith(consecutiveErrors: 3);
      expect(unhealthyStatus.isHealthy, false);
    });

    test('computed properties - hasReachedDailyLimit', () {
      const config = AiBotConfig(
        pair: 'DOGE-USDT',
        exchange: 'kucoin',
        dryRun: true,
        autoExecute: false,
        confidenceThreshold: 0.7,
        tradeSizeUsd: 100,
        leverage: 10,
        maxDailyLossUsd: 500,
        maxDailyTrades: 50,
        maxConsecutiveErrors: 3,
        maxOpenPositions: 2,
      );

      const statusWithinLimits = AiBotStatus(
        running: true,
        paused: false,
        emergencyStop: false,
        uptimeSeconds: 0,
        analysisCount: 0,
        executionCount: 0,
        errorCount: 0,
        consecutiveErrors: 0,
        dailyLoss: -100,
        dailyTrades: 10,
        openPositions: 0,
        config: config,
      );

      expect(statusWithinLimits.hasReachedDailyLimit, false);

      final statusExceededLoss = statusWithinLimits.copyWith(dailyLoss: -500);
      expect(statusExceededLoss.hasReachedDailyLimit, true);

      final statusExceededTrades = statusWithinLimits.copyWith(dailyTrades: 50);
      expect(statusExceededTrades.hasReachedDailyLimit, true);
    });

    test('success rate calculation', () {
      const status = AiBotStatus(
        running: true,
        paused: false,
        emergencyStop: false,
        uptimeSeconds: 0,
        analysisCount: 100,
        executionCount: 25,
        errorCount: 10,
        consecutiveErrors: 0,
        dailyLoss: 0,
        dailyTrades: 0,
        openPositions: 0,
        config: AiBotConfig(
          pair: 'DOGE-USDT',
          exchange: 'kucoin',
          dryRun: true,
          autoExecute: false,
          confidenceThreshold: 0.7,
          tradeSizeUsd: 100,
          leverage: 10,
          maxDailyLossUsd: 500,
          maxDailyTrades: 50,
          maxConsecutiveErrors: 3,
          maxOpenPositions: 2,
        ),
      );

      expect(status.successRate, 90.0);
    });
  });
}

extension on AiBotStatus {
  AiBotStatus copyWith({
    int? consecutiveErrors,
    double? dailyLoss,
    int? dailyTrades,
  }) {
    return AiBotStatus(
      running: running,
      paused: paused,
      emergencyStop: emergencyStop,
      startedAt: startedAt,
      lastAnalysisAt: lastAnalysisAt,
      uptimeSeconds: uptimeSeconds,
      analysisCount: analysisCount,
      executionCount: executionCount,
      errorCount: errorCount,
      consecutiveErrors: consecutiveErrors ?? this.consecutiveErrors,
      dailyLoss: dailyLoss ?? this.dailyLoss,
      dailyTrades: dailyTrades ?? this.dailyTrades,
      openPositions: openPositions,
      config: config,
    );
  }
}
