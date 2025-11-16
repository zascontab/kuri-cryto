import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../widgets/risk_sentinel_card.dart';
import '../l10n/l10n.dart';

/// Risk monitor screen with Risk Sentinel state
class RiskScreen extends StatefulWidget {
  const RiskScreen({super.key});

  @override
  State<RiskScreen> createState() => _RiskScreenState();
}

class _RiskScreenState extends State<RiskScreen> {
  Timer? _refreshTimer;
  bool _isLoading = false;

  // Mock data - replace with actual API calls
  double _dailyDrawdown = 2.3;
  double _weeklyDrawdown = 4.8;
  double _monthlyDrawdown = 8.5;
  double _maxDailyDrawdown = 5.0;
  double _maxWeeklyDrawdown = 10.0;
  double _maxMonthlyDrawdown = 15.0;
  double _totalExposure = 3500.0;
  double _maxExposure = 5000.0;
  int _consecutiveLosses = 2;
  int _maxConsecutiveLosses = 5;
  String _riskMode = 'Normal';
  bool _killSwitchActive = false;

  // Risk limits
  double _maxPositionSize = 1000.0;
  double _maxTotalExposure = 5000.0;
  double _stopLossPercent = 2.0;
  double _takeProfitPercent = 3.0;
  double _maxDailyLoss = 250.0;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
    _loadData();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) => _loadData(),
    );
  }

  Future<void> _loadData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    // TODO: Replace with actual API call
    // Example: final data = await riskService.getSentinelState();
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isLoading = false;
        // Update with real data
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  void _toggleKillSwitch() {
    HapticFeedback.heavyImpact();

    // TODO: Replace with actual API call
    setState(() {
      _killSwitchActive = !_killSwitchActive;
    });

    final l10n = L10n.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _killSwitchActive
              ? l10n.killSwitchActivated
              : l10n.killSwitchDeactivated,
        ),
        backgroundColor: _killSwitchActive
            ? const Color(0xFFF44336)
            : const Color(0xFF4CAF50),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _editRiskLimits() {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => _RiskLimitsDialog(
        maxPositionSize: _maxPositionSize,
        maxTotalExposure: _maxTotalExposure,
        stopLossPercent: _stopLossPercent,
        takeProfitPercent: _takeProfitPercent,
        maxDailyLoss: _maxDailyLoss,
        onSave: (limits) {
          setState(() {
            _maxPositionSize = limits['maxPositionSize']!;
            _maxTotalExposure = limits['maxTotalExposure']!;
            _stopLossPercent = limits['stopLossPercent']!;
            _takeProfitPercent = limits['takeProfitPercent']!;
            _maxDailyLoss = limits['maxDailyLoss']!;
          });

          final l10n = L10n.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.riskLimitsUpdated),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        },
      ),
    );
  }

  void _changeRiskMode() {
    HapticFeedback.lightImpact();

    final l10n = L10n.of(context);
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.selectRiskMode),
        children: [
          _buildRiskModeOption(
            l10n.conservative,
            l10n.lowerRiskSmallerPositions,
            const Color(0xFF4CAF50),
          ),
          _buildRiskModeOption(
            l10n.normal,
            l10n.balancedRiskReward,
            Colors.blue,
          ),
          _buildRiskModeOption(
            l10n.aggressive,
            l10n.higherRiskLargerPositions,
            const Color(0xFFF44336),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskModeOption(String mode, String description, Color color) {
    final isSelected = _riskMode == mode;

    return SimpleDialogOption(
      onPressed: () {
        setState(() => _riskMode = mode);
        Navigator.pop(context);

        HapticFeedback.mediumImpact();
        final l10n = L10n.of(context);
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
    final l10n = L10n.of(context);

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Risk Sentinel Card
          RiskSentinelCard(
            dailyDrawdown: _dailyDrawdown,
            weeklyDrawdown: _weeklyDrawdown,
            monthlyDrawdown: _monthlyDrawdown,
            maxDailyDrawdown: _maxDailyDrawdown,
            maxWeeklyDrawdown: _maxWeeklyDrawdown,
            maxMonthlyDrawdown: _maxMonthlyDrawdown,
            totalExposure: _totalExposure,
            maxExposure: _maxExposure,
            consecutiveLosses: _consecutiveLosses,
            maxConsecutiveLosses: _maxConsecutiveLosses,
            riskMode: _riskMode,
            killSwitchActive: _killSwitchActive,
            onKillSwitch: _toggleKillSwitch,
          ),

          const SizedBox(height: 20),

          // Risk Limits Card
          Card(
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
                        onPressed: _editRiskLimits,
                        tooltip: l10n.editLimits,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLimitRow(
                    l10n.maxPositionSize,
                    '\$${_maxPositionSize.toStringAsFixed(0)}',
                    theme,
                  ),
                  _buildLimitRow(
                    l10n.maxTotalExposure,
                    '\$${_maxTotalExposure.toStringAsFixed(0)}',
                    theme,
                  ),
                  _buildLimitRow(
                    l10n.stopLossPercent,
                    '${_stopLossPercent.toStringAsFixed(1)}%',
                    theme,
                  ),
                  _buildLimitRow(
                    l10n.takeProfitPercent,
                    '${_takeProfitPercent.toStringAsFixed(1)}%',
                    theme,
                  ),
                  _buildLimitRow(
                    l10n.maxDailyLoss,
                    '\$${_maxDailyLoss.toStringAsFixed(0)}',
                    theme,
                  ),
                ],
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
                        color: _getRiskModeColor().withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _riskMode,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: _getRiskModeColor(),
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
                  _buildExposureBar('BTC-USDT', 1500.0, theme),
                  const SizedBox(height: 8),
                  _buildExposureBar('ETH-USDT', 1200.0, theme),
                  const SizedBox(height: 8),
                  _buildExposureBar('DOGE-USDT', 800.0, theme),
                ],
              ),
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

  Widget _buildExposureBar(String symbol, double exposure, ThemeData theme) {
    final percentage = exposure / _maxExposure;

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
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Color _getRiskModeColor() {
    switch (_riskMode) {
      case 'Conservative':
        return const Color(0xFF4CAF50);
      case 'Aggressive':
        return const Color(0xFFF44336);
      default:
        return Colors.blue;
    }
  }
}

// Risk limits edit dialog
class _RiskLimitsDialog extends StatefulWidget {
  final double maxPositionSize;
  final double maxTotalExposure;
  final double stopLossPercent;
  final double takeProfitPercent;
  final double maxDailyLoss;
  final Function(Map<String, double>) onSave;

  const _RiskLimitsDialog({
    required this.maxPositionSize,
    required this.maxTotalExposure,
    required this.stopLossPercent,
    required this.takeProfitPercent,
    required this.maxDailyLoss,
    required this.onSave,
  });

  @override
  State<_RiskLimitsDialog> createState() => _RiskLimitsDialogState();
}

class _RiskLimitsDialogState extends State<_RiskLimitsDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _maxPositionSizeController;
  late TextEditingController _maxTotalExposureController;
  late TextEditingController _stopLossController;
  late TextEditingController _takeProfitController;
  late TextEditingController _maxDailyLossController;

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
  }

  @override
  void dispose() {
    _maxPositionSizeController.dispose();
    _maxTotalExposureController.dispose();
    _stopLossController.dispose();
    _takeProfitController.dispose();
    _maxDailyLossController.dispose();
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
      };

      Navigator.pop(context);
      widget.onSave(limits);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return AlertDialog(
      title: Text(l10n.editRiskLimits),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
