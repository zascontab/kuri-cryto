import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rebalancing_plan.dart';
import '../services/portfolio_service.dart';
import 'portfolio_provider.dart';

/// Provider for rebalancing plan
final rebalancingProvider =
    StateNotifierProvider<RebalancingNotifier, AsyncValue<RebalancingPlan?>>(
        (ref) {
  final service = ref.watch(portfolioServiceProvider);
  return RebalancingNotifier(service);
});

/// Rebalancing state notifier
class RebalancingNotifier extends StateNotifier<AsyncValue<RebalancingPlan?>> {
  final PortfolioService _service;

  RebalancingNotifier(this._service) : super(const AsyncValue.data(null));

  /// Generate rebalancing plan
  Future<void> generatePlan(Map<String, double> targetAllocations) async {
    state = const AsyncValue.loading();
    try {
      final plan = await _service.generateRebalancingPlan(targetAllocations);
      state = AsyncValue.data(plan);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Clear plan
  void clearPlan() {
    state = const AsyncValue.data(null);
  }
}
