import 'package:dio/dio.dart';
import '../models/models.dart';
import '../config/api_config.dart';
import 'api_exception.dart';

/// Service for aggregating data from multiple exchanges
class ExchangeAggregator {
  final Dio _dio;

  ExchangeAggregator(this._dio);

  /// Fetch balances from Binance
  Future<List<Asset>> fetchBinanceBalances() async {
    try {
      final response = await _dio.get(
        '${ApiConfig.gatewayBaseUrl}/exchanges/binance/balances',
      );

      final balances = response.data['balances'] as List<dynamic>;
      return balances
          .map((b) => _convertToAsset(b as Map<String, dynamic>, 'binance'))
          .where((asset) => asset.quantity > 0)
          .toList();
    } on DioException catch (e) {
      throw _handleError(e, 'Binance');
    }
  }

  /// Fetch balances from Bybit
  Future<List<Asset>> fetchBybitBalances() async {
    try {
      final response = await _dio.get(
        '${ApiConfig.gatewayBaseUrl}/exchanges/bybit/balances',
      );

      final balances = response.data['balances'] as List<dynamic>;
      return balances
          .map((b) => _convertToAsset(b as Map<String, dynamic>, 'bybit'))
          .where((asset) => asset.quantity > 0)
          .toList();
    } on DioException catch (e) {
      throw _handleError(e, 'Bybit');
    }
  }

  /// Aggregate balances from all exchanges
  Future<List<Asset>> aggregateBalances() async {
    final results = await Future.wait([
      fetchBinanceBalances().catchError((_) => <Asset>[]),
      fetchBybitBalances().catchError((_) => <Asset>[]),
    ]);

    final allAssets = <String, Asset>{};

    for (final assets in results) {
      for (final asset in assets) {
        final key = asset.symbol;
        if (allAssets.containsKey(key)) {
          // Combine assets with same symbol
          final existing = allAssets[key]!;
          final combinedQuantity = existing.quantity + asset.quantity;
          final combinedValue = existing.value + asset.value;
          allAssets[key] = Asset(
            symbol: asset.symbol,
            quantity: combinedQuantity,
            currentPrice: asset.currentPrice,
            value: combinedValue,
            allocation: 0, // Will be calculated later
            exchange: 'multiple',
            averageBuyPrice: _calculateWeightedAverage(
              existing.averageBuyPrice,
              existing.quantity,
              asset.averageBuyPrice,
              asset.quantity,
            ),
          );
        } else {
          allAssets[key] = asset;
        }
      }
    }

    return allAssets.values.toList();
  }

  /// Calculate total portfolio value
  Future<double> calculateTotalValue() async {
    final assets = await aggregateBalances();
    return assets.fold<double>(0.0, (sum, asset) => sum + asset.value);
  }

  /// Convert exchange-specific balance to Asset
  Asset _convertToAsset(Map<String, dynamic> balance, String exchange) {
    final symbol = balance['asset'] as String? ?? balance['symbol'] as String;
    final quantity = (balance['free'] as num?)?.toDouble() ?? 0.0;
    final price = (balance['price'] as num?)?.toDouble() ?? 0.0;
    final value = quantity * price;

    return Asset(
      symbol: symbol,
      quantity: quantity,
      currentPrice: price,
      value: value,
      allocation: 0, // Will be calculated by portfolio service
      exchange: exchange,
      averageBuyPrice: (balance['avg_price'] as num?)?.toDouble(),
    );
  }

  /// Calculate weighted average price
  double? _calculateWeightedAverage(
    double? price1,
    double qty1,
    double? price2,
    double qty2,
  ) {
    if (price1 == null && price2 == null) return null;
    if (price1 == null) return price2;
    if (price2 == null) return price1;

    final totalQty = qty1 + qty2;
    if (totalQty == 0) return null;

    return (price1 * qty1 + price2 * qty2) / totalQty;
  }

  ApiException _handleError(DioException e, String exchange) {
    if (e.response != null) {
      final data = e.response!.data;
      return ApiException(
        message:
            '$exchange error: ${data['error'] ?? data['message'] ?? 'Unknown error'}',
        details: data['details'],
        statusCode: e.response!.statusCode,
      );
    }
    return ApiException(
      message: '$exchange network error: ${e.message}',
      statusCode: null,
    );
  }
}
