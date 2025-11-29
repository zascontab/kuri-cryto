import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'api_exception.dart';

/// Service for transaction history management
class TransactionService {
  final Dio _dio;

  TransactionService(this._dio);

  /// Get transactions with pagination
  Future<TransactionPage> getTransactions({
    int page = 1,
    int pageSize = 50,
    String? type,
    String? asset,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        if (type != null) 'type': type,
        if (asset != null) 'asset': asset,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await _dio.get(
        '${ApiConfig.gatewayBaseUrl}/portfolio/transactions',
        queryParameters: queryParams,
      );

      return TransactionPage.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Export transactions as CSV
  Future<String> exportTransactions({
    String? type,
    String? asset,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'format': 'csv',
        if (type != null) 'type': type,
        if (asset != null) 'asset': asset,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await _dio.get(
        '${ApiConfig.gatewayBaseUrl}/portfolio/transactions/export',
        queryParameters: queryParams,
      );

      return response.data as String;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

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

/// Transaction page model
class TransactionPage {
  final List<Transaction> transactions;
  final int currentPage;
  final int totalPages;
  final int totalCount;

  const TransactionPage({
    required this.transactions,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
  });

  factory TransactionPage.fromJson(Map<String, dynamic> json) {
    return TransactionPage(
      transactions: (json['transactions'] as List<dynamic>)
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: json['current_page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
      totalCount: json['total_count'] as int? ?? 0,
    );
  }
}

/// Transaction model
class Transaction {
  final String id;
  final String type;
  final String asset;
  final double amount;
  final String exchange;
  final DateTime timestamp;

  const Transaction({
    required this.id,
    required this.type,
    required this.asset,
    required this.amount,
    required this.exchange,
    required this.timestamp,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      asset: json['asset'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      exchange: json['exchange'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
