/* import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kuri_crypto/services/ai_bot_service.dart';
import 'package:kuri_crypto/services/api_exception.dart';
import 'package:kuri_crypto/models/comprehensive_analysis.dart';
import 'package:kuri_crypto/models/ai_bot_config.dart';

// Generate mocks
@GenerateMocks([Dio])
import 'ai_bot_service_test.mocks.dart';

void main() {
  late MockDio mockDio;
  late AiBotService service;

  setUp(() {
    mockDio = MockDio();
    service = AiBotService(mockDio);
  });

  group('AiBotService - getComprehensiveAnalysis', () {
    test('should return ComprehensiveAnalysis on success', () async {
      // Arrange
      final mockResponse = {
        'symbol': 'BTC-USDT',
        'exchange': 'kucoin',
        'timestamp': '2025-11-26T10:00:00Z',
        'price_data': {
          'last': 90000.0,
          'bid': 89999.0,
          'ask': 90001.0,
          'volume': 1000000.0,
          'high_24h': 91000.0,
          'low_24h': 89000.0,
          'change_24h': 1000.0,
          'change_percent_24h': 1.12,
        },
        'technical_indicators': {
          '5m': {
            'rsi': {'value': 65.5, 'signal': 'neutral'},
            'macd': {'macd': 100.0, 'signal': 95.0, 'histogram': 5.0},
            'bollinger_bands': {
              'upper': 91000.0,
              'middle': 90000.0,
              'lower': 89000.0
            },
            'ema': {'ema_12': 90100.0, 'ema_26': 89900.0},
            'volume': {
              'current': 50000.0,
              'average': 45000.0,
              'trend': 'increasing'
            },
          },
        },
        'scenarios': [
          {
            'type': 'bullish',
            'probability': 0.65,
            'description': 'Strong uptrend',
            'conditions': ['RSI > 60', 'MACD positive'],
            'target_price': 92000.0,
            'stop_loss': 88000.0,
          },
        ],
        'recommendation': {
          'action': 'BUY',
          'confidence': 0.75,
          'entry': 90000.0,
          'stop_loss': 88500.0,
          'take_profit': 92000.0,
          'reasoning': 'Strong bullish momentum',
          'risks': ['High volatility'],
        },
      };

      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: mockResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      final result = await service.getComprehensiveAnalysis(symbol: 'BTC-USDT');

      // Assert
      expect(result, isA<ComprehensiveAnalysis>());
      expect(result.symbol, 'BTC-USDT');
      expect(result.priceData.last, 90000.0);
      expect(result.recommendation.action, 'BUY');
      expect(result.recommendation.confidence, 0.75);
    });

    test('should throw ApiException on error', () async {
      // Arrange
      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          data: {'error': 'Symbol not found'},
          statusCode: 404,
          requestOptions: RequestOptions(path: ''),
        ),
      ));

      // Act & Assert
      expect(
        () => service.getComprehensiveAnalysis(symbol: 'INVALID'),
        throwsA(isA<ApiException>()),
      );
    });

    test('should handle network error', () async {
      // Arrange
      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
        message: 'Connection timeout',
      ));

      // Act & Assert
      expect(
        () => service.getComprehensiveAnalysis(symbol: 'BTC-USDT'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('AiBotService - getConfig', () {
    test('should return AiBotConfig on success', () async {
      // Arrange
      final mockResponse = {
        'pair': 'BTC-USDT',
        'confidence_threshold': 0.7,
        'trade_size_usd': 10.0,
        'leverage': 5,
        'dry_run': true,
        'auto_execute': false,
        'max_daily_loss_usd': 50.0,
        'max_daily_trades': 20,
        'max_consecutive_errors': 3,
        'max_open_positions': 5,
      };

      when(mockDio.get(any)).thenAnswer((_) async => Response(
            data: mockResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      final result = await service.getConfig();

      // Assert
      expect(result, isA<AiBotConfig>());
      expect(result.pair, 'BTC-USDT');
      expect(result.confidenceThreshold, 0.7);
      expect(result.dryRun, true);
    });

    test('should throw ApiException on error', () async {
      // Arrange
      when(mockDio.get(any)).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          data: {'error': 'Config not found'},
          statusCode: 404,
          requestOptions: RequestOptions(path: ''),
        ),
      ));

      // Act & Assert
      expect(
        () => service.getConfig(),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('AiBotService - updateConfig', () {
    test('should return updated AiBotConfig on success', () async {
      // Arrange
      final updates = {'confidence_threshold': 0.8};
      final mockResponse = {
        'config': {
          'pair': 'BTC-USDT',
          'confidence_threshold': 0.8,
          'trade_size_usd': 10.0,
          'leverage': 5,
          'dry_run': true,
          'auto_execute': false,
          'max_daily_loss_usd': 50.0,
          'max_daily_trades': 20,
          'max_consecutive_errors': 3,
          'max_open_positions': 5,
        },
      };

      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: mockResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      final result = await service.updateConfig(updates);

      // Assert
      expect(result, isA<AiBotConfig>());
      expect(result.confidenceThreshold, 0.8);
    });

    test('should throw ApiException when bot is running', () async {
      // Arrange
      final updates = {'confidence_threshold': 0.8};
      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          data: {'error': 'Bot is running', 'message': 'Stop the bot first'},
          statusCode: 400,
          requestOptions: RequestOptions(path: ''),
        ),
      ));

      // Act & Assert
      expect(
        () => service.updateConfig(updates),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('AiBotService - Helper Methods', () {
    test('enableDryRunMode should set correct config', () async {
      // Arrange
      final mockResponse = {
        'config': {
          'pair': 'BTC-USDT',
          'confidence_threshold': 0.7,
          'trade_size_usd': 10.0,
          'leverage': 5,
          'dry_run': true,
          'auto_execute': false,
          'max_daily_loss_usd': 50.0,
          'max_daily_trades': 20,
          'max_consecutive_errors': 3,
          'max_open_positions': 5,
        },
      };

      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: mockResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      final result = await service.enableDryRunMode();

      // Assert
      expect(result.dryRun, true);
      expect(result.autoExecute, false);
      verify(mockDio.post(
        any,
        data: {'dry_run': true, 'auto_execute': false},
      )).called(1);
    });

    test('enableLiveMode should set correct config', () async {
      // Arrange
      final mockResponse = {
        'config': {
          'pair': 'BTC-USDT',
          'confidence_threshold': 0.7,
          'trade_size_usd': 10.0,
          'leverage': 5,
          'dry_run': false,
          'auto_execute': true,
          'max_daily_loss_usd': 50.0,
          'max_daily_trades': 20,
          'max_consecutive_errors': 3,
          'max_open_positions': 5,
        },
      };

      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: mockResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      final result = await service.enableLiveMode();

      // Assert
      expect(result.dryRun, false);
      expect(result.autoExecute, true);
      verify(mockDio.post(
        any,
        data: {'dry_run': false, 'auto_execute': true},
      )).called(1);
    });

    test('updateConfidenceThreshold should validate range', () async {
      // Act & Assert - Too low
      expect(
        () => service.updateConfidenceThreshold(0.3),
        throwsA(isA<ApiException>()),
      );

      // Act & Assert - Too high
      expect(
        () => service.updateConfidenceThreshold(1.5),
        throwsA(isA<ApiException>()),
      );
    });

    test('updateConfidenceThreshold should accept valid value', () async {
      // Arrange
      final mockResponse = {
        'config': {
          'pair': 'BTC-USDT',
          'confidence_threshold': 0.8,
          'trade_size_usd': 10.0,
          'leverage': 5,
          'dry_run': true,
          'auto_execute': false,
          'max_daily_loss_usd': 50.0,
          'max_daily_trades': 20,
          'max_consecutive_errors': 3,
          'max_open_positions': 5,
        },
      };

      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: mockResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      final result = await service.updateConfidenceThreshold(0.8);

      // Assert
      expect(result.confidenceThreshold, 0.8);
    });

    test('updateTradeSize should validate positive value', () async {
      // Act & Assert
      expect(
        () => service.updateTradeSize(-10.0),
        throwsA(isA<ApiException>()),
      );

      expect(
        () => service.updateTradeSize(0.0),
        throwsA(isA<ApiException>()),
      );
    });

    test('updateLeverage should validate range', () async {
      // Act & Assert - Too low
      expect(
        () => service.updateLeverage(0),
        throwsA(isA<ApiException>()),
      );

      // Act & Assert - Too high
      expect(
        () => service.updateLeverage(101),
        throwsA(isA<ApiException>()),
      );
    });

    test('updateSafetyLimits should send correct updates', () async {
      // Arrange
      final mockResponse = {
        'config': {
          'pair': 'BTC-USDT',
          'confidence_threshold': 0.7,
          'trade_size_usd': 10.0,
          'leverage': 5,
          'dry_run': true,
          'auto_execute': false,
          'max_daily_loss_usd': 100.0,
          'max_daily_trades': 30,
          'max_consecutive_errors': 5,
          'max_open_positions': 10,
        },
      };

      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: mockResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      final result = await service.updateSafetyLimits(
        maxDailyLoss: 100.0,
        maxDailyTrades: 30,
        maxConsecutiveErrors: 5,
        maxOpenPositions: 10,
      );

      // Assert
      expect(result.maxDailyLossUsd, 100.0);
      expect(result.maxDailyTrades, 30);
      expect(result.maxConsecutiveErrors, 5);
      expect(result.maxOpenPositions, 10);
    });
  });
}
 */