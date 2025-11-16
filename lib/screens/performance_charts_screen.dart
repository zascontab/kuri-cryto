import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/l10n.dart';

/// Performance Charts Screen
///
/// Displays performance charts and visualizations:
/// - P&L Chart (Daily/Weekly/Monthly)
/// - Win Rate Chart
/// - Drawdown Chart
/// - Latency Chart
///
/// Features:
/// - Period selection (7d, 30d, 90d, All)
/// - Strategy filtering
/// - Symbol filtering
class PerformanceChartsScreen extends ConsumerStatefulWidget {
  const PerformanceChartsScreen({super.key});

  @override
  ConsumerState<PerformanceChartsScreen> createState() => _PerformanceChartsScreenState();
}

class _PerformanceChartsScreenState extends ConsumerState<PerformanceChartsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '7d';
  String _selectedStrategy = 'all';
  String _selectedSymbol = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    HapticFeedback.lightImpact();
    setState(() {
      // Trigger refresh
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10n.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.performanceCharts),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, theme, l10n),
            tooltip: l10n.filterByStatus,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: l10n.refreshStats,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: l10n.pnlChart, icon: const Icon(Icons.show_chart)),
            Tab(text: l10n.winRateChart, icon: const Icon(Icons.trending_up)),
            Tab(text: l10n.drawdownChart, icon: const Icon(Icons.trending_down)),
            Tab(text: l10n.latencyChart, icon: const Icon(Icons.speed)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Period selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPeriodChip(theme, l10n, l10n.period7d, '7d'),
                _buildPeriodChip(theme, l10n, l10n.period30d, '30d'),
                _buildPeriodChip(theme, l10n, l10n.period90d, '90d'),
                _buildPeriodChip(theme, l10n, l10n.periodAll, 'all'),
              ],
            ),
          ),
          // Active filters
          if (_selectedStrategy != 'all' || _selectedSymbol != 'all')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedStrategy != 'all')
                    Chip(
                      label: Text('${l10n.strategy}: $_selectedStrategy'),
                      onDeleted: () {
                        setState(() => _selectedStrategy = 'all');
                      },
                    ),
                  if (_selectedSymbol != 'all')
                    Chip(
                      label: Text('${l10n.symbol}: $_selectedSymbol'),
                      onDeleted: () {
                        setState(() => _selectedSymbol = 'all');
                      },
                    ),
                ],
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPnlChart(theme, l10n),
                _buildWinRateChart(theme, l10n),
                _buildDrawdownChart(theme, l10n),
                _buildLatencyChart(theme, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(ThemeData theme, L10n l10n, String label, String value) {
    final isSelected = _selectedPeriod == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedPeriod = value);
        }
      },
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
    );
  }

  Widget _buildPnlChart(ThemeData theme, L10n l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.pnlChart,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Chart Placeholder',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This chart will display P&L trends over time.\nIntegrate with fl_chart library for visualization.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMockDataInfo(theme, l10n, [
                    'Period: $_selectedPeriod',
                    if (_selectedStrategy != 'all') 'Strategy: $_selectedStrategy',
                    if (_selectedSymbol != 'all') 'Symbol: $_selectedSymbol',
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinRateChart(ThemeData theme, L10n l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              size: 80,
              color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.winRateChart,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Chart Placeholder',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This chart will display win rate trends.\nIntegrate with fl_chart library for visualization.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMockDataInfo(theme, l10n, [
                    'Period: $_selectedPeriod',
                    if (_selectedStrategy != 'all') 'Strategy: $_selectedStrategy',
                    if (_selectedSymbol != 'all') 'Symbol: $_selectedSymbol',
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawdownChart(ThemeData theme, L10n l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_down,
              size: 80,
              color: const Color(0xFFF44336).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.drawdownChart,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF44336).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Chart Placeholder',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This chart will display drawdown over time.\nIntegrate with fl_chart library for visualization.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMockDataInfo(theme, l10n, [
                    'Period: $_selectedPeriod',
                    if (_selectedStrategy != 'all') 'Strategy: $_selectedStrategy',
                    if (_selectedSymbol != 'all') 'Symbol: $_selectedSymbol',
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatencyChart(ThemeData theme, L10n l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.speed,
              size: 80,
              color: Colors.orange.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.latencyChart,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Chart Placeholder',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This chart will display execution latency trends.\nIntegrate with fl_chart library for visualization.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMockDataInfo(theme, l10n, [
                    'Period: $_selectedPeriod',
                    if (_selectedStrategy != 'all') 'Strategy: $_selectedStrategy',
                    if (_selectedSymbol != 'all') 'Symbol: $_selectedSymbol',
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockDataInfo(ThemeData theme, L10n l10n, List<String> filters) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Filters:',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...filters.map((filter) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      filter,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, ThemeData theme, L10n l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.filterByStatus),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.filterByStrategy,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedStrategy,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: l10n.strategy,
                  ),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text(l10n.allStrategies)),
                    const DropdownMenuItem(value: 'rsi', child: Text('RSI Scalping')),
                    const DropdownMenuItem(value: 'macd', child: Text('MACD Scalping')),
                    const DropdownMenuItem(value: 'bollinger', child: Text('Bollinger Scalping')),
                    const DropdownMenuItem(value: 'volume', child: Text('Volume Scalping')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedStrategy = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.filterBySymbol,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedSymbol,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: l10n.symbol,
                  ),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text(l10n.allSymbols)),
                    const DropdownMenuItem(value: 'BTC-USDT', child: Text('BTC-USDT')),
                    const DropdownMenuItem(value: 'ETH-USDT', child: Text('ETH-USDT')),
                    const DropdownMenuItem(value: 'DOGE-USDT', child: Text('DOGE-USDT')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedSymbol = value);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStrategy = 'all';
                _selectedSymbol = 'all';
              });
              Navigator.pop(context);
            },
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              setState(() {}); // Apply filters
              Navigator.pop(context);
            },
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}
