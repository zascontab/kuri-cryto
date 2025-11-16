import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../widgets/custom_app_bar.dart';
import '../l10n/l10n.dart';

/// Main screen with bottom navigation and PageView
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  // Mock data - replace with actual state management
  String _systemStatus = 'running';
  bool _isConnected = true;

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
    final l10n = L10n.of(context);
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
    return Scaffold(
      appBar: CustomAppBar(
        title: _getAppBarTitle(context),
        status: _systemStatus,
        isConnected: _isConnected,
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
      bottomNavigationBar: Builder(
        builder: (context) {
          final l10n = L10n.of(context);
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
        }
      ),
    );
  }

  Widget _buildMoreScreen() {
    return Builder(
      builder: (context) {
        final l10n = L10n.of(context);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Column(
                children: [
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
            Card(
              child: Column(
                children: [
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
      }
    );
  }

  void _showAboutDialog() {
    final l10n = L10n.of(context);
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
