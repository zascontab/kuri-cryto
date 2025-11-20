// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_bot_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiBotServiceHash() => r'6a2aa91de7e08b68cb719febd331dc4783b13a77';

/// Provider for AI Bot Service
///
/// Copied from [aiBotService].
@ProviderFor(aiBotService)
final aiBotServiceProvider = AutoDisposeProvider<AiBotService>.internal(
  aiBotService,
  name: r'aiBotServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$aiBotServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AiBotServiceRef = AutoDisposeProviderRef<AiBotService>;
String _$aiBotStatusNotifierHash() =>
    r'8fb957cc012e7881a308bbd18d450f59fea7cad7';

/// Provider for AI Bot status with auto-refresh every 5 seconds
///
/// Fetches current AI Bot status including:
/// - Running state (running, paused, emergency stop)
/// - Uptime and analysis/execution counts
/// - Daily loss and trades
/// - Open positions
/// - Current configuration
///
/// Auto-refreshes every 5 seconds while provider is alive
///
/// Copied from [AiBotStatusNotifier].
@ProviderFor(AiBotStatusNotifier)
final aiBotStatusNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AiBotStatusNotifier, AiBotStatus>.internal(
  AiBotStatusNotifier.new,
  name: r'aiBotStatusNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aiBotStatusNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AiBotStatusNotifier = AutoDisposeAsyncNotifier<AiBotStatus>;
String _$aiBotConfigNotifierHash() =>
    r'9c4cb1b97ef2e86e6070ed74614a8cb209904f5e';

/// Provider for AI Bot Configuration
///
/// Manages bot configuration updates
///
/// Copied from [AiBotConfigNotifier].
@ProviderFor(AiBotConfigNotifier)
final aiBotConfigNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AiBotConfigNotifier, AiBotConfig>.internal(
  AiBotConfigNotifier.new,
  name: r'aiBotConfigNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aiBotConfigNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AiBotConfigNotifier = AutoDisposeAsyncNotifier<AiBotConfig>;
String _$aiBotPositionsHash() => r'3fb9c692942365005163c2bf74e0036110df57b8';

/// Provider for AI Bot Positions with auto-refresh every 5 seconds
///
/// Copied from [AiBotPositions].
@ProviderFor(AiBotPositions)
final aiBotPositionsProvider =
    AutoDisposeAsyncNotifierProvider<AiBotPositions, List<AiPosition>>.internal(
  AiBotPositions.new,
  name: r'aiBotPositionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aiBotPositionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AiBotPositions = AutoDisposeAsyncNotifier<List<AiPosition>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
