import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:kuri_crypto/models/rebalancing_plan.dart';
import '../models/models.dart';
import '../services/portfolio_service.dart';
import '../services/exchange_aggregator.dart';

/// Provider for PortfolioService
final portfolioServiceProvider = Provider<PortfolioService>((ref) {
  final dio = Dio();
  return PortfolioService(dio);
});

/// Provider for ExchangeAggregator
final exchangeAggregatorProvider = Provider<ExchangeAggregator>((ref) {
  final dio = Dio();
  return ExchangeAggregator(dio);
});

/// Provider for portfolio state
final portfolioProvider =
    StateNotifierProvider<PortfolioNotifier, AsyncValue<Portfolio>>((ref) {
  final service = ref.watch(portfolioServiceProvider);
  return PortfolioNotifier(service);
});

/// Portfolio state notifier
class PortfolioNotifier extends StateNotifier<AsyncValue<Portfolio>> {
  final PortfolioService _service;

  PortfolioNotifier(this._service) : super(const AsyncValue.loading()) {
    loadPortfolio();
  }

  /// Load portfolio data
  Future<void> loadPortfolio() async {
    state = const AsyncValue.loading();
    try {
      final portfolio = await _service.getPortfolio();
      state = AsyncValue.data(portfolio);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh portfolio data
  Future<void> refresh() async {
    await loadPortfolio();
  }

  /// Get total value
  double? get totalValue => state.value?.totalValue;

  /// Get 24h change
  double? get change24h => state.value?.change24h;

  /// Get total PnL
  double? get totalPnl => state.value?.totalPnl;
}

/// Provider for assets list
final assetsProvider = FutureProvider<List<Asset>>((ref) async {
  final service = ref.watch(portfolioServiceProvider);
  return service.getAssets();
});

/// Provider for performance data
final performanceProvider =
    FutureProvider.family<PerformanceData, TimePeriod>((ref, period) async {
  final service = ref.watch(portfolioServiceProvider);
  return service.getPerformance(period);
});

/// Provider for risk assessment
final riskAssessmentProvider = FutureProvider<RiskAssessment>((ref) async {
  final service = ref.watch(portfolioServiceProvider);
  return service.assessRisk();
});

/// Provider for rebalancing plan
final rebalancingPlanProvider =
    FutureProvider.family<RebalancingPlan, Map<String, double>>(
        (ref, targetAllocations) async {
  final service = ref.watch(portfolioServiceProvider);
  return service.generateRebalancingPlan(targetAllocations);
});
