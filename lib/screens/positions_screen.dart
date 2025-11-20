import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/position_card.dart';
import '../l10n/l10n_export.dart';
import '../providers/position_provider.dart';
import '../models/position.dart';

/// Positions screen with tabs for open and closed positions
class PositionsScreen extends ConsumerStatefulWidget {
  const PositionsScreen({super.key});

  @override
  ConsumerState<PositionsScreen> createState() => _PositionsScreenState();
}

class _PositionsScreenState extends ConsumerState<PositionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Store open positions from stream
  final List<Position> _openPositions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    // Refresh history (stream auto-updates)
    ref.invalidate(positionHistoryProvider);
    await ref.read(positionHistoryProvider().future);
  }

  void _closePosition(String positionId) async {
    HapticFeedback.heavyImpact();
    final l10n = context.l10n;

    try {
      await ref.read(positionCloserProvider.notifier).closePosition(positionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.closingPosition(positionId: positionId)),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFF44336),
            action: SnackBarAction(
              label: l10n.retry,
              textColor: Colors.white,
              onPressed: () => _closePosition(positionId),
            ),
          ),
        );
      }
    }
  }

  void _editSLTP(String positionId, Position position) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _SLTPEditSheet(
        positionId: positionId,
        position: position,
      ),
    );
  }

  void _moveToBreakeven(String positionId) async {
    HapticFeedback.mediumImpact();
    final l10n = context.l10n;

    try {
      await ref.read(breakevenMoverProvider.notifier).moveToBreakeven(positionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.movingStopLossBreakeven),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFF44336),
            action: SnackBarAction(
              label: l10n.retry,
              textColor: Colors.white,
              onPressed: () => _moveToBreakeven(positionId),
            ),
          ),
        );
      }
    }
  }

  void _enableTrailing(String positionId) async {
    HapticFeedback.mediumImpact();
    final l10n = context.l10n;

    try {
      // Use default 0.5% trailing distance
      await ref.read(trailingStopEnablerProvider.notifier).enableTrailingStop(
        positionId: positionId,
        distancePercent: 0.5,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.enablingTrailingStop),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFF44336),
            action: SnackBarAction(
              label: l10n.retry,
              textColor: Colors.white,
              onPressed: () => _enableTrailing(positionId),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Listen to position stream and update local list
    ref.listen<AsyncValue<Position>>(positionsProvider, (previous, next) {
      next.whenData((position) {
        setState(() {
          // Update or add position
          final index = _openPositions.indexWhere((p) => p.id == position.id);
          if (index >= 0) {
            if (position.status == 'open') {
              _openPositions[index] = position;
            } else {
              _openPositions.removeAt(index);
            }
          } else if (position.status == 'open') {
            _openPositions.add(position);
          }
        });
      });
    });

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.openPositions),
            Tab(text: l10n.history),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Open Positions Tab (WebSocket stream)
              _buildOpenPositionsList(),
              // History Tab (REST API)
              _buildHistoryList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOpenPositionsList() {
    // Show cached positions immediately, stream updates in background
    if (_openPositions.isEmpty) {
      return _buildEmptyState(true);
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _openPositions.length,
        itemBuilder: (context, index) {
          final position = _openPositions[index];
          return PositionCard(
            symbol: position.symbol,
            side: position.side,
            entryPrice: position.entryPrice,
            currentPrice: position.currentPrice,
            size: position.size,
            leverage: position.leverage,
            stopLoss: position.stopLoss,
            takeProfit: position.takeProfit,
            unrealizedPnl: position.unrealizedPnl,
            strategy: position.strategy,
            openTime: position.openTime,
            status: position.status,
            onClose: () => _closePosition(position.id),
            onEditSLTP: () => _editSLTP(position.id, position),
            onBreakeven: () => _moveToBreakeven(position.id),
            onTrailing: () => _enableTrailing(position.id),
          );
        },
      ),
    );
  }

  Widget _buildHistoryList() {
    final historyAsync = ref.watch(positionHistoryProvider());

    return historyAsync.when(
      data: (positions) {
        if (positions.isEmpty) {
          return _buildEmptyState(false);
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: positions.length,
            itemBuilder: (context, index) {
              final position = positions[index];
              return PositionCard(
                symbol: position.symbol,
                side: position.side,
                entryPrice: position.entryPrice,
                currentPrice: position.currentPrice,
                size: position.size,
                leverage: position.leverage,
                stopLoss: position.stopLoss,
                takeProfit: position.takeProfit,
                unrealizedPnl: position.unrealizedPnl,
                strategy: position.strategy,
                openTime: position.openTime,
                status: position.status,
                onClose: null,
                onEditSLTP: null,
                onBreakeven: null,
                onTrailing: null,
              );
            },
          ),
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
                label: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isOpen) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isOpen ? Icons.account_balance_wallet_outlined : Icons.history,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isOpen ? l10n.noOpenPositions : l10n.history,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            isOpen
                ? l10n.startEngineToTrade
                : l10n.closedPositionsHere,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }
}

// Bottom sheet for editing SL/TP
class _SLTPEditSheet extends ConsumerStatefulWidget {
  final String positionId;
  final Position position;

  const _SLTPEditSheet({
    required this.positionId,
    required this.position,
  });

  @override
  ConsumerState<_SLTPEditSheet> createState() => _SLTPEditSheetState();
}

class _SLTPEditSheetState extends ConsumerState<_SLTPEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _stopLossController;
  late TextEditingController _takeProfitController;

  @override
  void initState() {
    super.initState();
    _stopLossController = TextEditingController(
      text: widget.position.stopLoss?.toStringAsFixed(2) ?? '',
    );
    _takeProfitController = TextEditingController(
      text: widget.position.takeProfit?.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _stopLossController.dispose();
    _takeProfitController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();

      final stopLoss = double.tryParse(_stopLossController.text);
      final takeProfit = double.tryParse(_takeProfitController.text);

      try {
        await ref.read(slTpUpdaterProvider.notifier).updateSlTp(
          positionId: widget.positionId,
          stopLoss: stopLoss,
          takeProfit: takeProfit,
        );

        if (mounted) {
          Navigator.pop(context);

          final l10n = context.l10n;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.slTpUpdatedSuccess),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          final l10n = context.l10n;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: const Color(0xFFF44336),
              action: SnackBarAction(
                label: l10n.retry,
                textColor: Colors.white,
                onPressed: _save,
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.editStopLossTakeProfit,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _stopLossController,
                decoration: InputDecoration(
                  labelText: l10n.stopLoss,
                  prefixText: '\$',
                  border: const OutlineInputBorder(),
                  helperText: l10n.priceCloseIfLosing,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null; // Optional field
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return l10n.pleaseEnterValidPrice;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _takeProfitController,
                decoration: InputDecoration(
                  labelText: l10n.takeProfit,
                  prefixText: '\$',
                  border: const OutlineInputBorder(),
                  helperText: l10n.priceCloseIfWinning,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null; // Optional field
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return l10n.pleaseEnterValidPrice;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      child: Text(l10n.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
