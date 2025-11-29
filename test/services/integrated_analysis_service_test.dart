import 'package:flutter_test/flutter_test.dart';
import 'package:kuri_crypto/services/integrated_analysis_service.dart';
import 'package:kuri_crypto/services/market_data_service.dart';
import 'package:kuri_crypto/services/technical_indicators_service.dart';
import 'package:kuri_crypto/services/mcp_service.dart';
import 'package:kuri_crypto/models/mcp_trading_signal.dart';
import 'package:dio/dio.dart';

void main() {
  group('IntegratedAnalysisService', () {
    late IntegratedAnalysisService service;
    late MarketDataService mockMarketDataService;
    late TechnicalIndicatorsService mockTechnicalIndicatorsService;

    setUp(() {
      final mockDio = Dio();
      final mockMcpService = MCPService(mockDio);
      mockMarketDataService = MarketDataService(mockMcpService);
      mockTechnicalIndicatorsService =
          TechnicalIndicatorsService(mockMcpService);
      service = IntegratedAnalysisService(
        mockMarketDataService,
        mockTechnicalIndicatorsService,
      );
    });

    test('should initialize correctly', () {
      expect(service, isNotNull);
    });

    test('should have getCompleteMarketAnalysis method', () {
      expect(service.getCompleteMarketAnalysis, isNotNull);
    });

    test('should have getQuickAnalysis method', () {
      expect(service.getQuickAnalysis, isNotNull);
    });

    test('should have analyzeMultiplePairs method', () {
      expect(service.analyzeMultiplePairs, isNotNull);
    });

    test('should have findBuyOpportunities method', () {
      expect(service.findBuyOpportunities, isNotNull);
    });
  });

  group('MCPTradingSignal', () {
    test('should create from JSON correctly', () {
      final json = {
        'type': 'BUY',
        'strength': 75.0,
        'confidence': 80.0,
        'reasons': ['RSI oversold', 'MACD bullish'],
        'indicators': {'RSI': 'BUY', 'MACD': 'BUY'},
        'risk': 'LOW',
        'entry_price': 90000.0,
        'stop_loss': 88000.0,
        'take_profit': 95000.0,
      };

      final signal = MCPTradingSignal.fromJson(json);

      expect(signal.type, equals('BUY'));
      expect(signal.strength, equals(75.0));
      expect(signal.confidence, equals(80.0));
      expect(signal.reasons.length, equals(2));
      expect(signal.indicators.length, equals(2));
      expect(signal.risk, equals('LOW'));
      expect(signal.entryPrice, equals(90000.0));
      expect(signal.stopLoss, equals(88000.0));
      expect(signal.takeProfit, equals(95000.0));
    });

    test('should detect BUY signal', () {
      final signal = MCPTradingSignal(
        type: 'BUY',
        strength: 75.0,
        confidence: 80.0,
        reasons: ['Test'],
        indicators: {},
        risk: 'LOW',
      );

      expect(signal.isBuy, isTrue);
      expect(signal.isSell, isFalse);
      expect(signal.isHold, isFalse);
    });

    test('should detect SELL signal', () {
      final signal = MCPTradingSignal(
        type: 'SELL',
        strength: 70.0,
        confidence: 75.0,
        reasons: ['Test'],
        indicators: {},
        risk: 'MEDIUM',
      );

      expect(signal.isSell, isTrue);
      expect(signal.isBuy, isFalse);
      expect(signal.isHold, isFalse);
    });

    test('should detect HOLD signal', () {
      final signal = MCPTradingSignal(
        type: 'HOLD',
        strength: 50.0,
        confidence: 50.0,
        reasons: ['Test'],
        indicators: {},
        risk: 'LOW',
      );

      expect(signal.isHold, isTrue);
      expect(signal.isBuy, isFalse);
      expect(signal.isSell, isFalse);
    });

    test('should detect strong signal', () {
      final strong = MCPTradingSignal(
        type: 'BUY',
        strength: 80.0,
        confidence: 85.0,
        reasons: ['Test'],
        indicators: {},
        risk: 'LOW',
      );

      final weak = MCPTradingSignal(
        type: 'BUY',
        strength: 30.0,
        confidence: 35.0,
        reasons: ['Test'],
        indicators: {},
        risk: 'MEDIUM',
      );

      expect(strong.isStrong, isTrue);
      expect(weak.isWeak, isTrue);
    });

    test('should detect high confidence', () {
      final highConf = MCPTradingSignal(
        type: 'BUY',
        strength: 75.0,
        confidence: 85.0,
        reasons: ['Test'],
        indicators: {},
        risk: 'LOW',
      );

      final lowConf = MCPTradingSignal(
        type: 'BUY',
        strength: 75.0,
        confidence: 50.0,
        reasons: ['Test'],
        indicators: {},
        risk: 'LOW',
      );

      expect(highConf.isHighConfidence, isTrue);
      expect(lowConf.isHighConfidence, isFalse);
    });

    test('should detect risk levels', () {
      final lowRisk = MCPTradingSignal(
        type: 'BUY',
        strength: 75.0,
        confidence: 80.0,
        reasons: ['Test'],
        indicators: {},
        risk: 'LOW',
      );

      final highRisk = MCPTradingSignal(
        type: 'BUY',
        strength: 75.0,
        confidence: 80.0,
        reasons: ['Test'],
        indicators: {},
        risk: 'HIGH',
      );

      expect(lowRisk.isLowRisk, isTrue);
      expect(highRisk.isHighRisk, isTrue);
    });

    test('should calculate overall score', () {
      final signal = MCPTradingSignal(
        type: 'BUY',
        strength: 80.0,
        confidence: 90.0,
        reasons: ['Test'],
        indicators: {},
        risk: 'LOW',
      );

      expect(signal.overallScore, equals(85.0));
    });

    test('should detect actionable signals', () {
      final actionable = MCPTradingSignal(
        type: 'BUY',
        strength: 80.0,
        confidence: 85.0,
        reasons: ['Test'],
        indicators: {},
        risk: 'LOW',
      );

      final notActionable = MCPTradingSignal(
        type: 'BUY',
        strength: 60.0,
        confidence: 65.0,
        reasons: ['Test'],
        indicators: {},
        risk: 'LOW',
      );

      expect(actionable.isActionable, isTrue);
      expect(notActionable.isActionable, isFalse);
    });

    test('should calculate risk/reward ratio', () {
      final signal = MCPTradingSignal(
        type: 'BUY',
        strength: 75.0,
        confidence: 80.0,
        reasons: ['Test'],
        indicators: {},
        risk: 'LOW',
        entryPrice: 90000.0,
        stopLoss: 88000.0,
        takeProfit: 96000.0,
      );

      final ratio = signal.riskRewardRatio;
      expect(ratio, isNotNull);
      expect(ratio, equals(3.0)); // 6000 reward / 2000 risk = 3.0
    });

    test('should detect favorable risk/reward', () {
      final favorable = MCPTradingSignal(
        type: 'BUY',
        strength: 75.0,
        confidence: 80.0,
        reasons: ['Test'],
        indicators: {},
        risk: 'LOW',
        entryPrice: 90000.0,
        stopLoss: 88000.0,
        takeProfit: 96000.0,
      );

      final unfavorable = MCPTradingSignal(
        type: 'BUY',
        strength: 75.0,
        confidence: 80.0,
        reasons: ['Test'],
        indicators: {},
        risk: 'LOW',
        entryPrice: 90000.0,
        stopLoss: 88000.0,
        takeProfit: 91000.0,
      );

      expect(favorable.hasFavorableRiskReward, isTrue);
      expect(unfavorable.hasFavorableRiskReward, isFalse);
    });

    test('should count supporting indicators', () {
      final signal = MCPTradingSignal(
        type: 'BUY',
        strength: 75.0,
        confidence: 80.0,
        reasons: ['Test'],
        indicators: {'RSI': 'BUY', 'MACD': 'BUY', 'BB': 'BUY'},
        risk: 'LOW',
      );

      expect(signal.supportingIndicatorsCount, equals(3));
    });

    test('should generate description', () {
      final signal = MCPTradingSignal(
        type: 'BUY',
        strength: 75.0,
        confidence: 80.0,
        reasons: ['Test'],
        indicators: {'RSI': 'BUY', 'MACD': 'BUY'},
        risk: 'LOW',
      );

      final description = signal.description;
      expect(description, contains('BUY'));
      expect(description, contains('75%'));
      expect(description, contains('80%'));
      expect(description, contains('LOW'));
      expect(description, contains('2 indicators'));
    });

    test('should convert to JSON', () {
      final signal = MCPTradingSignal(
        type: 'BUY',
        strength: 75.0,
        confidence: 80.0,
        reasons: ['RSI oversold'],
        indicators: {'RSI': 'BUY'},
        risk: 'LOW',
        entryPrice: 90000.0,
      );

      final json = signal.toJson();

      expect(json['type'], equals('BUY'));
      expect(json['strength'], equals(75.0));
      expect(json['confidence'], equals(80.0));
      expect(json['reasons'], isA<List>());
      expect(json['indicators'], isA<Map>());
      expect(json['risk'], equals('LOW'));
      expect(json['entry_price'], equals(90000.0));
    });

    test('should implement equality', () {
      final signal1 = MCPTradingSignal(
        type: 'BUY',
        strength: 75.0,
        confidence: 80.0,
        reasons: ['Test'],
        indicators: {},
        risk: 'LOW',
      );

      final signal2 = MCPTradingSignal(
        type: 'BUY',
        strength: 75.0,
        confidence: 80.0,
        reasons: ['Test'],
        indicators: {},
        risk: 'LOW',
      );

      final signal3 = MCPTradingSignal(
        type: 'SELL',
        strength: 75.0,
        confidence: 80.0,
        reasons: ['Test'],
        indicators: {},
        risk: 'LOW',
      );

      expect(signal1, equals(signal2));
      expect(signal1, isNot(equals(signal3)));
    });

    test('should implement copyWith', () {
      final original = MCPTradingSignal(
        type: 'BUY',
        strength: 75.0,
        confidence: 80.0,
        reasons: ['Test'],
        indicators: {},
        risk: 'LOW',
      );

      final copied = original.copyWith(strength: 85.0, risk: 'MEDIUM');

      expect(copied.strength, equals(85.0));
      expect(copied.risk, equals('MEDIUM'));
      expect(copied.type, equals(original.type));
      expect(copied.confidence, equals(original.confidence));
    });
  });
}
