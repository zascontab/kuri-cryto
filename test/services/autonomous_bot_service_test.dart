import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';

import 'package:kuri_crypto/services/autonomous_bot_service.dart';
import 'package:kuri_crypto/services/matp_api_client.dart';
import 'package:kuri_crypto/models/bot_status.dart';
import 'package:kuri_crypto/models/bot_config.dart';
import 'package:kuri_crypto/models/bot_action_response.dart';

import 'autonomous_bot_service_test.mocks.dart';

@GenerateMocks([MATPApiClient])
void main() {
  late AutonomousBotService botService;
  late MockMATPApiClient mockMatpClient;

  setUp(() {
    mockMatpClient = MockMATPApiClient();
    botService = AutonomousBotService(mockMatpClient);
  });

  group('AutonomousBotService', () {
    group('Bot Control', () {
      test('should start bot successfully', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'ai_enabled': true,
            'status': 'running',
            'is_running': true,
            'last_action': 'start',
            'error_message': null,
            'metadata': {'started_at': DateTime.now().toIso8601String()},
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.post('/api/v1/bot/start'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await botService.startBot();

        // Assert
        expect(result, isA<BotStatus>());
        expect(result.status, equals('running'));
        expect(result.isRunning, isTrue);
        verify(mockMatpClient.post('/api/v1/bot/start')).called(1);
      });

      test('should stop bot successfully', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'ai_enabled': false,
            'status': 'stopped',
            'is_running': false,
            'last_action': 'stop',
            'error_message': null,
            'metadata': {'stopped_at': DateTime.now().toIso8601String()},
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.post('/api/v1/bot/stop'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await botService.stopBot();

        // Assert
        expect(result, isA<BotStatus>());
        expect(result.status, equals('stopped'));
        expect(result.isRunning, isFalse);
        verify(mockMatpClient.post('/api/v1/bot/stop')).called(1);
      });

      test('should execute emergency stop successfully', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'success': true,
            'message': 'Emergency stop executed successfully',
            'action': 'emergency_stop',
            'timestamp': DateTime.now().toIso8601String(),
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.post('/api/v1/bot/emergency-stop'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await botService.emergencyStop();

        // Assert
        expect(result, isA<BotActionResponse>());
        expect(result.success, isTrue);
        expect(result.message, contains('Emergency stop'));
        verify(mockMatpClient.post('/api/v1/bot/emergency-stop')).called(1);
      });
    });

    group('Configuration Management', () {
      test('should get bot configuration successfully', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'confidence_threshold': 0.8,
            'dry_run': false,
            'max_positions': 5,
            'max_risk_per_trade': 0.02,
            'symbols': ['BTC-USDT', 'ETH-USDT'],
            'use_stop_loss': true,
            'use_take_profit': true,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.get('/api/v1/bot/config'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await botService.getBotConfig();

        // Assert
        expect(result, isA<BotConfig>());
        expect(result.confidenceThreshold, equals(0.8));
        expect(result.dryRun, isFalse);
        expect(result.maxPositions, equals(5));
        verify(mockMatpClient.get('/api/v1/bot/config')).called(1);
      });

      test('should update bot configuration successfully', () async {
        // Arrange
        const config = BotConfig(
          confidenceThreshold: 0.75,
          dryRun: true,
          maxPositions: 3,
          maxRiskPerTrade: 0.01,
          symbols: ['BTC-USDT'],
        );

        final mockResponse = Response(
          data: config.toJson(),
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.put(
          '/api/v1/bot/config',
          data: anyNamed('data'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await botService.updateBotConfig(config);

        // Assert
        expect(result, isA<BotConfig>());
        expect(result.confidenceThreshold, equals(0.75));
        expect(result.dryRun, isTrue);
        verify(mockMatpClient.put(
          '/api/v1/bot/config',
          data: anyNamed('data'),
        )).called(1);
      });
    });

    group('Performance Monitoring', () {
      test('should get bot performance successfully', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'total_pnl': 150.50,
            'total_pnl_percent': 3.01,
            'total_trades': 25,
            'winning_trades': 18,
            'losing_trades': 7,
            'win_rate': 0.72,
            'average_win': 12.5,
            'average_loss': -8.2,
            'profit_factor': 1.52,
            'sharpe_ratio': 1.8,
            'max_drawdown': -5.2,
            'period_start': DateTime.now()
                .subtract(const Duration(days: 1))
                .toIso8601String(),
            'period_end': DateTime.now().toIso8601String(),
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.get(
          '/api/v1/bot/performance',
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await botService.getBotPerformance();

        // Assert
        expect(result, isA<BotPerformance>());
        expect(result.totalPnl, equals(150.50));
        expect(result.isProfitable, isTrue);
        expect(result.hasGoodWinRate, isTrue);
        verify(mockMatpClient.get(
          '/api/v1/bot/performance',
          queryParameters: anyNamed('queryParameters'),
        )).called(1);
      });
    });
  });

  // ============================================================================
  // PROPERTY-BASED TESTS
  // ============================================================================

  group('Property-Based Tests', () {
    test(
        '**Feature: backend-integration-update, Property 26: Autonomous Mode Configuration**',
        () async {
      // **Validates: Requirements 6.1**
      // Property: For any request to enable autonomous mode, the system should
      // configure bot parameters via MATP endpoints with proper validation

      final testCases = [
        {
          'enabled': true,
          'riskTolerance': 0.3,
          'allowedSymbols': ['BTC-USDT', 'ETH-USDT'],
          'strategies': ['rsi_strategy', 'macd_strategy'],
          'shouldSucceed': true,
        },
        {
          'enabled': true,
          'riskTolerance': 0.8,
          'allowedSymbols': ['ADA-USDT'],
          'strategies': ['bb_strategy'],
          'shouldSucceed': true,
        },
        {
          'enabled': false,
          'riskTolerance': 0.0,
          'allowedSymbols': <String>[],
          'strategies': <String>[],
          'shouldSucceed': true,
        },
      ];

      for (final testCase in testCases) {
        // Arrange
        final config = AutonomousConfig(
          enabled: testCase['enabled'] as bool,
          riskTolerance: testCase['riskTolerance'] as double,
          allowedSymbols: testCase['allowedSymbols'] as List<String>,
          strategies: testCase['strategies'] as List<String>,
          parameters: {'test': true},
        );

        final shouldSucceed = testCase['shouldSucceed'] as bool;

        final mockResponse = Response(
          data: {
            'enabled': config.enabled,
            'enabled_at':
                config.enabled ? DateTime.now().toIso8601String() : null,
            'config': config.toJson(),
            'metrics': {
              'symbols_count': config.allowedSymbols.length,
              'strategies_count': config.strategies.length,
            },
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.post(
          '/api/v1/bot/autonomous/enable',
          data: anyNamed('data'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        if (shouldSucceed) {
          final result = await botService.enableAutonomousMode(config);

          // Assert - Property: System should configure bot parameters with proper validation
          expect(result, isA<AutonomousStatus>());
          expect(result.enabled, equals(config.enabled));
          expect(result.config, isNotNull);
          expect(result.config!.riskTolerance, equals(config.riskTolerance));
          expect(result.config!.allowedSymbols, equals(config.allowedSymbols));
          expect(result.config!.strategies, equals(config.strategies));

          // Verify correct API call was made
          verify(mockMatpClient.post(
            '/api/v1/bot/autonomous/enable',
            data: argThat(
              predicate<Map<String, dynamic>>((data) =>
                  data['enabled'] == config.enabled &&
                  data['risk_tolerance'] == config.riskTolerance &&
                  (data['allowed_symbols'] as List).length ==
                      config.allowedSymbols.length &&
                  (data['strategies'] as List).length ==
                      config.strategies.length),
              named: 'data',
            ),
          )).called(1);
        }

        // Reset mock for next iteration
        reset(mockMatpClient);
      }
    });

    test(
        '**Feature: backend-integration-update, Property 27: Bot Status Display**',
        () async {
      // **Validates: Requirements 6.2**
      // Property: For any running bot, the system should display real-time
      // status and performance metrics accurately

      final testCases = [
        {
          'status': 'running',
          'aiEnabled': true,
          'isRunning': true,
          'lastAction': 'start',
          'expectedHealthy': true,
        },
        {
          'status': 'stopped',
          'aiEnabled': false,
          'isRunning': false,
          'lastAction': 'stop',
          'expectedHealthy': false,
        },
        {
          'status': 'error',
          'aiEnabled': true,
          'isRunning': false,
          'lastAction': 'trade',
          'expectedHealthy': false,
        },
        {
          'status': 'initializing',
          'aiEnabled': true,
          'isRunning': false,
          'lastAction': 'start',
          'expectedHealthy': false,
        },
      ];

      for (final testCase in testCases) {
        // Arrange
        final status = testCase['status'] as String;
        final aiEnabled = testCase['aiEnabled'] as bool;
        final isRunning = testCase['isRunning'] as bool;
        final lastAction = testCase['lastAction'] as String;
        final expectedHealthy = testCase['expectedHealthy'] as bool;

        final mockResponse = Response(
          data: {
            'ai_enabled': aiEnabled,
            'status': status,
            'is_running': isRunning,
            'last_action': lastAction,
            'error_message': status == 'error' ? 'Test error' : null,
            'metadata': {
              'uptime': '2h 30m',
              'last_update': DateTime.now().toIso8601String(),
            },
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.get('/api/v1/bot/status'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await botService.getBotStatus();

        // Assert - Property: System should display real-time status accurately
        expect(result, isA<BotStatus>());
        expect(result.status, equals(status));
        expect(result.aiEnabled, equals(aiEnabled));
        expect(result.isRunning, equals(isRunning));
        expect(result.lastAction, equals(lastAction));
        expect(result.isHealthy, equals(expectedHealthy));

        // Verify status-specific properties
        if (status == 'running') {
          expect(result.isRunning, isTrue);
          expect(result.isStopped, isFalse);
        } else if (status == 'stopped') {
          expect(result.isStopped, isTrue);
          expect(result.isRunning, isFalse);
        } else if (status == 'error') {
          expect(result.hasError, isTrue);
          expect(result.errorMessage, isNotNull);
        } else if (status == 'initializing') {
          expect(result.isInitializing, isTrue);
        }

        verify(mockMatpClient.get('/api/v1/bot/status')).called(1);

        // Reset mock for next iteration
        reset(mockMatpClient);
      }
    });

    test(
        '**Feature: backend-integration-update, Property 28: Bot Action Logging**',
        () async {
      // **Validates: Requirements 6.3**
      // Property: For any bot action taken, the system should log and display
      // trading decisions with timestamps and reasoning

      final testCases = [
        {
          'actionType': 'trade',
          'expectedActions': 3,
          'shouldHaveDetails': true,
        },
        {
          'actionType': 'config_change',
          'expectedActions': 2,
          'shouldHaveDetails': true,
        },
        {
          'actionType': null, // All actions
          'expectedActions': 5,
          'shouldHaveDetails': true,
        },
      ];

      for (final testCase in testCases) {
        // Arrange
        final actionType = testCase['actionType'] as String?;
        final expectedActions = testCase['expectedActions'] as int;
        final shouldHaveDetails = testCase['shouldHaveDetails'] as bool;

        final mockActions = List.generate(
            expectedActions,
            (index) => {
                  'id': 'action_$index',
                  'type': actionType ??
                      (index % 2 == 0 ? 'trade' : 'config_change'),
                  'description': 'Test action $index',
                  'details': {
                    'symbol': 'BTC-USDT',
                    'action': 'buy',
                    'confidence': 0.8 + (index * 0.05),
                    'reasoning': [
                      'Technical indicator signal',
                      'Market sentiment positive'
                    ],
                  },
                  'timestamp': DateTime.now()
                      .subtract(Duration(minutes: index * 5))
                      .toIso8601String(),
                  'result': index % 3 == 0
                      ? 'success'
                      : (index % 3 == 1 ? 'failure' : 'pending'),
                });

        final mockResponse = Response(
          data: {
            'actions': mockActions,
            'total': expectedActions,
            'limit': 50,
            'offset': 0,
            'has_more': false,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.get(
          '/api/v1/bot/actions/history',
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await botService.getBotActionHistory(
          actionType: actionType,
        );

        // Assert - Property: System should log and display trading decisions with timestamps
        expect(result, isA<BotActionHistory>());
        expect(result.actions.length, equals(expectedActions));
        expect(result.total, equals(expectedActions));

        // Verify each action has required information
        for (final action in result.actions) {
          expect(action.id, isNotEmpty);
          expect(action.type, isNotEmpty);
          expect(action.description, isNotEmpty);
          expect(action.timestamp, isA<DateTime>());

          if (shouldHaveDetails) {
            expect(action.details, isNotEmpty);
            if (action.type == 'trade') {
              expect(action.details, containsPair('symbol', isA<String>()));
              expect(action.details, containsPair('confidence', isA<double>()));
              expect(action.details, containsPair('reasoning', isA<List>()));
            }
          }

          // Verify result status
          expect(['success', 'failure', 'pending'], contains(action.result));
        }

        // Verify correct API call was made
        verify(mockMatpClient.get(
          '/api/v1/bot/actions/history',
          queryParameters: argThat(
            predicate<Map<String, dynamic>>((params) =>
                (actionType == null || params['action_type'] == actionType) &&
                params['limit'] == 50 &&
                params['offset'] == 0),
            named: 'queryParameters',
          ),
        )).called(1);

        // Reset mock for next iteration
        reset(mockMatpClient);
      }
    });

    test(
        '**Feature: backend-integration-update, Property 29: Emergency Stop Execution**',
        () async {
      // **Validates: Requirements 6.4**
      // Property: For any emergency stop trigger, the system should immediately
      // halt all bot operations and confirm the stop

      final testCases = [
        {
          'scenario': 'normal_emergency_stop',
          'success': true,
          'message': 'Emergency stop executed successfully',
        },
        {
          'scenario': 'emergency_stop_with_positions',
          'success': true,
          'message': 'Emergency stop executed - all positions closed',
        },
        {
          'scenario': 'emergency_stop_system_error',
          'success': false,
          'message': 'Emergency stop failed - system error',
        },
      ];

      for (final testCase in testCases) {
        // Arrange
        final scenario = testCase['scenario'] as String;
        final success = testCase['success'] as bool;
        final message = testCase['message'] as String;

        final mockResponse = Response(
          data: {
            'success': success,
            'message': message,
            'action': 'emergency_stop',
            'timestamp': DateTime.now().toIso8601String(),
          },
          statusCode: success ? 200 : 500,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.post('/api/v1/bot/emergency-stop'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await botService.emergencyStop();

        // Assert - Property: System should immediately halt operations and confirm stop
        expect(result, isA<BotActionResponse>());
        expect(result.success, equals(success));
        expect(result.message, equals(message));
        expect(result.action, equals('emergency_stop'));
        expect(result.timestamp, isA<DateTime>());

        // Verify emergency stop was called immediately
        verify(mockMatpClient.post('/api/v1/bot/emergency-stop')).called(1);

        // Reset mock for next iteration
        reset(mockMatpClient);
      }
    });

    test(
        '**Feature: backend-integration-update, Property 30: Bot Performance Analytics**',
        () async {
      // **Validates: Requirements 6.5**
      // Property: For any bot performance review request, the system should
      // display comprehensive statistics and analytics

      final testCases = [
        {
          'timeframe': '1h',
          'totalPnl': 25.50,
          'totalTrades': 5,
          'winRate': 0.8,
        },
        {
          'timeframe': '24h',
          'totalPnl': 150.75,
          'totalTrades': 25,
          'winRate': 0.72,
        },
        {
          'timeframe': '7d',
          'totalPnl': 890.25,
          'totalTrades': 120,
          'winRate': 0.68,
        },
        {
          'timeframe': '30d',
          'totalPnl': -45.80,
          'totalTrades': 200,
          'winRate': 0.45,
        },
      ];

      for (final testCase in testCases) {
        // Arrange
        final timeframe = testCase['timeframe'] as String;
        final totalPnl = testCase['totalPnl'] as double;
        final totalTrades = testCase['totalTrades'] as int;
        final winRate = testCase['winRate'] as double;

        final winningTrades = (totalTrades * winRate).round();
        final losingTrades = totalTrades - winningTrades;

        final mockResponse = Response(
          data: {
            'total_pnl': totalPnl,
            'total_pnl_percent':
                totalPnl / 5000 * 100, // Assuming 5000 initial capital
            'total_trades': totalTrades,
            'winning_trades': winningTrades,
            'losing_trades': losingTrades,
            'win_rate': winRate,
            'average_win': totalPnl > 0 ? totalPnl / winningTrades : 10.0,
            'average_loss': totalPnl < 0 ? totalPnl / losingTrades : -5.0,
            'profit_factor': totalPnl > 0 ? 1.5 : 0.8,
            'sharpe_ratio': totalPnl > 0 ? 1.2 : -0.5,
            'max_drawdown': totalPnl > 0 ? -2.5 : -15.0,
            'period_start': DateTime.now()
                .subtract(_getDuration(timeframe))
                .toIso8601String(),
            'period_end': DateTime.now().toIso8601String(),
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.get(
          '/api/v1/bot/performance',
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await botService.getBotPerformance(timeframe: timeframe);

        // Assert - Property: System should display comprehensive statistics and analytics
        expect(result, isA<BotPerformance>());
        expect(result.totalPnl, equals(totalPnl));
        expect(result.totalTrades, equals(totalTrades));
        expect(result.winningTrades, equals(winningTrades));
        expect(result.losingTrades, equals(losingTrades));
        expect(result.winRate, equals(winRate));
        expect(result.isProfitable, equals(totalPnl > 0));
        expect(result.hasGoodWinRate, equals(winRate >= 0.5));

        // Verify comprehensive metrics are present
        expect(result.averageWin, isA<double>());
        expect(result.averageLoss, isA<double>());
        expect(result.profitFactor, isA<double>());
        expect(result.sharpeRatio, isA<double>());
        expect(result.maxDrawdown, isA<double>());
        expect(result.periodStart, isA<DateTime>());
        expect(result.periodEnd, isA<DateTime>());
        expect(result.period, isA<Duration>());

        // Verify correct API call was made
        verify(mockMatpClient.get(
          '/api/v1/bot/performance',
          queryParameters: argThat(
            predicate<Map<String, dynamic>>(
                (params) => params['timeframe'] == timeframe),
            named: 'queryParameters',
          ),
        )).called(1);

        // Reset mock for next iteration
        reset(mockMatpClient);
      }
    });
  });
}

/// Helper function to convert timeframe string to Duration
Duration _getDuration(String timeframe) {
  switch (timeframe) {
    case '1h':
      return const Duration(hours: 1);
    case '24h':
      return const Duration(hours: 24);
    case '7d':
      return const Duration(days: 7);
    case '30d':
      return const Duration(days: 30);
    default:
      return const Duration(hours: 24);
  }
}
