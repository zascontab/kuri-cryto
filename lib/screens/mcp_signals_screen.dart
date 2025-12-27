import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/comprehensive_analysis_provider.dart';
import '../models/comprehensive_analysis.dart';
import '../models/technical_indicators.dart';
import '../widgets/scenarios_widget.dart';
import '../widgets/recommendation_widget.dart';
import '../widgets/multi_timeframe_widget.dart';

/// Screen for displaying comprehensive market signals and analysis
class McpSignalsScreen extends ConsumerStatefulWidget {
  final String exchange;
  final String pair;

  const McpSignalsScreen({
    super.key,
    required this.exchange,
    required this.pair,
  });

  @override
  ConsumerState<McpSignalsScreen> createState() => _McpSignalsScreenState();
}

class _McpSignalsScreenState extends ConsumerState<McpSignalsScreen> {
  @override
  void initState() {
    super.initState();
    // Load analysis on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalysis();
    });
  }

  void _loadAnalysis() {
    // El provider se carga automáticamente cuando se observa
    ref.invalidate(comprehensiveAnalysisNotifierProvider(widget.pair));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final analysisAsync =
        ref.watch(comprehensiveAnalysisNotifierProvider(widget.pair));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.pair} - ${widget.exchange}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalysis,
          ),
        ],
      ),
      body: analysisAsync.when(
        data: (analysis) {
          return RefreshIndicator(
            onRefresh: () async {
              _loadAnalysis();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPriceCard(analysis, theme),
                  const SizedBox(height: 16),
                  RecommendationWidget(
                    recommendation: analysis.recommendation,
                  ),
                  const SizedBox(height: 16),
                  ScenariosWidget(
                    scenarios: analysis.scenarios.values.toList(),
                  ),
                  const SizedBox(height: 16),
                  MultiTimeframeWidget(
                    technicalIndicators: _convertTechnicalIndicators(
                        analysis.technicalIndicators),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadAnalysis,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceCard(ComprehensiveAnalysis analysis, ThemeData theme) {
    final priceData = analysis.priceData;
    final changeColor = priceData.isRising ? Colors.green : Colors.red;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              analysis.symbol,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '\$${priceData.last.toStringAsFixed(4)}',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: changeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    priceData.isRising
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: changeColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${priceData.isRising ? '+' : ''}${priceData.changePercent24h.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: changeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriceMetric(
                  'High 24h',
                  '\$${priceData.high24h.toStringAsFixed(4)}',
                  theme,
                ),
                _buildPriceMetric(
                  'Low 24h',
                  '\$${priceData.low24h.toStringAsFixed(4)}',
                  theme,
                ),
                _buildPriceMetric(
                  'Volume',
                  priceData.volume.toStringAsFixed(0),
                  theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceMetric(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Convert ComprehensiveTechnicalIndicators to TechnicalIndicators
  Map<String, TechnicalIndicators> _convertTechnicalIndicators(
      Map<String, ComprehensiveTechnicalIndicators> comprehensive) {
    final converted = <String, TechnicalIndicators>{};

    for (final entry in comprehensive.entries) {
      final comp = entry.value;
      converted[entry.key] = TechnicalIndicators(
        rsi: comp.rsi?.value,
        bollingerBands: comp.bollingerBands != null
            ? BollingerBands(
                upper: comp.bollingerBands!.upper,
                middle: comp.bollingerBands!.middle,
                lower: comp.bollingerBands!.lower,
                bandwidth:
                    (comp.bollingerBands!.upper - comp.bollingerBands!.lower) /
                        comp.bollingerBands!.middle,
                percentB: (comp.bollingerBands!.currentPrice -
                        comp.bollingerBands!.lower) /
                    (comp.bollingerBands!.upper - comp.bollingerBands!.lower),
              )
            : null,
        macd: comp.macd != null
            ? MACD(
                macd: comp.macd!.macd,
                signal: comp.macd!.signal,
                histogram: comp.macd!.histogram,
                trend: comp.macd!.trend ?? 'neutral',
              )
            : null,
        timestamp: DateTime.now(),
        symbol: '${widget.exchange}:${widget.pair}',
        timeframe: comp.timeframe,
      );
    }

    return converted;
  }
}
