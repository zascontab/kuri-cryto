import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          _isEngineRunning ? Icons.stop_circle : Icons.play_circle_filled,
          size: 48,
          color: _isEngineRunning ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
        ),
        title: Text(_isEngineRunning ? 'Stop Engine' : 'Start Engine'),
        content: Text(
          _isEngineRunning
              ? 'This will stop the scalping engine. Open positions will remain active. Continue?'
              : 'This will start the scalping engine and begin trading. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
            child: Text(_isEngineRunning ? 'Stop' : 'Start'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEngineRunning
                ? 'Engine started successfully'
                : 'Engine stopped successfully',
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
      child: ListView(
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
                      Row(
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scalping Engine',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isEngineRunning ? 'Running' : 'Stopped',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
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
                          color: _getHealthColor().withOpacity(0.2),
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
                      _buildStatusInfo('Uptime', _uptime, theme),
                      _buildStatusInfo(
                        'Positions',
                        _activePositions.toString(),
                        theme,
                      ),
                      _buildStatusInfo(
                        'Latency',
                        '${_avgLatency.toStringAsFixed(0)}ms',
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
            'Key Metrics',
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
                title: 'Total P&L',
                value: '${_totalPnl >= 0 ? '+' : ''}\$${_totalPnl.toStringAsFixed(2)}',
                change: '${_dailyPnlChange >= 0 ? '+' : ''}${_dailyPnlChange.toStringAsFixed(1)}% today',
                changeColor: _dailyPnlChange >= 0
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFF44336),
                isLoading: _isLoading,
              ),
              MetricCard(
                icon: Icons.percent,
                title: 'Win Rate',
                value: '${_winRate.toStringAsFixed(1)}%',
                change: _winRate >= 50 ? 'Above target' : 'Below target',
                changeColor: _winRate >= 50
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFF44336),
                isLoading: _isLoading,
              ),
              MetricCard(
                icon: Icons.account_balance_wallet,
                title: 'Active Positions',
                value: _activePositions.toString(),
                change: 'Open trades',
                isLoading: _isLoading,
              ),
              MetricCard(
                icon: Icons.speed,
                title: 'Avg Latency',
                value: '${_avgLatency.toStringAsFixed(0)}ms',
                change: _avgLatency < 100 ? 'Excellent' : 'Good',
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
            'Quick Actions',
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
                  title: const Text('Refresh Data'),
                  subtitle: const Text('Last updated just now'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _onRefresh();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.analytics),
                  title: const Text('View Analytics'),
                  subtitle: const Text('Detailed performance charts'),
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
        label: Text(_isEngineRunning ? 'Stop Engine' : 'Start Engine'),
        backgroundColor: _isEngineRunning
            ? const Color(0xFFF44336)
            : const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
