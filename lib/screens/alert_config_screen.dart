import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/l10n.dart';
import '../models/alert_config.dart';
import '../providers/alert_provider.dart';
import '../widgets/tiktok_modal.dart';

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
    final l10n = L10n.of(context);
    final formKey = GlobalKey<FormState>();
    String name = rule?.name ?? '';
    AlertType type = rule?.type ?? AlertType.dailyDrawdown;
    double threshold = rule?.threshold ?? 0.0;
    String? symbol = rule?.symbol;
    AlertSeverity severity = rule?.severity ?? AlertSeverity.warning;
    int cooldownMinutes = rule?.cooldownMinutes ?? 60;

    showTikTokModal(
      context: context,
      title: rule == null ? l10n.addAlertRule : l10n.editAlertRule,
      content: StatefulBuilder(
        builder: (context, setState) {
          return Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: InputDecoration(
                    labelText: l10n.ruleName,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? l10n.pleaseEnterRuleName : null,
                  onSaved: (value) => name = value!,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AlertType>(
                  value: type,
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
                  onChanged: (value) => setState(() => type = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: threshold.toString(),
                  decoration: InputDecoration(
                    labelText: l10n.threshold,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      double.tryParse(value ?? '') == null ? l10n.pleaseEnterValidNumber : null,
                  onSaved: (value) => threshold = double.parse(value!),
                ),
                const SizedBox(height: 16),
                if (type == AlertType.price || type == AlertType.volume)
                  TextFormField(
                    initialValue: symbol,
                    decoration: InputDecoration(
                      labelText: l10n.symbol,
                      hintText: 'BTC-USDT',
                      border: const OutlineInputBorder(),
                    ),
                    onSaved: (value) => symbol = value?.isEmpty ?? true ? null : value,
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AlertSeverity>(
                  value: severity,
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
                  onChanged: (value) => setState(() => severity = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: cooldownMinutes.toString(),
                  decoration: InputDecoration(
                    labelText: l10n.cooldownMinutes,
                    border: const OutlineInputBorder(),
                    helperText: l10n.preventDuplicateAlerts,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      int.tryParse(value ?? '') == null ? l10n.pleaseEnterValidNumber : null,
                  onSaved: (value) => cooldownMinutes = int.parse(value!),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        TikTokModalButton(
          text: l10n.save,
          isPrimary: true,
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              final newRule = AlertRule(
                id: rule?.id,
                name: name,
                type: type,
                threshold: threshold,
                symbol: symbol,
                severity: severity,
                cooldownMinutes: cooldownMinutes,
                createdAt: rule?.createdAt,
                updatedAt: DateTime.now(),
              );

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
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(rule == null ? l10n.ruleAdded : l10n.ruleUpdated),
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.errorOccurred(error: e.toString())),
                      backgroundColor: const Color(0xFFF44336),
                    ),
                  );
                }
              }
            }
          },
        ),
        TikTokModalButton(
          text: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
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
    final confirmed = await showTikTokModal<bool>(
      context: context,
      title: l10n.deleteRule,
      message: l10n.confirmDeleteRule(name: rule.name),
      actions: [
        TikTokModalButton(
          text: l10n.delete,
          isPrimary: true,
          backgroundColor: Colors.red,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        TikTokModalButton(
          text: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
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
