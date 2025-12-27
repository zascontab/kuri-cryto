import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/bot_status.dart';
import '../models/bot_config.dart';
import '../services/autonomous_bot_service.dart';
import '../services/performance_cache_service.dart';
import '../services/logging_service.dart';

part 'bot_control_provider.g.dart';

/// Bot Control Provider for autonomous trading bot management
class BotControlProvider extends StateNotifier<BotState> {
  final AutonomousBotService _botService;
  final PerformanceCacheService _cacheService;

  StreamSubscription<BotStatusUpdate>? _statusSubscription;
  StreamSubscription<BotPerformanceUpdate>? _performanceSubscription;
  Timer? _healthCheckTimer;

  BotControlProvider(this._botService, this._cacheService)
      : super(const BotState.initial()) {
    _initializeProvider();
  }

  void _initializeProvider() {
    _subscribeToStatusUpdates();
    _subscribeToPerformanceUpdates();
    _startHealthChecks();

    LoggingService.instance.info(
      'Bot control provider initialized',
      tag: 'BotControlProvider',
    );
  }

  /// Start the bot
  Future<void> startBot() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final status = await _botService.startBot();

      state = state.copyWith(
        status: status,
        isLoading: false,
        lastStatusUpdate: DateTime.now(),
      );

      LoggingService.instance.info(
        'Bot started successfully',
        tag: 'BotControlProvider',
        context: {'bot_state': status.status},
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      LoggingService.instance.error(
        'Failed to start bot: $e',
        tag: 'BotControlProvider',
        error: e,
      );
    }
  }

  /// Stop the bot
  Future<void> stopBot() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final status = await _botService.stopBot();

      state = state.copyWith(
        status: status,
        isLoading: false,
        lastStatusUpdate: DateTime.now(),
      );

      LoggingService.instance.info(
        'Bot stopped successfully',
        tag: 'BotControlProvider',
        context: {'bot_state': status.status},
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      LoggingService.instance.error(
        'Failed to stop bot: $e',
        tag: 'BotControlProvider',
        error: e,
      );
    }
  }

  /// Pause the bot
  Future<void> pauseBot() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final status = await _botService.pauseBot();

      state = state.copyWith(
        status: status,
        isLoading: false,
        lastStatusUpdate: DateTime.now(),
      );

      LoggingService.instance.info(
        'Bot paused successfully',
        tag: 'BotControlProvider',
        context: {'bot_state': status.status},
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      LoggingService.instance.error(
        'Failed to pause bot: $e',
        tag: 'BotControlProvider',
        error: e,
      );
    }
  }

  /// Emergency stop the bot
  Future<void> emergencyStop() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _botService.emergencyStop();

      // Reload status after emergency stop
      final status = await _botService.getBotStatus();

      state = state.copyWith(
        status: status,
        isLoading: false,
        lastStatusUpdate: DateTime.now(),
        emergencyStopExecuted: true,
      );

      LoggingService.instance.warning(
        'Emergency stop executed',
        tag: 'BotControlProvider',
        context: {
          'response': response.message,
          'bot_state': status.status,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      LoggingService.instance.error(
        'Failed to execute emergency stop: $e',
        tag: 'BotControlProvider',
        error: e,
      );
    }
  }

  /// Load bot configuration
  Future<void> loadBotConfig() async {
    try {
      state = state.copyWith(isLoadingConfig: true, configError: null);

      const cacheKey = 'bot_config';

      final config = await _cacheService.getWithCaching<BotConfig>(
        key: cacheKey,
        fetchFunction: () => _botService.getBotConfig(),
        customTtl: const Duration(minutes: 5), // Config doesn't change often
      );

      state = state.copyWith(
        config: config,
        isLoadingConfig: false,
        lastConfigUpdate: DateTime.now(),
      );

      LoggingService.instance.info(
        'Bot configuration loaded',
        tag: 'BotControlProvider',
        context: {
          'confidence_threshold': config.confidenceThreshold,
          'max_positions': config.maxPositions,
          'dry_run': config.dryRun,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingConfig: false,
        configError: e.toString(),
      );

      LoggingService.instance.error(
        'Failed to load bot config: $e',
        tag: 'BotControlProvider',
        error: e,
      );
    }
  }

  /// Update bot configuration
  Future<void> updateBotConfig(BotConfig config) async {
    try {
      state = state.copyWith(isLoadingConfig: true, configError: null);

      final updatedConfig = await _botService.updateBotConfig(config);

      state = state.copyWith(
        config: updatedConfig,
        isLoadingConfig: false,
        lastConfigUpdate: DateTime.now(),
      );

      // Invalidate cache
      await _invalidateBotConfigCache();

      LoggingService.instance.info(
        'Bot configuration updated',
        tag: 'BotControlProvider',
        context: {
          'confidence_threshold': updatedConfig.confidenceThreshold,
          'max_positions': updatedConfig.maxPositions,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingConfig: false,
        configError: e.toString(),
      );

      LoggingService.instance.error(
        'Failed to update bot config: $e',
        tag: 'BotControlProvider',
        error: e,
      );
    }
  }

  /// Enable autonomous mode
  Future<void> enableAutonomousMode(AutonomousConfig config) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final autonomousStatus = await _botService.enableAutonomousMode(config);

      state = state.copyWith(
        autonomousStatus: autonomousStatus,
        isLoading: false,
        lastStatusUpdate: DateTime.now(),
      );

      LoggingService.instance.info(
        'Autonomous mode enabled',
        tag: 'BotControlProvider',
        context: {
          'risk_tolerance': config.riskTolerance,
          'allowed_symbols': config.allowedSymbols.length,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      LoggingService.instance.error(
        'Failed to enable autonomous mode: $e',
        tag: 'BotControlProvider',
        error: e,
      );
    }
  }

  /// Disable autonomous mode
  Future<void> disableAutonomousMode() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final autonomousStatus = await _botService.disableAutonomousMode();

      state = state.copyWith(
        autonomousStatus: autonomousStatus,
        isLoading: false,
        lastStatusUpdate: DateTime.now(),
      );

      LoggingService.instance.info(
        'Autonomous mode disabled',
        tag: 'BotControlProvider',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      LoggingService.instance.error(
        'Failed to disable autonomous mode: $e',
        tag: 'BotControlProvider',
        error: e,
      );
    }
  }

  /// Load bot performance
  Future<void> loadBotPerformance({String timeframe = '24h'}) async {
    try {
      state =
          state.copyWith(isLoadingPerformance: true, performanceError: null);

      final cacheKey = 'bot_performance_$timeframe';

      final performance = await _cacheService.getWithCaching<BotPerformance>(
        key: cacheKey,
        fetchFunction: () =>
            _botService.getBotPerformance(timeframe: timeframe),
        customTtl: const Duration(minutes: 2), // Performance updates frequently
      );

      state = state.copyWith(
        performance: performance,
        isLoadingPerformance: false,
        lastPerformanceUpdate: DateTime.now(),
      );

      LoggingService.instance.info(
        'Bot performance loaded',
        tag: 'BotControlProvider',
        context: {
          'timeframe': timeframe,
          'total_pnl': performance.totalPnl,
          'win_rate': performance.winRate,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingPerformance: false,
        performanceError: e.toString(),
      );

      LoggingService.instance.error(
        'Failed to load bot performance: $e',
        tag: 'BotControlProvider',
        error: e,
      );
    }
  }

  /// Subscribe to real-time status updates
  void _subscribeToStatusUpdates() {
    _statusSubscription?.cancel();

    _statusSubscription = _botService.subscribeToStatusUpdates().listen(
      (update) => _handleStatusUpdate(update),
      onError: (error) {
        LoggingService.instance.error(
          'Bot status update stream error: $error',
          tag: 'BotControlProvider',
          error: error,
        );
      },
    );
  }

  /// Subscribe to real-time performance updates
  void _subscribeToPerformanceUpdates() {
    _performanceSubscription?.cancel();

    _performanceSubscription =
        _botService.subscribeToPerformanceUpdates().listen(
      (update) => _handlePerformanceUpdate(update),
      onError: (error) {
        LoggingService.instance.error(
          'Bot performance update stream error: $error',
          tag: 'BotControlProvider',
          error: error,
        );
      },
    );
  }

  /// Handle status updates
  void _handleStatusUpdate(BotStatusUpdate update) {
    state = state.copyWith(
      status: update.status,
      lastStatusUpdate: update.timestamp,
    );

    LoggingService.instance.debug(
      'Bot status updated',
      tag: 'BotControlProvider',
      context: {
        'bot_state': update.status.status,
        'autonomous_mode': update.status.isRunning,
      },
    );
  }

  /// Handle performance updates
  void _handlePerformanceUpdate(BotPerformanceUpdate update) {
    state = state.copyWith(
      performance: update.performance,
      lastPerformanceUpdate: update.timestamp,
    );

    LoggingService.instance.debug(
      'Bot performance updated',
      tag: 'BotControlProvider',
      context: {
        'total_pnl': update.performance.totalPnl,
        'total_trades': update.performance.totalTrades,
      },
    );
  }

  /// Start health checks
  void _startHealthChecks() {
    _healthCheckTimer?.cancel();

    _healthCheckTimer = Timer.periodic(
      const Duration(minutes: 5), // Health check every 5 minutes
      (_) => _performHealthCheck(),
    );
  }

  /// Perform health check
  Future<void> _performHealthCheck() async {
    try {
      final healthCheck = await _botService.getBotHealthCheck();

      state = state.copyWith(
        healthCheck: healthCheck,
        lastHealthCheck: DateTime.now(),
      );

      if (!healthCheck.healthy) {
        LoggingService.instance.warning(
          'Bot health check failed',
          tag: 'BotControlProvider',
          context: {
            'issues': healthCheck.issues,
          },
        );
      }
    } catch (e) {
      LoggingService.instance.error(
        'Health check failed: $e',
        tag: 'BotControlProvider',
        error: e,
      );
    }
  }

  /// Invalidate bot config cache
  Future<void> _invalidateBotConfigCache() async {
    // Implementation would invalidate cache
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _performanceSubscription?.cancel();
    _healthCheckTimer?.cancel();
    super.dispose();
  }
}

/// Bot state
class BotState {
  final BotStatus? status;
  final BotConfig? config;
  final BotPerformance? performance;
  final AutonomousStatus? autonomousStatus;
  final BotHealthCheck? healthCheck;
  final bool isLoading;
  final bool isLoadingConfig;
  final bool isLoadingPerformance;
  final bool emergencyStopExecuted;
  final String? error;
  final String? configError;
  final String? performanceError;
  final DateTime? lastStatusUpdate;
  final DateTime? lastConfigUpdate;
  final DateTime? lastPerformanceUpdate;
  final DateTime? lastHealthCheck;

  const BotState({
    this.status,
    this.config,
    this.performance,
    this.autonomousStatus,
    this.healthCheck,
    required this.isLoading,
    required this.isLoadingConfig,
    required this.isLoadingPerformance,
    required this.emergencyStopExecuted,
    this.error,
    this.configError,
    this.performanceError,
    this.lastStatusUpdate,
    this.lastConfigUpdate,
    this.lastPerformanceUpdate,
    this.lastHealthCheck,
  });

  const BotState.initial()
      : status = null,
        config = null,
        performance = null,
        autonomousStatus = null,
        healthCheck = null,
        isLoading = false,
        isLoadingConfig = false,
        isLoadingPerformance = false,
        emergencyStopExecuted = false,
        error = null,
        configError = null,
        performanceError = null,
        lastStatusUpdate = null,
        lastConfigUpdate = null,
        lastPerformanceUpdate = null,
        lastHealthCheck = null;

  BotState copyWith({
    BotStatus? status,
    BotConfig? config,
    BotPerformance? performance,
    AutonomousStatus? autonomousStatus,
    BotHealthCheck? healthCheck,
    bool? isLoading,
    bool? isLoadingConfig,
    bool? isLoadingPerformance,
    bool? emergencyStopExecuted,
    String? error,
    String? configError,
    String? performanceError,
    DateTime? lastStatusUpdate,
    DateTime? lastConfigUpdate,
    DateTime? lastPerformanceUpdate,
    DateTime? lastHealthCheck,
  }) {
    return BotState(
      status: status ?? this.status,
      config: config ?? this.config,
      performance: performance ?? this.performance,
      autonomousStatus: autonomousStatus ?? this.autonomousStatus,
      healthCheck: healthCheck ?? this.healthCheck,
      isLoading: isLoading ?? this.isLoading,
      isLoadingConfig: isLoadingConfig ?? this.isLoadingConfig,
      isLoadingPerformance: isLoadingPerformance ?? this.isLoadingPerformance,
      emergencyStopExecuted:
          emergencyStopExecuted ?? this.emergencyStopExecuted,
      error: error,
      configError: configError,
      performanceError: performanceError,
      lastStatusUpdate: lastStatusUpdate ?? this.lastStatusUpdate,
      lastConfigUpdate: lastConfigUpdate ?? this.lastConfigUpdate,
      lastPerformanceUpdate:
          lastPerformanceUpdate ?? this.lastPerformanceUpdate,
      lastHealthCheck: lastHealthCheck ?? this.lastHealthCheck,
    );
  }

  bool get isRunning => status?.status == 'running';
  bool get isPaused => status?.status == 'paused';
  bool get isStopped => status?.status == 'stopped';
  bool get isAutonomous => autonomousStatus?.enabled ?? false;
  bool get isHealthy => healthCheck?.healthy ?? true;
  bool get hasErrors =>
      error != null || configError != null || performanceError != null;
}

/// Riverpod providers
@riverpod
class BotControl extends _$BotControl {
  @override
  BotState build() {
    return const BotState.initial();
  }

  Future<void> startBot() async {
    // Implementation would use the actual service
  }

  Future<void> stopBot() async {
    // Implementation would use the actual service
  }

  Future<void> pauseBot() async {
    // Implementation would use the actual service
  }

  Future<void> emergencyStop() async {
    // Implementation would use the actual service
  }
}
