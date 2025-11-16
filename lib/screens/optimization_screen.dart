import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/optimization.dart';
import '../providers/optimization_provider.dart';
import '../l10n/l10n.dart';
import '../widgets/tiktok_modal.dart';
import 'optimization_results_screen.dart';
import 'optimization_history_screen.dart';

/// Optimization Screen
///
/// Main screen for configuring and running parameter optimizations
class OptimizationScreen extends ConsumerStatefulWidget {
  const OptimizationScreen({super.key});

  @override
  ConsumerState<OptimizationScreen> createState() => _OptimizationScreenState();
}

class _OptimizationScreenState extends ConsumerState<OptimizationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10n.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.parameterOptimization),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.newOptimization),
            Tab(text: l10n.history),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOptimizationTab(theme, l10n),
          const OptimizationHistoryScreen(),
        ],
      ),
    );
  }

  Widget _buildOptimizationTab(ThemeData theme, L10n l10n) {
    final config = ref.watch(optimizationConfigFormProvider);
    final strategiesAsync = ref.watch(availableOptimizationStrategiesProvider);
    final isValid = ref.watch(isOptimizationConfigValidProvider);
    final estimatedCombos = ref.watch(estimatedCombinationsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Configuration Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.optimizationConfiguration,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Strategy selection
                  strategiesAsync.when(
                    data: (strategies) => _buildStrategyField(
                      theme,
                      l10n,
                      config.strategyName,
                      strategies,
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => Text(l10n.errorLoadingData),
                  ),
                  const SizedBox(height: 16),

                  // Symbol selection
                  _buildSymbolField(theme, l10n, config.symbol),
                  const SizedBox(height: 16),

                  // Date range
                  _buildDateRangeFields(theme, l10n, config),
                  const SizedBox(height: 16),

                  // Initial capital
                  _buildInitialCapitalField(theme, l10n, config.initialCapital ?? 10000.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Parameter Ranges Card
          _buildParameterRangesCard(theme, l10n, config),
          const SizedBox(height: 16),

          // Optimization Method Card
          _buildOptimizationMethodCard(theme, l10n, config),
          const SizedBox(height: 16),

          // Objective Card
          _buildObjectiveCard(theme, l10n, config),
          const SizedBox(height: 16),

          // Summary Card
          _buildSummaryCard(theme, l10n, estimatedCombos, isValid),
          const SizedBox(height: 24),

          // Run button
          FilledButton.icon(
            onPressed: isValid ? () => _runOptimization(l10n) : null,
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.runOptimization),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyField(
    ThemeData theme,
    L10n l10n,
    String currentStrategy,
    List<String> strategies,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.strategy,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: currentStrategy,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: strategies.map((strategy) {
            return DropdownMenuItem(
              value: strategy,
              child: Text(strategy.replaceAll('_', ' ').toUpperCase()),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              ref.read(optimizationConfigFormProvider.notifier).updateStrategyName(value);
              // Load default parameter ranges
              _loadDefaultRanges(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSymbolField(ThemeData theme, L10n l10n, String currentSymbol) {
    final symbols = ['BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'SOLUSDT', 'ADAUSDT'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.symbol,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: currentSymbol,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: symbols.map((symbol) {
            return DropdownMenuItem(
              value: symbol,
              child: Text(symbol),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              ref.read(optimizationConfigFormProvider.notifier).updateSymbol(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildDateRangeFields(
    ThemeData theme,
    L10n l10n,
    OptimizationConfig config,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dateRange,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                theme,
                l10n.startDate,
                config.startDate,
                (date) => ref
                    .read(optimizationConfigFormProvider.notifier)
                    .updateStartDate(date),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                theme,
                l10n.endDate,
                config.endDate,
                (date) => ref
                    .read(optimizationConfigFormProvider.notifier)
                    .updateEndDate(date),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(
    ThemeData theme,
    String label,
    DateTime currentDate,
    Function(DateTime) onDateSelected,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: currentDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MMM dd, yyyy').format(currentDate)),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialCapitalField(
    ThemeData theme,
    L10n l10n,
    double currentCapital,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.initialCapital,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: currentCapital.toStringAsFixed(0),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            prefixText: '\$ ',
            hintText: l10n.enterAmount,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (value) {
            final capital = double.tryParse(value);
            if (capital != null) {
              ref
                  .read(optimizationConfigFormProvider.notifier)
                  .updateInitialCapital(capital);
            }
          },
        ),
      ],
    );
  }

  Widget _buildParameterRangesCard(
    ThemeData theme,
    L10n l10n,
    OptimizationConfig config,
  ) {
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
                  l10n.parameterRanges,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddParameterDialog(theme, l10n),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addParameter),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (config.parameterRanges.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l10n.noParametersConfigured,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...config.parameterRanges.asMap().entries.map((entry) {
                final index = entry.key;
                final range = entry.value;
                return _buildParameterRangeItem(theme, l10n, index, range);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterRangeItem(
    ThemeData theme,
    L10n l10n,
    int index,
    ParameterRange range,
  ) {
    final isValid = range.validate();
    final error = range.getValidationError();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isValid ? null : theme.colorScheme.errorContainer.withOpacity(0.3),
      child: ListTile(
        title: Text(
          range.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.min}: ${range.min}  ${l10n.max}: ${range.max}  ${l10n.step}: ${range.step}'),
            if (!isValid && error != null)
              Text(
                error,
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditParameterDialog(theme, l10n, index, range),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                ref.read(optimizationConfigFormProvider.notifier).removeParameterRange(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationMethodCard(
    ThemeData theme,
    L10n l10n,
    OptimizationConfig config,
  ) {
    final methods = [
      ('grid_search', l10n.gridSearch, l10n.gridSearchDesc),
      ('random', l10n.randomSearch, l10n.randomSearchDesc),
      ('bayesian', l10n.bayesianOptimization, l10n.bayesianOptimizationDesc),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.optimizationMethod,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...methods.map((method) {
              final value = method.$1;
              final title = method.$2;
              final desc = method.$3;

              return RadioListTile<String>(
                value: value,
                groupValue: config.optimizationMethod,
                onChanged: (newValue) {
                  if (newValue != null) {
                    ref
                        .read(optimizationConfigFormProvider.notifier)
                        .updateOptimizationMethod(newValue);
                  }
                },
                title: Text(title),
                subtitle: Text(desc),
              );
            }).toList(),
            if (config.optimizationMethod != 'grid_search') ...[
              const SizedBox(height: 16),
              TextFormField(
                initialValue: config.maxIterations?.toString() ?? '100',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.maxIterations,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (value) {
                  final iterations = int.tryParse(value);
                  ref
                      .read(optimizationConfigFormProvider.notifier)
                      .updateMaxIterations(iterations);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildObjectiveCard(
    ThemeData theme,
    L10n l10n,
    OptimizationConfig config,
  ) {
    final objectives = [
      ('sharpe_ratio', l10n.sharpeRatio, l10n.sharpeRatioDesc),
      ('total_pnl', l10n.totalPnl, l10n.totalPnlDesc),
      ('win_rate', l10n.winRate, l10n.winRateDesc),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.objectiveToOptimize,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...objectives.map((objective) {
              final value = objective.$1;
              final title = objective.$2;
              final desc = objective.$3;

              return RadioListTile<String>(
                value: value,
                groupValue: config.objective,
                onChanged: (newValue) {
                  if (newValue != null) {
                    ref.read(optimizationConfigFormProvider.notifier).updateObjective(newValue);
                  }
                },
                title: Text(title),
                subtitle: Text(desc),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    L10n l10n,
    int estimatedCombos,
    bool isValid,
  ) {
    return Card(
      color: isValid
          ? theme.colorScheme.primaryContainer.withOpacity(0.3)
          : theme.colorScheme.errorContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isValid ? Icons.check_circle : Icons.warning,
                  color: isValid ? const Color(0xFF10B981) : theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.optimizationSummary,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(l10n.estimatedCombinations, estimatedCombos.toString()),
            if (!isValid)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.pleaseFixConfigurationErrors,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddParameterDialog(ThemeData theme, L10n l10n) async {
    final nameController = TextEditingController();
    final minController = TextEditingController();
    final maxController = TextEditingController();
    final stepController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showTikTokModal(
      context: context,
      title: l10n.addParameter,
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.parameterName,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterValue;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: minController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.minimumValue,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterValue;
                }
                if (double.tryParse(value) == null) {
                  return l10n.pleaseEnterValidNumber;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: maxController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.maximumValue,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterValue;
                }
                if (double.tryParse(value) == null) {
                  return l10n.pleaseEnterValidNumber;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: stepController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.stepSize,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterValue;
                }
                if (double.tryParse(value) == null) {
                  return l10n.pleaseEnterValidNumber;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TikTokModalButton(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TikTokModalButton(
          label: l10n.add,
          isPrimary: true,
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final range = ParameterRange(
                name: nameController.text,
                min: double.parse(minController.text),
                max: double.parse(maxController.text),
                step: double.parse(stepController.text),
              );

              ref.read(optimizationConfigFormProvider.notifier).addParameterRange(range);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  Future<void> _showEditParameterDialog(
    ThemeData theme,
    L10n l10n,
    int index,
    ParameterRange currentRange,
  ) async {
    final nameController = TextEditingController(text: currentRange.name);
    final minController = TextEditingController(text: currentRange.min.toString());
    final maxController = TextEditingController(text: currentRange.max.toString());
    final stepController = TextEditingController(text: currentRange.step.toString());
    final formKey = GlobalKey<FormState>();

    await showTikTokModal(
      context: context,
      title: l10n.editParameter,
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.parameterName,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterValue;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: minController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.minimumValue,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterValue;
                }
                if (double.tryParse(value) == null) {
                  return l10n.pleaseEnterValidNumber;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: maxController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.maximumValue,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterValue;
                }
                if (double.tryParse(value) == null) {
                  return l10n.pleaseEnterValidNumber;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: stepController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.stepSize,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterValue;
                }
                if (double.tryParse(value) == null) {
                  return l10n.pleaseEnterValidNumber;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TikTokModalButton(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TikTokModalButton(
          label: l10n.save,
          isPrimary: true,
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final range = ParameterRange(
                name: nameController.text,
                min: double.parse(minController.text),
                max: double.parse(maxController.text),
                step: double.parse(stepController.text),
              );

              ref.read(optimizationConfigFormProvider.notifier).updateParameterRange(index, range);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  Future<void> _loadDefaultRanges(String strategyName) async {
    try {
      final ranges = await ref
          .read(defaultParameterRangesProvider(strategyName).future);
      ref.read(optimizationConfigFormProvider.notifier).loadDefaultRanges(ranges);
    } catch (e) {
      // Ignore errors - user can add parameters manually
    }
  }

  Future<void> _runOptimization(L10n l10n) async {
    try {
      HapticFeedback.mediumImpact();

      final config = ref.read(optimizationConfigFormProvider);
      final optimizationId =
          await ref.read(optimizationRunnerProvider.notifier).run(config);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.optimizationStarted),
            backgroundColor: const Color(0xFF10B981),
          ),
        );

        // Navigate to results screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OptimizationResultsScreen(
              optimizationId: optimizationId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }
}
