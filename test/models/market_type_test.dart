import 'package:flutter_test/flutter_test.dart';
import 'package:kuri_crypto/models/market_type.dart';

void main() {
  group('MarketType.fromString', () {
    test('converts valid lowercase strings correctly', () {
      expect(MarketType.fromString('spot'), MarketType.spot);
      expect(MarketType.fromString('futures'), MarketType.futures);
      expect(MarketType.fromString('margin'), MarketType.margin);
      expect(MarketType.fromString('options'), MarketType.options);
    });

    test('converts valid uppercase strings correctly', () {
      expect(MarketType.fromString('SPOT'), MarketType.spot);
      expect(MarketType.fromString('FUTURES'), MarketType.futures);
      expect(MarketType.fromString('MARGIN'), MarketType.margin);
      expect(MarketType.fromString('OPTIONS'), MarketType.options);
    });

    test('converts valid mixed case strings correctly', () {
      expect(MarketType.fromString('Spot'), MarketType.spot);
      expect(MarketType.fromString('FuTuReS'), MarketType.futures);
      expect(MarketType.fromString('MaRgIn'), MarketType.margin);
      expect(MarketType.fromString('OpTiOnS'), MarketType.options);
    });

    test('returns default (futures) for invalid strings', () {
      expect(MarketType.fromString('invalid'), MarketType.futures);
      expect(MarketType.fromString(''), MarketType.futures);
      expect(MarketType.fromString('unknown'), MarketType.futures);
      expect(MarketType.fromString('123'), MarketType.futures);
    });

    test('handles strings with whitespace', () {
      expect(MarketType.fromString(' spot '), MarketType.futures);
      expect(MarketType.fromString('spot '), MarketType.futures);
      expect(MarketType.fromString(' spot'), MarketType.futures);
    });
  });

  group('MarketType properties', () {
    test('value property returns correct string', () {
      expect(MarketType.spot.value, 'spot');
      expect(MarketType.futures.value, 'futures');
      expect(MarketType.margin.value, 'margin');
      expect(MarketType.options.value, 'options');
    });

    test('displayName property returns correct string', () {
      expect(MarketType.spot.displayName, 'Spot');
      expect(MarketType.futures.displayName, 'Futures');
      expect(MarketType.margin.displayName, 'Margin');
      expect(MarketType.options.displayName, 'Options');
    });

    test('icon property returns correct emoji', () {
      expect(MarketType.spot.icon, '💰');
      expect(MarketType.futures.icon, '📈');
      expect(MarketType.margin.icon, '⚡');
      expect(MarketType.options.icon, '🎯');
    });

    test('description property returns non-empty string', () {
      expect(MarketType.spot.description.isNotEmpty, true);
      expect(MarketType.futures.description.isNotEmpty, true);
      expect(MarketType.margin.description.isNotEmpty, true);
      expect(MarketType.options.description.isNotEmpty, true);
    });
  });

  group('MarketType.maxLeverage', () {
    test('returns correct max leverage for each type', () {
      expect(MarketType.spot.maxLeverage, 1);
      expect(MarketType.futures.maxLeverage, 100);
      expect(MarketType.margin.maxLeverage, 10);
      expect(MarketType.options.maxLeverage, 1);
    });

    test('max leverage is always greater than or equal to min leverage', () {
      for (final type in MarketType.values) {
        expect(type.maxLeverage >= type.minLeverage, true,
            reason: '${type.displayName} maxLeverage should be >= minLeverage');
      }
    });

    test('max leverage is a positive integer', () {
      for (final type in MarketType.values) {
        expect(type.maxLeverage > 0, true,
            reason: '${type.displayName} maxLeverage should be positive');
      }
    });
  });

  group('MarketType.minLeverage', () {
    test('returns 1 for all market types', () {
      expect(MarketType.spot.minLeverage, 1);
      expect(MarketType.futures.minLeverage, 1);
      expect(MarketType.margin.minLeverage, 1);
      expect(MarketType.options.minLeverage, 1);
    });
  });

  group('MarketType.allowsLeverage', () {
    test('returns false only for spot', () {
      expect(MarketType.spot.allowsLeverage, false);
      expect(MarketType.futures.allowsLeverage, true);
      expect(MarketType.margin.allowsLeverage, true);
      expect(MarketType.options.allowsLeverage, true);
    });

    test('spot is the only type that does not allow leverage', () {
      final nonSpotTypes =
          MarketType.values.where((type) => type != MarketType.spot);
      for (final type in nonSpotTypes) {
        expect(type.allowsLeverage, true,
            reason: '${type.displayName} should allow leverage');
      }
    });
  });
}
