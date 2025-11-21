/// Trading metrics model
///
/// Aggregated metrics for overall trading performance and system health
class Metrics {
  /// Total number of trades executed
  final int totalTrades;

  /// Number of winning trades
  final int winningTrades;

  /// Number of losing trades
  final int losingTrades;

  /// Win rate as a percentage (0-100)
  final double winRate;

  /// Total profit/loss across all trades
  final double totalPnl;

  /// Profit/loss for today
  final double dailyPnl;

  /// Profit/loss for the current week
  final double weeklyPnl;

  /// Profit/loss for the current month
  final double monthlyPnl;

  /// Average profit per winning trade
  final double avgWin;

  /// Average loss per losing trade
  final double avgLoss;

  /// Profit factor (total wins / total losses)
  final double profitFactor;

  /// Sharpe ratio (risk-adjusted return)
  final double sharpeRatio;

  /// Maximum drawdown experienced
  final double maxDrawdown;

  /// Number of currently active positions
  final int activePositions;

  /// Average order execution latency in milliseconds
  final double avgLatencyMs;

  /// Average slippage percentage
  final double avgSlippagePct;

  const Metrics({
    this.totalTrades = 0,
    this.winningTrades = 0,
    this.losingTrades = 0,
    this.winRate = 0.0,
    this.totalPnl = 0.0,
    this.dailyPnl = 0.0,
    this.weeklyPnl = 0.0,
    this.monthlyPnl = 0.0,
    this.avgWin = 0.0,
    this.avgLoss = 0.0,
    this.profitFactor = 0.0,
    this.sharpeRatio = 0.0,
    this.maxDrawdown = 0.0,
    this.activePositions = 0,
    this.avgLatencyMs = 0.0,
    this.avgSlippagePct = 0.0,
  });

  /// Check if overall performance is positive
  bool get isProfitable => totalPnl > 0;

  /// Check if today's performance is positive
  bool get isDailyProfitable => dailyPnl > 0;

  /// Check if performance is good (win rate > 50% and profitable)
  bool get isPerformingWell => winRate > 50.0 && isProfitable;

  /// Check if execution is fast (latency < 100ms)
  bool get hasFastExecution => avgLatencyMs < 100.0;

  /// Get win/loss ratio
  double get winLossRatio {
    if (avgLoss == 0) return 0.0;
    return avgWin.abs() / avgLoss.abs();
  }

  /// Create Metrics from JSON
  factory Metrics.fromJson(Map<String, dynamic> json) {
    try {
      return Metrics(
        totalTrades: _parseInt(json['total_trades']),
        winningTrades: _parseInt(json['winning_trades']),
        losingTrades: _parseInt(json['losing_trades']),
        winRate: _parseDouble(json['win_rate']),
        totalPnl: _parseDouble(json['total_pnl']),
        dailyPnl: _parseDouble(json['daily_pnl']),
        weeklyPnl: _parseDouble(json['weekly_pnl']),
        monthlyPnl: _parseDouble(json['monthly_pnl']),
        avgWin: _parseDouble(json['avg_win']),
        avgLoss: _parseDouble(json['avg_loss']),
        profitFactor: _parseDouble(json['profit_factor']),
        sharpeRatio: _parseDouble(json['sharpe_ratio']),
        maxDrawdown: _parseDouble(json['max_drawdown']),
        activePositions: _parseInt(json['active_positions']),
        avgLatencyMs: _parseDouble(json['avg_latency_ms']),
        avgSlippagePct: _parseDouble(json['avg_slippage_pct']),
      );
    } catch (e) {
      throw FormatException('Failed to parse Metrics from JSON: $e');
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'total_trades': totalTrades,
      'winning_trades': winningTrades,
      'losing_trades': losingTrades,
      'win_rate': winRate,
      'total_pnl': totalPnl,
      'daily_pnl': dailyPnl,
      'weekly_pnl': weeklyPnl,
      'monthly_pnl': monthlyPnl,
      'avg_win': avgWin,
      'avg_loss': avgLoss,
      'profit_factor': profitFactor,
      'sharpe_ratio': sharpeRatio,
      'max_drawdown': maxDrawdown,
      'active_positions': activePositions,
      'avg_latency_ms': avgLatencyMs,
      'avg_slippage_pct': avgSlippagePct,
    };
  }

  /// Create a copy with modified fields
  Metrics copyWith({
    int? totalTrades,
    int? winningTrades,
    int? losingTrades,
    double? winRate,
    double? totalPnl,
    double? dailyPnl,
    double? weeklyPnl,
    double? monthlyPnl,
    double? avgWin,
    double? avgLoss,
    double? profitFactor,
    double? sharpeRatio,
    double? maxDrawdown,
    int? activePositions,
    double? avgLatencyMs,
    double? avgSlippagePct,
  }) {
    return Metrics(
      totalTrades: totalTrades ?? this.totalTrades,
      winningTrades: winningTrades ?? this.winningTrades,
      losingTrades: losingTrades ?? this.losingTrades,
      winRate: winRate ?? this.winRate,
      totalPnl: totalPnl ?? this.totalPnl,
      dailyPnl: dailyPnl ?? this.dailyPnl,
      weeklyPnl: weeklyPnl ?? this.weeklyPnl,
      monthlyPnl: monthlyPnl ?? this.monthlyPnl,
      avgWin: avgWin ?? this.avgWin,
      avgLoss: avgLoss ?? this.avgLoss,
      profitFactor: profitFactor ?? this.profitFactor,
      sharpeRatio: sharpeRatio ?? this.sharpeRatio,
      maxDrawdown: maxDrawdown ?? this.maxDrawdown,
      activePositions: activePositions ?? this.activePositions,
      avgLatencyMs: avgLatencyMs ?? this.avgLatencyMs,
      avgSlippagePct: avgSlippagePct ?? this.avgSlippagePct,
    );
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Metrics &&
      other.totalTrades == totalTrades &&
      other.winningTrades == winningTrades &&
      other.losingTrades == losingTrades &&
      other.winRate == winRate &&
      other.totalPnl == totalPnl &&
      other.dailyPnl == dailyPnl &&
      other.weeklyPnl == weeklyPnl &&
      other.monthlyPnl == monthlyPnl &&
      other.avgWin == avgWin &&
      other.avgLoss == avgLoss &&
      other.profitFactor == profitFactor &&
      other.sharpeRatio == sharpeRatio &&
      other.maxDrawdown == maxDrawdown &&
      other.activePositions == activePositions &&
      other.avgLatencyMs == avgLatencyMs &&
      other.avgSlippagePct == avgSlippagePct;
  }

  @override
  int get hashCode {
    return Object.hash(
      totalTrades,
      winningTrades,
      losingTrades,
      winRate,
      totalPnl,
      dailyPnl,
      weeklyPnl,
      monthlyPnl,
      avgWin,
      avgLoss,
      profitFactor,
      sharpeRatio,
      maxDrawdown,
      activePositions,
      avgLatencyMs,
      avgSlippagePct,
    );
  }

  @override
  String toString() {
    return 'Metrics('
        'totalTrades: $totalTrades, '
        'winRate: $winRate%, '
        'totalPnl: $totalPnl, '
        'dailyPnl: $dailyPnl, '
        'activePositions: $activePositions'
        ')';
  }
}
