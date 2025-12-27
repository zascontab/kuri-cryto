/// Backtest trade model for MCP integration
class BacktestTrade {
  final String id;
  final String symbol;
  final String side;
  final double entryPrice;
  final double exitPrice;
  final double size;
  final DateTime entryTime;
  final DateTime? exitTime;
  final double pnl;
  final double pnlPercent;

  const BacktestTrade({
    required this.id,
    required this.symbol,
    required this.side,
    required this.entryPrice,
    required this.exitPrice,
    required this.size,
    required this.entryTime,
    this.exitTime,
    required this.pnl,
    required this.pnlPercent,
  });

  factory BacktestTrade.fromJson(Map<String, dynamic> json) {
    return BacktestTrade(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      side: json['side'] ?? 'buy',
      entryPrice: json['entryPrice']?.toDouble() ?? 0.0,
      exitPrice: json['exitPrice']?.toDouble() ?? 0.0,
      size: json['size']?.toDouble() ?? 0.0,
      entryTime: DateTime.parse(json['entryTime']),
      exitTime:
          json['exitTime'] != null ? DateTime.parse(json['exitTime']) : null,
      pnl: json['pnl']?.toDouble() ?? 0.0,
      pnlPercent: json['pnlPercent']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'side': side,
      'entryPrice': entryPrice,
      'exitPrice': exitPrice,
      'size': size,
      'entryTime': entryTime.toIso8601String(),
      'exitTime': exitTime?.toIso8601String(),
      'pnl': pnl,
      'pnlPercent': pnlPercent,
    };
  }

  /// Check if trade is profitable
  bool get isProfitable => pnl > 0;

  /// Check if trade is a loss
  bool get isLoss => pnl < 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BacktestTrade &&
        other.id == id &&
        other.symbol == symbol &&
        other.side == side &&
        other.entryPrice == entryPrice &&
        other.exitPrice == exitPrice &&
        other.size == size &&
        other.entryTime == entryTime &&
        other.exitTime == exitTime &&
        other.pnl == pnl &&
        other.pnlPercent == pnlPercent;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      symbol,
      side,
      entryPrice,
      exitPrice,
      size,
      entryTime,
      exitTime,
      pnl,
      pnlPercent,
    );
  }

  @override
  String toString() {
    return 'BacktestTrade(id: $id, symbol: $symbol, pnl: $pnl)';
  }
}

/// Backtest result model for MCP integration
class BacktestResult {
  final double roi;
  final double sharpeRatio;
  final double maxDrawdown;
  final int totalTrades;
  final double winRate;
  final double profitFactor;
  final List<BacktestTrade> trades;

  const BacktestResult({
    required this.roi,
    required this.sharpeRatio,
    required this.maxDrawdown,
    required this.totalTrades,
    required this.winRate,
    required this.profitFactor,
    required this.trades,
  });

  factory BacktestResult.fromJson(Map<String, dynamic> json) {
    return BacktestResult(
      roi: json['roi']?.toDouble() ?? 0.0,
      sharpeRatio: json['sharpeRatio']?.toDouble() ?? 0.0,
      maxDrawdown: json['maxDrawdown']?.toDouble() ?? 0.0,
      totalTrades: json['totalTrades'] ?? 0,
      winRate: json['winRate']?.toDouble() ?? 0.0,
      profitFactor: json['profitFactor']?.toDouble() ?? 0.0,
      trades: (json['trades'] as List?)
              ?.map((trade) => BacktestTrade.fromJson(trade))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roi': roi,
      'sharpeRatio': sharpeRatio,
      'maxDrawdown': maxDrawdown,
      'totalTrades': totalTrades,
      'winRate': winRate,
      'profitFactor': profitFactor,
      'trades': trades.map((trade) => trade.toJson()).toList(),
    };
  }

  BacktestResult copyWith({
    double? roi,
    double? sharpeRatio,
    double? maxDrawdown,
    int? totalTrades,
    double? winRate,
    double? profitFactor,
    List<BacktestTrade>? trades,
  }) {
    return BacktestResult(
      roi: roi ?? this.roi,
      sharpeRatio: sharpeRatio ?? this.sharpeRatio,
      maxDrawdown: maxDrawdown ?? this.maxDrawdown,
      totalTrades: totalTrades ?? this.totalTrades,
      winRate: winRate ?? this.winRate,
      profitFactor: profitFactor ?? this.profitFactor,
      trades: trades ?? this.trades,
    );
  }

  /// Check if backtest results are profitable
  bool get isProfitable => roi > 0;

  /// Check if backtest has good performance (ROI > 10% and Sharpe > 1)
  bool get hasGoodPerformance => roi > 10 && sharpeRatio > 1.0;

  /// Check if backtest has acceptable risk (max drawdown < 20%)
  bool get hasAcceptableRisk => maxDrawdown < 20;

  /// Check if backtest has sufficient trades for statistical significance
  bool get hasSufficientTrades => totalTrades >= 30;

  /// Get number of winning trades
  int get winningTrades => (totalTrades * winRate / 100).round();

  /// Get number of losing trades
  int get losingTrades => totalTrades - winningTrades;

  /// Check if strategy is viable (good performance + acceptable risk + sufficient trades)
  bool get isViableStrategy {
    return hasGoodPerformance && hasAcceptableRisk && hasSufficientTrades;
  }

  /// Get performance grade (A-F)
  String get performanceGrade {
    if (roi >= 50 && sharpeRatio >= 2.0 && maxDrawdown <= 10) return 'A';
    if (roi >= 30 && sharpeRatio >= 1.5 && maxDrawdown <= 15) return 'B';
    if (roi >= 15 && sharpeRatio >= 1.0 && maxDrawdown <= 20) return 'C';
    if (roi >= 5 && sharpeRatio >= 0.5 && maxDrawdown <= 30) return 'D';
    return 'F';
  }

  /// Get average trade duration in hours
  double get averageTradeDurationHours {
    if (trades.isEmpty) return 0;

    final durations = trades
        .where((trade) => trade.exitTime != null)
        .map((trade) => trade.exitTime!.difference(trade.entryTime).inHours)
        .toList();

    if (durations.isEmpty) return 0;
    return durations.reduce((a, b) => a + b) / durations.length;
  }

  /// Get largest winning trade
  BacktestTrade? get largestWin {
    if (trades.isEmpty) return null;
    return trades.where((trade) => trade.pnl > 0).fold<BacktestTrade?>(null,
        (prev, trade) => prev == null || trade.pnl > prev.pnl ? trade : prev);
  }

  /// Get largest losing trade
  BacktestTrade? get largestLoss {
    if (trades.isEmpty) return null;
    return trades.where((trade) => trade.pnl < 0).fold<BacktestTrade?>(null,
        (prev, trade) => prev == null || trade.pnl < prev.pnl ? trade : prev);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BacktestResult &&
        other.roi == roi &&
        other.sharpeRatio == sharpeRatio &&
        other.maxDrawdown == maxDrawdown &&
        other.totalTrades == totalTrades &&
        other.winRate == winRate &&
        other.profitFactor == profitFactor &&
        other.trades.length == trades.length &&
        other.trades.every((element) => trades.contains(element));
  }

  @override
  int get hashCode {
    return Object.hash(
      roi,
      sharpeRatio,
      maxDrawdown,
      totalTrades,
      winRate,
      profitFactor,
      Object.hashAll(trades),
    );
  }

  @override
  String toString() {
    return 'BacktestResult(roi: $roi%, sharpe: $sharpeRatio, trades: $totalTrades, grade: $performanceGrade)';
  }
}

/// Optimization result model for MCP integration
class OptimizationResult {
  final String optimizationId;
  final String status;
  final Map<String, dynamic> bestParameters;
  final Map<String, dynamic> performanceMetrics;
  final List<OptimizationStep> steps;

  const OptimizationResult({
    required this.optimizationId,
    required this.status,
    required this.bestParameters,
    required this.performanceMetrics,
    required this.steps,
  });

  factory OptimizationResult.fromJson(Map<String, dynamic> json) {
    return OptimizationResult(
      optimizationId: json['optimizationId'] ?? '',
      status: json['status'] ?? 'pending',
      bestParameters: Map<String, dynamic>.from(json['bestParameters'] ?? {}),
      performanceMetrics:
          Map<String, dynamic>.from(json['performanceMetrics'] ?? {}),
      steps: (json['steps'] as List?)
              ?.map((step) => OptimizationStep.fromJson(step))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'optimizationId': optimizationId,
      'status': status,
      'bestParameters': bestParameters,
      'performanceMetrics': performanceMetrics,
      'steps': steps.map((step) => step.toJson()).toList(),
    };
  }

  OptimizationResult copyWith({
    String? optimizationId,
    String? status,
    Map<String, dynamic>? bestParameters,
    Map<String, dynamic>? performanceMetrics,
    List<OptimizationStep>? steps,
  }) {
    return OptimizationResult(
      optimizationId: optimizationId ?? this.optimizationId,
      status: status ?? this.status,
      bestParameters: bestParameters ?? this.bestParameters,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      steps: steps ?? this.steps,
    );
  }

  /// Check if optimization is completed
  bool get isCompleted => status.toLowerCase() == 'completed';

  /// Check if optimization is running
  bool get isRunning => status.toLowerCase() == 'running';

  /// Check if optimization failed
  bool get hasFailed => status.toLowerCase() == 'failed';

  /// Get best ROI from performance metrics
  double get bestROI {
    return performanceMetrics['roi']?.toDouble() ?? 0.0;
  }

  /// Get best Sharpe ratio from performance metrics
  double get bestSharpeRatio {
    return performanceMetrics['sharpeRatio']?.toDouble() ?? 0.0;
  }

  /// Get optimization progress (0-100)
  double get progress {
    if (steps.isEmpty) return 0;
    final completedSteps = steps.where((step) => step.isCompleted).length;
    return (completedSteps / steps.length * 100).clamp(0, 100);
  }

  /// Get parameter value by name
  dynamic getParameter(String name) {
    return bestParameters[name];
  }

  /// Get metric value by name
  double getMetric(String name) {
    return performanceMetrics[name]?.toDouble() ?? 0.0;
  }

  /// Check if optimization found viable parameters
  bool get foundViableParameters {
    return isCompleted && bestROI > 0 && bestSharpeRatio > 0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OptimizationResult &&
        other.optimizationId == optimizationId &&
        other.status == status &&
        other.bestParameters.length == bestParameters.length &&
        other.performanceMetrics.length == performanceMetrics.length &&
        other.steps.length == steps.length &&
        other.steps.every((element) => steps.contains(element));
  }

  @override
  int get hashCode {
    return Object.hash(
      optimizationId,
      status,
      Object.hashAll(bestParameters.entries),
      Object.hashAll(performanceMetrics.entries),
      Object.hashAll(steps),
    );
  }

  @override
  String toString() {
    return 'OptimizationResult(id: $optimizationId, status: $status, progress: ${progress.toStringAsFixed(1)}%)';
  }
}

/// Optimization step model
class OptimizationStep {
  final int stepNumber;
  final Map<String, dynamic> parameters;
  final Map<String, dynamic> results;
  final String status;
  final DateTime? startTime;
  final DateTime? endTime;

  const OptimizationStep({
    required this.stepNumber,
    required this.parameters,
    required this.results,
    required this.status,
    this.startTime,
    this.endTime,
  });

  factory OptimizationStep.fromJson(Map<String, dynamic> json) {
    return OptimizationStep(
      stepNumber: json['stepNumber'] ?? 0,
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      results: Map<String, dynamic>.from(json['results'] ?? {}),
      status: json['status'] ?? 'pending',
      startTime:
          json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'parameters': parameters,
      'results': results,
      'status': status,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  /// Check if step is completed
  bool get isCompleted => status.toLowerCase() == 'completed';

  /// Get step duration in seconds
  int get durationSeconds {
    if (startTime == null || endTime == null) return 0;
    return endTime!.difference(startTime!).inSeconds;
  }

  /// Get ROI for this step
  double get roi {
    return results['roi']?.toDouble() ?? 0.0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OptimizationStep &&
        other.stepNumber == stepNumber &&
        other.parameters.length == parameters.length &&
        other.results.length == results.length &&
        other.status == status &&
        other.startTime == startTime &&
        other.endTime == endTime;
  }

  @override
  int get hashCode {
    return Object.hash(
      stepNumber,
      Object.hashAll(parameters.entries),
      Object.hashAll(results.entries),
      status,
      startTime,
      endTime,
    );
  }

  @override
  String toString() {
    return 'OptimizationStep(step: $stepNumber, status: $status, roi: ${roi.toStringAsFixed(2)}%)';
  }
}

/// Strategy comparison model for MCP integration
class StrategyComparison {
  final String comparisonId;
  final List<String> strategies;
  final List<Map<String, dynamic>> results;
  final Map<String, dynamic> summary;
  final ComparisonMetrics metrics;

  const StrategyComparison({
    required this.comparisonId,
    required this.strategies,
    required this.results,
    required this.summary,
    required this.metrics,
  });

  factory StrategyComparison.fromJson(Map<String, dynamic> json) {
    return StrategyComparison(
      comparisonId: json['comparisonId'] ?? '',
      strategies: List<String>.from(json['strategies'] ?? []),
      results: List<Map<String, dynamic>>.from((json['results'] as List?)
              ?.map((result) => Map<String, dynamic>.from(result)) ??
          []),
      summary: Map<String, dynamic>.from(json['summary'] ?? {}),
      metrics: ComparisonMetrics.fromJson(json['metrics'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comparisonId': comparisonId,
      'strategies': strategies,
      'results': results,
      'summary': summary,
      'metrics': metrics.toJson(),
    };
  }

  StrategyComparison copyWith({
    String? comparisonId,
    List<String>? strategies,
    List<Map<String, dynamic>>? results,
    Map<String, dynamic>? summary,
    ComparisonMetrics? metrics,
  }) {
    return StrategyComparison(
      comparisonId: comparisonId ?? this.comparisonId,
      strategies: strategies ?? this.strategies,
      results: results ?? this.results,
      summary: summary ?? this.summary,
      metrics: metrics ?? this.metrics,
    );
  }

  /// Get best performing strategy name
  String get bestStrategy {
    return metrics.bestStrategy;
  }

  /// Get worst performing strategy name
  String get worstStrategy {
    return metrics.worstStrategy;
  }

  /// Get result for specific strategy
  Map<String, dynamic>? getStrategyResult(String strategyName) {
    try {
      return results.firstWhere(
        (result) => result['strategy'] == strategyName,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get ROI for specific strategy
  double getStrategyROI(String strategyName) {
    final result = getStrategyResult(strategyName);
    return result?['roi']?.toDouble() ?? 0.0;
  }

  /// Get Sharpe ratio for specific strategy
  double getStrategySharpe(String strategyName) {
    final result = getStrategyResult(strategyName);
    return result?['sharpeRatio']?.toDouble() ?? 0.0;
  }

  /// Get strategies ranked by performance (best first)
  List<String> get strategiesRankedByPerformance {
    final strategiesWithROI = strategies
        .map((strategy) => {
              'name': strategy,
              'roi': getStrategyROI(strategy),
            })
        .toList();

    strategiesWithROI
        .sort((a, b) => (b['roi'] as double).compareTo(a['roi'] as double));

    return strategiesWithROI.map((item) => item['name'] as String).toList();
  }

  /// Check if comparison has significant differences between strategies
  bool get hasSignificantDifferences {
    if (strategies.length < 2) return false;

    final rois =
        strategies.map((strategy) => getStrategyROI(strategy)).toList();
    final maxROI = rois.reduce((a, b) => a > b ? a : b);
    final minROI = rois.reduce((a, b) => a < b ? a : b);

    return (maxROI - minROI) > 5; // 5% difference threshold
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StrategyComparison &&
        other.comparisonId == comparisonId &&
        other.strategies.length == strategies.length &&
        other.strategies.every((element) => strategies.contains(element)) &&
        other.results.length == results.length &&
        other.summary.length == summary.length &&
        other.metrics == metrics;
  }

  @override
  int get hashCode {
    return Object.hash(
      comparisonId,
      Object.hashAll(strategies),
      Object.hashAll(results),
      Object.hashAll(summary.entries),
      metrics,
    );
  }

  @override
  String toString() {
    return 'StrategyComparison(id: $comparisonId, strategies: ${strategies.length}, best: $bestStrategy)';
  }
}

/// Comparison metrics model
class ComparisonMetrics {
  final String bestStrategy;
  final String worstStrategy;
  final double averageROI;
  final double roiStandardDeviation;
  final Map<String, double> correlations;

  const ComparisonMetrics({
    required this.bestStrategy,
    required this.worstStrategy,
    required this.averageROI,
    required this.roiStandardDeviation,
    required this.correlations,
  });

  factory ComparisonMetrics.fromJson(Map<String, dynamic> json) {
    return ComparisonMetrics(
      bestStrategy: json['bestStrategy'] ?? '',
      worstStrategy: json['worstStrategy'] ?? '',
      averageROI: json['averageROI']?.toDouble() ?? 0.0,
      roiStandardDeviation: json['roiStandardDeviation']?.toDouble() ?? 0.0,
      correlations: Map<String, double>.from((json['correlations'] ?? {})
          .map((k, v) => MapEntry(k, v?.toDouble() ?? 0.0))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bestStrategy': bestStrategy,
      'worstStrategy': worstStrategy,
      'averageROI': averageROI,
      'roiStandardDeviation': roiStandardDeviation,
      'correlations': correlations,
    };
  }

  /// Get correlation between two strategies
  double getCorrelation(String strategy1, String strategy2) {
    final key = '${strategy1}_$strategy2';
    return correlations[key] ?? correlations['${strategy2}_$strategy1'] ?? 0.0;
  }

  /// Check if strategies are highly correlated (>0.8)
  bool areHighlyCorrelated(String strategy1, String strategy2) {
    return getCorrelation(strategy1, strategy2).abs() > 0.8;
  }

  /// Get coefficient of variation (risk-adjusted performance measure)
  double get coefficientOfVariation {
    return averageROI != 0 ? roiStandardDeviation / averageROI : 0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComparisonMetrics &&
        other.bestStrategy == bestStrategy &&
        other.worstStrategy == worstStrategy &&
        other.averageROI == averageROI &&
        other.roiStandardDeviation == roiStandardDeviation &&
        other.correlations.length == correlations.length &&
        other.correlations.entries
            .every((entry) => correlations[entry.key] == entry.value);
  }

  @override
  int get hashCode {
    return Object.hash(
      bestStrategy,
      worstStrategy,
      averageROI,
      roiStandardDeviation,
      Object.hashAll(correlations.entries),
    );
  }

  @override
  String toString() {
    return 'ComparisonMetrics(best: $bestStrategy, worst: $worstStrategy, avgROI: ${averageROI.toStringAsFixed(2)}%)';
  }
}
