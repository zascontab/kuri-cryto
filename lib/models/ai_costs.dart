/// Modelo para costos de IA
///
/// Representa los costos acumulados del uso de servicios de IA
class AICosts {
  final DailyCosts today;
  final MonthlyCosts thisMonth;

  const AICosts({
    required this.today,
    required this.thisMonth,
  });

  factory AICosts.fromJson(Map<String, dynamic> json) {
    return AICosts(
      today: DailyCosts.fromJson(json['today'] as Map<String, dynamic>),
      thisMonth:
          MonthlyCosts.fromJson(json['this_month'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today': today.toJson(),
      'this_month': thisMonth.toJson(),
    };
  }
}

/// Costos diarios
class DailyCosts {
  final double total;
  final int callCount;
  final Map<String, double> byProvider; // provider -> cost

  const DailyCosts({
    required this.total,
    required this.callCount,
    required this.byProvider,
  });

  factory DailyCosts.fromJson(Map<String, dynamic> json) {
    return DailyCosts(
      total: (json['total'] as num).toDouble(),
      callCount: json['call_count'] as int,
      byProvider: (json['by_provider'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'call_count': callCount,
      'by_provider': byProvider,
    };
  }

  /// Costo promedio por llamada
  double get avgCostPerCall => callCount > 0 ? total / callCount : 0.0;

  /// Provider con mayor costo
  String? get topProvider {
    if (byProvider.isEmpty) return null;
    return byProvider.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Obtiene el porcentaje de uso de un provider
  double getProviderPercent(String provider) {
    if (total == 0) return 0.0;
    final providerCost = byProvider[provider] ?? 0.0;
    return (providerCost / total) * 100;
  }
}

/// Costos mensuales
class MonthlyCosts {
  final double total;
  final double projected; // Proyección basada en uso actual

  const MonthlyCosts({
    required this.total,
    required this.projected,
  });

  factory MonthlyCosts.fromJson(Map<String, dynamic> json) {
    return MonthlyCosts(
      total: (json['total'] as num).toDouble(),
      projected: (json['projected'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'projected': projected,
    };
  }

  /// Diferencia entre proyección y gasto actual
  double get projectedDifference => projected - total;

  /// Porcentaje de incremento proyectado
  double get projectedIncreasePercent {
    if (total == 0) return 0.0;
    return (projectedDifference / total) * 100;
  }

  /// Verifica si la proyección es mayor al gasto actual
  bool get isProjectedHigher => projected > total;
}
