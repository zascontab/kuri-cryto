import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum para representar el modo de tema
enum ThemeMode {
  light,
  dark,
  system,
}

/// Notificador para manejar el estado del tema
class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeModeKey = 'theme_mode';

  ThemeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  /// Carga el modo de tema guardado
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeModeKey);

      if (themeModeString != null) {
        state = ThemeMode.values.firstWhere(
          (e) => e.toString() == themeModeString,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (e) {
      // Si hay error, mantener el tema por defecto (system)
      debugPrint('Error loading theme mode: $e');
    }
  }

  /// Cambia el modo de tema y lo guarda
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.toString());
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  /// Alterna entre modo claro y oscuro
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Obtiene si el tema actual es oscuro basado en el brillo del sistema
  bool isDark(Brightness systemBrightness) {
    switch (state) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return systemBrightness == Brightness.dark;
    }
  }
}

/// Provider para el modo de tema
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

/// Provider para obtener si el tema oscuro está activo
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeProvider);
  // Por defecto usamos Brightness.light si no hay contexto
  // En la app real, esto se obtiene del contexto
  if (themeMode == ThemeMode.dark) {
    return true;
  } else if (themeMode == ThemeMode.light) {
    return false;
  }
  return false; // Por defecto modo claro
});
