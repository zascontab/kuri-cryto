/// Strategy performance metrics
///
/// Contains detailed performance statistics for a trading strategy
class StrategyPerformance {
  /// Total number of trades executed
  final int totalTrades;

  /// Number of winning trades
  final int winningTrades;

  /// Number of losing trades
  final int losingTrades;

  /// Win rate as a percentage (0-100)
  final double winRate;

  /// Total profit/loss
  final double totalPnl;

  /// Average profit per winning trade
  final double avgWin;

  /// Average loss per losing trade
  final double avgLoss;

  /// Sharpe ratio (risk-adjusted return)
  final double sharpeRatio;

  /// Maximum drawdown percentage
  final double maxDrawdown;

  /// Profit factor (total wins / total losses)
  final double profitFactor;

  const StrategyPerformance({
    this.totalTrades = 0,
    this.winningTrades = 0,
    this.losingTrades = 0,
    this.winRate = 0.0,
    this.totalPnl = 0.0,
    this.avgWin = 0.0,
    this.avgLoss = 0.0,
    this.sharpeRatio = 0.0,
    this.maxDrawdown = 0.0,
    this.profitFactor = 0.0,
  });

  /// Create StrategyPerformance from JSON
  factory StrategyPerformance.fromJson(Map<String, dynamic> json) {
    try {
      return StrategyPerformance(
        totalTrades: _parseInt(json['total_trades']),
        winningTrades: _parseInt(json['winning_trades']),
        losingTrades: _parseInt(json['losing_trades']),
        winRate: _parseDouble(json['win_rate']),
        totalPnl: _parseDouble(json['total_pnl']),
        avgWin: _parseDouble(json['avg_win']),
        avgLoss: _parseDouble(json['avg_loss']),
        sharpeRatio: _parseDouble(json['sharpe_ratio']),
        maxDrawdown: _parseDouble(json['max_drawdown']),
        profitFactor: _parseDouble(json['profit_factor']),
      );
    } catch (e) {
      throw FormatException('Failed to parse StrategyPerformance from JSON: $e');
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
      'avg_win': avgWin,
      'avg_loss': avgLoss,
      'sharpe_ratio': sharpeRatio,
      'max_drawdown': maxDrawdown,
      'profit_factor': profitFactor,
    };
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

    return other is StrategyPerformance &&
      other.totalTrades == totalTrades &&
      other.winningTrades == winningTrades &&
      other.losingTrades == losingTrades &&
      other.winRate == winRate &&
      other.totalPnl == totalPnl &&
      other.avgWin == avgWin &&
      other.avgLoss == avgLoss &&
      other.sharpeRatio == sharpeRatio &&
      other.maxDrawdown == maxDrawdown &&
      other.profitFactor == profitFactor;
  }

  @override
  int get hashCode {
    return Object.hash(
      totalTrades,
      winningTrades,
      losingTrades,
      winRate,
      totalPnl,
      avgWin,
      avgLoss,
      sharpeRatio,
      maxDrawdown,
      profitFactor,
    );
  }
}

/// Trading strategy model
///
/// Represents a trading strategy with its configuration and performance metrics
class Strategy {
  /// Strategy name/identifier
  final String name;

  /// Whether the strategy is currently active
  final bool active;

  /// Strategy weight in portfolio (0.0 - 1.0)
  final double weight;

  /// Performance metrics for this strategy
  final StrategyPerformance performance;

  /// Optional configuration parameters
  final Map<String, dynamic>? config;

  const Strategy({
    required this.name,
    this.active = false,
    this.weight = 0.0,
    required this.performance,
    this.config,
  });

  /// Check if strategy is performing well
  ///
  /// Returns true if win rate > 50% and total PnL is positive
  bool get isPerformingWell {
    return performance.winRate > 50.0 && performance.totalPnl > 0;
  }

  /// Check if strategy has sufficient data
  ///
  /// Returns true if strategy has at least 10 trades
  bool get hasSufficientData {
    return performance.totalTrades >= 10;
  }

  /// Create Strategy from JSON
  factory Strategy.fromJson(Map<String, dynamic> json) {
    try {
      return Strategy(
        name: json['name']?.toString() ?? 'unknown',
        active: json['active'] == true,
        weight: _parseDouble(json['weight']),
        performance: json['performance'] != null
            ? StrategyPerformance.fromJson(json['performance'] as Map<String, dynamic>)
            : const StrategyPerformance(),
        config: json['config'] as Map<String, dynamic>?,
      );
    } catch (e) {
      throw FormatException('Failed to parse Strategy from JSON: $e');
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'active': active,
      'weight': weight,
      'performance': performance.toJson(),
      if (config != null) 'config': config,
    };
  }

  /// Create a copy with modified fields
  Strategy copyWith({
    String? name,
    bool? active,
    double? weight,
    StrategyPerformance? performance,
    Map<String, dynamic>? config,
  }) {
    return Strategy(
      name: name ?? this.name,
      active: active ?? this.active,
      weight: weight ?? this.weight,
      performance: performance ?? this.performance,
      config: config ?? this.config,
    );
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

    return other is Strategy &&
      other.name == name &&
      other.active == active &&
      other.weight == weight &&
      other.performance == performance;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      active,
      weight,
      performance,
    );
  }

  @override
  String toString() {
    return 'Strategy('
        'name: $name, '
        'active: $active, '
        'weight: $weight, '
        'winRate: ${performance.winRate}%, '
        'totalPnl: ${performance.totalPnl}'
        ')';
  }
}
