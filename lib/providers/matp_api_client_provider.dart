import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/matp_api_client.dart';
import 'enhanced_error_handling_provider.dart';

/// Provider for MATP API Client with enhanced error handling
///
/// Provides a configured MATPApiClient instance for dependency injection
final matpApiClientProvider = Provider<MATPApiClient>((ref) {
  // Watch error handling services to ensure they're initialized
  ref.watch(retryServiceProvider);
  ref.watch(rateLimitServiceProvider);

  return MATPApiClient(environment: 'development');
});

/// Provider for MATP API Client state
///
/// Tracks authentication state and user level
final matpApiClientStateProvider =
    StateNotifierProvider<MATPApiClientStateNotifier, MATPApiClientState>(
        (ref) {
  final client = ref.watch(matpApiClientProvider);
  return MATPApiClientStateNotifier(client);
});

/// State for MATP API Client
class MATPApiClientState {
  final bool isAuthenticated;
  final int userLevel;
  final String? jwtToken;
  final DateTime? tokenExpiry;
  final bool isTokenExpired;

  const MATPApiClientState({
    this.isAuthenticated = false,
    this.userLevel = 1,
    this.jwtToken,
    this.tokenExpiry,
    this.isTokenExpired = false,
  });

  MATPApiClientState copyWith({
    bool? isAuthenticated,
    int? userLevel,
    String? jwtToken,
    DateTime? tokenExpiry,
    bool? isTokenExpired,
  }) {
    return MATPApiClientState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userLevel: userLevel ?? this.userLevel,
      jwtToken: jwtToken ?? this.jwtToken,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      isTokenExpired: isTokenExpired ?? this.isTokenExpired,
    );
  }
}

/// State notifier for MATP API Client
class MATPApiClientStateNotifier extends StateNotifier<MATPApiClientState> {
  final MATPApiClient _client;

  MATPApiClientStateNotifier(this._client) : super(const MATPApiClientState());

  /// Set JWT token and update state
  void setJWTToken(String token, {String? refreshToken, DateTime? expiry}) {
    _client.setJWTToken(token, refreshToken: refreshToken, expiry: expiry);

    state = state.copyWith(
      isAuthenticated: true,
      jwtToken: token,
      tokenExpiry: expiry,
      isTokenExpired: false,
    );
  }

  /// Clear JWT token and update state
  void clearJWTToken() {
    _client.clearJWTToken();

    state = state.copyWith(
      isAuthenticated: false,
      jwtToken: null,
      tokenExpiry: null,
      isTokenExpired: false,
    );
  }

  /// Set user level and update state
  void setUserLevel(int level) {
    _client.setUserLevel(level);

    state = state.copyWith(userLevel: level);
  }

  /// Check if token is expired and update state
  void checkTokenExpiry() {
    final isExpired = _client.isTokenExpired;

    if (isExpired && state.isAuthenticated) {
      state = state.copyWith(isTokenExpired: true);
    }
  }

  /// Check if user has required access level
  bool hasAccessLevel(int requiredLevel) {
    return _client.hasAccessLevel(requiredLevel);
  }

  /// Get rate limit status for debugging
  Map<String, dynamic> getRateLimitStatus() {
    return _client.getRateLimitStatus();
  }

  /// Clear error handling state (useful for testing)
  void clearState() {
    _client.clearState();
  }
}
