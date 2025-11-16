import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/position_card.dart';
import '../l10n/l10n.dart';

/// Positions screen with tabs for open and closed positions
class PositionsScreen extends StatefulWidget {
  const PositionsScreen({super.key});

  @override
  State<PositionsScreen> createState() => _PositionsScreenState();
}

class _PositionsScreenState extends State<PositionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Mock data - replace with actual API calls
  final List<_PositionData> _openPositions = [
    _PositionData(
      id: '1',
      symbol: 'BTC-USDT',
      side: 'long',
      entryPrice: 43250.00,
      currentPrice: 43580.00,
      size: 1000.0,
      leverage: 5.0,
      stopLoss: 42800.00,
      takeProfit: 44000.00,
      unrealizedPnl: 76.28,
      strategy: 'RSI Scalping',
      openTime: DateTime.now().subtract(const Duration(minutes: 15)),
      status: 'open',
    ),
    _PositionData(
      id: '2',
      symbol: 'ETH-USDT',
      side: 'short',
      entryPrice: 2280.50,
      currentPrice: 2265.20,
      size: 500.0,
      leverage: 3.0,
      stopLoss: 2310.00,
      takeProfit: 2200.00,
      unrealizedPnl: 33.74,
      strategy: 'MACD Scalping',
      openTime: DateTime.now().subtract(const Duration(hours: 1)),
      status: 'open',
    ),
    _PositionData(
      id: '3',
      symbol: 'DOGE-USDT',
      side: 'long',
      entryPrice: 0.08500,
      currentPrice: 0.08350,
      size: 200.0,
      leverage: 2.0,
      stopLoss: 0.08200,
      takeProfit: 0.08900,
      unrealizedPnl: -3.53,
      strategy: 'Volume Scalping',
      openTime: DateTime.now().subtract(const Duration(minutes: 45)),
      status: 'open',
    ),
  ];

  final List<_PositionData> _closedPositions = [
    _PositionData(
      id: '4',
      symbol: 'BTC-USDT',
      side: 'long',
      entryPrice: 42800.00,
      currentPrice: 43100.00,
      size: 500.0,
      leverage: 5.0,
      stopLoss: 42500.00,
      takeProfit: 43500.00,
      unrealizedPnl: 35.05,
      strategy: 'Bollinger Scalping',
      openTime: DateTime.now().subtract(const Duration(hours: 3)),
      status: 'closed',
    ),
    _PositionData(
      id: '5',
      symbol: 'SOL-USDT',
      side: 'short',
      entryPrice: 105.20,
      currentPrice: 106.50,
      size: 300.0,
      leverage: 4.0,
      unrealizedPnl: -14.82,
      strategy: 'AI Scalping',
      openTime: DateTime.now().subtract(const Duration(hours: 5)),
      status: 'closed',
    ),
  ];

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
    setState(() => _isLoading = true);

    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _closePosition(String positionId) {
    HapticFeedback.heavyImpact();

    // TODO: Replace with actual API call
    final l10n = L10n.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.closingPosition(positionId: positionId)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _editSLTP(String positionId) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _SLTPEditSheet(positionId: positionId),
    );
  }

  void _moveToBreakeven(String positionId) {
    HapticFeedback.mediumImpact();

    // TODO: Replace with actual API call
    final l10n = L10n.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.movingStopLossBreakeven),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  void _enableTrailing(String positionId) {
    HapticFeedback.mediumImpact();

    // TODO: Replace with actual API call
    final l10n = L10n.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.enablingTrailingStop),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10n.of(context);

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
              // Open Positions Tab
              _buildPositionsList(_openPositions, isOpen: true),
              // History Tab
              _buildPositionsList(_closedPositions, isOpen: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPositionsList(
    List<_PositionData> positions, {
    required bool isOpen,
  }) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (positions.isEmpty) {
      return _buildEmptyState(isOpen);
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
            onClose: isOpen ? () => _closePosition(position.id) : null,
            onEditSLTP: isOpen ? () => _editSLTP(position.id) : null,
            onBreakeven: isOpen ? () => _moveToBreakeven(position.id) : null,
            onTrailing: isOpen ? () => _enableTrailing(position.id) : null,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isOpen) {
    final l10n = L10n.of(context);
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

// Mock data class
class _PositionData {
  final String id;
  final String symbol;
  final String side;
  final double entryPrice;
  final double currentPrice;
  final double size;
  final double leverage;
  final double? stopLoss;
  final double? takeProfit;
  final double unrealizedPnl;
  final String strategy;
  final DateTime openTime;
  final String status;

  _PositionData({
    required this.id,
    required this.symbol,
    required this.side,
    required this.entryPrice,
    required this.currentPrice,
    required this.size,
    required this.leverage,
    this.stopLoss,
    this.takeProfit,
    required this.unrealizedPnl,
    required this.strategy,
    required this.openTime,
    required this.status,
  });
}

// Bottom sheet for editing SL/TP
class _SLTPEditSheet extends StatefulWidget {
  final String positionId;

  const _SLTPEditSheet({required this.positionId});

  @override
  State<_SLTPEditSheet> createState() => _SLTPEditSheetState();
}

class _SLTPEditSheetState extends State<_SLTPEditSheet> {
  final _formKey = GlobalKey<FormState>();
  final _stopLossController = TextEditingController(text: '42800.00');
  final _takeProfitController = TextEditingController(text: '44000.00');

  @override
  void dispose() {
    _stopLossController.dispose();
    _takeProfitController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();

      // TODO: Replace with actual API call
      Navigator.pop(context);

      final l10n = L10n.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.slTpUpdatedSuccess),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10n.of(context);

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
                    return l10n.pleaseEnterStopLoss;
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
                    return l10n.pleaseEnterTakeProfit;
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
