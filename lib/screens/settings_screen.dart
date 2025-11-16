import 'package:flutter/material.dart';
import '../widgets/theme_toggle_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección de Apariencia
          Text(
            'Apariencia',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ThemeModeSelector(),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Toggle rápido',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const ThemeSwitch(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sección de Trading
          Text(
            'Trading',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _buildSettingsCard(
            context,
            'Gestión de Riesgo',
            [
              _buildSettingItem(
                context,
                'Stop Loss Automático',
                'Activar SL automático en nuevas posiciones',
                true,
              ),
              _buildSettingItem(
                context,
                'Trailing Stop',
                'Activar trailing stop por defecto',
                false,
              ),
              _buildSettingItem(
                context,
                'Kill Switch',
                'Parar trading al alcanzar drawdown máximo',
                true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsCard(
            context,
            'Notificaciones',
            [
              _buildSettingItem(
                context,
                'Alertas de Posición',
                'Notificar al abrir/cerrar posiciones',
                true,
              ),
              _buildSettingItem(
                context,
                'Alertas de Riesgo',
                'Notificar eventos de riesgo importantes',
                true,
              ),
              _buildSettingItem(
                context,
                'Señales de Trading',
                'Notificar nuevas señales de trading',
                false,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sección de Cuenta
          Text(
            'Cuenta',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _buildSettingsCard(
            context,
            'Información',
            [
              _buildInfoItem(context, 'Versión', '1.0.0'),
              _buildInfoItem(context, 'API URL', 'http://localhost:8081'),
              _buildInfoItem(context, 'Estado', 'Conectado'),
            ],
          ),
          const SizedBox(height: 24),

          // Botones de acción
          ElevatedButton.icon(
            onPressed: () {
              _showResetDialog(context);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Restablecer Configuración'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              // Manejar cambio de configuración
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restablecer Configuración'),
        content: const Text(
          '¿Estás seguro de que quieres restablecer toda la configuración a los valores por defecto?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Restablecer configuración
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configuración restablecida'),
                ),
              );
            },
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );
  }
}
