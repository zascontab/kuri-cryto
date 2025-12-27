import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/l10n_export.dart';
import '../config/app_theme.dart';
import '../widgets/tiktok_modal.dart';
import '../widgets/market_type_selector.dart';
import '../models/market_type.dart';
import '../models/bot_config.dart';
import '../providers/ai_bot_provider.dart';
import '../providers/trading_pairs_provider.dart';

/// AI Bot Configuration Screen - Dynamic bot configuration
///
/// Features:
/// - Mode switches (DRY RUN / LIVE MODE, Auto Execute)
/// - Sliders for Confidence Threshold and Leverage
/// - Text fields for Trade Size, Max Daily Loss, Max Daily Trades
/// - Trading Pair dropdown selector
/// - Configuration presets (Conservative, Intermediate, Aggressive)
/// - Save button with confirmation
/// - Safety warnings for LIVE mode
class AiBotConfigScreen extends ConsumerStatefulWidget {
  const AiBotConfigScreen({super.key});

  @override
  ConsumerState<AiBotConfigScreen> createState() => _AiBotConfigScreenState();
}

class _AiBotConfigScreenState extends ConsumerState<AiBotConfigScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late TextEditingController _tradeSizeController;
  late TextEditingController _maxDailyLossController;
  late TextEditingController _maxDailyTradesController;
  late TextEditingController _maxConsecutiveErrorsController;
  late TextEditingController _maxOpenPositionsController;

  // Form state
  bool _isDryRun = true;
  bool _autoExecute = false;
  double _confidenceThreshold = 0.70;
  int _leverage = 5;
  String _selectedPair = 'DOGE-USDT';
  String _selectedMarketType = 'futures';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tradeSizeController = TextEditingController(text: '3.0');
    _maxDailyLossController = TextEditingController(text: '50.0');
    _maxDailyTradesController = TextEditingController(text: '20');
    _maxConsecutiveErrorsController = TextEditingController(text: '3');
    _maxOpenPositionsController = TextEditingController(text: '2');

    // Load current config
    _loadCurrentConfig();
  }

  @override
  void dispose() {
    _tradeSizeController.dispose();
    _maxDailyLossController.dispose();
    _maxDailyTradesController.dispose();
    _maxConsecutiveErrorsController.dispose();
    _maxOpenPositionsController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentConfig() async {
    final aiBotState = ref.read(aiBotProvider);
    if (aiBotState.config != null) {
      final config = aiBotState.config!;
      if (mounted) {
        setState(() {
          _isDryRun = config.dryRun;
          _confidenceThreshold = config.confidenceThreshold;
          _maxOpenPositionsController.text = config.maxPositions.toString();
          // Set default values for fields not in BotConfig
          _autoExecute = false;
          _leverage = 1;
          _selectedPair = 'BTC-USDT';
          _tradeSizeController.text = '100';
          _maxDailyLossController.text = '500';
          _maxDailyTradesController.text = '10';
          _maxConsecutiveErrorsController.text = '3';
        });
      }
    }
  }

  void _applyPreset(String preset) {
    HapticFeedback.mediumImpact();
    setState(() {
      switch (preset) {
        case 'conservative':
          _confidenceThreshold = 0.80;
          _leverage = 3;
          _tradeSizeController.text = '2.0';
          _maxDailyLossController.text = '30.0';
          _maxDailyTradesController.text = '10';
          break;
        case 'intermediate':
          _confidenceThreshold = 0.70;
          _leverage = 5;
          _tradeSizeController.text = '3.0';
          _maxDailyLossController.text = '50.0';
          _maxDailyTradesController.text = '20';
          break;
        case 'aggressive':
          _confidenceThreshold = 0.60;
          _leverage = 10;
          _tradeSizeController.text = '5.0';
          _maxDailyLossController.text = '100.0';
          _maxDailyTradesController.text = '50';
          break;
      }
    });
  }

  void _showSaveConfirmation() {
    final l10n = context.l10n;
    HapticFeedback.mediumImpact();

    if (!_isDryRun) {
      // Show warning for live mode
      showTikTokModal(
        context: context,
        title: l10n.aiBotLiveMode,
        message: l10n.aiBotWarningLiveMode,
        actions: [
          TikTokModalButton(
            text: l10n.confirm,
            isPrimary: true,
            icon: Icons.warning,
            backgroundColor: AppTheme.lossRed,
            onPressed: () {
              Navigator.pop(context);
              _saveConfiguration();
            },
          ),
          TikTokModalButton(
            text: l10n.cancel,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    } else {
      _saveConfiguration();
    }
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updates = {
        'dry_run': _isDryRun,
        'auto_execute': _autoExecute,
        'confidence_threshold': _confidenceThreshold,
        'leverage': _leverage,
        'pair': _selectedPair,
        'market_type': _selectedMarketType,
        'trade_size_usd': double.parse(_tradeSizeController.text),
        'max_daily_loss_usd': double.parse(_maxDailyLossController.text),
        'max_daily_trades': int.parse(_maxDailyTradesController.text),
        'max_consecutive_errors':
            int.parse(_maxConsecutiveErrorsController.text),
        'max_open_positions': int.parse(_maxOpenPositionsController.text),
      };

      // Convert updates to BotConfig and update
      final botConfig = BotConfig(
        dryRun: updates['dry_run'] as bool,
        confidenceThreshold: updates['confidence_threshold'] as double,
        maxPositions: updates['max_open_positions'] as int,
        maxRiskPerTrade: 0.02, // Default 2% risk per trade
        maxLeverage: (updates['leverage'] as int).toDouble(),
      );

      await ref.read(aiBotProvider.notifier).updateConfig(botConfig);

      if (mounted) {
        HapticFeedback.heavyImpact();
        final l10n = context.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.aiBotConfigUpdated),
            backgroundColor: AppTheme.profitGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final l10n = context.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: ${e.toString()}'),
            backgroundColor: AppTheme.lossRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildPreviewRow(
    ThemeData theme,
    String label,
    String value,
    Color? valueColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final tradingPairsAsync = ref.watch(activePairsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aiBotConfigTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Mode Configuration
            Text(
              'Trading Mode',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(l10n.aiBotDryRun),
                    subtitle: Text(
                      _isDryRun
                          ? 'Simulation mode - no real trades'
                          : l10n.aiBotLiveMode,
                    ),
                    value: _isDryRun,
                    activeThumbColor: AppTheme.profitGreen,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      setState(() => _isDryRun = value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(l10n.aiBotAutoExecute),
                    subtitle:
                        const Text('Automatically execute AI recommendations'),
                    value: _autoExecute,
                    activeThumbColor: AppTheme.profitGreen,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      setState(() => _autoExecute = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Trading Parameters
            Text(
              'Trading Parameters',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Trading Pair
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: tradingPairsAsync.when(
                  data: (pairs) {
                    final availablePairs = pairs.map((p) => p.symbol).toList();
                    if (!availablePairs.contains(_selectedPair)) {
                      availablePairs.insert(0, _selectedPair);
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: _selectedPair,
                      decoration: InputDecoration(
                        labelText: l10n.aiBotTradingPair,
                        border: const OutlineInputBorder(),
                      ),
                      items: availablePairs.map((pair) {
                        return DropdownMenuItem(
                          value: pair,
                          child: Text(pair),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedPair = value);
                        }
                      },
                    );
                  },
                  loading: () => DropdownButtonFormField<String>(
                    initialValue: _selectedPair,
                    decoration: InputDecoration(
                      labelText: l10n.aiBotTradingPair,
                      border: const OutlineInputBorder(),
                    ),
                    items: [_selectedPair].map((pair) {
                      return DropdownMenuItem(
                        value: pair,
                        child: Text(pair),
                      );
                    }).toList(),
                    onChanged: null,
                  ),
                  error: (_, __) => TextFormField(
                    initialValue: _selectedPair,
                    decoration: InputDecoration(
                      labelText: l10n.aiBotTradingPair,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) => _selectedPair = value,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Market Type Selector with Visual Indicators
            Card(
              elevation: 2,
              color: MarketType.fromString(_selectedMarketType)
                  .color
                  .withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: MarketType.fromString(_selectedMarketType)
                                .color
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            MarketType.fromString(_selectedMarketType).iconData,
                            color: MarketType.fromString(_selectedMarketType)
                                .color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Market Type',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Select trading market type',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Leverage indicator
                        if (_selectedMarketType != 'spot')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.profitGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.trending_up,
                                  size: 14,
                                  color: AppTheme.profitGreen,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Leverage',
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
                    MarketTypeChips(
                      selectedType: MarketType.fromString(_selectedMarketType),
                      onChanged: (type) {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _selectedMarketType = type.value;
                          // Reset leverage if spot
                          if (type == MarketType.spot) {
                            _leverage = 1;
                          }
                        });
                      },
                      showAllTypes: false,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              MarketType.fromString(_selectedMarketType)
                                  .description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Confidence Threshold Slider
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.aiBotConfidenceThreshold,
                          style: theme.textTheme.bodyLarge,
                        ),
                        Text(
                          '${(_confidenceThreshold * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _confidenceThreshold,
                      min: 0.5,
                      max: 1.0,
                      divisions: 50,
                      label:
                          '${(_confidenceThreshold * 100).toStringAsFixed(0)}%',
                      onChanged: (value) {
                        setState(() => _confidenceThreshold = value);
                      },
                    ),
                    Text(
                      'Minimum confidence required for trades',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Leverage Slider (only for non-spot markets)
            if (_selectedMarketType != 'spot')
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.aiBotLeverage,
                            style: theme.textTheme.bodyLarge,
                          ),
                          Text(
                            '${_leverage}x',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _leverage > 10
                                  ? AppTheme.lossRed
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _leverage.toDouble(),
                        min: 1,
                        max: MarketType.fromString(_selectedMarketType)
                            .maxLeverage
                            .toDouble(),
                        divisions: MarketType.fromString(_selectedMarketType)
                                .maxLeverage -
                            1,
                        label: '${_leverage}x',
                        onChanged: (value) {
                          HapticFeedback.selectionClick();
                          setState(() => _leverage = value.toInt());
                        },
                      ),
                      Text(
                        'Trading leverage multiplier (1-${MarketType.fromString(_selectedMarketType).maxLeverage}x for $_selectedMarketType)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // Trade Size
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _tradeSizeController,
                  decoration: InputDecoration(
                    labelText: '${l10n.aiBotTradeSize} (USD)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    final num = double.tryParse(value);
                    if (num == null || num <= 0) {
                      return 'Must be positive';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Safety Limits
            Text(
              'Safety Limits',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _maxDailyLossController,
                      decoration: InputDecoration(
                        labelText: '${l10n.aiBotMaxDailyLoss} (USD)',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.money_off),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final num = double.tryParse(value);
                        if (num == null || num <= 0) {
                          return 'Must be positive';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _maxDailyTradesController,
                      decoration: InputDecoration(
                        labelText: l10n.aiBotMaxDailyTrades,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.repeat),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final num = int.tryParse(value);
                        if (num == null || num <= 0) {
                          return 'Must be positive';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _maxConsecutiveErrorsController,
                      decoration: const InputDecoration(
                        labelText: 'Max Consecutive Errors',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.error_outline),
                        helperText: 'Bot stops after this many errors',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final num = int.tryParse(value);
                        if (num == null || num <= 0) {
                          return 'Must be positive';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _maxOpenPositionsController,
                      decoration: const InputDecoration(
                        labelText: 'Max Open Positions',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.layers),
                        helperText: 'Maximum simultaneous positions',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final num = int.tryParse(value);
                        if (num == null || num <= 0) {
                          return 'Must be positive';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Presets
            Text(
              'Configuration Presets',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _applyPreset('conservative'),
                    child: Text(l10n.aiBotPresetConservative),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _applyPreset('intermediate'),
                    child: Text(l10n.aiBotPresetIntermediate),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _applyPreset('aggressive'),
                    child: Text(l10n.aiBotPresetAggressive),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Warning if Live Mode
            if (!_isDryRun) ...[
              Card(
                color: AppTheme.lossRed.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: AppTheme.lossRed),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.aiBotWarningLiveMode,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.lossRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Configuration Preview Card
            Card(
              elevation: 3,
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.preview,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Configuration Preview',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildPreviewRow(
                      theme,
                      'Mode',
                      _isDryRun ? 'DRY RUN 🧪' : 'LIVE 🔴',
                      _isDryRun ? AppTheme.profitGreen : AppTheme.lossRed,
                    ),
                    _buildPreviewRow(
                      theme,
                      'Market Type',
                      '${MarketType.fromString(_selectedMarketType).icon} ${MarketType.fromString(_selectedMarketType).displayName}',
                      MarketType.fromString(_selectedMarketType).color,
                    ),
                    _buildPreviewRow(
                      theme,
                      'Trading Pair',
                      _selectedPair,
                      null,
                    ),
                    if (_selectedMarketType != 'spot')
                      _buildPreviewRow(
                        theme,
                        'Leverage',
                        '${_leverage}x',
                        _leverage > 10 ? AppTheme.warningYellow : null,
                      ),
                    _buildPreviewRow(
                      theme,
                      'Confidence',
                      '${(_confidenceThreshold * 100).toStringAsFixed(0)}%',
                      null,
                    ),
                    _buildPreviewRow(
                      theme,
                      'Trade Size',
                      '\$${_tradeSizeController.text}',
                      null,
                    ),
                    _buildPreviewRow(
                      theme,
                      'Daily Limits',
                      '\$${_maxDailyLossController.text} / ${_maxDailyTradesController.text} trades',
                      null,
                    ),
                    const SizedBox(height: 8),
                    if (_leverage > 20 && _selectedMarketType != 'spot')
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.warningYellow.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning,
                              size: 16,
                              color: AppTheme.warningYellow,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'High leverage detected! Use with caution.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.warningYellow,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _showSaveConfirmation,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(l10n.aiBotConfigSave),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
