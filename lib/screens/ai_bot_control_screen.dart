import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_theme.dart';
import '../l10n/l10n_export.dart';
import '../widgets/metric_card.dart';
import '../widgets/tiktok_modal.dart';
import '../providers/ai_bot_provider.dart';
import 'ai_bot_config_screen.dart';

/// AI Bot Control Screen - Main control panel for the AI Trading Bot
///
/// Features:
/// - Bot status display (running, paused, emergency stop)
/// - Control buttons (Start, Stop, Pause, Resume, Emergency Stop)
/// - Metrics cards (uptime, analyses, executions, errors)
/// - Daily limits progress (daily loss, daily trades)
/// - Open positions list
/// - Navigation to configuration screen
class AiBotControlScreen extends ConsumerStatefulWidget {
  const AiBotControlScreen({super.key});

  @override
  ConsumerState<AiBotControlScreen> createState() => _AiBotControlScreenState();
}

class _AiBotControlScreenState extends ConsumerState<AiBotControlScreen> {
  Future<void> _onRefresh() async {
    ref.invalidate(aiBotStatusNotifierProvider);
    ref.invalidate(aiBotPositionsProvider);
    await Future.wait([
      ref.read(aiBotStatusNotifierProvider.future),
      ref.read(aiBotPositionsProvider.future),
    ]);
  }

  void _showStartBotModal() {
    final l10n = context.l10n;
    HapticFeedback.mediumImpact();

    showTikTokModal(
      context: context,
      title: l10n.aiBotStart,
      message: l10n.aiBotConfirmStart,
      actions: [
        TikTokModalButton(
          text: l10n.aiBotStart,
          isPrimary: true,
          icon: Icons.play_circle_filled,
          backgroundColor: AppTheme.profitGreen,
          onPressed: () {
            Navigator.pop(context);
            _startBot();
          },
        ),
        TikTokModalButton(
          text: l10n.cancel,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  void _showStopBotModal() {
    final l10n = context.l10n;
    HapticFeedback.mediumImpact();

    showTikTokModal(
      context: context,
      title: l10n.aiBotStop,
      message: l10n.aiBotConfirmStop,
      actions: [
        TikTokModalButton(
          text: l10n.aiBotStop,
          isPrimary: true,
          icon: Icons.stop_circle,
          backgroundColor: AppTheme.lossRed,
          onPressed: () {
            Navigator.pop(context);
            _stopBot();
          },
        ),
        TikTokModalButton(
          text: l10n.cancel,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  void _showEmergencyStopModal() {
    final l10n = context.l10n;
    HapticFeedback.heavyImpact();

    showTikTokModal(
      context: context,
      title: l10n.aiBotEmergencyStop,
      message: l10n.aiBotConfirmEmergency,
      actions: [
        TikTokModalButton(
          text: l10n.aiBotEmergencyStop,
          isPrimary: true,
          icon: Icons.warning,
          backgroundColor: AppTheme.lossRed,
          onPressed: () {
            Navigator.pop(context);
            _emergencyStopBot();
          },
        ),
        TikTokModalButton(
          text: l10n.cancel,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Future<void> _startBot() async {
    final l10n = context.l10n;
    try {
      await ref.read(aiBotStatusNotifierProvider.notifier).start();
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.aiBotStartedSuccess),
            backgroundColor: AppTheme.profitGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: ${e.toString()}'),
            backgroundColor: AppTheme.lossRed,
          ),
        );
      }
    }
  }

  Future<void> _stopBot() async {
    final l10n = context.l10n;
    try {
      await ref.read(aiBotStatusNotifierProvider.notifier).stop();
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.aiBotStoppedSuccess),
            backgroundColor: AppTheme.profitGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: ${e.toString()}'),
            backgroundColor: AppTheme.lossRed,
          ),
        );
      }
    }
  }

  Future<void> _pauseBot() async {
    final l10n = context.l10n;
    try {
      await ref.read(aiBotStatusNotifierProvider.notifier).pause();
      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.aiBotPaused} ${l10n.success}'),
            backgroundColor: AppTheme.warningYellow,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: ${e.toString()}'),
            backgroundColor: AppTheme.lossRed,
          ),
        );
      }
    }
  }

  Future<void> _resumeBot() async {
    final l10n = context.l10n;
    try {
      await ref.read(aiBotStatusNotifierProvider.notifier).resume();
      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bot resumed ${l10n.success}'),
            backgroundColor: AppTheme.profitGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: ${e.toString()}'),
            backgroundColor: AppTheme.lossRed,
          ),
        );
      }
    }
  }

  Future<void> _emergencyStopBot() async {
    final l10n = context.l10n;
    try {
      await ref.read(aiBotStatusNotifierProvider.notifier).emergencyStop();
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency Stop Activated'),
            backgroundColor: AppTheme.lossRed,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: ${e.toString()}'),
            backgroundColor: AppTheme.lossRed,
          ),
        );
      }
    }
  }

  Color _getStatusColor(bool running, bool paused, bool emergencyStop) {
    if (emergencyStop) return AppTheme.lossRed;
    if (paused) return AppTheme.warningYellow;
    if (running) return AppTheme.profitGreen;
    return AppTheme.neutralGray;
  }

  String _getStatusText(bool running, bool paused, bool emergencyStop) {
    final l10n = context.l10n;
    if (emergencyStop) return 'EMERGENCY STOP';
    if (paused) return l10n.aiBotPaused.toUpperCase();
    if (running) return l10n.aiBotRunning.toUpperCase();
    return l10n.aiBotStopped.toUpperCase();
  }

  IconData _getStatusIcon(bool running, bool paused, bool emergencyStop) {
    if (emergencyStop) return Icons.warning;
    if (paused) return Icons.pause_circle;
    if (running) return Icons.play_circle_filled;
    return Icons.stop_circle;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final statusAsync = ref.watch(aiBotStatusNotifierProvider);
    final positionsAsync = ref.watch(aiBotPositionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aiBotTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AiBotConfigScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: statusAsync.when(
          data: (status) {
            final statusColor = _getStatusColor(
              status.running,
              status.paused,
              status.emergencyStop,
            );
            final statusText = _getStatusText(
              status.running,
              status.paused,
              status.emergencyStop,
            );
            final statusIcon = _getStatusIcon(
              status.running,
              status.paused,
              status.emergencyStop,
            );

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Status Card
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(statusIcon, size: 32, color: statusColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.aiBotStatus,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      statusText,
                                      style:
                                          theme.textTheme.labelMedium?.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Health Badge
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: status.isHealthy
                                  ? AppTheme.profitGreen.withOpacity(0.2)
                                  : AppTheme.warningYellow.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: status.isHealthy
                                    ? AppTheme.profitGreen
                                    : AppTheme.warningYellow,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  status.isHealthy
                                      ? Icons.check_circle
                                      : Icons.warning,
                                  color: status.isHealthy
                                      ? AppTheme.profitGreen
                                      : AppTheme.warningYellow,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  status.isHealthy ? 'Healthy' : 'Warning',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: status.isHealthy
                                        ? AppTheme.profitGreen
                                        : AppTheme.warningYellow,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatusInfo(
                              l10n.uptime,
                              status.uptimeFormatted,
                              theme,
                            ),
                            _buildStatusInfo(
                              l10n.aiBotOpenPositions,
                              status.openPositions.toString(),
                              theme,
                            ),
                            _buildStatusInfo(
                              'Mode',
                              status.config.dryRun ? 'DRY RUN' : 'LIVE',
                              theme,
                            ),
                          ],
                        ),
                        if (status.lastAnalysisAt != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Last Analysis: ${_formatDateTime(status.lastAnalysisAt!)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Metrics Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bot Metrics',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (status.analysisCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.profitGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${status.successRate.toStringAsFixed(1)}% Success',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.profitGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    MetricCard(
                      icon: Icons.analytics,
                      title: l10n.aiBotAnalysisCount,
                      value: status.analysisCount.toString(),
                      change: 'Total analyses',
                      isLoading: false,
                    ),
                    MetricCard(
                      icon: Icons.check_circle,
                      title: l10n.aiBotExecutionCount,
                      value: status.executionCount.toString(),
                      change: status.analysisCount > 0
                          ? '${(status.executionRate * 100).toStringAsFixed(1)}% exec rate'
                          : 'Executed',
                      changeColor: AppTheme.profitGreen,
                      isLoading: false,
                    ),
                    MetricCard(
                      icon: Icons.error,
                      title: l10n.aiBotErrorCount,
                      value: status.errorCount.toString(),
                      change: status.consecutiveErrors > 0
                          ? '${status.consecutiveErrors} consecutive'
                          : 'No errors',
                      changeColor: status.consecutiveErrors >= 3
                          ? AppTheme.lossRed
                          : status.consecutiveErrors > 0
                              ? AppTheme.warningYellow
                              : AppTheme.profitGreen,
                      isLoading: false,
                    ),
                    MetricCard(
                      icon: Icons.account_balance_wallet,
                      title: l10n.aiBotOpenPositions,
                      value: status.openPositions.toString(),
                      change: 'Active positions',
                      isLoading: false,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Daily Limits Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daily Limits',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (status.hasReachedDailyLimit)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lossRed.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.warning,
                              size: 14,
                              color: AppTheme.lossRed,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Limit Reached',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.lossRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildLimitProgress(
                          l10n.aiBotDailyLoss,
                          status.dailyLoss.abs(),
                          status.config.maxDailyLossUsd,
                          status.dailyLossPercent,
                          theme,
                        ),
                        const SizedBox(height: 16),
                        _buildLimitProgress(
                          l10n.aiBotDailyTrades,
                          status.dailyTrades.toDouble(),
                          status.config.maxDailyTrades.toDouble(),
                          status.dailyTradesPercent,
                          theme,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Open Positions
                Text(
                  l10n.aiBotOpenPositions,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                positionsAsync.when(
                  data: (positions) {
                    if (positions.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              'No open positions',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: positions.map((position) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              position.isLong
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: position.isLong
                                  ? AppTheme.profitGreen
                                  : AppTheme.lossRed,
                            ),
                            title: Text(
                              '${position.symbol} ${position.side}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Entry: \$${position.entryPrice.toStringAsFixed(4)} | ${position.leverage}x',
                            ),
                            trailing: Text(
                              '\$${position.pnl.toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: position.isProfit
                                    ? AppTheme.profitGreen
                                    : AppTheme.lossRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        '${l10n.error}: ${e.toString()}',
                        style: const TextStyle(color: AppTheme.lossRed),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
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
                  const Icon(Icons.error, color: AppTheme.lossRed, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    '${l10n.error}: ${e.toString()}',
                    style: const TextStyle(color: AppTheme.lossRed),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _onRefresh,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.refresh),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: statusAsync.maybeWhen(
        data: (status) => _buildControlButtons(status, theme, l10n),
        orElse: () => null,
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

  Widget _buildLimitProgress(
    String label,
    double current,
    double max,
    double percent,
    ThemeData theme,
  ) {
    Color progressColor = AppTheme.profitGreen;
    if (percent > 80) {
      progressColor = AppTheme.lossRed;
    } else if (percent > 50) {
      progressColor = AppTheme.warningYellow;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            Text(
              '${current.toStringAsFixed(1)} / ${max.toStringAsFixed(1)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percent / 100,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
        ),
        const SizedBox(height: 4),
        Text(
          '${percent.toStringAsFixed(1)}% used',
          style: theme.textTheme.bodySmall?.copyWith(
            color: progressColor,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons(
    dynamic status,
    ThemeData theme,
    dynamic l10n,
  ) {
    final bool running = status.running;
    final bool paused = status.paused;
    final bool emergencyStop = status.emergencyStop;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (!running || emergencyStop) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showStartBotModal,
                      icon: const Icon(Icons.play_circle_filled),
                      label: Text(l10n.aiBotStart),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.profitGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
                if (running && !paused && !emergencyStop) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pauseBot,
                      icon: const Icon(Icons.pause_circle),
                      label: Text(l10n.aiBotPause),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.warningYellow,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showStopBotModal,
                      icon: const Icon(Icons.stop_circle),
                      label: Text(l10n.aiBotStop),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lossRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
                if (paused) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _resumeBot,
                      icon: const Icon(Icons.play_circle_filled),
                      label: Text(l10n.aiBotResume),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.profitGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showStopBotModal,
                      icon: const Icon(Icons.stop_circle),
                      label: Text(l10n.aiBotStop),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lossRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (running && !emergencyStop) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showEmergencyStopModal,
                  icon: const Icon(Icons.warning),
                  label: Text(l10n.aiBotEmergencyStop),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.lossRed,
                    side: const BorderSide(color: AppTheme.lossRed),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
