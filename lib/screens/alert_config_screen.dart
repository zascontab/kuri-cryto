import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/l10n.dart';
import '../models/alert_config.dart';
import '../providers/alert_provider.dart';

/// Alert Configuration Screen
///
/// Allows users to:
/// - Configure Telegram bot settings
/// - Create/edit/delete alert rules
/// - Enable/disable alerts globally
/// - Test alert configuration
class AlertConfigScreen extends ConsumerStatefulWidget {
  const AlertConfigScreen({super.key});

  @override
  ConsumerState<AlertConfigScreen> createState() => _AlertConfigScreenState();
}

class _AlertConfigScreenState extends ConsumerState<AlertConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _alertsEnabled = false;
  bool _pushNotificationsEnabled = true;
  String _telegramToken = '';
  String _telegramChatId = '';

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    try {
      final config = await ref.read(alertConfigProvider.future);
      if (mounted) {
        setState(() {
          _alertsEnabled = config.enabled;
          _pushNotificationsEnabled = config.pushNotificationsEnabled;
          _telegramToken = config.telegramToken ?? '';
          _telegramChatId = config.telegramChatId ?? '';
        });
      }
    } catch (e) {
      // Config might not exist yet, use defaults
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final configAsync = ref.watch(alertConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.alertConfiguration),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveConfiguration,
            tooltip: l10n.save,
          ),
        ],
      ),
      body: configAsync.when(
        data: (config) => _buildConfigForm(config, l10n, theme),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(l10n, error),
      ),
    );
  }

  Widget _buildConfigForm(AlertConfig config, L10n l10n, ThemeData theme) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Global Enable/Disable
          Card(
            child: SwitchListTile(
              title: Text(l10n.enableAlerts),
              subtitle: Text(l10n.toggleAlertSystem),
              value: _alertsEnabled,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                setState(() => _alertsEnabled = value);
              },
            ),
          ),
          const SizedBox(height: 24),

          // Notification Settings
          Text(
            l10n.notificationSettings,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l10n.pushNotifications),
                  subtitle: Text(l10n.inAppNotifications),
                  value: _pushNotificationsEnabled,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    setState(() => _pushNotificationsEnabled = value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Telegram Configuration
          Text(
            l10n.telegramConfiguration,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: _telegramToken,
                    decoration: InputDecoration(
                      labelText: l10n.telegramBotToken,
                      hintText: '123456789:ABCdefGHIjklMNOpqrsTUVwxyz',
                      prefixIcon: const Icon(Icons.telegram),
                      border: const OutlineInputBorder(),
                    ),
                    onSaved: (value) => _telegramToken = value ?? '',
                    validator: (value) {
                      if (_alertsEnabled && (value == null || value.isEmpty)) {
                        return l10n.pleaseEnterTelegramToken;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _telegramChatId,
                    decoration: InputDecoration(
                      labelText: l10n.telegramChatId,
                      hintText: '123456789',
                      prefixIcon: const Icon(Icons.chat),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _telegramChatId = value ?? '',
                    validator: (value) {
                      if (_alertsEnabled && (value == null || value.isEmpty)) {
                        return l10n.pleaseEnterTelegramChatId;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.telegramSetupInstructions,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Alert Rules
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.alertRules,
                style: theme.textTheme.titleMedium,
              ),
              FilledButton.icon(
                onPressed: () => _showAddRuleDialog(config),
                icon: const Icon(Icons.add),
                label: Text(l10n.addRule),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (config.rules.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.rule_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.noAlertRulesYet,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.tapAddToCreateRule,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...config.rules.map((rule) => _buildRuleCard(rule, config, l10n, theme)),
        ],
      ),
    );
  }

  Widget _buildRuleCard(AlertRule rule, AlertConfig config, L10n l10n, ThemeData theme) {
    // Color based on severity
    Color severityColor;
    switch (rule.severity) {
      case AlertSeverity.critical:
        severityColor = const Color(0xFFF44336);
        break;
      case AlertSeverity.warning:
        severityColor = const Color(0xFFFF9800);
        break;
      default:
        severityColor = const Color(0xFF2196F3);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 4,
          decoration: BoxDecoration(
            color: severityColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(rule.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${l10n.type}: ${rule.type.displayName}'),
            Text('${l10n.threshold}: ${rule.threshold}'),
            if (rule.symbol != null)
              Text('${l10n.symbol}: ${rule.symbol}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: rule.enabled,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                _toggleRule(rule, config);
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditRuleDialog(rule, config);
                    break;
                  case 'delete':
                    _deleteRule(rule, l10n);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: const Icon(Icons.edit),
                    title: Text(l10n.edit),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: theme.colorScheme.error),
                    title: Text(l10n.delete, style: TextStyle(color: theme.colorScheme.error)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(L10n l10n, Object error) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.errorLoadingConfiguration,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              ref.invalidate(alertConfigProvider);
            },
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final currentConfig = await ref.read(alertConfigProvider.future);

      final newConfig = currentConfig.copyWith(
        enabled: _alertsEnabled,
        pushNotificationsEnabled: _pushNotificationsEnabled,
        telegramToken: _telegramToken.isEmpty ? null : _telegramToken,
        telegramChatId: _telegramChatId.isEmpty ? null : _telegramChatId,
        updatedAt: DateTime.now(),
      );

      await ref.read(alertConfiguratorProvider.notifier).configureAlerts(newConfig);

      if (mounted) {
        final l10n = L10n.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.alertConfigurationSaved),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        final l10n = L10n.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOccurred(error: e.toString())),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddRuleDialog(AlertConfig config) {
    _showRuleDialog(config: config);
  }

  void _showEditRuleDialog(AlertRule rule, AlertConfig config) {
    _showRuleDialog(config: config, rule: rule);
  }

  void _showRuleDialog({required AlertConfig config, AlertRule? rule}) {
    showDialog(
      context: context,
      builder: (context) => _AlertRuleDialog(
        config: config,
        rule: rule,
        onSave: (newRule) async {
          try {
            if (rule == null) {
              // Add new rule
              await ref.read(alertRuleManagerProvider.notifier).addRule(newRule);
            } else {
              // Update existing rule
              await ref.read(alertRuleManagerProvider.notifier).updateRule(
                rule.id!,
                newRule,
              );
            }
            if (mounted) {
              final l10n = L10n.of(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(rule == null ? l10n.ruleAdded : l10n.ruleUpdated),
                  backgroundColor: const Color(0xFF4CAF50),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              final l10n = L10n.of(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.errorOccurred(error: e.toString())),
                  backgroundColor: const Color(0xFFF44336),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _toggleRule(AlertRule rule, AlertConfig config) async {
    try {
      final updatedRule = rule.copyWith(enabled: !rule.enabled);
      await ref.read(alertRuleManagerProvider.notifier).updateRule(
        rule.id!,
        updatedRule,
      );
    } catch (e) {
      if (mounted) {
        final l10n = L10n.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOccurred(error: e.toString())),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
    }
  }

  void _deleteRule(AlertRule rule, L10n l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRule),
        content: Text(l10n.confirmDeleteRule(name: rule.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && rule.id != null) {
      try {
        await ref.read(alertRuleManagerProvider.notifier).deleteRule(rule.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.ruleDeleted),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.errorOccurred(error: e.toString())),
              backgroundColor: const Color(0xFFF44336),
            ),
          );
        }
      }
    }
  }
}

/// Dialog for creating/editing alert rules
class _AlertRuleDialog extends StatefulWidget {
  final AlertConfig config;
  final AlertRule? rule;
  final Function(AlertRule) onSave;

  const _AlertRuleDialog({
    required this.config,
    this.rule,
    required this.onSave,
  });

  @override
  State<_AlertRuleDialog> createState() => _AlertRuleDialogState();
}

class _AlertRuleDialogState extends State<_AlertRuleDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late AlertType _type;
  late double _threshold;
  late String? _symbol;
  late AlertSeverity _severity;
  late int _cooldownMinutes;

  @override
  void initState() {
    super.initState();
    _name = widget.rule?.name ?? '';
    _type = widget.rule?.type ?? AlertType.dailyDrawdown;
    _threshold = widget.rule?.threshold ?? 0.0;
    _symbol = widget.rule?.symbol;
    _severity = widget.rule?.severity ?? AlertSeverity.warning;
    _cooldownMinutes = widget.rule?.cooldownMinutes ?? 60;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return AlertDialog(
      title: Text(widget.rule == null ? l10n.addAlertRule : l10n.editAlertRule),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  labelText: l10n.ruleName,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? l10n.pleaseEnterRuleName : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AlertType>(
                value: _type,
                decoration: InputDecoration(
                  labelText: l10n.alertType,
                  border: const OutlineInputBorder(),
                ),
                items: AlertType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _type = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _threshold.toString(),
                decoration: InputDecoration(
                  labelText: l10n.threshold,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                    double.tryParse(value ?? '') == null ? l10n.pleaseEnterValidNumber : null,
                onSaved: (value) => _threshold = double.parse(value!),
              ),
              const SizedBox(height: 16),
              if (_type == AlertType.price || _type == AlertType.volume)
                TextFormField(
                  initialValue: _symbol,
                  decoration: InputDecoration(
                    labelText: l10n.symbol,
                    hintText: 'BTC-USDT',
                    border: const OutlineInputBorder(),
                  ),
                  onSaved: (value) => _symbol = value?.isEmpty ?? true ? null : value,
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AlertSeverity>(
                value: _severity,
                decoration: InputDecoration(
                  labelText: l10n.severity,
                  border: const OutlineInputBorder(),
                ),
                items: AlertSeverity.values.map((severity) {
                  return DropdownMenuItem(
                    value: severity,
                    child: Text(severity.displayName),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _severity = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _cooldownMinutes.toString(),
                decoration: InputDecoration(
                  labelText: l10n.cooldownMinutes,
                  border: const OutlineInputBorder(),
                  helperText: l10n.preventDuplicateAlerts,
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    int.tryParse(value ?? '') == null ? l10n.pleaseEnterValidNumber : null,
                onSaved: (value) => _cooldownMinutes = int.parse(value!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final rule = AlertRule(
                id: widget.rule?.id,
                name: _name,
                type: _type,
                threshold: _threshold,
                symbol: _symbol,
                severity: _severity,
                cooldownMinutes: _cooldownMinutes,
                createdAt: widget.rule?.createdAt,
                updatedAt: DateTime.now(),
              );
              widget.onSave(rule);
              Navigator.of(context).pop();
            }
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
