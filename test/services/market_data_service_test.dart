import 'package:flutter_test/flutter_test.dart';
import 'package:kuri_crypto/services/market_data_service.dart';
import 'package:kuri_crypto/services/mcp_service.dart';
import 'package:kuri_crypto/models/mcp_ticker.dart';
import 'package:kuri_crypto/models/mcp_candle.dart';
import 'package:kuri_crypto/models/mcp_orderbook.dart';
import 'package:dio/dio.dart';

void main() {
  group('MarketDataService', () {
    late MarketDataService service;
    late MCPService mockMcpService;

    setUp(() {
      final mockDio = Dio();
      mockMcpService = MCPService(mockDio);
      service = MarketDataService(mockMcpService);
    });

    test('should initialize correctly', () {
      expect(service, isNotNull);
    });

    test('should have getTicker method', () {
      expect(service.getTicker, isNotNull);
    });

    test('should have getCandles method', () {
      expect(service.getCandles, isNotNull);
    });

    test('should have getOrderBook method', () {
      expect(service.getOrderBook, isNotNull);
    });

    test('should have get24hStats method', () {
      expect(service.get24hStats, isNotNull);
    });

    test('should have getMultipleTickers method', () {
      expect(service.getMultipleTickers, isNotNull);
    });

    test('should have getMarkPrice method', () {
      expect(service.getMarkPrice, isNotNull);
    });

    test('should have convenience methods', () {
      expect(service.getSpread, isNotNull);
      expect(service.getMidPrice, isNotNull);
      expect(service.isRising, isNotNull);
      expect(service.getRecentCandles, isNotNull);
      expect(service.getLiquidityAnalysis, isNotNull);
      expect(service.estimateBuySlippage, isNotNull);
      expect(service.estimateSellSlippage, isNotNull);
      expect(service.hasEnoughLiquidity, isNotNull);
    });

    test('should support ticker data flow', () {
      const sampleJson = {
        'exchange': 'kucoin',
        'pair': 'BTC-USDT',
        'last': 90000.0,
        'bid': 89990.0,
        'ask': 90010.0,
        'volume': 1234567.89,
        'high_24h': 91000.0,
        'low_24h': 89000.0,
        'change_24h': 1000.0,
      };

      final ticker = MCPTicker.fromJson(sampleJson);
      expect(ticker.exchange, equals('kucoin'));
      expect(ticker.pair, equals('BTC-USDT'));
      expect(ticker.last, equals(90000.0));
    });

    test('should support candle data flow', () {
      final sampleJson = {
        'timestamp': '2025-11-20T10:00:00Z',
        'open': 90000.0,
        'high': 91000.0,
        'low': 89500.0,
        'close': 90500.0,
        'volume': 1234.56,
      };

      final candle = MCPCandle.fromJson(sampleJson);
      expect(candle.open, equals(90000.0));
      expect(candle.close, equals(90500.0));
      expect(candle.isBullish, isTrue);
    });

    test('should support orderbook data flow', () {
      final sampleJson = {
        'bids': [
          [90000.0, 1.5],
          [89990.0, 2.0],
        ],
        'asks': [
          [90010.0, 1.0],
          [90020.0, 2.5],
        ],
        'timestamp': '2025-11-20T10:00:00Z',
      };

      final orderBook = MCPOrderBook.fromJson(sampleJson);
      expect(orderBook.bids.length, equals(2));
      expect(orderBook.asks.length, equals(2));
      expect(orderBook.bestBid?.price, equals(90000.0));
      expect(orderBook.bestAsk?.price, equals(90010.0));
    });

    test('should support list of candles', () {
      final candlesJson = [
        [1700000000, 90000.0, 91000.0, 89500.0, 90500.0, 1234.56],
        [1700001000, 90500.0, 91500.0, 90000.0, 91000.0, 2345.67],
        [1700002000, 91000.0, 91200.0, 90800.0, 90900.0, 3456.78],
      ];

      final candles =
          candlesJson.map((json) => MCPCandle.fromJson(json)).toList();

      expect(candles.length, equals(3));
      expect(candles[0].close, equals(90500.0));
      expect(candles[1].close, equals(91000.0));
      expect(candles[2].close, equals(90900.0));
      expect(candles.maxHigh, equals(91500.0));
      expect(candles.minLow, equals(89500.0));
      expect(candles.bullishCount, equals(2));
    });

    test('should support multiple tickers list', () {
      final tickersJson = [
        {
          'exchange': 'kucoin',
          'pair': 'BTC-USDT',
          'last': 90000.0,
          'bid': 89990.0,
          'ask': 90010.0,
          'volume': 1000.0,
          'high_24h': 91000.0,
          'low_24h': 89000.0,
          'change_24h': 1000.0,
        },
        {
          'exchange': 'kucoin',
          'pair': 'ETH-USDT',
          'last': 3000.0,
          'bid': 2999.0,
          'ask': 3001.0,
          'volume': 5000.0,
          'high_24h': 3100.0,
          'low_24h': 2900.0,
          'change_24h': 100.0,
        },
      ];

      final tickers =
          tickersJson.map((json) => MCPTicker.fromJson(json)).toList();

      expect(tickers.length, equals(2));
      expect(tickers[0].pair, equals('BTC-USDT'));
      expect(tickers[1].pair, equals('ETH-USDT'));
      expect(tickers[0].baseAsset, equals('BTC'));
      expect(tickers[1].baseAsset, equals('ETH'));
    });
  });
}
