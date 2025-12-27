import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/bot_status.dart';
import '../models/bot_config.dart';
import '../models/positions_response.dart';
import '../services/ai_bot_service.dart';
import '../services/logging_service.dart';
import '../utils/retry_helper.dart';
import '../utils/error_handler.dart';
import '../exceptions/trading_api_exceptions.dart';
import 'api_client_provider.dart';

/// Estado del bot de IA
class AIBotState {
  final BotStatus? status;
  final BotConfig? config;
  final PositionsResponse? positions;
  final bool isLoading;
  final String? error;
  final TradingApiException? lastException;
  final DateTime? lastUpdated;
  final int retryCount;

  const AIBotState({
    this.status,
    this.config,
    this.positions,
    this.isLoading = false,
    this.error,
    this.lastException,
    this.lastUpdated,
    this.retryCount = 0,
  });

  AIBotState copyWith({
    BotStatus? status,
    BotConfig? config,
    PositionsResponse? positions,
    bool? isLoading,
    String? error,
    TradingApiException? lastException,
    DateTime? lastUpdated,
    int? retryCount,
  }) {
    return AIBotState(
      status: status ?? this.status,
      config: config ?? this.config,
      positions: positions ?? this.positions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastException: lastException,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  /// Whether the last error is recoverable
  bool get canRetry => lastException?.isRecoverable ?? false;

  /// User-friendly error message
  String? get userFriendlyError => lastException?.userFriendlyMessage ?? error;
}

/// Provider del servicio AIBot
final aiBotServiceProvider = Provider<AIBotService>((ref) {
  final dio = ref.watch(dioProvider);
  return AIBotService(dio);
});

/// Provider del estado del bot
final aiBotProvider = StateNotifierProvider<AIBotNotifier, AIBotState>((ref) {
  final service = ref.watch(aiBotServiceProvider);
  return AIBotNotifier(service);
});

/// Notifier para gestionar el estado del bot
class AIBotNotifier extends StateNotifier<AIBotState> {
  final AIBotService _service;
  Timer? _autoRefreshTimer;

  AIBotNotifier(this._service) : super(const AIBotState()) {
    loadAll();
  }

  /// Carga todos los datos del bot
  Future<void> loadAll() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      lastException: null,
      retryCount: 0,
    );

    LoggingService.instance.info(
      'Loading all bot data',
      tag: 'AIBotProvider',
    );

    try {
      await Future.wait([
        _loadStatusWithRetry(),
        _loadConfigWithRetry(),
        _loadPositionsWithRetry(),
      ]);

      state = state.copyWith(
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      LoggingService.instance.info(
        'Successfully loaded all bot data',
        tag: 'AIBotProvider',
      );
    } catch (e) {
      final exception = e is TradingApiException ? e : null;
      final errorMessage = getErrorMessage(e);

      LoggingService.instance.error(
        'Failed to load bot data',
        tag: 'AIBotProvider',
        error: e,
      );

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        lastException: exception,
      );
    }
  }

  /// Carga el estado del bot
  Future<void> loadStatus() async {
    try {
      final status = await _service.getStatus();
      state = state.copyWith(
        status: status,
        isLoading: false,
        error: null,
        lastException: null,
      );
    } catch (e) {
      final exception = e is TradingApiException ? e : null;
      final errorMessage = getErrorMessage(e);

      LoggingService.instance.error(
        'Failed to load bot status',
        tag: 'AIBotProvider',
        error: e,
      );

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        lastException: exception,
      );
    }
  }

  /// Carga el estado del bot con retry
  Future<void> _loadStatusWithRetry() async {
    return RetryHelper.execute(
      () => _service.getStatus(),
      maxRetries: 2,
      shouldRetry: (error) =>
          error is NetworkException || error is TimeoutException,
    ).then((status) {
      state = state.copyWith(
        status: status,
        error: null,
        lastException: null,
      );
    });
  }

  /// Carga la configuración del bot
  Future<void> loadConfig() async {
    try {
      final config = await _service.getConfig();
      state = state.copyWith(
        config: config,
        error: null,
        lastException: null,
      );
    } catch (e) {
      final exception = e is TradingApiException ? e : null;
      final errorMessage = getErrorMessage(e);

      LoggingService.instance.error(
        'Failed to load bot config',
        tag: 'AIBotProvider',
        error: e,
      );

      state = state.copyWith(
        error: errorMessage,
        lastException: exception,
      );
    }
  }

  /// Carga la configuración del bot con retry
  Future<void> _loadConfigWithRetry() async {
    return RetryHelper.execute(
      () => _service.getConfig(),
      maxRetries: 2,
      shouldRetry: (error) =>
          error is NetworkException || error is TimeoutException,
    ).then((config) {
      state = state.copyWith(
        config: config,
        error: null,
        lastException: null,
      );
    });
  }

  /// Carga las posiciones del bot
  Future<void> loadPositions() async {
    try {
      final positions = await _service.getPositions();
      state = state.copyWith(
        positions: positions,
        error: null,
        lastException: null,
      );
    } catch (e) {
      final exception = e is TradingApiException ? e : null;
      final errorMessage = getErrorMessage(e);

      LoggingService.instance.error(
        'Failed to load bot positions',
        tag: 'AIBotProvider',
        error: e,
      );

      state = state.copyWith(
        error: errorMessage,
        lastException: exception,
      );
    }
  }

  /// Carga las posiciones del bot con retry
  Future<void> _loadPositionsWithRetry() async {
    return RetryHelper.execute(
      () => _service.getPositions(),
      maxRetries: 2,
      shouldRetry: (error) =>
          error is NetworkException || error is TimeoutException,
    ).then((positions) {
      state = state.copyWith(
        positions: positions,
        error: null,
        lastException: null,
      );
    });
  }

  /// Inicia el bot
  Future<bool> startBot() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      lastException: null,
    );

    LoggingService.instance.info(
      'Starting bot',
      tag: 'AIBotProvider',
    );

    try {
      final response = await RetryHelper.execute(
        () => _service.start(),
        maxRetries: 2,
        shouldRetry: (error) =>
            error is NetworkException || error is TimeoutException,
      );

      if (response.success) {
        LoggingService.instance.info(
          'Bot started successfully',
          tag: 'AIBotProvider',
        );
        await loadStatus();
        return true;
      } else {
        LoggingService.instance.warning(
          'Bot start failed',
          tag: 'AIBotProvider',
          context: {'message': response.message},
        );
        state = state.copyWith(
          isLoading: false,
          error: response.message,
        );
        return false;
      }
    } catch (e) {
      final exception = e is TradingApiException ? e : null;
      final errorMessage = getErrorMessage(e);

      LoggingService.instance.error(
        'Failed to start bot',
        tag: 'AIBotProvider',
        error: e,
      );

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        lastException: exception,
      );
      return false;
    }
  }

  /// Detiene el bot
  Future<bool> stopBot() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      lastException: null,
    );

    LoggingService.instance.info(
      'Stopping bot',
      tag: 'AIBotProvider',
    );

    try {
      final response = await RetryHelper.execute(
        () => _service.stop(),
        maxRetries: 2,
        shouldRetry: (error) =>
            error is NetworkException || error is TimeoutException,
      );

      if (response.success) {
        LoggingService.instance.info(
          'Bot stopped successfully',
          tag: 'AIBotProvider',
        );
        await loadStatus();
        return true;
      } else {
        LoggingService.instance.warning(
          'Bot stop failed',
          tag: 'AIBotProvider',
          context: {'message': response.message},
        );
        state = state.copyWith(
          isLoading: false,
          error: response.message,
        );
        return false;
      }
    } catch (e) {
      final exception = e is TradingApiException ? e : null;
      final errorMessage = getErrorMessage(e);

      LoggingService.instance.error(
        'Failed to stop bot',
        tag: 'AIBotProvider',
        error: e,
      );

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        lastException: exception,
      );
      return false;
    }
  }

  /// Actualiza la configuración del bot
  Future<bool> updateConfig(BotConfig config) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      lastException: null,
    );

    LoggingService.instance.info(
      'Updating bot config',
      tag: 'AIBotProvider',
      context: config.toJson(),
    );

    try {
      final updatedConfig = await RetryHelper.execute(
        () => _service.updateConfig(config),
        maxRetries: 2,
        shouldRetry: (error) =>
            error is NetworkException || error is TimeoutException,
      );

      LoggingService.instance.info(
        'Bot config updated successfully',
        tag: 'AIBotProvider',
      );

      state = state.copyWith(
        config: updatedConfig,
        isLoading: false,
        error: null,
        lastException: null,
      );
      return true;
    } catch (e) {
      final exception = e is TradingApiException ? e : null;
      final errorMessage = getErrorMessage(e);

      LoggingService.instance.error(
        'Failed to update bot config',
        tag: 'AIBotProvider',
        error: e,
      );

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        lastException: exception,
      );
      return false;
    }
  }

  /// Inicia auto-refresh de posiciones
  void startAutoRefresh({Duration interval = const Duration(seconds: 5)}) {
    stopAutoRefresh();
    _autoRefreshTimer = Timer.periodic(interval, (_) {
      loadPositions();
    });
  }

  /// Detiene auto-refresh
  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  /// Refresca todos los datos
  Future<void> refresh() async {
    await loadAll();
  }

  /// Retry the last failed operation
  Future<void> retryLastOperation() async {
    if (!canRetry) return;

    final currentRetryCount = state.retryCount + 1;
    state = state.copyWith(
      retryCount: currentRetryCount,
      isLoading: true,
      error: null,
    );

    LoggingService.instance.info(
      'Retrying last operation (attempt $currentRetryCount)',
      tag: 'AIBotProvider',
    );

    await loadAll();
  }

  /// Whether retry is available
  bool get canRetry => state.canRetry && state.retryCount < 3;

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
