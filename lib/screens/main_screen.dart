import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboard_screen.dart';
import 'positions_screen.dart';
import 'strategies_screen.dart';
import 'risk_screen.dart';
import '../widgets/custom_app_bar.dart';

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
    // Navigate to settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings coming soon'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Trading Dashboard';
      case 1:
        return 'Positions';
      case 2:
        return 'Strategies';
      case 3:
        return 'Risk Monitor';
      case 4:
        return 'More';
      default:
        return 'Trading MCP';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _getAppBarTitle(),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Positions',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology),
            label: 'Strategies',
          ),
          NavigationDestination(
            icon: Icon(Icons.security_outlined),
            selectedIcon: Icon(Icons.security),
            label: 'Risk',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz_outlined),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }

  Widget _buildMoreScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.speed),
                title: const Text('Execution Stats'),
                subtitle: const Text('View latency and performance'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Navigate to execution stats
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.paid),
                title: const Text('Trading Pairs'),
                subtitle: const Text('Manage trading pairs'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Navigate to pairs management
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Alerts'),
                subtitle: const Text('Configure notifications'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Navigate to alerts
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
                title: const Text('Settings'),
                subtitle: const Text('App preferences'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Navigate to settings
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                subtitle: const Text('App information'),
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

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Trading MCP',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.currency_bitcoin,
        size: 48,
        color: Color(0xFF4CAF50),
      ),
      children: [
        const Text('Advanced cryptocurrency trading automation platform'),
        const SizedBox(height: 16),
        const Text('Backend: Trading MCP Server v1.0.0'),
      ],
    );
  }
}
