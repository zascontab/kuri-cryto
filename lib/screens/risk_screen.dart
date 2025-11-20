
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuri_crypto/models/risk_limits.dart';
import '../widgets/risk_sentinel_card.dart';
import '../widgets/tiktok_modal.dart';
import '../l10n/l10n_export.dart';
import '../providers/risk_sentinel_provider.dart';
import '../providers/risk_provider.dart';

/// Risk monitor screen with Risk Sentinel state
class RiskScreen extends ConsumerStatefulWidget {
  const RiskScreen({super.key});

  @override
  ConsumerState<RiskScreen> createState() => _RiskScreenState();
}

class _RiskScreenState extends ConsumerState<RiskScreen> {
  bool _isProcessing = false;

  Future<void> _onRefresh() async {
    await ref.read(riskSentinelProvider.notifier).refresh();
    await ref.read(riskLimitsProvider.notifier).refresh();
  }

  Future<void> _toggleKillSwitch(bool currentlyActive) async {
    if (_isProcessing) return;

    final l10n = context.l10n;

    // Show confirmation dialog
    final confirmed = await _showKillSwitchConfirmationDialog(
      context,
      currentlyActive,
    );

    if (!confirmed || !mounted) return;

    // Heavy haptic feedback for critical action
    HapticFeedback.heavyImpact();

    setState(() => _isProcessing = true);

    try {
      final notifier = ref.read(riskSentinelProvider.notifier);
      final success = currentlyActive
          ? await notifier.deactivateKillSwitch()
          : await notifier.activateKillSwitch('Manual activation by user');

      if (!mounted) return;

      if (success) {
        // Success feedback
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentlyActive
                  ? l10n.killSwitchDeactivated
                  : l10n.killSwitchActivated,
            ),
            backgroundColor: currentlyActive
                ? const Color(0xFF4CAF50)
                : const Color(0xFFF44336),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: l10n.ok,
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      } else {
        throw Exception('Failed to toggle kill switch');
      }
    } catch (e) {
      if (!mounted) return;

      // Error feedback
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorOccurred(error: e.toString())),
          backgroundColor: const Color(0xFFF44336),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: l10n.dismiss,
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<bool> _showKillSwitchConfirmationDialog(
    BuildContext context,
    bool currentlyActive,
  ) async {
    final l10n = context.l10n;

    if (currentlyActive) {
      // Double confirmation for deactivation
      return await _showDoubleConfirmationDialog(context);
    } else {
      // Single confirmation for activation with warnings
      return await _showActivationConfirmationDialog(context);
    }
  }

  Future<bool> _showActivationConfirmationDialog(BuildContext context) async {
    final l10n = context.l10n;

    final result = await showTikTokModal<bool>(
      context: context,
      isDismissible: false,
      title: l10n.activateKillSwitch,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF44336),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.killSwitchWarning,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF44336).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFF44336).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWarningItem(l10n.allTradingWillStop),
                const SizedBox(height: 8),
                _buildWarningItem(l10n.allPositionsWillClose),
                const SizedBox(height: 8),
                _buildWarningItem(l10n.requiresManualReactivation),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.areYouSure,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TikTokModalButton(
          text: l10n.activate,
          isPrimary: true,
          backgroundColor: const Color(0xFFF44336),
          onPressed: () => Navigator.pop(context, true),
        ),
        TikTokModalButton(
          text: l10n.cancel,
          onPressed: () => Navigator.pop(context, false),
        ),
      ],
    );

    return result ?? false;
  }

  Future<bool> _showDoubleConfirmationDialog(BuildContext context) async {
    final l10n = context.l10n;

    // First confirmation
    final firstConfirmation = await showTikTokModal<bool>(
      context: context,
      title: l10n.deactivateKillSwitch,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.blue,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.thisWillResumeTrading,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TikTokModalButton(
          text: l10n.continue_,
          isPrimary: true,
          backgroundColor: Colors.blue,
          onPressed: () => Navigator.pop(context, true),
        ),
        TikTokModalButton(
          text: l10n.cancel,
          onPressed: () => Navigator.pop(context, false),
        ),
      ],
    );

    if (firstConfirmation != true || !context.mounted) return false;

    // Second confirmation
    final secondConfirmation = await showTikTokModal<bool>(
      context: context,
      isDismissible: false,
      title: l10n.confirmDeactivation,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF4CAF50),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.confirmResumeTrading,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TikTokModalButton(
          text: l10n.resume,
          isPrimary: true,
          backgroundColor: const Color(0xFF4CAF50),
          onPressed: () => Navigator.pop(context, true),
        ),
        TikTokModalButton(
          text: l10n.cancel,
          onPressed: () => Navigator.pop(context, false),
        ),
      ],
    );

    return secondConfirmation ?? false;
  }

  Widget _buildWarningItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.circle,
          size: 8,
          color: Color(0xFFF44336),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _editRiskLimits(dynamic limits) {
    HapticFeedback.lightImpact();
    final e = context.l10n;
    showTikTokModal(
      context: context,
      isDismissible: false,
      actions: [TikTokModalButton(text: e.editRiskLimits)],
      content: _RiskLimitsContent(
        maxPositionSize: limits.parameters.maxPositionSizeUsd,
        maxTotalExposure: limits.parameters.maxTotalExposureUsd,
        stopLossPercent: limits.parameters.stopLossPercent,
        takeProfitPercent: limits.parameters.takeProfitPercent,
        maxDailyLoss: limits.parameters.maxDailyLossUsd,
        maxConsecutiveLosses: limits.parameters.maxConsecutiveLosses,
        onSave: (newLimits) async {
          final l10n = context.l10n;

          try {
            // Create RiskParameters object
            final riskParams = RiskParameters(
              maxPositionSizeUsd: newLimits['maxPositionSize']!,
              maxTotalExposureUsd: newLimits['maxTotalExposure']!,
              stopLossPercent: newLimits['stopLossPercent']!,
              takeProfitPercent: newLimits['takeProfitPercent']!,
              maxDailyLossUsd: newLimits['maxDailyLoss']!,
              maxConsecutiveLosses: newLimits['maxConsecutiveLosses']!.toInt(),
            );

            // Update via provider
            final success = await ref
                .read(riskLimitsUpdaterProvider.notifier)
                .updateLimits(riskParams);

            if (!mounted) return;

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.riskLimitsUpdated),
                  backgroundColor: const Color(0xFF4CAF50),
                ),
              );
            }
          } catch (e) {
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.errorOccurred(error: e.toString())),
                backgroundColor: const Color(0xFFF44336),
              ),
            );
          }
        },
      ),
    );
  }

  void _changeRiskMode() {
    HapticFeedback.lightImpact();

    final l10n = context.l10n;
    showTikTokModal(
      context: context,
      title: l10n.selectRiskMode,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRiskModeOption(
            l10n.conservative,
            l10n.lowerRiskSmallerPositions,
            const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 12),
          _buildRiskModeOption(
            l10n.normal,
            l10n.balancedRiskReward,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildRiskModeOption(
            l10n.aggressive,
            l10n.higherRiskLargerPositions,
            const Color(0xFFF44336),
          ),
        ],
      ),
      actions: [
        TikTokModalButton(
          text: l10n.cancel,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildRiskModeOption(String mode, String description, Color color) {
    final riskStateAsync = ref.watch(riskSentinelProvider);
    final currentMode = riskStateAsync.maybeWhen(
      data: (state) => state.riskMode,
      orElse: () => 'Normal',
    );
    final isSelected = currentMode == mode;

    return InkWell(
      onTap: () {
        // TODO: Implement API endpoint to change risk mode
        Navigator.pop(context);

        HapticFeedback.mediumImpact();
        final l10n = context.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.riskModeChanged(mode: mode)),
            backgroundColor: color,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : null,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isSelected)
                  Icon(Icons.check_circle, color: color, size: 20),
                if (isSelected) const SizedBox(width: 8),
                Text(
                  mode,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final riskStateAsync = ref.watch(riskSentinelProvider);
    final limitsAsync = ref.watch(riskLimitsProvider);

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: riskStateAsync.when(
        data: (riskState) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Kill Switch Active Banner
              if (riskState.killSwitchActive) _buildKillSwitchBanner(l10n),

              // Risk Sentinel Card
              RiskSentinelCard(
                dailyDrawdown: riskState.currentDrawdownDaily,
                weeklyDrawdown: riskState.currentDrawdownWeekly,
                monthlyDrawdown: riskState.currentDrawdownMonthly,
                maxDailyDrawdown: riskState.maxDailyDrawdown,
                maxWeeklyDrawdown: riskState.maxWeeklyDrawdown,
                maxMonthlyDrawdown: riskState.maxMonthlyDrawdown,
                totalExposure: riskState.totalExposure,
                maxExposure: riskState.maxTotalExposure,
                consecutiveLosses: riskState.consecutiveLosses,
                maxConsecutiveLosses: riskState.maxConsecutiveLosses,
                riskMode: riskState.riskMode,
                killSwitchActive: riskState.killSwitchActive,
                isProcessing: _isProcessing,
                onKillSwitch: () =>
                    _toggleKillSwitch(riskState.killSwitchActive),
              ),

              const SizedBox(height: 20),

              // Risk Limits Card
              limitsAsync.when(
                data: (limits) => Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.rule,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.riskLimits,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editRiskLimits(limits),
                              tooltip: l10n.editLimits,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildLimitRow(
                          l10n.maxPositionSize,
                          '\$${limits.parameters.maxPositionSizeUsd.toStringAsFixed(0)}',
                          theme,
                        ),
                        _buildLimitRow(
                          l10n.maxTotalExposure,
                          '\$${limits.parameters.maxTotalExposureUsd.toStringAsFixed(0)}',
                          theme,
                        ),
                        _buildLimitRow(
                          l10n.stopLossPercent,
                          '${limits.parameters.stopLossPercent.toStringAsFixed(1)}%',
                          theme,
                        ),
                        _buildLimitRow(
                          l10n.takeProfitPercent,
                          '${limits.parameters.takeProfitPercent.toStringAsFixed(1)}%',
                          theme,
                        ),
                        _buildLimitRow(
                          l10n.maxDailyLoss,
                          '\$${limits.parameters.maxDailyLossUsd.toStringAsFixed(0)}',
                          theme,
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, _) => Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: $error'),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Risk Mode Selector
              Card(
                elevation: 2,
                child: InkWell(
                  onTap: _changeRiskMode,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.tune,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.riskMode,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.tapToChangeMode,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getRiskModeColor(riskState.riskMode)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            riskState.riskMode,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: _getRiskModeColor(riskState.riskMode),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Exposure by Symbol Card
              if (riskState.exposureBySymbol.isNotEmpty)
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
                              Icons.pie_chart,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.exposureBySymbol,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...riskState.exposureBySymbol.entries
                            .map((entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _buildExposureBar(
                                    entry.key,
                                    entry.value,
                                    riskState.maxTotalExposure,
                                    theme,
                                  ),
                                ))
                            ,
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading risk data',
                  style: theme.textTheme.titleLarge,
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
          ),
        ),
      ),
    );
  }

  Widget _buildKillSwitchBanner(L10n l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF44336).withValues(alpha: 0.15),
        border: Border.all(
          color: const Color(0xFFF44336),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_rounded,
            color: Color(0xFFF44336),
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.killSwitchActive,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF44336),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.tradingDisabled,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitRow(String label, String value, ThemeData theme) {
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

  Widget _buildExposureBar(
    String symbol,
    double exposure,
    double maxExposure,
    ThemeData theme,
  ) {
    final percentage = maxExposure > 0 ? exposure / maxExposure : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              symbol,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '\$${exposure.toStringAsFixed(0)} (${(percentage * 100).toStringAsFixed(1)}%)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Color _getRiskModeColor(String mode) {
    switch (mode) {
      case 'Conservative':
        return const Color(0xFF4CAF50);
      case 'Aggressive':
        return const Color(0xFFF44336);
      default:
        return Colors.blue;
    }
  }
}

// Risk limits edit content (used in TikTokModal)
class _RiskLimitsContent extends StatefulWidget {
  final double maxPositionSize;
  final double maxTotalExposure;
  final double stopLossPercent;
  final double takeProfitPercent;
  final double maxDailyLoss;
  final int maxConsecutiveLosses;
  final Function(Map<String, double>) onSave;

  const _RiskLimitsContent({
    required this.maxPositionSize,
    required this.maxTotalExposure,
    required this.stopLossPercent,
    required this.takeProfitPercent,
    required this.maxDailyLoss,
    required this.maxConsecutiveLosses,
    required this.onSave,
  });

  @override
  State<_RiskLimitsContent> createState() => _RiskLimitsContentState();
}

class _RiskLimitsContentState extends State<_RiskLimitsContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _maxPositionSizeController;
  late TextEditingController _maxTotalExposureController;
  late TextEditingController _stopLossController;
  late TextEditingController _takeProfitController;
  late TextEditingController _maxDailyLossController;
  late TextEditingController _maxConsecutiveLossesController;

  @override
  void initState() {
    super.initState();
    _maxPositionSizeController = TextEditingController(
      text: widget.maxPositionSize.toStringAsFixed(0),
    );
    _maxTotalExposureController = TextEditingController(
      text: widget.maxTotalExposure.toStringAsFixed(0),
    );
    _stopLossController = TextEditingController(
      text: widget.stopLossPercent.toStringAsFixed(1),
    );
    _takeProfitController = TextEditingController(
      text: widget.takeProfitPercent.toStringAsFixed(1),
    );
    _maxDailyLossController = TextEditingController(
      text: widget.maxDailyLoss.toStringAsFixed(0),
    );
    _maxConsecutiveLossesController = TextEditingController(
      text: widget.maxConsecutiveLosses.toString(),
    );
  }

  @override
  void dispose() {
    _maxPositionSizeController.dispose();
    _maxTotalExposureController.dispose();
    _stopLossController.dispose();
    _takeProfitController.dispose();
    _maxDailyLossController.dispose();
    _maxConsecutiveLossesController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final limits = {
        'maxPositionSize': double.parse(_maxPositionSizeController.text),
        'maxTotalExposure': double.parse(_maxTotalExposureController.text),
        'stopLossPercent': double.parse(_stopLossController.text),
        'takeProfitPercent': double.parse(_takeProfitController.text),
        'maxDailyLoss': double.parse(_maxDailyLossController.text),
        'maxConsecutiveLosses':
            double.parse(_maxConsecutiveLossesController.text),
      };

      Navigator.pop(context);
      widget.onSave(limits);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return TikTokModal(
      title: l10n.editRiskLimits,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _maxPositionSizeController,
              decoration: InputDecoration(
                labelText: l10n.maxPositionSize,
                prefixText: '\$',
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterValue;
                }
                final val = double.tryParse(value);
                if (val == null || val <= 0) {
                  return l10n.pleaseEnterValidAmount;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _maxTotalExposureController,
              decoration: InputDecoration(
                labelText: l10n.maxTotalExposure,
                prefixText: '\$',
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterValue;
                }
                final val = double.tryParse(value);
                if (val == null || val <= 0) {
                  return l10n.pleaseEnterValidAmount;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stopLossController,
              decoration: InputDecoration(
                labelText: l10n.stopLossPercent,
                suffixText: '%',
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterValue;
                }
                final val = double.tryParse(value);
                if (val == null || val <= 0 || val > 100) {
                  return l10n.pleaseEnterValidPercentage;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _takeProfitController,
              decoration: InputDecoration(
                labelText: l10n.takeProfitPercent,
                suffixText: '%',
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterValue;
                }
                final val = double.tryParse(value);
                if (val == null || val <= 0 || val > 100) {
                  return l10n.pleaseEnterValidPercentage;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _maxDailyLossController,
              decoration: InputDecoration(
                labelText: l10n.maxDailyLoss,
                prefixText: '\$',
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterValue;
                }
                final val = double.tryParse(value);
                if (val == null || val <= 0) {
                  return l10n.pleaseEnterValidAmount;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _maxConsecutiveLossesController,
              decoration: InputDecoration(
                labelText: l10n.maxConsecutiveLosses,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterValue;
                }
                final val = int.tryParse(value);
                if (val == null || val <= 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
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
