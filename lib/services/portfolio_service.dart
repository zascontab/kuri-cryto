import 'package:dio/dio.dart';
import 'package:kuri_crypto/models/rebalancing_plan.dart';
import '../models/models.dart';
import '../config/api_config.dart';
import 'api_exception.dart';

/// Service for portfolio management operations
class PortfolioService {
  final Dio _dio;

  PortfolioService(this._dio);

  /// Get complete portfolio with all assets
  Future<Portfolio> getPortfolio() async {
    try {
      final response = await _dio.get(
        '${ApiConfig.gatewayBaseUrl}/portfolio',
      );

      return Portfolio.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get all assets in portfolio
  Future<List<Asset>> getAssets() async {
    try {
      final portfolio = await getPortfolio();
      final assets = List<Asset>.from(portfolio.assets);

      // Sort by value descending
      assets.sort((a, b) => b.value.compareTo(a.value));

      return assets;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get performance data for specified time period
  Future<PerformanceData> getPerformance(TimePeriod period) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.gatewayBaseUrl}/portfolio/performance',
        queryParameters: {
          'period': period.value,
        },
      );

      return PerformanceData.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Assess portfolio risk
  Future<RiskAssessment> assessRisk() async {
    try {
      final response = await _dio.get(
        '${ApiConfig.gatewayBaseUrl}/portfolio/risk',
      );

      return RiskAssessment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generate rebalancing plan based on target allocations
  Future<RebalancingPlan> generateRebalancingPlan(
      Map<String, double> targetAllocations) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.gatewayBaseUrl}/portfolio/rebalance',
        data: {
          'target_allocations': targetAllocations,
        },
      );

      return RebalancingPlan.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      return ApiException(
        message: data['error'] ?? data['message'] ?? 'Unknown error',
        details: data['details'],
        statusCode: e.response!.statusCode,
      );
    }
    return ApiException(
      message: 'Network error: ${e.message}',
      statusCode: null,
    );
  }
}

/// Time period enum for performance queries
enum TimePeriod {
  day('1D'),
  week('1W'),
  month('1M'),
  threeMonths('3M'),
  year('1Y'),
  all('ALL');

  final String value;
  const TimePeriod(this.value);
}
