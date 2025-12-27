import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/ai_status.dart';
import '../services/ai_service.dart';
import 'services_provider.dart';

part 'ai_status_provider.g.dart';

/// Provider for AI Service
@riverpod
AIService aiService(AiServiceRef ref) {
  final dio = ref.watch(dioProvider);
  return AIService(dio);
}

/// Provider for AI Status with auto-refresh every 30 seconds
///
/// Fetches current AI system status including:
/// - LLM status (provider, model, calls, limits)
/// - Sentiment analysis status
/// - Cost management (budget, spent, remaining)
///
/// Auto-refreshes every 30 seconds while provider is alive
@riverpod
class AIStatusNotifier extends _$AIStatusNotifier {
  Timer? _timer;

  @override
  FutureOr<AIStatus> build() async {
    ref.onDispose(() {
      _timer?.cancel();
    });

    _startAutoRefresh();
    return _fetchStatus();
  }

  Future<AIStatus> _fetchStatus() async {
    final service = ref.read(aiServiceProvider);
    return await service.getAIStatus();
  }

  void _startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      refresh();
    });
  }

  /// Manually refresh AI status
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchStatus());
  }

  /// Stop auto-refresh
  void stopAutoRefresh() {
    _timer?.cancel();
  }

  /// Restart auto-refresh
  void restartAutoRefresh() {
    _startAutoRefresh();
  }
}
