import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/l10n_export.dart';
import '../config/app_theme.dart';
import '../widgets/tiktok_modal.dart';
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
  
  // Form state
  bool _isDryRun = true;
  bool _autoExecute = false;
  double _confidenceThreshold = 0.70;
  int _leverage = 5;
  String _selectedPair = 'DOGE-USDT';
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tradeSizeController = TextEditingController(text: '3.0');
    _maxDailyLossController = TextEditingController(text: '50.0');
    _maxDailyTradesController = TextEditingController(text: '20');
    
    // Load current config
    _loadCurrentConfig();
  }

  @override
  void dispose() {
    _tradeSizeController.dispose();
    _maxDailyLossController.dispose();
    _maxDailyTradesController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentConfig() async {
    final configAsync = ref.read(aiBotConfigNotifierProvider);
    configAsync.whenData((config) {
      if (mounted) {
        setState(() {
          _isDryRun = config.dryRun;
          _autoExecute = config.autoExecute;
          _confidenceThreshold = config.confidenceThreshold;
          _leverage = config.leverage;
          _selectedPair = config.pair;
          _tradeSizeController.text = config.tradeSizeUsd.toString();
          _maxDailyLossController.text = config.maxDailyLossUsd.toString();
          _maxDailyTradesController.text = config.maxDailyTrades.toString();
        });
      }
    });
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
        'trade_size_usd': double.parse(_tradeSizeController.text),
        'max_daily_loss_usd': double.parse(_maxDailyLossController.text),
        'max_daily_trades': int.parse(_maxDailyTradesController.text),
      };

      await ref.read(aiBotConfigNotifierProvider.notifier).updateConfig(updates);

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
                    activeColor: AppTheme.profitGreen,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      setState(() => _isDryRun = value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(l10n.aiBotAutoExecute),
                    subtitle: const Text('Automatically execute AI recommendations'),
                    value: _autoExecute,
                    activeColor: AppTheme.profitGreen,
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
                      value: _selectedPair,
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
                    value: _selectedPair,
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
                      label: '${(_confidenceThreshold * 100).toStringAsFixed(0)}%',
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

            // Leverage Slider
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
                      max: 100,
                      divisions: 99,
                      label: '${_leverage}x',
                      onChanged: (value) {
                        HapticFeedback.selectionClick();
                        setState(() => _leverage = value.toInt());
                      },
                    ),
                    Text(
                      'Trading leverage multiplier',
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
