import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';

import 'package:kuri_crypto/services/ai_analysis_service.dart';
import 'package:kuri_crypto/services/matp_api_client.dart';
import 'package:kuri_crypto/models/comprehensive_analysis.dart';
import 'package:kuri_crypto/models/llm_analysis.dart';
import 'package:kuri_crypto/models/sentiment_analysis.dart';
import 'package:kuri_crypto/models/ai_costs.dart';
import 'package:kuri_crypto/models/ai_status.dart';

import 'ai_analysis_service_test.mocks.dart';

@GenerateMocks([MATPApiClient])
void main() {
  late AIAnalysisService aiAnalysisService;
  late MockMATPApiClient mockMatpClient;

  setUp(() {
    mockMatpClient = MockMATPApiClient();
    aiAnalysisService = AIAnalysisService(mockMatpClient);
  });

  group('AIAnalysisService', () {
    group('Complete Analysis', () {
      test('should get complete analysis successfully', () async {
        // Arrange
        final request = AnalysisRequest(
          symbol: 'BTC-USDT',
          exchange: 'kucoin',
        );

        final mockResponse = Response(
          data: {
            'symbol': 'BTC-USDT',
            'exchange': 'kucoin',
            'timestamp': DateTime.now().toIso8601String(),
            'price_data': {
              'last': 50000.0,
              'bid': 49999.0,
              'ask': 50001.0,
              'volume': 1000.0,
              'high_24h': 51000.0,
              'low_24h': 49000.0,
              'change_24h': 1000.0,
              'change_percent_24h': 2.0,
            },
            'technical_indicators': {},
            'scenarios': {},
            'recommendation': {
              'action': 'BUY',
              'confidence': 0.8,
              'reasoning': ['Strong technical indicators'],
              'risks': ['Market volatility'],
            },
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.post(
          '/api/v1/ai/analysis/complete',
          data: anyNamed('data'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await aiAnalysisService.getCompleteAnalysis(request);

        // Assert
        expect(result.symbol, equals('BTC-USDT'));
        expect(result.exchange, equals('kucoin'));
        verify(mockMatpClient.post(
          '/api/v1/ai/analysis/complete',
          data: anyNamed('data'),
        )).called(1);
      });
    });

    group('LLM Analysis', () {
      test('should get LLM analysis successfully', () async {
        // Arrange
        final request = LLMAnalysisRequest(
          symbol: 'BTC-USDT',
          provider: 'gemini',
        );

        final mockResponse = Response(
          data: {
            'provider': 'google',
            'model': 'gemini-2.5-flash',
            'explanation': 'Market shows strong bullish signals',
            'key_factors': ['Technical breakout', 'Volume increase'],
            'risk_assessment': 'Medium',
            'confidence': 0.85,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.post(
          '/api/v1/ai/llm/analyze',
          data: anyNamed('data'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await aiAnalysisService.getLLMAnalysis(request);

        // Assert
        expect(result.provider, equals('google'));
        expect(result.model, equals('gemini-2.5-flash'));
        expect(result.confidence, equals(0.85));
        verify(mockMatpClient.post(
          '/api/v1/ai/llm/analyze',
          data: anyNamed('data'),
        )).called(1);
      });
    });

    group('Sentiment Analysis', () {
      test('should get sentiment analysis successfully', () async {
        // Arrange
        const symbol = 'BTC-USDT';
        const hours = 24;

        final mockResponse = Response(
          data: {
            'overall': 0.75,
            'trend': 'bullish',
            'sources': ['news', 'twitter', 'reddit'],
            'confidence': 0.8,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.post(
          '/api/v1/ai/sentiment/analyze',
          data: anyNamed('data'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result =
            await aiAnalysisService.getSentimentAnalysis(symbol, hours);

        // Assert
        expect(result.overall, equals(0.75));
        expect(result.trend, equals('bullish'));
        expect(result.sources, contains('news'));
        verify(mockMatpClient.post(
          '/api/v1/ai/sentiment/analyze',
          data: anyNamed('data'),
        )).called(1);
      });
    });

    group('Cost Monitoring', () {
      test('should get AI costs successfully', () async {
        // Arrange
        const period = 'day';

        final mockResponse = Response(
          data: {
            'total_cost': 10.50,
            'daily_cost': 2.50,
            'monthly_cost': 75.00,
            'provider_costs': {
              'google': 5.25,
              'openai': 3.15,
              'anthropic': 2.10,
            },
            'call_counts': {
              'google': 15,
              'openai': 8,
              'anthropic': 5,
            },
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.get(
          '/api/v1/ai/costs',
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await aiAnalysisService.getAICosts(period);

        // Assert
        expect(result.totalCost, equals(10.50));
        expect(result.dailyCost, equals(2.50));
        verify(mockMatpClient.get(
          '/api/v1/ai/costs',
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
        '**Feature: backend-integration-update, Property 16: AI Analysis Execution**',
        () async {
      // **Validates: Requirements 4.1**
      // Property: For any AI analysis request, the system should call the appropriate
      // MATP AI endpoints and return complete market analysis

      final testCases = [
        {
          'symbol': 'BTC-USDT',
          'exchange': 'kucoin',
          'includeLLM': true,
          'includeSentiment': true,
        },
        {
          'symbol': 'ETH-USDT',
          'exchange': 'binance',
          'includeLLM': false,
          'includeSentiment': true,
        },
        {
          'symbol': 'ADA-USDT',
          'exchange': 'kucoin',
          'includeLLM': true,
          'includeSentiment': false,
        },
      ];

      for (final testCase in testCases) {
        // Arrange
        final request = AnalysisRequest(
          symbol: testCase['symbol'] as String,
          exchange: testCase['exchange'] as String,
          includeLLM: testCase['includeLLM'] as bool,
          includeSentiment: testCase['includeSentiment'] as bool,
        );

        final mockResponse = Response(
          data: {
            'symbol': request.symbol,
            'exchange': request.exchange,
            'timestamp': DateTime.now().toIso8601String(),
            'price_data': {
              'last': 50000.0,
              'bid': 49999.0,
              'ask': 50001.0,
              'volume': 1000.0,
              'high_24h': 51000.0,
              'low_24h': 49000.0,
              'change_24h': 1000.0,
              'change_percent_24h': 2.0,
            },
            'technical_indicators': {},
            'scenarios': {},
            'recommendation': {
              'action': 'BUY',
              'confidence': 0.8,
              'reasoning': ['Strong technical indicators'],
              'risks': ['Market volatility'],
            },
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.post(
          '/api/v1/ai/analysis/complete',
          data: anyNamed('data'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await aiAnalysisService.getCompleteAnalysis(request);

        // Assert - Property: System should call appropriate endpoints and return analysis
        expect(result.symbol, equals(request.symbol));
        expect(result.exchange, equals(request.exchange));
        expect(result.priceData, isNotNull);
        expect(result.recommendation, isNotNull);

        verify(mockMatpClient.post(
          '/api/v1/ai/analysis/complete',
          data: argThat(
            predicate<Map<String, dynamic>>((data) =>
                data['symbol'] == request.symbol &&
                data['exchange'] == request.exchange &&
                data['include_llm'] == request.includeLLM &&
                data['include_sentiment'] == request.includeSentiment),
            named: 'data',
          ),
        )).called(1);

        // Reset mock for next iteration
        reset(mockMatpClient);
      }
    });

    test(
        '**Feature: backend-integration-update, Property 17: AI Analysis Display**',
        () async {
      // **Validates: Requirements 4.2**
      // Property: For any completed AI analysis, the system should display
      // formatted analysis with clear recommendations

      final testCases = [
        {
          'symbol': 'BTC-USDT',
          'expectedFormat': 'formatted',
        },
        {
          'symbol': 'ETH-USDT',
          'expectedFormat': 'formatted',
        },
        {
          'symbol': 'ADA-USDT',
          'expectedFormat': 'formatted',
        },
      ];

      for (final testCase in testCases) {
        // Arrange
        final request = AnalysisRequest(
          symbol: testCase['symbol'] as String,
          exchange: 'kucoin',
        );

        final mockResponse = Response(
          data: {
            'system_status': 'System operational',
            'market_analysis': 'Market showing bullish trends',
            'position_analysis': 'Current positions are profitable',
            'ai_analysis': 'AI recommends buying',
            'risk_assessment': 'Medium risk level',
            'recommendations': 'Consider increasing position size',
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.post(
          '/api/v1/ai/analysis/formatted',
          data: anyNamed('data'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await aiAnalysisService.getFormattedAnalysis(request);

        // Assert - Property: System should display formatted analysis with clear recommendations
        expect(result.systemStatus, isNotEmpty);
        expect(result.marketAnalysis, isNotEmpty);
        expect(result.aiAnalysis, isNotEmpty);
        expect(result.recommendations, isNotEmpty);

        verify(mockMatpClient.post(
          '/api/v1/ai/analysis/formatted',
          data: anyNamed('data'),
        )).called(1);

        // Reset mock for next iteration
        reset(mockMatpClient);
      }
    });

    test(
        '**Feature: backend-integration-update, Property 18: Sentiment Analysis Retrieval**',
        () async {
      // **Validates: Requirements 4.3**
      // Property: For any sentiment analysis request, the system should retrieve
      // and display market sentiment data from multiple sources

      final testCases = [
        {
          'symbol': 'BTC-USDT',
          'hours': 24,
          'expectedSources': ['news', 'twitter'],
        },
        {
          'symbol': 'ETH-USDT',
          'hours': 12,
          'expectedSources': ['reddit', 'news'],
        },
        {
          'symbol': 'ADA-USDT',
          'hours': 48,
          'expectedSources': ['twitter', 'reddit', 'news'],
        },
      ];

      for (final testCase in testCases) {
        // Arrange
        final symbol = testCase['symbol'] as String;
        final hours = testCase['hours'] as int;
        final expectedSources = testCase['expectedSources'] as List<String>;

        final mockResponse = Response(
          data: {
            'overall': 0.75,
            'trend': 'bullish',
            'sources': expectedSources,
            'confidence': 0.8,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.post(
          '/api/v1/ai/sentiment/analyze',
          data: anyNamed('data'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result =
            await aiAnalysisService.getSentimentAnalysis(symbol, hours);

        // Assert - Property: System should retrieve sentiment data from multiple sources
        expect(result.sources, isNotEmpty);
        expect(result.sources.length, greaterThanOrEqualTo(1));
        expect(result.overall, greaterThanOrEqualTo(0.0));
        expect(result.overall, lessThanOrEqualTo(1.0));
        expect(result.confidence, greaterThanOrEqualTo(0.0));
        expect(result.confidence, lessThanOrEqualTo(1.0));

        // Verify that multiple sources are included
        for (final source in expectedSources) {
          expect(result.sources, contains(source));
        }

        verify(mockMatpClient.post(
          '/api/v1/ai/sentiment/analyze',
          data: argThat(
            predicate<Map<String, dynamic>>(
                (data) => data['symbol'] == symbol && data['hours'] == hours),
            named: 'data',
          ),
        )).called(1);

        // Reset mock for next iteration
        reset(mockMatpClient);
      }
    });

    test(
        '**Feature: backend-integration-update, Property 19: LLM Analysis Execution**',
        () async {
      // **Validates: Requirements 4.4**
      // Property: For any LLM analysis request, the system should call LLM endpoints
      // and display reasoning with confidence scores

      final testCases = [
        {
          'symbol': 'BTC-USDT',
          'provider': 'google',
          'expectedModel': 'gemini-2.5-flash',
        },
        {
          'symbol': 'ETH-USDT',
          'provider': 'openai',
          'expectedModel': 'gpt-4',
        },
        {
          'symbol': 'ADA-USDT',
          'provider': 'anthropic',
          'expectedModel': 'claude-3',
        },
      ];

      for (final testCase in testCases) {
        // Arrange
        final request = LLMAnalysisRequest(
          symbol: testCase['symbol'] as String,
          provider: testCase['provider'] as String,
        );

        final mockResponse = Response(
          data: {
            'provider': testCase['provider'],
            'model': testCase['expectedModel'],
            'explanation': 'Detailed market analysis explanation',
            'key_factors': ['Factor 1', 'Factor 2', 'Factor 3'],
            'risk_assessment': 'Medium',
            'confidence': 0.85,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.post(
          '/api/v1/ai/llm/analyze',
          data: anyNamed('data'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await aiAnalysisService.getLLMAnalysis(request);

        // Assert - Property: System should call LLM endpoints and display reasoning with confidence
        expect(result.provider, equals(testCase['provider']));
        expect(result.model, equals(testCase['expectedModel']));
        expect(result.explanation, isNotEmpty);
        expect(result.keyFactors, isNotEmpty);
        expect(result.confidence, greaterThanOrEqualTo(0.0));
        expect(result.confidence, lessThanOrEqualTo(1.0));
        expect(result.riskAssessment, isNotEmpty);

        verify(mockMatpClient.post(
          '/api/v1/ai/llm/analyze',
          data: argThat(
            predicate<Map<String, dynamic>>((data) =>
                data['symbol'] == request.symbol &&
                data['provider'] == request.provider),
            named: 'data',
          ),
        )).called(1);

        // Reset mock for next iteration
        reset(mockMatpClient);
      }
    });

    test(
        '**Feature: backend-integration-update, Property 20: AI Cost Monitoring**',
        () async {
      // **Validates: Requirements 4.5**
      // Property: For any AI operation that would exceed cost limits, the system
      // should warn users about budget constraints before execution

      final testCases = [
        {
          'operation': 'analysis',
          'estimatedCost': 5.0,
          'remainingBudget': 10.0,
          'shouldApprove': true,
        },
        {
          'operation': 'llm',
          'estimatedCost': 15.0,
          'remainingBudget': 10.0,
          'shouldApprove': false,
        },
        {
          'operation': 'sentiment',
          'estimatedCost': 2.0,
          'remainingBudget': 50.0,
          'shouldApprove': true,
        },
      ];

      for (final testCase in testCases) {
        // Arrange
        final operation = testCase['operation'] as String;
        final estimatedCost = testCase['estimatedCost'] as double;
        final remainingBudget = testCase['remainingBudget'] as double;
        final shouldApprove = testCase['shouldApprove'] as bool;

        final mockResponse = Response(
          data: {
            'approved': shouldApprove,
            'warning': shouldApprove ? null : 'Insufficient budget',
            'remaining_budget': remainingBudget,
            'estimated_total': estimatedCost,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockMatpClient.post(
          '/api/v1/ai/costs/check',
          data: anyNamed('data'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result =
            await aiAnalysisService.checkCostLimits(operation, estimatedCost);

        // Assert - Property: System should warn about budget constraints
        expect(result.approved, equals(shouldApprove));
        expect(result.remainingBudget, equals(remainingBudget));
        expect(result.estimatedTotal, equals(estimatedCost));

        if (!shouldApprove) {
          expect(result.warning, isNotNull);
          expect(result.warning, isNotEmpty);
        }

        verify(mockMatpClient.post(
          '/api/v1/ai/costs/check',
          data: argThat(
            predicate<Map<String, dynamic>>((data) =>
                data['operation'] == operation &&
                data['estimated_cost'] == estimatedCost),
            named: 'data',
          ),
        )).called(1);

        // Reset mock for next iteration
        reset(mockMatpClient);
      }
    });
  });
}
