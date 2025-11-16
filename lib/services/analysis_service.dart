import 'dart:developer' as developer;
import 'api_client.dart';
import 'api_exception.dart';
import '../models/analysis.dart';

/// Analysis Service
///
/// Handles multi-timeframe market analysis operations:
/// - Analyze symbol across multiple timeframes
/// - Get technical indicators (RSI, MACD, Bollinger)
/// - Generate trading signals with confidence scores
class AnalysisService {
  final ApiClient _apiClient;
  static const String _basePath = '/analysis';

  AnalysisService(this._apiClient);

  /// Analyze a symbol across multiple timeframes
  ///
  /// Performs technical analysis on the specified symbol using
  /// multiple timeframes (1m, 3m, 5m, 15m) and returns aggregated
  /// signals with consensus.
  ///
  /// Parameters:
  /// - [symbol]: Trading pair symbol (e.g., 'BTCUSDT')
  /// - [timeframes]: List of timeframes to analyze (defaults to [1m, 3m, 5m, 15m])
  ///
  /// Returns [MultiTimeframeAnalysis] with:
  /// - Individual timeframe analyses
  /// - Consensus signal and confidence
  /// - Technical indicators for each timeframe
  ///
  /// Example:
  /// ```dart
  /// final analysis = await analysisService.analyzeMultiTimeframe(
  ///   'BTCUSDT',
  ///   timeframes: ['1m', '5m', '15m'],
  /// );
  /// print('Consensus: ${analysis.consensusSignal}');
  /// print('Confidence: ${analysis.consensusConfidence}%');
  /// ```
  Future<MultiTimeframeAnalysis> analyzeMultiTimeframe(
    String symbol, {
    List<String>? timeframes,
  }) async {
    try {
      developer.log(
        'Analyzing multi-timeframe for $symbol...',
        name: 'AnalysisService',
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_basePath/multi-timeframe',
        data: {
          'symbol': symbol,
          if (timeframes != null) 'timeframes': timeframes,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final analysis = MultiTimeframeAnalysis.fromJson(response['data']);
        developer.log(
          'Multi-timeframe analysis completed for $symbol',
          name: 'AnalysisService',
        );
        return analysis;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log(
        'Error analyzing multi-timeframe: $e',
        name: 'AnalysisService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get analysis for a specific symbol and timeframe
  ///
  /// Parameters:
  /// - [symbol]: Trading pair symbol (e.g., 'BTCUSDT')
  /// - [timeframe]: Timeframe to analyze (e.g., '5m', '15m')
  ///
  /// Returns [TimeframeAnalysis] with indicators and signal
  ///
  /// Example:
  /// ```dart
  /// final analysis = await analysisService.analyzeTimeframe(
  ///   'BTCUSDT',
  ///   '5m',
  /// );
  /// print('RSI: ${analysis.indicators.rsi}');
  /// ```
  Future<TimeframeAnalysis> analyzeTimeframe(
    String symbol,
    String timeframe,
  ) async {
    try {
      developer.log(
        'Analyzing $symbol on $timeframe...',
        name: 'AnalysisService',
      );

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_basePath/$symbol/$timeframe',
      );

      if (response['success'] == true && response['data'] != null) {
        final analysis = TimeframeAnalysis.fromJson(response['data']);
        developer.log(
          'Analysis completed for $symbol on $timeframe',
          name: 'AnalysisService',
        );
        return analysis;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log(
        'Error analyzing timeframe: $e',
        name: 'AnalysisService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get available symbols for analysis
  ///
  /// Returns list of trading pairs that can be analyzed
  ///
  /// Example:
  /// ```dart
  /// final symbols = await analysisService.getAvailableSymbols();
  /// print('Available symbols: $symbols');
  /// ```
  Future<List<String>> getAvailableSymbols() async {
    try {
      developer.log(
        'Fetching available symbols...',
        name: 'AnalysisService',
      );

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_basePath/symbols',
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> symbolsData = response['data'];
        final symbols = symbolsData.map((s) => s.toString()).toList();
        developer.log(
          'Retrieved ${symbols.length} symbols',
          name: 'AnalysisService',
        );
        return symbols;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log(
        'Error getting symbols: $e',
        name: 'AnalysisService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get supported timeframes
  ///
  /// Returns list of timeframes available for analysis
  ///
  /// Example:
  /// ```dart
  /// final timeframes = await analysisService.getSupportedTimeframes();
  /// ```
  Future<List<String>> getSupportedTimeframes() async {
    try {
      developer.log(
        'Fetching supported timeframes...',
        name: 'AnalysisService',
      );

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_basePath/timeframes',
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> timeframesData = response['data'];
        final timeframes = timeframesData.map((t) => t.toString()).toList();
        developer.log(
          'Retrieved ${timeframes.length} timeframes',
          name: 'AnalysisService',
        );
        return timeframes;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log(
        'Error getting timeframes: $e',
        name: 'AnalysisService',
        error: e,
      );
      rethrow;
    }
  }
}
