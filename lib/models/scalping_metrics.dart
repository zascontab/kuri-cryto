/// Scalping system metrics model
///
/// Represents trading metrics according to the backend specification
/// (SCALPING_ENDPOINTS_SPEC.md)
class ScalpingMetrics {
  /// Total number of trades executed
  final int totalTrades;

  /// Number of successful trades
  final int successfulTrades;

  /// Number of failed trades
  final int failedTrades;

  /// Total profit and loss
  final double totalPnl;

  /// Total trading volume
  final double totalVolume;

  /// Win rate as a decimal (0.0 - 1.0)
  final double winRate;

  /// Average profit per winning trade
  final double avgProfit;

  /// Average loss per losing trade
  final double avgLoss;

  /// Timestamp when metrics were generated (RFC3339 format)
  final String timestamp;

  const ScalpingMetrics({
    required this.totalTrades,
    required this.successfulTrades,
    required this.failedTrades,
    required this.totalPnl,
    required this.totalVolume,
    required this.winRate,
    required this.avgProfit,
    required this.avgLoss,
    required this.timestamp,
  });

  /// Get win rate as percentage (0-100)
  double get winRatePercent => winRate * 100;

  /// Check if profitable
  bool get isProfitable => totalPnl > 0;

  /// Check if has trades
  bool get hasTrades => totalTrades > 0;

  /// Get loss rate as decimal (0.0 - 1.0)
  double get lossRate => 1.0 - winRate;

  /// Get loss rate as percentage (0-100)
  double get lossRatePercent => lossRate * 100;

  /// Get average PnL per trade
  double get avgPnlPerTrade => totalTrades > 0 ? totalPnl / totalTrades : 0.0;

  /// Get profit factor (avg profit / avg loss)
  double get profitFactor =>
      avgLoss != 0 ? avgProfit.abs() / avgLoss.abs() : 0.0;

  /// Get timestamp as DateTime
  DateTime get timestampAsDateTime => DateTime.parse(timestamp);

  /// Create ScalpingMetrics from JSON
  factory ScalpingMetrics.fromJson(Map<String, dynamic> json) {
    return ScalpingMetrics(
      totalTrades: json['total_trades'] as int,
      successfulTrades: json['successful_trades'] as int,
      failedTrades: json['failed_trades'] as int,
      totalPnl: (json['total_pnl'] as num).toDouble(),
      totalVolume: (json['total_volume'] as num).toDouble(),
      winRate: (json['win_rate'] as num).toDouble(),
      avgProfit: (json['avg_profit'] as num).toDouble(),
      avgLoss: (json['avg_loss'] as num).toDouble(),
      timestamp: json['timestamp'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'total_trades': totalTrades,
      'successful_trades': successfulTrades,
      'failed_trades': failedTrades,
      'total_pnl': totalPnl,
      'total_volume': totalVolume,
      'win_rate': winRate,
      'avg_profit': avgProfit,
      'avg_loss': avgLoss,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return 'ScalpingMetrics('
        'totalTrades: $totalTrades, '
        'successfulTrades: $successfulTrades, '
        'failedTrades: $failedTrades, '
        'totalPnl: $totalPnl, '
        'winRate: ${winRatePercent.toStringAsFixed(2)}%'
        ')';
  }
}
