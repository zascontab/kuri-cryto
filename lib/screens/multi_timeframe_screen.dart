import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analysis.dart';
import '../providers/analysis_provider.dart';
import '../l10n/l10n_export.dart';

/// Multi-Timeframe Analysis Screen
///
/// Displays technical analysis across multiple timeframes
/// with indicators, signals, and consensus
class MultiTimeframeScreen extends ConsumerStatefulWidget {
  const MultiTimeframeScreen({super.key});

  @override
  ConsumerState<MultiTimeframeScreen> createState() =>
      _MultiTimeframeScreenState();
}

class _MultiTimeframeScreenState extends ConsumerState<MultiTimeframeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedSymbol = 'BTCUSDT';

  final List<String> _availableSymbols = [
    'BTCUSDT',
    'ETHUSDT',
    'BNBUSDT',
    'SOLUSDT',
    'ADAUSDT',
  ];

  final List<Timeframe> _timeframes = [
    Timeframe.m1,
    Timeframe.m3,
    Timeframe.m5,
    Timeframe.m15,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _timeframes.length, vsync: this);
    // Trigger initial analysis
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performAnalysis();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _performAnalysis() {
    ref.read(multiTimeframeAnalysisNotifierProvider.notifier).analyze(
          _selectedSymbol,
          timeframes: _timeframes.map((t) => t.value).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final analysisAsync = ref.watch(multiTimeframeAnalysisNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.multiTimeframeAnalysis),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              HapticFeedback.lightImpact();
              _performAnalysis();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Symbol selector
          _buildSymbolSelector(theme, l10n),

          // Consensus panel
          analysisAsync.when(
            data: (analysis) {
              if (analysis == null) {
                return const SizedBox.shrink();
              }
              return _buildConsensusPanel(theme, l10n, analysis);
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Timeframe tabs
          Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              tabs: _timeframes.map((tf) => Tab(text: tf.value)).toList(),
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              indicatorColor: theme.colorScheme.primary,
            ),
          ),

          // Timeframe content
          Expanded(
            child: analysisAsync.when(
              data: (analysis) {
                if (analysis == null) {
                  return _buildEmptyState(theme, l10n);
                }
                return TabBarView(
                  controller: _tabController,
                  children: _timeframes.map((tf) {
                    final tfAnalysis = analysis.getTimeframe(tf.value);
                    if (tfAnalysis == null) {
                      return _buildEmptyState(theme, l10n);
                    }
                    return _buildTimeframeView(theme, l10n, tfAnalysis);
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(theme, l10n, error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolSelector(ThemeData theme, L10n l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          Text(
            l10n.symbol,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _selectedSymbol,
                isExpanded: true,
                underline: const SizedBox(),
                items: _availableSymbols.map((symbol) {
                  return DropdownMenuItem(
                    value: symbol,
                    child: Text(symbol),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSymbol = value;
                    });
                    HapticFeedback.selectionClick();
                    _performAnalysis();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsensusPanel(
    ThemeData theme,
    L10n l10n,
    MultiTimeframeAnalysis analysis,
  ) {
    final consensusSignal = SignalType.fromString(analysis.consensus.direction);
    final signalColor = _getSignalColor(consensusSignal);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.consensusSignal,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildConsensusMetric(
                  theme,
                  l10n.symbol,
                  analysis.symbol,
                ),
                _buildConsensusMetric(
                  theme,
                  l10n.signal,
                  consensusSignal.name.toUpperCase(),
                  color: signalColor,
                ),
                _buildConsensusMetric(
                  theme,
                  l10n.confidence,
                  '${analysis.consensus.confidence.toStringAsFixed(1)}%',
                  color: signalColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsensusMetric(
    ThemeData theme,
    String label,
    String value, {
    Color? color,
  }) {
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
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeframeView(
    ThemeData theme,
    L10n l10n,
    TimeframeAnalysis analysis,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Signal card
          _buildSignalCard(theme, l10n, analysis),
          const SizedBox(height: 16),

          // Indicators
          _buildIndicatorsSection(theme, l10n, analysis),
          const SizedBox(height: 16),

          // Recommendation (if available in future updates)
          // if (analysis.recommendation != null)
          //   _buildRecommendationCard(theme, l10n, analysis.recommendation!),
        ],
      ),
    );
  }

  Widget _buildSignalCard(
    ThemeData theme,
    L10n l10n,
    TimeframeAnalysis analysis,
  ) {
    final signal = SignalType.fromString(analysis.signal);
    final signalColor = _getSignalColor(signal);
    final strengthPercent = analysis.strength * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.tradingSignal,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: signalColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: signalColor, width: 2),
                      ),
                      child: Text(
                        signal.name.toUpperCase(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: signalColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      l10n.confidence,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${strengthPercent.toStringAsFixed(1)}%',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: signalColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 100,
                      child: LinearProgressIndicator(
                        value: analysis.strength,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        color: signalColor,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorsSection(
    ThemeData theme,
    L10n l10n,
    TimeframeAnalysis analysis,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.technicalIndicators,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // RSI
        if (analysis.rsi != null) ...[
          _buildIndicatorCard(
            theme,
            'RSI',
            analysis.rsi!.toStringAsFixed(2),
            _getRSIColor(analysis.rsi!),
          ),
          const SizedBox(height: 8),
        ],

        // MACD
        if (analysis.macd != null) ...[
          _buildMACDCard(theme, analysis.macd!),
          const SizedBox(height: 8),
        ],

        // Bollinger Bands
        if (analysis.bollinger != null) ...[
          _buildBollingerCard(theme, analysis.bollinger!),
        ],
      ],
    );
  }

  Widget _buildIndicatorCard(
    ThemeData theme,
    String name,
    String value,
    Color color,
  ) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              name,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(name),
        trailing: Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildMACDCard(ThemeData theme, MACDValues macd) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MACD',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMACDValue(theme, 'MACD', macd.macd),
                _buildMACDValue(theme, 'Signal', macd.signal),
                _buildMACDValue(
                  theme,
                  'Histogram',
                  macd.histogram,
                  color: macd.histogram > 0
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMACDValue(
    ThemeData theme,
    String label,
    double value, {
    Color? color,
  }) {
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
          value.toStringAsFixed(2),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildBollingerCard(ThemeData theme, BollingerBands bollinger) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bollinger Bands',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBollingerValue(theme, 'Upper', bollinger.upper),
                _buildBollingerValue(theme, 'Middle', bollinger.middle),
                _buildBollingerValue(theme, 'Lower', bollinger.lower),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBollingerValue(ThemeData theme, String label, double value) {
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
          value.toStringAsFixed(2),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, L10n l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.selectSymbolToAnalyze,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, L10n l10n, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.errorLoadingData,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _performAnalysis,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Color _getSignalColor(SignalType signal) {
    switch (signal) {
      case SignalType.buy:
        return const Color(0xFF10B981);
      case SignalType.sell:
        return const Color(0xFFEF4444);
      case SignalType.neutral:
        return const Color(0xFF6B7280);
    }
  }

  Color _getRSIColor(double rsi) {
    if (rsi >= 70) {
      return const Color(0xFFEF4444); // Overbought
    } else if (rsi <= 30) {
      return const Color(0xFF10B981); // Oversold
    } else {
      return const Color(0xFF3B82F6); // Neutral
    }
  }
}
