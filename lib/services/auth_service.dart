import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Servicio de autenticación que maneja el login con Google OAuth
/// 
/// Esta implementación usa solo Google Sign-In sin Firebase,
/// guardando la información del usuario localmente de forma segura.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final Logger _logger = Logger();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Keys para almacenamiento seguro
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyUserPhoto = 'user_photo';

  GoogleSignInAccount? _currentUser;

  /// Usuario actual
  GoogleSignInAccount? get currentUser => _currentUser;

  /// Verifica si el usuario está autenticado
  bool get isAuthenticated => _currentUser != null;

  /// Inicializa el servicio y verifica si hay sesión guardada
  Future<void> initialize() async {
    try {
      // Intentar hacer sign in silencioso (si hay sesión previa)
      _currentUser = await _googleSignIn.signInSilently();
      
      if (_currentUser != null) {
        _logger.i('Sesión restaurada: ${_currentUser!.email}');
        await _saveUserInfo(_currentUser!);
      }
    } catch (e) {
      _logger.e('Error al inicializar auth', error: e);
    }
  }

  /// Inicia sesión con Google
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      _logger.i('Iniciando proceso de login con Google...');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _logger.w('Usuario canceló el login de Google');
        return null;
      }

      _logger.i('Usuario de Google obtenido: ${googleUser.email}');
      _currentUser = googleUser;

      // Guardar información del usuario
      await _saveUserInfo(googleUser);

      _logger.i('Login exitoso: ${googleUser.email}');
      return googleUser;
    } catch (e) {
      _logger.e('Error al iniciar sesión con Google', error: e);
      rethrow;
    }
  }

  /// Cierra sesión
  Future<void> signOut() async {
    try {
      _logger.i('Cerrando sesión...');

      // Sign out from Google
      await _googleSignIn.signOut();
      _currentUser = null;

      // Limpiar información guardada
      await _clearUserInfo();

      _logger.i('Sesión cerrada correctamente');
    } catch (e) {
      _logger.e('Error al cerrar sesión', error: e);
      rethrow;
    }
  }

  /// Desconectar completamente la cuenta de Google
  Future<void> disconnect() async {
    try {
      _logger.i('Desconectando cuenta...');

      await _googleSignIn.disconnect();
      _currentUser = null;
      await _clearUserInfo();

      _logger.i('Cuenta desconectada correctamente');
    } catch (e) {
      _logger.e('Error al desconectar cuenta', error: e);
      rethrow;
    }
  }

  /// Obtiene la información del usuario actual
  Map<String, dynamic>? getUserInfo() {
    if (_currentUser == null) return null;

    return {
      'id': _currentUser!.id,
      'email': _currentUser!.email,
      'displayName': _currentUser!.displayName ?? '',
      'photoUrl': _currentUser!.photoUrl ?? '',
    };
  }

  /// Guarda la información del usuario de forma segura
  Future<void> _saveUserInfo(GoogleSignInAccount user) async {
    await _storage.write(key: _keyUserId, value: user.id);
    await _storage.write(key: _keyUserEmail, value: user.email);
    await _storage.write(key: _keyUserName, value: user.displayName ?? '');
    await _storage.write(key: _keyUserPhoto, value: user.photoUrl ?? '');
  }

  /// Limpia la información del usuario guardada
  Future<void> _clearUserInfo() async {
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyUserEmail);
    await _storage.delete(key: _keyUserName);
    await _storage.delete(key: _keyUserPhoto);
  }

  /// Lee la información del usuario guardada
  Future<Map<String, String?>> getSavedUserInfo() async {
    return {
      'id': await _storage.read(key: _keyUserId),
      'email': await _storage.read(key: _keyUserEmail),
      'displayName': await _storage.read(key: _keyUserName),
      'photoUrl': await _storage.read(key: _keyUserPhoto),
    };
  }
}
