import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/llm_analysis.dart';

/// Card para mostrar explicación detallada del LLM
///
/// Muestra:
/// - Icono de IA
/// - Explicación completa
/// - Factores clave
/// - Evaluación de riesgo
/// - Provider y modelo usado
class LLMExplanationCard extends StatefulWidget {
  final LLMAnalysis llmAnalysis;
  final bool expandable;

  const LLMExplanationCard({
    super.key,
    required this.llmAnalysis,
    this.expandable = true,
  });

  @override
  State<LLMExplanationCard> createState() => _LLMExplanationCardState();
}

class _LLMExplanationCardState extends State<LLMExplanationCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riskColor = _getRiskColor();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: widget.expandable
                ? () => setState(() => _isExpanded = !_isExpanded)
                : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.smart_toy,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Análisis de ${_getProviderDisplayName()}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.llmAnalysis.model,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.expandable)
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () => _copyToClipboard(context),
                    tooltip: 'Copiar explicación',
                  ),
                ],
              ),
            ),
          ),

          // Content
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Explicación
                  Text(
                    widget.llmAnalysis.explanation,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Factores clave
                  if (widget.llmAnalysis.keyFactors.isNotEmpty) ...[
                    Text(
                      'Factores Clave:',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.llmAnalysis.keyFactors.map((factor) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                factor,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],

                  // Evaluación de riesgo
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: riskColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: riskColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getRiskIcon(),
                          color: riskColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Riesgo: ${widget.llmAnalysis.riskAssessment}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: riskColor,
                                ),
                              ),
                              Text(
                                'Confianza: ${(widget.llmAnalysis.confidence * 100).toStringAsFixed(0)}%',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getProviderDisplayName() {
    if (widget.llmAnalysis.isGemini) return 'Gemini';
    if (widget.llmAnalysis.isGPT) return 'GPT';
    if (widget.llmAnalysis.isClaude) return 'Claude';
    return widget.llmAnalysis.provider;
  }

  Color _getRiskColor() {
    if (widget.llmAnalysis.isLowRisk) {
      return const Color(0xFF10B981); // Green
    } else if (widget.llmAnalysis.isMediumRisk) {
      return const Color(0xFFF59E0B); // Orange
    } else {
      return const Color(0xFFEF4444); // Red
    }
  }

  IconData _getRiskIcon() {
    if (widget.llmAnalysis.isLowRisk) {
      return Icons.check_circle;
    } else if (widget.llmAnalysis.isMediumRisk) {
      return Icons.warning;
    } else {
      return Icons.error;
    }
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(
      ClipboardData(text: widget.llmAnalysis.explanation),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Explicación copiada al portapapeles'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
