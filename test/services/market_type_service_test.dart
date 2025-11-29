import 'package:flutter_test/flutter_test.dart';
import 'package:kuri_crypto/models/market_type.dart';
import 'package:kuri_crypto/services/market_type_service.dart';
import 'package:dio/dio.dart';

void main() {
  group('MarketTypeService.validateLeverage', () {
    late MarketTypeService service;

    setUp(() {
      service = MarketTypeService(Dio());
    });

    test('validates spot leverage correctly', () {
      expect(service.validateLeverage(MarketType.spot, 1.0), true);
      expect(service.validateLeverage(MarketType.spot, 2.0), false);
      expect(service.validateLeverage(MarketType.spot, 5.0), false);
    });

    test('validates futures leverage correctly', () {
      expect(service.validateLeverage(MarketType.futures, 1.0), true);
      expect(service.validateLeverage(MarketType.futures, 50.0), true);
      expect(service.validateLeverage(MarketType.futures, 100.0), true);
      expect(service.validateLeverage(MarketType.futures, 101.0), false);
      expect(service.validateLeverage(MarketType.futures, 0.5), false);
    });

    test('validates margin leverage correctly', () {
      expect(service.validateLeverage(MarketType.margin, 1.0), true);
      expect(service.validateLeverage(MarketType.margin, 5.0), true);
      expect(service.validateLeverage(MarketType.margin, 10.0), true);
      expect(service.validateLeverage(MarketType.margin, 11.0), false);
      expect(service.validateLeverage(MarketType.margin, 0.5), false);
    });

    test('validates options leverage correctly', () {
      expect(service.validateLeverage(MarketType.options, 1.0), true);
      expect(service.validateLeverage(MarketType.options, 2.0), false);
    });
  });

  group('MarketTypeService.getLeverageRange', () {
    late MarketTypeService service;

    setUp(() {
      service = MarketTypeService(Dio());
    });

    test('returns correct range for spot', () {
      final range = service.getLeverageRange(MarketType.spot);
      expect(range['min'], 1);
      expect(range['max'], 1);
    });

    test('returns correct range for futures', () {
      final range = service.getLeverageRange(MarketType.futures);
      expect(range['min'], 1);
      expect(range['max'], 100);
    });

    test('returns correct range for margin', () {
      final range = service.getLeverageRange(MarketType.margin);
      expect(range['min'], 1);
      expect(range['max'], 10);
    });

    test('returns correct range for options', () {
      final range = service.getLeverageRange(MarketType.options);
      expect(range['min'], 1);
      expect(range['max'], 1);
    });

    test('min is always less than or equal to max', () {
      for (final type in MarketType.values) {
        final range = service.getLeverageRange(type);
        expect(range['min']! <= range['max']!, true,
            reason: '${type.displayName} min should be <= max');
      }
    });
  });
}
