import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/market_type.dart';
import '../models/positions_response.dart';
import '../models/trading_position.dart';
import '../providers/ai_bot_provider.dart';
import '../widgets/error_widgets.dart';

import '../exceptions/trading_api_exceptions.dart';

/// Screen for displaying AI Bot positions from Trading MCP Server
class AIBotPositionsScreen extends ConsumerStatefulWidget {
  const AIBotPositionsScreen({super.key});

  @override
  ConsumerState<AIBotPositionsScreen> createState() =>
      _AIBotPositionsScreenState();
}

class _AIBotPositionsScreenState extends ConsumerState<AIBotPositionsScreen> {
  MarketType? _selectedMarketType;
  bool _autoRefreshEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_autoRefreshEnabled) {
        ref.read(aiBotProvider.notifier).startAutoRefresh();
      }
    });
  }

  @override
  void dispose() {
    ref.read(aiBotProvider.notifier).stopAutoRefresh();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(aiBotProvider.notifier).loadPositions();
  }

  void _toggleAutoRefresh() {
    setState(() {
      _autoRefreshEnabled = !_autoRefreshEnabled;
    });

    if (_autoRefreshEnabled) {
      ref.read(aiBotProvider.notifier).startAutoRefresh();
    } else {
      ref.read(aiBotProvider.notifier).stopAutoRefresh();
    }
  }

  List<TradingPosition> _filterPositions(List<TradingPosition> positions) {
    if (_selectedMarketType == null) return positions;
    return positions
        .where(
            (p) => MarketType.fromString(p.marketType) == _selectedMarketType)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final aiBotState = ref.watch(aiBotProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posiciones del Bot IA'),
        actions: [
          PopupMenuButton<MarketType?>(
            icon: Icon(
              Icons.filter_list,
              color: _selectedMarketType != null
                  ? theme.colorScheme.primary
                  : null,
            ),
            onSelected: (marketType) {
              setState(() {
                _selectedMarketType = marketType;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive, size: 20),
                    SizedBox(width: 8),
                    Text('Todos los tipos'),
                  ],
                ),
              ),
              ...MarketType.values.map((type) => PopupMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(type.iconData, size: 20, color: type.color),
                        const SizedBox(width: 8),
                        Text(type.displayName),
                      ],
                    ),
                  )),
            ],
          ),
          IconButton(
            icon: Icon(
              _autoRefreshEnabled ? Icons.sync : Icons.sync_disabled,
              color: _autoRefreshEnabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: _toggleAutoRefresh,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: Column(
        children: [
          if (aiBotState.positions != null)
            _buildPnLSummaryCard(aiBotState.positions!),
          Expanded(
            child: _buildPositionsList(aiBotState),
          ),
        ],
      ),
    );
  }

  Widget _buildPnLSummaryCard(PositionsResponse positionsResponse) {
    final theme = Theme.of(context);
    final totalPnL = positionsResponse.totalPnL;
    final totalPnLPercent = positionsResponse.totalPnLPercent;
    final isPositive = totalPnL >= 0;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'P&L Total',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isPositive
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 16,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isPositive ? '+' : ''}\$${totalPnL.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isPositive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Posiciones Abiertas: ${positionsResponse.totalPositions}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${isPositive ? '+' : ''}${totalPnLPercent.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionsList(AIBotState aiBotState) {
    if (aiBotState.isLoading && aiBotState.positions == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando posiciones del bot...'),
          ],
        ),
      );
    }

    if (aiBotState.error != null && aiBotState.positions == null) {
      return _buildErrorDisplay(aiBotState);
    }

    if (aiBotState.positions == null ||
        aiBotState.positions!.positions.isEmpty) {
      return _buildEmptyState();
    }

    final filteredPositions = _filterPositions(aiBotState.positions!.positions);

    if (filteredPositions.isEmpty) {
      return _buildEmptyState(isFiltered: true);
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filteredPositions.length,
        itemBuilder: (context, index) {
          final position = filteredPositions[index];
          return _buildPositionCard(position);
        },
      ),
    );
  }

  Widget _buildPositionCard(TradingPosition position) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: position.side == 'long'
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        position.side.toUpperCase(),
                        style: TextStyle(
                          color: position.side == 'long'
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      position.symbol,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${position.pnl >= 0 ? '+' : ''}\$${position.pnl.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: position.pnl >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      '${position.pnlPercent >= 0 ? '+' : ''}${position.pnlPercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: position.pnlPercent >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Precio Entrada',
                    '\$${position.entryPrice.toStringAsFixed(4)}',
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Precio Actual',
                    '\$${position.currentPrice.toStringAsFixed(4)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Tamaño',
                    position.size.toStringAsFixed(4),
                  ),
                ),
                if (position.leverage != null)
                  Expanded(
                    child: _buildDetailItem(
                      'Apalancamiento',
                      '${position.leverage!.toStringAsFixed(0)}x',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({bool isFiltered = false}) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFiltered
                  ? Icons.filter_list_off
                  : Icons.account_balance_wallet_outlined,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered
                  ? 'No hay posiciones para este tipo de mercado'
                  : 'No hay posiciones abiertas',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Prueba seleccionando un tipo de mercado diferente'
                  : 'El bot de IA no tiene posiciones abiertas actualmente',
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (isFiltered) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedMarketType = null;
                  });
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar filtro'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds error display with appropriate error widgets
  Widget _buildErrorDisplay(AIBotState aiBotState) {
    final error = aiBotState.lastException ?? aiBotState.error;

    // Check if it's a network error
    if (aiBotState.lastException is NetworkException ||
        aiBotState.error?.toLowerCase().contains('network') == true ||
        aiBotState.error?.toLowerCase().contains('connection') == true) {
      return ErrorWidgets.networkError(
        onRetry: _onRefresh,
        message: aiBotState.userFriendlyError,
      );
    }

    // Check if it's a server error
    if (aiBotState.lastException is ServerException ||
        aiBotState.error?.contains('500') == true ||
        aiBotState.error?.contains('502') == true ||
        aiBotState.error?.contains('503') == true) {
      return ErrorWidgets.serverError(
        onRetry: _onRefresh,
        message: aiBotState.userFriendlyError,
      );
    }

    // Check if it's a bot-specific error
    if (aiBotState.lastException is BotException) {
      return ErrorWidgets.errorCard(
        error: error,
        onRetry: aiBotState.canRetry ? _onRefresh : null,
        title: 'Error del Bot de IA',
      );
    }

    // Generic error card for other errors
    return ErrorWidgets.errorCard(
      error: error,
      onRetry: aiBotState.canRetry ? _onRefresh : null,
      title: 'Error al cargar posiciones',
    );
  }
}
