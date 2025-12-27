import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/l10n_export.dart';
import '../models/market_type.dart';
import '../providers/market_provider.dart';
import 'mcp_signals_screen.dart';
import 'comprehensive_analysis_screen.dart';

/// MCP Trading main screen with tabs for Overview, Signals, and Portfolio
class MCPMainScreen extends ConsumerStatefulWidget {
  const MCPMainScreen({super.key});

  @override
  ConsumerState<MCPMainScreen> createState() => _MCPMainScreenState();
}

class _MCPMainScreenState extends ConsumerState<MCPMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedExchange = 'kucoin';
  String _selectedPair = 'BTC-USDT';
  final MarketType _selectedMarketType = MarketType.futures;

  final List<String> _exchanges = ['kucoin', 'binance', 'bybit'];

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

  Future<void> _onRefresh() async {
    // Refresh all providers
    ref.invalidate(availablePairsProvider);
    // Refresh other relevant providers as needed
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MCP Trading'),
        actions: [
          // Exchange selector
          PopupMenuButton<String>(
            tooltip: l10n.exchange,
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedExchange.toUpperCase(),
                  style: theme.textTheme.labelLarge,
                ),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
            onSelected: (value) {
              setState(() => _selectedExchange = value);
            },
            itemBuilder: (context) => _exchanges.map((exchange) {
              return PopupMenuItem<String>(
                value: exchange,
                child: Text(exchange.toUpperCase()),
              );
            }).toList(),
          ),
          const SizedBox(width: 8),
          // Pair selector (dynamic from provider)
          Consumer(
            builder: (context, ref, _) {
              final pairsAsync = ref.watch(
                availablePairsProvider(
                  marketType: _selectedMarketType,
                  exchange: _selectedExchange,
                ),
              );

              return pairsAsync.when(
                data: (pairs) {
                  // Ensure selected pair is in the list
                  if (!pairs.contains(_selectedPair) && pairs.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() => _selectedPair = pairs.first);
                      }
                    });
                  }

                  return PopupMenuButton<String>(
                    tooltip: l10n.selectedPair,
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedPair,
                          style: theme.textTheme.labelLarge,
                        ),
                        const Icon(Icons.arrow_drop_down, size: 20),
                      ],
                    ),
                    onSelected: (value) {
                      setState(() => _selectedPair = value);
                    },
                    itemBuilder: (context) => pairs.map((pair) {
                      return PopupMenuItem<String>(
                        value: pair,
                        child: Text(pair),
                      );
                    }).toList(),
                  );
                },
                loading: () => PopupMenuButton<String>(
                  tooltip: l10n.selectedPair,
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedPair,
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(width: 4),
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ),
                  itemBuilder: (context) => [],
                ),
                error: (error, stack) => PopupMenuButton<String>(
                  tooltip: l10n.selectedPair,
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedPair,
                        style: theme.textTheme.labelLarge,
                      ),
                      const Icon(Icons.error_outline,
                          size: 16, color: Colors.red),
                    ],
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: _selectedPair,
                      child: Text(_selectedPair),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Signals'),
            Tab(text: 'Portfolio'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: TabBarView(
          controller: _tabController,
          children: [
            ComprehensiveAnalysisScreen(
              initialSymbol: _selectedPair,
              initialExchange: _selectedExchange,
            ),
            McpSignalsScreen(
              exchange: _selectedExchange,
              pair: _selectedPair,
            ),
            const Center(
              child: Text('Portfolio - Coming Soon'),
            ),
          ],
        ),
      ),
    );
  }
}
