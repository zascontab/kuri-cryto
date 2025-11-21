/// Risk state model for monitoring trading risk levels
///
/// Tracks drawdowns, exposure, and risk controls to prevent excessive losses
class RiskState {
  /// Current daily drawdown percentage
  final double currentDrawdownDaily;

  /// Current weekly drawdown percentage
  final double currentDrawdownWeekly;

  /// Current monthly drawdown percentage
  final double currentDrawdownMonthly;

  /// Total exposure across all positions
  final double totalExposure;

  /// Exposure broken down by trading pair
  final Map<String, double> exposureBySymbol;

  /// Number of consecutive losing trades
  final int consecutiveLosses;

  /// Current risk mode: 'Conservative', 'Normal', 'Aggressive', 'ControlledCrazy'
  final String riskMode;

  /// Whether the kill switch is active (stops all trading)
  final bool killSwitchActive;

  /// Last time this state was updated
  final DateTime lastUpdate;

  /// Maximum allowed daily drawdown percentage
  final double maxDailyDrawdown;

  /// Maximum allowed weekly drawdown percentage
  final double maxWeeklyDrawdown;

  /// Maximum allowed monthly drawdown percentage
  final double maxMonthlyDrawdown;

  /// Maximum allowed consecutive losses
  final int maxConsecutiveLosses;

  /// Maximum allowed total exposure
  final double maxTotalExposure;

  const RiskState({
    this.currentDrawdownDaily = 0.0,
    this.currentDrawdownWeekly = 0.0,
    this.currentDrawdownMonthly = 0.0,
    this.totalExposure = 0.0,
    this.exposureBySymbol = const {},
    this.consecutiveLosses = 0,
    this.riskMode = 'Normal',
    this.killSwitchActive = false,
    required this.lastUpdate,
    this.maxDailyDrawdown = 5.0,
    this.maxWeeklyDrawdown = 10.0,
    this.maxMonthlyDrawdown = 15.0,
    this.maxConsecutiveLosses = 3,
    this.maxTotalExposure = 100.0,
  });

  /// Check if the system is in a high-risk state
  ///
  /// Returns true if any of the following conditions are met:
  /// - Daily drawdown exceeds 80% of limit
  /// - Weekly drawdown exceeds 80% of limit
  /// - Monthly drawdown exceeds 80% of limit
  /// - Consecutive losses exceed 80% of limit
  /// - Total exposure exceeds 80% of limit
  bool isHighRisk() {
    const threshold = 0.8;

    final dailyRisk = currentDrawdownDaily.abs() / maxDailyDrawdown;
    final weeklyRisk = currentDrawdownWeekly.abs() / maxWeeklyDrawdown;
    final monthlyRisk = currentDrawdownMonthly.abs() / maxMonthlyDrawdown;
    final lossRisk = consecutiveLosses / maxConsecutiveLosses;
    final exposureRisk = totalExposure / maxTotalExposure;

    return dailyRisk > threshold ||
        weeklyRisk > threshold ||
        monthlyRisk > threshold ||
        lossRisk > threshold ||
        exposureRisk > threshold;
  }

  /// Check if trading is allowed in the current state
  ///
  /// Returns false if:
  /// - Kill switch is active
  /// - Any drawdown limit is exceeded
  /// - Consecutive losses limit is exceeded
  /// - Total exposure limit is exceeded
  bool canTrade() {
    if (killSwitchActive) return false;

    // Check drawdown limits
    if (currentDrawdownDaily.abs() >= maxDailyDrawdown) return false;
    if (currentDrawdownWeekly.abs() >= maxWeeklyDrawdown) return false;
    if (currentDrawdownMonthly.abs() >= maxMonthlyDrawdown) return false;

    // Check consecutive losses
    if (consecutiveLosses >= maxConsecutiveLosses) return false;

    // Check exposure limit
    if (totalExposure >= maxTotalExposure) return false;

    return true;
  }

  /// Get risk level as a percentage (0-100)
  ///
  /// Combines all risk factors into a single score
  double getRiskLevel() {
    final dailyRisk = (currentDrawdownDaily.abs() / maxDailyDrawdown) * 100;
    final weeklyRisk = (currentDrawdownWeekly.abs() / maxWeeklyDrawdown) * 100;
    final monthlyRisk = (currentDrawdownMonthly.abs() / maxMonthlyDrawdown) * 100;
    final lossRisk = (consecutiveLosses / maxConsecutiveLosses) * 100;
    final exposureRisk = (totalExposure / maxTotalExposure) * 100;

    // Use the highest risk factor
    return [dailyRisk, weeklyRisk, monthlyRisk, lossRisk, exposureRisk]
        .reduce((a, b) => a > b ? a : b)
        .clamp(0.0, 100.0);
  }

  /// Get available exposure (remaining capacity)
  double getAvailableExposure() {
    return (maxTotalExposure - totalExposure).clamp(0.0, maxTotalExposure);
  }

  /// Get exposure percentage used
  double getExposurePercentage() {
    if (maxTotalExposure == 0) return 0.0;
    return (totalExposure / maxTotalExposure * 100).clamp(0.0, 100.0);
  }

  /// Create RiskState from JSON
  factory RiskState.fromJson(Map<String, dynamic> json) {
    try {
      // Parse exposure by symbol
      Map<String, double> exposureMap = {};
      if (json['exposure_by_symbol'] != null) {
        final exposureData = json['exposure_by_symbol'] as Map<String, dynamic>;
        exposureMap = exposureData.map(
          (key, value) => MapEntry(key, _parseDouble(value)),
        );
      }

      return RiskState(
        currentDrawdownDaily: _parseDouble(json['current_drawdown_daily']),
        currentDrawdownWeekly: _parseDouble(json['current_drawdown_weekly']),
        currentDrawdownMonthly: _parseDouble(json['current_drawdown_monthly']),
        totalExposure: _parseDouble(json['total_exposure']),
        exposureBySymbol: exposureMap,
        consecutiveLosses: _parseInt(json['consecutive_losses']),
        riskMode: json['risk_mode']?.toString() ?? 'Normal',
        killSwitchActive: json['kill_switch_active'] == true,
        lastUpdate: _parseDateTime(json['last_update']) ?? DateTime.now(),
        maxDailyDrawdown: _parseDouble(
          json['max_daily_drawdown'],
          defaultValue: 5.0,
        ),
        maxWeeklyDrawdown: _parseDouble(
          json['max_weekly_drawdown'],
          defaultValue: 10.0,
        ),
        maxMonthlyDrawdown: _parseDouble(
          json['max_monthly_drawdown'],
          defaultValue: 15.0,
        ),
        maxConsecutiveLosses: _parseInt(
          json['max_consecutive_losses'],
          defaultValue: 3,
        ),
        maxTotalExposure: _parseDouble(
          json['max_total_exposure'],
          defaultValue: 100.0,
        ),
      );
    } catch (e) {
      throw FormatException('Failed to parse RiskState from JSON: $e');
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'current_drawdown_daily': currentDrawdownDaily,
      'current_drawdown_weekly': currentDrawdownWeekly,
      'current_drawdown_monthly': currentDrawdownMonthly,
      'total_exposure': totalExposure,
      'exposure_by_symbol': exposureBySymbol,
      'consecutive_losses': consecutiveLosses,
      'risk_mode': riskMode,
      'kill_switch_active': killSwitchActive,
      'last_update': lastUpdate.toIso8601String(),
      'max_daily_drawdown': maxDailyDrawdown,
      'max_weekly_drawdown': maxWeeklyDrawdown,
      'max_monthly_drawdown': maxMonthlyDrawdown,
      'max_consecutive_losses': maxConsecutiveLosses,
      'max_total_exposure': maxTotalExposure,
    };
  }

  /// Create a copy with modified fields
  RiskState copyWith({
    double? currentDrawdownDaily,
    double? currentDrawdownWeekly,
    double? currentDrawdownMonthly,
    double? totalExposure,
    Map<String, double>? exposureBySymbol,
    int? consecutiveLosses,
    String? riskMode,
    bool? killSwitchActive,
    DateTime? lastUpdate,
    double? maxDailyDrawdown,
    double? maxWeeklyDrawdown,
    double? maxMonthlyDrawdown,
    int? maxConsecutiveLosses,
    double? maxTotalExposure,
  }) {
    return RiskState(
      currentDrawdownDaily: currentDrawdownDaily ?? this.currentDrawdownDaily,
      currentDrawdownWeekly: currentDrawdownWeekly ?? this.currentDrawdownWeekly,
      currentDrawdownMonthly: currentDrawdownMonthly ?? this.currentDrawdownMonthly,
      totalExposure: totalExposure ?? this.totalExposure,
      exposureBySymbol: exposureBySymbol ?? this.exposureBySymbol,
      consecutiveLosses: consecutiveLosses ?? this.consecutiveLosses,
      riskMode: riskMode ?? this.riskMode,
      killSwitchActive: killSwitchActive ?? this.killSwitchActive,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      maxDailyDrawdown: maxDailyDrawdown ?? this.maxDailyDrawdown,
      maxWeeklyDrawdown: maxWeeklyDrawdown ?? this.maxWeeklyDrawdown,
      maxMonthlyDrawdown: maxMonthlyDrawdown ?? this.maxMonthlyDrawdown,
      maxConsecutiveLosses: maxConsecutiveLosses ?? this.maxConsecutiveLosses,
      maxTotalExposure: maxTotalExposure ?? this.maxTotalExposure,
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

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RiskState &&
      other.currentDrawdownDaily == currentDrawdownDaily &&
      other.currentDrawdownWeekly == currentDrawdownWeekly &&
      other.currentDrawdownMonthly == currentDrawdownMonthly &&
      other.totalExposure == totalExposure &&
      _mapEquals(other.exposureBySymbol, exposureBySymbol) &&
      other.consecutiveLosses == consecutiveLosses &&
      other.riskMode == riskMode &&
      other.killSwitchActive == killSwitchActive &&
      other.lastUpdate == lastUpdate;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentDrawdownDaily,
      currentDrawdownWeekly,
      currentDrawdownMonthly,
      totalExposure,
      Object.hashAll(exposureBySymbol.entries.map((e) => Object.hash(e.key, e.value))),
      consecutiveLosses,
      riskMode,
      killSwitchActive,
      lastUpdate,
    );
  }

  @override
  String toString() {
    return 'RiskState('
        'dailyDD: $currentDrawdownDaily%, '
        'weeklyDD: $currentDrawdownWeekly%, '
        'monthlyDD: $currentDrawdownMonthly%, '
        'exposure: $totalExposure, '
        'consecutiveLosses: $consecutiveLosses, '
        'mode: $riskMode, '
        'killSwitch: $killSwitchActive'
        ')';
  }

  static bool _mapEquals(Map<String, double> a, Map<String, double> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
