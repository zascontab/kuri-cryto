import 'package:test/test.dart';
import 'package:kuri_crypto/models/risk_state.dart';

void main() {
  group('RiskState Model', () {
    final testTimestamp = DateTime.parse('2025-11-16T10:30:00Z');

    test('should create RiskState with all fields', () {
      final riskState = RiskState(
        currentDrawdownDaily: 2.5,
        currentDrawdownWeekly: 5.0,
        currentDrawdownMonthly: 8.5,
        totalExposure: 45.50,
        exposureBySymbol: {
          'DOGE-USDT': 25.00,
          'BTC-USDT': 20.50,
        },
        consecutiveLosses: 1,
        riskMode: 'Normal',
        killSwitchActive: false,
        lastUpdate: testTimestamp,
      );

      expect(riskState.currentDrawdownDaily, 2.5);
      expect(riskState.currentDrawdownWeekly, 5.0);
      expect(riskState.currentDrawdownMonthly, 8.5);
      expect(riskState.totalExposure, 45.50);
      expect(riskState.exposureBySymbol['DOGE-USDT'], 25.00);
      expect(riskState.consecutiveLosses, 1);
      expect(riskState.riskMode, 'Normal');
      expect(riskState.killSwitchActive, false);
    });

    test('should parse RiskState from JSON', () {
      final json = {
        'current_drawdown_daily': 2.5,
        'current_drawdown_weekly': 5.0,
        'current_drawdown_monthly': 8.5,
        'total_exposure': 45.50,
        'exposure_by_symbol': {
          'DOGE-USDT': 25.00,
          'BTC-USDT': 20.50,
        },
        'consecutive_losses': 1,
        'risk_mode': 'Normal',
        'kill_switch_active': false,
        'last_update': '2025-11-16T10:30:00Z',
      };

      final riskState = RiskState.fromJson(json);

      expect(riskState.currentDrawdownDaily, 2.5);
      expect(riskState.currentDrawdownWeekly, 5.0);
      expect(riskState.totalExposure, 45.50);
      expect(riskState.exposureBySymbol['DOGE-USDT'], 25.00);
      expect(riskState.riskMode, 'Normal');
      expect(riskState.killSwitchActive, false);
    });

    test('should convert RiskState to JSON', () {
      final riskState = RiskState(
        currentDrawdownDaily: 2.5,
        currentDrawdownWeekly: 5.0,
        currentDrawdownMonthly: 8.5,
        totalExposure: 45.50,
        exposureBySymbol: {
          'DOGE-USDT': 25.00,
          'BTC-USDT': 20.50,
        },
        consecutiveLosses: 1,
        riskMode: 'Normal',
        killSwitchActive: false,
        lastUpdate: testTimestamp,
      );

      final json = riskState.toJson();

      expect(json['current_drawdown_daily'], 2.5);
      expect(json['total_exposure'], 45.50);
      expect(json['exposure_by_symbol']['DOGE-USDT'], 25.00);
      expect(json['risk_mode'], 'Normal');
      expect(json['kill_switch_active'], false);
    });

    test('should check if system is in high risk state', () {
      // Normal risk (50% of limits)
      final normalRisk = RiskState(
        currentDrawdownDaily: 2.5,
        totalExposure: 50.0,
        consecutiveLosses: 1,
        lastUpdate: testTimestamp,
        maxDailyDrawdown: 5.0,
        maxTotalExposure: 100.0,
        maxConsecutiveLosses: 3,
      );

      // High risk (85% of daily drawdown limit)
      final highRisk = RiskState(
        currentDrawdownDaily: 4.25,
        totalExposure: 50.0,
        consecutiveLosses: 1,
        lastUpdate: testTimestamp,
        maxDailyDrawdown: 5.0,
        maxTotalExposure: 100.0,
        maxConsecutiveLosses: 3,
      );

      expect(normalRisk.isHighRisk(), false);
      expect(highRisk.isHighRisk(), true);
    });

    test('should check if trading is allowed', () {
      // Can trade
      final canTrade = RiskState(
        currentDrawdownDaily: 2.5,
        totalExposure: 50.0,
        consecutiveLosses: 1,
        killSwitchActive: false,
        lastUpdate: testTimestamp,
        maxDailyDrawdown: 5.0,
        maxTotalExposure: 100.0,
        maxConsecutiveLosses: 3,
      );

      // Kill switch active
      final killSwitch = canTrade.copyWith(killSwitchActive: true);

      // Daily drawdown exceeded
      final drawdownExceeded = canTrade.copyWith(currentDrawdownDaily: -5.5);

      // Too many consecutive losses
      final tooManyLosses = canTrade.copyWith(consecutiveLosses: 3);

      // Exposure exceeded
      final exposureExceeded = canTrade.copyWith(totalExposure: 100.0);

      expect(canTrade.canTrade(), true);
      expect(killSwitch.canTrade(), false);
      expect(drawdownExceeded.canTrade(), false);
      expect(tooManyLosses.canTrade(), false);
      expect(exposureExceeded.canTrade(), false);
    });

    test('should calculate risk level percentage', () {
      final riskState = RiskState(
        currentDrawdownDaily: 4.0,
        totalExposure: 50.0,
        consecutiveLosses: 2,
        lastUpdate: testTimestamp,
        maxDailyDrawdown: 5.0,
        maxTotalExposure: 100.0,
        maxConsecutiveLosses: 3,
      );

      // Highest risk: daily drawdown = 4/5 = 80%
      expect(riskState.getRiskLevel(), 80.0);
    });

    test('should calculate available exposure', () {
      final riskState = RiskState(
        totalExposure: 35.50,
        lastUpdate: testTimestamp,
        maxTotalExposure: 100.0,
      );

      expect(riskState.getAvailableExposure(), 64.50);
    });

    test('should calculate exposure percentage', () {
      final riskState = RiskState(
        totalExposure: 35.50,
        lastUpdate: testTimestamp,
        maxTotalExposure: 100.0,
      );

      expect(riskState.getExposurePercentage(), 35.5);
    });

    test('should create copy with modified fields', () {
      final original = RiskState(
        currentDrawdownDaily: 2.5,
        totalExposure: 50.0,
        killSwitchActive: false,
        lastUpdate: testTimestamp,
      );

      final copy = original.copyWith(
        currentDrawdownDaily: 3.5,
        killSwitchActive: true,
      );

      expect(copy.currentDrawdownDaily, 3.5);
      expect(copy.killSwitchActive, true);
      expect(copy.totalExposure, original.totalExposure);
    });

    test('should handle empty exposure map', () {
      final riskState = RiskState(
        exposureBySymbol: {},
        lastUpdate: testTimestamp,
      );

      expect(riskState.exposureBySymbol, isEmpty);
    });

    test('should handle string numbers in exposure map', () {
      final json = {
        'total_exposure': '45.50',
        'exposure_by_symbol': {
          'DOGE-USDT': '25.00',
          'BTC-USDT': 20.50,
        },
        'consecutive_losses': '1',
        'last_update': '2025-11-16T10:30:00Z',
      };

      final riskState = RiskState.fromJson(json);

      expect(riskState.totalExposure, 45.50);
      expect(riskState.exposureBySymbol['DOGE-USDT'], 25.00);
      expect(riskState.exposureBySymbol['BTC-USDT'], 20.50);
      expect(riskState.consecutiveLosses, 1);
    });

    test('should handle negative drawdowns', () {
      final riskState = RiskState(
        currentDrawdownDaily: -4.0,
        currentDrawdownWeekly: -7.0,
        currentDrawdownMonthly: -10.0,
        lastUpdate: testTimestamp,
        maxDailyDrawdown: 5.0,
        maxWeeklyDrawdown: 10.0,
        maxMonthlyDrawdown: 15.0,
      );

      // Should use absolute values
      expect(riskState.isHighRisk(), true);
    });

    test('should handle custom limits', () {
      final riskState = RiskState(
        currentDrawdownDaily: 8.0,
        totalExposure: 150.0,
        consecutiveLosses: 5,
        lastUpdate: testTimestamp,
        maxDailyDrawdown: 10.0,
        maxTotalExposure: 200.0,
        maxConsecutiveLosses: 5,
      );

      // Daily drawdown: 8/10 = 80% (high risk)
      expect(riskState.isHighRisk(), true);

      // But can still trade (not exceeded)
      expect(riskState.canTrade(), true);
    });

    test('should handle different risk modes', () {
      final conservative = RiskState(
        riskMode: 'Conservative',
        lastUpdate: testTimestamp,
      );

      final aggressive = RiskState(
        riskMode: 'Aggressive',
        lastUpdate: testTimestamp,
      );

      final controlledCrazy = RiskState(
        riskMode: 'ControlledCrazy',
        lastUpdate: testTimestamp,
      );

      expect(conservative.riskMode, 'Conservative');
      expect(aggressive.riskMode, 'Aggressive');
      expect(controlledCrazy.riskMode, 'ControlledCrazy');
    });

    test('should clamp risk level to 0-100 range', () {
      final overLimit = RiskState(
        currentDrawdownDaily: 10.0,
        lastUpdate: testTimestamp,
        maxDailyDrawdown: 5.0,
      );

      final underLimit = RiskState(
        currentDrawdownDaily: 0.0,
        lastUpdate: testTimestamp,
        maxDailyDrawdown: 5.0,
      );

      expect(overLimit.getRiskLevel(), lessThanOrEqualTo(100.0));
      expect(underLimit.getRiskLevel(), greaterThanOrEqualTo(0.0));
    });
  });
}
