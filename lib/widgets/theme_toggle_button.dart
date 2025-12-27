import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart' as theme_provider;

/// Widget de botón para cambiar entre modo claro y oscuro
class ThemeToggleButton extends ConsumerWidget {
  final bool showLabel;

  const ThemeToggleButton({
    super.key,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(theme_provider.themeProvider);
    final isDark = themeMode == theme_provider.ThemeMode.dark;

    return showLabel
        ? _buildWithLabel(context, ref, isDark)
        : _buildIconButton(context, ref, isDark);
  }

  Widget _buildIconButton(BuildContext context, WidgetRef ref, bool isDark) {
    return IconButton(
      icon: Icon(
        isDark ? Icons.light_mode : Icons.dark_mode,
      ),
      onPressed: () => _toggleTheme(ref),
      tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
    );
  }

  Widget _buildWithLabel(BuildContext context, WidgetRef ref, bool isDark) {
    return InkWell(
      onTap: () => _toggleTheme(ref),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isDark ? 'Modo claro' : 'Modo oscuro',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleTheme(WidgetRef ref) {
    ref.read(theme_provider.themeProvider.notifier).toggleTheme();
  }
}

/// Widget de switch animado para cambiar el tema
class ThemeSwitch extends ConsumerWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(theme_provider.themeProvider);
    final isDark = themeMode == theme_provider.ThemeMode.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.light_mode,
          size: 20,
          color: !isDark
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).iconTheme.color,
        ),
        const SizedBox(width: 8),
        Switch(
          value: isDark,
          onChanged: (value) {
            ref.read(theme_provider.themeProvider.notifier).setThemeMode(
                  value
                      ? theme_provider.ThemeMode.dark
                      : theme_provider.ThemeMode.light,
                );
          },
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.dark_mode,
          size: 20,
          color: isDark
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).iconTheme.color,
        ),
      ],
    );
  }
}

/// Selector de modo de tema con tres opciones
class ThemeModeSelector extends ConsumerWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(theme_provider.themeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Tema',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildOption(
          context,
          ref,
          theme_provider.ThemeMode.light,
          'Claro',
          Icons.light_mode,
          currentThemeMode,
        ),
        const SizedBox(height: 8),
        _buildOption(
          context,
          ref,
          theme_provider.ThemeMode.dark,
          'Oscuro',
          Icons.dark_mode,
          currentThemeMode,
        ),
        const SizedBox(height: 8),
        _buildOption(
          context,
          ref,
          theme_provider.ThemeMode.system,
          'Sistema',
          Icons.settings_suggest,
          currentThemeMode,
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context,
    WidgetRef ref,
    theme_provider.ThemeMode mode,
    String label,
    IconData icon,
    theme_provider.ThemeMode currentMode,
  ) {
    final isSelected = mode == currentMode;

    return InkWell(
      onTap: () {
        ref.read(theme_provider.themeProvider.notifier).setThemeMode(mode);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).iconTheme.color,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
