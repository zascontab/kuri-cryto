/// Backtesting Models
///
/// Models for strategy backtesting and results

/// Backtest configuration
class BacktestConfig {
  final String symbol;
  final String strategy;
  final DateTime startDate;
  final DateTime endDate;
  final double initialCapital;
  final Map<String, dynamic>? strategyParams;

  BacktestConfig({
    required this.symbol,
    required this.strategy,
    required this.startDate,
    required this.endDate,
    this.initialCapital = 10000.0,
    this.strategyParams,
  });

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'strategy': strategy,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'initial_capital': initialCapital,
      if (strategyParams != null) 'strategy_params': strategyParams,
    };
  }

  factory BacktestConfig.fromJson(Map<String, dynamic> json) {
    return BacktestConfig(
      symbol: json['symbol'] ?? '',
      strategy: json['strategy'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      initialCapital: json['initial_capital']?.toDouble() ?? 10000.0,
      strategyParams: json['strategy_params'],
    );
  }
}

/// Individual trade in backtest
class BacktestTrade {
  final DateTime entryTime;
  final DateTime exitTime;
  final double entryPrice;
  final double exitPrice;
  final String side; // 'long' or 'short'
  final double quantity;
  final double pnl;
  final double pnlPercent;
  final String? exitReason;

  BacktestTrade({
    required this.entryTime,
    required this.exitTime,
    required this.entryPrice,
    required this.exitPrice,
    required this.side,
    required this.quantity,
    required this.pnl,
    required this.pnlPercent,
    this.exitReason,
  });

  factory BacktestTrade.fromJson(Map<String, dynamic> json) {
    return BacktestTrade(
      entryTime: DateTime.parse(json['entry_time']),
      exitTime: DateTime.parse(json['exit_time']),
      entryPrice: json['entry_price']?.toDouble() ?? 0.0,
      exitPrice: json['exit_price']?.toDouble() ?? 0.0,
      side: json['side'] ?? 'long',
      quantity: json['quantity']?.toDouble() ?? 0.0,
      pnl: json['pnl']?.toDouble() ?? 0.0,
      pnlPercent: json['pnl_percent']?.toDouble() ?? 0.0,
      exitReason: json['exit_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entry_time': entryTime.toIso8601String(),
      'exit_time': exitTime.toIso8601String(),
      'entry_price': entryPrice,
      'exit_price': exitPrice,
      'side': side,
      'quantity': quantity,
      'pnl': pnl,
      'pnl_percent': pnlPercent,
      'exit_reason': exitReason,
    };
  }

  bool get isWinning => pnl > 0;
}

/// Equity curve point
class EquityPoint {
  final DateTime timestamp;
  final double equity;

  EquityPoint({
    required this.timestamp,
    required this.equity,
  });

  factory EquityPoint.fromJson(Map<String, dynamic> json) {
    return EquityPoint(
      timestamp: DateTime.parse(json['timestamp']),
      equity: json['equity']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'equity': equity,
    };
  }
}

/// Backtest performance metrics
class BacktestMetrics {
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final double winRate;
  final double totalPnl;
  final double totalPnlPercent;
  final double avgWin;
  final double avgLoss;
  final double largestWin;
  final double largestLoss;
  final double profitFactor;
  final double sharpeRatio;
  final double maxDrawdown;
  final double maxDrawdownPercent;
  final double recoveryFactor;
  final int maxConsecutiveWins;
  final int maxConsecutiveLosses;

  BacktestMetrics({
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.winRate,
    required this.totalPnl,
    required this.totalPnlPercent,
    required this.avgWin,
    required this.avgLoss,
    required this.largestWin,
    required this.largestLoss,
    required this.profitFactor,
    required this.sharpeRatio,
    required this.maxDrawdown,
    required this.maxDrawdownPercent,
    required this.recoveryFactor,
    required this.maxConsecutiveWins,
    required this.maxConsecutiveLosses,
  });

  factory BacktestMetrics.fromJson(Map<String, dynamic> json) {
    return BacktestMetrics(
      totalTrades: json['total_trades'] ?? 0,
      winningTrades: json['winning_trades'] ?? 0,
      losingTrades: json['losing_trades'] ?? 0,
      winRate: json['win_rate']?.toDouble() ?? 0.0,
      totalPnl: json['total_pnl']?.toDouble() ?? 0.0,
      totalPnlPercent: json['total_pnl_percent']?.toDouble() ?? 0.0,
      avgWin: json['avg_win']?.toDouble() ?? 0.0,
      avgLoss: json['avg_loss']?.toDouble() ?? 0.0,
      largestWin: json['largest_win']?.toDouble() ?? 0.0,
      largestLoss: json['largest_loss']?.toDouble() ?? 0.0,
      profitFactor: json['profit_factor']?.toDouble() ?? 0.0,
      sharpeRatio: json['sharpe_ratio']?.toDouble() ?? 0.0,
      maxDrawdown: json['max_drawdown']?.toDouble() ?? 0.0,
      maxDrawdownPercent: json['max_drawdown_percent']?.toDouble() ?? 0.0,
      recoveryFactor: json['recovery_factor']?.toDouble() ?? 0.0,
      maxConsecutiveWins: json['max_consecutive_wins'] ?? 0,
      maxConsecutiveLosses: json['max_consecutive_losses'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_trades': totalTrades,
      'winning_trades': winningTrades,
      'losing_trades': losingTrades,
      'win_rate': winRate,
      'total_pnl': totalPnl,
      'total_pnl_percent': totalPnlPercent,
      'avg_win': avgWin,
      'avg_loss': avgLoss,
      'largest_win': largestWin,
      'largest_loss': largestLoss,
      'profit_factor': profitFactor,
      'sharpe_ratio': sharpeRatio,
      'max_drawdown': maxDrawdown,
      'max_drawdown_percent': maxDrawdownPercent,
      'recovery_factor': recoveryFactor,
      'max_consecutive_wins': maxConsecutiveWins,
      'max_consecutive_losses': maxConsecutiveLosses,
    };
  }
}

/// Complete backtest result
class BacktestResult {
  final String id;
  final BacktestConfig config;
  final BacktestMetrics metrics;
  final List<BacktestTrade> trades;
  final List<EquityPoint> equityCurve;
  final DateTime completedAt;
  final String status; // 'completed', 'running', 'failed'
  final String? errorMessage;

  BacktestResult({
    required this.id,
    required this.config,
    required this.metrics,
    required this.trades,
    required this.equityCurve,
    required this.completedAt,
    this.status = 'completed',
    this.errorMessage,
  });

  factory BacktestResult.fromJson(Map<String, dynamic> json) {
    final tradesData = json['trades'] as List<dynamic>? ?? [];
    final equityData = json['equity_curve'] as List<dynamic>? ?? [];

    return BacktestResult(
      id: json['id'] ?? '',
      config: BacktestConfig.fromJson(json['config'] ?? {}),
      metrics: BacktestMetrics.fromJson(json['metrics'] ?? {}),
      trades: tradesData
          .map((t) => BacktestTrade.fromJson(t as Map<String, dynamic>))
          .toList(),
      equityCurve: equityData
          .map((e) => EquityPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : DateTime.now(),
      status: json['status'] ?? 'completed',
      errorMessage: json['error_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'config': config.toJson(),
      'metrics': metrics.toJson(),
      'trades': trades.map((t) => t.toJson()).toList(),
      'equity_curve': equityCurve.map((e) => e.toJson()).toList(),
      'completed_at': completedAt.toIso8601String(),
      'status': status,
      'error_message': errorMessage,
    };
  }

  bool get isCompleted => status == 'completed';
  bool get isRunning => status == 'running';
  bool get isFailed => status == 'failed';
}
