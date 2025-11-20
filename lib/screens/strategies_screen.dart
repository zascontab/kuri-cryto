import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/strategy_card.dart';
import '../widgets/tiktok_modal.dart';
import '../l10n/l10n_export.dart';
import '../providers/strategy_provider.dart';
import '../models/strategy.dart';

/// Strategies screen for controlling trading strategies
class StrategiesScreen extends ConsumerStatefulWidget {
  const StrategiesScreen({super.key});

  @override
  ConsumerState<StrategiesScreen> createState() => _StrategiesScreenState();
}

class _StrategiesScreenState extends ConsumerState<StrategiesScreen> {
  Future<void> _onRefresh() async {
    ref.invalidate(strategiesProvider);
    await ref.read(strategiesProvider.future);
  }

  void _toggleStrategy(String name, bool currentValue) async {
    HapticFeedback.mediumImpact();
    final l10n = context.l10n;

    try {
      await ref.read(strategyTogglerProvider.notifier).toggle(name);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !currentValue
                  ? l10n.strategyActivated(name: name)
                  : l10n.strategyDeactivated(name: name),
            ),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFF44336),
            action: SnackBarAction(
              label: l10n.retry,
              textColor: Colors.white,
              onPressed: () => _toggleStrategy(name, currentValue),
            ),
          ),
        );
      }
    }
  }

  void _showStrategyDetails(Strategy strategy) {
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

  void _configureStrategy(Strategy strategy) {
    HapticFeedback.lightImpact();
    final l10n = context.l10n;
    showTikTokModal(
      context: context,
      isDismissible: false,
      content: _StrategyConfigContent(strategy: strategy),
      actions: [
        TikTokModalButton(
          text: l10n.strategies,
          isPrimary: true,
          onPressed: () => _configureStrategy(strategy),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final strategiesAsync = ref.watch(strategiesProvider);
    final stats = ref.watch(strategyStatsProvider);

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: strategiesAsync.when(
        data: (strategies) => ListView(
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
                          l10n.strategiesOverview,
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
                        Expanded(
                          child: _buildSummaryMetric(
                            l10n.active,
                            stats.activeStrategies.toString(),
                            theme,
                            const Color(0xFF4CAF50),
                          ),
                        ),
                        Expanded(
                          child: _buildSummaryMetric(
                            l10n.totalTrades,
                            strategies
                                .map((s) => s.performance.totalTrades ?? 0)
                                .reduce((a, b) => a + b)
                                .toString(),
                            theme,
                          ),
                        ),
                        Expanded(
                          child: _buildSummaryMetric(
                            l10n.avgWinRate,
                            '${stats.combinedWinRate.toStringAsFixed(1)}%',
                            theme,
                          ),
                        ),
                        Expanded(
                          child: _buildSummaryMetric(
                            l10n.totalPnl,
                            '+\$${stats.combinedPnl.toStringAsFixed(2)}',
                            theme,
                            const Color(0xFF4CAF50),
                          ),
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
              l10n.availableStrategies,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ...strategies.map((strategy) {
              return StrategyCard(
                name: strategy.name,
                isActive: strategy.active,
                weight: strategy.weight,
                totalTrades: strategy.performance.totalTrades ?? 0,
                winRate: strategy.performance.winRate ?? 0.0,
                totalPnl: strategy.performance.totalPnl ?? 0.0,
                onToggle: (value) =>
                    _toggleStrategy(strategy.name, strategy.active),
                onTap: () => _showStrategyDetails(strategy),
                onConfigure: () => _configureStrategy(strategy),
              );
            }),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Error: ${e.toString()}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _onRefresh,
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

  Widget _buildSummaryMetric(
    String label,
    String value,
    ThemeData theme, [
    Color? color,
  ]) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? theme.colorScheme.onSurface,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Strategy details sheet
class _StrategyDetailsSheet extends StatelessWidget {
  final Strategy strategy;
  final ScrollController scrollController;

  const _StrategyDetailsSheet({
    required this.strategy,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final performance = strategy.performance;

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
            strategy.description ?? 'No description available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            l10n.performanceMetrics,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...[
            _buildMetricRow(
                l10n.totalTrades, performance.totalTrades.toString(), theme),
            _buildMetricRow(l10n.winRate,
                '${performance.winRate.toStringAsFixed(1)}%', theme),
            _buildMetricRow(l10n.totalPnl,
                '+\$${performance.totalPnl.toStringAsFixed(2)}', theme),
            _buildMetricRow(l10n.weight,
                '${(strategy.weight * 100).toStringAsFixed(0)}%', theme),
            _buildMetricRow(
              l10n.avgWin,
              '\$${performance.avgWin.toStringAsFixed(2)}',
              theme,
            ),
            _buildMetricRow(
              l10n.avgLoss,
              '-\$${performance.avgLoss.abs().toStringAsFixed(2)}',
              theme,
            ),
          ],
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            l10n.configuration,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (strategy.config != null && strategy.config!.isNotEmpty)
            ...strategy.config!.entries.map((entry) {
              return _buildMetricRow(
                entry.key.replaceAll('_', ' ').toUpperCase(),
                entry.value.toString(),
                theme,
              );
            })
          else
            Text(
              'No configuration available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
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

// Strategy configuration content (used in TikTokModal)
class _StrategyConfigContent extends ConsumerStatefulWidget {
  final Strategy strategy;

  const _StrategyConfigContent({required this.strategy});

  @override
  ConsumerState<_StrategyConfigContent> createState() =>
      _StrategyConfigContentState();
}

class _StrategyConfigContentState
    extends ConsumerState<_StrategyConfigContent> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    widget.strategy.config?.forEach((key, value) {
      _controllers[key] = TextEditingController(text: value.toString());
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();

      // Convert controllers to config map
      final config = <String, dynamic>{};
      _controllers.forEach((key, controller) {
        final value = controller.text;
        // Try to parse as number, otherwise keep as string
        config[key] = double.tryParse(value) ?? int.tryParse(value) ?? value;
      });

      try {
        await ref.read(strategyConfigUpdaterProvider.notifier).updateConfig(
              strategyName: widget.strategy.name,
              config: config,
            );

        if (mounted) {
          Navigator.pop(context);

          final l10n = context.l10n;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.strategyConfigUpdated),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          final l10n = context.l10n;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: const Color(0xFFF44336),
              action: SnackBarAction(
                label: l10n.retry,
                textColor: Colors.white,
                onPressed: _save,
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return TikTokModal(
      title: l10n.configureStrategy(name: widget.strategy.name),
      content: Form(
        key: _formKey,
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
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterValue;
                  }
                  return null;
                },
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TikTokModalButton(
          text: l10n.save,
          isPrimary: true,
          onPressed: _save,
        ),
        TikTokModalButton(
          text: l10n.cancel,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
