import 'package:flutter_test/flutter_test.dart';
import 'package:kuri_crypto/models/comprehensive_analysis.dart';

void main() {
  group('ComprehensiveAnalysis', () {
    test('fromJson with complete data', () {
      final json = {
        'symbol': 'BTC-USDT',
        'exchange': 'kucoin',
        'current_price': {
          'current': 50000.0,
          'volume_24h': 1000000.0,
          'high_24h': 51000.0,
          'low_24h': 49000.0,
          'change_24h': 1000.0,
        },
        'multi_timeframe': {
          '1h': {
            'timeframe': '1h',
            'rsi': 65.5,
            'signal': 'neutral',
          },
        },
        'scenarios': [
          {
            'type': 'bullish',
            'probability': 0.7,
            'description': 'Test scenario',
          },
        ],
        'recommendation': {
          'action': 'BUY',
          'confidence': 0.8,
          'reasoning': ['Test reason 1', 'Test reason 2'],
        },
      };

      final analysis = ComprehensiveAnalysis.fromJson(json);

      expect(analysis.symbol, 'BTC-USDT');
      expect(analysis.exchange, 'kucoin');
      expect(analysis.priceData.last, 50000.0);
      expect(analysis.recommendation.action, 'BUY');
      expect(analysis.recommendation.confidence, 0.8);
    });

    test('fromJson with missing optional fields', () {
      final json = {
        'exchange': 'kucoin',
        'current_price': {},
        'recommendation': {
          'action': 'WAIT',
          'confidence': 0.5,
        },
      };

      final analysis = ComprehensiveAnalysis.fromJson(json);

      expect(analysis.symbol, '');
      expect(analysis.exchange, 'kucoin');
      expect(analysis.recommendation.action, 'WAIT');
    });

    test('computed properties', () {
      final json = {
        'exchange': 'kucoin',
        'current_price': {},
        'recommendation': {
          'action': 'BUY',
          'confidence': 0.85,
        },
        'scenarios': [
          {
            'type': 'bullish',
            'probability': 0.8,
            'description': 'Bullish scenario',
          },
        ],
      };

      final analysis = ComprehensiveAnalysis.fromJson(json);

      expect(analysis.isStrongBuy, true);
      expect(analysis.isBullish, true);
    });
  });

  group('Recommendation', () {
    test('fromJson handles reasoning as List', () {
      final json = {
        'action': 'BUY',
        'confidence': 0.75,
        'reasoning': ['Reason 1', 'Reason 2'],
      };

      final recommendation = Recommendation.fromJson(json);

      expect(recommendation.reasoning, ['Reason 1', 'Reason 2']);
      expect(recommendation.isBuy, true);
    });

    test('fromJson handles reasoning as String', () {
      final json = {
        'action': 'SELL',
        'confidence': 0.65,
        'reasoning': 'Single reason',
      };

      final recommendation = Recommendation.fromJson(json);

      expect(recommendation.reasoning, ['Single reason']);
      expect(recommendation.isSell, true);
    });

    test('computed properties', () {
      final json = {
        'action': 'BUY',
        'confidence': 0.85,
        'entry': 50000.0,
        'stop_loss': 48000.0,
        'take_profit': 55000.0,
      };

      final recommendation = Recommendation.fromJson(json);

      expect(recommendation.isHighConfidence, true);
      expect(recommendation.riskRewardRatio, closeTo(2.5, 0.1));
    });
  });
}
