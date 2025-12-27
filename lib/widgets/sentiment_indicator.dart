import 'package:flutter/material.dart';
import '../models/sentiment_analysis.dart';

/// Indicador visual de sentimiento de mercado
///
/// Muestra:
/// - Emoji según sentimiento
/// - Porcentaje
/// - Trend (bullish/bearish/neutral)
/// - Fuentes (news, twitter, reddit)
class SentimentIndicator extends StatelessWidget {
  final SentimentAnalysis sentiment;
  final bool compact;

  const SentimentIndicator({
    super.key,
    required this.sentiment,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getSentimentColor();

    if (compact) {
      return _buildCompact(theme, color);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                sentiment.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sentimiento: ${sentiment.trend.toUpperCase()}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${sentiment.positivePercent}% positivo',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (sentiment.sources.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sentiment.sources.map((source) {
                return Chip(
                  label: Text(_getSourceDisplayName(source)),
                  avatar: Icon(
                    _getSourceIcon(source),
                    size: 16,
                  ),
                  labelStyle: const TextStyle(fontSize: 12),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
          if (sentiment.isHighConfidence) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.verified,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Alta confianza (${(sentiment.confidence * 100).toStringAsFixed(0)}%)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompact(ThemeData theme, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(sentiment.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            sentiment.trend.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${sentiment.positivePercent}%',
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSentimentColor() {
    if (sentiment.isBullish) return const Color(0xFF10B981); // Green
    if (sentiment.isBearish) return const Color(0xFFEF4444); // Red
    return const Color(0xFF6B7280); // Gray
  }

  String _getSourceDisplayName(String source) {
    switch (source.toLowerCase()) {
      case 'news':
        return 'Noticias';
      case 'twitter':
        return 'Twitter';
      case 'reddit':
        return 'Reddit';
      default:
        return source;
    }
  }

  IconData _getSourceIcon(String source) {
    switch (source.toLowerCase()) {
      case 'news':
        return Icons.newspaper;
      case 'twitter':
        return Icons.tag;
      case 'reddit':
        return Icons.forum;
      default:
        return Icons.source;
    }
  }
}
