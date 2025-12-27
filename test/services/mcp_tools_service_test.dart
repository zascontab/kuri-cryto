import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kuri_crypto/services/mcp_tools_service.dart';
import 'package:kuri_crypto/services/mcp_service.dart';
import 'package:kuri_crypto/models/mcp_ticker.dart';
import 'package:kuri_crypto/models/mcp_candle.dart';
import 'package:kuri_crypto/models/mcp_rsi_result.dart';
import 'package:kuri_crypto/models/mcp_macd_result.dart';
import 'package:kuri_crypto/models/mcp_bollinger_bands.dart';
import 'package:kuri_crypto/models/mcp_account_info.dart';
import 'package:kuri_crypto/models/mcp_balance.dart';
import 'package:kuri_crypto/models/mcp_portfolio.dart';
import 'package:kuri_crypto/services/api_exception.dart';

// Generate mocks
@GenerateMocks([MCPService])
import 'mcp_tools_service_test.mocks.dart';

void main() {
  late MockMCPService mockMCPService;
  late MCPToolsService mcpToolsService;

  setUp(() {
    mockMCPService = MockMCPService();
    mcpToolsService = MCPToolsService(mockMCPService);
  });

  group('MCPToolsService - Market Data', () {
    test('getTicker should return valid ticker data', () async {
      // Arrange
      final mockTicker = MCPTicker(
        exchange: 'kucoin',
        pair: 'BTC-USDT',
        last: 50000.0,
        bid: 49999.0,
        ask: 50001.0,
        volume24h: 1000.0,
        high24h: 51000.0,
        low24h: 49000.0,
        change24h: 1000.0,
        change24hPercent: 2.0,
        timestamp: DateTime.now(),
      );

      when(mockMCPService.callToolTyped<MCPTicker>(
        toolName: 'get_ticker',
        arguments: anyNamed('arguments'),
        marketType: anyNamed('marketType'),
        fromJson: anyNamed('fromJson'),
      )).thenAnswer((_) async => mockTicker);

      // Act
      final result = await mcpToolsService.getTicker('kucoin', 'BTC-USDT');

      // Assert
      expect(result, equals(mockTicker));
      verify(mockMCPService.callToolTyped<MCPTicker>(
        toolName: 'get_ticker',
        arguments: {
          'exchange': 'kucoin',
          'pair': 'BTC-USDT',
        },
        marketType: null,
        fromJson: anyNamed('fromJson'),
      )).called(1);
    });

    test('getCandles should return list of candles', () async {
      // Arrange
      final mockCandles = [
        MCPCandle(
          timestamp: DateTime.now(),
          open: 50000.0,
          high: 50100.0,
          low: 49900.0,
          close: 50050.0,
          volume: 100.0,
        ),
      ];

      when(mockMCPService.callTool(
        toolName: 'get_candles',
        arguments: anyNamed('arguments'),
        marketType: anyNamed('marketType'),
      )).thenAnswer((_) async => {
            'candles': mockCandles.map((c) => c.toJson()).toList(),
          });

      // Act
      final result = await mcpToolsService.getCandles(
        'kucoin',
        'BTC-USDT',
        '1h',
        100,
      );

      // Assert
      expect(result, hasLength(1));
      expect(result.first.close, equals(50050.0));
    });

    test('getMarkets should return list of trading pairs', () async {
      // Arrange
      final mockMarkets = ['BTC-USDT', 'ETH-USDT', 'ADA-USDT'];

      when(mockMCPService.callTool(
        toolName: 'get_markets',
        arguments: anyNamed('arguments'),
        marketType: anyNamed('marketType'),
      )).thenAnswer((_) async => {
            'markets': mockMarkets,
          });

      // Act
      final result = await mcpToolsService.getMarkets('kucoin');

      // Assert
      expect(result, equals(mockMarkets));
    });
  });

  group('MCPToolsService - Technical Indicators', () {
    test('calculateRSI should return RSI result', () async {
      // Arrange
      final mockRSI = MCPRSIResult(
        value: 65.5,
        signal: 'neutral',
        timestamp: DateTime.now(),
        exchange: 'kucoin',
        pair: 'BTC-USDT',
        period: 14,
      );

      when(mockMCPService.callToolTyped<MCPRSIResult>(
        toolName: 'calculate_rsi',
        arguments: anyNamed('arguments'),
        marketType: anyNamed('marketType'),
        fromJson: anyNamed('fromJson'),
      )).thenAnswer((_) async => mockRSI);

      // Act
      final result = await mcpToolsService.calculateRSI('kucoin', 'BTC-USDT');

      // Assert
      expect(result, equals(mockRSI));
      expect(result.value, equals(65.5));
      expect(result.signal, equals('neutral'));
    });

    test('calculateMACD should return MACD result', () async {
      // Arrange
      final mockMACD = MCPMACDResult(
        macd: 100.0,
        signal: 95.0,
        histogram: 5.0,
        trend: 'bullish',
        timestamp: DateTime.now(),
        exchange: 'kucoin',
        pair: 'BTC-USDT',
      );

      when(mockMCPService.callToolTyped<MCPMACDResult>(
        toolName: 'calculate_macd',
        arguments: anyNamed('arguments'),
        marketType: anyNamed('marketType'),
        fromJson: anyNamed('fromJson'),
      )).thenAnswer((_) async => mockMACD);

      // Act
      final result = await mcpToolsService.calculateMACD('kucoin', 'BTC-USDT');

      // Assert
      expect(result, equals(mockMACD));
      expect(result.macd, equals(100.0));
      expect(result.histogram, equals(5.0));
    });

    test('calculateBollingerBands should return Bollinger Bands result',
        () async {
      // Arrange
      final mockBB = MCPBollingerBands(
        upper: 51000.0,
        middle: 50000.0,
        lower: 49000.0,
        currentPrice: 50500.0,
        timestamp: DateTime.now(),
        exchange: 'kucoin',
        pair: 'BTC-USDT',
        period: 20,
        stdDev: 2.0,
      );

      when(mockMCPService.callToolTyped<MCPBollingerBands>(
        toolName: 'calculate_bollinger_bands',
        arguments: anyNamed('arguments'),
        marketType: anyNamed('marketType'),
        fromJson: anyNamed('fromJson'),
      )).thenAnswer((_) async => mockBB);

      // Act
      final result = await mcpToolsService.calculateBollingerBands(
        'kucoin',
        'BTC-USDT',
      );

      // Assert
      expect(result, equals(mockBB));
      expect(result.upper, equals(51000.0));
      expect(result.lower, equals(49000.0));
    });
  });

  group('MCPToolsService - Account Management', () {
    test('getAccountInfo should return account information', () async {
      // Arrange
      final mockAccountInfo = MCPAccountInfo(
        accountType: 'spot',
        makerFee: 0.1,
        takerFee: 0.1,
        canTrade: true,
        canWithdraw: true,
        canDeposit: true,
        permissions: ['spot'],
        balances: [],
      );

      when(mockMCPService.callToolTyped<MCPAccountInfo>(
        toolName: 'get_account_info',
        arguments: anyNamed('arguments'),
        fromJson: anyNamed('fromJson'),
      )).thenAnswer((_) async => mockAccountInfo);

      // Act
      final result = await mcpToolsService.getAccountInfo('kucoin');

      // Assert
      expect(result, equals(mockAccountInfo));
      expect(result.accountType, equals('spot'));
      expect(result.canTrade, isTrue);
    });

    test('getBalance should return balance information', () async {
      // Arrange
      final mockBalance = MCPBalance(
        asset: 'BTC',
        available: 1.0,
        locked: 0.1,
        total: 1.1,
        valueUsd: 50000.0,
      );

      when(mockMCPService.callToolTyped<MCPBalance>(
        toolName: 'get_balance',
        arguments: anyNamed('arguments'),
        fromJson: anyNamed('fromJson'),
      )).thenAnswer((_) async => mockBalance);

      // Act
      final result = await mcpToolsService.getBalance('kucoin', 'BTC');

      // Assert
      expect(result, equals(mockBalance));
      expect(result.asset, equals('BTC'));
      expect(result.total, equals(1.1));
    });

    test('getPortfolio should return portfolio information', () async {
      // Arrange
      final mockPortfolio = MCPPortfolio(
        balances: [
          MCPBalance(
            asset: 'BTC',
            available: 1.0,
            locked: 0.0,
            total: 1.0,
            valueUsd: 50000.0,
          ),
        ],
        totalValueUsd: 50000.0,
      );

      when(mockMCPService.callToolTyped<MCPPortfolio>(
        toolName: 'get_portfolio',
        arguments: anyNamed('arguments'),
        fromJson: anyNamed('fromJson'),
      )).thenAnswer((_) async => mockPortfolio);

      // Act
      final result = await mcpToolsService.getPortfolio();

      // Assert
      expect(result, equals(mockPortfolio));
      expect(result.totalValueUsd, equals(50000.0));
      expect(result.balances, hasLength(1));
    });
  });

  group('MCPToolsService - Error Handling', () {
    test('should handle API exceptions gracefully', () async {
      // Arrange
      when(mockMCPService.callToolTyped<MCPTicker>(
        toolName: anyNamed('toolName'),
        arguments: anyNamed('arguments'),
        marketType: anyNamed('marketType'),
        fromJson: anyNamed('fromJson'),
      )).thenThrow(ApiException(
        message: 'Network error',
        code: 'NETWORK_ERROR',
      ));

      // Act & Assert
      expect(
        () => mcpToolsService.getTicker('kucoin', 'BTC-USDT'),
        throwsA(isA<ApiException>()),
      );
    });

    test('should handle invalid parameters', () async {
      // Arrange
      when(mockMCPService.callTool(
        toolName: anyNamed('toolName'),
        arguments: anyNamed('arguments'),
        marketType: anyNamed('marketType'),
      )).thenThrow(ApiException(
        message: 'Invalid parameters',
        code: 'INVALID_PARAMS',
      ));

      // Act & Assert
      expect(
        () => mcpToolsService.getCandles('', '', '', -1),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ============================================================================
  // PROPERTY-BASED TESTS
  // ============================================================================

  group('Property-Based Tests', () {
    test(
        '**Feature: backend-integration-update, Property 11: Technical Indicator Calculation**',
        () async {
      // **Validates: Requirements 3.1**
      // Property: For any request for technical indicators (RSI, MACD, Bollinger Bands),
      // the system should call the appropriate MCP tools and return calculated values

      final testCases = [
        {
          'exchange': 'kucoin',
          'pair': 'BTC-USDT',
          'tool': 'calculate_rsi',
          'expectedCall': 'calculate_rsi'
        },
        {
          'exchange': 'binance',
          'pair': 'ETH-USDT',
          'tool': 'calculate_macd',
          'expectedCall': 'calculate_macd'
        },
        {
          'exchange': 'kucoin',
          'pair': 'ADA-USDT',
          'tool': 'calculate_bollinger_bands',
          'expectedCall': 'calculate_bollinger_bands'
        },
      ];

      for (final testCase in testCases) {
        // Arrange
        final exchange = testCase['exchange'] as String;
        final pair = testCase['pair'] as String;
        final tool = testCase['tool'] as String;
        final expectedCall = testCase['expectedCall'] as String;

        // Mock different responses based on tool type
        if (tool == 'calculate_rsi') {
          when(mockMCPService.callToolTyped<MCPRSIResult>(
            toolName: expectedCall,
            arguments: anyNamed('arguments'),
            marketType: anyNamed('marketType'),
            fromJson: anyNamed('fromJson'),
          )).thenAnswer((_) async => MCPRSIResult(
                value: 65.0,
                signal: 'neutral',
                timestamp: DateTime.now(),
                exchange: exchange,
                pair: pair,
                period: 14,
              ));

          // Act
          final result = await mcpToolsService.calculateRSI(exchange, pair);

          // Assert
          expect(result.exchange, equals(exchange));
          expect(result.pair, equals(pair));
          expect(result.value, greaterThan(0));
          expect(result.value, lessThanOrEqualTo(100));
        } else if (tool == 'calculate_macd') {
          when(mockMCPService.callToolTyped<MCPMACDResult>(
            toolName: expectedCall,
            arguments: anyNamed('arguments'),
            marketType: anyNamed('marketType'),
            fromJson: anyNamed('fromJson'),
          )).thenAnswer((_) async => MCPMACDResult(
                macd: 100.0,
                signal: 95.0,
                histogram: 5.0,
                trend: 'bullish',
                timestamp: DateTime.now(),
                exchange: exchange,
                pair: pair,
              ));

          // Act
          final result = await mcpToolsService.calculateMACD(exchange, pair);

          // Assert
          expect(result.exchange, equals(exchange));
          expect(result.pair, equals(pair));
          expect(result.histogram, equals(result.macd - result.signal));
        } else if (tool == 'calculate_bollinger_bands') {
          when(mockMCPService.callToolTyped<MCPBollingerBands>(
            toolName: expectedCall,
            arguments: anyNamed('arguments'),
            marketType: anyNamed('marketType'),
            fromJson: anyNamed('fromJson'),
          )).thenAnswer((_) async => MCPBollingerBands(
                upper: 51000.0,
                middle: 50000.0,
                lower: 49000.0,
                currentPrice: 50500.0,
                timestamp: DateTime.now(),
                exchange: exchange,
                pair: pair,
                period: 20,
                stdDev: 2.0,
              ));

          // Act
          final result = await mcpToolsService.calculateBollingerBands(
            exchange,
            pair,
          );

          // Assert
          expect(result.exchange, equals(exchange));
          expect(result.pair, equals(pair));
          expect(result.upper, greaterThan(result.middle));
          expect(result.middle, greaterThan(result.lower));
        }

        // Verify the correct MCP tool was called
        verify(mockMCPService.callToolTyped(
          toolName: expectedCall,
          arguments: argThat(
            contains('exchange'),
            named: 'arguments',
          ),
          marketType: anyNamed('marketType'),
          fromJson: anyNamed('fromJson'),
        )).called(1);

        // Reset mocks for next iteration
        reset(mockMCPService);
      }
    });

    test(
        '**Feature: backend-integration-update, Property 31: Backtest Execution**',
        () async {
      // **Validates: Requirements 7.1**
      // Property: For any backtest initiation, the system should call MCP backtest tools
      // with specified parameters and return results

      final testRequests = [
        {
          'strategy': 'rsi_strategy',
          'symbol': 'BTC-USDT',
          'start_date': '2023-01-01',
          'end_date': '2023-12-31',
          'initial_capital': 10000.0,
        },
        {
          'strategy': 'macd_strategy',
          'symbol': 'ETH-USDT',
          'start_date': '2023-06-01',
          'end_date': '2023-12-31',
          'initial_capital': 5000.0,
        },
        {
          'strategy': 'bb_strategy',
          'symbol': 'ADA-USDT',
          'start_date': '2023-03-01',
          'end_date': '2023-09-30',
          'initial_capital': 1000.0,
        },
      ];

      for (final request in testRequests) {
        // Arrange
        final mockResult = {
          'backtest_id': 'test_${DateTime.now().millisecondsSinceEpoch}',
          'strategy': request['strategy'],
          'symbol': request['symbol'],
          'total_return': 15.5,
          'sharpe_ratio': 1.2,
          'max_drawdown': -5.8,
          'total_trades': 45,
          'win_rate': 0.67,
          'profit_factor': 1.8,
        };

        when(mockMCPService.callTool(
          toolName: 'run_backtest',
          arguments: anyNamed('arguments'),
        )).thenAnswer((_) async => mockResult);

        // Act
        final result = await mcpToolsService.runBacktest(request);

        // Assert
        expect(result['strategy'], equals(request['strategy']));
        expect(result['symbol'], equals(request['symbol']));
        expect(result['total_return'], isA<num>());
        expect(result['sharpe_ratio'], isA<num>());
        expect(result['max_drawdown'], isA<num>());
        expect(result['total_trades'], isA<num>());
        expect(result['win_rate'], isA<num>());
        expect(result['profit_factor'], isA<num>());

        // Verify the backtest tool was called with correct parameters
        verify(mockMCPService.callTool(
          toolName: 'run_backtest',
          arguments: request,
        )).called(1);

        // Reset for next iteration
        reset(mockMCPService);
      }
    });

    test(
        '**Feature: backend-integration-update, Property 33: Strategy Optimization**',
        () async {
      // **Validates: Requirements 7.3**
      // Property: For any strategy optimization request, the system should run parameter
      // optimization via MCP tools and return optimal parameters

      final testRequests = [
        {
          'strategy': 'rsi_strategy',
          'symbol': 'BTC-USDT',
          'parameters': {
            'rsi_period': {'min': 10, 'max': 20, 'step': 1},
            'rsi_overbought': {'min': 70, 'max': 80, 'step': 1},
            'rsi_oversold': {'min': 20, 'max': 30, 'step': 1},
          },
          'optimization_metric': 'sharpe_ratio',
        },
        {
          'strategy': 'macd_strategy',
          'symbol': 'ETH-USDT',
          'parameters': {
            'fast_period': {'min': 8, 'max': 16, 'step': 1},
            'slow_period': {'min': 20, 'max': 30, 'step': 1},
            'signal_period': {'min': 7, 'max': 12, 'step': 1},
          },
          'optimization_metric': 'total_return',
        },
      ];

      for (final request in testRequests) {
        // Arrange
        final mockResult = {
          'optimization_id': 'opt_${DateTime.now().millisecondsSinceEpoch}',
          'strategy': request['strategy'],
          'symbol': request['symbol'],
          'best_parameters': {
            'rsi_period': 14,
            'rsi_overbought': 75,
            'rsi_oversold': 25,
          },
          'best_performance': {
            'total_return': 22.3,
            'sharpe_ratio': 1.45,
            'max_drawdown': -4.2,
          },
          'iterations_completed': 100,
          'optimization_time': 45.6,
        };

        when(mockMCPService.callTool(
          toolName: 'optimize_parameters',
          arguments: anyNamed('arguments'),
        )).thenAnswer((_) async => mockResult);

        // Act
        final result = await mcpToolsService.optimizeParameters(request);

        // Assert
        expect(result['strategy'], equals(request['strategy']));
        expect(result['symbol'], equals(request['symbol']));
        expect(result['best_parameters'], isA<Map>());
        expect(result['best_performance'], isA<Map>());
        expect(result['iterations_completed'], isA<num>());
        expect(result['optimization_time'], isA<num>());

        // Verify optimization tool was called
        verify(mockMCPService.callTool(
          toolName: 'optimize_parameters',
          arguments: request,
        )).called(1);

        // Reset for next iteration
        reset(mockMCPService);
      }
    });

    test(
        '**Feature: backend-integration-update, Property 34: Strategy Comparison**',
        () async {
      // **Validates: Requirements 7.4**
      // Property: For any request to compare multiple strategies, the system should
      // display comparative analysis results with clear metrics

      final testStrategies = [
        [
          {'name': 'rsi_strategy', 'symbol': 'BTC-USDT'},
          {'name': 'macd_strategy', 'symbol': 'BTC-USDT'},
        ],
        [
          {'name': 'bb_strategy', 'symbol': 'ETH-USDT'},
          {'name': 'sma_strategy', 'symbol': 'ETH-USDT'},
          {'name': 'ema_strategy', 'symbol': 'ETH-USDT'},
        ],
      ];

      for (final strategies in testStrategies) {
        // Arrange
        final mockResult = {
          'comparison_id': 'comp_${DateTime.now().millisecondsSinceEpoch}',
          'strategies_compared': strategies.length,
          'results': strategies
              .map((strategy) => {
                    'strategy': strategy['name'],
                    'symbol': strategy['symbol'],
                    'total_return': 15.0 + (strategies.indexOf(strategy) * 2.5),
                    'sharpe_ratio': 1.2 + (strategies.indexOf(strategy) * 0.1),
                    'max_drawdown': -5.0 - (strategies.indexOf(strategy) * 0.5),
                    'win_rate': 0.65 + (strategies.indexOf(strategy) * 0.02),
                  })
              .toList(),
          'best_strategy': strategies.first['name'],
          'ranking_metric': 'sharpe_ratio',
        };

        when(mockMCPService.callTool(
          toolName: 'compare_strategies',
          arguments: anyNamed('arguments'),
        )).thenAnswer((_) async => mockResult);

        // Act
        final result = await mcpToolsService.compareStrategies(strategies);

        // Assert
        expect(result['strategies_compared'], equals(strategies.length));
        expect(result['results'], isA<List>());
        expect(result['results'], hasLength(strategies.length));
        expect(result['best_strategy'], isA<String>());
        expect(result['ranking_metric'], isA<String>());

        // Verify each strategy result has required metrics
        final results = result['results'] as List;
        for (final strategyResult in results) {
          expect(strategyResult['strategy'], isA<String>());
          expect(strategyResult['symbol'], isA<String>());
          expect(strategyResult['total_return'], isA<num>());
          expect(strategyResult['sharpe_ratio'], isA<num>());
          expect(strategyResult['max_drawdown'], isA<num>());
          expect(strategyResult['win_rate'], isA<num>());
        }

        // Verify comparison tool was called
        verify(mockMCPService.callTool(
          toolName: 'compare_strategies',
          arguments: {'strategies': strategies},
        )).called(1);

        // Reset for next iteration
        reset(mockMCPService);
      }
    });
  });
}
