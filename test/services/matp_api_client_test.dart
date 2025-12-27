import 'package:flutter_test/flutter_test.dart';
import 'package:kuri_crypto/services/matp_api_client.dart';
import 'package:kuri_crypto/config/api_config.dart';

void main() {
  group('MATPApiClient Configuration Tests', () {
    late MATPApiClient client;

    setUp(() {
      client = MATPApiClient(environment: 'development');
    });

    tearDown(() {
      client.close();
    });

    group('Property 1: MATP Client Configuration', () {
      test('should configure Kong Gateway base URL correctly', () {
        // **Feature: backend-integration-update, Property 1: MATP Client Configuration**
        // For any Flutter app initialization, the MATP API client should be configured
        // with the correct Kong Gateway base URL and default headers

        // Verify base URL is set to Kong Gateway
        expect(
            client.dio.options.baseUrl, equals(ApiConfig.matpKongGatewayUrl));

        // Verify default headers are set
        expect(client.dio.options.headers['Content-Type'],
            equals('application/json'));
        expect(
            client.dio.options.headers['Accept'], equals('application/json'));
      });

      test('should initialize with default user level 1', () {
        // Verify initial user level
        expect(client.userLevel, equals(1));

        // Verify no JWT token initially
        expect(client.jwtToken, isNull);
        expect(client.refreshToken, isNull);
        expect(client.isTokenExpired, isFalse);
      });

      test('should validate MATP configuration URLs', () {
        // Verify MATP configuration is valid
        expect(ApiConfig.validateMATPConfiguration(), isTrue);

        // Verify Kong Gateway URL is properly formatted
        final uri = Uri.parse(ApiConfig.matpKongGatewayUrl);
        expect(uri.scheme, equals('http'));
        expect(uri.port, equals(10000));
      });

      test('should set user level and update headers', () {
        // Test setting different user levels
        for (int level = 1; level <= 4; level++) {
          client.setUserLevel(level);

          expect(client.userLevel, equals(level));
          expect(client.dio.options.headers['X-User-Level'],
              equals(level.toString()));
          expect(client.hasAccessLevel(level), isTrue);
          expect(client.hasAccessLevel(level + 1), isFalse);
        }
      });

      test('should manage JWT tokens correctly', () {
        const testToken = 'test-jwt-token';
        const testRefreshToken = 'test-refresh-token';
        final testExpiry = DateTime.now().add(const Duration(hours: 1));

        // Set JWT token
        client.setJWTToken(testToken,
            refreshToken: testRefreshToken, expiry: testExpiry);

        expect(client.jwtToken, equals(testToken));
        expect(client.refreshToken, equals(testRefreshToken));
        expect(client.dio.options.headers['Authorization'],
            equals('Bearer $testToken'));
        expect(client.isTokenExpired, isFalse);

        // Clear JWT token
        client.clearJWTToken();

        expect(client.jwtToken, isNull);
        expect(client.refreshToken, isNull);
        expect(client.dio.options.headers['Authorization'], isNull);
      });

      test('should detect expired tokens', () {
        const testToken = 'expired-jwt-token';
        final expiredTime = DateTime.now().subtract(const Duration(hours: 1));

        client.setJWTToken(testToken, expiry: expiredTime);

        expect(client.isTokenExpired, isTrue);
      });

      test('should handle access level validation in MATP methods', () {
        // Set user to level 1
        client.setUserLevel(1);

        // Should allow access to level 1 endpoints
        expect(client.hasAccessLevel(1), isTrue);

        // Should deny access to higher level endpoints
        expect(client.hasAccessLevel(2), isFalse);
        expect(client.hasAccessLevel(3), isFalse);
        expect(client.hasAccessLevel(4), isFalse);
      });

      test('should include request tracking headers', () {
        // Verify that MATP interceptor adds request tracking
        // This is tested indirectly by checking that the interceptor is added
        expect(client.dio.interceptors.length, greaterThan(0));
      });
    });

    group('Property-Based Configuration Tests', () {
      test(
          'MATP client configuration should be consistent across multiple initializations',
          () {
        // **Feature: backend-integration-update, Property 1: MATP Client Configuration**
        // Property: For any environment configuration, MATP client should consistently
        // configure Kong Gateway settings

        final environments = ['development', 'production'];

        for (final env in environments) {
          final testClient = MATPApiClient(environment: env);

          // All clients should use Kong Gateway URL regardless of environment
          expect(testClient.dio.options.baseUrl,
              equals(ApiConfig.matpKongGatewayUrl));

          // All clients should have consistent headers
          expect(testClient.dio.options.headers['Content-Type'],
              equals('application/json'));
          expect(testClient.dio.options.headers['Accept'],
              equals('application/json'));

          // All clients should start with level 1
          expect(testClient.userLevel, equals(1));

          testClient.close();
        }
      });

      test('user level changes should be consistent and valid', () {
        // Property: For any valid user level (1-4), setting the level should
        // update both internal state and headers consistently

        final validLevels = [1, 2, 3, 4];

        for (final level in validLevels) {
          client.setUserLevel(level);

          // Internal state should match
          expect(client.userLevel, equals(level));

          // Header should match
          expect(client.dio.options.headers['X-User-Level'],
              equals(level.toString()));

          // Access level checks should be consistent
          for (int checkLevel = 1; checkLevel <= 4; checkLevel++) {
            final shouldHaveAccess = checkLevel <= level;
            expect(client.hasAccessLevel(checkLevel), equals(shouldHaveAccess));
          }
        }
      });

      test('JWT token management should maintain consistency', () {
        // Property: For any valid JWT token and expiry time, token management
        // should maintain consistency between internal state and headers

        final testCases = [
          {
            'token': 'token1',
            'refresh': 'refresh1',
            'expiry': DateTime.now().add(const Duration(hours: 1)),
          },
          {
            'token': 'token2',
            'refresh': 'refresh2',
            'expiry': DateTime.now().add(const Duration(minutes: 30)),
          },
          {
            'token': 'token3',
            'refresh': null,
            'expiry': null,
          },
        ];

        for (final testCase in testCases) {
          final token = testCase['token'] as String;
          final refresh = testCase['refresh'] as String?;
          final expiry = testCase['expiry'] as DateTime?;

          client.setJWTToken(token, refreshToken: refresh, expiry: expiry);

          // Internal state should match
          expect(client.jwtToken, equals(token));
          expect(client.refreshToken, equals(refresh));

          // Header should match
          expect(client.dio.options.headers['Authorization'],
              equals('Bearer $token'));

          // Expiry check should be consistent
          if (expiry != null) {
            final expectedExpired = DateTime.now().isAfter(expiry);
            expect(client.isTokenExpired, equals(expectedExpired));
          }

          // Clear and verify consistency
          client.clearJWTToken();
          expect(client.jwtToken, isNull);
          expect(client.refreshToken, isNull);
          expect(client.dio.options.headers['Authorization'], isNull);
        }
      });
    });
  });
}
