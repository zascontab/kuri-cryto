import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'l10n/l10n.dart';
import 'screens/main_screen.dart';

/// Punto de entrada principal de la aplicación Kuri Crypto
void main() async {
  // Asegurar que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive para almacenamiento local
  await Hive.initFlutter();

  // TODO: Registrar adaptadores de Hive aquí
  // Hive.registerAdapter(UserAdapter());
  // Hive.registerAdapter(OrderAdapter());

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
    return MaterialApp(
      title: 'Kuri Crypto',
      debugShowCheckedModeBanner: false,

      // Localization
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,

      // Configuración de tema claro
      theme: _buildLightTheme(),

      // Configuración de tema oscuro
      darkTheme: _buildDarkTheme(),

      // Modo de tema por defecto (sistema)
      themeMode: ThemeMode.system,

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

  /// Construye el tema claro de Material 3
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1), // Indigo
        brightness: Brightness.light,
      ),

      // Configuración de AppBar
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),

      // Configuración de Cards
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Configuración de botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Configuración de inputs
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
    );
  }

  /// Construye el tema oscuro de Material 3
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1), // Indigo
        brightness: Brightness.dark,
      ),

      // Configuración de AppBar
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),

      // Configuración de Cards
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Configuración de botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Configuración de inputs
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
    );
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
      backgroundColor: colorScheme.background,
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
                    color: colorScheme.onBackground.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
