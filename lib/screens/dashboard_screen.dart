import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/l10n.dart';
import '../widgets/metric_card.dart';
import '../widgets/tiktok_modal.dart';
import '../providers/system_provider.dart';

/// Dashboard screen showing system status and key metrics
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isTogglingEngine = false;

  Future<void> _onRefresh() async {
    ref.invalidate(systemStatusProvider);
    ref.invalidate(metricsProvider);
    ref.invalidate(healthProvider);

    // Wait for providers to reload
    await Future.wait([
      ref.read(systemStatusProvider.future),
      ref.read(metricsProvider.future),
      ref.read(healthProvider.future),
    ]);
  }

  void _toggleEngine(bool isRunning) {
    HapticFeedback.mediumImpact();
    final l10n = L10n.of(context);

    showTikTokModal(
      context: context,
      title: isRunning ? l10n.stopEngine : l10n.startEngine,
      message: isRunning ? l10n.stopEngineMessage : l10n.startEngineMessage,
      actions: [
        TikTokModalButton(
          text: isRunning ? l10n.stop : l10n.start,
          isPrimary: true,
          icon: isRunning ? Icons.stop_circle : Icons.play_circle_filled,
          backgroundColor: isRunning
              ? const Color(0xFFF44336)
              : const Color(0xFF4CAF50),
          onPressed: () {
            Navigator.pop(context);
            _performEngineToggle(isRunning);
          },
        ),
        TikTokModalButton(
          text: l10n.cancel,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Future<void> _performEngineToggle(bool isRunning) async {
    if (_isTogglingEngine) return;

    setState(() => _isTogglingEngine = true);

    try {
      final notifier = ref.read(systemStatusProvider.notifier);

      if (isRunning) {
        await notifier.stopEngine();
      } else {
        await notifier.startEngine();
      }

      if (mounted) {
        HapticFeedback.heavyImpact();
        final l10n = L10n.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRunning
                  ? l10n.engineStoppedSuccess
                  : l10n.engineStartedSuccess,
            ),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = L10n.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFF44336),
            action: SnackBarAction(
              label: l10n.retry,
              textColor: Colors.white,
              onPressed: () => _performEngineToggle(isRunning),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTogglingEngine = false);
      }
    }
  }

  Color _getHealthColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return const Color(0xFF4CAF50);
      case 'degraded':
        return Colors.orange;
      case 'down':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = L10n.of(context);

    final systemStatusAsync = ref.watch(systemStatusProvider);
    final metricsAsync = ref.watch(metricsProvider);
    final healthAsync = ref.watch(healthProvider);

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Scaffold(
        body: systemStatusAsync.when(
          data: (systemStatus) {
            final isEngineRunning = systemStatus.running;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // System Status Card
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    isEngineRunning
                                        ? Icons.play_circle_filled
                                        : Icons.stop_circle,
                                    size: 32,
                                    color: isEngineRunning
                                        ? const Color(0xFF4CAF50)
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.scalpingEngine,
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isEngineRunning
                                              ? l10n.running
                                              : l10n.stopped,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            healthAsync.when(
                              data: (health) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getHealthColor(health.status).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _getHealthColor(health.status),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      health.status.toUpperCase(),
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: _getHealthColor(health.status),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              loading: () => const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              error: (_, __) => const Icon(Icons.error, color: Colors.red),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        metricsAsync.when(
                          data: (metrics) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatusInfo(
                                l10n.uptime,
                                systemStatus.uptime,
                                theme,
                              ),
                              _buildStatusInfo(
                                l10n.activePositions,
                                metrics.activePositions.toString(),
                                theme,
                              ),
                              _buildStatusInfo(
                                l10n.avgLatency,
                                '${metrics.avgLatencyMs.toStringAsFixed(0)}${l10n.ms}',
                                theme,
                              ),
                            ],
                          ),
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (e, _) => Center(
                            child: Text(
                              'Error: ${e.toString()}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Metrics Grid
                Text(
                  l10n.keyMetrics,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                metricsAsync.when(
                  data: (metrics) => GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      MetricCard(
                        icon: Icons.attach_money,
                        title: l10n.totalPnl,
                        value:
                            '${metrics.totalPnl >= 0 ? '+' : ''}\$${metrics.totalPnl.toStringAsFixed(2)}',
                        change:
                            '${metrics.dailyPnl >= 0 ? '+' : ''}${metrics.dailyPnl.toStringAsFixed(1)}% ${l10n.today}',
                        changeColor: metrics.dailyPnl >= 0
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFF44336),
                        isLoading: false,
                      ),
                      MetricCard(
                        icon: Icons.percent,
                        title: l10n.winRate,
                        value: '${metrics.winRate.toStringAsFixed(1)}%',
                        change: metrics.winRate >= 50
                            ? l10n.aboveTarget
                            : l10n.belowTarget,
                        changeColor: metrics.winRate >= 50
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFF44336),
                        isLoading: false,
                      ),
                      MetricCard(
                        icon: Icons.account_balance_wallet,
                        title: l10n.activePositions,
                        value: metrics.activePositions.toString(),
                        change: l10n.openTrades,
                        isLoading: false,
                      ),
                      MetricCard(
                        icon: Icons.speed,
                        title: l10n.avgLatency,
                        value: '${metrics.avgLatencyMs.toStringAsFixed(0)}${l10n.ms}',
                        change: metrics.avgLatencyMs < 100
                            ? l10n.excellent
                            : l10n.good,
                        changeColor: metrics.avgLatencyMs < 100
                            ? const Color(0xFF4CAF50)
                            : Colors.orange,
                        isLoading: false,
                      ),
                    ],
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(48.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${e.toString()}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
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

                const SizedBox(height: 20),

                // Quick Actions
                Text(
                  l10n.quickActions,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.refresh),
                        title: Text(l10n.refreshData),
                        subtitle: Text(l10n.lastUpdatedNow),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _onRefresh();
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.analytics),
                        title: Text(l10n.viewAnalytics),
                        subtitle: Text(l10n.detailedCharts),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          // Navigate to analytics
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
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
        floatingActionButton: systemStatusAsync.maybeWhen(
          data: (systemStatus) => FloatingActionButton.extended(
            onPressed: _isTogglingEngine
                ? null
                : () => _toggleEngine(systemStatus.running),
            icon: Icon(
              systemStatus.running ? Icons.stop : Icons.play_arrow,
            ),
            label: Text(systemStatus.running
                ? l10n.stopEngine
                : l10n.startEngine),
            backgroundColor: systemStatus.running
                ? const Color(0xFFF44336)
                : const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
          ),
          orElse: () => null,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildStatusInfo(String label, String value, ThemeData theme) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
