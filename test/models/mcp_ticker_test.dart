import 'package:flutter_test/flutter_test.dart';
import 'package:kuri_crypto/models/mcp_ticker.dart';

void main() {
  group('MCPTicker', () {
    late Map<String, dynamic> sampleJson;
    late MCPTicker sampleTicker;

    setUp(() {
      sampleJson = {
        'exchange': 'kucoin',
        'pair': 'BTC-USDT',
        'last': 90638.1,
        'bid': 90623.6,
        'ask': 90623.7,
        'volume': 1234567.89,
        'high_24h': 91000.0,
        'low_24h': 89500.0,
        'change_24h': 1138.1,
        'change_24h_percent': 1.27,
        'timestamp': '2025-11-19T10:30:00Z',
      };

      sampleTicker = MCPTicker.fromJson(sampleJson);
    });

    test('should create from JSON correctly', () {
      expect(sampleTicker.exchange, equals('kucoin'));
      expect(sampleTicker.pair, equals('BTC-USDT'));
      expect(sampleTicker.last, equals(90638.1));
      expect(sampleTicker.bid, equals(90623.6));
      expect(sampleTicker.ask, equals(90623.7));
      expect(sampleTicker.volume, equals(1234567.89));
      expect(sampleTicker.high24h, equals(91000.0));
      expect(sampleTicker.low24h, equals(89500.0));
      expect(sampleTicker.change24h, equals(1138.1));
      expect(sampleTicker.change24hPercent, equals(1.27));
      expect(sampleTicker.timestamp, isNotNull);
    });

    test('should handle missing optional fields', () {
      const minimalJson = {
        'exchange': 'kucoin',
        'pair': 'BTC-USDT',
        'last': 90638.1,
        'bid': 90623.6,
        'ask': 90623.7,
        'volume': 1234567.89,
        'high_24h': 91000.0,
        'low_24h': 89500.0,
        'change_24h': 1138.1,
      };

      final ticker = MCPTicker.fromJson(minimalJson);

      expect(ticker.change24hPercent, isNull);
      expect(ticker.timestamp, isNull);
    });

    test('should convert to JSON correctly', () {
      final json = sampleTicker.toJson();

      expect(json['exchange'], equals('kucoin'));
      expect(json['pair'], equals('BTC-USDT'));
      expect(json['last'], equals(90638.1));
      expect(json['change_24h_percent'], equals(1.27));
    });

    test('should calculate spread correctly', () {
      // spread = ask - bid = 90623.7 - 90623.6 = 0.1
      expect(sampleTicker.spread, closeTo(0.1, 0.001));
    });

    test('should calculate spread percent correctly', () {
      // spreadPercent = (spread / last) * 100
      const expected = (0.1 / 90638.1) * 100;
      expect(sampleTicker.spreadPercent, closeTo(expected, 0.0001));
    });

    test('should calculate mid price correctly', () {
      // midPrice = (bid + ask) / 2 = (90623.6 + 90623.7) / 2
      const expected = (90623.6 + 90623.7) / 2;
      expect(sampleTicker.midPrice, closeTo(expected, 0.001));
    });

    test('should detect rising price', () {
      expect(sampleTicker.isRising, isTrue);
      expect(sampleTicker.isFalling, isFalse);
    });

    test('should detect falling price', () {
      final fallingTicker = sampleTicker.copyWith(change24h: -100.0);

      expect(fallingTicker.isFalling, isTrue);
      expect(fallingTicker.isRising, isFalse);
    });

    test('should extract base asset correctly', () {
      expect(sampleTicker.baseAsset, equals('BTC'));
    });

    test('should extract quote asset correctly', () {
      expect(sampleTicker.quoteAsset, equals('USDT'));
    });

    test('should handle copyWith correctly', () {
      final newTicker = sampleTicker.copyWith(
        last: 91000.0,
        volume: 2000000.0,
      );

      expect(newTicker.last, equals(91000.0));
      expect(newTicker.volume, equals(2000000.0));
      expect(newTicker.exchange, equals(sampleTicker.exchange)); // unchanged
      expect(newTicker.pair, equals(sampleTicker.pair)); // unchanged
    });

    test('should implement toString', () {
      final str = sampleTicker.toString();

      expect(str, contains('MCPTicker'));
      expect(str, contains('kucoin'));
      expect(str, contains('BTC-USDT'));
    });

    test('should implement equality correctly', () {
      final ticker1 = MCPTicker.fromJson(sampleJson);
      final ticker2 = MCPTicker.fromJson(sampleJson);
      final ticker3 = ticker1.copyWith(last: 95000.0);

      expect(ticker1, equals(ticker2));
      expect(ticker1, isNot(equals(ticker3)));
    });

    test('should implement hashCode correctly', () {
      final ticker1 = MCPTicker.fromJson(sampleJson);
      final ticker2 = MCPTicker.fromJson(sampleJson);

      expect(ticker1.hashCode, equals(ticker2.hashCode));
    });
  });
}
