import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/l10n_export.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/theme_toggle_button.dart';
import 'login_screen.dart';

/// Settings screen with app configuration options
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          // Theme Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Apariencia',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        style: theme.textTheme.bodyLarge,
                      ),
                      const ThemeSwitch(),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Language Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.language,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _LanguageTile(
                  title: l10n.english,
                  subtitle: 'English',
                  locale: const Locale('en'),
                  currentLocale: currentLocale,
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                  },
                ),
                const Divider(height: 1),
                _LanguageTile(
                  title: l10n.spanish,
                  subtitle: 'Español',
                  locale: const Locale('es'),
                  currentLocale: currentLocale,
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(const Locale('es'));
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Account Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Cuenta',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _AccountInfoTile(ref: ref),
                const Divider(height: 1),
                _SignOutTile(ref: ref),
              ],
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Locale locale;
  final Locale? currentLocale;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.title,
    required this.subtitle,
    required this.locale,
    required this.currentLocale,
    required this.onTap,
  });

  bool get isSelected {
    if (currentLocale == null) {
      // If no locale is set, use system default
      return false;
    }
    return currentLocale!.languageCode == locale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: onTap,
    );
  }
}

/// Widget que muestra información de la cuenta del usuario
class _AccountInfoTile extends StatelessWidget {
  final WidgetRef ref;

  const _AccountInfoTile({required this.ref});

  @override
  Widget build(BuildContext context) {
    final userInfo = ref.watch(userInfoProvider);

    if (userInfo == null) {
      return const ListTile(
        leading: Icon(Icons.account_circle),
        title: Text('No autenticado'),
        subtitle: Text('Por favor, inicia sesión'),
      );
    }

    return ListTile(
      leading: userInfo['photoUrl'] != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(userInfo['photoUrl'] as String),
            )
          : const CircleAvatar(
              child: Icon(Icons.person),
            ),
      title: Text(userInfo['displayName'] as String? ?? 'Usuario'),
      subtitle: Text(userInfo['email'] as String? ?? ''),
      trailing: Icon(
        Icons.check_circle,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

/// Widget que permite cerrar sesión
class _SignOutTile extends StatelessWidget {
  final WidgetRef ref;

  const _SignOutTile({required this.ref});

  Future<void> _handleSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(authNotifierProvider.notifier).signOut();

        if (context.mounted) {
          // Navegar al login y limpiar el stack de navegación
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cerrar sesión: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      return const SizedBox.shrink();
    }

    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text(
        'Cerrar sesión',
        style: TextStyle(color: Colors.red),
      ),
      onTap: () => _handleSignOut(context),
    );
  }
}
