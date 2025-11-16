import 'dart:developer' as developer;
import 'api_client.dart';
import 'api_exception.dart';

/// Position Model
class Position {
  final String id;
  final String symbol;
  final String side; // 'long' or 'short'
  final double entryPrice;
  final double currentPrice;
  final double size;
  final double leverage;
  final double? stopLoss;
  final double? takeProfit;
  final double unrealizedPnl;
  final double? realizedPnl;
  final DateTime openTime;
  final DateTime? closeTime;
  final String strategy;
  final String status; // 'open', 'closing', 'closed'
  final String? closeReason;

  Position({
    required this.id,
    required this.symbol,
    required this.side,
    required this.entryPrice,
    required this.currentPrice,
    required this.size,
    required this.leverage,
    this.stopLoss,
    this.takeProfit,
    required this.unrealizedPnl,
    this.realizedPnl,
    required this.openTime,
    this.closeTime,
    required this.strategy,
    required this.status,
    this.closeReason,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'],
      symbol: json['symbol'],
      side: json['side'],
      entryPrice: (json['entry_price']).toDouble(),
      currentPrice: (json['current_price'] ?? json['entry_price']).toDouble(),
      size: (json['size']).toDouble(),
      leverage: (json['leverage'] ?? 1).toDouble(),
      stopLoss: json['stop_loss']?.toDouble(),
      takeProfit: json['take_profit']?.toDouble(),
      unrealizedPnl: (json['unrealized_pnl'] ?? 0).toDouble(),
      realizedPnl: json['realized_pnl']?.toDouble(),
      openTime: DateTime.parse(json['open_time']),
      closeTime: json['close_time'] != null ? DateTime.parse(json['close_time']) : null,
      strategy: json['strategy'] ?? '',
      status: json['status'] ?? 'open',
      closeReason: json['close_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'side': side,
      'entry_price': entryPrice,
      'current_price': currentPrice,
      'size': size,
      'leverage': leverage,
      'stop_loss': stopLoss,
      'take_profit': takeProfit,
      'unrealized_pnl': unrealizedPnl,
      'realized_pnl': realizedPnl,
      'open_time': openTime.toIso8601String(),
      'close_time': closeTime?.toIso8601String(),
      'strategy': strategy,
      'status': status,
      'close_reason': closeReason,
    };
  }
}

/// Position Service
///
/// Handles position management operations:
/// - Get open positions
/// - Get position history
/// - Close positions
/// - Update SL/TP
/// - Move to breakeven
/// - Enable trailing stop
class PositionService {
  final ApiClient _apiClient;
  static const String _basePath = '/scalping/positions';

  PositionService(this._apiClient);

  /// Get all open positions
  ///
  /// Returns a list of all currently open positions.
  ///
  /// Example:
  /// ```dart
  /// final positions = await positionService.getPositions();
  /// print('Open positions: ${positions.length}');
  /// ```
  Future<List<Position>> getPositions() async {
    try {
      developer.log('Fetching open positions...', name: 'PositionService');

      final response = await _apiClient.get<Map<String, dynamic>>(_basePath);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        final positions = data.map((json) => Position.fromJson(json)).toList();
        developer.log('Retrieved ${positions.length} positions', name: 'PositionService');
        return positions;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log('Error getting positions: $e', name: 'PositionService', error: e);
      rethrow;
    }
  }

  /// Get position history
  ///
  /// Returns historical positions with optional filtering.
  ///
  /// Parameters:
  /// - [limit]: Maximum number of positions to return (default: 100)
  /// - [from]: Start date for filtering (ISO 8601 format)
  /// - [to]: End date for filtering (ISO 8601 format)
  ///
  /// Example:
  /// ```dart
  /// final history = await positionService.getPositionHistory(
  ///   limit: 50,
  ///   from: '2025-11-01T00:00:00Z',
  ///   to: '2025-11-16T23:59:59Z',
  /// );
  /// ```
  Future<List<Position>> getPositionHistory({
    int? limit,
    String? from,
    String? to,
  }) async {
    try {
      developer.log('Fetching position history...', name: 'PositionService');

      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_basePath/history',
        queryParameters: queryParams,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        final positions = data.map((json) => Position.fromJson(json)).toList();
        developer.log('Retrieved ${positions.length} historical positions', name: 'PositionService');
        return positions;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log('Error getting position history: $e', name: 'PositionService', error: e);
      rethrow;
    }
  }

  /// Close a position
  ///
  /// Closes an open position by ID.
  ///
  /// Parameters:
  /// - [id]: Position ID to close
  ///
  /// Returns true if successful.
  ///
  /// Example:
  /// ```dart
  /// await positionService.closePosition('pos_123');
  /// ```
  Future<bool> closePosition(String id) async {
    try {
      developer.log('Closing position: $id', name: 'PositionService');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_basePath/$id/close',
      );

      if (response['success'] == true) {
        developer.log('Position closed successfully', name: 'PositionService');
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to close position',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error closing position: $e', name: 'PositionService', error: e);
      rethrow;
    }
  }

  /// Update Stop Loss and Take Profit
  ///
  /// Updates the SL and/or TP for an existing position.
  ///
  /// Parameters:
  /// - [id]: Position ID
  /// - [stopLoss]: New stop loss price (optional)
  /// - [takeProfit]: New take profit price (optional)
  ///
  /// At least one parameter (stopLoss or takeProfit) must be provided.
  ///
  /// Example:
  /// ```dart
  /// await positionService.updateSlTp(
  ///   'pos_123',
  ///   stopLoss: 0.08400,
  ///   takeProfit: 0.08800,
  /// );
  /// ```
  Future<bool> updateSlTp(String id, {double? stopLoss, double? takeProfit}) async {
    if (stopLoss == null && takeProfit == null) {
      throw ArgumentError('At least one parameter (stopLoss or takeProfit) must be provided');
    }

    try {
      developer.log('Updating SL/TP for position: $id', name: 'PositionService');

      final data = <String, dynamic>{};
      if (stopLoss != null) data['stop_loss'] = stopLoss;
      if (takeProfit != null) data['take_profit'] = takeProfit;

      final response = await _apiClient.put<Map<String, dynamic>>(
        '$_basePath/$id/sltp',
        data: data,
      );

      if (response['success'] == true) {
        developer.log('SL/TP updated successfully', name: 'PositionService');
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to update SL/TP',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error updating SL/TP: $e', name: 'PositionService', error: e);
      rethrow;
    }
  }

  /// Move Stop Loss to Breakeven
  ///
  /// Moves the stop loss to the entry price (breakeven) for a position.
  ///
  /// Parameters:
  /// - [id]: Position ID
  ///
  /// Returns the new stop loss price.
  ///
  /// Example:
  /// ```dart
  /// final newStopLoss = await positionService.moveToBreakeven('pos_123');
  /// print('New SL: $newStopLoss');
  /// ```
  Future<double> moveToBreakeven(String id) async {
    try {
      developer.log('Moving position to breakeven: $id', name: 'PositionService');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_basePath/$id/breakeven',
      );

      if (response['success'] == true) {
        final newStopLoss = (response['new_stop_loss'] ?? 0).toDouble();
        developer.log('Position moved to breakeven, new SL: $newStopLoss', name: 'PositionService');
        return newStopLoss;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to move to breakeven',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error moving to breakeven: $e', name: 'PositionService', error: e);
      rethrow;
    }
  }

  /// Enable Trailing Stop
  ///
  /// Enables a trailing stop for a position with the specified distance.
  ///
  /// Parameters:
  /// - [id]: Position ID
  /// - [distancePercent]: Distance from current price in percentage (e.g., 0.2 for 0.2%)
  ///
  /// Example:
  /// ```dart
  /// await positionService.enableTrailingStop('pos_123', 0.2);
  /// ```
  Future<bool> enableTrailingStop(String id, double distancePercent) async {
    try {
      developer.log('Enabling trailing stop for position: $id', name: 'PositionService');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_basePath/$id/trailing-stop',
        data: {
          'distance_percent': distancePercent,
        },
      );

      if (response['success'] == true) {
        developer.log('Trailing stop enabled successfully', name: 'PositionService');
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to enable trailing stop',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error enabling trailing stop: $e', name: 'PositionService', error: e);
      rethrow;
    }
  }

  /// Get a specific position by ID
  ///
  /// Returns the details of a specific position.
  ///
  /// Parameters:
  /// - [id]: Position ID
  ///
  /// Example:
  /// ```dart
  /// final position = await positionService.getPosition('pos_123');
  /// print('Position: ${position.symbol} at ${position.currentPrice}');
  /// ```
  Future<Position> getPosition(String id) async {
    try {
      developer.log('Fetching position: $id', name: 'PositionService');

      final response = await _apiClient.get<Map<String, dynamic>>('$_basePath/$id');

      if (response['success'] == true && response['data'] != null) {
        final position = Position.fromJson(response['data']);
        developer.log('Position retrieved successfully', name: 'PositionService');
        return position;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log('Error getting position: $e', name: 'PositionService', error: e);
      rethrow;
    }
  }

  /// Partially close a position
  ///
  /// Closes a portion of an open position.
  ///
  /// Parameters:
  /// - [id]: Position ID
  /// - [size]: Size to close (must be less than or equal to position size)
  ///
  /// Example:
  /// ```dart
  /// await positionService.partialClose('pos_123', 500.0);
  /// ```
  Future<bool> partialClose(String id, double size) async {
    try {
      developer.log('Partially closing position: $id ($size)', name: 'PositionService');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_basePath/$id/partial-close',
        data: {
          'size': size,
        },
      );

      if (response['success'] == true) {
        developer.log('Position partially closed successfully', name: 'PositionService');
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to partially close position',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error partially closing position: $e', name: 'PositionService', error: e);
      rethrow;
    }
  }
}
