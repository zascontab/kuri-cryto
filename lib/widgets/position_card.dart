import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Expandable card widget for displaying position details
class PositionCard extends StatefulWidget {
  final String symbol;
  final String side; // 'long' or 'short'
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
  final VoidCallback? onClose;
  final VoidCallback? onEditSLTP;
  final VoidCallback? onBreakeven;
  final VoidCallback? onTrailing;

  const PositionCard({
    super.key,
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
    this.onClose,
    this.onEditSLTP,
    this.onBreakeven,
    this.onTrailing,
  });

  @override
  State<PositionCard> createState() => _PositionCardState();
}

class _PositionCardState extends State<PositionCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Color _getPnLColor() {
    if (widget.unrealizedPnl > 0) return const Color(0xFF4CAF50); // Green
    if (widget.unrealizedPnl < 0) return const Color(0xFFF44336); // Red
    return Colors.grey;
  }

  Color _getSideColor() {
    return widget.side.toLowerCase() == 'long'
        ? const Color(0xFF4CAF50)
        : const Color(0xFFF44336);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pnlColor = _getPnLColor();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: _toggleExpanded,
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showOptionsMenu(context);
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Symbol and PnL
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
                              color: _getSideColor().withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.side.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _getSideColor(),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.symbol,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.leverage}x',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${widget.unrealizedPnl >= 0 ? '+' : ''}\$${widget.unrealizedPnl.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: pnlColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Price info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPriceInfo(
                        'Entry',
                        '\$${widget.entryPrice.toStringAsFixed(4)}',
                        theme,
                      ),
                      _buildPriceInfo(
                        'Current',
                        '\$${widget.currentPrice.toStringAsFixed(4)}',
                        theme,
                      ),
                      _buildPriceInfo(
                        'Size',
                        '\$${widget.size.toStringAsFixed(2)}',
                        theme,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Expanded details
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildDetailRow('Strategy', widget.strategy, theme),
                    _buildDetailRow(
                      'Stop Loss',
                      widget.stopLoss != null
                          ? '\$${widget.stopLoss!.toStringAsFixed(4)}'
                          : 'Not set',
                      theme,
                    ),
                    _buildDetailRow(
                      'Take Profit',
                      widget.takeProfit != null
                          ? '\$${widget.takeProfit!.toStringAsFixed(4)}'
                          : 'Not set',
                      theme,
                    ),
                    _buildDetailRow(
                      'Open Time',
                      _formatDateTime(widget.openTime),
                      theme,
                    ),
                    const SizedBox(height: 12),
                    // Action buttons
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (widget.onEditSLTP != null)
                          _buildActionButton(
                            'Edit SL/TP',
                            Icons.edit,
                            widget.onEditSLTP!,
                            theme,
                          ),
                        if (widget.onBreakeven != null)
                          _buildActionButton(
                            'Breakeven',
                            Icons.equalizer,
                            widget.onBreakeven!,
                            theme,
                          ),
                        if (widget.onTrailing != null)
                          _buildActionButton(
                            'Trailing',
                            Icons.trending_up,
                            widget.onTrailing!,
                            theme,
                          ),
                        if (widget.onClose != null)
                          _buildActionButton(
                            'Close',
                            Icons.close,
                            () {
                              HapticFeedback.mediumImpact();
                              _showCloseConfirmation(context);
                            },
                            theme,
                            backgroundColor: const Color(0xFFF44336),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInfo(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
    ThemeData theme, {
    Color? backgroundColor,
  }) {
    return FilledButton.tonalIcon(
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit SL/TP'),
              onTap: () {
                Navigator.pop(context);
                widget.onEditSLTP?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.equalizer),
              title: const Text('Move to Breakeven'),
              onTap: () {
                Navigator.pop(context);
                widget.onBreakeven?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Enable Trailing Stop'),
              onTap: () {
                Navigator.pop(context);
                widget.onTrailing?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.close, color: Color(0xFFF44336)),
              title: const Text(
                'Close Position',
                style: TextStyle(color: Color(0xFFF44336)),
              ),
              onTap: () {
                Navigator.pop(context);
                _showCloseConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCloseConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Position'),
        content: Text(
          'Are you sure you want to close this position?\n\n'
          'Current P&L: ${widget.unrealizedPnl >= 0 ? '+' : ''}\$${widget.unrealizedPnl.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.heavyImpact();
              widget.onClose?.call();
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
