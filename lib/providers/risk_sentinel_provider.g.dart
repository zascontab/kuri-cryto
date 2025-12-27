// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'risk_sentinel_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$killSwitchStatusHash() => r'8bb859394cff6b0088d19ea1c5c2559917230838';

/// Convenience provider for kill switch status only
///
/// Copied from [killSwitchStatus].
@ProviderFor(killSwitchStatus)
final killSwitchStatusProvider = AutoDisposeProvider<bool>.internal(
  killSwitchStatus,
  name: r'killSwitchStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$killSwitchStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef KillSwitchStatusRef = AutoDisposeProviderRef<bool>;
String _$tradingAllowedHash() => r'87bb15ec7991221ee3dd72ec171ec57791d2d18a';

/// Convenience provider for trading allowed status
///
/// Copied from [tradingAllowed].
@ProviderFor(tradingAllowed)
final tradingAllowedProvider = AutoDisposeProvider<bool>.internal(
  tradingAllowed,
  name: r'tradingAllowedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tradingAllowedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TradingAllowedRef = AutoDisposeProviderRef<bool>;
String _$riskSentinelHash() => r'83cc33805dd40ca9e75b5be86e849115c99acb68';

/// Provider for Risk Sentinel state with real-time WebSocket updates
///
/// This provider combines:
/// - Initial state from REST API
/// - Real-time updates via WebSocket kill_switch events
/// - Auto-refresh every 5 seconds as fallback
///
/// Features:
/// - Automatic WebSocket subscription on build
/// - Real-time kill switch event handling
/// - Periodic state refresh
/// - Error handling and recovery
///
/// Copied from [RiskSentinel].
@ProviderFor(RiskSentinel)
final riskSentinelProvider =
    AutoDisposeAsyncNotifierProvider<RiskSentinel, RiskState>.internal(
  RiskSentinel.new,
  name: r'riskSentinelProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$riskSentinelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RiskSentinel = AutoDisposeAsyncNotifier<RiskState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
