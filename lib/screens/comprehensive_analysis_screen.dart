import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuri_crypto/providers/comprehensive_analysis_provider.dart';
import '../providers/selected_symbol_provider.dart' as symbol_provider;
import '../models/comprehensive_analysis.dart';
import '../models/market_type.dart';
import '../models/key_levels.dart';
import '../models/futures_data.dart';
import '../models/margin_data.dart';
import '../models/options_data.dart';
import '../models/risk_assessment.dart';
import '../models/technical_indicators.dart';
import '../widgets/ai_analysis_card.dart';
import '../widgets/sentiment_indicator.dart';
import '../widgets/symbol_selector.dart';
import '../widgets/error_widgets.dart';
import '../utils/error_handler.dart';
import '../exceptions/trading_api_exceptions.dart';

/// Screen for displaying comprehensive market analysis
///
/// Shows:
/// - Current price data
/// - Technical indicators across multiple timeframes
/// - Market scenarios with probabilities
/// - AI-powered trading recommendations
class ComprehensiveAnalysisScreen extends ConsumerStatefulWidget {
  final String? initialSymbol;
  final String? initialExchange;
  final String? marketType;

  const ComprehensiveAnalysisScreen({
    super.key,
    this.initialSymbol,
    this.initialExchange,
    this.marketType,
  });

  @override
  ConsumerState<ComprehensiveAnalysisScreen> createState() =>
      _ComprehensiveAnalysisScreenState();
}

class _ComprehensiveAnalysisScreenState
    extends ConsumerState<ComprehensiveAnalysisScreen> {
  MarketType? _selectedMarketType;
  bool _enableLLM = true;
  bool _enableSentiment = true;

  @override
  void initState() {
    super.initState();
    _selectedMarketType = widget.marketType != null
        ? MarketType.fromString(widget.marketType!)
        : null;

    // Set initial symbol and exchange if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialSymbol != null) {
        ref
            .read(symbol_provider.selectedSymbolProvider.notifier)
            .setSymbol(widget.initialSymbol!);
      }
      if (widget.initialExchange != null) {
        ref
            .read(symbol_provider.selectedExchangeProvider.notifier)
            .setExchange(widget.initialExchange!);
      }
      _loadAnalysis();
    });
  }

  void _loadAnalysis() {
    final selectedSymbol = ref.read(symbol_provider.selectedSymbolProvider);
    ref
        .read(comprehensiveAnalysisNotifierProvider(selectedSymbol).notifier)
        .refresh(
          marketType: _selectedMarketType,
          enableLLM: _enableLLM,
          enableSentiment: _enableSentiment,
        );
  }

  @override
  Widget build(BuildContext context) {
    final selectedSymbol = ref.watch(symbol_provider.selectedSymbolProvider);
    final analysisAsync =
        ref.watch(comprehensiveAnalysisNotifierProvider(selectedSymbol));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Flexible(
              child: Text(
                'Análisis: $selectedSymbol',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_selectedMarketType != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _selectedMarketType!.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedMarketType!.color,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _selectedMarketType!.iconData,
                      size: 14,
                      color: _selectedMarketType!.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _selectedMarketType!.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _selectedMarketType!.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          // AI Toggle
          PopupMenuButton<String>(
            icon: Icon(
              Icons.psychology,
              color: _enableLLM || _enableSentiment
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            onSelected: (value) {
              setState(() {
                switch (value) {
                  case 'toggle_llm':
                    _enableLLM = !_enableLLM;
                    break;
                  case 'toggle_sentiment':
                    _enableSentiment = !_enableSentiment;
                    break;
                }
              });
              _loadAnalysis();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_llm',
                child: Row(
                  children: [
                    Icon(
                      _enableLLM
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Análisis LLM'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle_sentiment',
                child: Row(
                  children: [
                    Icon(
                      _enableSentiment
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Análisis de Sentimiento'),
                  ],
                ),
              ),
            ],
          ),
          // Market Type Selector
          PopupMenuButton<MarketType?>(
            icon: const Icon(Icons.category),
            onSelected: (marketType) {
              setState(() {
                _selectedMarketType = marketType;
              });
              _loadAnalysis();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive, size: 20),
                    SizedBox(width: 8),
                    Text('Todos los tipos'),
                  ],
                ),
              ),
              ...MarketType.values.map((type) => PopupMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(type.iconData, size: 20, color: type.color),
                        const SizedBox(width: 8),
                        Text(type.displayName),
                      ],
                    ),
                  )),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalysis,
          ),
        ],
      ),
      body: analysisAsync.when(
        data: (analysis) => _buildAnalysisContent(analysis, selectedSymbol),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _buildErrorDisplay(error),
      ),
    );
  }

  Widget _buildAnalysisContent(
      ComprehensiveAnalysis analysis, String selectedSymbol) {
    return RefreshIndicator(
      onRefresh: () async => _loadAnalysis(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Symbol Selector
            SymbolSelector(
              onSymbolChanged: () {
                _loadAnalysis();
              },
            ),
            const SizedBox(height: 16),

            // Price Data Section
            _buildPriceDataSection(analysis.priceData),
            const SizedBox(height: 24),

            // AI Analysis Section (if available)
            if (analysis.hasLLMAnalysis || analysis.hasSentimentAnalysis)
              _buildAIAnalysisSection(analysis),
            if (analysis.hasLLMAnalysis || analysis.hasSentimentAnalysis)
              const SizedBox(height: 24),

            // Key Levels Section
            if (analysis.keyLevels != null) ...[
              _buildKeyLevelsSection(analysis.keyLevels!),
              const SizedBox(height: 24),
            ],

            // Recent Movement Chart
            if (analysis.recentMovement != null &&
                analysis.recentMovement!.isNotEmpty) ...[
              _buildRecentMovementSection(analysis.recentMovement!),
              const SizedBox(height: 24),
            ],

            // Multi-Timeframe Technical Indicators
            _buildMultiTimeframeSection(_convertTechnicalIndicators(
                analysis.technicalIndicators, selectedSymbol)),
            const SizedBox(height: 24),

            // Market Type Specific Data
            if (_selectedMarketType != null) ...[
              _buildMarketTypeSpecificSection(analysis),
              const SizedBox(height: 24),
            ],

            // Scenarios Section
            _buildScenariosSection(analysis.scenarios),
            const SizedBox(height: 24),

            // Risk Assessment
            if (analysis.riskAssessment != null) ...[
              _buildRiskAssessmentSection(analysis.riskAssessment!),
              const SizedBox(height: 24),
            ],

            // Recommendation Section
            _buildRecommendationSection(analysis.recommendation),
          ],
        ),
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

  Widget _buildAIAnalysisSection(ComprehensiveAnalysis analysis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (analysis.hasLLMAnalysis)
          AIAnalysisCard(
            recommendation: analysis.recommendation,
            llmAnalysis: analysis.llmAnalysis,
            sentimentAnalysis: analysis.sentimentAnalysis,
          ),
        if (analysis.hasSentimentAnalysis && !analysis.hasLLMAnalysis) ...[
          const SizedBox(height: 16),
          SentimentIndicator(sentiment: analysis.sentimentAnalysis!),
        ],
      ],
    );
  }

  Widget _buildKeyLevelsSection(KeyLevels keyLevels) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Niveles Clave',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildLevelCard(
                    'Soporte',
                    keyLevels.support,
                    Colors.green,
                    Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLevelCard(
                    'Resistencia',
                    keyLevels.resistance,
                    Colors.red,
                    Icons.trending_down,
                  ),
                ),
              ],
            ),
            if (keyLevels.distance != null) ...[
              const SizedBox(height: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Distancia al soporte: ${keyLevels.distance!.toSupportPercent.toStringAsFixed(2)}%',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 2,
                  ),
                  Text(
                    'Distancia a resistencia: ${keyLevels.distance!.toResistancePercent.toStringAsFixed(2)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(
      String label, double value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${value.toStringAsFixed(4)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMovementSection(List<PricePoint> recentMovement) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Movimiento Reciente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildSimpleChart(recentMovement),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleChart(List<PricePoint> points) {
    if (points.isEmpty) return const Center(child: Text('No hay datos'));

    final minPrice = points.map((p) => p.price).reduce((a, b) => a < b ? a : b);
    final maxPrice = points.map((p) => p.price).reduce((a, b) => a > b ? a : b);
    final priceRange = maxPrice - minPrice;

    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: SimpleChartPainter(
        points: points,
        minPrice: minPrice,
        maxPrice: maxPrice,
        priceRange: priceRange,
      ),
    );
  }

  Widget _buildMultiTimeframeSection(
      Map<String, TechnicalIndicators> indicators) {
    if (indicators.isEmpty) {
      return const SizedBox.shrink();
    }

    // Ordenar timeframes
    final sortedTimeframes = indicators.keys.toList()
      ..sort((a, b) {
        final order = {'1m': 1, '5m': 2, '15m': 3, '1h': 4, '4h': 5, '1d': 6};
        return (order[a] ?? 99).compareTo(order[b] ?? 99);
      });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'X Análisis Multi-Temporalidad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...sortedTimeframes.map((timeframe) {
              final indicator = indicators[timeframe]!;
              return _buildTimeframeRow(timeframe, indicator);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeframeRow(String timeframe, TechnicalIndicators indicators) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            timeframe.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (indicators.rsi != null)
                Expanded(
                  child: _buildIndicatorChip(
                    'RSI',
                    indicators.rsi!.toStringAsFixed(1),
                    _getRSIColor(indicators.rsi!),
                  ),
                ),
              if (indicators.macd != null)
                Expanded(
                  child: _buildIndicatorChip(
                    'MACD',
                    indicators.macd!.trend,
                    _getTrendColor(indicators.macd!.trend),
                  ),
                ),
              if (indicators.bollingerBands != null)
                Expanded(
                  child: _buildIndicatorChip(
                    'BB',
                    indicators.bollingerBands!.signal,
                    _getTrendColor(indicators.bollingerBands!.signal),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorChip(String name, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketTypeSpecificSection(ComprehensiveAnalysis analysis) {
    if (_selectedMarketType == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_selectedMarketType!.iconData,
                    color: _selectedMarketType!.color),
                const SizedBox(width: 8),
                Text(
                  'Datos de ${_selectedMarketType!.displayName}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedMarketType == MarketType.futures &&
                analysis.futuresData != null)
              _buildFuturesData(analysis.futuresData!),
            if (_selectedMarketType == MarketType.margin &&
                analysis.marginData != null)
              _buildMarginData(analysis.marginData!),
            if (_selectedMarketType == MarketType.options &&
                analysis.optionsData != null)
              _buildOptionsData(analysis.optionsData!),
          ],
        ),
      ),
    );
  }

  Widget _buildFuturesData(FuturesData futuresData) {
    return Column(
      children: [
        _buildDataRow('Funding Rate',
            '${(futuresData.fundingRate * 100).toStringAsFixed(4)}%'),
        _buildDataRow(
            'Mark Price', '\$${futuresData.markPrice.toStringAsFixed(4)}'),
        if (futuresData.liquidationPrice != null)
          _buildDataRow('Liquidation Price',
              '\$${futuresData.liquidationPrice!.toStringAsFixed(4)}'),
        _buildDataRow(
            'Open Interest', futuresData.openInterest.toStringAsFixed(2)),
      ],
    );
  }

  Widget _buildMarginData(MarginData marginData) {
    return Column(
      children: [
        _buildDataRow('Interest Rate',
            '${(marginData.interestRate * 100).toStringAsFixed(4)}%'),
        _buildDataRow('Margin Level',
            '${(marginData.marginLevel * 100).toStringAsFixed(2)}%'),
        _buildDataRow(
            'Borrowed Amount', marginData.borrowedAmount.toStringAsFixed(4)),
      ],
    );
  }

  Widget _buildOptionsData(OptionsData optionsData) {
    return Column(
      children: [
        _buildDataRow('Implied Volatility',
            '${(optionsData.impliedVolatility * 100).toStringAsFixed(2)}%'),
        if (optionsData.greeks != null) ...[
          _buildDataRow('Delta', optionsData.greeks!.delta.toStringAsFixed(4)),
          _buildDataRow('Gamma', optionsData.greeks!.gamma.toStringAsFixed(4)),
          _buildDataRow('Theta', optionsData.greeks!.theta.toStringAsFixed(4)),
          _buildDataRow('Vega', optionsData.greeks!.vega.toStringAsFixed(4)),
        ],
      ],
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRiskAssessmentSection(RiskAssessment riskAssessment) {
    final riskColor = _getRiskColor(riskAssessment.level);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: riskColor),
                const SizedBox(width: 8),
                const Text(
                  'Evaluación de Riesgo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: riskColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: riskColor.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          riskAssessment.level.toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: riskColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Score: ${riskAssessment.score.toStringAsFixed(0)}/100',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Factores de Riesgo:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      ...riskAssessment.factors.map((factor) => Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber,
                                    size: 14, color: Colors.orange),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    factor,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRSIColor(double rsi) {
    if (rsi > 70) return Colors.red;
    if (rsi < 30) return Colors.green;
    return Colors.orange;
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'bullish':
        return Colors.green;
      case 'bearish':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getRiskColor(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Builds error display with appropriate error widgets
  Widget _buildErrorDisplay(dynamic error) {
    // Check if it's a network error
    if (error is NetworkException ||
        error.toString().toLowerCase().contains('network') ||
        error.toString().toLowerCase().contains('connection')) {
      return ErrorWidgets.networkError(
        onRetry: _loadAnalysis,
        message: getErrorMessage(error),
      );
    }

    // Check if it's a server error
    if (error is ServerException ||
        error.toString().contains('500') ||
        error.toString().contains('502') ||
        error.toString().contains('503')) {
      return ErrorWidgets.serverError(
        onRetry: _loadAnalysis,
        message: getErrorMessage(error),
      );
    }

    // Generic error card for other errors
    return ErrorWidgets.errorCard(
      error: error,
      onRetry: _loadAnalysis,
      title: 'Error al cargar análisis',
    );
  }

  /// Convert ComprehensiveTechnicalIndicators to TechnicalIndicators
  Map<String, TechnicalIndicators> _convertTechnicalIndicators(
      Map<String, ComprehensiveTechnicalIndicators> comprehensive,
      String selectedSymbol) {
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
                trend: comp.macd!.trend,
              )
            : null,
        timestamp: DateTime.now(),
        symbol: selectedSymbol,
        timeframe: comp.timeframe,
      );
    }

    return converted;
  }
}

// Simple chart painter for recent movement
class SimpleChartPainter extends CustomPainter {
  final List<PricePoint> points;
  final double minPrice;
  final double maxPrice;
  final double priceRange;

  SimpleChartPainter({
    required this.points,
    required this.minPrice,
    required this.maxPrice,
    required this.priceRange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || priceRange == 0) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height -
          ((points[i].price - minPrice) / priceRange) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height -
          ((points[i].price - minPrice) / priceRange) * size.height;
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
