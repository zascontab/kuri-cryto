import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/strategy_card.dart';

/// Strategies screen for controlling trading strategies
class StrategiesScreen extends StatefulWidget {
  const StrategiesScreen({super.key});

  @override
  State<StrategiesScreen> createState() => _StrategiesScreenState();
}

class _StrategiesScreenState extends State<StrategiesScreen> {
  bool _isLoading = false;

  // Mock data - replace with actual API calls
  final List<_StrategyData> _strategies = [
    _StrategyData(
      name: 'RSI Scalping',
      isActive: true,
      weight: 0.25,
      totalTrades: 150,
      winRate: 68.5,
      totalPnl: 245.80,
      description: 'Trades based on RSI overbought/oversold conditions',
      config: {
        'period': 14,
        'oversold': 25,
        'overbought': 75,
      },
    ),
    _StrategyData(
      name: 'MACD Scalping',
      isActive: true,
      weight: 0.30,
      totalTrades: 120,
      winRate: 62.3,
      totalPnl: 189.50,
      description: 'Trades based on MACD crossovers and divergence',
      config: {
        'fast_period': 12,
        'slow_period': 26,
        'signal_period': 9,
      },
    ),
    _StrategyData(
      name: 'Bollinger Scalping',
      isActive: true,
      weight: 0.20,
      totalTrades: 95,
      winRate: 71.2,
      totalPnl: 167.30,
      description: 'Trades based on Bollinger Bands price action',
      config: {
        'period': 20,
        'std_dev': 2.0,
      },
    ),
    _StrategyData(
      name: 'Volume Scalping',
      isActive: false,
      weight: 0.15,
      totalTrades: 78,
      winRate: 58.9,
      totalPnl: 92.40,
      description: 'Trades based on unusual volume patterns',
      config: {
        'volume_threshold': 1.5,
        'lookback_periods': 20,
      },
    ),
    _StrategyData(
      name: 'AI Scalping',
      isActive: true,
      weight: 0.10,
      totalTrades: 45,
      winRate: 75.6,
      totalPnl: 312.90,
      description: 'ML-based trading using multiple indicators',
      config: {
        'model_version': 'v2.1',
        'confidence_threshold': 0.75,
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Strategies Overview',
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
                      _buildSummaryMetric(
                        'Active',
                        _strategies.where((s) => s.isActive).length.toString(),
                        theme,
                        const Color(0xFF4CAF50),
                      ),
                      _buildSummaryMetric(
                        'Total Trades',
                        _strategies
                            .map((s) => s.totalTrades)
                            .reduce((a, b) => a + b)
                            .toString(),
                        theme,
                      ),
                      _buildSummaryMetric(
                        'Avg Win Rate',
                        '${(_strategies.map((s) => s.winRate).reduce((a, b) => a + b) / _strategies.length).toStringAsFixed(1)}%',
                        theme,
                      ),
                      _buildSummaryMetric(
                        'Total P&L',
                        '+\$${_strategies.map((s) => s.totalPnl).reduce((a, b) => a + b).toStringAsFixed(2)}',
                        theme,
                        const Color(0xFF4CAF50),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Strategies list
          Text(
            'Available Strategies',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            ..._strategies.map((strategy) {
              return StrategyCard(
                name: strategy.name,
                isActive: strategy.isActive,
                weight: strategy.weight,
                totalTrades: strategy.totalTrades,
                winRate: strategy.winRate,
                totalPnl: strategy.totalPnl,
                onToggle: (value) => _toggleStrategy(strategy.name, value),
                onTap: () => _showStrategyDetails(strategy),
                onConfigure: () => _configureStrategy(strategy),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(
    String label,
    String value,
    ThemeData theme, [
    Color? color,
  ]) {
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
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);

    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _toggleStrategy(String name, bool value) {
    HapticFeedback.mediumImpact();

    // TODO: Replace with actual API call
    setState(() {
      final strategy = _strategies.firstWhere((s) => s.name == name);
      strategy.isActive = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Strategy "$name" activated'
              : 'Strategy "$name" deactivated',
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showStrategyDetails(_StrategyData strategy) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return _StrategyDetailsSheet(
            strategy: strategy,
            scrollController: scrollController,
          );
        },
      ),
    );
  }

  void _configureStrategy(_StrategyData strategy) {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => _StrategyConfigDialog(strategy: strategy),
    );
  }
}

// Mock data class
class _StrategyData {
  final String name;
  bool isActive;
  final double weight;
  final int totalTrades;
  final double winRate;
  final double totalPnl;
  final String description;
  final Map<String, dynamic> config;

  _StrategyData({
    required this.name,
    required this.isActive,
    required this.weight,
    required this.totalTrades,
    required this.winRate,
    required this.totalPnl,
    required this.description,
    required this.config,
  });
}

// Strategy details sheet
class _StrategyDetailsSheet extends StatelessWidget {
  final _StrategyData strategy;
  final ScrollController scrollController;

  const _StrategyDetailsSheet({
    required this.strategy,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: ListView(
        controller: scrollController,
        children: [
          Text(
            strategy.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strategy.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Performance Metrics',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildMetricRow('Total Trades', strategy.totalTrades.toString(), theme),
          _buildMetricRow('Win Rate', '${strategy.winRate.toStringAsFixed(1)}%', theme),
          _buildMetricRow('Total P&L', '+\$${strategy.totalPnl.toStringAsFixed(2)}', theme),
          _buildMetricRow('Weight', '${(strategy.weight * 100).toStringAsFixed(0)}%', theme),
          _buildMetricRow(
            'Avg Win',
            '\$${((strategy.totalPnl / strategy.totalTrades) * (strategy.winRate / 100)).toStringAsFixed(2)}',
            theme,
          ),
          _buildMetricRow(
            'Avg Loss',
            '-\$${((strategy.totalPnl / strategy.totalTrades) * ((100 - strategy.winRate) / 100)).abs().toStringAsFixed(2)}',
            theme,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Configuration',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...strategy.config.entries.map((entry) {
            return _buildMetricRow(
              entry.key.replaceAll('_', ' ').toUpperCase(),
              entry.value.toString(),
              theme,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Strategy configuration dialog
class _StrategyConfigDialog extends StatefulWidget {
  final _StrategyData strategy;

  const _StrategyConfigDialog({required this.strategy});

  @override
  State<_StrategyConfigDialog> createState() => _StrategyConfigDialogState();
}

class _StrategyConfigDialogState extends State<_StrategyConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    widget.strategy.config.forEach((key, value) {
      _controllers[key] = TextEditingController(text: value.toString());
    });
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();

      // TODO: Replace with actual API call
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Strategy configuration updated'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Configure ${widget.strategy.name}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _controllers.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: entry.value,
                  decoration: InputDecoration(
                    labelText: entry.key.replaceAll('_', ' ').toUpperCase(),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    return null;
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
