import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/portfolio_service.dart';
import 'portfolio_provider.dart';

/// Provider for analytics data
final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AsyncValue<PerformanceData>>(
        (ref) {
  final service = ref.watch(portfolioServiceProvider);
  return AnalyticsNotifier(service);
});

/// Analytics state notifier
class AnalyticsNotifier extends StateNotifier<AsyncValue<PerformanceData>> {
  final PortfolioService _service;
  TimePeriod _currentPeriod = TimePeriod.month;

  AnalyticsNotifier(this._service) : super(const AsyncValue.loading()) {
    loadPerformance(TimePeriod.month);
  }

  /// Load performance data for period
  Future<void> loadPerformance(TimePeriod period) async {
    _currentPeriod = period;
    state = const AsyncValue.loading();
    try {
      final performance = await _service.getPerformance(period);
      state = AsyncValue.data(performance);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh current period
  Future<void> refresh() async {
    await loadPerformance(_currentPeriod);
  }

  /// Get current period
  TimePeriod get currentPeriod => _currentPeriod;
}
