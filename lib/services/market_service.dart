import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/market_type.dart';
import '../models/markets_response.dart';
import '../models/market_features.dart';
import '../models/market_pair.dart';

/// Market Service - Abstraction layer for different market types
///
/// This service provides a unified interface for interacting with different
/// market types (spot, futures, margin, options).
///
/// ✅ Backend Status: FULLY IMPLEMENTED (v3.2)
/// - All 67 tools support optional market_type parameter
/// - Automatic symbol conversion (BTC-USDT → BTCUSDTM for futures)
/// - Market-specific validation (leverage limits, etc.)
/// - Backwards compatible (market_type is optional)
///
/// See: BACKEND_RESPONSE_TO_FLUTTER_TEAM.md for full documentation
class MarketService {
  final Dio _dio;

  MarketService(this._dio);

  // ============================================================================
  // Enhanced Markets Endpoint (v2.0)
  // ============================================================================

  /// Get markets with optional filtering by market type
  ///
  /// **Hybrid Solution (3 Phases)**:
  /// - Phase 1: Try get_markets (enhanced format)
  /// - Phase 2: Fallback to get_pairs_by_type (works correctly)
  /// - Phase 3: Fallback to static data (last resort)
  ///
  /// Backend endpoint: get_markets tool via MCP (preferred)
  /// Fallback endpoint: get_pairs_by_type tool via MCP (working)
  ///
  /// Parameters:
  /// - [exchange]: Exchange name (e.g., 'kucoin')
  /// - [marketType]: Optional market type filter ('spot', 'futures', 'margin', 'options')
  ///
  /// Returns: [MarketsResponse] with pairs, features, counts, and metadata
  ///
  /// Example:
  /// ```dart
  /// // Get all pairs
  /// final allMarkets = await service.getMarkets(exchange: 'kucoin');
  ///
  /// // Get only futures pairs
  /// final futuresMarkets = await service.getMarkets(
  ///   exchange: 'kucoin',
  ///   marketType: 'futures',
  /// );
  /// ```
  Future<MarketsResponse> getMarkets({
    required String exchange,
    String? marketType,
  }) async {
    // Phase 1: Try get_markets (enhanced format)
    try {
      final marketsResponse = await _tryGetMarkets(exchange, marketType);

      // Check if it's the enhanced format (v2.0)
      if (marketsResponse.version == '2.0' &&
          marketsResponse.dataSource != 'fallback' &&
          marketsResponse.pairs.isNotEmpty) {
        // Backend has been updated! Use enhanced format
        return marketsResponse;
      }
    } catch (e) {
      // get_markets failed or returned old format, continue to Phase 2
    }

    // Phase 2: Fallback to get_pairs_by_type (works correctly)
    try {
      return await _getMarketsUsingPairsByType(exchange, marketType);
    } catch (e) {
      // get_pairs_by_type also failed, continue to Phase 3
    }

    // Phase 3: Fallback to static data (last resort)
    return _getFallbackMarketsResponse(exchange, marketType);
  }

  /// Phase 1: Try get_markets endpoint
  Future<MarketsResponse> _tryGetMarkets(
    String exchange,
    String? marketType,
  ) async {
    final arguments = <String, dynamic>{
      'exchange': exchange,
    };

    if (marketType != null) {
      arguments['market_type'] = marketType;
    }

    final response = await _dio.post(
      ApiConfig.mcpToolsUrl,
      data: {
        'jsonrpc': '2.0',
        'method': 'tools/call',
        'params': {
          'name': 'get_markets',
          'arguments': arguments,
        },
        'id': DateTime.now().millisecondsSinceEpoch,
      },
    );

    // Check for JSON-RPC error
    if (response.data['error'] != null) {
      final error = response.data['error'];
      throw Exception('Backend error: ${error['message']}');
    }

    final result = response.data['result'] as Map<String, dynamic>;

    // Check if backend returned the enhanced format
    if (result.containsKey('pairs') && result.containsKey('version')) {
      // Enhanced format (v2.0) - backend has been updated!
      return MarketsResponse.fromJson(result);
    } else {
      // Simple format (old) - throw to trigger fallback
      throw Exception('get_markets returned old format');
    }
  }

  /// Phase 2: Use get_pairs_by_type (works correctly)
  Future<MarketsResponse> _getMarketsUsingPairsByType(
    String exchange,
    String? marketType,
  ) async {
    // get_pairs_by_type requires market_type, default to 'spot' if not provided
    final effectiveMarketType = marketType ?? 'spot';

    final response = await _dio.post(
      ApiConfig.mcpToolsUrl,
      data: {
        'jsonrpc': '2.0',
        'method': 'tools/call',
        'params': {
          'name': 'get_pairs_by_type',
          'arguments': {
            'exchange': exchange,
            'market_type': effectiveMarketType,
          },
        },
        'id': DateTime.now().millisecondsSinceEpoch,
      },
    );

    // Check for JSON-RPC error
    if (response.data['error'] != null) {
      final error = response.data['error'];
      throw Exception('Backend error: ${error['message']}');
    }

    final result = response.data['result'] as Map<String, dynamic>;

    // Convert get_pairs_by_type format to MarketsResponse
    return _convertPairsByTypeToMarketsResponse(result, exchange, marketType);
  }

  /// Convert get_pairs_by_type response to MarketsResponse format
  MarketsResponse _convertPairsByTypeToMarketsResponse(
    Map<String, dynamic> result,
    String exchange,
    String? marketType,
  ) {
    final pairsData = result['pairs'] as List<dynamic>;
    final pairs = pairsData.map((symbol) {
      final symbolStr = symbol as String;
      return MarketPair.fromJson({
        'symbol': symbolStr,
        'standard_symbol': _toStandardSymbol(symbolStr),
        'base': _extractBase(symbolStr),
        'quote': _extractQuote(symbolStr),
        'market_type': result['market_type'] ?? marketType,
      });
    }).toList();

    return MarketsResponse(
      exchange: exchange,
      marketType: marketType,
      pairs: pairs,
      features: result['features'] != null
          ? MarketFeatures.fromJson(result['features'] as Map<String, dynamic>)
          : null,
      totalCount: result['count'] ?? pairs.length,
      marketTypesCount: {}, // Not available in get_pairs_by_type
      dataSource: 'backend_pairs_by_type',
      cached: false,
      timestamp: DateTime.now(),
      version: '1.0', // get_pairs_by_type is v1.0
      note: result['note'] as String?,
    );
  }

  /// Convert exchange-specific symbol to standard format (BASE-QUOTE)
  String _toStandardSymbol(String symbol) {
    // Remove futures suffix (M)
    if (symbol.endsWith('M') && symbol.length > 1) {
      final withoutM = symbol.substring(0, symbol.length - 1);
      // Try to split into base and quote
      // Common patterns: BTCUSDT -> BTC-USDT
      if (withoutM.contains('USDT')) {
        final base = withoutM.replaceAll('USDT', '');
        return '$base-USDT';
      }
      if (withoutM.contains('USDC')) {
        final base = withoutM.replaceAll('USDC', '');
        return '$base-USDC';
      }
      if (withoutM.contains('BUSD')) {
        final base = withoutM.replaceAll('BUSD', '');
        return '$base-BUSD';
      }
    }

    // Already in standard format (BTC-USDT)
    if (symbol.contains('-')) {
      return symbol;
    }

    // Try to split BTCUSDT -> BTC-USDT
    if (symbol.contains('USDT')) {
      final base = symbol.replaceAll('USDT', '');
      return '$base-USDT';
    }
    if (symbol.contains('USDC')) {
      final base = symbol.replaceAll('USDC', '');
      return '$base-USDC';
    }
    if (symbol.contains('BUSD')) {
      final base = symbol.replaceAll('BUSD', '');
      return '$base-BUSD';
    }

    // Can't parse, return as-is
    return symbol;
  }

  /// Extract base currency from symbol
  String _extractBase(String symbol) {
    final standard = _toStandardSymbol(symbol);
    if (standard.contains('-')) {
      return standard.split('-')[0];
    }
    return standard;
  }

  /// Extract quote currency from symbol
  String _extractQuote(String symbol) {
    final standard = _toStandardSymbol(symbol);
    if (standard.contains('-')) {
      return standard.split('-')[1];
    }
    return 'USDT'; // Default
  }

  /// Get all markets without filtering
  ///
  /// Convenience method to get all pairs from all market types.
  ///
  /// Example:
  /// ```dart
  /// final allMarkets = await service.getAllMarkets(exchange: 'kucoin');
  /// print('Total pairs: ${allMarkets.totalCount}');
  /// print('Spot pairs: ${allMarkets.marketTypesCount['spot']}');
  /// ```
  Future<MarketsResponse> getAllMarkets({
    required String exchange,
  }) async {
    return await getMarkets(exchange: exchange);
  }

  /// Fallback markets response with static data
  MarketsResponse _getFallbackMarketsResponse(
    String exchange,
    String? marketType,
  ) {
    final allPairs = _getAllFallbackPairs();
    final filteredPairs = marketType != null
        ? allPairs.where((p) => p.marketType == marketType).toList()
        : allPairs;

    return MarketsResponse(
      exchange: exchange,
      marketType: marketType,
      pairs: filteredPairs,
      features:
          marketType != null ? _getFallbackFeaturesForType(marketType) : null,
      totalCount: filteredPairs.length,
      marketTypesCount: {
        'spot': allPairs.where((p) => p.marketType == 'spot').length,
        'futures': allPairs.where((p) => p.marketType == 'futures').length,
        'margin': allPairs.where((p) => p.marketType == 'margin').length,
        'options': allPairs.where((p) => p.marketType == 'options').length,
      },
      dataSource: 'fallback',
      cached: false,
      timestamp: DateTime.now(),
      version: '2.0',
      note: 'Using fallback data - backend endpoint unavailable',
    );
  }

  /// Get all fallback pairs (static data)
  List<MarketPair> _getAllFallbackPairs() {
    final commonPairs = [
      'BTC-USDT',
      'ETH-USDT',
      'SOL-USDT',
      'BNB-USDT',
      'XRP-USDT',
      'ADA-USDT',
      'DOGE-USDT',
    ];

    final pairs = <MarketPair>[];

    // Spot pairs
    for (final pair in commonPairs) {
      pairs.add(MarketPair.fromJson({
        'symbol': pair,
        'standard_symbol': pair,
        'base': pair.split('-')[0],
        'quote': pair.split('-')[1],
        'market_type': 'spot',
      }));
    }

    // Futures pairs
    for (final pair in commonPairs) {
      final futuresSymbol = pair.replaceAll('-', '') + 'M';
      pairs.add(MarketPair.fromJson({
        'symbol': futuresSymbol,
        'standard_symbol': pair,
        'base': pair.split('-')[0],
        'quote': pair.split('-')[1],
        'market_type': 'futures',
      }));
    }

    // Margin pairs (subset)
    for (final pair in commonPairs.take(3)) {
      pairs.add(MarketPair.fromJson({
        'symbol': pair,
        'standard_symbol': pair,
        'base': pair.split('-')[0],
        'quote': pair.split('-')[1],
        'market_type': 'margin',
      }));
    }

    // Options pairs (subset)
    for (final pair in commonPairs.take(2)) {
      pairs.add(MarketPair.fromJson({
        'symbol': pair,
        'standard_symbol': pair,
        'base': pair.split('-')[0],
        'quote': pair.split('-')[1],
        'market_type': 'options',
      }));
    }

    return pairs;
  }

  /// Get fallback features for a market type
  MarketFeatures _getFallbackFeaturesForType(String marketType) {
    switch (marketType.toLowerCase()) {
      case 'spot':
        return const MarketFeatures(
          hasLeverage: false,
          leverageMin: 1,
          leverageMax: 1,
          hasFundingRate: false,
          hasLiquidation: false,
          hasMarkPrice: false,
        );
      case 'futures':
        return const MarketFeatures(
          hasLeverage: true,
          leverageMin: 1,
          leverageMax: 100,
          hasFundingRate: true,
          hasLiquidation: true,
          hasMarkPrice: true,
        );
      case 'margin':
        return const MarketFeatures(
          hasLeverage: true,
          leverageMin: 2,
          leverageMax: 10,
          hasFundingRate: false,
          hasLiquidation: true,
          hasMarkPrice: false,
        );
      case 'options':
        return const MarketFeatures(
          hasLeverage: false,
          leverageMin: 1,
          leverageMax: 1,
          hasFundingRate: false,
          hasLiquidation: false,
          hasMarkPrice: false,
        );
      default:
        return const MarketFeatures(
          hasLeverage: false,
          leverageMin: 1,
          leverageMax: 1,
          hasFundingRate: false,
          hasLiquidation: false,
        );
    }
  }

  // ============================================================================
  // Market Information (Legacy - uses new endpoint internally)
  // ============================================================================

  /// Get available market types
  ///
  /// Backend endpoint: get_market_types tool via MCP
  Future<List<MarketType>> getAvailableMarketTypes() async {
    try {
      final response = await _dio.post(
        '${ApiConfig.mcpDirectUrl}/api/v1/mcp/tools/execute',
        data: {
          'tool': 'get_market_types',
          'params': {},
        },
      );

      final result = response.data['result'] ?? response.data;
      final types = (result['market_types'] as List)
          .map((type) => _parseMarketType(type as String))
          .whereType<MarketType>()
          .toList();
      return types;
    } catch (e) {
      // Fallback to all types if endpoint not available
      return MarketType.values;
    }
  }

  /// Get available trading pairs for a market type
  ///
  /// ⚠️ This method now uses the enhanced `get_markets` endpoint internally
  /// instead of the deprecated `get_pairs_by_type` endpoint.
  ///
  /// Backend endpoint: get_markets tool via MCP (internally)
  Future<List<String>> getAvailablePairs({
    required MarketType marketType,
    required String exchange,
  }) async {
    try {
      // Use the new enhanced endpoint
      final marketsResponse = await getMarkets(
        exchange: exchange,
        marketType: marketType.value,
      );

      // Return standard symbols (BASE-QUOTE format)
      return marketsResponse.standardSymbols;
    } catch (e) {
      // Fallback to hardcoded pairs if endpoint not available
      return _getDefaultPairs(marketType);
    }
  }

  List<String> _getDefaultPairs(MarketType marketType) {
    switch (marketType) {
      case MarketType.spot:
      case MarketType.futures:
        return [
          'BTC-USDT',
          'ETH-USDT',
          'SOL-USDT',
          'BNB-USDT',
          'XRP-USDT',
          'ADA-USDT',
          'DOGE-USDT',
        ];
      case MarketType.margin:
        return [
          'BTC-USDT',
          'ETH-USDT',
          'SOL-USDT',
        ];
      case MarketType.options:
        return [
          'BTC-USDT',
          'ETH-USDT',
        ];
    }
  }

  /// Get market features for a specific market type
  ///
  /// Returns information about what features are available
  /// (leverage, funding rate, liquidation, etc.)
  ///
  /// ⚠️ This method now uses the enhanced `get_markets` endpoint internally
  /// instead of the deprecated `get_pairs_by_type` endpoint.
  ///
  /// Backend endpoint: get_markets tool via MCP (internally)
  Future<MarketFeatures> getMarketFeatures({
    required MarketType marketType,
    required String exchange,
  }) async {
    try {
      // Use the new enhanced endpoint
      final marketsResponse = await getMarkets(
        exchange: exchange,
        marketType: marketType.value,
      );

      // Return features from response
      if (marketsResponse.features != null) {
        return marketsResponse.features!;
      }
    } catch (e) {
      // Fallback to hardcoded features if endpoint fails
    }

    // Fallback features based on market type
    return _getFallbackFeaturesForType(marketType.value);
  }

  // ============================================================================
  // Symbol Formatting
  // ============================================================================

  /// Format symbol for API request based on market type
  ///
  /// ⚠️ IMPORTANT: According to backend documentation, the backend handles
  /// ALL symbol formatting automatically. Flutter should ALWAYS send the
  /// standard format (BTC-USDT) and let the backend convert it.
  ///
  /// Frontend: BTC-USDT (always)
  /// Backend converts automatically:
  /// - Spot: BTC-USDT → BTC-USDT (no change)
  /// - Futures: BTC-USDT → BTCUSDTM (adds M suffix)
  /// - Margin: BTC-USDT → BTC-USDT (no change)
  /// - Options: BTC-USDT → [exchange-specific format]
  ///
  /// See: BACKEND_RESPONSE_TO_FLUTTER_TEAM.md
  String formatSymbolForApi({
    required String symbol,
    required MarketType marketType,
    required String exchange,
  }) {
    // Backend handles all conversions - always send standard format
    return symbol; // Always BTC-USDT format
  }

  /// Parse symbol from API response to frontend format
  ///
  /// ⚠️ IMPORTANT: According to backend documentation, the backend ALWAYS
  /// returns symbols in standard format (BTC-USDT), regardless of market type.
  /// No parsing needed.
  ///
  /// See: BACKEND_RESPONSE_TO_FLUTTER_TEAM.md
  String parseSymbolFromApi({
    required String apiSymbol,
    required MarketType marketType,
    required String exchange,
  }) {
    // Backend always returns standard format - no conversion needed
    return apiSymbol; // Already in BTC-USDT format
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Parse market type string to enum
  MarketType? _parseMarketType(String type) {
    switch (type.toLowerCase()) {
      case 'spot':
        return MarketType.spot;
      case 'futures':
        return MarketType.futures;
      case 'margin':
        return MarketType.margin;
      case 'options':
        return MarketType.options;
      default:
        return null;
    }
  }
}

// MarketFeatures class moved to lib/models/market_features.dart
