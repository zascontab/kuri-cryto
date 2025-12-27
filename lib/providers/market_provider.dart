import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/market_service.dart';
import '../models/market_type.dart';
import '../models/markets_response.dart';
import '../models/market_features.dart';
import 'services_provider.dart';

part 'market_provider.g.dart';

/// Provider for Market Service
@riverpod
MarketService marketService(MarketServiceRef ref) {
  final dio = ref.watch(dioProvider);
  return MarketService(dio);
}

/// Provider for available market types
@riverpod
Future<List<MarketType>> availableMarketTypes(
  AvailableMarketTypesRef ref,
) async {
  final service = ref.watch(marketServiceProvider);
  return await service.getAvailableMarketTypes();
}

/// Provider for available pairs by market type
@riverpod
Future<List<String>> availablePairs(
  AvailablePairsRef ref, {
  required MarketType marketType,
  required String exchange,
}) async {
  final service = ref.watch(marketServiceProvider);
  return await service.getAvailablePairs(
    marketType: marketType,
    exchange: exchange,
  );
}

/// Provider for market features
@riverpod
Future<MarketFeatures> marketFeatures(
  MarketFeaturesRef ref, {
  required MarketType marketType,
  required String exchange,
}) async {
  final service = ref.watch(marketServiceProvider);
  return await service.getMarketFeatures(
    marketType: marketType,
    exchange: exchange,
  );
}

// ============================================================================
// Enhanced Markets Providers (v2.0)
// ============================================================================

/// Provider for enhanced markets endpoint
///
/// Gets trading pairs with optional filtering by market type.
/// Returns rich information including features, counts, and metadata.
///
/// Example:
/// ```dart
/// // Get all pairs
/// final allMarkets = ref.watch(marketsProvider(exchange: 'kucoin'));
///
/// // Get only futures pairs
/// final futuresMarkets = ref.watch(
///   marketsProvider(exchange: 'kucoin', marketType: 'futures'),
/// );
/// ```
@riverpod
Future<MarketsResponse> markets(
  MarketsRef ref, {
  required String exchange,
  String? marketType,
}) async {
  final service = ref.watch(marketServiceProvider);
  return await service.getMarkets(
    exchange: exchange,
    marketType: marketType,
  );
}

/// Provider for all markets (no filtering)
///
/// Convenience provider to get all pairs from all market types.
///
/// Example:
/// ```dart
/// final allMarkets = ref.watch(allMarketsProvider(exchange: 'kucoin'));
/// print('Total pairs: ${allMarkets.value?.totalCount}');
/// ```
@riverpod
Future<MarketsResponse> allMarkets(
  AllMarketsRef ref, {
  required String exchange,
}) async {
  final service = ref.watch(marketServiceProvider);
  return await service.getAllMarkets(exchange: exchange);
}
