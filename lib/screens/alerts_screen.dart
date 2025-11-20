import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../l10n/l10n_export.dart';
import '../models/alert_config.dart';
import '../providers/alert_provider.dart';
import 'alert_config_screen.dart';

/// Alerts screen with tabs for active alerts, history, and configuration
class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen>
    with SingleTickerProviderStateMixin {
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

  Future<void> _onRefresh() async {
    // Refresh active alerts and history
    ref.invalidate(activeAlertsProvider);
    ref.invalidate(alertHistoryProvider());
    await Future.wait([
      ref.read(activeAlertsProvider.future),
      ref.read(alertHistoryProvider().future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              indicatorColor: theme.colorScheme.primary,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              tabs: [
                Tab(
                  icon: const Icon(Icons.warning_amber),
                  text: l10n.activeAlerts,
                ),
                Tab(
                  icon: const Icon(Icons.history),
                  text: l10n.history,
                ),
                Tab(
                  icon: const Icon(Icons.settings),
                  text: l10n.configuration,
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActiveAlertsTab(l10n),
                _buildHistoryTab(l10n),
                _buildConfigurationTab(l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveAlertsTab(L10n l10n) {
    final activeAlertsAsync = ref.watch(activeAlertsProvider);

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: activeAlertsAsync.when(
        data: (alerts) {
          if (alerts.isEmpty) {
            return _buildEmptyState(
              icon: Icons.check_circle_outline,
              title: l10n.noActiveAlerts,
              subtitle: l10n.allClear,
            );
          }

          // Sort by severity: critical > warning > info
          final sortedAlerts = [...alerts]..sort((a, b) {
            final severityOrder = {'critical': 3, 'warning': 2, 'info': 1};
            final aSeverity = severityOrder[a.severity.value] ?? 0;
            final bSeverity = severityOrder[b.severity.value] ?? 0;
            return bSeverity.compareTo(aSeverity);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedAlerts.length,
            itemBuilder: (context, index) {
              final alert = sortedAlerts[index];
              return _buildAlertCard(alert, l10n, isActive: true);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(l10n, error),
      ),
    );
  }

  Widget _buildHistoryTab(L10n l10n) {
    final historyAsync = ref.watch(alertHistoryProvider(limit: 100));

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: historyAsync.when(
        data: (alerts) {
          if (alerts.isEmpty) {
            return _buildEmptyState(
              icon: Icons.inbox_outlined,
              title: l10n.noAlertsYet,
              subtitle: l10n.alertHistoryWillAppearHere,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return _buildAlertCard(alert, l10n, isActive: false);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(l10n, error),
      ),
    );
  }

  Widget _buildConfigurationTab(L10n l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.alertConfiguration,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.tune),
              title: Text(l10n.manageAlertRules),
              subtitle: Text(l10n.configureAlertConditions),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AlertConfigScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.send),
              title: Text(l10n.testAlertSystem),
              subtitle: Text(l10n.sendTestAlert),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                HapticFeedback.lightImpact();
                _testAlertConfiguration(l10n);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Alert alert, L10n l10n, {required bool isActive}) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, y h:mm a');

    // Determine severity color
    Color severityColor;
    IconData severityIcon;
    switch (alert.severity.value) {
      case 'critical':
        severityColor = const Color(0xFFF44336);
        severityIcon = Icons.error;
        break;
      case 'warning':
        severityColor = const Color(0xFFFF9800);
        severityIcon = Icons.warning;
        break;
      default:
        severityColor = const Color(0xFF2196F3);
        severityIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with severity indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(severityIcon, color: severityColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  alert.severity.value.toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: severityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  dateFormat.format(alert.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Alert content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.message,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                if (alert.trigger != null)
                  Row(
                    children: [
                      Icon(
                        Icons.label_outline,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${l10n.trigger}: ${alert.trigger}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (alert.value != null) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.trending_up,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${l10n.value}: ${alert.value}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),

          // Action buttons (only for active alerts)
          if (isActive && !alert.acknowledged)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _dismissAlert(alert.id, l10n),
                    icon: const Icon(Icons.close, size: 18),
                    label: Text(l10n.dismiss),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => _acknowledgeAlert(alert.id, l10n),
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(l10n.acknowledge),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
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
            l10n.errorLoadingAlerts,
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
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  void _acknowledgeAlert(String alertId, L10n l10n) async {
    HapticFeedback.mediumImpact();

    try {
      await ref.read(alertAcknowledgerProvider.notifier).acknowledgeAlert(alertId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.alertAcknowledged),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOccurred(error: e.toString())),
            backgroundColor: const Color(0xFFF44336),
            action: SnackBarAction(
              label: l10n.retry,
              textColor: Colors.white,
              onPressed: () => _acknowledgeAlert(alertId, l10n),
            ),
          ),
        );
      }
    }
  }

  void _dismissAlert(String alertId, L10n l10n) async {
    HapticFeedback.mediumImpact();

    try {
      await ref.read(alertDismisserProvider.notifier).dismissAlert(alertId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.alertDismissed),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOccurred(error: e.toString())),
            backgroundColor: const Color(0xFFF44336),
            action: SnackBarAction(
              label: l10n.retry,
              textColor: Colors.white,
              onPressed: () => _dismissAlert(alertId, l10n),
            ),
          ),
        );
      }
    }
  }

  void _testAlertConfiguration(L10n l10n) async {
    HapticFeedback.mediumImpact();

    try {
      await ref.read(alertTesterProvider.notifier).testConfig();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.testAlertSent),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOccurred(error: e.toString())),
            backgroundColor: const Color(0xFFF44336),
            action: SnackBarAction(
              label: l10n.retry,
              textColor: Colors.white,
              onPressed: () => _testAlertConfiguration(l10n),
            ),
          ),
        );
      }
    }
  }
}
