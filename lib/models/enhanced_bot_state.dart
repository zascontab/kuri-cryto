/// Enhanced bot state model for autonomous trading
class EnhancedBotState {
  final EnhancedBotStatus status;
  final EnhancedBotConfig config;
  final BotPerformance? performance;
  final AutonomousStatus? autonomousStatus;
  final List<BotAction> recentActions;

  const EnhancedBotState({
    required this.status,
    required this.config,
    this.performance,
    this.autonomousStatus,
    required this.recentActions,
  });

  factory EnhancedBotState.fromJson(Map<String, dynamic> json) {
    return EnhancedBotState(
      status: EnhancedBotStatus.fromJson(json['status'] ?? {}),
      config: EnhancedBotConfig.fromJson(json['config'] ?? {}),
      performance: json['performance'] != null
          ? BotPerformance.fromJson(json['performance'])
          : null,
      autonomousStatus: json['autonomousStatus'] != null
          ? AutonomousStatus.fromJson(json['autonomousStatus'])
          : null,
      recentActions: (json['recentActions'] as List?)
              ?.map((action) => BotAction.fromJson(action))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.toJson(),
      'config': config.toJson(),
      'performance': performance?.toJson(),
      'autonomousStatus': autonomousStatus?.toJson(),
      'recentActions': recentActions.map((action) => action.toJson()).toList(),
    };
  }

  EnhancedBotState copyWith({
    EnhancedBotStatus? status,
    EnhancedBotConfig? config,
    BotPerformance? performance,
    AutonomousStatus? autonomousStatus,
    List<BotAction>? recentActions,
  }) {
    return EnhancedBotState(
      status: status ?? this.status,
      config: config ?? this.config,
      performance: performance ?? this.performance,
      autonomousStatus: autonomousStatus ?? this.autonomousStatus,
      recentActions: recentActions ?? this.recentActions,
    );
  }

  /// Check if bot is currently running
  bool get isRunning => status.isRunning;

  /// Check if bot is in autonomous mode
  bool get isAutonomous => status.autonomousMode;

  /// Check if bot has recent activity (last 5 minutes)
  bool get hasRecentActivity {
    if (recentActions.isEmpty) return false;
    final lastAction = recentActions.first;
    return DateTime.now().difference(lastAction.timestamp).inMinutes < 5;
  }

  /// Get overall bot health score (0-100)
  double get healthScore {
    double score = 50; // Base score

    if (isRunning) score += 20;
    if (performance != null && performance!.isPerformingWell) score += 20;
    if (hasRecentActivity) score += 10;

    return score.clamp(0, 100);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EnhancedBotState &&
        other.status == status &&
        other.config == config &&
        other.performance == performance &&
        other.autonomousStatus == autonomousStatus &&
        other.recentActions.length == recentActions.length &&
        other.recentActions.every((element) => recentActions.contains(element));
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      config,
      performance,
      autonomousStatus,
      Object.hashAll(recentActions),
    );
  }

  @override
  String toString() {
    return 'EnhancedBotState(running: $isRunning, autonomous: $isAutonomous, actions: ${recentActions.length})';
  }
}

/// Enhanced bot status model
class EnhancedBotStatus {
  final String state;
  final bool autonomousMode;
  final PositionSummary positions;
  final PerformanceSummary performance;
  final RiskSummary risk;
  final BotAction? lastAction;

  const EnhancedBotStatus({
    required this.state,
    required this.autonomousMode,
    required this.positions,
    required this.performance,
    required this.risk,
    this.lastAction,
  });

  factory EnhancedBotStatus.fromJson(Map<String, dynamic> json) {
    return EnhancedBotStatus(
      state: json['state'] ?? 'stopped',
      autonomousMode: json['autonomousMode'] ?? false,
      positions: PositionSummary.fromJson(json['positions'] ?? {}),
      performance: PerformanceSummary.fromJson(json['performance'] ?? {}),
      risk: RiskSummary.fromJson(json['risk'] ?? {}),
      lastAction: json['lastAction'] != null
          ? BotAction.fromJson(json['lastAction'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'autonomousMode': autonomousMode,
      'positions': positions.toJson(),
      'performance': performance.toJson(),
      'risk': risk.toJson(),
      'lastAction': lastAction?.toJson(),
    };
  }

  EnhancedBotStatus copyWith({
    String? state,
    bool? autonomousMode,
    PositionSummary? positions,
    PerformanceSummary? performance,
    RiskSummary? risk,
    BotAction? lastAction,
  }) {
    return EnhancedBotStatus(
      state: state ?? this.state,
      autonomousMode: autonomousMode ?? this.autonomousMode,
      positions: positions ?? this.positions,
      performance: performance ?? this.performance,
      risk: risk ?? this.risk,
      lastAction: lastAction ?? this.lastAction,
    );
  }

  /// Check if bot is running
  bool get isRunning => state.toLowerCase() == 'running';

  /// Check if bot is stopped
  bool get isStopped => state.toLowerCase() == 'stopped';

  /// Check if bot is paused
  bool get isPaused => state.toLowerCase() == 'paused';

  /// Check if bot is in error state
  bool get hasError => state.toLowerCase() == 'error';

  /// Get state display name
  String get stateDisplayName {
    switch (state.toLowerCase()) {
      case 'running':
        return 'Running';
      case 'stopped':
        return 'Stopped';
      case 'paused':
        return 'Paused';
      case 'error':
        return 'Error';
      default:
        return state;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EnhancedBotStatus &&
        other.state == state &&
        other.autonomousMode == autonomousMode &&
        other.positions == positions &&
        other.performance == performance &&
        other.risk == risk &&
        other.lastAction == lastAction;
  }

  @override
  int get hashCode {
    return Object.hash(
      state,
      autonomousMode,
      positions,
      performance,
      risk,
      lastAction,
    );
  }

  @override
  String toString() {
    return 'EnhancedBotStatus(state: $state, autonomous: $autonomousMode)';
  }
}

/// Enhanced bot configuration model
class EnhancedBotConfig {
  final bool dryRun;
  final bool autoExecute;
  final int maxPositions;
  final double positionSizeUsd;
  final double stopLossPercent;
  final double takeProfitPercent;
  final List<String> symbols;
  final List<String> timeframes;
  final List<String> strategies;
  final RiskManagementConfig riskManagement;

  const EnhancedBotConfig({
    required this.dryRun,
    required this.autoExecute,
    required this.maxPositions,
    required this.positionSizeUsd,
    required this.stopLossPercent,
    required this.takeProfitPercent,
    required this.symbols,
    required this.timeframes,
    required this.strategies,
    required this.riskManagement,
  });

  factory EnhancedBotConfig.fromJson(Map<String, dynamic> json) {
    return EnhancedBotConfig(
      dryRun: json['dryRun'] ?? true,
      autoExecute: json['autoExecute'] ?? false,
      maxPositions: json['maxPositions'] ?? 5,
      positionSizeUsd: json['positionSizeUsd']?.toDouble() ?? 100.0,
      stopLossPercent: json['stopLossPercent']?.toDouble() ?? 2.0,
      takeProfitPercent: json['takeProfitPercent']?.toDouble() ?? 4.0,
      symbols: List<String>.from(json['symbols'] ?? []),
      timeframes: List<String>.from(json['timeframes'] ?? ['1h']),
      strategies: List<String>.from(json['strategies'] ?? []),
      riskManagement:
          RiskManagementConfig.fromJson(json['riskManagement'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dryRun': dryRun,
      'autoExecute': autoExecute,
      'maxPositions': maxPositions,
      'positionSizeUsd': positionSizeUsd,
      'stopLossPercent': stopLossPercent,
      'takeProfitPercent': takeProfitPercent,
      'symbols': symbols,
      'timeframes': timeframes,
      'strategies': strategies,
      'riskManagement': riskManagement.toJson(),
    };
  }

  EnhancedBotConfig copyWith({
    bool? dryRun,
    bool? autoExecute,
    int? maxPositions,
    double? positionSizeUsd,
    double? stopLossPercent,
    double? takeProfitPercent,
    List<String>? symbols,
    List<String>? timeframes,
    List<String>? strategies,
    RiskManagementConfig? riskManagement,
  }) {
    return EnhancedBotConfig(
      dryRun: dryRun ?? this.dryRun,
      autoExecute: autoExecute ?? this.autoExecute,
      maxPositions: maxPositions ?? this.maxPositions,
      positionSizeUsd: positionSizeUsd ?? this.positionSizeUsd,
      stopLossPercent: stopLossPercent ?? this.stopLossPercent,
      takeProfitPercent: takeProfitPercent ?? this.takeProfitPercent,
      symbols: symbols ?? this.symbols,
      timeframes: timeframes ?? this.timeframes,
      strategies: strategies ?? this.strategies,
      riskManagement: riskManagement ?? this.riskManagement,
    );
  }

  /// Check if configuration is safe for live trading
  bool get isSafeForLive {
    return stopLossPercent > 0 &&
        takeProfitPercent > 0 &&
        maxPositions > 0 &&
        positionSizeUsd > 0;
  }

  /// Get risk/reward ratio
  double get riskRewardRatio {
    return stopLossPercent > 0 ? takeProfitPercent / stopLossPercent : 0;
  }

  /// Check if risk/reward ratio is favorable
  bool get hasFavorableRiskReward => riskRewardRatio >= 2.0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EnhancedBotConfig &&
        other.dryRun == dryRun &&
        other.autoExecute == autoExecute &&
        other.maxPositions == maxPositions &&
        other.positionSizeUsd == positionSizeUsd &&
        other.stopLossPercent == stopLossPercent &&
        other.takeProfitPercent == takeProfitPercent &&
        other.symbols.length == symbols.length &&
        other.symbols.every((element) => symbols.contains(element)) &&
        other.timeframes.length == timeframes.length &&
        other.timeframes.every((element) => timeframes.contains(element)) &&
        other.strategies.length == strategies.length &&
        other.strategies.every((element) => strategies.contains(element)) &&
        other.riskManagement == riskManagement;
  }

  @override
  int get hashCode {
    return Object.hash(
      dryRun,
      autoExecute,
      maxPositions,
      positionSizeUsd,
      stopLossPercent,
      takeProfitPercent,
      Object.hashAll(symbols),
      Object.hashAll(timeframes),
      Object.hashAll(strategies),
      riskManagement,
    );
  }

  @override
  String toString() {
    return 'EnhancedBotConfig(dryRun: $dryRun, maxPositions: $maxPositions, symbols: ${symbols.length})';
  }
}

/// Position summary model
class PositionSummary {
  final int total;
  final int open;
  final double totalValue;
  final double unrealizedPnl;

  const PositionSummary({
    required this.total,
    required this.open,
    required this.totalValue,
    required this.unrealizedPnl,
  });

  factory PositionSummary.fromJson(Map<String, dynamic> json) {
    return PositionSummary(
      total: json['total'] ?? 0,
      open: json['open'] ?? 0,
      totalValue: json['totalValue']?.toDouble() ?? 0.0,
      unrealizedPnl: json['unrealizedPnl']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'open': open,
      'totalValue': totalValue,
      'unrealizedPnl': unrealizedPnl,
    };
  }

  /// Check if positions are profitable
  bool get isProfitable => unrealizedPnl > 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PositionSummary &&
        other.total == total &&
        other.open == open &&
        other.totalValue == totalValue &&
        other.unrealizedPnl == unrealizedPnl;
  }

  @override
  int get hashCode {
    return Object.hash(total, open, totalValue, unrealizedPnl);
  }

  @override
  String toString() {
    return 'PositionSummary(total: $total, open: $open, pnl: $unrealizedPnl)';
  }
}

/// Performance summary model
class PerformanceSummary {
  final double totalPnl;
  final double winRate;
  final int totalTrades;
  final double sharpeRatio;

  const PerformanceSummary({
    required this.totalPnl,
    required this.winRate,
    required this.totalTrades,
    required this.sharpeRatio,
  });

  factory PerformanceSummary.fromJson(Map<String, dynamic> json) {
    return PerformanceSummary(
      totalPnl: json['totalPnl']?.toDouble() ?? 0.0,
      winRate: json['winRate']?.toDouble() ?? 0.0,
      totalTrades: json['totalTrades'] ?? 0,
      sharpeRatio: json['sharpeRatio']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPnl': totalPnl,
      'winRate': winRate,
      'totalTrades': totalTrades,
      'sharpeRatio': sharpeRatio,
    };
  }

  /// Check if performance is good
  bool get isPerformingWell => totalPnl > 0 && winRate > 0.5;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PerformanceSummary &&
        other.totalPnl == totalPnl &&
        other.winRate == winRate &&
        other.totalTrades == totalTrades &&
        other.sharpeRatio == sharpeRatio;
  }

  @override
  int get hashCode {
    return Object.hash(totalPnl, winRate, totalTrades, sharpeRatio);
  }

  @override
  String toString() {
    return 'PerformanceSummary(pnl: $totalPnl, winRate: $winRate, trades: $totalTrades)';
  }
}

/// Risk summary model
class RiskSummary {
  final double currentRisk;
  final double maxRisk;
  final String riskLevel;

  const RiskSummary({
    required this.currentRisk,
    required this.maxRisk,
    required this.riskLevel,
  });

  factory RiskSummary.fromJson(Map<String, dynamic> json) {
    return RiskSummary(
      currentRisk: json['currentRisk']?.toDouble() ?? 0.0,
      maxRisk: json['maxRisk']?.toDouble() ?? 100.0,
      riskLevel: json['riskLevel'] ?? 'low',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentRisk': currentRisk,
      'maxRisk': maxRisk,
      'riskLevel': riskLevel,
    };
  }

  /// Check if risk is high
  bool get isHighRisk => riskLevel.toLowerCase() == 'high';

  /// Get risk percentage
  double get riskPercent => maxRisk > 0 ? (currentRisk / maxRisk * 100) : 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RiskSummary &&
        other.currentRisk == currentRisk &&
        other.maxRisk == maxRisk &&
        other.riskLevel == riskLevel;
  }

  @override
  int get hashCode {
    return Object.hash(currentRisk, maxRisk, riskLevel);
  }

  @override
  String toString() {
    return 'RiskSummary(current: $currentRisk, max: $maxRisk, level: $riskLevel)';
  }
}

/// Bot action model
class BotAction {
  final String id;
  final String type;
  final String symbol;
  final DateTime timestamp;
  final Map<String, dynamic> details;

  const BotAction({
    required this.id,
    required this.type,
    required this.symbol,
    required this.timestamp,
    required this.details,
  });

  factory BotAction.fromJson(Map<String, dynamic> json) {
    return BotAction(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      symbol: json['symbol'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      details: Map<String, dynamic>.from(json['details'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'symbol': symbol,
      'timestamp': timestamp.toIso8601String(),
      'details': details,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BotAction &&
        other.id == id &&
        other.type == type &&
        other.symbol == symbol &&
        other.timestamp == timestamp &&
        other.details.length == details.length;
  }

  @override
  int get hashCode {
    return Object.hash(
        id, type, symbol, timestamp, Object.hashAll(details.entries));
  }

  @override
  String toString() {
    return 'BotAction(type: $type, symbol: $symbol, timestamp: $timestamp)';
  }
}

/// Bot performance model
class BotPerformance {
  final double totalReturn;
  final double dailyReturn;
  final double maxDrawdown;
  final int totalTrades;
  final double winRate;

  const BotPerformance({
    required this.totalReturn,
    required this.dailyReturn,
    required this.maxDrawdown,
    required this.totalTrades,
    required this.winRate,
  });

  factory BotPerformance.fromJson(Map<String, dynamic> json) {
    return BotPerformance(
      totalReturn: json['totalReturn']?.toDouble() ?? 0.0,
      dailyReturn: json['dailyReturn']?.toDouble() ?? 0.0,
      maxDrawdown: json['maxDrawdown']?.toDouble() ?? 0.0,
      totalTrades: json['totalTrades'] ?? 0,
      winRate: json['winRate']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalReturn': totalReturn,
      'dailyReturn': dailyReturn,
      'maxDrawdown': maxDrawdown,
      'totalTrades': totalTrades,
      'winRate': winRate,
    };
  }

  /// Check if performance is good
  bool get isPerformingWell => totalReturn > 0 && winRate > 0.5;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BotPerformance &&
        other.totalReturn == totalReturn &&
        other.dailyReturn == dailyReturn &&
        other.maxDrawdown == maxDrawdown &&
        other.totalTrades == totalTrades &&
        other.winRate == winRate;
  }

  @override
  int get hashCode {
    return Object.hash(
        totalReturn, dailyReturn, maxDrawdown, totalTrades, winRate);
  }

  @override
  String toString() {
    return 'BotPerformance(return: $totalReturn, winRate: $winRate, trades: $totalTrades)';
  }
}

/// Autonomous status model
class AutonomousStatus {
  final bool enabled;
  final String mode;
  final DateTime? lastDecision;
  final Map<String, dynamic> parameters;

  const AutonomousStatus({
    required this.enabled,
    required this.mode,
    this.lastDecision,
    required this.parameters,
  });

  factory AutonomousStatus.fromJson(Map<String, dynamic> json) {
    return AutonomousStatus(
      enabled: json['enabled'] ?? false,
      mode: json['mode'] ?? 'conservative',
      lastDecision: json['lastDecision'] != null
          ? DateTime.parse(json['lastDecision'])
          : null,
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'mode': mode,
      'lastDecision': lastDecision?.toIso8601String(),
      'parameters': parameters,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutonomousStatus &&
        other.enabled == enabled &&
        other.mode == mode &&
        other.lastDecision == lastDecision &&
        other.parameters.length == parameters.length;
  }

  @override
  int get hashCode {
    return Object.hash(
        enabled, mode, lastDecision, Object.hashAll(parameters.entries));
  }

  @override
  String toString() {
    return 'AutonomousStatus(enabled: $enabled, mode: $mode)';
  }
}

/// Risk management configuration model
class RiskManagementConfig {
  final double maxDailyLoss;
  final double maxPositionSize;
  final double maxDrawdown;
  final bool useStopLoss;
  final bool useTakeProfit;

  const RiskManagementConfig({
    required this.maxDailyLoss,
    required this.maxPositionSize,
    required this.maxDrawdown,
    required this.useStopLoss,
    required this.useTakeProfit,
  });

  factory RiskManagementConfig.fromJson(Map<String, dynamic> json) {
    return RiskManagementConfig(
      maxDailyLoss: json['maxDailyLoss']?.toDouble() ?? 100.0,
      maxPositionSize: json['maxPositionSize']?.toDouble() ?? 1000.0,
      maxDrawdown: json['maxDrawdown']?.toDouble() ?? 10.0,
      useStopLoss: json['useStopLoss'] ?? true,
      useTakeProfit: json['useTakeProfit'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxDailyLoss': maxDailyLoss,
      'maxPositionSize': maxPositionSize,
      'maxDrawdown': maxDrawdown,
      'useStopLoss': useStopLoss,
      'useTakeProfit': useTakeProfit,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RiskManagementConfig &&
        other.maxDailyLoss == maxDailyLoss &&
        other.maxPositionSize == maxPositionSize &&
        other.maxDrawdown == maxDrawdown &&
        other.useStopLoss == useStopLoss &&
        other.useTakeProfit == useTakeProfit;
  }

  @override
  int get hashCode {
    return Object.hash(
        maxDailyLoss, maxPositionSize, maxDrawdown, useStopLoss, useTakeProfit);
  }

  @override
  String toString() {
    return 'RiskManagementConfig(maxLoss: $maxDailyLoss, maxPosition: $maxPositionSize)';
  }
}
