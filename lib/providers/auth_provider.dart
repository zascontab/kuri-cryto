import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';

/// Provider del servicio de autenticación
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider del usuario actual de Google
final currentUserProvider = StateProvider<GoogleSignInAccount?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser;
});

/// Provider que indica si el usuario está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

/// Provider de información del usuario
final userInfoProvider = Provider<Map<String, dynamic>?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.getUserInfo();
});

/// Clase para manejar acciones de autenticación
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier(this._authService, this._ref) : super(const AsyncValue.data(null));

  final AuthService _authService;
  final Ref _ref;

  /// Inicia sesión con Google
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _authService.signInWithGoogle();
      if (result == null) {
        throw Exception('Login cancelado por el usuario');
      }
      // Actualizar el provider del usuario actual
      _ref.read(currentUserProvider.notifier).state = result;
    });
  }

  /// Cierra sesión
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.signOut();
      // Limpiar el provider del usuario actual
      _ref.read(currentUserProvider.notifier).state = null;
    });
  }

  /// Desconecta la cuenta de Google completamente
  Future<void> disconnect() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.disconnect();
      // Limpiar el provider del usuario actual
      _ref.read(currentUserProvider.notifier).state = null;
    });
  }
}

/// Provider del notifier de autenticación
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService, ref);
});
