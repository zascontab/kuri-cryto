/// Estado completo del sistema de IA
///
/// Incluye información sobre LLM, análisis de sentimiento y gestión de costos
class AIStatus {
  /// Estado del LLM
  final LLMStatus llm;

  /// Estado del análisis de sentimiento
  final SentimentStatus sentiment;

  /// Gestión de costos
  final CostManagement costManagement;

  const AIStatus({
    required this.llm,
    required this.sentiment,
    required this.costManagement,
  });

  factory AIStatus.fromJson(Map<String, dynamic> json) {
    return AIStatus(
      llm: LLMStatus.fromJson(
        json['llm'] as Map<String, dynamic>? ?? {},
      ),
      sentiment: SentimentStatus.fromJson(
        json['sentiment'] as Map<String, dynamic>? ?? {},
      ),
      costManagement: CostManagement.fromJson(
        json['cost_management'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'llm': llm.toJson(),
      'sentiment': sentiment.toJson(),
      'cost_management': costManagement.toJson(),
    };
  }

  /// Indica si todo el sistema de IA está operacional
  bool get isFullyOperational =>
      llm.isOperational && sentiment.enabled && !costManagement.hasReachedLimit;

  /// Indica si hay algún problema con el sistema de IA
  bool get hasIssues => !llm.isOperational || costManagement.hasReachedLimit;
}

/// Estado del LLM (Large Language Model)
class LLMStatus {
  /// Indica si el LLM está habilitado
  final bool enabled;

  /// Proveedor del LLM ('google', 'openai', 'anthropic')
  final String provider;

  /// Modelo específico usado
  final String model;

  /// Estado operacional ('operational', 'error', 'degraded')
  final String status;

  /// Número de llamadas realizadas hoy
  final int callsToday;

  /// Límite diario de llamadas
  final int dailyLimit;

  const LLMStatus({
    required this.enabled,
    required this.provider,
    required this.model,
    required this.status,
    required this.callsToday,
    required this.dailyLimit,
  });

  factory LLMStatus.fromJson(Map<String, dynamic> json) {
    return LLMStatus(
      enabled: json['enabled'] as bool? ?? false,
      provider: json['provider'] as String? ?? '',
      model: json['model'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      callsToday: json['calls_today'] as int? ?? 0,
      dailyLimit: json['daily_limit'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'provider': provider,
      'model': model,
      'status': status,
      'calls_today': callsToday,
      'daily_limit': dailyLimit,
    };
  }

  /// Indica si el LLM está operacional
  bool get isOperational => enabled && status == 'operational';

  /// Indica si hay un error
  bool get hasError => status == 'error';

  /// Indica si el servicio está degradado
  bool get isDegraded => status == 'degraded';

  /// Porcentaje de llamadas usadas
  double get usagePercent {
    if (dailyLimit == 0) return 0.0;
    return (callsToday / dailyLimit) * 100;
  }

  /// Llamadas restantes
  int get callsRemaining => dailyLimit - callsToday;

  /// Indica si se ha alcanzado el límite
  bool get hasReachedLimit => callsToday >= dailyLimit;

  /// Indica si está cerca del límite (>= 80%)
  bool get isNearLimit => usagePercent >= 80;

  /// Nombre amigable del proveedor
  String get providerDisplayName {
    switch (provider.toLowerCase()) {
      case 'google':
        return 'Gemini';
      case 'openai':
        return 'GPT';
      case 'anthropic':
        return 'Claude';
      default:
        return provider;
    }
  }

  /// Color sugerido según el estado
  String get statusColorHex {
    if (isOperational) return '#10B981'; // Green
    if (isDegraded) return '#F59E0B'; // Orange
    if (hasError) return '#EF4444'; // Red
    return '#6B7280'; // Gray
  }
}

/// Estado del análisis de sentimiento
class SentimentStatus {
  /// Indica si el análisis de sentimiento está habilitado
  final bool enabled;

  /// Fuentes de datos habilitadas
  final Map<String, bool> sources;

  const SentimentStatus({
    required this.enabled,
    required this.sources,
  });

  factory SentimentStatus.fromJson(Map<String, dynamic> json) {
    final sourcesData = json['sources'] as Map<String, dynamic>? ?? {};
    final sources = sourcesData.map(
      (key, value) => MapEntry(key, value as bool? ?? false),
    );

    return SentimentStatus(
      enabled: json['enabled'] as bool? ?? false,
      sources: sources,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'sources': sources,
    };
  }

  /// Número de fuentes habilitadas
  int get enabledSourcesCount =>
      sources.values.where((enabled) => enabled).length;

  /// Lista de fuentes habilitadas
  List<String> get enabledSources =>
      sources.entries.where((e) => e.value).map((e) => e.key).toList();

  /// Indica si una fuente específica está habilitada
  bool isSourceEnabled(String source) => sources[source] ?? false;
}

/// Gestión de costos de IA
class CostManagement {
  /// Indica si la gestión de costos está habilitada
  final bool enabled;

  /// Presupuesto diario en USD
  final double dailyBudget;

  /// Gasto del día actual en USD
  final double spentToday;

  /// Presupuesto restante en USD
  final double remaining;

  const CostManagement({
    required this.enabled,
    required this.dailyBudget,
    required this.spentToday,
    required this.remaining,
  });

  factory CostManagement.fromJson(Map<String, dynamic> json) {
    return CostManagement(
      enabled: json['enabled'] as bool? ?? false,
      dailyBudget: (json['daily_budget'] as num?)?.toDouble() ?? 0.0,
      spentToday: (json['spent_today'] as num?)?.toDouble() ?? 0.0,
      remaining: (json['remaining'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'daily_budget': dailyBudget,
      'spent_today': spentToday,
      'remaining': remaining,
    };
  }

  /// Porcentaje del presupuesto usado
  double get usagePercent {
    if (dailyBudget == 0) return 0.0;
    return (spentToday / dailyBudget) * 100;
  }

  /// Indica si se ha alcanzado el límite del presupuesto
  bool get hasReachedLimit => remaining <= 0;

  /// Indica si está cerca del límite (>= 80%)
  bool get isNearLimit => usagePercent >= 80;

  /// Color sugerido según el uso
  String get usageColorHex {
    if (usagePercent < 50) return '#10B981'; // Green
    if (usagePercent < 80) return '#F59E0B'; // Orange
    return '#EF4444'; // Red
  }
}
