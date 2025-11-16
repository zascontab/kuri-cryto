import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trading_pair.dart';
import '../providers/trading_pairs_provider.dart';
import '../l10n/l10n.dart';
import '../widgets/tiktok_modal.dart';

/// Trading Pairs management screen
///
/// Allows users to:
/// - View active trading pairs
/// - Add new trading pairs
/// - Remove trading pairs (with validation)
/// - See pair details and status
class TradingPairsScreen extends ConsumerWidget {
  const TradingPairsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final pairsAsync = ref.watch(activePairsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tradingPairs),
        elevation: 0,
      ),
      body: pairsAsync.when(
        data: (pairs) => _buildPairsList(context, ref, pairs),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(context, ref, error),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPairDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.addPair),
      ),
    );
  }

  Widget _buildPairsList(BuildContext context, WidgetRef ref, List<TradingPair> pairs) {
    final l10n = L10n.of(context);

    if (pairs.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(activePairsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pairs.length,
        itemBuilder: (context, index) {
          final pair = pairs[index];
          return _TradingPairCard(
            pair: pair,
            onRemove: () => _confirmRemovePair(context, ref, pair),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = L10n.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.paid_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noTradingPairs,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tapAddPairToStart,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    final l10n = L10n.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              l10n.errorOccurred(error: error.toString()),
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(activePairsProvider),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemovePair(BuildContext context, WidgetRef ref, TradingPair pair) {
    final l10n = L10n.of(context);

    // Check if pair has open positions
    if (pair.hasOpenPositions) {
      _showCannotRemoveDialog(context, pair);
      return;
    }

    showTikTokModal(
      context: context,
      title: l10n.removePair,
      message: l10n.removePairConfirmation(
        exchange: pair.exchange.toUpperCase(),
        symbol: pair.symbol,
      ),
      actions: [
        TikTokModalButton(
          text: l10n.remove,
          isPrimary: true,
          backgroundColor: Colors.red,
          onPressed: () async {
            Navigator.pop(context);
            await _removePair(context, ref, pair);
          },
        ),
        TikTokModalButton(
          text: l10n.cancel,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  void _showCannotRemoveDialog(BuildContext context, TradingPair pair) {
    final l10n = L10n.of(context);

    showTikTokModal(
      context: context,
      title: l10n.cannotRemovePair,
      message: l10n.cannotRemovePairWithPositions(
        count: pair.openPositions ?? 0,
      ),
      actions: [
        TikTokModalButton(
          text: l10n.ok,
          isPrimary: true,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Future<void> _removePair(BuildContext context, WidgetRef ref, TradingPair pair) async {
    final l10n = L10n.of(context);

    try {
      await ref.read(pairRemoverProvider.notifier).removePair(
            exchange: pair.exchange,
            symbol: pair.symbol,
            hasOpenPositions: pair.hasOpenPositions,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pairRemovedSuccess(symbol: pair.symbol)),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOccurred(error: e.toString())),
            backgroundColor: const Color(0xFFF44336),
            action: SnackBarAction(
              label: l10n.retry,
              textColor: Colors.white,
              onPressed: () => _removePair(context, ref, pair),
            ),
          ),
        );
      }
    }
  }

  void _showAddPairDialog(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => const _AddPairDialog(),
    );
  }
}

/// Card widget for displaying a trading pair
class _TradingPairCard extends StatelessWidget {
  final TradingPair pair;
  final VoidCallback onRemove;

  const _TradingPairCard({
    required this.pair,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    return Dismissible(
      key: Key('${pair.exchange}_${pair.symbol}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        onRemove();
        return false; // Don't actually dismiss, handled by dialog
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF44336),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Symbol
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pair.symbol,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.account_balance,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              pair.exchange.toUpperCase(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  _StatusBadge(status: pair.status, enabled: pair.enabled),
                ],
              ),
              const Divider(height: 24),
              // Metrics
              Row(
                children: [
                  Expanded(
                    child: _MetricItem(
                      label: l10n.lastPrice,
                      value: pair.lastPrice != null
                          ? '\$${pair.lastPrice!.toStringAsFixed(2)}'
                          : l10n.notAvailable,
                    ),
                  ),
                  Expanded(
                    child: _MetricItem(
                      label: l10n.volume24h,
                      value: pair.volume24h != null
                          ? '\$${_formatVolume(pair.volume24h!)}'
                          : l10n.notAvailable,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetricItem(
                      label: l10n.exposure,
                      value: pair.exposure != null
                          ? '\$${pair.exposure!.toStringAsFixed(2)}'
                          : '\$0.00',
                    ),
                  ),
                  Expanded(
                    child: _MetricItem(
                      label: l10n.openPositions,
                      value: '${pair.openPositions ?? 0}',
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

  String _formatVolume(double volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(2)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(2)}K';
    }
    return volume.toStringAsFixed(2);
  }
}

/// Status badge widget
class _StatusBadge extends StatelessWidget {
  final String status;
  final bool enabled;

  const _StatusBadge({
    required this.status,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final isActive = status == 'active' && enabled;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4CAF50) : Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? l10n.active : l10n.inactive,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Metric item widget
class _MetricItem extends StatelessWidget {
  final String label;
  final String value;

  const _MetricItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Dialog for adding a new trading pair
class _AddPairDialog extends ConsumerStatefulWidget {
  const _AddPairDialog();

  @override
  ConsumerState<_AddPairDialog> createState() => _AddPairDialogState();
}

class _AddPairDialogState extends ConsumerState<_AddPairDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedExchange;
  String _searchQuery = '';
  TradingPair? _selectedPair;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final exchanges = ref.watch(supportedExchangesProvider);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.addNewPair,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Exchange Selector
            Form(
              key: _formKey,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: l10n.exchange,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.account_balance),
                ),
                value: _selectedExchange,
                items: exchanges.map((exchange) {
                  return DropdownMenuItem(
                    value: exchange,
                    child: Text(exchange.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedExchange = value;
                    _selectedPair = null;
                    _searchQuery = '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseSelectExchange;
                  }
                  return null;
                },
              ),
            ),

            const SizedBox(height: 16),

            // Search Field
            if (_selectedExchange != null) ...[
              TextField(
                decoration: InputDecoration(
                  labelText: l10n.searchPairs,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // Available Pairs List
            if (_selectedExchange != null)
              Expanded(
                child: _buildAvailablePairsList(),
              ),

            const SizedBox(height: 16),

            // Selected Pair Preview
            if (_selectedPair != null) _buildPairPreview(),

            const SizedBox(height: 16),

            // Actions
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
                    onPressed: _selectedPair != null ? _addPair : null,
                    child: Text(l10n.addPair),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailablePairsList() {
    final l10n = L10n.of(context);
    final pairsAsync = ref.watch(availablePairsProvider(_selectedExchange!));

    return pairsAsync.when(
      data: (pairs) {
        final filteredPairs = _searchQuery.isEmpty
            ? pairs
            : pairs.where((pair) => pair.symbol.toLowerCase().contains(_searchQuery)).toList();

        if (filteredPairs.isEmpty) {
          return Center(child: Text(l10n.noPairsFound));
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: filteredPairs.length,
          itemBuilder: (context, index) {
            final pair = filteredPairs[index];
            final isSelected = _selectedPair?.symbol == pair.symbol;

            return ListTile(
              selected: isSelected,
              leading: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? const Color(0xFF4CAF50) : null,
              ),
              title: Text(pair.symbol),
              subtitle: pair.lastPrice != null
                  ? Text('\$${pair.lastPrice!.toStringAsFixed(2)}')
                  : null,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedPair = pair;
                });
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          l10n.errorOccurred(error: error.toString()),
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildPairPreview() {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final pair = _selectedPair!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectedPair,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pair.symbol,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _selectedExchange!.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (pair.lastPrice != null)
                Text(
                  '\$${pair.lastPrice!.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addPair() async {
    if (!_formKey.currentState!.validate() || _selectedPair == null) {
      return;
    }

    final l10n = L10n.of(context);

    try {
      await ref.read(pairAdderProvider.notifier).addPair(
            exchange: _selectedExchange!,
            symbol: _selectedPair!.symbol,
          );

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pairAddedSuccess(symbol: _selectedPair!.symbol)),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOccurred(error: e.toString())),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
    }
  }
}
