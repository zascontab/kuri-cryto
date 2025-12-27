/// Análisis generado por LLM (Large Language Model)
///
/// Contiene la explicación detallada y factores clave identificados por IA
/// como Gemini, GPT o Claude.
class LLMAnalysis {
  /// Proveedor del LLM ('google', 'openai', 'anthropic')
  final String provider;

  /// Modelo específico usado (ej: 'gemini-2.5-flash', 'gpt-4', 'claude-3')
  final String model;

  /// Explicación detallada generada por el LLM
  final String explanation;

  /// Factores clave identificados por el LLM
  final List<String> keyFactors;

  /// Evaluación de riesgo ('Low', 'Medium', 'High')
  final String riskAssessment;

  /// Nivel de confianza del LLM (0.0 - 1.0)
  final double confidence;

  const LLMAnalysis({
    required this.provider,
    required this.model,
    required this.explanation,
    required this.keyFactors,
    required this.riskAssessment,
    required this.confidence,
  });

  factory LLMAnalysis.fromJson(Map<String, dynamic> json) {
    return LLMAnalysis(
      provider: json['provider'] as String? ?? '',
      model: json['model'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      keyFactors: json['key_factors'] != null
          ? List<String>.from(json['key_factors'] as List)
          : [],
      riskAssessment: json['risk_assessment'] as String? ?? 'Medium',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'model': model,
      'explanation': explanation,
      'key_factors': keyFactors,
      'risk_assessment': riskAssessment,
      'confidence': confidence,
    };
  }

  /// Indica si el riesgo es bajo
  bool get isLowRisk => riskAssessment.toLowerCase() == 'low';

  /// Indica si el riesgo es medio
  bool get isMediumRisk => riskAssessment.toLowerCase() == 'medium';

  /// Indica si el riesgo es alto
  bool get isHighRisk => riskAssessment.toLowerCase() == 'high';

  /// Indica si la confianza del LLM es alta (>= 70%)
  bool get isHighConfidence => confidence >= 0.70;

  /// Indica si es análisis de Gemini
  bool get isGemini => provider.toLowerCase() == 'google';

  /// Indica si es análisis de GPT
  bool get isGPT => provider.toLowerCase() == 'openai';

  /// Indica si es análisis de Claude
  bool get isClaude => provider.toLowerCase() == 'anthropic';

  /// Nombre amigable del proveedor
  String get providerDisplayName {
    if (isGemini) return 'Gemini';
    if (isGPT) return 'GPT';
    if (isClaude) return 'Claude';
    return provider;
  }
}
