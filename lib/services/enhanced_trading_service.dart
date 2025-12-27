import 'dart:developer' as developer;
import '../models/position.dart';
import '../models/mcp_rsi_result.dart';
import '../models/mcp_macd_result.dart';
import '../models/mcp_bollinger_bands.dart';
import 'matp_api_client.dart';
import 'mcp_tools_service.dart';
import '../exceptions/matp_exceptions.dart';

/// Enhanced Trading Service combining MATP and MCP capabilities
///
/// This service provides comprehensive trading functionality by combining:
/// - MATP REST API for position management and order execution
/// - MCP tools for technical analysis and risk assessment
/// - Real-time position updates and monitoring
/// - Risk management and position sizing
///
/// Features:
/// - Position management (create, update, close)
/// - Technical analysis integration (RSI, MACD, Bollinger Bands)
/// - Risk assessment and position sizing
/// - Real-time position updates
/// - Multi-exchange support
/// - Market type support (spot, futures, margin, options)
///
/// Example usage:
/// ```dart
/// final tradingService = EnhancedTradingService(matpClient, mcpTools);
///
/// // Get positions
/// final positions = await tradingService.getPositions();
///
/// // Create position with risk assessment
/// final request = CreatePositionRequest(
///   symbol: 'BTC-USDT',
///   side: 'long',
///   size: 0.1,
///   leverage: 2,
/// );
/// final position = await tradingService.createPosition(request);
///
/// // Get technical analysis
/// final rsi = await tradingService.calculateRSI('kucoin', 'BTC-USDT');
/// ```
class EnhancedTradingService {
  final MATPApiClient _matpClient;
  final MCPToolsService _mcpTools;

  EnhancedTradingService(this._matpClient, this._mcpTools);

  // ============================================================================
  // POSITION MANAGEMENT
  // ============================================================================

  /// Get all current positions
  ///
  /// [exchange]: Optional exchange filter
  /// [marketType]: Optional market type filter ('spot', 'futures', 'margin', 'options')
  /// [symbol]: Optional symbol filter
  ///
  /// Returns: List of [Position] objects with current market data
  Future<List<Position>> getPositions({
    String? exchange,
    String? marketType,
    String? symbol,
  }) async {
    try {
      developer.log(
        'Getting positions - exchange: $exchange, marketType: $marketType, symbol: $symbol',
        name: 'EnhancedTradingService',
      );

      final queryParams = <String, dynamic>{};
      if (exchange != null) queryParams['exchange'] = exchange;
      if (marketType != null) queryParams['market_type'] = marketType;
      if (symbol != null) queryParams['symbol'] = symbol;

      final response = await _matpClient.get(
        '/api/v1/trading/positions',
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;
      final positions = data['positions'] as List;

      return positions
          .map((pos) => Position.fromJson(pos as Map<String, dynamic>))
          .toList();
    } catch (e) {
      developer.log(
        'Failed to get positions - $e',
        name: 'EnhancedTradingService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get position by ID
  ///
  /// [positionId]: Unique position identifier
  ///
  /// Returns: [Position] with current market data
  Future<Position> getPosition(String positionId) async {
    try {
      developer.log(
        'Getting position: $positionId',
        name: 'EnhancedTradingService',
      );

      final response = await _matpClient.get(
        '/api/v1/trading/positions/$positionId',
      );

      return Position.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to get position $positionId - $e',
        name: 'EnhancedTradingService',
        error: e,
      );
      rethrow;
    }
  }

  /// Create a new trading position with risk validation
  ///
  /// [request]: Position creation request with all parameters
  ///
  /// Returns: [Position] representing the created position
  Future<Position> createPosition(CreatePositionRequest request) async {
    try {
      developer.log(
        'Creating position: ${request.symbol} ${request.side} ${request.size}',
        name: 'EnhancedTradingService',
      );

      // Validate request parameters
      await _validatePositionRequest(request);

      // Perform risk assessment if enabled
      if (request.performRiskAssessment) {
        final riskAssessment = await assessPositionRisk(request);
        if (!riskAssessment.approved) {
          throw MATPValidationException(
            message:
                'Position creation rejected by risk assessment: ${riskAssessment.reason}',
            details: {'risk_assessment': riskAssessment.toJson()},
          );
        }
      }

      final response = await _matpClient.post(
        '/api/v1/trading/positions',
        data: request.toJson(),
      );

      return Position.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to create position for ${request.symbol} - $e',
        name: 'EnhancedTradingService',
        error: e,
      );
      rethrow;
    }
  }

  /// Update an existing position
  ///
  /// [positionId]: Position to update
  /// [request]: Update parameters
  ///
  /// Returns: Updated [Position]
  Future<Position> updatePosition(
    String positionId,
    UpdatePositionRequest request,
  ) async {
    try {
      developer.log(
        'Updating position: $positionId',
        name: 'EnhancedTradingService',
      );

      final response = await _matpClient.put(
        '/api/v1/trading/positions/$positionId',
        data: request.toJson(),
      );

      return Position.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to update position $positionId - $e',
        name: 'EnhancedTradingService',
        error: e,
      );
      rethrow;
    }
  }

  /// Close a trading position
  ///
  /// [positionId]: Position to close
  /// [closeRequest]: Optional close parameters (partial close, limit price, etc.)
  ///
  /// Returns: [ClosePositionResult] with final P&L and execution details
  Future<ClosePositionResult> closePosition(
    String positionId, {
    ClosePositionRequest? closeRequest,
  }) async {
    try {
      developer.log(
        'Closing position: $positionId',
        name: 'EnhancedTradingService',
      );

      final data = closeRequest?.toJson() ?? {};

      final response = await _matpClient.post(
        '/api/v1/trading/positions/$positionId/close',
        data: data,
      );

      return ClosePositionResult.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      developer.log(
        'Failed to close position $positionId - $e',
        name: 'EnhancedTradingService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get position history
  ///
  /// [limit]: Maximum number of positions to return
  /// [offset]: Pagination offset
  /// [symbol]: Optional symbol filter
  /// [status]: Optional status filter ('open', 'closed', 'all')
  ///
  /// Returns: [PositionHistory] with positions and pagination info
  Future<PositionHistory> getPositionHistory({
    int limit = 50,
    int offset = 0,
    String? symbol,
    String? status,
  }) async {
    try {
      final queryParams = {
        'limit': limit,
        'offset': offset,
        if (symbol != null) 'symbol': symbol,
        if (status != null) 'status': status,
      };

      final response = await _matpClient.get(
        '/api/v1/trading/positions/history',
        queryParameters: queryParams,
      );

      return PositionHistory.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to get position history - $e',
        name: 'EnhancedTradingService',
        error: e,
      );
      rethrow;
    }
  }

  // ============================================================================
  // TECHNICAL ANALYSIS INTEGRATION
  // ============================================================================

  /// Calculate RSI for a trading pair
  ///
  /// [exchange]: Exchange name
  /// [symbol]: Trading pair symbol
  /// [period]: RSI period (default: 14)
  /// [marketType]: Optional market type
  ///
  /// Returns: [MCPRSIResult] with RSI value and signal
  Future<MCPRSIResult> calculateRSI(
    String exchange,
    String symbol, {
    int period = 14,
    String? marketType,
  }) async {
    try {
      return await _mcpTools.calculateRSI(
        exchange,
        symbol,
        period: period,
        marketType: marketType,
      );
    } catch (e) {
      developer.log(
        'Failed to calculate RSI for $exchange:$symbol - $e',
        name: 'EnhancedTradingService',
        error: e,
      );
      rethrow;
    }
  }

  /// Calculate MACD for a trading pair
  ///
  /// [exchange]: Exchange name
  /// [symbol]: Trading pair symbol
  /// [fastPeriod]: Fast EMA period (default: 12)
  /// [slowPeriod]: Slow EMA period (default: 26)
  /// [signalPeriod]: Signal line period (default: 9)
  /// [marketType]: Optional market type
  ///
  /// Returns: [MCPMACDResult] with MACD, signal, and histogram
  Future<MCPMACDResult> calculateMACD(
    String exchange,
    String symbol, {
    int fastPeriod = 12,
    int slowPeriod = 26,
    int signalPeriod = 9,
    String? marketType,
  }) async {
    try {
      return await _mcpTools.calculateMACD(
        exchange,
        symbol,
        fastPeriod: fastPeriod,
        slowPeriod: slowPeriod,
        signalPeriod: signalPeriod,
        marketType: marketType,
      );
    } catch (e) {
      developer.log(
        'Failed to calculate MACD for $exchange:$symbol - $e',
        name: 'EnhancedTradingService',
        error: e,
      );
      rethrow;
    }
  }

  /// Calculate Bollinger Bands for a trading pair
  ///
  /// [exchange]: Exchange name
  /// [symbol]: Trading pair symbol
  /// [period]: Moving average period (default: 20)
  /// [stdDev]: Standard deviation multiplier (default: 2.0)
  /// [marketType]: Optional market type
  ///
  /// Returns: [MCPBollingerBands] with upper, middle, and lower bands
  Future<MCPBollingerBands> calculateBollingerBands(
    String exchange,
    String symbol, {
    int period = 20,
    double stdDev = 2.0,
    String? marketType,
  }) async {
    try {
      return await _mcpTools.calculateBollingerBands(
        exchange,
        symbol,
        period: period,
        stdDev: stdDev,
        marketType: marketType,
      );
    } catch (e) {
      developer.log(
        'Failed to calculate Bollinger Bands for $exchange:$symbol - $e',
        name: 'EnhancedTradingService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get comprehensive technical analysis for a symbol
  ///
  /// [exchange]: Exchange name
  /// [symbol]: Trading pair symbol
  /// [marketType]: Optional market type
  ///
  /// Returns: [TechnicalAnalysisResult] with all indicators
  Future<TechnicalAnalysisResult> getTechnicalAnalysis(
    String exchange,
    String symbol, {
    String? marketType,
  }) async {
    try {
      developer.log(
        'Getting technical analysis for $exchange:$symbol',
        name: 'EnhancedTradingService',
      );

      // Get all technical indicators in parallel
      final futures = await Future.wait([
        calculateRSI(exchange, symbol, marketType: marketType),
        calculateMACD(exchange, symbol, marketType: marketType),
        calculateBollingerBands(exchange, symbol, marketType: marketType),
      ]);

      return TechnicalAnalysisResult(
        symbol: symbol,
        exchange: exchange,
        timestamp: DateTime.now(),
        rsi: futures[0] as MCPRSIResult,
        macd: futures[1] as MCPMACDResult,
        bollingerBands: futures[2] as MCPBollingerBands,
      );
    } catch (e) {
      developer.log(
        'Failed to get technical analysis for $exchange:$symbol - $e',
        name: 'EnhancedTradingService',
        error: e,
      );
      rethrow;
    }
  }

  // ============================================================================
  // RISK ASSESSMENT AND POSITION SIZING
  // ============================================================================

  /// Assess risk for a potential position
  ///
  /// [request]: Position request to assess
  ///
  /// Returns: [RiskAssessmentResult] with approval status and risk metrics
  Future<RiskAssessmentResult> assessPositionRisk(
    CreatePositionRequest request,
  ) async {
    try {
      developer.log(
        'Assessing risk for ${request.symbol} position',
        name: 'EnhancedTradingService',
      );

      final riskRequest = {
        'symbol': request.symbol,
        'side': request.side,
        'size': request.size,
        'leverage': request.leverage,
        'entry_price': request.entryPrice,
        'stop_loss': request.stopLoss,
        'take_profit': request.takeProfit,
        'exchange': request.exchange,
        'market_type': request.marketType,
      };

      final result = await _mcpTools.assessRisk(riskRequest);

      return RiskAssessmentResult.fromJson(result);
    } catch (e) {
      developer.log(
        'Failed to assess risk for ${request.symbol} - $e',
        name: 'EnhancedTradingService',
        error: e,
      );
      rethrow;
    }
  }

  /// Calculate optimal position size based on risk parameters
  ///
  /// [request]: Position sizing request with risk parameters
  ///
  /// Returns: [PositionSizeResult] with recommended size and risk metrics
  Future<PositionSizeResult> calculatePositionSize(
    PositionSizeRequest request,
  ) async {
    try {
      developer.log(
        'Calculating position size for ${request.symbol}',
        name: 'EnhancedTradingService',
      );

      final result = await _mcpTools.calculatePositionSize(request.toJson());

      return PositionSizeResult.fromJson(result);
    } catch (e) {
      developer.log(
        'Failed to calculate position size for ${request.symbol} - $e',
        name: 'EnhancedTradingService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get current risk state and exposure
  ///
  /// [exchange]: Optional exchange filter
  ///
  /// Returns: [RiskState] with current risk metrics and limits
  Future<RiskState> getRiskState({String? exchange}) async {
    try {
      final riskState = await _mcpTools.getRiskState();
      final exposure = await _mcpTools.getExposure(exchange: exchange);

      return RiskState.fromJson({
        ...riskState,
        'exposure': exposure,
      });
    } catch (e) {
      developer.log(
        'Failed to get risk state - $e',
        name: 'EnhancedTradingService',
        error: e,
      );
      rethrow;
    }
  }

  // ============================================================================
  // REAL-TIME UPDATES
  // ============================================================================

  /// Subscribe to real-time position updates
  ///
  /// [onUpdate]: Callback function for position updates
  /// [symbols]: Optional list of symbols to monitor
  ///
  /// Returns: Stream subscription that can be cancelled
  Stream<PositionUpdate> subscribeToPositionUpdates({
    List<String>? symbols,
  }) async* {
    try {
      developer.log(
        'Subscribing to position updates for symbols: $symbols',
        name: 'EnhancedTradingService',
      );

      // This would typically connect to a WebSocket stream
      // For now, we'll simulate with periodic polling
      await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
        try {
          final positions = await getPositions(
            symbol: symbols?.join(','),
          );

          for (final position in positions) {
            yield PositionUpdate(
              type: 'position_update',
              position: position,
              timestamp: DateTime.now(),
            );
          }
        } catch (e) {
          developer.log(
            'Error in position update stream - $e',
            name: 'EnhancedTradingService',
            error: e,
          );
        }
      }
    } catch (e) {
      developer.log(
        'Failed to subscribe to position updates - $e',
        name: 'EnhancedTradingService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get real-time market data for a symbol
  ///
  /// [exchange]: Exchange name
  /// [symbol]: Trading pair symbol
  /// [marketType]: Optional market type
  ///
  /// Returns: [MarketData] with current prices and volume
  Future<MarketData> getMarketData(
    String exchange,
    String symbol, {
    String? marketType,
  }) async {
    try {
      final ticker = await _mcpTools.getTicker(
        exchange,
        symbol,
        marketType: marketType,
      );

      return MarketData.fromTicker(ticker);
    } catch (e) {
      developer.log(
        'Failed to get market data for $exchange:$symbol - $e',
        name: 'EnhancedTradingService',
        error: e,
      );
      rethrow;
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Validate position request parameters
  Future<void> _validatePositionRequest(CreatePositionRequest request) async {
    if (request.symbol.isEmpty) {
      throw MATPValidationException(message:'Symbol cannot be empty');
    }

    if (request.size <= 0) {
      throw MATPValidationException(message:'Position size must be greater than 0');
    }

    if (request.leverage != null && request.leverage! <= 0) {
      throw MATPValidationException(message:'Leverage must be greater than 0');
    }

    if (!['long', 'short', 'buy', 'sell']
        .contains(request.side.toLowerCase())) {
      throw MATPValidationException(message:'Invalid position side: ${request.side}');
    }

    // Additional validation can be added here
  }

  /// Get trading statistics
  ///
  /// [timeframe]: Statistics timeframe ('1d', '7d', '30d')
  /// [symbol]: Optional symbol filter
  ///
  /// Returns: [TradingStatistics] with performance metrics
  Future<TradingStatistics> getTradingStatistics(
    String timeframe, {
    String? symbol,
  }) async {
    try {
      final queryParams = {
        'timeframe': timeframe,
        if (symbol != null) 'symbol': symbol,
      };

      final response = await _matpClient.get(
        '/api/v1/trading/statistics',
        queryParameters: queryParams,
      );

      return TradingStatistics.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log(
        'Failed to get trading statistics - $e',
        name: 'EnhancedTradingService',
        error: e,
      );
      rethrow;
    }
  }
}

// ============================================================================
// REQUEST/RESPONSE MODELS
// ============================================================================

/// Request model for creating a new position
class CreatePositionRequest {
  final String symbol;
  final String side; // 'long', 'short', 'buy', 'sell'
  final double size;
  final String exchange;
  final String marketType; // 'spot', 'futures', 'margin', 'options'
  final double? leverage;
  final double? entryPrice; // null for market orders
  final double? stopLoss;
  final double? takeProfit;
  final String? orderType; // 'market', 'limit', 'stop'
  final bool performRiskAssessment;
  final Map<String, dynamic>? metadata;

  CreatePositionRequest({
    required this.symbol,
    required this.side,
    required this.size,
    required this.exchange,
    this.marketType = 'spot',
    this.leverage,
    this.entryPrice,
    this.stopLoss,
    this.takeProfit,
    this.orderType = 'market',
    this.performRiskAssessment = true,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'side': side,
      'size': size,
      'exchange': exchange,
      'market_type': marketType,
      if (leverage != null) 'leverage': leverage,
      if (entryPrice != null) 'entry_price': entryPrice,
      if (stopLoss != null) 'stop_loss': stopLoss,
      if (takeProfit != null) 'take_profit': takeProfit,
      'order_type': orderType,
      'perform_risk_assessment': performRiskAssessment,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Request model for updating a position
class UpdatePositionRequest {
  final double? stopLoss;
  final double? takeProfit;
  final double? size; // For partial closes or size adjustments
  final Map<String, dynamic>? metadata;

  UpdatePositionRequest({
    this.stopLoss,
    this.takeProfit,
    this.size,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      if (stopLoss != null) 'stop_loss': stopLoss,
      if (takeProfit != null) 'take_profit': takeProfit,
      if (size != null) 'size': size,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Request model for closing a position
class ClosePositionRequest {
  final double? size; // null for full close
  final double? price; // null for market close
  final String? orderType; // 'market', 'limit'

  ClosePositionRequest({
    this.size,
    this.price,
    this.orderType = 'market',
  });

  Map<String, dynamic> toJson() {
    return {
      if (size != null) 'size': size,
      if (price != null) 'price': price,
      'order_type': orderType,
    };
  }
}

/// Request model for position sizing calculation
class PositionSizeRequest {
  final String symbol;
  final String exchange;
  final double accountBalance;
  final double riskPercentage; // Percentage of account to risk
  final double entryPrice;
  final double stopLoss;
  final double? leverage;

  PositionSizeRequest({
    required this.symbol,
    required this.exchange,
    required this.accountBalance,
    required this.riskPercentage,
    required this.entryPrice,
    required this.stopLoss,
    this.leverage,
  });

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'exchange': exchange,
      'account_balance': accountBalance,
      'risk_percentage': riskPercentage,
      'entry_price': entryPrice,
      'stop_loss': stopLoss,
      if (leverage != null) 'leverage': leverage,
    };
  }
}

/// Result of position close operation
class ClosePositionResult {
  final String positionId;
  final String status;
  final double exitPrice;
  final double realizedPnl;
  final double pnlPercent;
  final DateTime closedAt;
  final double fees;

  ClosePositionResult({
    required this.positionId,
    required this.status,
    required this.exitPrice,
    required this.realizedPnl,
    required this.pnlPercent,
    required this.closedAt,
    required this.fees,
  });

  factory ClosePositionResult.fromJson(Map<String, dynamic> json) {
    return ClosePositionResult(
      positionId: json['position_id'] as String,
      status: json['status'] as String,
      exitPrice: (json['exit_price'] as num).toDouble(),
      realizedPnl: (json['realized_pnl'] as num).toDouble(),
      pnlPercent: (json['pnl_percent'] as num).toDouble(),
      closedAt: DateTime.parse(json['closed_at'] as String),
      fees: (json['fees'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position_id': positionId,
      'status': status,
      'exit_price': exitPrice,
      'realized_pnl': realizedPnl,
      'pnl_percent': pnlPercent,
      'closed_at': closedAt.toIso8601String(),
      'fees': fees,
    };
  }

  bool get isProfit => realizedPnl > 0;
}

/// Position history with pagination
class PositionHistory {
  final List<Position> positions;
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  PositionHistory({
    required this.positions,
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  factory PositionHistory.fromJson(Map<String, dynamic> json) {
    return PositionHistory(
      positions: (json['positions'] as List)
          .map((pos) => Position.fromJson(pos as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      hasMore: json['has_more'] as bool,
    );
  }
}

/// Technical analysis result
class TechnicalAnalysisResult {
  final String symbol;
  final String exchange;
  final DateTime timestamp;
  final MCPRSIResult rsi;
  final MCPMACDResult macd;
  final MCPBollingerBands bollingerBands;

  TechnicalAnalysisResult({
    required this.symbol,
    required this.exchange,
    required this.timestamp,
    required this.rsi,
    required this.macd,
    required this.bollingerBands,
  });

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'exchange': exchange,
      'timestamp': timestamp.toIso8601String(),
      'rsi': rsi.toJson(),
      'macd': macd.toJson(),
      'bollinger_bands': bollingerBands.toJson(),
    };
  }
}

/// Risk assessment result
class RiskAssessmentResult {
  final bool approved;
  final String? reason;
  final double riskScore;
  final Map<String, dynamic> metrics;
  final List<String> warnings;

  RiskAssessmentResult({
    required this.approved,
    this.reason,
    required this.riskScore,
    required this.metrics,
    required this.warnings,
  });

  factory RiskAssessmentResult.fromJson(Map<String, dynamic> json) {
    return RiskAssessmentResult(
      approved: json['approved'] as bool,
      reason: json['reason'] as String?,
      riskScore: (json['risk_score'] as num).toDouble(),
      metrics: json['metrics'] as Map<String, dynamic>? ?? {},
      warnings: (json['warnings'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'approved': approved,
      if (reason != null) 'reason': reason,
      'risk_score': riskScore,
      'metrics': metrics,
      'warnings': warnings,
    };
  }
}

/// Position size calculation result
class PositionSizeResult {
  final double recommendedSize;
  final double maxSize;
  final double riskAmount;
  final double riskPercentage;
  final Map<String, dynamic> calculations;

  PositionSizeResult({
    required this.recommendedSize,
    required this.maxSize,
    required this.riskAmount,
    required this.riskPercentage,
    required this.calculations,
  });

  factory PositionSizeResult.fromJson(Map<String, dynamic> json) {
    return PositionSizeResult(
      recommendedSize: (json['recommended_size'] as num).toDouble(),
      maxSize: (json['max_size'] as num).toDouble(),
      riskAmount: (json['risk_amount'] as num).toDouble(),
      riskPercentage: (json['risk_percentage'] as num).toDouble(),
      calculations: json['calculations'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommended_size': recommendedSize,
      'max_size': maxSize,
      'risk_amount': riskAmount,
      'risk_percentage': riskPercentage,
      'calculations': calculations,
    };
  }
}

/// Risk state information
class RiskState {
  final double totalExposure;
  final double availableMargin;
  final double usedMargin;
  final double marginRatio;
  final Map<String, double> assetExposure;
  final List<String> riskWarnings;

  RiskState({
    required this.totalExposure,
    required this.availableMargin,
    required this.usedMargin,
    required this.marginRatio,
    required this.assetExposure,
    required this.riskWarnings,
  });

  factory RiskState.fromJson(Map<String, dynamic> json) {
    return RiskState(
      totalExposure: (json['total_exposure'] as num?)?.toDouble() ?? 0.0,
      availableMargin: (json['available_margin'] as num?)?.toDouble() ?? 0.0,
      usedMargin: (json['used_margin'] as num?)?.toDouble() ?? 0.0,
      marginRatio: (json['margin_ratio'] as num?)?.toDouble() ?? 0.0,
      assetExposure: (json['asset_exposure'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
          {},
      riskWarnings: (json['risk_warnings'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_exposure': totalExposure,
      'available_margin': availableMargin,
      'used_margin': usedMargin,
      'margin_ratio': marginRatio,
      'asset_exposure': assetExposure,
      'risk_warnings': riskWarnings,
    };
  }

  bool get isHighRisk => marginRatio > 0.8;
  bool get hasWarnings => riskWarnings.isNotEmpty;
}

/// Real-time position update
class PositionUpdate {
  final String type;
  final Position position;
  final DateTime timestamp;

  PositionUpdate({
    required this.type,
    required this.position,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'position': position.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Market data snapshot
class MarketData {
  final String symbol;
  final String exchange;
  final double price;
  final double bid;
  final double ask;
  final double volume24h;
  final double change24h;
  final double changePercent24h;
  final DateTime timestamp;

  MarketData({
    required this.symbol,
    required this.exchange,
    required this.price,
    required this.bid,
    required this.ask,
    required this.volume24h,
    required this.change24h,
    required this.changePercent24h,
    required this.timestamp,
  });

  factory MarketData.fromTicker(dynamic ticker) {
    return MarketData(
      symbol: ticker.pair ?? '',
      exchange: ticker.exchange ?? '',
      price: ticker.last ?? 0.0,
      bid: ticker.bid ?? 0.0,
      ask: ticker.ask ?? 0.0,
      volume24h: ticker.volume ?? 0.0,
      change24h: ticker.change ?? 0.0,
      changePercent24h: ticker.changePercent ?? 0.0,
      timestamp: ticker.timestamp ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'exchange': exchange,
      'price': price,
      'bid': bid,
      'ask': ask,
      'volume_24h': volume24h,
      'change_24h': change24h,
      'change_percent_24h': changePercent24h,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  double get spread => ask - bid;
  double get spreadPercent => price > 0 ? (spread / price) * 100 : 0.0;
  bool get isRising => change24h > 0;
}

/// Trading statistics
class TradingStatistics {
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final double totalPnl;
  final double winRate;
  final double averageWin;
  final double averageLoss;
  final double profitFactor;
  final double sharpeRatio;
  final double maxDrawdown;

  TradingStatistics({
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.totalPnl,
    required this.winRate,
    required this.averageWin,
    required this.averageLoss,
    required this.profitFactor,
    required this.sharpeRatio,
    required this.maxDrawdown,
  });

  factory TradingStatistics.fromJson(Map<String, dynamic> json) {
    return TradingStatistics(
      totalTrades: json['total_trades'] as int? ?? 0,
      winningTrades: json['winning_trades'] as int? ?? 0,
      losingTrades: json['losing_trades'] as int? ?? 0,
      totalPnl: (json['total_pnl'] as num?)?.toDouble() ?? 0.0,
      winRate: (json['win_rate'] as num?)?.toDouble() ?? 0.0,
      averageWin: (json['average_win'] as num?)?.toDouble() ?? 0.0,
      averageLoss: (json['average_loss'] as num?)?.toDouble() ?? 0.0,
      profitFactor: (json['profit_factor'] as num?)?.toDouble() ?? 0.0,
      sharpeRatio: (json['sharpe_ratio'] as num?)?.toDouble() ?? 0.0,
      maxDrawdown: (json['max_drawdown'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_trades': totalTrades,
      'winning_trades': winningTrades,
      'losing_trades': losingTrades,
      'total_pnl': totalPnl,
      'win_rate': winRate,
      'average_win': averageWin,
      'average_loss': averageLoss,
      'profit_factor': profitFactor,
      'sharpe_ratio': sharpeRatio,
      'max_drawdown': maxDrawdown,
    };
  }

  bool get isProfitable => totalPnl > 0;
  bool get hasGoodWinRate => winRate >= 0.5;
}
