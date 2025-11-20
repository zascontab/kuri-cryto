import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/l10n_export.dart';
import '../config/app_theme.dart';
import '../models/comprehensive_analysis.dart';
import '../providers/comprehensive_analysis_provider.dart';

/// Comprehensive Analysis Screen - Complete market analysis with AI
///
/// Features:
/// - Symbol selector and refresh button
/// - Price header with 24h statistics
/// - Technical indicators (RSI, MACD, Bollinger, EMA)
/// - Multi-timeframe analysis (1m, 5m, 15m, 1h)
/// - Trading recommendation with confidence
/// - Possible market scenarios with probabilities
/// - Risk assessment
class ComprehensiveAnalysisScreen extends ConsumerStatefulWidget {
  const ComprehensiveAnalysisScreen({super.key});

  @override
  ConsumerState<ComprehensiveAnalysisScreen> createState() =>
      _ComprehensiveAnalysisScreenState();
}

class _ComprehensiveAnalysisScreenState
    extends ConsumerState<ComprehensiveAnalysisScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final selectedSymbol = ref.watch(selectedSymbolProvider);
    final analysisAsync = ref.watch(comprehensiveAnalysisNotifierProvider(selectedSymbol));
    final availableSymbols = ref.watch(availableSymbolsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analysisTitle),
        actions: [
          PopupMenuButton<String>(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedSymbol,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
            onSelected: (symbol) {
              ref.read(selectedSymbolProvider.notifier).setSymbol(symbol);
            },
            itemBuilder: (context) {
              return availableSymbols.map((symbol) {
                return PopupMenuItem(
                  value: symbol,
                  child: Row(
                    children: [
                      if (symbol == selectedSymbol)
                        const Icon(Icons.check, size: 20)
                      else
                        const SizedBox(width: 20),
                      const SizedBox(width: 8),
                      Text(symbol),
                    ],
                  ),
                );
              }).toList();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(comprehensiveAnalysisNotifierProvider(selectedSymbol).notifier).refresh();
            },
          ),
        ],
      ),
      body: analysisAsync.when(
        data: (analysis) => RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(comprehensiveAnalysisNotifierProvider(selectedSymbol).notifier)
                .refresh();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Price Header
              _PriceHeaderWidget(analysis: analysis),
              const SizedBox(height: 16),

              // Technical Indicators
              _TechnicalIndicatorsWidget(analysis: analysis),
              const SizedBox(height: 16),

              // Multi-Timeframe Analysis
              _MultiTimeframeWidget(analysis: analysis),
              const SizedBox(height: 16),

              // Recommendation
              _RecommendationWidget(analysis: analysis),
              const SizedBox(height: 16),

              // Scenarios
              _ScenariosWidget(analysis: analysis),
              const SizedBox(height: 16),

              // Risk Assessment
              _RiskAssessmentWidget(analysis: analysis),
              const SizedBox(height: 80),
            ],
          ),
        ),
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                l10n.analysisLoading,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: AppTheme.lossRed, size: 64),
                const SizedBox(height: 16),
                Text(
                  '${l10n.error}: ${e.toString()}',
                  style: const TextStyle(color: AppTheme.lossRed),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(comprehensiveAnalysisNotifierProvider(selectedSymbol).notifier).refresh();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Price Header Widget - Shows current price and 24h statistics
class _PriceHeaderWidget extends StatelessWidget {
  final ComprehensiveAnalysis analysis;

  const _PriceHeaderWidget({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = analysis.currentPrice;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  analysis.symbol,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: price.isPositiveChange
                        ? AppTheme.profitGreen.withOpacity(0.2)
                        : AppTheme.lossRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${price.isPositiveChange ? '+' : ''}${price.change24h.toStringAsFixed(2)}%',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: price.isPositiveChange
                          ? AppTheme.profitGreen
                          : AppTheme.lossRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '\$${price.current.toStringAsFixed(4)}',
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPriceStat('High 24h', price.high24h, theme),
                _buildPriceStat('Low 24h', price.low24h, theme),
                _buildPriceStat('Volume', price.volume24h, theme, isVolume: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceStat(String label, double value, ThemeData theme,
      {bool isVolume = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isVolume
              ? '\$${(value / 1000000).toStringAsFixed(2)}M'
              : '\$${value.toStringAsFixed(4)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Technical Indicators Widget
class _TechnicalIndicatorsWidget extends StatelessWidget {
  final ComprehensiveAnalysis analysis;

  const _TechnicalIndicatorsWidget({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final tech = analysis.technicalAnalysis;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.analysisTechnical,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildIndicatorRow('RSI', tech.rsi.value.toStringAsFixed(1),
                tech.rsi.signal, theme, l10n),
            const Divider(height: 24),
            _buildIndicatorRow('MACD', tech.macd.histogram.toStringAsFixed(4),
                tech.macd.trend, theme, l10n),
            const Divider(height: 24),
            _buildIndicatorRow(
                'Bollinger', tech.bollinger.position, '', theme, l10n),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Trend'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getTrendColor(tech.trend).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    tech.trend.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: _getTrendColor(tech.trend),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorRow(String name, String value, String signal,
      ThemeData theme, dynamic l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, style: theme.textTheme.bodyLarge),
        Row(
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (signal.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSignalColor(signal).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _translateSignal(signal, l10n),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getSignalColor(signal),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'bullish':
        return AppTheme.profitGreen;
      case 'bearish':
        return AppTheme.lossRed;
      default:
        return AppTheme.neutralGray;
    }
  }

  Color _getSignalColor(String signal) {
    switch (signal.toLowerCase()) {
      case 'oversold':
        return AppTheme.profitGreen;
      case 'overbought':
        return AppTheme.lossRed;
      case 'bullish':
        return AppTheme.profitGreen;
      case 'bearish':
        return AppTheme.lossRed;
      default:
        return AppTheme.neutralGray;
    }
  }

  String _translateSignal(String signal, dynamic l10n) {
    switch (signal.toLowerCase()) {
      case 'oversold':
        return l10n.analysisOversold;
      case 'overbought':
        return l10n.analysisOverbought;
      case 'bullish':
        return l10n.analysisBullish;
      case 'bearish':
        return l10n.analysisBearish;
      case 'neutral':
        return l10n.analysisNeutral;
      default:
        return signal;
    }
  }
}

/// Multi-Timeframe Widget
class _MultiTimeframeWidget extends StatelessWidget {
  final ComprehensiveAnalysis analysis;

  const _MultiTimeframeWidget({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final mtf = analysis.multiTimeframe;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.analysisMultiTimeframe,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getAlignmentColor(mtf.alignment).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    mtf.isAligned ? 'ALIGNED' : 'NOT ALIGNED',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getAlignmentColor(mtf.alignment),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTimeframeRow('1m', mtf.oneMinute, theme),
            const Divider(height: 16),
            _buildTimeframeRow('5m', mtf.fiveMinutes, theme),
            const Divider(height: 16),
            _buildTimeframeRow('15m', mtf.fifteenMinutes, theme),
            const Divider(height: 16),
            _buildTimeframeRow('1h', mtf.oneHour, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeframeRow(String tf, TimeframeData data, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 40,
          child: Text(
            tf,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTrendColor(data.trend).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  data.trend.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getTrendColor(data.trend),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'RSI: ${data.rsi.toStringAsFixed(0)}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'bullish':
        return AppTheme.profitGreen;
      case 'bearish':
        return AppTheme.lossRed;
      default:
        return AppTheme.neutralGray;
    }
  }

  Color _getAlignmentColor(String alignment) {
    if (alignment.contains('bullish')) return AppTheme.profitGreen;
    if (alignment.contains('bearish')) return AppTheme.lossRed;
    return AppTheme.neutralGray;
  }
}

/// Recommendation Widget
class _RecommendationWidget extends StatelessWidget {
  final ComprehensiveAnalysis analysis;

  const _RecommendationWidget({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final rec = analysis.recommendation;

    return Card(
      color: _getActionColor(rec.action).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.analysisRecommendation,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getActionColor(rec.action),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    rec.action,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '${l10n.analysisConfidence}: ',
                  style: theme.textTheme.bodyLarge,
                ),
                Text(
                  '${(rec.confidence * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getActionColor(rec.action),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriceLevel(l10n.analysisEntry, rec.entryPrice, theme),
                _buildPriceLevel(l10n.analysisStopLoss, rec.stopLoss, theme),
                _buildPriceLevel(l10n.analysisTakeProfit, rec.takeProfit, theme),
              ],
            ),
            if (rec.reasoning.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Reasoning:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...rec.reasoning.map((reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(reason)),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceLevel(String label, double price, ThemeData theme) {
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
          '\$${price.toStringAsFixed(4)}',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getActionColor(String action) {
    switch (action.toUpperCase()) {
      case 'BUY':
        return AppTheme.profitGreen;
      case 'SELL':
        return AppTheme.lossRed;
      default:
        return AppTheme.warningYellow;
    }
  }
}

/// Scenarios Widget
class _ScenariosWidget extends StatelessWidget {
  final ComprehensiveAnalysis analysis;

  const _ScenariosWidget({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.analysisScenarios,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...analysis.scenarios.map((scenario) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildScenarioCard(scenario, theme),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioCard(MarketScenario scenario, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getImpactColor(scenario.impact).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getImpactColor(scenario.impact).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  scenario.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${(scenario.probability * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: _getImpactColor(scenario.impact),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            scenario.description,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Target: \$${scenario.targetPrice.toStringAsFixed(4)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${scenario.changePercent >= 0 ? '+' : ''}${scenario.changePercent.toStringAsFixed(2)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scenario.changePercent >= 0
                      ? AppTheme.profitGreen
                      : AppTheme.lossRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                scenario.timeframe,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getImpactColor(String impact) {
    switch (impact.toLowerCase()) {
      case 'positive':
        return AppTheme.profitGreen;
      case 'negative':
        return AppTheme.lossRed;
      default:
        return AppTheme.neutralGray;
    }
  }
}

/// Risk Assessment Widget
class _RiskAssessmentWidget extends StatelessWidget {
  final ComprehensiveAnalysis analysis;

  const _RiskAssessmentWidget({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final risk = analysis.riskAssessment;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.analysisRisk,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getRiskColor(risk.level).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _translateRiskLevel(risk.level, l10n).toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: _getRiskColor(risk.level),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Risk Score: ',
                  style: theme.textTheme.bodyLarge,
                ),
                Text(
                  '${risk.score.toStringAsFixed(0)}/100',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getRiskColor(risk.level),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: risk.score / 100,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(_getRiskColor(risk.level)),
            ),
            const SizedBox(height: 16),
            Text(
              'Volatility: ${risk.volatility.toUpperCase()}',
              style: theme.textTheme.bodyMedium,
            ),
            if (risk.factors.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Risk Factors:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...risk.factors.map((factor) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(factor)),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Color _getRiskColor(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return AppTheme.profitGreen;
      case 'medium':
        return AppTheme.warningYellow;
      case 'high':
        return AppTheme.lossRed;
      default:
        return AppTheme.neutralGray;
    }
  }

  String _translateRiskLevel(String level, dynamic l10n) {
    switch (level.toLowerCase()) {
      case 'low':
        return l10n.analysisLowRisk;
      case 'medium':
        return l10n.analysisMediumRisk;
      case 'high':
        return l10n.analysisHighRisk;
      default:
        return level;
    }
  }
}
