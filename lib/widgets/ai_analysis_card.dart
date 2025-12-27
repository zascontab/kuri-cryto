import 'package:flutter/material.dart';
import '../models/llm_analysis.dart';
import '../models/sentiment_analysis.dart';
import '../models/comprehensive_analysis.dart';

/// Card completo para mostrar análisis con IA
///
/// Muestra:
/// - Acción principal (BUY/SELL/WAIT) con color
/// - Confianza con progress bar
/// - Explicación generada por LLM
/// - Factores clave como chips
/// - Sentimiento de mercado
class AIAnalysisCard extends StatelessWidget {
  final Recommendation recommendation;
  final LLMAnalysis? llmAnalysis;
  final SentimentAnalysis? sentimentAnalysis;

  const AIAnalysisCard({
    super.key,
    required this.recommendation,
    this.llmAnalysis,
    this.sentimentAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionColor = _getActionColor();

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              actionColor.withValues(alpha: 0.1),
              actionColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con acción
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Análisis de IA',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: actionColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      recommendation.action,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Confianza
              Text(
                'Confianza: ${(recommendation.confidence * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: recommendation.confidence,
                  minHeight: 10,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(actionColor),
                ),
              ),

              // Explicación de LLM
              if (llmAnalysis != null) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.smart_toy, size: 20, color: actionColor),
                    const SizedBox(width: 8),
                    Text(
                      llmAnalysis!.providerDisplayName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: actionColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      llmAnalysis!.model,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  llmAnalysis!.explanation,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: llmAnalysis!.keyFactors.map((factor) {
                    return Chip(
                      label: Text(factor),
                      backgroundColor: actionColor.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: actionColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],

              // Sentimiento
              if (sentimentAnalysis != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getSentimentColor().withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        sentimentAnalysis!.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sentimiento: ${sentimentAnalysis!.trend.toUpperCase()}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getSentimentColor(),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${sentimentAnalysis!.positivePercent}% positivo',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (sentimentAnalysis!.sources.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          children: sentimentAnalysis!.sources.map((source) {
                            return Chip(
                              label: Text(source),
                              labelStyle: const TextStyle(fontSize: 10),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getActionColor() {
    if (recommendation.isBuy) {
      return const Color(0xFF10B981); // Green
    } else if (recommendation.isSell) {
      return const Color(0xFFEF4444); // Red
    } else {
      return const Color(0xFFF59E0B); // Orange
    }
  }

  Color _getSentimentColor() {
    if (sentimentAnalysis == null) return Colors.grey;
    if (sentimentAnalysis!.isBullish) return const Color(0xFF10B981);
    if (sentimentAnalysis!.isBearish) return const Color(0xFFEF4444);
    return const Color(0xFF6B7280);
  }
}
