import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';

import 'package:kuri_crypto/services/enhanced_trading_service.dart';
import 'package:kuri_crypto/services/matp_api_client.dart';
import 'package:kuri_crypto/services/mcp_tools_service.dart';
import 'package:kuri_crypto/models/position.dart';
import 'package:kuri_crypto/models/mcp_rsi_result.dart';
import 'package:kuri_crypto/models/mcp_macd_result.dart';
import 'package:kuri_crypto/models/mcp_bollinger_bands.dart';

import 'enhanced_trading_service_test.mocks.dart';

@GenerateMocks([MATPApiClient, MCPToolsService])
void main() {
  late EnhancedTradingService tradingService;
  late MockMATPApiClient mockMatpClient;
  late MockMCPToolsService mockMcpTools;

  setUp(() {
    mockMatpClient = MockMATPApiClient();
    mockMcpTools = MockMCPToolsService();
    tradingService = EnhancedTradingService(mockMatpClient, mockMcpTools);
  });

  group('EnhancedTradingService', () {
    group('Position Management', () {
      test('should get positions successfully', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'positions': [
              {
                'id': 'pos_1',
                'symbol': 'BTC-USDT',
                'side': 'long',
                'entry_price': 50000.0,
                'current_price': 51000.0,
                'size': 0.1,
                'leverage': 2.0,
                'unrealized_pnl': 100.0,
                'realized_pnl': 0.0,
                'open_time': DateTime.now().toIso8601String(),
                'strategy': 'test',
                'status': 'open',
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.get(
          '/api/v1/trading/positions',
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await tradingService.getPositions();

        // Assert
        expect(result, isA<List<Position>>());
        expect(result.length, equals(1));
        expect(result.first.symbol, equals('BTC-USDT'));
        verify(mockMatpClient.get(
          '/api/v1/trading/positions',
          queryParameters: anyNamed('queryParameters'),
        )).called(1);
      });

      test('should create position successfully', () async {
        // Arrange
        final request = CreatePositionRequest(
          symbol: 'BTC-USDT',
          side: 'long',
          size: 0.1,
          exchange: 'kucoin',
          performRiskAssessment: false, // Skip risk assessment for test
        );

        final mockResponse = Response(
          data: {
            'id': 'pos_1',
            'symbol': 'BTC-USDT',
            'side': 'long',
            'entry_price': 50000.0,
            'current_price': 50000.0,
            'size': 0.1,
            'leverage': 1.0,
            'unrealized_pnl': 0.0,
            'realized_pnl': 0.0,
            'open_time': DateTime.now().toIso8601String(),
            'strategy': 'manual',
            'status': 'open',
          },
          statusCode: 201,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.post(
          '/api/v1/trading/positions',
          data: anyNamed('data'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await tradingService.createPosition(request);

        // Assert
        expect(result, isA<Position>());
        expect(result.symbol, equals('BTC-USDT'));
        expect(result.side, equals('long'));
        verify(mockMatpClient.post(
          '/api/v1/trading/positions',
          data: anyNamed('data'),
        )).called(1);
      });

      test('should close position successfully', () async {
        // Arrange
        const positionId = 'pos_1';
        final mockResponse = Response(
          data: {
            'position_id': positionId,
            'status': 'closed',
            'exit_price': 51000.0,
            'realized_pnl': 100.0,
            'pnl_percent': 2.0,
            'closed_at': DateTime.now().toIso8601String(),
            'fees': 5.0,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.post(
          '/api/v1/trading/positions/$positionId/close',
          data: anyNamed('data'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await tradingService.closePosition(positionId);

        // Assert
        expect(result, isA<ClosePositionResult>());
        expect(result.positionId, equals(positionId));
        expect(result.status, equals('closed'));
        expect(result.isProfit, isTrue);
        verify(mockMatpClient.post(
          '/api/v1/trading/positions/$positionId/close',
          data: anyNamed('data'),
        )).called(1);
      });
    });

    group('Technical Analysis', () {
      test('should calculate RSI successfully', () async {
        // Arrange
        final mockRSI = MCPRSIResult(
          value: 65.0,
          signal: 'neutral',
          timestamp: DateTime.now(),
          exchange: 'kucoin',
          pair: 'BTC-USDT',
          period: 14,
        );

        when(mockMcpTools.calculateRSI(
          'kucoin',
          'BTC-USDT',
          period: anyNamed('period'),
          marketType: anyNamed('marketType'),
        )).thenAnswer((_) async => mockRSI);

        // Act
        final result = await tradingService.calculateRSI('kucoin', 'BTC-USDT');

        // Assert
        expect(result, equals(mockRSI));
        expect(result.value, equals(65.0));
        verify(mockMcpTools.calculateRSI(
          'kucoin',
          'BTC-USDT',
          period: anyNamed('period'),
          marketType: anyNamed('marketType'),
        )).called(1);
      });

      test('should get comprehensive technical analysis', () async {
        // Arrange
        final mockRSI = MCPRSIResult(
          value: 65.0,
          signal: 'neutral',
          timestamp: DateTime.now(),
          exchange: 'kucoin',
          pair: 'BTC-USDT',
          period: 14,
        );

        final mockMACD = MCPMACDResult(
          macd: 100.0,
          signal: 80.0,
          histogram: 20.0,
          trend: 'bullish',
          timestamp: DateTime.now(),
          exchange: 'kucoin',
          pair: 'BTC-USDT',
        );

        final mockBB = MCPBollingerBands(
          upper: 52000.0,
          middle: 50000.0,
          lower: 48000.0,
          currentPrice: 50500.0,
          position: 'within_bands',
          timestamp: DateTime.now(),
          exchange: 'kucoin',
          pair: 'BTC-USDT',
        );

        when(mockMcpTools.calculateRSI(
          'kucoin',
          'BTC-USDT',
          period: anyNamed('period'),
          marketType: anyNamed('marketType'),
        )).thenAnswer((_) async => mockRSI);

        when(mockMcpTools.calculateMACD(
          'kucoin',
          'BTC-USDT',
          fastPeriod: anyNamed('fastPeriod'),
          slowPeriod: anyNamed('slowPeriod'),
          signalPeriod: anyNamed('signalPeriod'),
          marketType: anyNamed('marketType'),
        )).thenAnswer((_) async => mockMACD);

        when(mockMcpTools.calculateBollingerBands(
          'kucoin',
          'BTC-USDT',
          period: anyNamed('period'),
          stdDev: anyNamed('stdDev'),
          marketType: anyNamed('marketType'),
        )).thenAnswer((_) async => mockBB);

        // Act
        final result =
            await tradingService.getTechnicalAnalysis('kucoin', 'BTC-USDT');

        // Assert
        expect(result, isA<TechnicalAnalysisResult>());
        expect(result.symbol, equals('BTC-USDT'));
        expect(result.exchange, equals('kucoin'));
        expect(result.rsi, equals(mockRSI));
        expect(result.macd, equals(mockMACD));
        expect(result.bollingerBands, equals(mockBB));
      });
    });

    group('Risk Assessment', () {
      test('should assess position risk successfully', () async {
        // Arrange
        final request = CreatePositionRequest(
          symbol: 'BTC-USDT',
          side: 'long',
          size: 0.1,
          exchange: 'kucoin',
        );

        final mockRiskResult = {
          'approved': true,
          'risk_score': 0.3,
          'metrics': {'volatility': 0.2, 'correlation': 0.1},
          'warnings': <String>[],
        };

        when(mockMcpTools.assessRisk(any))
            .thenAnswer((_) async => mockRiskResult);

        // Act
        final result = await tradingService.assessPositionRisk(request);

        // Assert
        expect(result, isA<RiskAssessmentResult>());
        expect(result.approved, isTrue);
        expect(result.riskScore, equals(0.3));
        verify(mockMcpTools.assessRisk(any)).called(1);
      });
    });
  });

  // ============================================================================
  // PROPERTY-BASED TESTS
  // ============================================================================

  group('Property-Based Tests', () {
    test(
        '**Feature: backend-integration-update, Property 21: Position Retrieval and Display**',
        () async {
      // **Validates: Requirements 5.1**
      // Property: For any request to view positions, the system should retrieve
      // current positions from MATP and display them accurately

      final testCases = [
        {
          'exchange': 'kucoin',
          'marketType': 'spot',
          'symbol': 'BTC-USDT',
          'expectedPositions': 2,
        },
        {
          'exchange': 'binance',
          'marketType': 'futures',
          'symbol': 'ETH-USDT',
          'expectedPositions': 1,
        },
        {
          'exchange': null,
          'marketType': null,
          'symbol': null,
          'expectedPositions': 3,
        },
      ];

      for (final testCase in testCases) {
        // Arrange
        final exchange = testCase['exchange'] as String?;
        final marketType = testCase['marketType'] as String?;
        final symbol = testCase['symbol'] as String?;
        final expectedCount = testCase['expectedPositions'] as int;

        final mockPositions = List.generate(
            expectedCount,
            (index) => {
                  'id': 'pos_$index',
                  'symbol': symbol ?? 'BTC-USDT',
                  'side': index % 2 == 0 ? 'long' : 'short',
                  'entry_price': 50000.0 + (index * 1000),
                  'current_price': 51000.0 + (index * 1000),
                  'size': 0.1 * (index + 1),
                  'leverage': 1.0 + index,
                  'unrealized_pnl': 100.0 * (index + 1),
                  'realized_pnl': 0.0,
                  'open_time': DateTime.now().toIso8601String(),
                  'strategy': 'test',
                  'status': 'open',
                });

        final mockResponse = Response(
          data: {'positions': mockPositions},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.get(
          '/api/v1/trading/positions',
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await tradingService.getPositions(
          exchange: exchange,
          marketType: marketType,
          symbol: symbol,
        );

        // Assert - Property: System should retrieve and display positions accurately
        expect(result, isA<List<Position>>());
        expect(result.length, equals(expectedCount));

        // Verify all positions have required fields
        for (final position in result) {
          expect(position.id, isNotEmpty);
          expect(position.symbol, isNotEmpty);
          expect(position.side, isIn(['long', 'short']));
          expect(position.entryPrice, greaterThan(0));
          expect(position.currentPrice, greaterThan(0));
          expect(position.size, greaterThan(0));
          expect(position.status, equals('open'));
        }

        // Verify correct API call was made
        verify(mockMatpClient.get(
          '/api/v1/trading/positions',
          queryParameters: argThat(
            predicate<Map<String, dynamic>?>((params) {
              if (params == null) {
                return exchange == null && marketType == null && symbol == null;
              }
              return (exchange == null || params['exchange'] == exchange) &&
                  (marketType == null || params['market_type'] == marketType) &&
                  (symbol == null || params['symbol'] == symbol);
            }),
            named: 'queryParameters',
          ),
        )).called(1);

        // Reset mock for next iteration
        reset(mockMatpClient);
      }
    });

    test(
        '**Feature: backend-integration-update, Property 22: Position Creation Validation**',
        () async {
      // **Validates: Requirements 5.2**
      // Property: For any position creation request, the system should validate
      // all parameters and submit orders via MATP with proper error handling

      final testCases = [
        {
          'symbol': 'BTC-USDT',
          'side': 'long',
          'size': 0.1,
          'exchange': 'kucoin',
          'marketType': 'spot',
          'shouldSucceed': true,
        },
        {
          'symbol': 'ETH-USDT',
          'side': 'short',
          'size': 0.5,
          'exchange': 'binance',
          'marketType': 'futures',
          'shouldSucceed': true,
        },
        {
          'symbol': '', // Invalid symbol
          'side': 'long',
          'size': 0.1,
          'exchange': 'kucoin',
          'marketType': 'spot',
          'shouldSucceed': false,
        },
        {
          'symbol': 'ADA-USDT',
          'side': 'invalid', // Invalid side
          'size': 0.1,
          'exchange': 'kucoin',
          'marketType': 'spot',
          'shouldSucceed': false,
        },
        {
          'symbol': 'ADA-USDT',
          'side': 'long',
          'size': 0.0, // Invalid size
          'exchange': 'kucoin',
          'marketType': 'spot',
          'shouldSucceed': false,
        },
      ];

      for (final testCase in testCases) {
        // Arrange
        final request = CreatePositionRequest(
          symbol: testCase['symbol'] as String,
          side: testCase['side'] as String,
          size: testCase['size'] as double,
          exchange: testCase['exchange'] as String,
          marketType: testCase['marketType'] as String,
          performRiskAssessment:
              false, // Skip risk assessment for validation test
        );

        final shouldSucceed = testCase['shouldSucceed'] as bool;

        if (shouldSucceed) {
          final mockResponse = Response(
            data: {
              'id': 'pos_${DateTime.now().millisecondsSinceEpoch}',
              'symbol': request.symbol,
              'side': request.side,
              'entry_price': 50000.0,
              'current_price': 50000.0,
              'size': request.size,
              'leverage': 1.0,
              'unrealized_pnl': 0.0,
              'realized_pnl': 0.0,
              'open_time': DateTime.now().toIso8601String(),
              'strategy': 'manual',
              'status': 'open',
            },
            statusCode: 201,
            requestOptions: RequestOptions(path: ''),
          );

          when(mockMatpClient.post(
            '/api/v1/trading/positions',
            data: anyNamed('data'),
          )).thenAnswer((_) async => mockResponse);
        }

        // Act & Assert
        if (shouldSucceed) {
          final result = await tradingService.createPosition(request);

          // Assert - Property: System should validate parameters and create position
          expect(result, isA<Position>());
          expect(result.symbol, equals(request.symbol));
          expect(result.side, equals(request.side));
          expect(result.size, equals(request.size));

          verify(mockMatpClient.post(
            '/api/v1/trading/positions',
            data: argThat(
              predicate<Map<String, dynamic>>((data) =>
                  data['symbol'] == request.symbol &&
                  data['side'] == request.side &&
                  data['size'] == request.size &&
                  data['exchange'] == request.exchange &&
                  data['market_type'] == request.marketType),
              named: 'data',
            ),
          )).called(1);
        } else {
          // Assert - Property: System should reject invalid parameters
          expect(
            () => tradingService.createPosition(request),
            throwsA(isA<Exception>()),
          );
        }

        // Reset mock for next iteration
        reset(mockMatpClient);
      }
    });

    test(
        '**Feature: backend-integration-update, Property 23: Real-Time Position Updates**',
        () async {
      // **Validates: Requirements 5.3**
      // Property: For any position update that occurs, the system should reflect
      // changes in the UI immediately

      final testCases = [
        {
          'symbols': ['BTC-USDT'],
          'expectedUpdates': 1,
        },
        {
          'symbols': ['BTC-USDT', 'ETH-USDT'],
          'expectedUpdates': 2,
        },
        {
          'symbols': null, // All symbols
          'expectedUpdates': 3,
        },
      ];

      for (final testCase in testCases) {
        // Arrange
        final symbols = testCase['symbols'] as List<String>?;
        final expectedUpdates = testCase['expectedUpdates'] as int;

        final mockPositions = List.generate(
            expectedUpdates,
            (index) => Position(
                  id: 'pos_$index',
                  symbol: symbols?[index % symbols.length] ?? 'BTC-USDT',
                  side: 'long',
                  entryPrice: 50000.0,
                  currentPrice:
                      51000.0 + (index * 100), // Simulate price changes
                  size: 0.1,
                  openTime: DateTime.now(),
                  strategy: 'test',
                ));

        final mockResponse = Response(
          data: {
            'positions': mockPositions.map((p) => p.toJson()).toList(),
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.get(
          '/api/v1/trading/positions',
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final updateStream = tradingService.subscribeToPositionUpdates(
          symbols: symbols,
        );

        final updates = <PositionUpdate>[];
        final subscription = updateStream.listen((update) {
          updates.add(update);
        });

        // Wait for at least one update cycle
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - Property: System should reflect position changes immediately
        expect(updates, isNotEmpty);

        for (final update in updates) {
          expect(update.type, equals('position_update'));
          expect(update.position, isA<Position>());
          expect(update.timestamp, isA<DateTime>());

          // Verify position data is current
          expect(update.position.currentPrice, greaterThan(0));
          if (symbols != null) {
            expect(symbols, contains(update.position.symbol));
          }
        }

        // Cleanup
        await subscription.cancel();

        // Reset mock for next iteration
        reset(mockMatpClient);
      }
    });

    test(
        '**Feature: backend-integration-update, Property 24: Risk Limit Enforcement**',
        () async {
      // **Validates: Requirements 5.4**
      // Property: For any position creation that would exceed risk limits,
      // the system should prevent the creation and warn the user

      final testCases = [
        {
          'symbol': 'BTC-USDT',
          'size': 0.1,
          'riskScore': 0.3, // Low risk
          'approved': true,
          'shouldCreatePosition': true,
        },
        {
          'symbol': 'ETH-USDT',
          'size': 1.0,
          'riskScore': 0.9, // High risk
          'approved': false,
          'shouldCreatePosition': false,
        },
        {
          'symbol': 'ADA-USDT',
          'size': 0.5,
          'riskScore': 0.7, // Medium risk
          'approved': true,
          'shouldCreatePosition': true,
        },
      ];

      for (final testCase in testCases) {
        // Arrange
        final request = CreatePositionRequest(
          symbol: testCase['symbol'] as String,
          side: 'long',
          size: testCase['size'] as double,
          exchange: 'kucoin',
          performRiskAssessment: true, // Enable risk assessment
        );

        final riskScore = testCase['riskScore'] as double;
        final approved = testCase['approved'] as bool;
        final shouldCreatePosition = testCase['shouldCreatePosition'] as bool;

        final mockRiskResult = {
          'approved': approved,
          'reason': approved ? null : 'Risk limits exceeded',
          'risk_score': riskScore,
          'metrics': {'volatility': riskScore},
          'warnings': approved ? <String>[] : ['High risk position'],
        };

        when(mockMcpTools.assessRisk(any))
            .thenAnswer((_) async => mockRiskResult);

        if (shouldCreatePosition) {
          final mockResponse = Response(
            data: {
              'id': 'pos_${DateTime.now().millisecondsSinceEpoch}',
              'symbol': request.symbol,
              'side': request.side,
              'entry_price': 50000.0,
              'current_price': 50000.0,
              'size': request.size,
              'leverage': 1.0,
              'unrealized_pnl': 0.0,
              'realized_pnl': 0.0,
              'open_time': DateTime.now().toIso8601String(),
              'strategy': 'manual',
              'status': 'open',
            },
            statusCode: 201,
            requestOptions: RequestOptions(path: ''),
          );

          when(mockMatpClient.post(
            '/api/v1/trading/positions',
            data: anyNamed('data'),
          )).thenAnswer((_) async => mockResponse);
        }

        // Act & Assert
        if (shouldCreatePosition) {
          final result = await tradingService.createPosition(request);

          // Assert - Property: System should allow low-risk positions
          expect(result, isA<Position>());
          expect(result.symbol, equals(request.symbol));

          verify(mockMcpTools.assessRisk(any)).called(1);
          verify(mockMatpClient.post(
            '/api/v1/trading/positions',
            data: anyNamed('data'),
          )).called(1);
        } else {
          // Assert - Property: System should prevent high-risk positions and warn user
          expect(
            () => tradingService.createPosition(request),
            throwsA(predicate((e) =>
                e.toString().contains('risk assessment') ||
                e.toString().contains('Risk limits exceeded'))),
          );

          verify(mockMcpTools.assessRisk(any)).called(1);
          verifyNever(mockMatpClient.post(
            '/api/v1/trading/positions',
            data: anyNamed('data'),
          ));
        }

        // Reset mocks for next iteration
        reset(mockMcpTools);
        reset(mockMatpClient);
      }
    });

    test(
        '**Feature: backend-integration-update, Property 25: Position Closing Updates**',
        () async {
      // **Validates: Requirements 5.5**
      // Property: For any position that is closed, the system should update
      // the UI immediately and display the final PnL

      final testCases = [
        {
          'positionId': 'pos_1',
          'exitPrice': 51000.0,
          'realizedPnl': 100.0,
          'pnlPercent': 2.0,
          'isProfit': true,
        },
        {
          'positionId': 'pos_2',
          'exitPrice': 49000.0,
          'realizedPnl': -100.0,
          'pnlPercent': -2.0,
          'isProfit': false,
        },
        {
          'positionId': 'pos_3',
          'exitPrice': 50000.0,
          'realizedPnl': 0.0,
          'pnlPercent': 0.0,
          'isProfit': false,
        },
      ];

      for (final testCase in testCases) {
        // Arrange
        final positionId = testCase['positionId'] as String;
        final exitPrice = testCase['exitPrice'] as double;
        final realizedPnl = testCase['realizedPnl'] as double;
        final pnlPercent = testCase['pnlPercent'] as double;
        final isProfit = testCase['isProfit'] as bool;

        final mockResponse = Response(
          data: {
            'position_id': positionId,
            'status': 'closed',
            'exit_price': exitPrice,
            'realized_pnl': realizedPnl,
            'pnl_percent': pnlPercent,
            'closed_at': DateTime.now().toIso8601String(),
            'fees': 5.0,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.post(
          '/api/v1/trading/positions/$positionId/close',
          data: anyNamed('data'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await tradingService.closePosition(positionId);

        // Assert - Property: System should update UI immediately and display final PnL
        expect(result, isA<ClosePositionResult>());
        expect(result.positionId, equals(positionId));
        expect(result.status, equals('closed'));
        expect(result.exitPrice, equals(exitPrice));
        expect(result.realizedPnl, equals(realizedPnl));
        expect(result.pnlPercent, equals(pnlPercent));
        expect(result.isProfit, equals(isProfit));
        expect(result.closedAt, isA<DateTime>());

        // Verify the close request was made
        verify(mockMatpClient.post(
          '/api/v1/trading/positions/$positionId/close',
          data: anyNamed('data'),
        )).called(1);

        // Reset mock for next iteration
        reset(mockMatpClient);
      }
    });
  });
}
