import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pantalla para configurar IA
///
/// Permite configurar:
/// - Habilitar/deshabilitar IA
/// - Habilitar/deshabilitar sentimiento
/// - Seleccionar provider (Gemini/GPT/Claude)
/// - Configurar presupuesto diario
/// - Configurar límite de llamadas
class AISettingsScreen extends ConsumerStatefulWidget {
  const AISettingsScreen({super.key});

  @override
  ConsumerState<AISettingsScreen> createState() => _AISettingsScreenState();
}

class _AISettingsScreenState extends ConsumerState<AISettingsScreen> {
  bool _enableLLM = true;
  bool _enableSentiment = true;
  String _selectedProvider = 'google';
  double _dailyBudget = 2.0;
  int _dailyLimit = 100;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de IA'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Enable/Disable IA
          Card(
            child: SwitchListTile(
              title: const Text('Habilitar Análisis con IA'),
              subtitle: const Text('Usar LLM para análisis mejorado'),
              value: _enableLLM,
              onChanged: (value) {
                setState(() => _enableLLM = value);
              },
              secondary: const Icon(Icons.psychology),
            ),
          ),
          const SizedBox(height: 12),

          // Enable/Disable Sentiment
          Card(
            child: SwitchListTile(
              title: const Text('Habilitar Análisis de Sentimiento'),
              subtitle: const Text('Analizar noticias y redes sociales'),
              value: _enableSentiment,
              onChanged: (value) {
                setState(() => _enableSentiment = value);
              },
              secondary: const Icon(Icons.sentiment_satisfied),
            ),
          ),
          const SizedBox(height: 24),

          // Provider Selection
          Text(
            'Proveedor de LLM',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Gemini (Google)'),
                  subtitle: const Text('Rápido y económico'),
                  value: 'google',
                  groupValue: _selectedProvider,
                  onChanged: (value) {
                    setState(() => _selectedProvider = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('GPT (OpenAI)'),
                  subtitle: const Text('Más preciso'),
                  value: 'openai',
                  groupValue: _selectedProvider,
                  onChanged: (value) {
                    setState(() => _selectedProvider = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Claude (Anthropic)'),
                  subtitle: const Text('Análisis detallado'),
                  value: 'anthropic',
                  groupValue: _selectedProvider,
                  onChanged: (value) {
                    setState(() => _selectedProvider = value!);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Budget Settings
          Text(
            'Límites y Presupuesto',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Presupuesto Diario: \$${_dailyBudget.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall,
                  ),
                  Slider(
                    value: _dailyBudget,
                    min: 0.5,
                    max: 10.0,
                    divisions: 19,
                    label: '\$${_dailyBudget.toStringAsFixed(2)}',
                    onChanged: (value) {
                      setState(() => _dailyBudget = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Límite de Llamadas: $_dailyLimit',
                    style: theme.textTheme.titleSmall,
                  ),
                  Slider(
                    value: _dailyLimit.toDouble(),
                    min: 10,
                    max: 500,
                    divisions: 49,
                    label: '$_dailyLimit',
                    onChanged: (value) {
                      setState(() => _dailyLimit = value.toInt());
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Save Button
          ElevatedButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            label: const Text('Guardar Configuración'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    // TODO: Implement save to SharedPreferences
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración guardada'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
