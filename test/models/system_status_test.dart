import 'package:test/test.dart';
import 'package:kuri_crypto/models/system_status.dart';

void main() {
  group('SystemStatus Model', () {
    final testTimestamp = DateTime.parse('2025-11-16T10:30:00Z');

    test('should create SystemStatus with all fields', () {
      final status = SystemStatus(
        running: true,
        uptime: '2h30m15s',
        pairsCount: 3,
        activeStrategies: 5,
        healthStatus: 'healthy',
        errors: [],
        timestamp: testTimestamp,
      );

      expect(status.running, true);
      expect(status.uptime, '2h30m15s');
      expect(status.pairsCount, 3);
      expect(status.activeStrategies, 5);
      expect(status.healthStatus, 'healthy');
      expect(status.errors, isEmpty);
      expect(status.timestamp, testTimestamp);
    });

    test('should parse SystemStatus from JSON', () {
      final json = {
        'running': true,
        'uptime': '2h30m15s',
        'pairs_count': 3,
        'active_strategies': 5,
        'health_status': 'healthy',
        'errors': [],
        'timestamp': '2025-11-16T10:30:00Z',
      };

      final status = SystemStatus.fromJson(json);

      expect(status.running, true);
      expect(status.uptime, '2h30m15s');
      expect(status.pairsCount, 3);
      expect(status.activeStrategies, 5);
      expect(status.healthStatus, 'healthy');
      expect(status.errors, isEmpty);
    });

    test('should handle errors list in JSON', () {
      final json = {
        'running': false,
        'uptime': '0s',
        'pairs_count': 0,
        'active_strategies': 0,
        'health_status': 'unhealthy',
        'errors': ['Connection timeout', 'API rate limit exceeded'],
      };

      final status = SystemStatus.fromJson(json);

      expect(status.running, false);
      expect(status.healthStatus, 'unhealthy');
      expect(status.errors.length, 2);
      expect(status.errors[0], 'Connection timeout');
      expect(status.errors[1], 'API rate limit exceeded');
    });

    test('should convert SystemStatus to JSON', () {
      final status = SystemStatus(
        running: true,
        uptime: '2h30m15s',
        pairsCount: 3,
        activeStrategies: 5,
        healthStatus: 'healthy',
        errors: [],
        timestamp: testTimestamp,
      );

      final json = status.toJson();

      expect(json['running'], true);
      expect(json['uptime'], '2h30m15s');
      expect(json['pairs_count'], 3);
      expect(json['active_strategies'], 5);
      expect(json['health_status'], 'healthy');
      expect(json['errors'], isEmpty);
    });

    test('should check if system is healthy', () {
      const healthy = SystemStatus(
        healthStatus: 'healthy',
        errors: [],
      );

      const degraded = SystemStatus(
        healthStatus: 'degraded',
        errors: [],
      );

      const withErrors = SystemStatus(
        healthStatus: 'healthy',
        errors: ['Some error'],
      );

      expect(healthy.isHealthy, true);
      expect(degraded.isHealthy, false);
      expect(withErrors.isHealthy, false);
    });

    test('should check if system has errors', () {
      const noErrors = SystemStatus(
        errors: [],
      );

      const hasErrors = SystemStatus(
        errors: ['Error 1', 'Error 2'],
      );

      expect(noErrors.hasErrors, false);
      expect(hasErrors.hasErrors, true);
    });

    test('should check if system is operational', () {
      const operational = SystemStatus(
        running: true,
        healthStatus: 'healthy',
        errors: [],
      );

      final notRunning = operational.copyWith(running: false);
      final unhealthy = operational.copyWith(healthStatus: 'unhealthy');

      expect(operational.isOperational, true);
      expect(notRunning.isOperational, false);
      expect(unhealthy.isOperational, false);
    });

    test('should parse uptime to seconds', () {
      const status1 = SystemStatus(uptime: '2h30m15s');
      const status2 = SystemStatus(uptime: '1h');
      const status3 = SystemStatus(uptime: '45m');
      const status4 = SystemStatus(uptime: '30s');
      const status5 = SystemStatus(uptime: '1h5m30s');

      expect(status1.uptimeSeconds, 2 * 3600 + 30 * 60 + 15);
      expect(status2.uptimeSeconds, 3600);
      expect(status3.uptimeSeconds, 45 * 60);
      expect(status4.uptimeSeconds, 30);
      expect(status5.uptimeSeconds, 3600 + 5 * 60 + 30);
    });

    test('should get uptime as Duration', () {
      const status = SystemStatus(uptime: '2h30m15s');
      final duration = status.uptimeDuration;

      expect(duration.inHours, 2);
      expect(duration.inMinutes, 150);
      expect(duration.inSeconds, 2 * 3600 + 30 * 60 + 15);
    });

    test('should handle invalid uptime format', () {
      const status = SystemStatus(uptime: 'invalid');

      expect(status.uptimeSeconds, 0);
      expect(status.uptimeDuration, Duration.zero);
    });

    test('should create copy with modified fields', () {
      const original = SystemStatus(
        running: true,
        uptime: '2h30m',
        pairsCount: 3,
        activeStrategies: 5,
        healthStatus: 'healthy',
      );

      final copy = original.copyWith(
        running: false,
        healthStatus: 'degraded',
        errors: ['Error occurred'],
      );

      expect(copy.running, false);
      expect(copy.healthStatus, 'degraded');
      expect(copy.errors, ['Error occurred']);
      expect(copy.uptime, original.uptime);
      expect(copy.pairsCount, original.pairsCount);
    });

    test('should handle missing fields in JSON', () {
      final json = {
        'running': true,
      };

      final status = SystemStatus.fromJson(json);

      expect(status.running, true);
      expect(status.uptime, '0s');
      expect(status.pairsCount, 0);
      expect(status.activeStrategies, 0);
      expect(status.healthStatus, 'unknown');
      expect(status.errors, isEmpty);
    });

    test('should handle string numbers in JSON', () {
      final json = {
        'running': true,
        'pairs_count': '3',
        'active_strategies': '5',
      };

      final status = SystemStatus.fromJson(json);

      expect(status.pairsCount, 3);
      expect(status.activeStrategies, 5);
    });

    test('should handle equality correctly', () {
      const status1 = SystemStatus(
        running: true,
        uptime: '2h30m',
        pairsCount: 3,
        healthStatus: 'healthy',
        errors: [],
      );

      const status2 = SystemStatus(
        running: true,
        uptime: '2h30m',
        pairsCount: 3,
        healthStatus: 'healthy',
        errors: [],
      );

      final status3 = status1.copyWith(running: false);

      expect(status1, equals(status2));
      expect(status1, isNot(equals(status3)));
    });

    test('should handle different health statuses', () {
      const healthy = SystemStatus(healthStatus: 'healthy');
      const degraded = SystemStatus(healthStatus: 'degraded');
      const unhealthy = SystemStatus(healthStatus: 'unhealthy');

      expect(healthy.healthStatus, 'healthy');
      expect(degraded.healthStatus, 'degraded');
      expect(unhealthy.healthStatus, 'unhealthy');
    });

    test('should handle empty errors array', () {
      final json = {
        'running': true,
        'errors': [],
      };

      final status = SystemStatus.fromJson(json);

      expect(status.errors, isEmpty);
      expect(status.hasErrors, false);
    });

    test('should filter out null and empty errors', () {
      final json = {
        'running': true,
        'errors': ['Error 1', null, '', 'Error 2'],
      };

      final status = SystemStatus.fromJson(json);

      expect(status.errors.length, 2);
      expect(status.errors[0], 'Error 1');
      expect(status.errors[1], 'Error 2');
    });

    test('should handle uptime edge cases', () {
      const noTime = SystemStatus(uptime: '0s');
      const onlyHours = SystemStatus(uptime: '5h');
      const onlyMinutes = SystemStatus(uptime: '30m');
      const complex = SystemStatus(uptime: '12h45m30s');

      expect(noTime.uptimeSeconds, 0);
      expect(onlyHours.uptimeSeconds, 5 * 3600);
      expect(onlyMinutes.uptimeSeconds, 30 * 60);
      expect(complex.uptimeSeconds, 12 * 3600 + 45 * 60 + 30);
    });

    test('should handle timestamp parsing', () {
      final json = {
        'running': true,
        'timestamp': '2025-11-16T10:30:00Z',
      };

      final status = SystemStatus.fromJson(json);

      expect(status.timestamp, isNotNull);
      expect(status.timestamp, DateTime.parse('2025-11-16T10:30:00Z'));
    });

    test('should handle missing timestamp', () {
      final json = {
        'running': true,
      };

      final status = SystemStatus.fromJson(json);

      expect(status.timestamp, isNull);
    });
  });
}
