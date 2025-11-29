import 'portfolio.dart';

/// Performance data model for portfolio analytics
class PerformanceData {
  final List<HistoricalValue> historicalValues;
  final double roi;
  final Asset? bestPerformer;
  final Asset? worstPerformer;
  final DateTime startDate;
  final DateTime endDate;

  const PerformanceData({
    required this.historicalValues,
    required this.roi,
    this.bestPerformer,
    this.worstPerformer,
    required this.startDate,
    required this.endDate,
  });

  /// Total return percentage
  double get totalReturn => roi * 100;

  /// Number of data points
  int get dataPoints => historicalValues.length;

  /// Average daily return
  double get averageDailyReturn {
    if (historicalValues.length < 2) return 0.0;
    final days = endDate.difference(startDate).inDays;
    return days > 0 ? roi / days : 0.0;
  }

  /// Maximum value in period
  double get maxValue {
    if (historicalValues.isEmpty) return 0.0;
    return historicalValues.map((e) => e.value).reduce((a, b) => a > b ? a : b);
  }

  /// Minimum value in period
  double get minValue {
    if (historicalValues.isEmpty) return 0.0;
    return historicalValues.map((e) => e.value).reduce((a, b) => a < b ? a : b);
  }

  factory PerformanceData.fromJson(Map<String, dynamic> json) {
    return PerformanceData(
      historicalValues: (json['historical_values'] as List<dynamic>?)
              ?.map((e) => HistoricalValue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      roi: (json['roi'] as num?)?.toDouble() ?? 0.0,
      bestPerformer: json['best_performer'] != null
          ? Asset.fromJson(json['best_performer'] as Map<String, dynamic>)
          : null,
      worstPerformer: json['worst_performer'] != null
          ? Asset.fromJson(json['worst_performer'] as Map<String, dynamic>)
          : null,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : DateTime.now().subtract(const Duration(days: 30)),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'historical_values': historicalValues.map((e) => e.toJson()).toList(),
      'roi': roi,
      if (bestPerformer != null) 'best_performer': bestPerformer!.toJson(),
      if (worstPerformer != null) 'worst_performer': worstPerformer!.toJson(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }
}

/// Historical value point for charts
class HistoricalValue {
  final DateTime timestamp;
  final double value;

  const HistoricalValue({
    required this.timestamp,
    required this.value,
  });

  factory HistoricalValue.fromJson(Map<String, dynamic> json) {
    return HistoricalValue(
      timestamp: DateTime.parse(json['timestamp'] as String),
      value: (json['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'value': value,
    };
  }
}
