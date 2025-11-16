// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'services_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dioHash() => r'afb4bedcef88943128885adf2238001c47b7d2b5';

/// Provider for Dio HTTP client
///
/// Configured with:
/// - Base URL
/// - Connect timeout: 10s
/// - Receive timeout: 30s
/// - JSON content type
/// - Logging interceptor (debug mode)
///
/// Copied from [dio].
@ProviderFor(dio)
final dioProvider = AutoDisposeProvider<Dio>.internal(
  dio,
  name: r'dioProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DioRef = AutoDisposeProviderRef<Dio>;
String _$apiClientHash() => r'830b3339c24d952121db45e5d7278545d0d2fbfd';

/// Provider for API client
///
/// Creates ApiClient with custom error handling and retry logic
///
/// Copied from [apiClient].
@ProviderFor(apiClient)
final apiClientProvider = AutoDisposeProvider<ApiClient>.internal(
  apiClient,
  name: r'apiClientProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$apiClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ApiClientRef = AutoDisposeProviderRef<ApiClient>;
String _$scalpingServiceHash() => r'cbaa2c2e23b62007b8542a6ae3c0da33f34d880d';

/// Provider for Scalping Service
///
/// Handles all scalping-related API calls:
/// - System control (start/stop)
/// - Status and metrics
/// - Health check
///
/// Copied from [scalpingService].
@ProviderFor(scalpingService)
final scalpingServiceProvider = AutoDisposeProvider<ScalpingService>.internal(
  scalpingService,
  name: r'scalpingServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scalpingServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ScalpingServiceRef = AutoDisposeProviderRef<ScalpingService>;
String _$positionServiceHash() => r'de0a96f6af5941f610db50f9780fe8fd64c01017';

/// Provider for Position Service
///
/// Manages position-related operations:
/// - Get open positions
/// - Get position history
/// - Close positions
/// - Update SL/TP
/// - Move to breakeven
/// - Enable trailing stop
///
/// Copied from [positionService].
@ProviderFor(positionService)
final positionServiceProvider = AutoDisposeProvider<PositionService>.internal(
  positionService,
  name: r'positionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$positionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PositionServiceRef = AutoDisposeProviderRef<PositionService>;
String _$strategyServiceHash() => r'e159e20ce7b935299226b7484f2478397e849d8b';

/// Provider for Strategy Service
///
/// Handles strategy configuration and control:
/// - List strategies
/// - Start/Stop strategies
/// - Update strategy config
/// - Get strategy performance
///
/// Copied from [strategyService].
@ProviderFor(strategyService)
final strategyServiceProvider = AutoDisposeProvider<StrategyService>.internal(
  strategyService,
  name: r'strategyServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$strategyServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StrategyServiceRef = AutoDisposeProviderRef<StrategyService>;
String _$riskServiceHash() => r'c742d500fe00a8bd4056b801462e220d28e16714';

/// Provider for Risk Service
///
/// Manages risk parameters and monitoring:
/// - Get/Update risk limits
/// - Get exposure
/// - Risk Sentinel state
/// - Kill switch activation/deactivation
///
/// Copied from [riskService].
@ProviderFor(riskService)
final riskServiceProvider = AutoDisposeProvider<RiskService>.internal(
  riskService,
  name: r'riskServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$riskServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RiskServiceRef = AutoDisposeProviderRef<RiskService>;
String _$websocketServiceHash() => r'c60c8cde9e9bfa1bc1926c24980b96cf7eebc04f';

/// Provider for WebSocket Service
///
/// Manages WebSocket connection for real-time updates:
/// - Position updates
/// - Metrics updates
/// - Alerts
/// - Kill switch events
///
/// Auto-reconnection with exponential backoff
///
/// Copied from [websocketService].
@ProviderFor(websocketService)
final websocketServiceProvider = AutoDisposeProvider<WebSocketService>.internal(
  websocketService,
  name: r'websocketServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$websocketServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WebsocketServiceRef = AutoDisposeProviderRef<WebSocketService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
