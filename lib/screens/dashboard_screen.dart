import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../l10n/l10n.dart';
import '../widgets/metric_card.dart';

/// Dashboard screen showing system status and key metrics
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _refreshTimer;
  bool _isLoading = false;
  bool _isEngineRunning = false;

  // Mock data - replace with actual API calls
  String _uptime = '2h 30m';
  String _healthStatus = 'healthy';
  double _totalPnl = 125.50;
  double _dailyPnlChange = 12.3;
  double _winRate = 65.5;
  int _activePositions = 3;
  double _avgLatency = 45.2;

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
    // Example: final data = await scalpingService.getStatus();
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

  void _toggleEngine() {
    HapticFeedback.mediumImpact();
    final l10n = L10n.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          _isEngineRunning ? Icons.stop_circle : Icons.play_circle_filled,
          size: 48,
          color: _isEngineRunning
              ? const Color(0xFFF44336)
              : const Color(0xFF4CAF50),
        ),
        title: Text(_isEngineRunning ? l10n.stopEngine : l10n.startEngine),
        content: Text(
          _isEngineRunning ? l10n.stopEngineMessage : l10n.startEngineMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _performEngineToggle();
            },
            style: FilledButton.styleFrom(
              backgroundColor: _isEngineRunning
                  ? const Color(0xFFF44336)
                  : const Color(0xFF4CAF50),
            ),
            child: Text(_isEngineRunning ? l10n.stop : l10n.start),
          ),
        ],
      ),
    );
  }

  Future<void> _performEngineToggle() async {
    setState(() => _isLoading = true);

    // TODO: Replace with actual API call
    // Example: await scalpingService.toggleEngine(!_isEngineRunning);
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isEngineRunning = !_isEngineRunning;
        _isLoading = false;
      });

      HapticFeedback.heavyImpact();
      final l10n = L10n.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEngineRunning
                ? l10n.engineStartedSuccess
                : l10n.engineStoppedSuccess,
          ),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Color _getHealthColor() {
    switch (_healthStatus.toLowerCase()) {
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

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Scaffold(
        body: ListView(
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
                                _isEngineRunning
                                    ? Icons.play_circle_filled
                                    : Icons.stop_circle,
                                size: 32,
                                color: _isEngineRunning
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      L10n.of(context).scalpingEngine,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isEngineRunning
                                          ? L10n.of(context).running
                                          : L10n.of(context).stopped,
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getHealthColor().withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getHealthColor(),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _healthStatus.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _getHealthColor(),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatusInfo(
                            L10n.of(context).uptime, _uptime, theme),
                        _buildStatusInfo(
                          L10n.of(context).activePositions,
                          _activePositions.toString(),
                          theme,
                        ),
                        _buildStatusInfo(
                          L10n.of(context).avgLatency,
                          '${_avgLatency.toStringAsFixed(0)}${L10n.of(context).ms}',
                          theme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Metrics Grid
            Text(
              L10n.of(context).keyMetrics,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
                  icon: Icons.attach_money,
                  title: L10n.of(context).totalPnl,
                  value:
                      '${_totalPnl >= 0 ? '+' : ''}\$${_totalPnl.toStringAsFixed(2)}',
                  change:
                      '${_dailyPnlChange >= 0 ? '+' : ''}${_dailyPnlChange.toStringAsFixed(1)}% ${L10n.of(context).today}',
                  changeColor: _dailyPnlChange >= 0
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFF44336),
                  isLoading: _isLoading,
                ),
                MetricCard(
                  icon: Icons.percent,
                  title: L10n.of(context).winRate,
                  value: '${_winRate.toStringAsFixed(1)}%',
                  change: _winRate >= 50
                      ? L10n.of(context).aboveTarget
                      : L10n.of(context).belowTarget,
                  changeColor: _winRate >= 50
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFF44336),
                  isLoading: _isLoading,
                ),
                MetricCard(
                  icon: Icons.account_balance_wallet,
                  title: L10n.of(context).activePositions,
                  value: _activePositions.toString(),
                  change: L10n.of(context).openTrades,
                  isLoading: _isLoading,
                ),
                MetricCard(
                  icon: Icons.speed,
                  title: L10n.of(context).avgLatency,
                  value: '${_avgLatency.toStringAsFixed(0)}${L10n.of(context).ms}',
                  change: _avgLatency < 100
                      ? L10n.of(context).excellent
                      : L10n.of(context).good,
                  changeColor: _avgLatency < 100
                      ? const Color(0xFF4CAF50)
                      : Colors.orange,
                  isLoading: _isLoading,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Quick Actions
            Text(
              L10n.of(context).quickActions,
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
                    title: Text(L10n.of(context).refreshData),
                    subtitle: Text(L10n.of(context).lastUpdatedNow),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _onRefresh();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.analytics),
                    title: Text(L10n.of(context).viewAnalytics),
                    subtitle: Text(L10n.of(context).detailedCharts),
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
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _toggleEngine,
          icon: Icon(
            _isEngineRunning ? Icons.stop : Icons.play_arrow,
          ),
          label: Text(_isEngineRunning
              ? L10n.of(context).stopEngine
              : L10n.of(context).startEngine),
          backgroundColor: _isEngineRunning
              ? const Color(0xFFF44336)
              : const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildStatusInfo(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
