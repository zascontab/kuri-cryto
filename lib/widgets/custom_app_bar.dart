import 'package:flutter/material.dart';

/// Custom AppBar with status badge and connection indicator
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String status; // 'running', 'stopped', 'error', 'connecting'
  final bool isConnected;
  final VoidCallback? onSettingsTap;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.status,
    this.isConnected = true,
    this.onSettingsTap,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'running':
        return const Color(0xFF10B981); // Green
      case 'connecting':
        return const Color(0xFF6B7280); // Gray
      case 'stopped':
        return const Color(0xFF6B7280); // Gray
      case 'error':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  IconData _getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'running':
        return Icons.check_circle;
      case 'connecting':
        return Icons.sync;
      case 'stopped':
        return Icons.stop_circle;
      case 'error':
        return Icons.error_outline;
      default:
        return Icons.help_outline;
    }
  }

  String _getConnectionText() {
    if (!isConnected) return 'Disconnected';

    switch (status.toLowerCase()) {
      case 'running':
        return 'Connected';
      case 'connecting':
        return 'Connecting...';
      case 'error':
        return 'Error';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Text(title),
      actions: [
        // Connection indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  shape: BoxShape.circle,
                  boxShadow: isConnected && status.toLowerCase() == 'running'
                      ? [
                          BoxShadow(
                            color: _getStatusColor().withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _getConnectionText(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        // Status badge
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getStatusColor(),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(),
                  size: 16,
                  color: _getStatusColor(),
                ),
                const SizedBox(width: 6),
                Text(
                  status.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Settings icon
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: onSettingsTap,
          tooltip: 'Settings',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
