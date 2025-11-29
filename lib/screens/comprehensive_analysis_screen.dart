import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/comprehensive_analysis.dart';
import '../models/market_type.dart';
import '../providers/ai_bot_provider.dart';

/// Screen for displaying comprehensive market analysis
///
/// Shows:
/// - Current price data
/// - Technical indicators across multiple timeframes
/// - Market scenarios with probabilities
/// - AI-powered trading recommendations
class ComprehensiveAnalysisScreen extends ConsumerStatefulWidget {
  final String symbol;
  final String exchange;
  final String? marketType;

  const ComprehensiveAnalysisScreen({
    super.key,
    required this.symbol,
    this.exchange = 'kucoin',
    this.marketType,
  });

  @override
  ConsumerState<ComprehensiveAnalysisScreen> createState() =>
      _ComprehensiveAnalysisScreenState();
}

class _ComprehensiveAnalysisScreenState
    extends ConsumerState<ComprehensiveAnalysisScreen> {
  @override
  void initState() {
    super.initState();
    // Load analysis on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalysis();
    });
  }

  void _loadAnalysis() {
    ref.read(comprehensiveAnalysisNotifierProvider.notifier).loadAnalysis(
          symbol: widget.symbol,
          exchange: widget.exchange,
          marketType: widget.marketType,
        );
  }

  @override
  Widget build(BuildContext context) {
    final analysisAsync = ref.watch(comprehensiveAnalysisNotifierProvider);

    final marketType = widget.marketType != null
        ? MarketType.fromString(widget.marketType!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Flexible(
              child: Text(
                'Análisis: ${widget.symbol}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (marketType != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: marketType.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: marketType.color,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      marketType.iconData,
                      size: 14,
                      color: marketType.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      marketType.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: marketType.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalysis,
          ),
        ],
      ),
      body: analysisAsync.when(
        data: (analysis) {
          if (analysis == null) {
            return const Center(
              child: Text('No hay análisis disponible'),
            );
          }
          return _buildAnalysisContent(analysis);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAnalysis,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisContent(ComprehensiveAnalysis analysis) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPriceDataSection(analysis.priceData),
          const SizedBox(height: 24),
          _buildTechnicalIndicatorsSection(analysis.technicalIndicators),
          const SizedBox(height: 24),
          _buildScenariosSection(analysis.scenarios),
          const SizedBox(height: 24),
          _buildRecommendationSection(analysis.recommendation),
        ],
      ),
    );
  }

  Widget _buildPriceDataSection(PriceData priceData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datos de Precio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPriceRow('Último', '\$${priceData.last.toStringAsFixed(4)}'),
            _buildPriceRow('Bid', '\$${priceData.bid.toStringAsFixed(4)}'),
            _buildPriceRow('Ask', '\$${priceData.ask.toStringAsFixed(4)}'),
            _buildPriceRow('Volumen', priceData.volume.toStringAsFixed(2)),
            _buildPriceRow(
                'Alto 24h', '\$${priceData.high24h.toStringAsFixed(4)}'),
            _buildPriceRow(
                'Bajo 24h', '\$${priceData.low24h.toStringAsFixed(4)}'),
            _buildPriceRow(
              'Cambio 24h',
              '${priceData.changePercent24h >= 0 ? '+' : ''}${priceData.changePercent24h.toStringAsFixed(2)}%',
              color: priceData.isRising ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalIndicatorsSection(
    Map<String, TechnicalIndicators> indicators,
  ) {
    if (indicators.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Indicadores Técnicos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...indicators.entries.map((entry) {
              return _buildTimeframeIndicators(entry.key, entry.value);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeframeIndicators(
    String timeframe,
    TechnicalIndicators indicators,
  ) {
    return ExpansionTile(
      title: Text(timeframe.toUpperCase()),
      children: [
        if (indicators.rsi != null)
          _buildIndicatorRow(
            'RSI',
            indicators.rsi!.value.toStringAsFixed(2),
            indicators.rsi!.signal,
          ),
        if (indicators.macd != null)
          _buildIndicatorRow(
            'MACD',
            indicators.macd!.histogram.toStringAsFixed(4),
            indicators.macd!.trend,
          ),
        if (indicators.bollingerBands != null)
          _buildIndicatorRow(
            'Bollinger',
            indicators.bollingerBands!.position,
            '',
          ),
        if (indicators.ema != null)
          _buildIndicatorRow(
            'EMA',
            indicators.ema!.trend,
            '',
          ),
      ],
    );
  }

  Widget _buildIndicatorRow(String name, String value, String signal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Row(
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (signal.isNotEmpty) ...[
                const SizedBox(width: 8),
                Chip(
                  label: Text(signal, style: const TextStyle(fontSize: 12)),
                  padding: EdgeInsets.zero,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScenariosSection(Map<String, Scenario> scenarios) {
    if (scenarios.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escenarios de Mercado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...scenarios.entries.map((entry) {
              return _buildScenarioCard(entry.value);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioCard(Scenario scenario) {
    Color color;
    IconData icon;

    switch (scenario.type.toLowerCase()) {
      case 'bullish':
        color = Colors.green;
        icon = Icons.trending_up;
        break;
      case 'bearish':
        color = Colors.red;
        icon = Icons.trending_down;
        break;
      default:
        color = Colors.grey;
        icon = Icons.trending_flat;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  scenario.type.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(scenario.probability * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(scenario.description),
            if (scenario.conditions.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...scenario.conditions.map((condition) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(condition,
                              style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationSection(Recommendation recommendation) {
    Color actionColor;
    IconData actionIcon;

    switch (recommendation.action) {
      case 'BUY':
        actionColor = Colors.green;
        actionIcon = Icons.arrow_upward;
        break;
      case 'SELL':
        actionColor = Colors.red;
        actionIcon = Icons.arrow_downward;
        break;
      default:
        actionColor = Colors.grey;
        actionIcon = Icons.pause;
    }

    return Card(
      color: actionColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(actionIcon, color: actionColor, size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.action,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: actionColor,
                      ),
                    ),
                    Text(
                      'Confianza: ${(recommendation.confidence * 100).toStringAsFixed(0)}%',
                      style: TextStyle(color: actionColor),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recommendation.entry != null)
              _buildRecommendationRow(
                  'Entrada', '\$${recommendation.entry!.toStringAsFixed(4)}'),
            if (recommendation.stopLoss != null)
              _buildRecommendationRow('Stop Loss',
                  '\$${recommendation.stopLoss!.toStringAsFixed(4)}'),
            if (recommendation.takeProfit != null)
              _buildRecommendationRow('Take Profit',
                  '\$${recommendation.takeProfit!.toStringAsFixed(4)}'),
            if (recommendation.riskRewardRatio != null)
              _buildRecommendationRow('R:R',
                  '1:${recommendation.riskRewardRatio!.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            const Text(
              'Razonamiento:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ...recommendation.reasoning.map((reason) {
              return Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(reason)),
                  ],
                ),
              );
            }),
            if (recommendation.risks.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Riesgos:',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              const SizedBox(height: 4),
              ...recommendation.risks.map((risk) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber,
                          size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(child: Text(risk)),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
