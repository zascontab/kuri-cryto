import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/optimization.dart';
import '../providers/optimization_provider.dart';
import '../l10n/l10n.dart';
import '../widgets/tiktok_modal.dart';
import 'optimization_results_screen.dart';

/// Optimization History Screen
///
/// Displays list of past optimizations
class OptimizationHistoryScreen extends ConsumerWidget {
  const OptimizationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = L10n.of(context);
    final historyAsync = ref.watch(optimizationHistoryProvider());

    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) {
          return _buildEmptyState(theme, l10n);
        }
        return _buildHistoryList(context, theme, l10n, history, ref);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorState(theme, l10n, error),
    );
  }

  Widget _buildEmptyState(ThemeData theme, L10n l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noOptimizationsYet,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, L10n l10n, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.errorLoadingData,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    ThemeData theme,
    L10n l10n,
    List<OptimizationSummary> history,
    WidgetRef ref,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(optimizationHistoryProvider().notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final optimization = history[index];
          return _buildOptimizationCard(context, theme, l10n, optimization, ref);
        },
      ),
    );
  }

  Widget _buildOptimizationCard(
    BuildContext context,
    ThemeData theme,
    L10n l10n,
    OptimizationSummary optimization,
    WidgetRef ref,
  ) {
    Color statusColor;
    IconData statusIcon;

    if (optimization.isCompleted) {
      statusColor = const Color(0xFF10B981);
      statusIcon = Icons.check_circle;
    } else if (optimization.isRunning) {
      statusColor = const Color(0xFF3B82F6);
      statusIcon = Icons.pending;
    } else if (optimization.isFailed) {
      statusColor = const Color(0xFFEF4444);
      statusIcon = Icons.error;
    } else {
      statusColor = theme.colorScheme.onSurfaceVariant;
      statusIcon = Icons.cancel;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OptimizationResultsScreen(
                optimizationId: optimization.id,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          optimization.strategyName.replaceAll('_', ' ').toUpperCase(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          optimization.symbol,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusText(l10n, optimization.status),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      theme,
                      Icons.tune,
                      optimization.optimizationMethod.replaceAll('_', ' ').toUpperCase(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      theme,
                      Icons.flag,
                      optimization.objective.replaceAll('_', ' ').toUpperCase(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.started,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy HH:mm').format(optimization.startedAt),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  if (optimization.bestScore != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.bestScore,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          optimization.bestScore!.toStringAsFixed(4),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10n.totalCombinations}: ${optimization.totalCombinations}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        iconSize: 20,
                        onPressed: () => _deleteOptimization(
                          context,
                          l10n,
                          optimization.id,
                          ref,
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(L10n l10n, String status) {
    switch (status) {
      case 'running':
        return l10n.running;
      case 'completed':
        return l10n.completed;
      case 'failed':
        return l10n.failed;
      case 'cancelled':
        return l10n.cancelled;
      default:
        return status;
    }
  }

  Future<void> _deleteOptimization(
    BuildContext context,
    L10n l10n,
    String optimizationId,
    WidgetRef ref,
  ) async {
    final confirmed = await showTikTokModal<bool>(
      context: context,
      title: l10n.deleteOptimization,
      message: l10n.deleteOptimizationConfirmation,
      actions: [
        TikTokModalButton(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TikTokModalButton(
          label: l10n.delete,
          isPrimary: true,
          backgroundColor: Colors.red,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );

    if (confirmed != true) return;

    try {
      await ref.read(optimizationHistoryProvider().notifier).delete(optimizationId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.optimizationDeletedSuccessfully),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
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
