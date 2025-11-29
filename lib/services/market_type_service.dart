import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/market_type.dart';
import 'api_exception.dart';

/// Service for managing market type operations and API interactions.
///
/// This service provides methods to:
/// - Fetch available market types from the backend
/// - Get trading pairs filtered by market type
/// - Retrieve market type features and capabilities
/// - Validate leverage values for specific market types
///
/// All API calls use JSON-RPC 2.0 protocol through the MCP tools endpoint.
///
/// Example usage:
/// ```dart
/// final dio = Dio();
/// final service = MarketTypeService(dio);
///
/// // Get all market types
/// final types = await service.getMarketTypes();
///
/// // Get futures pairs for Binance
/// final pairs = await service.getPairsByType(
///   exchange: 'binance',
///   marketType: 'futures',
/// );
///
/// // Validate leverage
/// final isValid = service.validateLeverage(MarketType.futures, 50.0);
/// ```
///
/// See also:
/// - [MarketType] for the market type enum
/// - [MarketTypeFeatures] for feature data model
class MarketTypeService {
  /// The Dio HTTP client used for API requests.
  final Dio _dio;

  /// Creates a [MarketTypeService] with the given [Dio] client.
  ///
  /// The Dio client should be configured with appropriate timeouts,
  /// interceptors, and base options before being passed to this service.
  MarketTypeService(this._dio);

  /// Fetches the list of available market types from the backend.
  ///
  /// Makes a JSON-RPC call to the `get_market_types` tool to retrieve
  /// all supported market types with their descriptions and capabilities.
  ///
  /// Returns a map containing market type information. The structure
  /// depends on the backend API response.
  ///
  /// Throws [ApiException] if the API call fails or returns an error.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final types = await service.getMarketTypes();
  ///   print('Available types: ${types.keys}');
  /// } catch (e) {
  ///   print('Error fetching market types: $e');
  /// }
  /// ```
  Future<Map<String, dynamic>> getMarketTypes() async {
    try {
      final response = await _dio.post(
        ApiConfig.mcpToolsUrl,
        data: {
          'jsonrpc': '2.0',
          'method': 'tools/call',
          'params': {
            'name': 'get_market_types',
            'arguments': {},
          },
          'id': DateTime.now().millisecondsSinceEpoch,
        },
      );

      final result = response.data['result'] as Map<String, dynamic>;
      return result;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetches trading pairs filtered by market type for a specific exchange.
  ///
  /// Makes a JSON-RPC call to the `get_pairs_by_type` tool to retrieve
  /// all trading pairs available for the specified market type on the
  /// given exchange.
  ///
  /// Parameters:
  /// - [exchange]: The exchange identifier (e.g., 'binance', 'kucoin', 'bybit')
  /// - [marketType]: The market type value ('spot', 'futures', 'margin', 'options')
  ///
  /// Returns a map containing:
  /// - `pairs`: List of available trading pairs
  /// - `features`: Market type features and capabilities
  /// - Additional exchange-specific information
  ///
  /// Throws [ApiException] if the API call fails or returns an error.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final result = await service.getPairsByType(
  ///     exchange: 'binance',
  ///     marketType: 'futures',
  ///   );
  ///   final pairs = result['pairs'] as List;
  ///   print('Found ${pairs.length} futures pairs');
  /// } catch (e) {
  ///   print('Error: $e');
  /// }
  /// ```
  Future<Map<String, dynamic>> getPairsByType({
    required String exchange,
    required String marketType,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.mcpToolsUrl,
        data: {
          'jsonrpc': '2.0',
          'method': 'tools/call',
          'params': {
            'name': 'get_pairs_by_type',
            'arguments': {
              'exchange': exchange,
              'market_type': marketType,
            },
          },
          'id': DateTime.now().millisecondsSinceEpoch,
        },
      );

      final result = response.data['result'] as Map<String, dynamic>;
      return result;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Retrieves detailed features and capabilities for a specific market type.
  ///
  /// Fetches market type features from the backend, including:
  /// - Leverage availability and limits
  /// - Funding rate mechanism availability
  /// - Margin trading support
  /// - Options trading support
  ///
  /// This method calls [getPairsByType] internally and extracts the
  /// features information from the response.
  ///
  /// Parameters:
  /// - [exchange]: The exchange identifier (e.g., 'binance', 'kucoin')
  /// - [marketType]: The market type value ('spot', 'futures', 'margin', 'options')
  ///
  /// Returns a [MarketTypeFeatures] object with the capabilities.
  /// If features are not available in the response, returns a default
  /// [MarketTypeFeatures] with all features disabled.
  ///
  /// Throws [ApiException] if the API call fails.
  ///
  /// Example:
  /// ```dart
  /// final features = await service.getMarketTypeFeatures(
  ///   exchange: 'binance',
  ///   marketType: 'futures',
  /// );
  ///
  /// if (features.hasLeverage) {
  ///   print('Leverage: ${features.leverageMin}x - ${features.leverageMax}x');
  /// }
  /// if (features.hasFundingRate) {
  ///   print('Funding rate is available');
  /// }
  /// ```
  Future<MarketTypeFeatures> getMarketTypeFeatures({
    required String exchange,
    required String marketType,
  }) async {
    final result = await getPairsByType(
      exchange: exchange,
      marketType: marketType,
    );

    final features = result['features'] as Map<String, dynamic>?;
    if (features == null) {
      return const MarketTypeFeatures(
        hasLeverage: false,
        leverageMin: 1,
        leverageMax: 1,
        hasFundingRate: false,
        hasMargin: false,
        hasOptions: false,
      );
    }

    return MarketTypeFeatures.fromJson(features);
  }

  /// Validates whether a leverage value is allowed for a specific market type.
  ///
  /// This is a convenience method that delegates to [MarketType.isValidLeverage].
  /// It checks if the leverage value is within the allowed range for the
  /// given market type.
  ///
  /// Parameters:
  /// - [marketType]: The market type to validate against
  /// - [leverage]: The leverage value to validate
  ///
  /// Returns `true` if the leverage is valid, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// // Valid leverage for Futures (1-100x)
  /// service.validateLeverage(MarketType.futures, 50.0); // true
  /// service.validateLeverage(MarketType.futures, 150.0); // false
  ///
  /// // Spot only allows 1x
  /// service.validateLeverage(MarketType.spot, 1.0); // true
  /// service.validateLeverage(MarketType.spot, 5.0); // false
  ///
  /// // Margin allows 1-10x
  /// service.validateLeverage(MarketType.margin, 8.0); // true
  /// service.validateLeverage(MarketType.margin, 15.0); // false
  /// ```
  bool validateLeverage(MarketType marketType, double leverage) {
    return marketType.isValidLeverage(leverage);
  }

  /// Gets the allowed leverage range for a specific market type.
  ///
  /// Returns a map containing the minimum and maximum leverage values
  /// allowed for the given market type.
  ///
  /// Parameters:
  /// - [marketType]: The market type to get the range for
  ///
  /// Returns a map with 'min' and 'max' keys containing integer leverage values.
  ///
  /// Example:
  /// ```dart
  /// final range = service.getLeverageRange(MarketType.futures);
  /// print('Futures leverage: ${range['min']}x - ${range['max']}x');
  /// // Output: "Futures leverage: 1x - 100x"
  ///
  /// final spotRange = service.getLeverageRange(MarketType.spot);
  /// print('Spot leverage: ${spotRange['min']}x - ${spotRange['max']}x');
  /// // Output: "Spot leverage: 1x - 1x"
  /// ```
  Map<String, int> getLeverageRange(MarketType marketType) {
    return {
      'min': marketType.minLeverage,
      'max': marketType.maxLeverage,
    };
  }

  /// Handles Dio exceptions and converts them to [ApiException].
  ///
  /// Extracts error information from the Dio exception response and
  /// creates an appropriate [ApiException] with user-friendly error messages.
  ///
  /// If the response contains error data, it extracts the error message
  /// and details. For network errors without a response, it creates a
  /// generic network error message.
  ApiException _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      return ApiException(
        message: data['error'] ?? data['message'] ?? 'Unknown error',
        details: data['details'],
        statusCode: e.response!.statusCode,
      );
    }
    return ApiException(
      message: 'Network error: ${e.message}',
      statusCode: null,
    );
  }
}
