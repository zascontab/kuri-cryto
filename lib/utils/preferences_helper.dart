import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

/// Helper para gestionar preferencias de usuario con SharedPreferences
///
/// Este archivo proporciona funciones para guardar y recuperar preferencias
/// de usuario como tema, idioma, configuraciones, etc.
///
/// Ejemplos de uso:
/// ```dart
/// // Inicializar
/// await PreferencesHelper.init();
///
/// // Guardar tema
/// await PreferencesHelper.saveThemeMode(ThemeMode.dark);
///
/// // Obtener tema
/// final theme = PreferencesHelper.getThemeMode();
///
/// // Guardar símbolo favorito
/// await PreferencesHelper.saveLastSymbol('BTC-USDT');
/// ```
class PreferencesHelper {
  // Singleton instance
  static PreferencesHelper? _instance;
  static SharedPreferences? _prefs;

  PreferencesHelper._();

  /// Obtiene la instancia singleton
  static PreferencesHelper get instance {
    _instance ??= PreferencesHelper._();
    return _instance!;
  }

  /// Inicializa SharedPreferences
  ///
  /// Debe llamarse antes de usar cualquier otro método
  ///
  /// Ejemplo:
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await PreferencesHelper.init();
  ///   runApp(MyApp());
  /// }
  /// ```
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Obtiene la instancia de SharedPreferences
  ///
  /// Lanza una excepción si no se ha inicializado
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
        'PreferencesHelper not initialized. Call PreferencesHelper.init() first.',
      );
    }
    return _prefs!;
  }

  // ==========================================================================
  // Tema
  // ==========================================================================

  /// Guarda el modo de tema
  ///
  /// [mode]: Modo de tema (light, dark, system)
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.saveThemeMode(ThemeMode.dark);
  /// ```
  static Future<bool> saveThemeMode(ThemeMode mode) async {
    return await prefs.setString(
      AppConstants.prefThemeMode,
      mode.toString(),
    );
  }

  /// Obtiene el modo de tema guardado
  ///
  /// Retorna ThemeMode.system por defecto si no hay preferencia guardada
  ///
  /// Ejemplo:
  /// ```dart
  /// final theme = PreferencesHelper.getThemeMode();
  /// ```
  static ThemeMode getThemeMode() {
    final themeString = prefs.getString(AppConstants.prefThemeMode);

    if (themeString == null) return ThemeMode.system;

    switch (themeString) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.system':
      default:
        return ThemeMode.system;
    }
  }

  /// Verifica si el tema oscuro está activo
  ///
  /// [brightness]: Brightness del sistema (opcional)
  ///
  /// Ejemplo:
  /// ```dart
  /// final isDark = PreferencesHelper.isDarkMode(
  ///   MediaQuery.of(context).platformBrightness,
  /// );
  /// ```
  static bool isDarkMode(Brightness? brightness) {
    final mode = getThemeMode();

    switch (mode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
      default:
        return brightness == Brightness.dark;
    }
  }

  // ==========================================================================
  // Idioma/Locale
  // ==========================================================================

  /// Guarda el locale preferido
  ///
  /// [locale]: Locale a guardar (e.g., 'en', 'es', 'en_US')
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.saveLocale('es');
  /// ```
  static Future<bool> saveLocale(String locale) async {
    return await prefs.setString(AppConstants.prefLocale, locale);
  }

  /// Obtiene el locale guardado
  ///
  /// Retorna null si no hay preferencia guardada
  ///
  /// Ejemplo:
  /// ```dart
  /// final locale = PreferencesHelper.getLocale();
  /// ```
  static String? getLocale() {
    return prefs.getString(AppConstants.prefLocale);
  }

  /// Obtiene el Locale como objeto Locale
  ///
  /// Retorna null si no hay preferencia guardada
  ///
  /// Ejemplo:
  /// ```dart
  /// final locale = PreferencesHelper.getLocaleObject();
  /// if (locale != null) {
  ///   // Use locale
  /// }
  /// ```
  static Locale? getLocaleObject() {
    final localeString = getLocale();
    if (localeString == null) return null;

    final parts = localeString.split('_');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }

    return Locale(parts[0]);
  }

  // ==========================================================================
  // Trading
  // ==========================================================================

  /// Guarda el último símbolo usado
  ///
  /// [symbol]: Símbolo de trading (e.g., 'BTC-USDT')
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.saveLastSymbol('BTC-USDT');
  /// ```
  static Future<bool> saveLastSymbol(String symbol) async {
    return await prefs.setString(AppConstants.prefLastSymbol, symbol);
  }

  /// Obtiene el último símbolo usado
  ///
  /// Retorna el símbolo por defecto si no hay preferencia guardada
  ///
  /// Ejemplo:
  /// ```dart
  /// final symbol = PreferencesHelper.getLastSymbol();
  /// ```
  static String getLastSymbol() {
    return prefs.getString(AppConstants.prefLastSymbol) ??
        AppConstants.defaultSymbol;
  }

  /// Guarda el timeframe por defecto
  ///
  /// [timeframe]: Timeframe (e.g., '1h', '4h', '1d')
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.saveDefaultTimeframe('4h');
  /// ```
  static Future<bool> saveDefaultTimeframe(String timeframe) async {
    return await prefs.setString(
      AppConstants.prefDefaultTimeframe,
      timeframe,
    );
  }

  /// Obtiene el timeframe por defecto
  ///
  /// Retorna '1h' por defecto si no hay preferencia guardada
  ///
  /// Ejemplo:
  /// ```dart
  /// final timeframe = PreferencesHelper.getDefaultTimeframe();
  /// ```
  static String getDefaultTimeframe() {
    return prefs.getString(AppConstants.prefDefaultTimeframe) ??
        Timeframes.oneHour;
  }

  /// Guarda el tipo de gráfico preferido
  ///
  /// [chartType]: Tipo de gráfico ('candlestick', 'line', 'area')
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.saveChartType('candlestick');
  /// ```
  static Future<bool> saveChartType(String chartType) async {
    return await prefs.setString(AppConstants.prefChartType, chartType);
  }

  /// Obtiene el tipo de gráfico preferido
  ///
  /// Retorna 'candlestick' por defecto
  ///
  /// Ejemplo:
  /// ```dart
  /// final chartType = PreferencesHelper.getChartType();
  /// ```
  static String getChartType() {
    return prefs.getString(AppConstants.prefChartType) ?? 'candlestick';
  }

  // ==========================================================================
  // Notificaciones
  // ==========================================================================

  /// Guarda el estado de las notificaciones
  ///
  /// [enabled]: Si las notificaciones están habilitadas
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.saveNotificationsEnabled(true);
  /// ```
  static Future<bool> saveNotificationsEnabled(bool enabled) async {
    return await prefs.setBool(AppConstants.prefNotifications, enabled);
  }

  /// Verifica si las notificaciones están habilitadas
  ///
  /// Retorna true por defecto
  ///
  /// Ejemplo:
  /// ```dart
  /// final enabled = PreferencesHelper.areNotificationsEnabled();
  /// ```
  static bool areNotificationsEnabled() {
    return prefs.getBool(AppConstants.prefNotifications) ?? true;
  }

  // ==========================================================================
  // Símbolos Favoritos
  // ==========================================================================

  /// Guarda la lista de símbolos favoritos
  ///
  /// [symbols]: Lista de símbolos favoritos
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.saveFavoriteSymbols(['BTC-USDT', 'ETH-USDT']);
  /// ```
  static Future<bool> saveFavoriteSymbols(List<String> symbols) async {
    return await prefs.setStringList('favorite_symbols', symbols);
  }

  /// Obtiene la lista de símbolos favoritos
  ///
  /// Retorna una lista vacía si no hay favoritos
  ///
  /// Ejemplo:
  /// ```dart
  /// final favorites = PreferencesHelper.getFavoriteSymbols();
  /// ```
  static List<String> getFavoriteSymbols() {
    return prefs.getStringList('favorite_symbols') ?? [];
  }

  /// Añade un símbolo a favoritos
  ///
  /// [symbol]: Símbolo a añadir
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.addFavoriteSymbol('BTC-USDT');
  /// ```
  static Future<bool> addFavoriteSymbol(String symbol) async {
    final favorites = getFavoriteSymbols();
    if (!favorites.contains(symbol)) {
      favorites.add(symbol);
      return await saveFavoriteSymbols(favorites);
    }
    return true;
  }

  /// Remueve un símbolo de favoritos
  ///
  /// [symbol]: Símbolo a remover
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.removeFavoriteSymbol('BTC-USDT');
  /// ```
  static Future<bool> removeFavoriteSymbol(String symbol) async {
    final favorites = getFavoriteSymbols();
    favorites.remove(symbol);
    return await saveFavoriteSymbols(favorites);
  }

  /// Verifica si un símbolo está en favoritos
  ///
  /// [symbol]: Símbolo a verificar
  ///
  /// Ejemplo:
  /// ```dart
  /// final isFavorite = PreferencesHelper.isFavoriteSymbol('BTC-USDT');
  /// ```
  static bool isFavoriteSymbol(String symbol) {
    return getFavoriteSymbols().contains(symbol);
  }

  /// Alterna un símbolo en favoritos
  ///
  /// [symbol]: Símbolo a alternar
  ///
  /// Retorna true si se añadió, false si se removió
  ///
  /// Ejemplo:
  /// ```dart
  /// final added = await PreferencesHelper.toggleFavoriteSymbol('BTC-USDT');
  /// ```
  static Future<bool> toggleFavoriteSymbol(String symbol) async {
    if (isFavoriteSymbol(symbol)) {
      await removeFavoriteSymbol(symbol);
      return false;
    } else {
      await addFavoriteSymbol(symbol);
      return true;
    }
  }

  // ==========================================================================
  // Configuración de Riesgo
  // ==========================================================================

  /// Guarda el modo de riesgo preferido
  ///
  /// [mode]: Modo de riesgo ('conservative', 'moderate', 'aggressive')
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.saveRiskMode('moderate');
  /// ```
  static Future<bool> saveRiskMode(String mode) async {
    return await prefs.setString('risk_mode', mode);
  }

  /// Obtiene el modo de riesgo preferido
  ///
  /// Retorna 'moderate' por defecto
  ///
  /// Ejemplo:
  /// ```dart
  /// final riskMode = PreferencesHelper.getRiskMode();
  /// ```
  static String getRiskMode() {
    return prefs.getString('risk_mode') ?? RiskModes.moderate;
  }

  /// Guarda el porcentaje máximo de riesgo por operación
  ///
  /// [percent]: Porcentaje de riesgo (0-100)
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.saveMaxRiskPerTrade(2.0);
  /// ```
  static Future<bool> saveMaxRiskPerTrade(double percent) async {
    return await prefs.setDouble('max_risk_per_trade', percent);
  }

  /// Obtiene el porcentaje máximo de riesgo por operación
  ///
  /// Retorna 2.0% por defecto
  ///
  /// Ejemplo:
  /// ```dart
  /// final maxRisk = PreferencesHelper.getMaxRiskPerTrade();
  /// ```
  static double getMaxRiskPerTrade() {
    return prefs.getDouble('max_risk_per_trade') ?? 2.0;
  }

  // ==========================================================================
  // Autenticación
  // ==========================================================================

  /// Guarda el token de autenticación
  ///
  /// [token]: Token JWT o similar
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.saveAuthToken('eyJ...');
  /// ```
  static Future<bool> saveAuthToken(String token) async {
    return await prefs.setString('auth_token', token);
  }

  /// Obtiene el token de autenticación
  ///
  /// Retorna null si no hay token guardado
  ///
  /// Ejemplo:
  /// ```dart
  /// final token = PreferencesHelper.getAuthToken();
  /// ```
  static String? getAuthToken() {
    return prefs.getString('auth_token');
  }

  /// Remueve el token de autenticación
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.removeAuthToken();
  /// ```
  static Future<bool> removeAuthToken() async {
    return await prefs.remove('auth_token');
  }

  /// Verifica si el usuario está autenticado
  ///
  /// Ejemplo:
  /// ```dart
  /// if (PreferencesHelper.isAuthenticated()) {
  ///   // User is logged in
  /// }
  /// ```
  static bool isAuthenticated() {
    return getAuthToken() != null;
  }

  /// Guarda el ID del usuario
  ///
  /// [userId]: ID del usuario
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.saveUserId('user123');
  /// ```
  static Future<bool> saveUserId(String userId) async {
    return await prefs.setString('user_id', userId);
  }

  /// Obtiene el ID del usuario
  ///
  /// Ejemplo:
  /// ```dart
  /// final userId = PreferencesHelper.getUserId();
  /// ```
  static String? getUserId() {
    return prefs.getString('user_id');
  }

  /// Guarda el email del usuario
  ///
  /// [email]: Email del usuario
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.saveUserEmail('user@example.com');
  /// ```
  static Future<bool> saveUserEmail(String email) async {
    return await prefs.setString('user_email', email);
  }

  /// Obtiene el email del usuario
  ///
  /// Ejemplo:
  /// ```dart
  /// final email = PreferencesHelper.getUserEmail();
  /// ```
  static String? getUserEmail() {
    return prefs.getString('user_email');
  }

  // ==========================================================================
  // Onboarding
  // ==========================================================================

  /// Marca el onboarding como completado
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.setOnboardingCompleted();
  /// ```
  static Future<bool> setOnboardingCompleted() async {
    return await prefs.setBool('onboarding_completed', true);
  }

  /// Verifica si el onboarding está completado
  ///
  /// Ejemplo:
  /// ```dart
  /// if (!PreferencesHelper.isOnboardingCompleted()) {
  ///   // Show onboarding
  /// }
  /// ```
  static bool isOnboardingCompleted() {
    return prefs.getBool('onboarding_completed') ?? false;
  }

  // ==========================================================================
  // Cache de Datos
  // ==========================================================================

  /// Guarda datos en cache con timestamp
  ///
  /// [key]: Clave del cache
  /// [data]: Datos a guardar (como JSON string)
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.saveCachedData('market_data', jsonString);
  /// ```
  static Future<bool> saveCachedData(String key, String data) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('${key}_timestamp', timestamp);
    return await prefs.setString('cache_$key', data);
  }

  /// Obtiene datos del cache
  ///
  /// [key]: Clave del cache
  /// [maxAge]: Edad máxima del cache (por defecto 5 minutos)
  ///
  /// Retorna null si no hay datos o están expirados
  ///
  /// Ejemplo:
  /// ```dart
  /// final data = PreferencesHelper.getCachedData('market_data');
  /// ```
  static String? getCachedData(
    String key, {
    Duration maxAge = const Duration(minutes: 5),
  }) {
    final timestamp = prefs.getInt('${key}_timestamp');
    if (timestamp == null) return null;

    final cacheDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    if (now.difference(cacheDate) > maxAge) {
      // Cache expirado
      return null;
    }

    return prefs.getString('cache_$key');
  }

  /// Limpia un cache específico
  ///
  /// [key]: Clave del cache a limpiar
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.clearCache('market_data');
  /// ```
  static Future<bool> clearCache(String key) async {
    await prefs.remove('${key}_timestamp');
    return await prefs.remove('cache_$key');
  }

  // ==========================================================================
  // Utilidades
  // ==========================================================================

  /// Limpia todas las preferencias
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.clearAll();
  /// ```
  static Future<bool> clearAll() async {
    return await prefs.clear();
  }

  /// Limpia todas las preferencias excepto las especificadas
  ///
  /// [keysToKeep]: Lista de claves a mantener
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.clearAllExcept(['auth_token', 'user_id']);
  /// ```
  static Future<void> clearAllExcept(List<String> keysToKeep) async {
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (!keysToKeep.contains(key)) {
        await prefs.remove(key);
      }
    }
  }

  /// Verifica si existe una clave
  ///
  /// [key]: Clave a verificar
  ///
  /// Ejemplo:
  /// ```dart
  /// if (PreferencesHelper.containsKey('auth_token')) {
  ///   // Key exists
  /// }
  /// ```
  static bool containsKey(String key) {
    return prefs.containsKey(key);
  }

  /// Obtiene todas las claves guardadas
  ///
  /// Ejemplo:
  /// ```dart
  /// final keys = PreferencesHelper.getAllKeys();
  /// ```
  static Set<String> getAllKeys() {
    return prefs.getKeys();
  }

  /// Obtiene un valor genérico
  ///
  /// [key]: Clave del valor
  ///
  /// Ejemplo:
  /// ```dart
  /// final value = PreferencesHelper.getValue('custom_key');
  /// ```
  static Object? getValue(String key) {
    return prefs.get(key);
  }

  /// Guarda un valor String
  ///
  /// [key]: Clave
  /// [value]: Valor a guardar
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.setString('custom_key', 'value');
  /// ```
  static Future<bool> setString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  /// Guarda un valor int
  ///
  /// [key]: Clave
  /// [value]: Valor a guardar
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.setInt('custom_key', 123);
  /// ```
  static Future<bool> setInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }

  /// Guarda un valor double
  ///
  /// [key]: Clave
  /// [value]: Valor a guardar
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.setDouble('custom_key', 123.45);
  /// ```
  static Future<bool> setDouble(String key, double value) async {
    return await prefs.setDouble(key, value);
  }

  /// Guarda un valor bool
  ///
  /// [key]: Clave
  /// [value]: Valor a guardar
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.setBool('custom_key', true);
  /// ```
  static Future<bool> setBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  /// Obtiene un valor String
  ///
  /// [key]: Clave
  ///
  /// Ejemplo:
  /// ```dart
  /// final value = PreferencesHelper.getString('custom_key');
  /// ```
  static String? getString(String key) {
    return prefs.getString(key);
  }

  /// Obtiene un valor int
  ///
  /// [key]: Clave
  ///
  /// Ejemplo:
  /// ```dart
  /// final value = PreferencesHelper.getInt('custom_key');
  /// ```
  static int? getInt(String key) {
    return prefs.getInt(key);
  }

  /// Obtiene un valor double
  ///
  /// [key]: Clave
  ///
  /// Ejemplo:
  /// ```dart
  /// final value = PreferencesHelper.getDouble('custom_key');
  /// ```
  static double? getDouble(String key) {
    return prefs.getDouble(key);
  }

  /// Obtiene un valor bool
  ///
  /// [key]: Clave
  ///
  /// Ejemplo:
  /// ```dart
  /// final value = PreferencesHelper.getBool('custom_key');
  /// ```
  static bool? getBool(String key) {
    return prefs.getBool(key);
  }

  /// Remueve un valor
  ///
  /// [key]: Clave a remover
  ///
  /// Ejemplo:
  /// ```dart
  /// await PreferencesHelper.remove('custom_key');
  /// ```
  static Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }
}
