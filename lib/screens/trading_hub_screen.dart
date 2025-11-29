import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';
import '../providers/ai_bot_provider.dart';
import '../providers/market_provider.dart';
import 'comprehensive_analysis_screen.dart';
import 'ai_bot_control_screen.dart';
import 'futures_positions_screen.dart';

import '../models/market_type.dart';

/// Trading Hub - Unified trading interface with quick access to all features
///
/// Features:
/// - Quick pair/exchange/timeframe selector
/// - Live market data with real-time updates
/// - One-tap access to analysis, bot control, positions
/// - Contextual actions based on market conditions
/// - Gesture-based navigation
class TradingHubScreen extends ConsumerStatefulWidget {
  const TradingHubScreen({super.key});

  @override
  ConsumerState<TradingHubScreen> createState() => _TradingHubScreenState();
}

class _TradingHubScreenState extends ConsumerState<TradingHubScreen>
    with SingleTickerProviderStateMixin {
  // Current selections
  String _selectedPair = 'BTC-USDT';
  String _selectedExchange = 'kucoin';
  String _selectedTimeframe = '1h';
  MarketType _selectedMarketType = MarketType.futures;

  // Get market type value for API calls
  String get _marketTypeValue => _selectedMarketType.value;

  // Available timeframes
  final List<String> _timeframes = [
    '1m',
    '5m',
    '15m',
    '1h',
    '4h',
    '1d',
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onPairSelected(String pair) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedPair = pair;
    });
  }

  void _onTimeframeSelected(String timeframe) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedTimeframe = timeframe;
    });
  }

  void _showPairSelector() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PairSelectorSheetWithProvider(
        selectedPair: _selectedPair,
        exchange: _selectedExchange,
        marketType: _selectedMarketType,
        onPairSelected: (pair) {
          _onPairSelected(pair);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showExchangeSelector() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      builder: (context) => _ExchangeSelectorSheet(
        selectedExchange: _selectedExchange,
        onExchangeSelected: (exchange) {
          setState(() {
            _selectedExchange = exchange;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showMarketTypeSelector() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MarketTypeSelectorSheet(
        selectedMarketType: _selectedMarketType,
        onMarketTypeSelected: (marketType) {
          setState(() {
            _selectedMarketType = marketType;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final botStatus = ref.watch(aiBotStatusNotifierProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with context selector
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.7),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Pair Selector
                        GestureDetector(
                          onTap: _showPairSelector,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _selectedPair,
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Market Type, Exchange & Timeframe
                        Row(
                          children: [
                            // Market Type Selector with Enhanced Visual
                            GestureDetector(
                              onTap: _showMarketTypeSelector,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedMarketType.color
                                      .withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.8),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _selectedMarketType.color
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _selectedMarketType.iconData,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _selectedMarketType.displayName,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Exchange Selector
                            GestureDetector(
                              onTap: _showExchangeSelector,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.swap_horiz,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _selectedExchange.toUpperCase(),
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Timeframe chips
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _timeframes.map((tf) {
                                    final isSelected = tf == _selectedTimeframe;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: GestureDetector(
                                        onTap: () => _onTimeframeSelected(tf),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.white
                                                    .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            tf,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: isSelected
                                                  ? theme.colorScheme.primary
                                                  : Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Quick Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: QuickActionButton(
                          icon: Icons.insights,
                          label: 'Analysis',
                          color: AppTheme.profitGreen,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ComprehensiveAnalysisScreen(
                                  symbol: _selectedPair,
                                  exchange: _selectedExchange,
                                  marketType: _marketTypeValue,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuickActionButton(
                          icon: Icons.smart_toy,
                          label: 'AI Bot',
                          color: Colors.blue,
                          badge: botStatus.maybeWhen(
                            data: (status) => status.running ? 'ON' : null,
                            orElse: () => null,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AiBotControlScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuickActionButton(
                          icon: Icons.account_balance,
                          label: 'Positions',
                          color: Colors.orange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const FuturesPositionsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Market Overview Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _MarketOverviewCard(
                pair: _selectedPair,
                exchange: _selectedExchange,
                timeframe: _selectedTimeframe,
              ),
            ),
          ),

          // Tabs for different views
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Signals'),
                  Tab(text: 'Indicators'),
                  Tab(text: 'News'),
                ],
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _SignalsView(
                  pair: _selectedPair,
                  exchange: _selectedExchange,
                ),
                _IndicatorsView(
                  pair: _selectedPair,
                  timeframe: _selectedTimeframe,
                ),
                _NewsView(pair: _selectedPair),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick Action Button Widget
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 32),
                if (badge != null)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.profitGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Market Overview Card
class _MarketOverviewCard extends StatelessWidget {
  final String pair;
  final String exchange;
  final String timeframe;

  const _MarketOverviewCard({
    required this.pair,
    required this.exchange,
    required this.timeframe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Market Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.profitGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.profitGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.profitGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Price display
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$50,234.56',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.profitGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+2.45%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Quick stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _QuickStat(
                  label: '24h High',
                  value: '\$51,200',
                  theme: theme,
                ),
                _QuickStat(
                  label: '24h Low',
                  value: '\$49,100',
                  theme: theme,
                ),
                _QuickStat(
                  label: 'Volume',
                  value: '2.4B',
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _QuickStat({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
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
          ),
        ),
      ],
    );
  }
}

/// Signals View
class _SignalsView extends StatelessWidget {
  final String pair;
  final String exchange;

  const _SignalsView({
    required this.pair,
    required this.exchange,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SignalCard(
          type: 'BUY',
          confidence: 0.85,
          reason: 'RSI oversold + MACD bullish crossover',
          timeframe: '1h',
        ),
        const SizedBox(height: 12),
        _SignalCard(
          type: 'WAIT',
          confidence: 0.60,
          reason: 'Mixed signals across timeframes',
          timeframe: '15m',
        ),
      ],
    );
  }
}

class _SignalCard extends StatelessWidget {
  final String type;
  final double confidence;
  final String reason;
  final String timeframe;

  const _SignalCard({
    required this.type,
    required this.confidence,
    required this.reason,
    required this.timeframe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = type == 'BUY'
        ? AppTheme.profitGreen
        : type == 'SELL'
            ? AppTheme.lossRed
            : AppTheme.warningYellow;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    type,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${(confidence * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              reason,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  timeframe,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Indicators View
class _IndicatorsView extends StatelessWidget {
  final String pair;
  final String timeframe;

  const _IndicatorsView({
    required this.pair,
    required this.timeframe,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Indicators View - Coming Soon'),
    );
  }
}

/// News View
class _NewsView extends StatelessWidget {
  final String pair;

  const _NewsView({required this.pair});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('News View - Coming Soon'),
    );
  }
}

/// Pair Selector Bottom Sheet with Provider
class _PairSelectorSheetWithProvider extends ConsumerWidget {
  final String selectedPair;
  final String exchange;
  final MarketType marketType;
  final Function(String) onPairSelected;

  const _PairSelectorSheetWithProvider({
    required this.selectedPair,
    required this.exchange,
    required this.marketType,
    required this.onPairSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Get pairs from provider based on market type
    final pairsAsync = ref.watch(
      availablePairsProvider(
        marketType: marketType,
        exchange: exchange,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Select Trading Pair',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  marketType.displayName,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Show pairs from provider
          pairsAsync.when(
            data: (pairs) {
              if (pairs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No pairs available',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: pairs.take(10).map((pair) {
                  final isSelected = pair == selectedPair;
                  return ListTile(
                    leading: Icon(
                      Icons.currency_bitcoin,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                    title: Text(
                      pair,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? theme.colorScheme.primary : null,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                    onTap: () => onPairSelected(pair),
                  );
                }).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error loading pairs',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Exchange Selector Bottom Sheet
class _ExchangeSelectorSheet extends StatelessWidget {
  final String selectedExchange;
  final Function(String) onExchangeSelected;

  const _ExchangeSelectorSheet({
    required this.selectedExchange,
    required this.onExchangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exchanges = ['kucoin', 'binance', 'bybit'];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Select Exchange',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...exchanges.map((exchange) {
            final isSelected = exchange == selectedExchange;
            return ListTile(
              leading: Icon(
                Icons.swap_horiz,
                color: isSelected ? theme.colorScheme.primary : null,
              ),
              title: Text(
                exchange.toUpperCase(),
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? theme.colorScheme.primary : null,
                ),
              ),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                    )
                  : null,
              onTap: () => onExchangeSelected(exchange),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Market Type Selector Bottom Sheet
class _MarketTypeSelectorSheet extends StatelessWidget {
  final MarketType selectedMarketType;
  final Function(MarketType) onMarketTypeSelected;

  const _MarketTypeSelectorSheet({
    required this.selectedMarketType,
    required this.onMarketTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Select Market Type',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Choose the type of market you want to trade',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...MarketType.values.map((marketType) {
            final isSelected = marketType == selectedMarketType;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? marketType.color.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? marketType.color
                      : theme.colorScheme.outline.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: marketType.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    marketType.iconData,
                    color: marketType.color,
                    size: 24,
                  ),
                ),
                title: Text(
                  marketType.displayName,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? marketType.color : null,
                  ),
                ),
                subtitle: Text(
                  marketType.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: marketType.color,
                      )
                    : null,
                onTap: () => onMarketTypeSelected(marketType),
              ),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
