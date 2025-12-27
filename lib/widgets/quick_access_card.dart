import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget de acceso rápido para funcionalidades principales
class QuickAccessCard extends StatelessWidget {
  const QuickAccessCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Acceso Rápido',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Grid de accesos rápidos
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildQuickAccessButton(
                  context,
                  icon: Icons.psychology,
                  label: 'Dashboard IA',
                  color: Colors.purple,
                  onTap: () => _navigateToAIDashboard(context),
                ),
                _buildQuickAccessButton(
                  context,
                  icon: Icons.smart_toy,
                  label: 'Bot Autónomo',
                  color: Colors.orange,
                  onTap: () => _navigateToBotControl(context),
                ),
                _buildQuickAccessButton(
                  context,
                  icon: Icons.insights,
                  label: 'Análisis Pro',
                  color: Colors.blue,
                  onTap: () => _navigateToAnalysis(context),
                ),
                _buildQuickAccessButton(
                  context,
                  icon: Icons.dashboard_customize,
                  label: 'Trading Hub',
                  color: Colors.green,
                  onTap: () => _navigateToTradingHub(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAIDashboard(BuildContext context) {
    Navigator.of(context).pushNamed('/ai-dashboard');
  }

  void _navigateToBotControl(BuildContext context) {
    Navigator.of(context).pushNamed('/bot-control');
  }

  void _navigateToAnalysis(BuildContext context) {
    Navigator.of(context).pushNamed('/comprehensive-analysis');
  }

  void _navigateToTradingHub(BuildContext context) {
    Navigator.of(context).pushNamed('/trading-hub');
  }
}
