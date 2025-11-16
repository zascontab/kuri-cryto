// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$systemStatusHash() => r'a40559e023e55789735e3084cf0b89f370d1c7a2';

/// Provider for system status with auto-refresh every 5 seconds
///
/// Fetches current system status including:
/// - Running state
/// - Uptime
/// - Pairs count
/// - Active strategies
///
/// Auto-refreshes every 5 seconds while provider is alive
///
/// Copied from [SystemStatus].
@ProviderFor(SystemStatus)
final systemStatusProvider = AutoDisposeAsyncNotifierProvider<SystemStatus,
    models.SystemStatus>.internal(
  SystemStatus.new,
  name: r'systemStatusProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$systemStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SystemStatus = AutoDisposeAsyncNotifier<models.SystemStatus>;
String _$metricsHash() => r'4b3d02f715c2fee422b2d1b10f968ba8e253827b';

/// Provider for trading metrics with auto-refresh every 5 seconds
///
/// Provides real-time trading metrics:
/// - Total trades
/// - Win rate
/// - Total P&L
/// - Daily P&L
/// - Active positions
/// - Average latency
///
/// Auto-refreshes every 5 seconds
///
/// Copied from [Metrics].
@ProviderFor(Metrics)
final metricsProvider =
    AutoDisposeAsyncNotifierProvider<Metrics, models.Metrics>.internal(
  Metrics.new,
  name: r'metricsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$metricsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Metrics = AutoDisposeAsyncNotifier<models.Metrics>;
String _$healthHash() => r'298a18be5cdaddc55a217dfcce898c7ce0dba1b4';

/// Provider for health status with auto-refresh every 10 seconds
///
/// Monitors system health
///
/// Auto-refreshes every 10 seconds
///
/// Copied from [Health].
@ProviderFor(Health)
final healthProvider =
    AutoDisposeAsyncNotifierProvider<Health, models.HealthStatus>.internal(
  Health.new,
  name: r'healthProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$healthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Health = AutoDisposeAsyncNotifier<models.HealthStatus>;
String _$autoRefreshEnabledHash() =>
    r'da9b828861197b8f880f5ef382d6218dd9ad3b06';

/// Provider for pause/resume state of auto-refresh
///
/// Allows UI to pause auto-refresh when app is in background
/// to save battery and bandwidth
///
/// Copied from [AutoRefreshEnabled].
@ProviderFor(AutoRefreshEnabled)
final autoRefreshEnabledProvider =
    AutoDisposeNotifierProvider<AutoRefreshEnabled, bool>.internal(
  AutoRefreshEnabled.new,
  name: r'autoRefreshEnabledProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$autoRefreshEnabledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AutoRefreshEnabled = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
