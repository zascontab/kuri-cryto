import 'package:flutter_test/flutter_test.dart';
import 'package:kuri_crypto/services/api_client.dart';
import 'package:kuri_crypto/services/matp_api_client.dart';
import 'package:kuri_crypto/models/models.dart';
import 'package:kuri_crypto/services/api_exception.dart';

/// **Feature: backend-integration-update, Property 44: Service Interface Compatibility**
///
/// Property: For any new service integration, the system should maintain existing
/// service interfaces and not break current functionality
///
/// This test validates that all existing service interfaces remain functional
/// after the backend integration update.
void main() {
  group('Property 44: Service Interface Compatibility', () {
    late MATPApiClient matpApiClient;

    setUp(() {
      matpApiClient = MATPApiClient();
    });

    test('should maintain MATPApiClient extends ApiClient interface', () {
      // Act & Assert: Verify MATPApiClient maintains ApiClient interface
      expect(matpApiClient, isA<ApiClient>());

      // Verify all ApiClient methods are available
      expect(matpApiClient.get, isA<Function>());
      expect(matpApiClient.post, isA<Function>());
      expect(matpApiClient.put, isA<Function>());
      expect(matpApiClient.delete, isA<Function>());

      // Verify enhanced client maintains base functionality
      expect(matpApiClient.dio, isNotNull);
    });

    test('should maintain method signatures for HTTP operations', () {
      // Act & Assert: Verify method signatures are maintained
      expect(
        () => matpApiClient.get('/test'),
        returnsNormally,
      );
      expect(
        () => matpApiClient.post('/test', data: {'data': 'value'}),
        returnsNormally,
      );
      expect(
        () => matpApiClient.put('/test', data: {'data': 'value'}),
        returnsNormally,
      );
      expect(
        () => matpApiClient.delete('/test'),
        returnsNormally,
      );
    });

    test('should maintain configuration compatibility', () {
      // Arrange: Create clients with different configurations
      final client1 = ApiClient(environment: 'development');
      final client2 = MATPApiClient(environment: 'development');

      // Act & Assert: Verify both clients can be configured similarly
      expect(client1, isA<ApiClient>());
      expect(client2, isA<ApiClient>());
      expect(client2, isA<MATPApiClient>());

      // Verify both have access to dio instance
      expect(client1.dio, isNotNull);
      expect(client2.dio, isNotNull);
    });

    test('should maintain backward compatibility for existing models', () {
      // Arrange: Create legacy data structures
      final legacyPosition = {
        'id': 'pos_123',
        'symbol': 'BTC-USDT',
        'side': 'long',
        'size': 0.1,
        'entryPrice': 50000.0,
        'currentPrice': 51000.0,
        'unrealizedPnl': 100.0,
        'pnlPercent': 2.0,
        'createdAt': '2024-01-01T00:00:00Z',
      };

      // Act: Create position from legacy data
      final position = Position.fromJson(legacyPosition);

      // Assert: Verify legacy data is properly converted
      expect(position.id, equals('pos_123'));
      expect(position.symbol, equals('BTC-USDT'));
      expect(position.side, equals('long'));
      expect(position.size, equals(0.1));
    });

    test('should maintain API client authentication methods', () {
      // Arrange: Create API client
      final client = ApiClient();

      // Act & Assert: Verify authentication methods exist
      expect(() => client.setAuthToken('test-token'), returnsNormally);
      expect(() => client.clearAuthToken(), returnsNormally);
    });

    test('should maintain base URL configuration methods', () {
      // Arrange: Create API client
      final client = ApiClient();

      // Act & Assert: Verify URL configuration methods exist
      expect(() => client.updateBaseUrl('https://new-api.example.com'),
          returnsNormally);
      expect(client.dio.options.baseUrl, isNotEmpty);
    });

    test('should maintain client lifecycle methods', () {
      // Arrange: Create API client
      final client = ApiClient();

      // Act & Assert: Verify lifecycle methods exist
      expect(() => client.close(), returnsNormally);
      expect(() => client.close(force: true), returnsNormally);
    });

    test('should maintain backward compatibility adapters', () {
      // Arrange: Create legacy LLM analysis data
      final legacyData = {
        'provider': 'openai',
        'explanation': 'Market shows bullish signals',
        'keyFactors': ['Strong volume', 'Breaking resistance'],
        'confidence': 0.85,
        'recommendation': 'BUY',
      };

      // Act: Convert using backward compatibility adapter
      final enhanced =
          BackwardCompatibilityAdapter.convertLLMAnalysis(legacyData);

      // Assert: Verify conversion maintains data integrity
      expect(enhanced.action, equals('BUY'));
      expect(enhanced.confidence, equals(0.85));
      expect(enhanced.reasoning, contains('Strong volume'));
      expect(enhanced.reasoning, contains('Breaking resistance'));
      expect(enhanced.provider, equals('openai'));
    });

    test('should maintain service interface patterns', () {
      // Arrange: Create different client types
      final baseClient = ApiClient();
      final matpClient = MATPApiClient();

      // Act & Assert: Verify interface consistency
      expect(baseClient, isA<ApiClient>());
      expect(matpClient, isA<ApiClient>());
      expect(matpClient, isA<MATPApiClient>());

      // Verify both clients have the same base methods
      expect(baseClient.get, isA<Function>());
      expect(matpClient.get, isA<Function>());
      expect(baseClient.post, isA<Function>());
      expect(matpClient.post, isA<Function>());
    });

    test('should maintain API exception compatibility', () {
      // Arrange: Create API exceptions with different constructors
      final exception1 = ApiException(message: 'Test error');
      final exception2 = ApiException(
        message: 'Network error',
        statusCode: 500,
        code: 'NETWORK_ERROR',
      );

      // Act & Assert: Verify exception interface is maintained
      expect(exception1, isA<ApiException>());
      expect(exception2, isA<ApiException>());
      expect(exception1.message, equals('Test error'));
      expect(exception2.statusCode, equals(500));
      expect(exception2.code, equals('NETWORK_ERROR'));
    });

    test('should maintain data model serialization compatibility', () {
      // Arrange: Create a position model
      final position = Position(
        id: 'pos_123',
        symbol: 'BTC-USDT',
        side: 'long',
        size: 0.1,
        entryPrice: 50000.0,
        currentPrice: 51000.0,
        unrealizedPnl: 100.0,
        openTime: DateTime.parse('2024-01-01T00:00:00Z'),
        strategy: 'test_strategy',
      );

      // Act: Serialize and deserialize
      final json = position.toJson();
      final restored = Position.fromJson(json);

      // Assert: Verify serialization maintains data integrity
      expect(restored.id, equals(position.id));
      expect(restored.symbol, equals(position.symbol));
      expect(restored.side, equals(position.side));
      expect(restored.size, equals(position.size));
      expect(restored.entryPrice, equals(position.entryPrice));
    });

    test('should maintain configuration migration patterns', () {
      // Arrange: Create legacy configuration data
      final legacyConfig = {
        'dryRun': false,
        'maxPositions': 3,
        'positionSizeUsd': 500.0,
        'stopLossPercent': 2.5,
        'takeProfitPercent': 5.0,
        'symbols': ['BTC-USDT', 'ETH-USDT'],
      };

      // Act: Convert using backward compatibility adapter
      final enhanced =
          BackwardCompatibilityAdapter.convertBotConfig(legacyConfig);

      // Assert: Verify conversion maintains configuration
      expect(enhanced.dryRun, isFalse);
      expect(enhanced.maxPositions, equals(3));
      expect(enhanced.positionSizeUsd, equals(500.0));
      expect(enhanced.stopLossPercent, equals(2.5));
      expect(enhanced.takeProfitPercent, equals(5.0));
      expect(enhanced.symbols, contains('BTC-USDT'));
      expect(enhanced.symbols, contains('ETH-USDT'));
    });

    test('should maintain API response format compatibility', () {
      // Arrange: Create legacy API response with snake_case
      final legacyResponse = {
        'user_id': 'user_123',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T12:00:00Z',
        'entry_price': 50000.0,
        'current_price': 51000.0,
        'unrealized_pnl': 100.0,
        'pnl_percent': 2.0,
      };

      // Act: Convert using backward compatibility adapter
      final converted =
          BackwardCompatibilityAdapter.convertLegacyApiResponse(legacyResponse);

      // Assert: Verify snake_case is converted to camelCase
      expect(converted['userId'], equals('user_123'));
      expect(converted['createdAt'], equals('2024-01-01T00:00:00Z'));
      expect(converted['updatedAt'], equals('2024-01-01T12:00:00Z'));
      expect(converted['entryPrice'], equals(50000.0));
      expect(converted['currentPrice'], equals(51000.0));
      expect(converted['unrealizedPnl'], equals(100.0));
      expect(converted['pnlPercent'], equals(2.0));

      // Original snake_case keys should be removed
      expect(converted.containsKey('user_id'), isFalse);
      expect(converted.containsKey('created_at'), isFalse);
      expect(converted.containsKey('entry_price'), isFalse);
    });
  });
}
