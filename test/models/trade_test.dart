import 'package:test/test.dart';
import 'package:kuri_crypto/models/trade.dart';

void main() {
  group('Trade Model', () {
    final testTimestamp = DateTime.parse('2025-11-16T10:00:00Z');

    test('should create Trade with all fields', () {
      final trade = Trade(
        id: 'trade_123',
        orderId: 'ord_123',
        symbol: 'DOGE-USDT',
        side: 'buy',
        type: 'market',
        price: 0.08500,
        size: 1000,
        status: 'filled',
        latencyMs: 45.0,
        timestamp: testTimestamp,
        fee: 0.85,
        feeCurrency: 'USDT',
        slippagePct: 0.05,
      );

      expect(trade.id, 'trade_123');
      expect(trade.orderId, 'ord_123');
      expect(trade.symbol, 'DOGE-USDT');
      expect(trade.side, 'buy');
      expect(trade.type, 'market');
      expect(trade.price, 0.08500);
      expect(trade.size, 1000);
      expect(trade.status, 'filled');
      expect(trade.latencyMs, 45.0);
      expect(trade.timestamp, testTimestamp);
      expect(trade.fee, 0.85);
      expect(trade.feeCurrency, 'USDT');
      expect(trade.slippagePct, 0.05);
    });

    test('should parse Trade from JSON', () {
      final json = {
        'id': 'trade_123',
        'order_id': 'ord_123',
        'symbol': 'DOGE-USDT',
        'side': 'buy',
        'type': 'market',
        'size': 1000,
        'price': 0.08500,
        'status': 'filled',
        'latency_ms': 45,
        'timestamp': '2025-11-16T10:00:00Z',
      };

      final trade = Trade.fromJson(json);

      expect(trade.id, 'trade_123');
      expect(trade.orderId, 'ord_123');
      expect(trade.symbol, 'DOGE-USDT');
      expect(trade.side, 'buy');
      expect(trade.type, 'market');
      expect(trade.price, 0.08500);
      expect(trade.size, 1000);
      expect(trade.status, 'filled');
      expect(trade.latencyMs, 45.0);
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        'id': 'trade_123',
        'order_id': 'ord_123',
        'symbol': 'BTC-USDT',
        'side': 'sell',
        'price': 43000,
        'size': 0.1,
        'timestamp': '2025-11-16T10:00:00Z',
      };

      final trade = Trade.fromJson(json);

      expect(trade.type, 'market');
      expect(trade.status, 'pending');
      expect(trade.latencyMs, 0.0);
      expect(trade.fee, null);
      expect(trade.feeCurrency, null);
      expect(trade.slippagePct, null);
    });

    test('should convert Trade to JSON', () {
      final trade = Trade(
        id: 'trade_123',
        orderId: 'ord_123',
        symbol: 'DOGE-USDT',
        side: 'buy',
        type: 'market',
        price: 0.08500,
        size: 1000,
        status: 'filled',
        latencyMs: 45.0,
        timestamp: testTimestamp,
        fee: 0.85,
        feeCurrency: 'USDT',
        slippagePct: 0.05,
      );

      final json = trade.toJson();

      expect(json['id'], 'trade_123');
      expect(json['order_id'], 'ord_123');
      expect(json['symbol'], 'DOGE-USDT');
      expect(json['side'], 'buy');
      expect(json['type'], 'market');
      expect(json['price'], 0.08500);
      expect(json['size'], 1000);
      expect(json['status'], 'filled');
      expect(json['latency_ms'], 45.0);
      expect(json['fee'], 0.85);
      expect(json['fee_currency'], 'USDT');
      expect(json['slippage_pct'], 0.05);
    });

    test('should check if trade is buy', () {
      final buy = Trade(
        id: 'trade_123',
        orderId: 'ord_123',
        symbol: 'BTC-USDT',
        side: 'buy',
        price: 43000,
        size: 0.1,
        timestamp: testTimestamp,
      );

      final sell = buy.copyWith(side: 'sell');

      expect(buy.isBuy, true);
      expect(buy.isSell, false);
      expect(sell.isBuy, false);
      expect(sell.isSell, true);
    });

    test('should check trade status', () {
      final filled = Trade(
        id: 'trade_123',
        orderId: 'ord_123',
        symbol: 'BTC-USDT',
        side: 'buy',
        price: 43000,
        size: 0.1,
        status: 'filled',
        timestamp: testTimestamp,
      );

      final pending = filled.copyWith(status: 'pending');
      final failed = filled.copyWith(status: 'failed');
      final cancelled = filled.copyWith(status: 'cancelled');

      expect(filled.isFilled, true);
      expect(filled.isPending, false);
      expect(filled.isFailed, false);

      expect(pending.isFilled, false);
      expect(pending.isPending, true);
      expect(pending.isFailed, false);

      expect(failed.isFilled, false);
      expect(failed.isPending, false);
      expect(failed.isFailed, true);

      expect(cancelled.isFailed, true);
    });

    test('should check if execution is fast', () {
      final fast = Trade(
        id: 'trade_123',
        orderId: 'ord_123',
        symbol: 'BTC-USDT',
        side: 'buy',
        price: 43000,
        size: 0.1,
        latencyMs: 45.0,
        timestamp: testTimestamp,
      );

      final slow = fast.copyWith(latencyMs: 150.0);

      expect(fast.isFastExecution, true);
      expect(slow.isFastExecution, false);
    });

    test('should calculate total cost with fee', () {
      final trade = Trade(
        id: 'trade_123',
        orderId: 'ord_123',
        symbol: 'BTC-USDT',
        side: 'buy',
        price: 43000.0,
        size: 0.1,
        fee: 4.3,
        timestamp: testTimestamp,
      );

      // (43000 * 0.1) + 4.3 = 4300 + 4.3 = 4304.3
      expect(trade.getTotalCost(), 4304.3);
    });

    test('should calculate total cost without fee', () {
      final trade = Trade(
        id: 'trade_123',
        orderId: 'ord_123',
        symbol: 'BTC-USDT',
        side: 'buy',
        price: 43000.0,
        size: 0.1,
        timestamp: testTimestamp,
      );

      // 43000 * 0.1 = 4300
      expect(trade.getTotalCost(), 4300.0);
    });

    test('should calculate effective price with slippage', () {
      final trade = Trade(
        id: 'trade_123',
        orderId: 'ord_123',
        symbol: 'BTC-USDT',
        side: 'buy',
        price: 43000.0,
        size: 0.1,
        slippagePct: 0.05,
        timestamp: testTimestamp,
      );

      // 43000 * 1.0005 = 43021.5
      expect(trade.getEffectivePrice(), 43021.5);
    });

    test('should calculate effective price without slippage', () {
      final trade = Trade(
        id: 'trade_123',
        orderId: 'ord_123',
        symbol: 'BTC-USDT',
        side: 'buy',
        price: 43000.0,
        size: 0.1,
        timestamp: testTimestamp,
      );

      expect(trade.getEffectivePrice(), 43000.0);
    });

    test('should create copy with modified fields', () {
      final original = Trade(
        id: 'trade_123',
        orderId: 'ord_123',
        symbol: 'BTC-USDT',
        side: 'buy',
        price: 43000.0,
        size: 0.1,
        status: 'pending',
        timestamp: testTimestamp,
      );

      final copy = original.copyWith(
        status: 'filled',
        latencyMs: 45.0,
        fee: 4.3,
      );

      expect(copy.id, original.id);
      expect(copy.symbol, original.symbol);
      expect(copy.status, 'filled');
      expect(copy.latencyMs, 45.0);
      expect(copy.fee, 4.3);
    });

    test('should handle string numbers in JSON', () {
      final json = {
        'id': 'trade_123',
        'order_id': 'ord_123',
        'symbol': 'BTC-USDT',
        'side': 'buy',
        'price': '43000.0',
        'size': '0.1',
        'latency_ms': '45',
        'timestamp': '2025-11-16T10:00:00Z',
      };

      final trade = Trade.fromJson(json);

      expect(trade.price, 43000.0);
      expect(trade.size, 0.1);
      expect(trade.latencyMs, 45.0);
    });

    test('should handle equality correctly', () {
      final trade1 = Trade(
        id: 'trade_123',
        orderId: 'ord_123',
        symbol: 'BTC-USDT',
        side: 'buy',
        price: 43000.0,
        size: 0.1,
        timestamp: testTimestamp,
      );

      final trade2 = Trade(
        id: 'trade_123',
        orderId: 'ord_123',
        symbol: 'BTC-USDT',
        side: 'buy',
        price: 43000.0,
        size: 0.1,
        timestamp: testTimestamp,
      );

      final trade3 = trade1.copyWith(status: 'filled');

      expect(trade1, equals(trade2));
      expect(trade1, isNot(equals(trade3)));
    });

    test('should handle different order types', () {
      final market = Trade(
        id: 'trade_123',
        orderId: 'ord_123',
        symbol: 'BTC-USDT',
        side: 'buy',
        type: 'market',
        price: 43000.0,
        size: 0.1,
        timestamp: testTimestamp,
      );

      final limit = market.copyWith(type: 'limit');
      final stop = market.copyWith(type: 'stop');

      expect(market.type, 'market');
      expect(limit.type, 'limit');
      expect(stop.type, 'stop');
    });

    test('should handle case-insensitive side checking', () {
      final buyLower = Trade(
        id: 'trade_123',
        orderId: 'ord_123',
        symbol: 'BTC-USDT',
        side: 'buy',
        price: 43000.0,
        size: 0.1,
        timestamp: testTimestamp,
      );

      final buyUpper = buyLower.copyWith(side: 'BUY');
      final sellMixed = buyLower.copyWith(side: 'Sell');

      expect(buyLower.isBuy, true);
      expect(buyUpper.isBuy, true);
      expect(sellMixed.isSell, true);
    });

    test('should handle fee in different currencies', () {
      final usdtFee = Trade(
        id: 'trade_123',
        orderId: 'ord_123',
        symbol: 'BTC-USDT',
        side: 'buy',
        price: 43000.0,
        size: 0.1,
        fee: 4.3,
        feeCurrency: 'USDT',
        timestamp: testTimestamp,
      );

      final btcFee = usdtFee.copyWith(
        fee: 0.0001,
        feeCurrency: 'BTC',
      );

      expect(usdtFee.feeCurrency, 'USDT');
      expect(btcFee.feeCurrency, 'BTC');
    });

    test('should handle large trade sizes', () {
      final largeTrade = Trade(
        id: 'trade_123',
        orderId: 'ord_123',
        symbol: 'DOGE-USDT',
        side: 'buy',
        price: 0.085,
        size: 1000000,
        timestamp: testTimestamp,
      );

      expect(largeTrade.size, 1000000);
      expect(largeTrade.getTotalCost(), 85000.0);
    });

    test('should handle small price precision', () {
      final smallPrice = Trade(
        id: 'trade_123',
        orderId: 'ord_123',
        symbol: 'DOGE-USDT',
        side: 'buy',
        price: 0.00008500,
        size: 1000,
        timestamp: testTimestamp,
      );

      expect(smallPrice.price, 0.00008500);
      expect(smallPrice.getTotalCost(), closeTo(0.085, 0.0001));
    });
  });
}
