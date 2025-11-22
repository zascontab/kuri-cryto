import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_theme.dart';
import 'providers/theme_provider.dart' as theme_provider;
import 'screens/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: KuriCryptoApp(),
    ),
  );
}

class KuriCryptoApp extends ConsumerWidget {
  const KuriCryptoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(theme_provider.themeProvider);

    // Convertir nuestro ThemeMode al ThemeMode de Flutter
    final flutterThemeMode = _convertThemeMode(themeMode);

    return MaterialApp(
      title: 'Kuri Crypto',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: flutterThemeMode,
      home: const HomeScreen(),
    );
  }

  ThemeMode _convertThemeMode(theme_provider.ThemeMode mode) {
    switch (mode) {
      case theme_provider.ThemeMode.light:
        return ThemeMode.light;
      case theme_provider.ThemeMode.dark:
        return ThemeMode.dark;
      case theme_provider.ThemeMode.system:
        return ThemeMode.system;
    }
  }
}
