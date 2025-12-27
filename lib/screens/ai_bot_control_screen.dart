import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ai_bot_provider.dart';
import '../utils/error_handler.dart';

/// Pantalla de control del bot de IA
class AIBotControlScreen extends ConsumerStatefulWidget {
  const AIBotControlScreen({super.key});

  @override
  ConsumerState<AIBotControlScreen> createState() => _AIBotControlScreenState();
}

class _AIBotControlScreenState extends ConsumerState<AIBotControlScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiBotProvider.notifier).loadStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Bot Control'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: const Center(
        child: Text('AI Bot Control Screen'),
      ),
    );
  }
}

extension _AIBotControlScreenStateExtension on _AIBotControlScreenState {
  Future<void> _startBot() async {
    try {
      await ref.read(aiBotProvider.notifier).startBot();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bot started successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, 'Failed to start bot: $e');
      }
    }
  }

  Future<void> _stopBot() async {
    try {
      await ref.read(aiBotProvider.notifier).stopBot();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bot stopped successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, 'Failed to stop bot: $e');
      }
    }
  }
}
