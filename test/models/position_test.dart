import 'package:test/test.dart';
import '../../lib/models/position.dart';

void main() {
  group('Position Model', () {
    final testTimestamp = DateTime.parse('2025-11-16T10:00:00Z');

    test('should create Position with all fields', () {
      final position = Position(
        id: 'pos_123',
        symbol: 'BTC-USDT',
        side: 'long',
        entryPrice: 43000.0,
        currentPrice: 43500.0,
        size: 0.1,
        leverage: 2.0,
        stopLoss: 42500.0,
        takeProfit: 44000.0,
        unrealizedPnl: 50.0,
        realizedPnl: 0.0,
        openTime: testTimestamp,
        strategy: 'rsi_scalping',
        status: 'open',
      );

      expect(position.id, 'pos_123');
      expect(position.symbol, 'BTC-USDT');
      expect(position.side, 'long');
      expect(position.entryPrice, 43000.0);
      expect(position.currentPrice, 43500.0);
      expect(position.size, 0.1);
      expect(position.leverage, 2.0);
      expect(position.stopLoss, 42500.0);
      expect(position.takeProfit, 44000.0);
      expect(position.unrealizedPnl, 50.0);
      expect(position.isOpen, true);
      expect(position.isProfitable, true);
    });

    test('should calculate PnL percentage for long position', () {
      final position = Position(
        id: 'pos_123',
        symbol: 'BTC-USDT',
        side: 'long',
        entryPrice: 100.0,
        currentPrice: 110.0,
        size: 1.0,
        leverage: 2.0,
        openTime: testTimestamp,
        strategy: 'test',
      );

      // (110 - 100) / 100 * 100 * 2 = 20%
      expect(position.calculatePnlPercentage(), 20.0);
    });

    test('should calculate PnL percentage for short position', () {
      final position = Position(
        id: 'pos_123',
        symbol: 'BTC-USDT',
        side: 'short',
        entryPrice: 100.0,
        currentPrice: 90.0,
        size: 1.0,
        leverage: 2.0,
        openTime: testTimestamp,
        strategy: 'test',
      );

      // (90 - 100) / 100 * 100 * -1 * 2 = 20%
      expect(position.calculatePnlPercentage(), 20.0);
    });

    test('should parse Position from JSON', () {
      final json = {
        'id': 'pos_123',
        'symbol': 'DOGE-USDT',
        'side': 'long',
        'entry_price': 0.085,
        'current_price': 0.0865,
        'size': 1000,
        'leverage': 2,
        'stop_loss': 0.0835,
        'take_profit': 0.0875,
        'unrealized_pnl': 15.0,
        'realized_pnl': 0.0,
        'open_time': '2025-11-16T10:00:00Z',
        'strategy': 'rsi_scalping',
        'status': 'open',
      };

      final position = Position.fromJson(json);

      expect(position.id, 'pos_123');
      expect(position.symbol, 'DOGE-USDT');
      expect(position.side, 'long');
      expect(position.entryPrice, 0.085);
      expect(position.currentPrice, 0.0865);
      expect(position.size, 1000);
      expect(position.leverage, 2);
      expect(position.stopLoss, 0.0835);
      expect(position.takeProfit, 0.0875);
      expect(position.unrealizedPnl, 15.0);
      expect(position.strategy, 'rsi_scalping');
      expect(position.status, 'open');
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        'id': 'pos_123',
        'symbol': 'BTC-USDT',
        'side': 'long',
        'entry_price': 43000,
        'current_price': 43500,
        'size': 0.1,
        'open_time': '2025-11-16T10:00:00Z',
        'strategy': 'test',
      };

      final position = Position.fromJson(json);

      expect(position.leverage, 1.0);
      expect(position.stopLoss, null);
      expect(position.takeProfit, null);
      expect(position.unrealizedPnl, 0.0);
      expect(position.closeTime, null);
      expect(position.status, 'open');
    });

    test('should convert Position to JSON', () {
      final position = Position(
        id: 'pos_123',
        symbol: 'BTC-USDT',
        side: 'long',
        entryPrice: 43000.0,
        currentPrice: 43500.0,
        size: 0.1,
        leverage: 2.0,
        stopLoss: 42500.0,
        takeProfit: 44000.0,
        unrealizedPnl: 50.0,
        realizedPnl: 0.0,
        openTime: testTimestamp,
        strategy: 'rsi_scalping',
        status: 'open',
      );

      final json = position.toJson();

      expect(json['id'], 'pos_123');
      expect(json['symbol'], 'BTC-USDT');
      expect(json['side'], 'long');
      expect(json['entry_price'], 43000.0);
      expect(json['current_price'], 43500.0);
      expect(json['size'], 0.1);
      expect(json['leverage'], 2.0);
      expect(json['stop_loss'], 42500.0);
      expect(json['take_profit'], 44000.0);
      expect(json['unrealized_pnl'], 50.0);
      expect(json['strategy'], 'rsi_scalping');
      expect(json['status'], 'open');
    });

    test('should create copy with modified fields', () {
      final original = Position(
        id: 'pos_123',
        symbol: 'BTC-USDT',
        side: 'long',
        entryPrice: 43000.0,
        currentPrice: 43500.0,
        size: 0.1,
        openTime: testTimestamp,
        strategy: 'test',
      );

      final copy = original.copyWith(
        currentPrice: 44000.0,
        unrealizedPnl: 100.0,
        status: 'closing',
      );

      expect(copy.id, original.id);
      expect(copy.symbol, original.symbol);
      expect(copy.currentPrice, 44000.0);
      expect(copy.unrealizedPnl, 100.0);
      expect(copy.status, 'closing');
    });

    test('should handle string numbers in JSON', () {
      final json = {
        'id': 'pos_123',
        'symbol': 'BTC-USDT',
        'side': 'long',
        'entry_price': '43000.0',
        'current_price': '43500',
        'size': '0.1',
        'leverage': '2',
        'open_time': '2025-11-16T10:00:00Z',
        'strategy': 'test',
      };

      final position = Position.fromJson(json);

      expect(position.entryPrice, 43000.0);
      expect(position.currentPrice, 43500.0);
      expect(position.size, 0.1);
      expect(position.leverage, 2.0);
    });

    test('should handle equality correctly', () {
      final position1 = Position(
        id: 'pos_123',
        symbol: 'BTC-USDT',
        side: 'long',
        entryPrice: 43000.0,
        currentPrice: 43500.0,
        size: 0.1,
        openTime: testTimestamp,
        strategy: 'test',
      );

      final position2 = Position(
        id: 'pos_123',
        symbol: 'BTC-USDT',
        side: 'long',
        entryPrice: 43000.0,
        currentPrice: 43500.0,
        size: 0.1,
        openTime: testTimestamp,
        strategy: 'test',
      );

      final position3 = position1.copyWith(currentPrice: 44000.0);

      expect(position1, equals(position2));
      expect(position1, isNot(equals(position3)));
    });

    test('should check if position is profitable', () {
      final profitable = Position(
        id: 'pos_123',
        symbol: 'BTC-USDT',
        side: 'long',
        entryPrice: 43000.0,
        currentPrice: 43500.0,
        size: 0.1,
        unrealizedPnl: 50.0,
        openTime: testTimestamp,
        strategy: 'test',
      );

      final unprofitable = profitable.copyWith(unrealizedPnl: -50.0);

      expect(profitable.isProfitable, true);
      expect(unprofitable.isProfitable, false);
    });
  });
}
