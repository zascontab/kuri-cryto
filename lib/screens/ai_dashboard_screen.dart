import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ai_status_provider.dart';
import '../providers/ai_notifications_provider.dart';
import '../providers/comprehensive_analysis_provider.dart';
import '../providers/selected_symbol_provider.dart' as symbol_provider;
import '../widgets/ai_status_indicator.dart';
import '../widgets/ai_analysis_card.dart';
import '../widgets/symbol_selector.dart';
import '../widgets/live_price_widget.dart';
import 'ai_notifications_screen.dart';
import 'ai_costs_screen.dart';
import 'ai_settings_screen.dart';

/// Dashboard principal con todas las features de IA
/// Rediseñado con CustomScrollView y Slivers para evitar overflow
class AIDashboardScreen extends ConsumerWidget {
  const AIDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSymbol = ref.watch(symbol_provider.selectedSymbolProvider);

    final aiStatusAsync = ref.watch(aIStatusNotifierProvider);
    final notificationsAsync = ref.watch(aINotificationsNotifierProvider);
    final analysisAsync = ref.watch(
      comprehensiveAnalysisNotifierProvider(selectedSymbol),
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(aIStatusNotifierProvider.notifier).refresh(),
            ref.read(aINotificationsNotifierProvider.notifier).refresh(),
          ]);
        },
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              title: const Text('Trading IA'),
              floating: true,
              snap: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AISettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Compact Symbol Selector in App Bar area
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SymbolSelector(
                  compact: true,
                  onSymbolChanged: () {
                    ref.invalidate(
                        comprehensiveAnalysisNotifierProvider(selectedSymbol));
                  },
                ),
              ),
            ),

            // Main Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Full Symbol Selector
                  SymbolSelector(
                    onSymbolChanged: () {
                      ref.invalidate(comprehensiveAnalysisNotifierProvider(
                          selectedSymbol));
                    },
                  ),
                  const SizedBox(height: 16),

                  // Live Price Widget
                  const LivePriceWidget(),
                  const SizedBox(height: 16),
                ]),
              ),
            ),

            // AI Status Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: aiStatusAsync.when(
                  data: (status) => AIStatusIndicator(
                    aiStatus: status,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AICostsScreen(),
                        ),
                      );
                    },
                  ),
                  loading: () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (error, stack) => _buildErrorCard(
                    context,
                    'Error loading AI status',
                    error.toString(),
                  ),
                ),
              ),
            ),

            // Spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),

            // Analysis Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: analysisAsync.when(
                  data: (analysis) {
                    if (analysis.hasFullAIAnalysis) {
                      return AIAnalysisCard(
                        recommendation: analysis.recommendation,
                        llmAnalysis: analysis.llmAnalysis,
                        sentimentAnalysis: analysis.sentimentAnalysis,
                      );
                    }
                    return _buildEmptyAnalysisCard(context);
                  },
                  loading: () => _buildLoadingCard('Analyzing market...'),
                  error: (error, stack) => _buildErrorCard(
                    context,
                    'Analysis Error',
                    error.toString(),
                  ),
                ),
              ),
            ),

            // Spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),

            // Notifications Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: notificationsAsync.when(
                  data: (notifications) {
                    if (notifications.isEmpty) {
                      return _buildEmptyNotificationsCard(context);
                    }
                    final recent = notifications.take(3).toList();
                    return _buildNotificationsSection(context, recent);
                  },
                  loading: () => _buildLoadingCard('Loading notifications...'),
                  error: (error, stack) => _buildErrorCard(
                    context,
                    'Notifications Error',
                    error.toString(),
                  ),
                ),
              ),
            ),

            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la sección de notificaciones con diseño mejorado
  Widget _buildNotificationsSection(
    BuildContext context,
    List notifications,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Notificaciones Recientes',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AINotificationsScreen(),
                      ),
                    );
                  },
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Notifications List
            ...notifications.map((n) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (n.isBuy
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444))
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      n.isBuy ? Icons.trending_up : Icons.trending_down,
                      color: n.isBuy
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    '${n.action} ${n.symbol}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    n.llmExplanation,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        n.timeAgoFormatted,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Construye una card de carga
  Widget _buildLoadingCard(String message) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye una card de error
  Widget _buildErrorCard(BuildContext context, String title, String error) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Construye una card vacía para análisis
  Widget _buildEmptyAnalysisCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.analytics_outlined,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'No AI Analysis Available',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a symbol to get AI-powered market analysis',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Construye una card vacía para notificaciones
  Widget _buildEmptyNotificationsCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'No Recent Notifications',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI notifications will appear here when available',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
