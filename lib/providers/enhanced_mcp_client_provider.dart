import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/enhanced_mcp_client.dart';
import 'enhanced_error_handling_provider.dart';

/// Provider for Enhanced MCP Client with enhanced error handling
///
/// Provides a configured EnhancedMCPClient instance for dependency injection
final enhancedMcpClientProvider = Provider<EnhancedMCPClient>((ref) {
  // Watch error handling services to ensure they're initialized
  ref.watch(retryServiceProvider);
  ref.watch(rateLimitServiceProvider);
  ref.watch(fallbackServiceProvider);

  return EnhancedMCPClient();
});

/// Provider for MCP Client state
///
/// Tracks connection status and request statistics
final mcpClientStateProvider =
    StateNotifierProvider<MCPClientStateNotifier, MCPClientState>((ref) {
  final client = ref.watch(enhancedMcpClientProvider);
  return MCPClientStateNotifier(client);
});

/// State for MCP Client
class MCPClientState {
  final bool isConnected;
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final DateTime? lastRequestTime;
  final String? lastError;

  const MCPClientState({
    this.isConnected = true,
    this.totalRequests = 0,
    this.successfulRequests = 0,
    this.failedRequests = 0,
    this.lastRequestTime,
    this.lastError,
  });

  MCPClientState copyWith({
    bool? isConnected,
    int? totalRequests,
    int? successfulRequests,
    int? failedRequests,
    DateTime? lastRequestTime,
    String? lastError,
  }) {
    return MCPClientState(
      isConnected: isConnected ?? this.isConnected,
      totalRequests: totalRequests ?? this.totalRequests,
      successfulRequests: successfulRequests ?? this.successfulRequests,
      failedRequests: failedRequests ?? this.failedRequests,
      lastRequestTime: lastRequestTime ?? this.lastRequestTime,
      lastError: lastError ?? this.lastError,
    );
  }

  /// Get success rate as percentage
  double get successRate {
    if (totalRequests == 0) return 0.0;
    return (successfulRequests / totalRequests) * 100;
  }

  /// Check if client is healthy (success rate > 80%)
  bool get isHealthy => successRate >= 80.0;
}

/// State notifier for MCP Client
class MCPClientStateNotifier extends StateNotifier<MCPClientState> {
  final EnhancedMCPClient _client;

  MCPClientStateNotifier(this._client) : super(const MCPClientState());

  /// Record a successful request
  void recordSuccess() {
    state = state.copyWith(
      totalRequests: state.totalRequests + 1,
      successfulRequests: state.successfulRequests + 1,
      lastRequestTime: DateTime.now(),
      isConnected: true,
      lastError: null,
    );
  }

  /// Record a failed request
  void recordFailure(String error) {
    state = state.copyWith(
      totalRequests: state.totalRequests + 1,
      failedRequests: state.failedRequests + 1,
      lastRequestTime: DateTime.now(),
      lastError: error,
    );

    // Mark as disconnected if too many failures
    if (state.successRate < 50.0 && state.totalRequests >= 5) {
      state = state.copyWith(isConnected: false);
    }
  }

  /// Reset statistics
  void resetStats() {
    state = const MCPClientState();
  }

  /// Test connection to MCP server
  Future<bool> testConnection() async {
    try {
      // Try to call a simple tool to test connectivity
      await _client.callTool(
        toolName: 'get_markets',
        arguments: {'exchange': 'kucoin'},
      );

      recordSuccess();
      return true;
    } catch (e) {
      recordFailure(e.toString());
      return false;
    }
  }

  /// Get fallback service status
  Map<String, dynamic> getFallbackStatus() {
    return _client.getFallbackStatus();
  }

  /// Get rate limit status for debugging
  Map<String, dynamic> getRateLimitStatus() {
    return _client.getRateLimitStatus();
  }

  /// Clear error handling state (useful for testing)
  void clearState() {
    _client.clearState();
  }

  /// Reset request ID counter (useful for testing)
  void resetRequestId() {
    _client.resetRequestId();
  }
}
