import 'package:flutter/material.dart';
import '../widgets/theme_toggle_button.dart';
import '../config/app_theme.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuri Crypto'),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con estadísticas principales
            _buildStatsCards(context),
            const SizedBox(height: 24),

            // Sección de posiciones
            Text(
              'Posiciones Abiertas',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            _buildPositionsList(context),
            const SizedBox(height: 24),

            // Sección de estrategias
            Text(
              'Estrategias Activas',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            _buildStrategiesList(context),
            const SizedBox(height: 24),

            // Sección de alertas
            Text(
              'Alertas Recientes',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            _buildAlertsList(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Acción para iniciar/detener trading
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text('Iniciar Trading'),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'P&L Total',
            '\$2,450.50',
            '+12.5%',
            AppTheme.profitGreen,
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Win Rate',
            '68.5%',
            '+2.3%',
            AppTheme.profitGreen,
            Icons.check_circle_outline,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    String change,
    Color changeColor,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Icon(icon, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.arrow_upward,
                  size: 14,
                  color: changeColor,
                ),
                const SizedBox(width: 4),
                Text(
                  change,
                  style: TextStyle(
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionsList(BuildContext context) {
    final positions = [
      {
        'symbol': 'BTC/USDT',
        'side': 'LONG',
        'entry': '42,500',
        'current': '43,200',
        'pnl': '+\$350.00',
        'pnlPercent': '+1.65%',
        'isProfit': true,
      },
      {
        'symbol': 'ETH/USDT',
        'side': 'SHORT',
        'entry': '2,250',
        'current': '2,180',
        'pnl': '+\$140.00',
        'pnlPercent': '+3.11%',
        'isProfit': true,
      },
      {
        'symbol': 'SOL/USDT',
        'side': 'LONG',
        'entry': '98.50',
        'current': '96.20',
        'pnl': '-\$46.00',
        'pnlPercent': '-2.34%',
        'isProfit': false,
      },
    ];

    return Column(
      children: positions.map((pos) => _buildPositionCard(context, pos)).toList(),
    );
  }

  Widget _buildPositionCard(BuildContext context, Map<String, dynamic> position) {
    final isProfit = position['isProfit'] as bool;
    final pnlColor = isProfit ? AppTheme.profitGreen : AppTheme.lossRed;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      position['symbol'],
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: position['side'] == 'LONG'
                            ? AppTheme.profitGreen.withOpacity(0.2)
                            : AppTheme.lossRed.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        position['side'],
                        style: TextStyle(
                          color: position['side'] == 'LONG'
                              ? AppTheme.profitGreen
                              : AppTheme.lossRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      position['pnl'],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: pnlColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      position['pnlPercent'],
                      style: TextStyle(
                        color: pnlColor,
                        fontSize: 12,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Entrada',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '\$${position['entry']}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Actual',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '\$${position['current']}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategiesList(BuildContext context) {
    final strategies = [
      {'name': 'Scalping BTC', 'status': 'active', 'winRate': '72%', 'trades': '145'},
      {'name': 'Mean Reversion ETH', 'status': 'active', 'winRate': '65%', 'trades': '89'},
      {'name': 'Breakout SOL', 'status': 'paused', 'winRate': '58%', 'trades': '34'},
    ];

    return Column(
      children: strategies.map((strategy) => _buildStrategyCard(context, strategy)).toList(),
    );
  }

  Widget _buildStrategyCard(BuildContext context, Map<String, String> strategy) {
    final isActive = strategy['status'] == 'active';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive
              ? AppTheme.profitGreen.withOpacity(0.2)
              : AppTheme.neutralGray.withOpacity(0.2),
          child: Icon(
            isActive ? Icons.play_arrow : Icons.pause,
            color: isActive ? AppTheme.profitGreen : AppTheme.neutralGray,
          ),
        ),
        title: Text(strategy['name']!),
        subtitle: Text(
          'Win Rate: ${strategy['winRate']} • ${strategy['trades']} trades',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: Switch(
          value: isActive,
          onChanged: (value) {
            // Toggle strategy
          },
        ),
      ),
    );
  }

  Widget _buildAlertsList(BuildContext context) {
    final alerts = [
      {
        'type': 'warning',
        'message': 'Drawdown diario: 3.5%',
        'time': 'Hace 5 min',
      },
      {
        'type': 'info',
        'message': 'Nueva señal de compra en BTC',
        'time': 'Hace 12 min',
      },
      {
        'type': 'success',
        'message': 'TP alcanzado en ETH/USDT',
        'time': 'Hace 25 min',
      },
    ];

    return Column(
      children: alerts.map((alert) => _buildAlertCard(context, alert)).toList(),
    );
  }

  Widget _buildAlertCard(BuildContext context, Map<String, String> alert) {
    IconData icon;
    Color color;

    switch (alert['type']) {
      case 'warning':
        icon = Icons.warning_amber;
        color = AppTheme.warningYellow;
        break;
      case 'success':
        icon = Icons.check_circle;
        color = AppTheme.profitGreen;
        break;
      default:
        icon = Icons.info;
        color = Theme.of(context).colorScheme.primary;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(alert['message']!),
        subtitle: Text(
          alert['time']!,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
