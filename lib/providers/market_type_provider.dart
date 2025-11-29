import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/market_type.dart';
import '../services/market_type_service.dart';
import 'package:dio/dio.dart';

/// Provides a singleton instance of [MarketTypeService].
///
/// This provider creates and manages the [MarketTypeService] instance
/// with a configured Dio client for making API calls.
///
/// Example usage:
/// ```dart
/// final service = ref.read(marketTypeServiceProvider);
/// final marketTypes = await service.getMarketTypes();
/// ```
final marketTypeServiceProvider = Provider<MarketTypeService>((ref) {
  final dio = Dio();
  return MarketTypeService(dio);
});

/// Provides the currently selected market type across the application.
///
/// This is the primary state provider for market type selection. It maintains
/// a single source of truth for which market type is currently active.
///
/// The default market type is [MarketType.futures].
///
/// Example usage:
/// ```dart
/// // Read the current market type
/// final marketType = ref.watch(selectedMarketTypeProvider);
///
/// // Change the market type
/// ref.read(selectedMarketTypeProvider.notifier).setMarketType(MarketType.spot);
///
/// // Reset to default
/// ref.read(selectedMarketTypeProvider.notifier).reset();
/// ```
///
/// See also:
/// - [SelectedMarketTypeNotifier] for the state management logic
/// - [leverageProvider] which depends on this provider
final selectedMarketTypeProvider =
    StateNotifierProvider<SelectedMarketTypeNotifier, MarketType>((ref) {
  return SelectedMarketTypeNotifier();
});

/// State notifier for managing the selected market type.
///
/// This notifier handles market type selection state and provides methods
/// to update or reset the selection. The default market type is [MarketType.futures].
///
/// Example usage:
/// ```dart
/// final notifier = ref.read(selectedMarketTypeProvider.notifier);
///
/// // Change market type
/// notifier.setMarketType(MarketType.margin);
///
/// // Reset to default (Futures)
/// notifier.reset();
/// ```
class SelectedMarketTypeNotifier extends StateNotifier<MarketType> {
  /// Creates a [SelectedMarketTypeNotifier] with [MarketType.futures] as default.
  SelectedMarketTypeNotifier() : super(MarketType.futures);

  /// Updates the selected market type to [type].
  ///
  /// This will notify all listeners of the state change, triggering
  /// rebuilds in widgets that watch this provider.
  void setMarketType(MarketType type) {
    state = type;
  }

  /// Resets the selected market type to the default ([MarketType.futures]).
  void reset() {
    state = MarketType.futures;
  }
}

/// Provides the current leverage value with automatic validation.
///
/// This provider manages leverage state and automatically validates values
/// against the currently selected market type's limits. It watches
/// [selectedMarketTypeProvider] to ensure leverage stays within valid ranges.
///
/// The default leverage is 1.0x.
///
/// Example usage:
/// ```dart
/// // Read current leverage
/// final leverage = ref.watch(leverageProvider);
///
/// // Set leverage (automatically validated)
/// ref.read(leverageProvider.notifier).setLeverage(50.0);
///
/// // Get max leverage for current market type
/// final maxLeverage = ref.read(leverageProvider.notifier).maxLeverage;
///
/// // Reset to 1x
/// ref.read(leverageProvider.notifier).reset();
/// ```
///
/// See also:
/// - [LeverageNotifier] for the state management logic
/// - [selectedMarketTypeProvider] which this provider depends on
final leverageProvider = StateNotifierProvider<LeverageNotifier, double>((ref) {
  final marketType = ref.watch(selectedMarketTypeProvider);
  return LeverageNotifier(marketType);
});

/// State notifier for managing leverage values with validation.
///
/// This notifier handles leverage state and ensures all values are valid
/// for the associated market type. Invalid leverage values are rejected.
///
/// Example usage:
/// ```dart
/// final notifier = ref.read(leverageProvider.notifier);
///
/// // Set valid leverage
/// notifier.setLeverage(10.0); // Accepted if valid for market type
///
/// // Attempt invalid leverage
/// notifier.setLeverage(150.0); // Rejected if exceeds max for market type
///
/// // Check limits
/// print('Max: ${notifier.maxLeverage}');
/// print('Min: ${notifier.minLeverage}');
/// ```
class LeverageNotifier extends StateNotifier<double> {
  /// The market type this notifier is associated with.
  final MarketType marketType;

  /// Creates a [LeverageNotifier] for the given [marketType].
  ///
  /// The initial leverage is set to 1.0x.
  LeverageNotifier(this.marketType) : super(1.0);

  /// Sets the leverage to [value] if it's valid for the current market type.
  ///
  /// The value is validated using [MarketType.isValidLeverage]. If invalid,
  /// the state is not updated and the current leverage remains unchanged.
  ///
  /// Example:
  /// ```dart
  /// notifier.setLeverage(50.0); // Valid for Futures
  /// notifier.setLeverage(5.0);  // Valid for Margin
  /// notifier.setLeverage(1.0);  // Valid for all types
  /// ```
  void setLeverage(double value) {
    if (marketType.isValidLeverage(value)) {
      state = value;
    }
  }

  /// Resets the leverage to 1.0x.
  void reset() {
    state = 1.0;
  }

  /// The maximum leverage allowed for the current market type.
  ///
  /// Returns the [MarketType.maxLeverage] value as a double.
  double get maxLeverage => marketType.maxLeverage.toDouble();

  /// The minimum leverage allowed for the current market type.
  ///
  /// Returns the [MarketType.minLeverage] value as a double (always 1.0).
  double get minLeverage => marketType.minLeverage.toDouble();
}

/// Provides a list of available market types from the backend API.
///
/// This is a [FutureProvider] that fetches market type information from
/// the server. The data includes available market types and their configurations.
///
/// Example usage:
/// ```dart
/// final marketTypesAsync = ref.watch(marketTypesProvider);
///
/// marketTypesAsync.when(
///   data: (types) => Text('Loaded ${types.length} market types'),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
final marketTypesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(marketTypeServiceProvider);
  return service.getMarketTypes();
});

/// Provides trading pairs filtered by market type and exchange.
///
/// This is a family provider that fetches trading pairs for a specific
/// exchange and market type combination. Use [MarketTypePairsParams] to
/// specify the parameters.
///
/// Example usage:
/// ```dart
/// final params = MarketTypePairsParams(
///   exchange: 'binance',
///   marketType: 'futures',
/// );
///
/// final pairsAsync = ref.watch(pairsByTypeProvider(params));
///
/// pairsAsync.when(
///   data: (pairs) => ListView(
///     children: pairs.entries.map((e) => Text(e.key)).toList(),
///   ),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
final pairsByTypeProvider =
    FutureProvider.family<Map<String, dynamic>, MarketTypePairsParams>(
  (ref, params) async {
    final service = ref.watch(marketTypeServiceProvider);
    return service.getPairsByType(
      exchange: params.exchange,
      marketType: params.marketType,
    );
  },
);

/// Parameters for market type and exchange specific providers.
///
/// This class encapsulates the exchange and market type parameters needed
/// for family providers like [pairsByTypeProvider] and [marketTypeFeaturesProvider].
///
/// Implements equality and hashCode for proper provider caching.
///
/// Example usage:
/// ```dart
/// final params = MarketTypePairsParams(
///   exchange: 'binance',
///   marketType: 'spot',
/// );
///
/// final pairs = ref.watch(pairsByTypeProvider(params));
/// ```
class MarketTypePairsParams {
  /// The exchange identifier (e.g., 'binance', 'bybit').
  final String exchange;

  /// The market type value (e.g., 'spot', 'futures', 'margin', 'options').
  final String marketType;

  /// Creates [MarketTypePairsParams] with the given [exchange] and [marketType].
  const MarketTypePairsParams({
    required this.exchange,
    required this.marketType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketTypePairsParams &&
          runtimeType == other.runtimeType &&
          exchange == other.exchange &&
          marketType == other.marketType;

  @override
  int get hashCode => exchange.hashCode ^ marketType.hashCode;
}

/// Provides market type features and capabilities for a specific exchange.
///
/// This family provider fetches detailed feature information for a market type
/// on a specific exchange, including leverage limits, funding rate availability,
/// and other capabilities.
///
/// Example usage:
/// ```dart
/// final params = MarketTypePairsParams(
///   exchange: 'binance',
///   marketType: 'futures',
/// );
///
/// final featuresAsync = ref.watch(marketTypeFeaturesProvider(params));
///
/// featuresAsync.when(
///   data: (features) => Column(
///     children: [
///       Text('Max Leverage: ${features.leverageMax}x'),
///       if (features.hasFundingRate) Text('Has Funding Rate'),
///     ],
///   ),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
final marketTypeFeaturesProvider =
    FutureProvider.family<MarketTypeFeatures, MarketTypePairsParams>(
  (ref, params) async {
    final service = ref.watch(marketTypeServiceProvider);
    return service.getMarketTypeFeatures(
      exchange: params.exchange,
      marketType: params.marketType,
    );
  },
);
