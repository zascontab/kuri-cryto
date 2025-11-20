/// Configuración del AI Trading Bot
class AiBotConfig {
  final String pair;
  final String exchange;
  final double confidenceThreshold;
  final double tradeSizeUsd;
  final int leverage;
  final bool dryRun;
  final bool autoExecute;
  final double maxDailyLossUsd;
  final int maxDailyTrades;
  final int maxConsecutiveErrors;
  final int maxOpenPositions;

  const AiBotConfig({
    required this.pair,
    required this.exchange,
    required this.confidenceThreshold,
    required this.tradeSizeUsd,
    required this.leverage,
    required this.dryRun,
    required this.autoExecute,
    required this.maxDailyLossUsd,
    required this.maxDailyTrades,
    required this.maxConsecutiveErrors,
    required this.maxOpenPositions,
  });

  factory AiBotConfig.fromJson(Map<String, dynamic> json) {
    return AiBotConfig(
      pair: json['pair'] as String? ?? 'DOGE-USDT',
      exchange: json['exchange'] as String? ?? 'kucoin',
      confidenceThreshold: (json['confidence_threshold'] as num?)?.toDouble() ?? 0.70,
      tradeSizeUsd: (json['trade_size_usd'] as num?)?.toDouble() ?? 3.0,
      leverage: json['leverage'] as int? ?? 5,
      dryRun: json['dry_run'] as bool? ?? true,
      autoExecute: json['auto_execute'] as bool? ?? false,
      maxDailyLossUsd: (json['max_daily_loss_usd'] as num?)?.toDouble() ?? 50.0,
      maxDailyTrades: json['max_daily_trades'] as int? ?? 20,
      maxConsecutiveErrors: json['max_consecutive_errors'] as int? ?? 3,
      maxOpenPositions: json['max_open_positions'] as int? ?? 2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pair': pair,
      'exchange': exchange,
      'confidence_threshold': confidenceThreshold,
      'trade_size_usd': tradeSizeUsd,
      'leverage': leverage,
      'dry_run': dryRun,
      'auto_execute': autoExecute,
      'max_daily_loss_usd': maxDailyLossUsd,
      'max_daily_trades': maxDailyTrades,
      'max_consecutive_errors': maxConsecutiveErrors,
      'max_open_positions': maxOpenPositions,
    };
  }

  AiBotConfig copyWith({
    String? pair,
    String? exchange,
    double? confidenceThreshold,
    double? tradeSizeUsd,
    int? leverage,
    bool? dryRun,
    bool? autoExecute,
    double? maxDailyLossUsd,
    int? maxDailyTrades,
    int? maxConsecutiveErrors,
    int? maxOpenPositions,
  }) {
    return AiBotConfig(
      pair: pair ?? this.pair,
      exchange: exchange ?? this.exchange,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      tradeSizeUsd: tradeSizeUsd ?? this.tradeSizeUsd,
      leverage: leverage ?? this.leverage,
      dryRun: dryRun ?? this.dryRun,
      autoExecute: autoExecute ?? this.autoExecute,
      maxDailyLossUsd: maxDailyLossUsd ?? this.maxDailyLossUsd,
      maxDailyTrades: maxDailyTrades ?? this.maxDailyTrades,
      maxConsecutiveErrors: maxConsecutiveErrors ?? this.maxConsecutiveErrors,
      maxOpenPositions: maxOpenPositions ?? this.maxOpenPositions,
    );
  }
}
