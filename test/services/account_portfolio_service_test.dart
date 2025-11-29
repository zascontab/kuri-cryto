import 'package:flutter_test/flutter_test.dart';
import 'package:kuri_crypto/services/account_portfolio_service.dart';
import 'package:kuri_crypto/services/mcp_service.dart';
import 'package:kuri_crypto/models/mcp_account_info.dart';
import 'package:kuri_crypto/models/mcp_balance.dart';
import 'package:kuri_crypto/models/mcp_portfolio.dart';
import 'package:dio/dio.dart';

void main() {
  group('AccountPortfolioService', () {
    late AccountPortfolioService service;
    late MCPService mockMcpService;

    setUp(() {
      final mockDio = Dio();
      mockMcpService = MCPService(mockDio);
      service = AccountPortfolioService(mockMcpService);
    });

    test('should initialize correctly', () {
      expect(service, isNotNull);
    });

    test('should have getAccountInfo method', () {
      expect(service.getAccountInfo, isNotNull);
    });

    test('should have getBalances method', () {
      expect(service.getBalances, isNotNull);
    });

    test('should have getBalance method', () {
      expect(service.getBalance, isNotNull);
    });

    test('should have getPortfolio method', () {
      expect(service.getPortfolio, isNotNull);
    });

    test('should have getPortfolioAnalysis method', () {
      expect(service.getPortfolioAnalysis, isNotNull);
    });

    test('should have convenience methods', () {
      expect(service.getSignificantBalances, isNotNull);
      expect(service.getTotalValueUsd, isNotNull);
      expect(service.hasSufficientBalance, isNotNull);
      expect(service.getAssetDistribution, isNotNull);
      expect(service.getDiversificationScore, isNotNull);
    });
  });

  group('MCPAccountInfo', () {
    test('should create from JSON correctly', () {
      final json = {
        'account_type': 'spot',
        'exchange': 'kucoin',
        'can_trade': true,
        'can_withdraw': true,
        'can_deposit': true,
        'maker_fee': 0.1,
        'taker_fee': 0.1,
        'status': 'active',
      };

      final accountInfo = MCPAccountInfo.fromJson(json);

      expect(accountInfo.accountType, equals('spot'));
      expect(accountInfo.exchange, equals('kucoin'));
      expect(accountInfo.canTrade, isTrue);
      expect(accountInfo.canWithdraw, isTrue);
      expect(accountInfo.canDeposit, isTrue);
      expect(accountInfo.makerFee, equals(0.1));
      expect(accountInfo.takerFee, equals(0.1));
    });

    test('should detect active status', () {
      final accountInfo = MCPAccountInfo(
        accountType: 'spot',
        exchange: 'kucoin',
        canTrade: true,
        canWithdraw: true,
        canDeposit: true,
        status: 'active',
      );

      expect(accountInfo.isActive, isTrue);
    });

    test('should detect full permissions', () {
      final accountInfo = MCPAccountInfo(
        accountType: 'spot',
        exchange: 'kucoin',
        canTrade: true,
        canWithdraw: true,
        canDeposit: true,
      );

      expect(accountInfo.hasFullPermissions, isTrue);
    });

    test('should calculate average fee', () {
      final accountInfo = MCPAccountInfo(
        accountType: 'spot',
        exchange: 'kucoin',
        canTrade: true,
        canWithdraw: true,
        canDeposit: true,
        makerFee: 0.1,
        takerFee: 0.2,
      );

      expect(accountInfo.averageFee, closeTo(0.15, 0.001));
    });
  });

  group('MCPBalance', () {
    test('should create from JSON correctly', () {
      final json = {
        'asset': 'BTC',
        'total': 1.5,
        'available': 1.0,
        'locked': 0.5,
        'exchange': 'kucoin',
        'value_usd': 60000.0,
      };

      final balance = MCPBalance.fromJson(json);

      expect(balance.asset, equals('BTC'));
      expect(balance.total, equals(1.5));
      expect(balance.available, equals(1.0));
      expect(balance.locked, equals(0.5));
      expect(balance.valueUsd, equals(60000.0));
    });

    test('should calculate total from available and locked', () {
      final json = {
        'asset': 'BTC',
        'available': 1.0,
        'locked': 0.5,
      };

      final balance = MCPBalance.fromJson(json);

      expect(balance.total, equals(1.5));
    });

    test('should calculate percentages correctly', () {
      final balance = MCPBalance(
        asset: 'BTC',
        total: 10.0,
        available: 7.0,
        locked: 3.0,
      );

      expect(balance.availablePercent, equals(70.0));
      expect(balance.lockedPercent, equals(30.0));
    });

    test('should detect available balance', () {
      final balance = MCPBalance(
        asset: 'BTC',
        total: 1.0,
        available: 0.5,
        locked: 0.5,
      );

      expect(balance.hasAvailable, isTrue);
      expect(balance.hasLocked, isTrue);
    });

    test('should detect empty balance', () {
      final balance = MCPBalance(
        asset: 'BTC',
        total: 0.0,
        available: 0.0,
        locked: 0.0,
      );

      expect(balance.isEmpty, isTrue);
    });

    test('should detect significant balance', () {
      final significant = MCPBalance(
        asset: 'BTC',
        total: 1.0,
        available: 1.0,
        locked: 0.0,
      );

      final insignificant = MCPBalance(
        asset: 'DUST',
        total: 0.00001,
        available: 0.00001,
        locked: 0.0,
      );

      expect(significant.isSignificant(), isTrue);
      expect(insignificant.isSignificant(), isFalse);
    });
  });

  group('MCPBalance List Extensions', () {
    late List<MCPBalance> balances;

    setUp(() {
      balances = [
        MCPBalance(
          asset: 'BTC',
          total: 1.0,
          available: 0.8,
          locked: 0.2,
          valueUsd: 40000.0,
        ),
        MCPBalance(
          asset: 'ETH',
          total: 10.0,
          available: 10.0,
          locked: 0.0,
          valueUsd: 20000.0,
        ),
        MCPBalance(
          asset: 'USDT',
          total: 1000.0,
          available: 1000.0,
          locked: 0.0,
          valueUsd: 1000.0,
        ),
        MCPBalance(
          asset: 'DUST',
          total: 0.00001,
          available: 0.00001,
          locked: 0.0,
          valueUsd: 0.01,
        ),
      ];
    });

    test('should filter balances with available', () {
      final withAvailable = balances.withAvailable;
      expect(withAvailable.length, equals(4));
    });

    test('should filter significant balances', () {
      final significant = balances.significant();
      expect(significant.length, equals(3));
    });

    test('should calculate total value USD', () {
      expect(balances.totalValueUsd, equals(61000.01));
    });

    test('should get balance by asset', () {
      final btcBalance = balances.getBalance('BTC');
      expect(btcBalance, isNotNull);
      expect(btcBalance!.asset, equals('BTC'));

      final unknownBalance = balances.getBalance('UNKNOWN');
      expect(unknownBalance, isNull);
    });

    test('should sort by total', () {
      final sorted = balances.sortByTotal();
      expect(sorted.first.asset, equals('USDT'));
      expect(sorted.last.asset, equals('DUST'));
    });

    test('should sort by value USD', () {
      final sorted = balances.sortByValueUsd();
      expect(sorted.first.asset, equals('BTC'));
      expect(sorted.last.asset, equals('DUST'));
    });
  });

  group('MCPPortfolio', () {
    late List<MCPBalance> balances;

    setUp(() {
      balances = [
        MCPBalance(
          asset: 'BTC',
          total: 1.0,
          available: 1.0,
          locked: 0.0,
          valueUsd: 40000.0,
        ),
        MCPBalance(
          asset: 'ETH',
          total: 10.0,
          available: 10.0,
          locked: 0.0,
          valueUsd: 20000.0,
        ),
        MCPBalance(
          asset: 'USDT',
          total: 10000.0,
          available: 10000.0,
          locked: 0.0,
          valueUsd: 10000.0,
        ),
      ];
    });

    test('should create from JSON correctly', () {
      final json = {
        'balances': balances.map((b) => b.toJson()).toList(),
        'total_value_usd': 70000.0,
        'exchange': 'kucoin',
      };

      final portfolio = MCPPortfolio.fromJson(json);

      expect(portfolio.balances.length, equals(3));
      expect(portfolio.totalValueUsd, equals(70000.0));
      expect(portfolio.exchange, equals('kucoin'));
    });

    test('should count assets correctly', () {
      final portfolio = MCPPortfolio(
        balances: balances,
        totalValueUsd: 70000.0,
        exchange: 'kucoin',
      );

      expect(portfolio.assetCount, equals(3));
    });

    test('should get largest holding', () {
      final portfolio = MCPPortfolio(
        balances: balances,
        totalValueUsd: 70000.0,
        exchange: 'kucoin',
      );

      expect(portfolio.largestHolding?.asset, equals('USDT'));
      expect(portfolio.largestHoldingByValue?.asset, equals('BTC'));
    });

    test('should calculate asset percentage', () {
      final portfolio = MCPPortfolio(
        balances: balances,
        totalValueUsd: 70000.0,
        exchange: 'kucoin',
      );

      final btcPercent = portfolio.getAssetPercentage('BTC');
      expect(btcPercent, closeTo(57.14, 0.01));
    });

    test('should calculate diversification score', () {
      final portfolio = MCPPortfolio(
        balances: balances,
        totalValueUsd: 70000.0,
        exchange: 'kucoin',
      );

      expect(portfolio.diversificationScore, greaterThan(0));
    });

    test('should detect concentrated portfolio', () {
      final concentrated = MCPPortfolio(
        balances: [
          MCPBalance(
            asset: 'BTC',
            total: 1.0,
            available: 1.0,
            locked: 0.0,
            valueUsd: 60000.0,
          ),
          MCPBalance(
            asset: 'ETH',
            total: 1.0,
            available: 1.0,
            locked: 0.0,
            valueUsd: 2000.0,
          ),
        ],
        totalValueUsd: 62000.0,
        exchange: 'kucoin',
      );

      expect(concentrated.isConcentrated, isTrue);
    });

    test('should get asset distribution', () {
      final portfolio = MCPPortfolio(
        balances: balances,
        totalValueUsd: 70000.0,
        exchange: 'kucoin',
      );

      final distribution = portfolio.getAssetDistribution();
      expect(distribution.length, equals(3));
      expect(distribution.first['asset'], equals('BTC'));
    });
  });
}
