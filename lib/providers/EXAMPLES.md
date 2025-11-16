# Ejemplos de Uso de Providers

Este documento contiene ejemplos prácticos de cómo usar los providers en la aplicación.

## Índice

1. [Dashboard Screen](#1-dashboard-screen)
2. [Positions Screen](#2-positions-screen)
3. [Strategies Screen](#3-strategies-screen)
4. [Risk Monitor](#4-risk-monitor)
5. [WebSocket Connection Indicator](#5-websocket-connection-indicator)
6. [Kill Switch Button](#6-kill-switch-button)
7. [Position Management](#7-position-management)
8. [Strategy Configuration](#8-strategy-configuration)

---

## 1. Dashboard Screen

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/system_provider.dart';
import '../providers/websocket_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemStatus = ref.watch(systemStatusProvider);
    final metrics = ref.watch(metricsProvider);
    final wsState = ref.watch(websocketConnectionStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading Dashboard'),
        actions: [
          // WebSocket status indicator
          _buildConnectionIndicator(wsState),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(systemStatusProvider.notifier).refresh();
          await ref.read(metricsProvider.notifier).refresh();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // System Status Card
            systemStatus.when(
              data: (status) => _SystemStatusCard(status),
              loading: () => const _LoadingCard(),
              error: (error, _) => _ErrorCard(error),
            ),
            const SizedBox(height: 16),

            // Metrics Grid
            metrics.when(
              data: (metrics) => _MetricsGrid(metrics),
              loading: () => const _LoadingCard(),
              error: (error, _) => _ErrorCard(error),
            ),
            const SizedBox(height: 16),

            // Control Buttons
            _buildControlButtons(context, ref, systemStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionIndicator(WebSocketConnectionState state) {
    final color = state == WebSocketConnectionState.connected
        ? Colors.green
        : Colors.red;
    final icon = state == WebSocketConnectionState.connected
        ? Icons.check_circle
        : Icons.error;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildControlButtons(
    BuildContext context,
    WidgetRef ref,
    AsyncValue systemStatus,
  ) {
    return systemStatus.when(
      data: (status) {
        final isRunning = status.running;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: isRunning
                  ? null
                  : () => _startEngine(context, ref),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Engine'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
            ElevatedButton.icon(
              onPressed: !isRunning
                  ? null
                  : () => _stopEngine(context, ref),
              icon: const Icon(Icons.stop),
              label: const Text('Stop Engine'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }

  Future<void> _startEngine(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(systemStatusProvider.notifier).startEngine();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Engine started successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start engine: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopEngine(BuildContext context, WidgetRef ref) async {
    // Confirm before stopping
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Stop'),
        content: const Text('Are you sure you want to stop the engine?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Stop'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(systemStatusProvider.notifier).stopEngine();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Engine stopped'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop engine: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Helper widgets
class _SystemStatusCard extends StatelessWidget {
  final SystemStatusModel status;
  const _SystemStatusCard(this.status);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _StatusRow('Status', status.running ? 'Running' : 'Stopped'),
            _StatusRow('Uptime', status.uptime),
            _StatusRow('Pairs', status.pairsCount.toString()),
            _StatusRow('Active Strategies', status.activeStrategies.toString()),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatusRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
```

---

## 2. Positions Screen

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/position_provider.dart';

class PositionsScreen extends ConsumerWidget {
  const PositionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionsStream = ref.watch(positionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Positions'),
      ),
      body: positionsStream.when(
        data: (positions) {
          if (positions.isEmpty) {
            return const Center(
              child: Text('No open positions'),
            );
          }

          return ListView.builder(
            itemCount: positions.length,
            itemBuilder: (context, index) {
              final position = positions[index];
              return _PositionCard(position);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(positionsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PositionCard extends ConsumerWidget {
  final Position position;
  const _PositionCard(this.position);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pnlColor = position.unrealizedPnl >= 0 ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(
          position.symbol,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${position.side.toUpperCase()} • ${position.strategy}',
        ),
        trailing: Text(
          '\$${position.unrealizedPnl.toStringAsFixed(2)}',
          style: TextStyle(
            color: pnlColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _PositionDetail('Entry', '\$${position.entryPrice}'),
                _PositionDetail('Current', '\$${position.currentPrice}'),
                _PositionDetail('Size', position.size.toString()),
                _PositionDetail('Leverage', '${position.leverage}x'),
                _PositionDetail('Stop Loss', '\$${position.stopLoss}'),
                _PositionDetail('Take Profit', '\$${position.takeProfit}'),
                const Divider(),
                _buildActions(context, ref),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      children: [
        ElevatedButton(
          onPressed: () => _editSlTp(context, ref),
          child: const Text('Edit SL/TP'),
        ),
        ElevatedButton(
          onPressed: () => _moveToBreakeven(context, ref),
          child: const Text('Breakeven'),
        ),
        ElevatedButton(
          onPressed: () => _closePosition(context, ref),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<void> _editSlTp(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (context) => _EditSlTpDialog(position),
    );

    if (result == null) return;

    try {
      await ref.read(slTpUpdaterProvider.notifier).updateSlTp(
            positionId: position.id,
            stopLoss: result['sl'],
            takeProfit: result['tp'],
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SL/TP updated')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _moveToBreakeven(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(breakevenMoverProvider.notifier)
          .moveToBreakeven(position.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Moved to breakeven')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _closePosition(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Position'),
        content: Text(
          'Close ${position.symbol} ${position.side} position?\n\n'
          'Current P&L: \$${position.unrealizedPnl.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Close'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(positionCloserProvider.notifier)
          .closePosition(position.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Position closed')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
```

---

## 3. Strategies Screen

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/strategy_provider.dart';

class StrategiesScreen extends ConsumerWidget {
  const StrategiesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strategies = ref.watch(strategiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Strategies'),
      ),
      body: strategies.when(
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final strategy = list[index];
            return _StrategyCard(strategy);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _StrategyCard extends ConsumerWidget {
  final Strategy strategy;
  const _StrategyCard(this.strategy);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: ListTile(
        title: Text(
          strategy.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: strategy.performance != null
            ? Text(
                'Win Rate: ${(strategy.performance!.winRate * 100).toStringAsFixed(1)}% • '
                'P&L: \$${strategy.performance!.totalPnl.toStringAsFixed(2)}',
              )
            : null,
        trailing: Switch(
          value: strategy.active,
          onChanged: (value) => _toggleStrategy(context, ref),
        ),
        onTap: () => _showStrategyDetails(context, ref),
      ),
    );
  }

  Future<void> _toggleStrategy(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(strategyTogglerProvider.notifier)
          .toggle(strategy.name);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showStrategyDetails(BuildContext context, WidgetRef ref) {
    ref.read(selectedStrategyProvider.notifier).select(strategy);
    Navigator.pushNamed(context, '/strategy-details');
  }
}
```

---

## 4. Risk Monitor

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/risk_provider.dart';

class RiskMonitorWidget extends ConsumerWidget {
  const RiskMonitorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riskState = ref.watch(riskStateProvider);
    final exposure = ref.watch(exposureProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Risk Monitor',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Drawdown
            riskState.when(
              data: (state) => _DrawdownSection(state),
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 16),

            // Exposure
            exposure.when(
              data: (exp) => _ExposureSection(exp),
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawdownSection extends StatelessWidget {
  final RiskState state;
  const _DrawdownSection(this.state);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Drawdown', style: TextStyle(fontWeight: FontWeight.bold)),
        _DrawdownBar('Daily', state.currentDrawdownDaily, 5.0),
        _DrawdownBar('Weekly', state.currentDrawdownWeekly, 10.0),
        _DrawdownBar('Monthly', state.currentDrawdownMonthly, 20.0),
      ],
    );
  }
}

class _DrawdownBar extends StatelessWidget {
  final String label;
  final double current;
  final double max;
  const _DrawdownBar(this.label, this.current, this.max);

  @override
  Widget build(BuildContext context) {
    final percentage = current / max;
    final color = percentage > 0.9
        ? Colors.red
        : percentage > 0.7
            ? Colors.orange
            : Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ${current.toStringAsFixed(2)}%'),
          LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ],
      ),
    );
  }
}
```

---

## 5. WebSocket Connection Indicator

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/websocket_provider.dart';

class WebSocketIndicator extends ConsumerWidget {
  const WebSocketIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(websocketStatusProvider);
    final latency = ref.watch(websocketLatencyProvider);

    return Tooltip(
      message: '${status.message} • ${latency.current}ms',
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIcon(status.color),
              color: _getColor(status.color),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${latency.current}ms',
              style: TextStyle(
                fontSize: 12,
                color: latency.isGood ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(ConnectionStatusColor color) {
    switch (color) {
      case ConnectionStatusColor.success:
        return Icons.check_circle;
      case ConnectionStatusColor.warning:
        return Icons.sync;
      case ConnectionStatusColor.error:
        return Icons.error;
    }
  }

  Color _getColor(ConnectionStatusColor color) {
    switch (color) {
      case ConnectionStatusColor.success:
        return Colors.green;
      case ConnectionStatusColor.warning:
        return Colors.orange;
      case ConnectionStatusColor.error:
        return Colors.red;
    }
  }
}
```

---

## 6. Kill Switch Button

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/risk_provider.dart';

class KillSwitchButton extends ConsumerWidget {
  const KillSwitchButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = ref.watch(killSwitchActiveProvider);

    return ElevatedButton.icon(
      onPressed: () => isActive
          ? _deactivateKillSwitch(context, ref)
          : _activateKillSwitch(context, ref),
      icon: Icon(isActive ? Icons.lock_open : Icons.emergency),
      label: Text(isActive ? 'Deactivate Kill Switch' : 'Kill Switch'),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.orange : Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  Future<void> _activateKillSwitch(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<String>(
      context: context,
      builder: (context) => _KillSwitchDialog(),
    );

    if (confirmed == null || confirmed.isEmpty) return;

    try {
      await ref.read(killSwitchActivatorProvider.notifier)
          .activate(confirmed);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kill switch activated - All trading stopped'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deactivateKillSwitch(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Kill Switch'),
        content: const Text(
          'Are you sure you want to resume trading?\n\n'
          'Make sure the issue has been resolved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(killSwitchDeactivatorProvider.notifier).deactivate();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kill switch deactivated - Trading resumed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _KillSwitchDialog extends StatefulWidget {
  @override
  State<_KillSwitchDialog> createState() => _KillSwitchDialogState();
}

class _KillSwitchDialogState extends State<_KillSwitchDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('⚠️ Activate Kill Switch'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This will immediately:\n'
            '• Stop all trading\n'
            '• Close all open positions\n'
            '• Prevent new trades\n',
            style: TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Reason',
              hintText: 'Why are you activating the kill switch?',
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('ACTIVATE'),
        ),
      ],
    );
  }
}
```

---

Estos ejemplos muestran los patrones más comunes de uso de los providers en la aplicación. Puedes adaptarlos según tus necesidades específicas.
