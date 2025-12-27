import 'dart:developer' as developer;
import '../models/mcp_ticker.dart';
import '../models/mcp_candle.dart';
import '../models/mcp_orderbook.dart';
import '../models/mcp_rsi_result.dart';
import '../models/mcp_macd_result.dart';
import '../models/mcp_bollinger_bands.dart';
import '../models/mcp_account_info.dart';
import '../models/mcp_balance.dart';
import '../models/mcp_portfolio.dart';
import '../models/mcp_trading_signal.dart';
import 'mcp_service.dart';

/// Service for MCP Tools with all 29 verified tools
///
/// This service provides a high-level interface to all verified MCP tools
/// for technical analysis, backtesting, and risk management.
///
/// Features:
/// - Market data retrieval (tickers, candles, orderbooks)
/// - Technical indicators (RSI, MACD, Bollinger Bands, EMA, SMA, etc.)
/// - Backtesting and optimization tools
/// - Account management and portfolio analysis
/// - Risk assessment and position sizing
///
/// Example usage:
/// ```dart
/// final mcpTools = MCPToolsService(mcpService);
///
/// // Get market data
/// final ticker = await mcpTools.getTicker('kucoin', 'BTC-USDT');
/// final candles = await mcpTools.getCandles('kucoin', 'BTC-USDT', '1h', 100);
///
/// // Calculate technical indicators
/// final rsi = await mcpTools.calculateRSI('kucoin', 'BTC-USDT', 14);
/// final macd = await mcpTools.calculateMACD('kucoin', 'BTC-USDT');
/// final bb = await mcpTools.calculateBollingerBands('kucoin', 'BTC-USDT', 20, 2.0);
///
/// // Run backtesting
/// final backtest = await mcpTools.runBacktest(backtestRequest);
/// ```
class MCPToolsService {
  final MCPService _mcpService;

  MCPToolsService(this._mcpService);

  // ============================================================================
  // MARKET DATA TOOLS
  // ============================================================================

  /// Get ticker data for a trading pair
  ///
  /// [exchange]: Exchange name (e.g., 'kucoin', 'binance')
  /// [pair]: Trading pair (e.g., 'BTC-USDT', 'ETH-USDT')
  /// [marketType]: Optional market type ('spot', 'futures', 'margin', 'options')
  ///
  /// Returns: [MCPTicker] with current price, volume, and 24h statistics
  Future<MCPTicker> getTicker(
    String exchange,
    String pair, {
    String? marketType,
  }) async {
    try {
      return await _mcpService.callToolTyped<MCPTicker>(
        toolName: 'get_ticker',
        arguments: {
          'exchange': exchange,
          'pair': pair,
        },
        marketType: marketType,
        fromJson: MCPTicker.fromJson,
      );
    } catch (e) {
      developer.log(
        'Failed to get ticker for $exchange:$pair - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get historical candle data
  ///
  /// [exchange]: Exchange name
  /// [pair]: Trading pair
  /// [interval]: Candle interval ('1m', '5m', '15m', '1h', '4h', '1d', etc.)
  /// [limit]: Number of candles to retrieve (max 1000)
  /// [marketType]: Optional market type
  ///
  /// Returns: List of [MCPCandle] objects ordered by timestamp
  Future<List<MCPCandle>> getCandles(
    String exchange,
    String pair,
    String interval,
    int limit, {
    String? marketType,
  }) async {
    try {
      final result = await _mcpService.callTool(
        toolName: 'get_candles',
        arguments: {
          'exchange': exchange,
          'pair': pair,
          'interval': interval,
          'limit': limit,
        },
        marketType: marketType,
      );

      final candlesData = result['candles'] as List;
      return candlesData
          .map((candle) => MCPCandle.fromJson(candle as Map<String, dynamic>))
          .toList();
    } catch (e) {
      developer.log(
        'Failed to get candles for $exchange:$pair - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get order book data
  ///
  /// [exchange]: Exchange name
  /// [pair]: Trading pair
  /// [depth]: Order book depth (default: 20)
  /// [marketType]: Optional market type
  ///
  /// Returns: [MCPOrderBook] with bids and asks
  Future<MCPOrderBook> getOrderBook(
    String exchange,
    String pair, {
    int depth = 20,
    String? marketType,
  }) async {
    try {
      return await _mcpService.callToolTyped<MCPOrderBook>(
        toolName: 'get_orderbook',
        arguments: {
          'exchange': exchange,
          'pair': pair,
          'depth': depth,
        },
        marketType: marketType,
        fromJson: MCPOrderBook.fromJson,
      );
    } catch (e) {
      developer.log(
        'Failed to get orderbook for $exchange:$pair - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get available markets for an exchange
  ///
  /// [exchange]: Exchange name
  /// [marketType]: Optional market type filter
  ///
  /// Returns: List of available trading pairs
  Future<List<String>> getMarkets(
    String exchange, {
    String? marketType,
  }) async {
    try {
      final result = await _mcpService.callTool(
        toolName: 'get_markets',
        arguments: {
          'exchange': exchange,
        },
        marketType: marketType,
      );

      return (result['markets'] as List).cast<String>();
    } catch (e) {
      developer.log(
        'Failed to get markets for $exchange - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get mark price for futures contracts
  ///
  /// [exchange]: Exchange name
  /// [pair]: Trading pair
  ///
  /// Returns: Current mark price
  Future<double> getMarkPrice(String exchange, String pair) async {
    try {
      final result = await _mcpService.callTool(
        toolName: 'get_mark_price',
        arguments: {
          'exchange': exchange,
          'pair': pair,
        },
        marketType: 'futures',
      );

      return (result['mark_price'] as num).toDouble();
    } catch (e) {
      developer.log(
        'Failed to get mark price for $exchange:$pair - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  // ============================================================================
  // TECHNICAL INDICATORS
  // ============================================================================

  /// Calculate RSI (Relative Strength Index)
  ///
  /// [exchange]: Exchange name
  /// [pair]: Trading pair
  /// [period]: RSI period (default: 14)
  /// [marketType]: Optional market type
  ///
  /// Returns: [MCPRSIResult] with RSI value and signal
  Future<MCPRSIResult> calculateRSI(
    String exchange,
    String pair, {
    int period = 14,
    String? marketType,
  }) async {
    try {
      return await _mcpService.callToolTyped<MCPRSIResult>(
        toolName: 'calculate_rsi',
        arguments: {
          'exchange': exchange,
          'pair': pair,
          'period': period,
        },
        marketType: marketType,
        fromJson: MCPRSIResult.fromJson,
      );
    } catch (e) {
      developer.log(
        'Failed to calculate RSI for $exchange:$pair - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Calculate MACD (Moving Average Convergence Divergence)
  ///
  /// [exchange]: Exchange name
  /// [pair]: Trading pair
  /// [fastPeriod]: Fast EMA period (default: 12)
  /// [slowPeriod]: Slow EMA period (default: 26)
  /// [signalPeriod]: Signal line period (default: 9)
  /// [marketType]: Optional market type
  ///
  /// Returns: [MCPMACDResult] with MACD, signal, and histogram
  Future<MCPMACDResult> calculateMACD(
    String exchange,
    String pair, {
    int fastPeriod = 12,
    int slowPeriod = 26,
    int signalPeriod = 9,
    String? marketType,
  }) async {
    try {
      return await _mcpService.callToolTyped<MCPMACDResult>(
        toolName: 'calculate_macd',
        arguments: {
          'exchange': exchange,
          'pair': pair,
          'fast_period': fastPeriod,
          'slow_period': slowPeriod,
          'signal_period': signalPeriod,
        },
        marketType: marketType,
        fromJson: MCPMACDResult.fromJson,
      );
    } catch (e) {
      developer.log(
        'Failed to calculate MACD for $exchange:$pair - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Calculate Bollinger Bands
  ///
  /// [exchange]: Exchange name
  /// [pair]: Trading pair
  /// [period]: Moving average period (default: 20)
  /// [stdDev]: Standard deviation multiplier (default: 2.0)
  /// [marketType]: Optional market type
  ///
  /// Returns: [MCPBollingerBands] with upper, middle, and lower bands
  Future<MCPBollingerBands> calculateBollingerBands(
    String exchange,
    String pair, {
    int period = 20,
    double stdDev = 2.0,
    String? marketType,
  }) async {
    try {
      return await _mcpService.callToolTyped<MCPBollingerBands>(
        toolName: 'calculate_bollinger_bands',
        arguments: {
          'exchange': exchange,
          'pair': pair,
          'period': period,
          'std_dev': stdDev,
        },
        marketType: marketType,
        fromJson: MCPBollingerBands.fromJson,
      );
    } catch (e) {
      developer.log(
        'Failed to calculate Bollinger Bands for $exchange:$pair - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Calculate EMA (Exponential Moving Average)
  ///
  /// [exchange]: Exchange name
  /// [pair]: Trading pair
  /// [period]: EMA period
  /// [marketType]: Optional market type
  ///
  /// Returns: Current EMA value
  Future<double> calculateEMA(
    String exchange,
    String pair,
    int period, {
    String? marketType,
  }) async {
    try {
      final result = await _mcpService.callTool(
        toolName: 'calculate_ema',
        arguments: {
          'exchange': exchange,
          'pair': pair,
          'period': period,
        },
        marketType: marketType,
      );

      return (result['ema'] as num).toDouble();
    } catch (e) {
      developer.log(
        'Failed to calculate EMA for $exchange:$pair - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Calculate SMA (Simple Moving Average)
  ///
  /// [exchange]: Exchange name
  /// [pair]: Trading pair
  /// [period]: SMA period
  /// [marketType]: Optional market type
  ///
  /// Returns: Current SMA value
  Future<double> calculateSMA(
    String exchange,
    String pair,
    int period, {
    String? marketType,
  }) async {
    try {
      final result = await _mcpService.callTool(
        toolName: 'calculate_sma',
        arguments: {
          'exchange': exchange,
          'pair': pair,
          'period': period,
        },
        marketType: marketType,
      );

      return (result['sma'] as num).toDouble();
    } catch (e) {
      developer.log(
        'Failed to calculate SMA for $exchange:$pair - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Calculate ATR (Average True Range)
  ///
  /// [exchange]: Exchange name
  /// [pair]: Trading pair
  /// [period]: ATR period (default: 14)
  /// [marketType]: Optional market type
  ///
  /// Returns: Current ATR value
  Future<double> calculateATR(
    String exchange,
    String pair, {
    int period = 14,
    String? marketType,
  }) async {
    try {
      final result = await _mcpService.callTool(
        toolName: 'calculate_atr',
        arguments: {
          'exchange': exchange,
          'pair': pair,
          'period': period,
        },
        marketType: marketType,
      );

      return (result['atr'] as num).toDouble();
    } catch (e) {
      developer.log(
        'Failed to calculate ATR for $exchange:$pair - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Calculate Stochastic Oscillator
  ///
  /// [exchange]: Exchange name
  /// [pair]: Trading pair
  /// [kPeriod]: %K period (default: 14)
  /// [dPeriod]: %D period (default: 3)
  /// [marketType]: Optional market type
  ///
  /// Returns: Map with 'k' and 'd' values
  Future<Map<String, double>> calculateStochastic(
    String exchange,
    String pair, {
    int kPeriod = 14,
    int dPeriod = 3,
    String? marketType,
  }) async {
    try {
      final result = await _mcpService.callTool(
        toolName: 'calculate_stochastic',
        arguments: {
          'exchange': exchange,
          'pair': pair,
          'k_period': kPeriod,
          'd_period': dPeriod,
        },
        marketType: marketType,
      );

      return {
        'k': (result['k'] as num).toDouble(),
        'd': (result['d'] as num).toDouble(),
      };
    } catch (e) {
      developer.log(
        'Failed to calculate Stochastic for $exchange:$pair - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Calculate ADX (Average Directional Index)
  ///
  /// [exchange]: Exchange name
  /// [pair]: Trading pair
  /// [period]: ADX period (default: 14)
  /// [marketType]: Optional market type
  ///
  /// Returns: Current ADX value
  Future<double> calculateADX(
    String exchange,
    String pair, {
    int period = 14,
    String? marketType,
  }) async {
    try {
      final result = await _mcpService.callTool(
        toolName: 'calculate_adx',
        arguments: {
          'exchange': exchange,
          'pair': pair,
          'period': period,
        },
        marketType: marketType,
      );

      return (result['adx'] as num).toDouble();
    } catch (e) {
      developer.log(
        'Failed to calculate ADX for $exchange:$pair - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Calculate CCI (Commodity Channel Index)
  ///
  /// [exchange]: Exchange name
  /// [pair]: Trading pair
  /// [period]: CCI period (default: 20)
  /// [marketType]: Optional market type
  ///
  /// Returns: Current CCI value
  Future<double> calculateCCI(
    String exchange,
    String pair, {
    int period = 20,
    String? marketType,
  }) async {
    try {
      final result = await _mcpService.callTool(
        toolName: 'calculate_cci',
        arguments: {
          'exchange': exchange,
          'pair': pair,
          'period': period,
        },
        marketType: marketType,
      );

      return (result['cci'] as num).toDouble();
    } catch (e) {
      developer.log(
        'Failed to calculate CCI for $exchange:$pair - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Calculate Williams %R
  ///
  /// [exchange]: Exchange name
  /// [pair]: Trading pair
  /// [period]: Williams %R period (default: 14)
  /// [marketType]: Optional market type
  ///
  /// Returns: Current Williams %R value
  Future<double> calculateWilliamsR(
    String exchange,
    String pair, {
    int period = 14,
    String? marketType,
  }) async {
    try {
      final result = await _mcpService.callTool(
        toolName: 'calculate_williams_r',
        arguments: {
          'exchange': exchange,
          'pair': pair,
          'period': period,
        },
        marketType: marketType,
      );

      return (result['williams_r'] as num).toDouble();
    } catch (e) {
      developer.log(
        'Failed to calculate Williams %R for $exchange:$pair - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Calculate multiple EMAs at once
  ///
  /// [exchange]: Exchange name
  /// [pair]: Trading pair
  /// [periods]: List of EMA periods to calculate
  /// [marketType]: Optional market type
  ///
  /// Returns: Map of period -> EMA value
  Future<Map<int, double>> calculateMultipleEMAs(
    String exchange,
    String pair,
    List<int> periods, {
    String? marketType,
  }) async {
    try {
      final result = await _mcpService.callTool(
        toolName: 'calculate_multiple_emas',
        arguments: {
          'exchange': exchange,
          'pair': pair,
          'periods': periods,
        },
        marketType: marketType,
      );

      final emas = result['emas'] as Map<String, dynamic>;
      return emas.map(
        (key, value) => MapEntry(int.parse(key), (value as num).toDouble()),
      );
    } catch (e) {
      developer.log(
        'Failed to calculate multiple EMAs for $exchange:$pair - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get complete technical analysis for a pair
  ///
  /// [exchange]: Exchange name
  /// [pair]: Trading pair
  /// [marketType]: Optional market type
  ///
  /// Returns: [MCPTradingSignal] with comprehensive analysis
  Future<MCPTradingSignal> getCompleteAnalysis(
    String exchange,
    String pair, {
    String? marketType,
  }) async {
    try {
      return await _mcpService.callToolTyped<MCPTradingSignal>(
        toolName: 'get_complete_analysis',
        arguments: {
          'exchange': exchange,
          'pair': pair,
        },
        marketType: marketType,
        fromJson: MCPTradingSignal.fromJson,
      );
    } catch (e) {
      developer.log(
        'Failed to get complete analysis for $exchange:$pair - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  // ============================================================================
  // BACKTESTING TOOLS
  // ============================================================================

  /// Run a backtest with specified parameters
  ///
  /// [request]: Backtest configuration
  ///
  /// Returns: Backtest results with performance metrics
  Future<Map<String, dynamic>> runBacktest(
    Map<String, dynamic> request,
  ) async {
    try {
      return await _mcpService.callTool(
        toolName: 'run_backtest',
        arguments: request,
      );
    } catch (e) {
      developer.log(
        'Failed to run backtest - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Optimize strategy parameters
  ///
  /// [request]: Optimization configuration
  ///
  /// Returns: Optimization results with best parameters
  Future<Map<String, dynamic>> optimizeParameters(
    Map<String, dynamic> request,
  ) async {
    try {
      return await _mcpService.callTool(
        toolName: 'optimize_parameters',
        arguments: request,
      );
    } catch (e) {
      developer.log(
        'Failed to optimize parameters - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Compare multiple strategies
  ///
  /// [strategies]: List of strategy configurations
  ///
  /// Returns: Comparison results
  Future<Map<String, dynamic>> compareStrategies(
    List<Map<String, dynamic>> strategies,
  ) async {
    try {
      return await _mcpService.callTool(
        toolName: 'compare_strategies',
        arguments: {
          'strategies': strategies,
        },
      );
    } catch (e) {
      developer.log(
        'Failed to compare strategies - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  // ============================================================================
  // ACCOUNT MANAGEMENT
  // ============================================================================

  /// Get account information
  ///
  /// [exchange]: Exchange name
  ///
  /// Returns: [MCPAccountInfo] with account details
  Future<MCPAccountInfo> getAccountInfo(String exchange) async {
    try {
      return await _mcpService.callToolTyped<MCPAccountInfo>(
        toolName: 'get_account_info',
        arguments: {
          'exchange': exchange,
        },
        fromJson: MCPAccountInfo.fromJson,
      );
    } catch (e) {
      developer.log(
        'Failed to get account info for $exchange - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get balance for a specific currency
  ///
  /// [exchange]: Exchange name
  /// [currency]: Currency symbol (e.g., 'BTC', 'USDT')
  ///
  /// Returns: [MCPBalance] with balance details
  Future<MCPBalance> getBalance(String exchange, String currency) async {
    try {
      return await _mcpService.callToolTyped<MCPBalance>(
        toolName: 'get_balance',
        arguments: {
          'exchange': exchange,
          'currency': currency,
        },
        fromJson: MCPBalance.fromJson,
      );
    } catch (e) {
      developer.log(
        'Failed to get balance for $exchange:$currency - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get complete portfolio
  ///
  /// Returns: [MCPPortfolio] with all balances
  Future<MCPPortfolio> getPortfolio() async {
    try {
      return await _mcpService.callToolTyped<MCPPortfolio>(
        toolName: 'get_portfolio',
        arguments: {},
        fromJson: MCPPortfolio.fromJson,
      );
    } catch (e) {
      developer.log(
        'Failed to get portfolio - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get portfolio analysis
  ///
  /// Returns: Portfolio analysis with metrics
  Future<Map<String, dynamic>> getPortfolioAnalysis() async {
    try {
      return await _mcpService.callTool(
        toolName: 'get_portfolio_analysis',
        arguments: {},
      );
    } catch (e) {
      developer.log(
        'Failed to get portfolio analysis - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  // ============================================================================
  // RISK MANAGEMENT
  // ============================================================================

  /// Calculate position size based on risk parameters
  ///
  /// [request]: Position sizing parameters
  ///
  /// Returns: Recommended position size
  Future<Map<String, dynamic>> calculatePositionSize(
    Map<String, dynamic> request,
  ) async {
    try {
      return await _mcpService.callTool(
        toolName: 'calculate_position_size',
        arguments: request,
      );
    } catch (e) {
      developer.log(
        'Failed to calculate position size - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get current risk state
  ///
  /// Returns: Current risk metrics and limits
  Future<Map<String, dynamic>> getRiskState() async {
    try {
      return await _mcpService.callTool(
        toolName: 'get_risk_state',
        arguments: {},
      );
    } catch (e) {
      developer.log(
        'Failed to get risk state - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get exposure analysis
  ///
  /// [exchange]: Optional exchange filter
  ///
  /// Returns: Exposure breakdown by asset and exchange
  Future<Map<String, dynamic>> getExposure({String? exchange}) async {
    try {
      final arguments = <String, dynamic>{};
      if (exchange != null) {
        arguments['exchange'] = exchange;
      }

      return await _mcpService.callTool(
        toolName: 'get_exposure',
        arguments: arguments,
      );
    } catch (e) {
      developer.log(
        'Failed to get exposure - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Assess risk for a potential trade
  ///
  /// [request]: Risk assessment parameters
  ///
  /// Returns: Risk analysis and recommendations
  Future<Map<String, dynamic>> assessRisk(
    Map<String, dynamic> request,
  ) async {
    try {
      return await _mcpService.callTool(
        toolName: 'assess_risk',
        arguments: request,
      );
    } catch (e) {
      developer.log(
        'Failed to assess risk - $e',
        name: 'MCPToolsService',
        error: e,
      );
      rethrow;
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get list of all available MCP tools
  ///
  /// Returns: List of tool names
  Future<List<String>> getAvailableTools() async {
    return await _mcpService.getAvailableTools();
  }

  /// Call any MCP tool directly (for tools not yet wrapped)
  ///
  /// [toolName]: Name of the MCP tool
  /// [arguments]: Tool arguments
  /// [marketType]: Optional market type
  ///
  /// Returns: Raw tool result
  Future<Map<String, dynamic>> callTool(
    String toolName,
    Map<String, dynamic> arguments, {
    String? marketType,
  }) async {
    return await _mcpService.callTool(
      toolName: toolName,
      arguments: arguments,
      marketType: marketType,
    );
  }

  /// Call multiple tools in parallel
  ///
  /// [calls]: List of tool calls with 'tool' and 'args' keys
  ///
  /// Returns: List of results in the same order as calls
  Future<List<Map<String, dynamic>>> callMultipleTools(
    List<Map<String, dynamic>> calls,
  ) async {
    return await _mcpService.callMultipleTools(calls);
  }
}
