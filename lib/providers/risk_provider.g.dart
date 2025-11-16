// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'risk_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$riskStateHash() => r'5799f4443e5aef461e1b150c7667091150bc24cf';

/// Provider for real-time risk state via WebSocket
///
/// Provides live Risk Sentinel state including:
/// - Drawdown (daily, weekly, monthly)
/// - Total exposure and by symbol
/// - Consecutive losses count
/// - Risk mode (Conservative/Normal/Aggressive)
/// - Kill switch status
///
/// For now, fetches from REST API.
/// TODO: Switch to WebSocket stream when available
///
/// Copied from [riskState].
@ProviderFor(riskState)
final riskStateProvider = AutoDisposeFutureProvider<RiskState>.internal(
  riskState,
  name: r'riskStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$riskStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RiskStateRef = AutoDisposeFutureProviderRef<RiskState>;
String _$killSwitchActiveHash() => r'c87ed8a96e0cebc01b514e1bfaa8b7a49b9beb9e';

/// Provider for kill switch status
///
/// Derived from risk state stream.
/// Returns true if kill switch is active, false otherwise.
///
/// Copied from [killSwitchActive].
@ProviderFor(killSwitchActive)
final killSwitchActiveProvider = AutoDisposeProvider<bool>.internal(
  killSwitchActive,
  name: r'killSwitchActiveProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$killSwitchActiveHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef KillSwitchActiveRef = AutoDisposeProviderRef<bool>;
String _$riskModeHash() => r'd15caf268660b183f560a74e7e83655fe6006ea1';

/// Provider for current risk mode
///
/// Derived from risk state stream.
/// Returns current risk mode: Conservative, Normal, or Aggressive.
///
/// Copied from [riskMode].
@ProviderFor(riskMode)
final riskModeProvider = AutoDisposeProvider<String>.internal(
  riskMode,
  name: r'riskModeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$riskModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RiskModeRef = AutoDisposeProviderRef<String>;
String _$riskLimitsHash() => r'e07bbef71b5d78049339d7c770ab5fe4e1df8e55';

/// Provider for risk limits configuration
///
/// Fetches current risk limits:
/// - Max position size
/// - Max total exposure
/// - Stop loss %
/// - Take profit %
/// - Max daily loss
/// - Max consecutive losses
///
/// Can be refreshed manually or invalidated after updates.
///
/// Copied from [RiskLimits].
@ProviderFor(RiskLimits)
final riskLimitsProvider =
    AutoDisposeAsyncNotifierProvider<RiskLimits, RiskLimitsModel>.internal(
  RiskLimits.new,
  name: r'riskLimitsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$riskLimitsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RiskLimits = AutoDisposeAsyncNotifier<RiskLimitsModel>;
String _$exposureHash() => r'972f6c44da1a394fa4f64eb794784c6d332ce416';

/// Provider for current exposure
///
/// Fetches current exposure metrics:
/// - Current total exposure
/// - Max exposure limit
/// - Available exposure
/// - Exposure percentage
/// - Exposure by symbol
///
/// Refreshed periodically or on-demand.
///
/// Copied from [Exposure].
@ProviderFor(Exposure)
final exposureProvider =
    AutoDisposeAsyncNotifierProvider<Exposure, ExposureInfo>.internal(
  Exposure.new,
  name: r'exposureProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$exposureHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Exposure = AutoDisposeAsyncNotifier<ExposureInfo>;
String _$killSwitchActivatorHash() =>
    r'94bc04df1b34344591d631e5d2606799411a22e9';

/// Provider for activating kill switch
///
/// Emergency stop mechanism that:
/// 1. Stops all trading immediately
/// 2. Closes all open positions
/// 3. Prevents new trades until deactivated
///
/// CRITICAL SAFETY FEATURE
///
/// Copied from [KillSwitchActivator].
@ProviderFor(KillSwitchActivator)
final killSwitchActivatorProvider =
    AutoDisposeAsyncNotifierProvider<KillSwitchActivator, void>.internal(
  KillSwitchActivator.new,
  name: r'killSwitchActivatorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$killSwitchActivatorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$KillSwitchActivator = AutoDisposeAsyncNotifier<void>;
String _$killSwitchDeactivatorHash() =>
    r'2cb08675f1d2aae28f1c57b25da0ee8aba0c70fe';

/// Provider for deactivating kill switch
///
/// Deactivates the kill switch to resume normal trading operations.
/// Should only be used after resolving the issue that triggered the kill switch.
///
/// Copied from [KillSwitchDeactivator].
@ProviderFor(KillSwitchDeactivator)
final killSwitchDeactivatorProvider =
    AutoDisposeAsyncNotifierProvider<KillSwitchDeactivator, void>.internal(
  KillSwitchDeactivator.new,
  name: r'killSwitchDeactivatorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$killSwitchDeactivatorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$KillSwitchDeactivator = AutoDisposeAsyncNotifier<void>;
String _$riskLimitsUpdaterHash() => r'74fa76fb46f92a32068d0f772d078084c170ccd9';

/// Provider for updating risk limits
///
/// Updates risk management parameters.
/// All parameters are optional - only provided ones will be updated.
///
/// Copied from [RiskLimitsUpdater].
@ProviderFor(RiskLimitsUpdater)
final riskLimitsUpdaterProvider =
    AutoDisposeAsyncNotifierProvider<RiskLimitsUpdater, void>.internal(
  RiskLimitsUpdater.new,
  name: r'riskLimitsUpdaterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$riskLimitsUpdaterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RiskLimitsUpdater = AutoDisposeAsyncNotifier<void>;
String _$drawdownStatusHash() => r'43a851cdccfa09defc4d0dacfc25f8349d65871e';

/// Provider for drawdown status
///
/// Provides current drawdown levels and warnings.
///
/// Copied from [DrawdownStatus].
@ProviderFor(DrawdownStatus)
final drawdownStatusProvider =
    AutoDisposeNotifierProvider<DrawdownStatus, DrawdownInfo>.internal(
  DrawdownStatus.new,
  name: r'drawdownStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$drawdownStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DrawdownStatus = AutoDisposeNotifier<DrawdownInfo>;
String _$consecutiveLossesStatusHash() =>
    r'b56e8f956e17de443c1005434971e37ee99e25a7';

/// Provider for consecutive losses status
///
/// Monitors consecutive losses and warns when approaching limit.
///
/// Copied from [ConsecutiveLossesStatus].
@ProviderFor(ConsecutiveLossesStatus)
final consecutiveLossesStatusProvider = AutoDisposeNotifierProvider<
    ConsecutiveLossesStatus, ConsecutiveLossesInfo>.internal(
  ConsecutiveLossesStatus.new,
  name: r'consecutiveLossesStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$consecutiveLossesStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ConsecutiveLossesStatus = AutoDisposeNotifier<ConsecutiveLossesInfo>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
