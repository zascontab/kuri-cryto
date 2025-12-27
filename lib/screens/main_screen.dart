import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/health_provider.dart';
import '../providers/ai_bot_provider.dart';
import '../utils/error_handler.dart';
import 'dashboard_screen.dart';
import 'positions_screen.dart';
import 'strategies_screen.dart';
import 'risk_screen.dart';
import 'settings_screen.dart';
import 'multi_timeframe_screen.dart';
import 'backtest_screen.dart';
import 'optimization_screen.dart';
import 'trading_pairs_screen.dart';
import 'alerts_screen.dart';
import 'execution_stats_screen.dart';
import 'performance_charts_screen.dart';
import 'ai_bot_control_screen.dart';
import 'ai_bot_config_screen.dart';
import 'comprehensive_analysis_screen.dart';
import 'futures_positions_screen.dart';
import 'trading_hub_screen.dart';
import 'mcp_main_screen.dart';
import 'market_type_demo_screen.dart';
import 'ai_dashboard_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../l10n/l10n_export.dart';

/// Main screen with bottom navigation and PageView
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    HapticFeedback.lightImpact();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onSettingsTap() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  String _getAppBarTitle(BuildContext context) {
    final l10n = context.l10n;
    switch (_currentIndex) {
      case 0:
        return l10n.tradingDashboard;
      case 1:
        return l10n.positions;
      case 2:
        return l10n.strategies;
      case 3:
        return l10n.riskMonitor;
      case 4:
        return l10n.more;
      default:
        return l10n.tradingMCP;
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityStatus = ref.watch(connectivityStatusProvider);

    // Listen for AI Bot errors and show snackbars
    ref.listen<AIBotState>(aiBotProvider, (previous, current) {
      if (current.error != null &&
          (previous?.error != current.error) &&
          mounted) {
        showErrorSnackbar(context, current.userFriendlyError ?? current.error!);
      }
    });

    // Determine connection status and system status from health data
    final isConnected = connectivityStatus.isConnected;

    final systemStatus = connectivityStatus == ConnectivityStatus.connected
        ? 'running'
        : connectivityStatus == ConnectivityStatus.checking
            ? 'connecting'
            : 'error';

    return Scaffold(
      appBar: CustomAppBar(
        title: _getAppBarTitle(context),
        status: systemStatus,
        isConnected: isConnected,
        onSettingsTap: _onSettingsTap,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          const DashboardScreen(),
          const PositionsScreen(),
          const StrategiesScreen(),
          const RiskScreen(),
          _buildMoreScreen(),
        ],
      ),
      bottomNavigationBar: Builder(builder: (context) {
        final l10n = context.l10n;
        return NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(Icons.dashboard),
              label: l10n.home,
            ),
            NavigationDestination(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: const Icon(Icons.account_balance_wallet),
              label: l10n.positions,
            ),
            NavigationDestination(
              icon: const Icon(Icons.psychology_outlined),
              selectedIcon: const Icon(Icons.psychology),
              label: l10n.strategies,
            ),
            NavigationDestination(
              icon: const Icon(Icons.security_outlined),
              selectedIcon: const Icon(Icons.security),
              label: l10n.risk,
            ),
            NavigationDestination(
              icon: const Icon(Icons.more_horiz_outlined),
              selectedIcon: const Icon(Icons.more_horiz),
              label: l10n.more,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMoreScreen() {
    return Builder(builder: (context) {
      final l10n = context.l10n;
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Nueva sección: Funcionalidades Avanzadas
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Funcionalidades Avanzadas',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.psychology),
                  title: const Text('Dashboard de IA'),
                  subtitle:
                      const Text('Análisis inteligente y recomendaciones'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AIDashboardScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.smart_toy),
                  title: const Text('Bot Autónomo'),
                  subtitle:
                      const Text('Control y monitoreo del bot de trading'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'BOT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AIBotControlScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.insights),
                  title: const Text('Análisis Comprensivo'),
                  subtitle:
                      const Text('Análisis técnico multi-temporal con IA'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            const ComprehensiveAnalysisScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.dashboard_customize),
                  title: const Text('Trading Hub'),
                  subtitle: const Text('Interfaz unificada de trading'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TradingHubScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sección: Herramientas de Análisis
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.analytics,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Herramientas de Análisis',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.analytics),
                  title: Text(l10n.multiTimeframeAnalysis),
                  subtitle: Text(l10n.technicalAnalysisMultipleTimeframes),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MultiTimeframeScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(l10n.backtesting),
                  subtitle: Text(l10n.testStrategiesWithHistoricalData),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const BacktestScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.tune),
                  title: Text(l10n.parameterOptimization),
                  subtitle: Text(l10n.optimizeStrategyParameters),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const OptimizationScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.speed),
                  title: Text(l10n.executionStats),
                  subtitle: Text(l10n.viewLatencyPerformance),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ExecutionStatsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.show_chart),
                  title: Text(l10n.performanceCharts),
                  subtitle: Text(l10n.detailedCharts),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PerformanceChartsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.paid),
                  title: Text(l10n.tradingPairs),
                  subtitle: Text(l10n.manageTradingPairs),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TradingPairsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(l10n.alerts),
                  subtitle: Text(l10n.configureNotifications),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AlertsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sección: Trading Avanzado
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Trading Avanzado',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance),
                  title: const Text('Posiciones Futures'),
                  subtitle: const Text('Gestión de posiciones de futuros'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FuturesPositionsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: const Text('Tipos de Mercado'),
                  subtitle: const Text('Spot, Futures, Margin, Options'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'DEMO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MarketTypeDemoScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.analytics),
                  title: const Text('MCP Trading'),
                  subtitle: const Text('Señales y análisis MCP'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MCPMainScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_suggest),
                  title: const Text('Configuración del Bot'),
                  subtitle: const Text('Configurar parámetros del bot de IA'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AiBotConfigScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sección: Configuración
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Configuración',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(l10n.settings),
                  subtitle: Text(l10n.appPreferences),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // Navigate to settings
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.about),
                  subtitle: Text(l10n.appInformation),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showAboutDialog();
                  },
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  void _showAboutDialog() {
    final l10n = context.l10n;
    showAboutDialog(
      context: context,
      applicationName: l10n.tradingMCP,
      applicationVersion: l10n.appVersion,
      applicationIcon: const Icon(
        Icons.currency_bitcoin,
        size: 48,
        color: Color(0xFF4CAF50),
      ),
      children: [
        Text(l10n.appDescription),
        const SizedBox(height: 16),
        Text(l10n.backendVersion),
      ],
    );
  }
}
