import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/app_theme.dart';
import 'l10n/l10n_export.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart' as theme_provider;
import 'screens/main_screen.dart';
import 'models/adapters/position_adapter.dart';
import 'models/adapters/trade_adapter.dart';
import 'models/adapters/strategy_adapter.dart';
import 'models/adapters/risk_state_adapter.dart';
import 'models/adapters/metrics_adapter.dart';
import 'models/adapters/system_status_adapter.dart';
import 'services/cache_service.dart';

/// Punto de entrada principal de la aplicación Kuri Crypto
void main() async {
  // Asegurar que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive para almacenamiento local
  await Hive.initFlutter();

  // Registrar adaptadores de Hive para caché local
  Hive.registerAdapter(PositionAdapter());
  Hive.registerAdapter(TradeAdapter());
  Hive.registerAdapter(StrategyAdapter());
  Hive.registerAdapter(StrategyPerformanceAdapter());
  Hive.registerAdapter(RiskStateAdapter());
  Hive.registerAdapter(MetricsAdapter());
  Hive.registerAdapter(SystemStatusAdapter());

  // Inicializar el servicio de caché
  await CacheService().init();

  // Ejecutar la aplicación envuelta en ProviderScope para Riverpod
  runApp(
    const ProviderScope(
      child: KuriCryptoApp(),
    ),
  );
}

/// Widget raíz de la aplicación
class KuriCryptoApp extends ConsumerWidget {
  const KuriCryptoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(theme_provider.themeProvider);

    // Convertir nuestro ThemeMode al ThemeMode de Flutter
    final flutterThemeMode = _convertThemeMode(themeMode);

    return MaterialApp(
      title: 'Kuri Crypto',
      debugShowCheckedModeBanner: false,

      // Localization
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      locale: locale,

      // Temas usando AppTheme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: flutterThemeMode,

      // Pantalla inicial
      home: const SplashScreen(),

      // TODO: Configurar rutas nombradas
      // routes: {
      //   '/login': (context) => const LoginScreen(),
      //   '/home': (context) => const HomeScreen(),
      //   '/trading': (context) => const TradingScreen(),
      // },
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

/// Pantalla de splash inicial
///
/// Se muestra mientras la aplicación carga recursos y verifica autenticación
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Inicializa la aplicación y navega a la pantalla correspondiente
  Future<void> _initializeApp() async {
    // Simular carga de recursos (2 segundos)
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Verificar si el usuario está autenticado
    // final isAuthenticated = await ref.read(authProvider).isAuthenticated();

    // Navegar a la pantalla principal
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o icono de la app
            Icon(
              Icons.currency_bitcoin,
              size: 100,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 24),

            // Nombre de la aplicación
            Text(
              'Kuri Crypto',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 16),

            // Indicador de carga
            CircularProgressIndicator(
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),

            // Texto de carga
            Text(
              'Cargando...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
