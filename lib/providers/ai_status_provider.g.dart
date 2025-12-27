// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiServiceHash() => r'6766ca3fa3d2a62cec219987be377e9afdbaac0a';

/// Provider for AI Service
///
/// Copied from [aiService].
@ProviderFor(aiService)
final aiServiceProvider = AutoDisposeProvider<AIService>.internal(
  aiService,
  name: r'aiServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$aiServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AiServiceRef = AutoDisposeProviderRef<AIService>;
String _$aIStatusNotifierHash() => r'39758597270e849cf32923bc938baeb87f1f0b0a';

/// Provider for AI Status with auto-refresh every 30 seconds
///
/// Fetches current AI system status including:
/// - LLM status (provider, model, calls, limits)
/// - Sentiment analysis status
/// - Cost management (budget, spent, remaining)
///
/// Auto-refreshes every 30 seconds while provider is alive
///
/// Copied from [AIStatusNotifier].
@ProviderFor(AIStatusNotifier)
final aIStatusNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AIStatusNotifier, AIStatus>.internal(
  AIStatusNotifier.new,
  name: r'aIStatusNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aIStatusNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AIStatusNotifier = AutoDisposeAsyncNotifier<AIStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
