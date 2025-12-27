import 'package:flutter_test/flutter_test.dart';
import 'package:kuri_crypto/models/futures_position.dart';

void main() {
  group('FuturesPosition', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'symbol': 'BTCUSDTM',
        'side': 'long',
        'size': 1.5,
        'entry_price': 50000.0,
        'current_price': 51000.0,
        'unrealized_pnl': 1500.0,
        'realized_pnl': 200.0,
        'leverage': 10,
        'margin': 7500.0,
        'margin_mode': 'ISOLATED',
        'liquidation_price': 45000.0,
        'pnl_percent': 3.0,
        'updated_at': '2024-01-01T00:00:00Z',
        'mark_price': 51000.0,
      };

      final position = FuturesPosition.fromJson(json);

      expect(position.symbol, 'BTCUSDTM');
      expect(position.side, 'long');
      expect(position.size, 1.5);
      expect(position.entryPrice, 50000.0);
      expect(position.unrealizedPnl, 1500.0);
      expect(position.realizedPnl, 200.0);
      expect(position.leverage, 10);
      expect(position.marginMode, 'ISOLATED');
    });

    test('computed properties - totalPnl', () {
      final position = FuturesPosition(
        symbol: 'BTCUSDTM',
        side: 'long',
        size: 1.0,
        entryPrice: 50000.0,
        currentPrice: 51000.0,
        unrealizedPnl: 1000.0,
        realizedPnl: 500.0,
        leverage: 10,
        margin: 5000.0,
        marginMode: 'ISOLATED',
        liquidationPrice: 45000.0,
        pnlPercent: 2.0,
        updatedAt: DateTime.now(),
      );

      expect(position.totalPnl, 1500.0);
    });

    test('computed properties - isNearLiquidation', () {
      final safePosition = FuturesPosition(
        symbol: 'BTCUSDTM',
        side: 'long',
        size: 1.0,
        entryPrice: 50000.0,
        currentPrice: 50000.0,
        unrealizedPnl: 0,
        realizedPnl: 0,
        leverage: 10,
        margin: 5000.0,
        marginMode: 'ISOLATED',
        liquidationPrice: 40000.0, // 20% away
        pnlPercent: 0,
        updatedAt: DateTime.now(),
      );

      expect(safePosition.isNearLiquidation, false);
      expect(safePosition.distanceToLiquidationPercent, 20.0);

      final dangerPosition = FuturesPosition(
        symbol: 'BTCUSDTM',
        side: 'long',
        size: 1.0,
        entryPrice: 50000.0,
        currentPrice: 50000.0,
        unrealizedPnl: 0,
        realizedPnl: 0,
        leverage: 10,
        margin: 5000.0,
        marginMode: 'ISOLATED',
        liquidationPrice: 48000.0, // 4% away
        pnlPercent: 0,
        updatedAt: DateTime.now(),
      );

      expect(dangerPosition.isNearLiquidation, true);
      expect(dangerPosition.distanceToLiquidationPercent, closeTo(4.0, 0.1));
    });

    test('computed properties - isProfit and isLoss', () {
      final profitPosition = FuturesPosition(
        symbol: 'BTCUSDTM',
        side: 'long',
        size: 1.0,
        entryPrice: 50000.0,
        currentPrice: 51000.0,
        unrealizedPnl: 1000.0,
        realizedPnl: 0,
        leverage: 10,
        margin: 5000.0,
        marginMode: 'ISOLATED',
        liquidationPrice: 45000.0,
        pnlPercent: 2.0,
        updatedAt: DateTime.now(),
      );

      expect(profitPosition.isProfit, true);
      expect(profitPosition.isLoss, false);

      final lossPosition = FuturesPosition(
        symbol: 'BTCUSDTM',
        side: 'long',
        size: 1.0,
        entryPrice: 50000.0,
        currentPrice: 49000.0,
        unrealizedPnl: -1000.0,
        realizedPnl: 0,
        leverage: 10,
        margin: 5000.0,
        marginMode: 'ISOLATED',
        liquidationPrice: 45000.0,
        pnlPercent: -2.0,
        updatedAt: DateTime.now(),
      );

      expect(lossPosition.isProfit, false);
      expect(lossPosition.isLoss, true);
    });

    test('computed properties - isLong and isShort', () {
      final longPosition = FuturesPosition(
        symbol: 'BTCUSDTM',
        side: 'long',
        size: 1.0,
        entryPrice: 50000.0,
        currentPrice: 50000.0,
        unrealizedPnl: 0,
        realizedPnl: 0,
        leverage: 10,
        margin: 5000.0,
        marginMode: 'ISOLATED',
        liquidationPrice: 45000.0,
        pnlPercent: 0,
        updatedAt: DateTime.now(),
      );

      expect(longPosition.isLong, true);
      expect(longPosition.isShort, false);

      final shortPosition = FuturesPosition(
        symbol: 'BTCUSDTM',
        side: 'short',
        size: 1.0,
        entryPrice: 50000.0,
        currentPrice: 50000.0,
        unrealizedPnl: 0,
        realizedPnl: 0,
        leverage: 10,
        margin: 5000.0,
        marginMode: 'CROSS',
        liquidationPrice: 55000.0,
        pnlPercent: 0,
        updatedAt: DateTime.now(),
      );

      expect(shortPosition.isLong, false);
      expect(shortPosition.isShort, true);
    });
  });
}
