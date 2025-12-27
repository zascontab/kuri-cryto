import 'package:flutter_test/flutter_test.dart';
import 'package:kuri_crypto/services/technical_indicators_service.dart';
import 'package:kuri_crypto/services/mcp_service.dart';
import 'package:kuri_crypto/models/mcp_rsi_result.dart';
import 'package:kuri_crypto/models/mcp_macd_result.dart';
import 'package:kuri_crypto/models/mcp_bollinger_bands.dart';
import 'package:dio/dio.dart';

void main() {
  group('TechnicalIndicatorsService', () {
    late TechnicalIndicatorsService service;
    late MCPService mockMcpService;

    setUp(() {
      final mockDio = Dio();
      mockMcpService = MCPService(mockDio);
      service = TechnicalIndicatorsService(mockMcpService);
    });

    test('should initialize correctly', () {
      expect(service, isNotNull);
    });

    test('should have calculateRSI method', () {
      expect(service.calculateRSI, isNotNull);
    });

    test('should have calculateMACD method', () {
      expect(service.calculateMACD, isNotNull);
    });

    test('should have calculateBollingerBands method', () {
      expect(service.calculateBollingerBands, isNotNull);
    });

    test('should have calculateEMA method', () {
      expect(service.calculateEMA, isNotNull);
    });

    test('should have calculateSMA method', () {
      expect(service.calculateSMA, isNotNull);
    });

    test('should have calculateATR method', () {
      expect(service.calculateATR, isNotNull);
    });

    test('should have calculateStochastic method', () {
      expect(service.calculateStochastic, isNotNull);
    });

    test('should have calculateADX method', () {
      expect(service.calculateADX, isNotNull);
    });

    test('should have calculateCCI method', () {
      expect(service.calculateCCI, isNotNull);
    });

    test('should have calculateWilliamsR method', () {
      expect(service.calculateWilliamsR, isNotNull);
    });

    test('should have calculateMultipleEMAs method', () {
      expect(service.calculateMultipleEMAs, isNotNull);
    });

    test('should have getCompleteAnalysis method', () {
      expect(service.getCompleteAnalysis, isNotNull);
    });
  });

  group('MCPRSIResult', () {
    test('should create from JSON correctly', () {
      final json = {
        'rsi': 65.5,
        'timestamp': '2025-11-20T10:00:00Z',
        'pair': 'BTC-USDT',
        'exchange': 'kucoin',
        'period': 14,
      };

      final rsi = MCPRSIResult.fromJson(json);

      expect(rsi.value, equals(65.5));
      expect(rsi.pair, equals('BTC-USDT'));
      expect(rsi.exchange, equals('kucoin'));
      expect(rsi.period, equals(14));
    });

    test('should detect overbought condition', () {
      final rsi = MCPRSIResult(
        value: 75.0,
        timestamp: DateTime.now(),
      );

      expect(rsi.isOverbought, isTrue);
      expect(rsi.isOversold, isFalse);
      expect(rsi.signal, equals('SELL'));
    });

    test('should detect oversold condition', () {
      final rsi = MCPRSIResult(
        value: 25.0,
        timestamp: DateTime.now(),
      );

      expect(rsi.isOversold, isTrue);
      expect(rsi.isOverbought, isFalse);
      expect(rsi.signal, equals('BUY'));
    });

    test('should detect neutral condition', () {
      final rsi = MCPRSIResult(
        value: 50.0,
        timestamp: DateTime.now(),
      );

      expect(rsi.isNeutral, isTrue);
      expect(rsi.isNearNeutral, isTrue);
      expect(rsi.signal, equals('NEUTRAL'));
    });

    test('should calculate signal strength', () {
      final rsi1 = MCPRSIResult(value: 80.0, timestamp: DateTime.now());
      final rsi2 = MCPRSIResult(value: 60.0, timestamp: DateTime.now());

      expect(rsi1.signalStrength, equals(60.0)); // (80-50)*2
      expect(rsi2.signalStrength, equals(20.0)); // (60-50)*2
    });
  });

  group('MCPMACDResult', () {
    test('should create from JSON correctly', () {
      final json = {
        'macd': 150.5,
        'signal': 145.0,
        'histogram': 5.5,
        'timestamp': '2025-11-20T10:00:00Z',
        'pair': 'BTC-USDT',
        'exchange': 'kucoin',
      };

      final macd = MCPMACDResult.fromJson(json);

      expect(macd.macd, equals(150.5));
      expect(macd.signal, equals(145.0));
      expect(macd.histogram, equals(5.5));
      expect(macd.pair, equals('BTC-USDT'));
    });

    test('should detect bullish condition', () {
      final macd = MCPMACDResult(
        macd: 150.0,
        signal: 145.0,
        histogram: 5.0,
        timestamp: DateTime.now(),
      );

      expect(macd.isBullish, isTrue);
      expect(macd.isBearish, isFalse);
      expect(macd.hasPositiveMomentum, isTrue);
      expect(macd.signalType, equals('BUY'));
    });

    test('should detect bearish condition', () {
      final macd = MCPMACDResult(
        macd: 145.0,
        signal: 150.0,
        histogram: -5.0,
        timestamp: DateTime.now(),
      );

      expect(macd.isBearish, isTrue);
      expect(macd.isBullish, isFalse);
      expect(macd.hasNegativeMomentum, isTrue);
      expect(macd.signalType, equals('SELL'));
    });

    test('should detect bullish crossover', () {
      final previous = MCPMACDResult(
        macd: 145.0,
        signal: 150.0,
        histogram: -5.0,
        timestamp: DateTime.now(),
      );

      final current = MCPMACDResult(
        macd: 151.0,
        signal: 150.0,
        histogram: 1.0,
        timestamp: DateTime.now(),
      );

      expect(current.isBullishCrossover(previous), isTrue);
    });

    test('should calculate divergence', () {
      final macd = MCPMACDResult(
        macd: 150.0,
        signal: 145.0,
        histogram: 5.0,
        timestamp: DateTime.now(),
      );

      expect(macd.divergence, equals(5.0));
    });
  });

  group('MCPBollingerBands', () {
    test('should create from JSON correctly', () {
      final json = {
        'upper': 92000.0,
        'middle': 90000.0,
        'lower': 88000.0,
        'timestamp': '2025-11-20T10:00:00Z',
        'pair': 'BTC-USDT',
        'exchange': 'kucoin',
        'period': 20,
        'std_dev': 2.0,
      };

      final bb = MCPBollingerBands.fromJson(json);

      expect(bb.upper, equals(92000.0));
      expect(bb.middle, equals(90000.0));
      expect(bb.lower, equals(88000.0));
      expect(bb.pair, equals('BTC-USDT'));
    });

    test('should calculate bandwidth', () {
      final bb = MCPBollingerBands(
        upper: 92000.0,
        middle: 90000.0,
        lower: 88000.0,
        timestamp: DateTime.now(),
      );

      expect(bb.bandwidth, equals(4000.0));
      expect(bb.bandwidthPercent, closeTo(4.44, 0.01));
    });

    test('should calculate percentB', () {
      final bb = MCPBollingerBands(
        upper: 92000.0,
        middle: 90000.0,
        lower: 88000.0,
        timestamp: DateTime.now(),
      );

      expect(bb.percentB(90000.0), equals(0.5)); // En el medio
      expect(bb.percentB(92000.0), equals(1.0)); // En upper
      expect(bb.percentB(88000.0), equals(0.0)); // En lower
    });

    test('should detect price near upper band', () {
      final bb = MCPBollingerBands(
        upper: 92000.0,
        middle: 90000.0,
        lower: 88000.0,
        timestamp: DateTime.now(),
      );

      expect(bb.isPriceNearUpperBand(91500.0), isTrue);
      expect(bb.isPriceNearUpperBand(85000.0), isFalse);
    });

    test('should detect price near lower band', () {
      final bb = MCPBollingerBands(
        upper: 92000.0,
        middle: 90000.0,
        lower: 88000.0,
        timestamp: DateTime.now(),
      );

      expect(bb.isPriceNearLowerBand(88500.0), isTrue);
      expect(bb.isPriceNearLowerBand(95000.0), isFalse);
    });

    test('should detect price above upper band', () {
      final bb = MCPBollingerBands(
        upper: 92000.0,
        middle: 90000.0,
        lower: 88000.0,
        timestamp: DateTime.now(),
      );

      expect(bb.isPriceAboveUpperBand(93000.0), isTrue);
      expect(bb.isPriceAboveUpperBand(91000.0), isFalse);
    });

    test('should detect price below lower band', () {
      final bb = MCPBollingerBands(
        upper: 92000.0,
        middle: 90000.0,
        lower: 88000.0,
        timestamp: DateTime.now(),
      );

      expect(bb.isPriceBelowLowerBand(87000.0), isTrue);
      expect(bb.isPriceBelowLowerBand(89000.0), isFalse);
    });

    test('should get correct signal', () {
      final bb = MCPBollingerBands(
        upper: 100000.0,
        middle: 90000.0,
        lower: 80000.0,
        timestamp: DateTime.now(),
      );

      expect(bb.getSignal(78000.0), equals('BUY')); // Below lower
      expect(bb.getSignal(102000.0), equals('SELL')); // Above upper
      expect(bb.getSignal(90000.0), equals('NEUTRAL')); // In middle
    });

    test('should detect squeeze', () {
      final bb = MCPBollingerBands(
        upper: 92000.0,
        middle: 90000.0,
        lower: 88000.0,
        timestamp: DateTime.now(),
      );

      expect(bb.isSqueeze(5000.0), isTrue); // 4000 < 5000
      expect(bb.isExpanding(3000.0), isTrue); // 4000 > 3000
    });
  });
}
