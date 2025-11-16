import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/l10n.dart';
import '../providers/locale_provider.dart';

/// Settings screen with app configuration options
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = L10n.of(context);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
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
