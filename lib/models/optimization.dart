/// Optimization Models
///
/// Models for parameter optimization system

/// Parameter range configuration
class ParameterRange {
  final String name;
  final double min;
  final double max;
  final double step;

  ParameterRange({
    required this.name,
    required this.min,
    required this.max,
    required this.step,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'min': min,
      'max': max,
      'step': step,
    };
  }

  factory ParameterRange.fromJson(Map<String, dynamic> json) {
    return ParameterRange(
      name: json['name'] ?? '',
      min: json['min']?.toDouble() ?? 0.0,
      max: json['max']?.toDouble() ?? 0.0,
      step: json['step']?.toDouble() ?? 0.0,
    );
  }

  /// Validate parameter range
  bool validate() {
    return min < max && step > 0 && step <= (max - min);
  }

  /// Get error message if validation fails
  String? getValidationError() {
    if (min >= max) return 'Minimum must be less than maximum';
    if (step <= 0) return 'Step must be greater than 0';
    if (step > (max - min)) return 'Step too large for range';
    return null;
  }
}

/// Optimization configuration
class OptimizationConfig {
  final String strategyName;
  final String symbol;
  final DateTime startDate;
  final DateTime endDate;
  final List<ParameterRange> parameterRanges;
  final String optimizationMethod; // 'grid_search', 'random', 'bayesian'
  final String objective; // 'sharpe_ratio', 'total_pnl', 'win_rate'
  final int? maxIterations; // For random/bayesian methods
  final double? initialCapital;

  OptimizationConfig({
    required this.strategyName,
    required this.symbol,
    required this.startDate,
    required this.endDate,
    required this.parameterRanges,
    this.optimizationMethod = 'grid_search',
    this.objective = 'sharpe_ratio',
    this.maxIterations,
    this.initialCapital = 10000.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'strategy_name': strategyName,
      'symbol': symbol,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'parameter_ranges': parameterRanges.map((p) => p.toJson()).toList(),
      'optimization_method': optimizationMethod,
      'objective': objective,
      if (maxIterations != null) 'max_iterations': maxIterations,
      if (initialCapital != null) 'initial_capital': initialCapital,
    };
  }

  factory OptimizationConfig.fromJson(Map<String, dynamic> json) {
    final rangesData = json['parameter_ranges'] as List<dynamic>? ?? [];

    return OptimizationConfig(
      strategyName: json['strategy_name'] ?? '',
      symbol: json['symbol'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      parameterRanges: rangesData
          .map((r) => ParameterRange.fromJson(r as Map<String, dynamic>))
          .toList(),
      optimizationMethod: json['optimization_method'] ?? 'grid_search',
      objective: json['objective'] ?? 'sharpe_ratio',
      maxIterations: json['max_iterations'],
      initialCapital: json['initial_capital']?.toDouble() ?? 10000.0,
    );
  }

  /// Validate entire configuration
  bool validate() {
    if (strategyName.isEmpty) return false;
    if (symbol.isEmpty) return false;
    if (startDate.isAfter(endDate)) return false;
    if (parameterRanges.isEmpty) return false;
    if (!parameterRanges.every((p) => p.validate())) return false;
    return true;
  }
}

/// Set of parameter values
class ParameterSet {
  final Map<String, double> parameters;
  final double score;
  final double winRate;
  final double totalPnl;
  final double sharpeRatio;
  final double maxDrawdown;
  final int totalTrades;

  ParameterSet({
    required this.parameters,
    required this.score,
    required this.winRate,
    required this.totalPnl,
    required this.sharpeRatio,
    required this.maxDrawdown,
    required this.totalTrades,
  });

  factory ParameterSet.fromJson(Map<String, dynamic> json) {
    final parametersData = json['parameters'] as Map<String, dynamic>? ?? {};
    final parameters = parametersData
        .map((key, value) => MapEntry(key, (value as num).toDouble()));

    return ParameterSet(
      parameters: parameters,
      score: json['score']?.toDouble() ?? 0.0,
      winRate: json['win_rate']?.toDouble() ?? 0.0,
      totalPnl: json['total_pnl']?.toDouble() ?? 0.0,
      sharpeRatio: json['sharpe_ratio']?.toDouble() ?? 0.0,
      maxDrawdown: json['max_drawdown']?.toDouble() ?? 0.0,
      totalTrades: json['total_trades'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parameters': parameters,
      'score': score,
      'win_rate': winRate,
      'total_pnl': totalPnl,
      'sharpe_ratio': sharpeRatio,
      'max_drawdown': maxDrawdown,
      'total_trades': totalTrades,
    };
  }

  /// Get formatted parameter string
  String getFormattedParameters() {
    return parameters.entries
        .map((e) => '${e.key}: ${e.value.toStringAsFixed(2)}')
        .join(', ');
  }
}

/// Optimization result
class OptimizationResult {
  final String id;
  final OptimizationConfig config;
  final List<ParameterSet> results;
  final ParameterSet? bestParameters;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String status; // 'running', 'completed', 'failed', 'cancelled'
  final String? errorMessage;
  final int? progress; // 0-100 percentage
  final int? estimatedTimeRemaining; // seconds
  final int totalCombinations;
  final int completedCombinations;

  OptimizationResult({
    required this.id,
    required this.config,
    required this.results,
    this.bestParameters,
    required this.startedAt,
    this.completedAt,
    this.status = 'running',
    this.errorMessage,
    this.progress,
    this.estimatedTimeRemaining,
    required this.totalCombinations,
    required this.completedCombinations,
  });

  factory OptimizationResult.fromJson(Map<String, dynamic> json) {
    final resultsData = json['results'] as List<dynamic>? ?? [];

    return OptimizationResult(
      id: json['id'] ?? '',
      config: OptimizationConfig.fromJson(json['config'] ?? {}),
      results: resultsData
          .map((r) => ParameterSet.fromJson(r as Map<String, dynamic>))
          .toList(),
      bestParameters: json['best_parameters'] != null
          ? ParameterSet.fromJson(json['best_parameters'])
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      status: json['status'] ?? 'running',
      errorMessage: json['error_message'],
      progress: json['progress'],
      estimatedTimeRemaining: json['estimated_time_remaining'],
      totalCombinations: json['total_combinations'] ?? 0,
      completedCombinations: json['completed_combinations'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'config': config.toJson(),
      'results': results.map((r) => r.toJson()).toList(),
      if (bestParameters != null) 'best_parameters': bestParameters!.toJson(),
      'started_at': startedAt.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
      'status': status,
      'error_message': errorMessage,
      'progress': progress,
      'estimated_time_remaining': estimatedTimeRemaining,
      'total_combinations': totalCombinations,
      'completed_combinations': completedCombinations,
    };
  }

  bool get isRunning => status == 'running';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isCancelled => status == 'cancelled';

  /// Get duration of optimization
  Duration? getDuration() {
    if (completedAt != null) {
      return completedAt!.difference(startedAt);
    } else if (isRunning) {
      return DateTime.now().difference(startedAt);
    }
    return null;
  }

  /// Get formatted duration string
  String getFormattedDuration() {
    final duration = getDuration();
    if (duration == null) return '-';

    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Get formatted estimated time remaining
  String getFormattedTimeRemaining() {
    if (estimatedTimeRemaining == null) return '-';

    final duration = Duration(seconds: estimatedTimeRemaining!);
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}

/// Summary of past optimization
class OptimizationSummary {
  final String id;
  final String strategyName;
  final String symbol;
  final String optimizationMethod;
  final String objective;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String status;
  final double? bestScore;
  final int totalCombinations;

  OptimizationSummary({
    required this.id,
    required this.strategyName,
    required this.symbol,
    required this.optimizationMethod,
    required this.objective,
    required this.startedAt,
    this.completedAt,
    required this.status,
    this.bestScore,
    required this.totalCombinations,
  });

  factory OptimizationSummary.fromJson(Map<String, dynamic> json) {
    return OptimizationSummary(
      id: json['id'] ?? '',
      strategyName: json['strategy_name'] ?? '',
      symbol: json['symbol'] ?? '',
      optimizationMethod: json['optimization_method'] ?? 'grid_search',
      objective: json['objective'] ?? 'sharpe_ratio',
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      status: json['status'] ?? 'running',
      bestScore: json['best_score']?.toDouble(),
      totalCombinations: json['total_combinations'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'strategy_name': strategyName,
      'symbol': symbol,
      'optimization_method': optimizationMethod,
      'objective': objective,
      'started_at': startedAt.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
      'status': status,
      'best_score': bestScore,
      'total_combinations': totalCombinations,
    };
  }

  bool get isRunning => status == 'running';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isCancelled => status == 'cancelled';
}
