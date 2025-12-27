import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_costs.dart';
import '../services/logging_service.dart';

/// Provider para costos de IA
///
/// Gestiona el estado de los costos acumulados de servicios de IA
final aICostsNotifierProvider =
    StateNotifierProvider<AICostsNotifier, AsyncValue<AICosts>>(
  (ref) => AICostsNotifier(),
);

/// Notifier para gestionar costos de IA
class AICostsNotifier extends StateNotifier<AsyncValue<AICosts>> {
  AICostsNotifier() : super(const AsyncValue.loading()) {
    _loadCosts();
  }

  /// Carga los costos desde el backend
  Future<void> _loadCosts() async {
    state = const AsyncValue.loading();
    try {
      // Return empty costs structure - ready for AI service integration
      const costs = AICosts(
        today: DailyCosts(total: 0.0, callCount: 0, byProvider: {}),
        thisMonth: MonthlyCosts(total: 0.0, projected: 0.0),
      );
      state = const AsyncValue.data(costs);

      // TODO: Replace with actual AI service call when available
      // final costs = await aiService.getCosts();
      // state = AsyncValue.data(costs);
    } catch (error, stackTrace) {
      LoggingService.instance.error(
        'Error loading AI costs',
        tag: 'AICostsProvider',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresca los costos
  Future<void> refresh() async {
    await _loadCosts();
  }
}
