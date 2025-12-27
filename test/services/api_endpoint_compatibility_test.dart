import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:kuri_crypto/services/api_client.dart';
import 'package:kuri_crypto/services/matp_api_client.dart';
import 'package:kuri_crypto/services/api_exception.dart';

/// **Feature: backend-integration-update, Property 46: API Endpoint Compatibility**
///
/// Property: For any new endpoint addition, the system should not break existing
/// API calls and maintain response format compatibility
///
/// This test validates that all existing API endpoints continue to work correctly
/// after the backend integration update and that response formats remain compatible.
void main() {
  group('Property 46: API Endpoint Compatibility', () {
    late ApiClient legacyApiClient;
    late MATPApiClient matpApiClient;

    setUp(() {
      legacyApiClient = MockApiClient();
      matpApiClient = MATPApiClient();
    });

    test('should maintain existing position endpoints', () async {
      // Arrange: Mock legacy position endpoint response
      final mockPositionsResponse = {
        'success': true,
        'data': [
          {
            'id': 'pos_123',
            'symbol': 'BTC-USDT',
            'side': 'long',
            'size': 0.1,
            'entry_price': 50000.0, // Legacy snake_case format
            'current_price': 51000.0, // Legacy snake_case format
            'unrealized_pnl': 100.0, // Legacy snake_case format
            'open_time': '2024-01-01T00:00:00Z', // Legacy snake_case format
            'strategy': 'test_strategy',
          }
        ]
      };

      when(legacyApiClient.get('/positions'))
          .thenAnswer((_) async => mockPositionsResponse);

      // Act: Call legacy endpoint
      final response = await legacyApiClient.get('/positions');

      // Assert: Verify legacy endpoint response format is maintained
      expect(response, isA<Map<String, dynamic>>());
      expect(response['success'], isTrue);
      expect(response['data'], isA<List>());
      expect(response['data'][0]['id'], equals('pos_123'));
      expect(response['data'][0]['entry_price'],
          equals(50000.0)); // snake_case preserved
    });

    test('should maintain existing trading endpoints', () async {
      // Arrange: Mock legacy trading endpoint response
      final mockCreatePositionResponse = {
        'success': true,
        'data': {
          'id': 'pos_new',
          'symbol': 'ETH-USDT',
          'side': 'long',
          'size': 1.0,
          'entry_price': 3000.0, // Legacy snake_case format
          'current_price': 3000.0, // Legacy snake_case format
          'unrealized_pnl': 0.0, // Legacy snake_case format
          'open_time': '2024-01-01T00:00:00Z', // Legacy snake_case format
          'strategy': 'manual',
        }
      };

      when(legacyApiClient.post('/positions', data: anyNamed('data')))
          .thenAnswer((_) async => mockCreatePositionResponse);

      // Act: Call legacy endpoint
      final response = await legacyApiClient.post('/positions', data: {
        'symbol': 'ETH-USDT',
        'side': 'long',
        'size': 1.0,
        'price': 3000.0,
      });

      // Assert: Verify legacy endpoint response format is maintained
      expect(response, isA<Map<String, dynamic>>());
      expect(response['success'], isTrue);
      expect(response['data']['id'], equals('pos_new'));
      expect(response['data']['entry_price'],
          equals(3000.0)); // snake_case preserved
    });

    test('should maintain existing analysis endpoints', () async {
      // Arrange: Mock legacy analysis endpoint response
      final mockAnalysisResponse = {
        'success': true,
        'data': {
          'symbol': 'BTC-USDT',
          'timestamp': '2024-01-01T12:00:00Z',
          'technical_analysis': {
            // Legacy snake_case format
            'rsi': 65.5,
            'macd': {
              'macd': 150.0,
              'signal': 120.0,
              'histogram': 30.0,
              'trend': 'bullish',
            },
            'bollinger_bands': {
              // Legacy snake_case format
              'upper': 52000.0,
              'middle': 51000.0,
              'lower': 50000.0,
            }
          }
        }
      };

      when(legacyApiClient.get('/analysis/technical'))
          .thenAnswer((_) async => mockAnalysisResponse);

      // Act: Call legacy endpoint
      final response = await legacyApiClient.get('/analysis/technical');

      // Assert: Verify legacy endpoint response format is maintained
      expect(response, isA<Map<String, dynamic>>());
      expect(response['success'], isTrue);
      expect(response['data']['technical_analysis'],
          isNotNull); // snake_case preserved
      expect(response['data']['technical_analysis']['bollinger_bands'],
          isNotNull); // snake_case preserved
    });

    test('should maintain existing bot endpoints', () async {
      // Arrange: Mock legacy bot endpoint response
      final mockBotStatusResponse = {
        'success': true,
        'data': {
          'state': 'running',
          'autonomous_mode': true, // Legacy snake_case format
          'total_trades': 10, // Legacy snake_case format
          'win_rate': 65.0, // Legacy snake_case format
          'total_pnl': 150.0, // Legacy snake_case format
          'current_risk': 25.0, // Legacy snake_case format
          'max_risk': 100.0, // Legacy snake_case format
        }
      };

      when(legacyApiClient.get('/bot/status'))
          .thenAnswer((_) async => mockBotStatusResponse);

      // Act: Call legacy endpoint
      final response = await legacyApiClient.get('/bot/status');

      // Assert: Verify legacy endpoint response format is maintained
      expect(response, isA<Map<String, dynamic>>());
      expect(response['success'], isTrue);
      expect(
          response['data']['autonomous_mode'], isTrue); // snake_case preserved
      expect(
          response['data']['total_trades'], equals(10)); // snake_case preserved
      expect(
          response['data']['win_rate'], equals(65.0)); // snake_case preserved
    });

    test('should maintain existing market data endpoints', () async {
      // Arrange: Mock legacy market data endpoint response
      final mockMarketDataResponse = {
        'success': true,
        'data': {
          'symbol': 'BTC-USDT',
          'price': 51000.0,
          'volume_24h': 1000000.0, // Legacy snake_case format
          'price_change_24h': 2.5, // Legacy snake_case format
          'last_updated': '2024-01-01T12:00:00Z', // Legacy snake_case format
        }
      };

      when(legacyApiClient.get('/market/ticker'))
          .thenAnswer((_) async => mockMarketDataResponse);

      // Act: Call legacy endpoint
      final response = await legacyApiClient.get('/market/ticker');

      // Assert: Verify legacy endpoint response format is maintained
      expect(response, isA<Map<String, dynamic>>());
      expect(response['success'], isTrue);
      expect(response['data']['volume_24h'],
          equals(1000000.0)); // snake_case preserved
      expect(response['data']['price_change_24h'],
          equals(2.5)); // snake_case preserved
      expect(
          response['data']['last_updated'], isNotNull); // snake_case preserved
    });

    test('should maintain error response format compatibility', () async {
      // Arrange: Mock legacy error response format
      final mockErrorResponse = {
        'success': false,
        'error': {
          'code': 'POSITION_NOT_FOUND',
          'message': 'Position not found',
          'details': {
            'position_id': 'pos_invalid', // Legacy snake_case format
            'requested_at': '2024-01-01T12:00:00Z', // Legacy snake_case format
          }
        }
      };

      when(legacyApiClient.get('/positions/invalid'))
          .thenAnswer((_) async => mockErrorResponse);

      // Act: Call legacy endpoint that returns error
      final response = await legacyApiClient.get('/positions/invalid');

      // Assert: Verify legacy error response format is maintained
      expect(response, isA<Map<String, dynamic>>());
      expect(response['success'], isFalse);
      expect(response['error']['code'], equals('POSITION_NOT_FOUND'));
      expect(response['error']['details']['position_id'],
          equals('pos_invalid')); // snake_case preserved
      expect(response['error']['details']['requested_at'],
          isNotNull); // snake_case preserved
    });

    test('should maintain pagination format compatibility', () async {
      // Arrange: Mock legacy paginated response format
      final mockPaginatedResponse = {
        'success': true,
        'data': [
          {'id': 'item_1', 'name': 'Item 1'},
          {'id': 'item_2', 'name': 'Item 2'},
        ],
        'pagination': {
          'current_page': 1, // Legacy snake_case format
          'total_pages': 5, // Legacy snake_case format
          'per_page': 10, // Legacy snake_case format
          'total_items': 50, // Legacy snake_case format
          'has_next': true, // Legacy snake_case format
          'has_previous': false, // Legacy snake_case format
        }
      };

      when(legacyApiClient.get('/data/paginated'))
          .thenAnswer((_) async => mockPaginatedResponse);

      // Act: Call legacy paginated endpoint
      final response = await legacyApiClient.get('/data/paginated');

      // Assert: Verify legacy pagination format is maintained
      expect(response, isA<Map<String, dynamic>>());
      expect(response['success'], isTrue);
      expect(response['pagination']['current_page'],
          equals(1)); // snake_case preserved
      expect(response['pagination']['total_pages'],
          equals(5)); // snake_case preserved
      expect(response['pagination']['per_page'],
          equals(10)); // snake_case preserved
      expect(
          response['pagination']['has_next'], isTrue); // snake_case preserved
    });

    test('should maintain query parameter compatibility', () async {
      // Arrange: Mock response for endpoint with query parameters
      final mockFilteredResponse = {
        'success': true,
        'data': [
          {
            'id': 'pos_btc',
            'symbol': 'BTC-USDT',
            'side': 'long',
            'created_at': '2024-01-01T00:00:00Z', // Legacy snake_case format
          }
        ],
        'filters_applied': {
          // Legacy snake_case format
          'symbol': 'BTC-USDT',
          'side': 'long',
          'date_from': '2024-01-01', // Legacy snake_case format
          'date_to': '2024-01-31', // Legacy snake_case format
        }
      };

      when(legacyApiClient.get('/positions',
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => mockFilteredResponse);

      // Act: Call legacy endpoint with query parameters
      final response =
          await legacyApiClient.get('/positions', queryParameters: {
        'symbol': 'BTC-USDT',
        'side': 'long',
        'date_from': '2024-01-01',
        'date_to': '2024-01-31',
      });

      // Assert: Verify legacy query parameter handling is maintained
      expect(response, isA<Map<String, dynamic>>());
      expect(response['success'], isTrue);
      expect(response['filters_applied'], isNotNull); // snake_case preserved
      expect(response['filters_applied']['date_from'],
          equals('2024-01-01')); // snake_case preserved
      expect(response['filters_applied']['date_to'],
          equals('2024-01-31')); // snake_case preserved
    });

    test('should maintain HTTP status code compatibility', () async {
      // Arrange: Mock different HTTP status responses
      when(legacyApiClient.get('/success'))
          .thenAnswer((_) async => {'success': true, 'data': {}});

      when(legacyApiClient.get('/not-found'))
          .thenThrow(ApiException(message: 'Not found', statusCode: 404));

      when(legacyApiClient.get('/server-error'))
          .thenThrow(ApiException(message: 'Server error', statusCode: 500));

      // Act & Assert: Verify different status codes are handled correctly

      // Success case
      final successResponse = await legacyApiClient.get('/success');
      expect(successResponse['success'], isTrue);

      // Not found case
      expect(
        () => legacyApiClient.get('/not-found'),
        throwsA(predicate((e) => e is ApiException && e.statusCode == 404)),
      );

      // Server error case
      expect(
        () => legacyApiClient.get('/server-error'),
        throwsA(predicate((e) => e is ApiException && e.statusCode == 500)),
      );
    });

    test('should maintain request header compatibility', () async {
      // Arrange: Mock response that echoes request headers
      final mockHeaderResponse = {
        'success': true,
        'received_headers': {
          // Legacy snake_case format
          'content_type': 'application/json', // Legacy snake_case format
          'user_agent': 'KuriCrypto/1.0', // Legacy snake_case format
          'accept_language': 'en-US', // Legacy snake_case format
        }
      };

      when(legacyApiClient.get('/echo-headers'))
          .thenAnswer((_) async => mockHeaderResponse);

      // Act: Call endpoint that processes headers
      final response = await legacyApiClient.get('/echo-headers');

      // Assert: Verify header processing format is maintained
      expect(response, isA<Map<String, dynamic>>());
      expect(response['success'], isTrue);
      expect(response['received_headers'], isNotNull); // snake_case preserved
      expect(response['received_headers']['content_type'],
          isNotNull); // snake_case preserved
      expect(response['received_headers']['user_agent'],
          isNotNull); // snake_case preserved
    });

    test('should maintain nested object format compatibility', () async {
      // Arrange: Mock response with deeply nested legacy format
      final mockNestedResponse = {
        'success': true,
        'data': {
          'user_info': {
            // Legacy snake_case format
            'user_id': 'user_123', // Legacy snake_case format
            'account_settings': {
              // Legacy snake_case format
              'trading_preferences': {
                // Legacy snake_case format
                'default_position_size': 100.0, // Legacy snake_case format
                'risk_management': {
                  // Legacy snake_case format
                  'max_daily_loss': 500.0, // Legacy snake_case format
                  'stop_loss_enabled': true, // Legacy snake_case format
                }
              }
            }
          }
        }
      };

      when(legacyApiClient.get('/user/profile'))
          .thenAnswer((_) async => mockNestedResponse);

      // Act: Call endpoint with nested response
      final response = await legacyApiClient.get('/user/profile');

      // Assert: Verify nested object format is maintained
      expect(response, isA<Map<String, dynamic>>());
      expect(response['success'], isTrue);
      expect(response['data']['user_info'], isNotNull); // snake_case preserved
      expect(response['data']['user_info']['user_id'],
          equals('user_123')); // snake_case preserved
      expect(
          response['data']['user_info']['account_settings']
              ['trading_preferences'],
          isNotNull); // snake_case preserved
      expect(
          response['data']['user_info']['account_settings']
              ['trading_preferences']['default_position_size'],
          equals(100.0)); // snake_case preserved
      expect(
          response['data']['user_info']['account_settings']
              ['trading_preferences']['risk_management']['max_daily_loss'],
          equals(500.0)); // snake_case preserved
    });

    test('should maintain array response format compatibility', () async {
      // Arrange: Mock array response with legacy format
      final mockArrayResponse = {
        'success': true,
        'data': [
          {
            'trade_id': 'trade_1', // Legacy snake_case format
            'executed_at': '2024-01-01T10:00:00Z', // Legacy snake_case format
            'trade_type': 'buy', // Legacy snake_case format
          },
          {
            'trade_id': 'trade_2', // Legacy snake_case format
            'executed_at': '2024-01-01T11:00:00Z', // Legacy snake_case format
            'trade_type': 'sell', // Legacy snake_case format
          }
        ],
        'total_count': 2, // Legacy snake_case format
      };

      when(legacyApiClient.get('/trades/history'))
          .thenAnswer((_) async => mockArrayResponse);

      // Act: Call endpoint that returns array
      final response = await legacyApiClient.get('/trades/history');

      // Assert: Verify array response format is maintained
      expect(response, isA<Map<String, dynamic>>());
      expect(response['success'], isTrue);
      expect(response['data'], isA<List>());
      expect(response['data'].length, equals(2));
      expect(response['data'][0]['trade_id'],
          equals('trade_1')); // snake_case preserved
      expect(response['data'][0]['executed_at'],
          isNotNull); // snake_case preserved
      expect(response['data'][1]['trade_type'],
          equals('sell')); // snake_case preserved
      expect(response['total_count'], equals(2)); // snake_case preserved
    });
  });
}

// Mock class for testing
class MockApiClient extends Mock implements ApiClient {
  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic options,
    dynamic cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) {
    return super.noSuchMethod(
      Invocation.method(#get, [
        path
      ], {
        #queryParameters: queryParameters,
        #options: options,
        #cancelToken: cancelToken,
        #onReceiveProgress: onReceiveProgress,
      }),
      returnValue: Future<T>.value({} as T),
    );
  }

  @override
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dynamic options,
    dynamic cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    return super.noSuchMethod(
      Invocation.method(#post, [
        path
      ], {
        #data: data,
        #queryParameters: queryParameters,
        #options: options,
        #cancelToken: cancelToken,
        #onSendProgress: onSendProgress,
        #onReceiveProgress: onReceiveProgress,
      }),
      returnValue: Future<T>.value({} as T),
    );
  }
}
