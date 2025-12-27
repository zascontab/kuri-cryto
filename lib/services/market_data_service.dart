import '../models/mcp_ticker.dart';
import '../models/mcp_candle.dart';
import '../models/mcp_orderbook.dart';
import 'mcp_service.dart';

/// Market Data Service - Wrapper para herramientas MCP de datos de mercado
///
/// Provee acceso tipo-seguro a las herramientas MCP:
/// - get_ticker: Obtiene datos de ticker actuales
/// - get_candles: Obtiene datos históricos OHLCV
/// - get_orderbook: Obtiene libro de órdenes
/// - get_24h_stats: Estadísticas de 24 horas
/// - get_multiple_tickers: Múltiples tickers en paralelo
///
/// Ejemplo de uso:
/// ```dart
/// final marketDataService = MarketDataService(mcpService);
///
/// // Obtener ticker
/// final ticker = await marketDataService.getTicker(
///   exchange: 'kucoin',
///   pair: 'BTC-USDT',
/// );
/// print('Precio actual: \$${ticker.last}');
///
/// // Obtener velas
/// final candles = await marketDataService.getCandles(
///   exchange: 'kucoin',
///   pair: 'BTC-USDT',
///   interval: '5m',
///   limit: 100,
/// );
/// print('${candles.length} velas obtenidas');
///
/// // Obtener order book
/// final orderBook = await marketDataService.getOrderBook(
///   exchange: 'kucoin',
///   pair: 'BTC-USDT',
///   depth: 20,
/// );
/// print('Mejor bid: \$${orderBook.bestBid?.price}');
/// print('Mejor ask: \$${orderBook.bestAsk?.price}');
/// ```
class MarketDataService {
  final MCPService _mcpService;

  MarketDataService(this._mcpService);

  /// Obtiene el ticker actual para un par en un exchange
  ///
  /// Usa la herramienta MCP 'get_ticker'
  ///
  /// Parámetros:
  /// - [exchange]: Exchange a consultar (ej: 'kucoin', 'binance', 'mexc')
  /// - [pair]: Par de trading (ej: 'BTC-USDT', 'ETH-USDT')
  /// - [marketType]: Tipo de mercado opcional ('spot', 'futures', 'margin', 'options')
  ///
  /// Retorna: [MCPTicker] con precio actual, bid, ask, volumen, cambios 24h
  ///
  /// Nota: El backend maneja automáticamente la conversión de símbolos según market_type
  Future<MCPTicker> getTicker({
    required String exchange,
    required String pair,
    String? marketType,
  }) async {
    final arguments = {
      'exchange': exchange,
      'pair': pair,
    };

    if (marketType != null) {
      arguments['market_type'] = marketType;
    }

    return await _mcpService.callToolTyped(
      toolName: 'get_ticker',
      arguments: arguments,
      fromJson: MCPTicker.fromJson,
    );
  }

  /// Obtiene datos históricos de velas OHLCV
  ///
  /// Usa la herramienta MCP 'get_candles'
  ///
  /// Parámetros:
  /// - [exchange]: Exchange a consultar
  /// - [pair]: Par de trading
  /// - [interval]: Intervalo de tiempo ('1m', '5m', '15m', '1h', '4h', '1d')
  /// - [limit]: Número de velas a obtener (default: 100, max suele ser 1000)
  /// - [since]: Timestamp desde el cual obtener velas (opcional)
  /// - [marketType]: Tipo de mercado opcional ('spot', 'futures', 'margin', 'options')
  ///
  /// Retorna: Lista de [MCPCandle] ordenadas por timestamp
  Future<List<MCPCandle>> getCandles({
    required String exchange,
    required String pair,
    required String interval,
    int limit = 100,
    DateTime? since,
    String? marketType,
  }) async {
    final arguments = {
      'exchange': exchange,
      'pair': pair,
      'interval': interval,
      'limit': limit,
    };

    if (since != null) {
      arguments['since'] = since.millisecondsSinceEpoch;
    }

    if (marketType != null) {
      arguments['market_type'] = marketType;
    }

    final result = await _mcpService.callTool(
      toolName: 'get_candles',
      arguments: arguments,
    );

    // El resultado puede venir como {'candles': [...]} o directamente [...]
    final candlesList = result['candles'] ?? result;

    if (candlesList is! List) {
      throw FormatException(
          'Expected list of candles, got ${candlesList.runtimeType}');
    }

    return candlesList.map((candle) => MCPCandle.fromJson(candle)).toList();
  }

  /// Obtiene el libro de órdenes (order book) con profundidad de mercado
  ///
  /// Usa la herramienta MCP 'get_orderbook'
  ///
  /// Parámetros:
  /// - [exchange]: Exchange a consultar
  /// - [pair]: Par de trading
  /// - [depth]: Profundidad del libro (número de niveles de precio, default: 20)
  /// - [marketType]: Tipo de mercado opcional ('spot', 'futures', 'margin', 'options')
  ///
  /// Retorna: [MCPOrderBook] con bids, asks y métricas calculadas
  Future<MCPOrderBook> getOrderBook({
    required String exchange,
    required String pair,
    int depth = 20,
    String? marketType,
  }) async {
    final arguments = {
      'exchange': exchange,
      'pair': pair,
      'depth': depth,
    };

    if (marketType != null) {
      arguments['market_type'] = marketType;
    }

    final result = await _mcpService.callTool(
      toolName: 'get_orderbook',
      arguments: arguments,
    );

    // Agregar exchange y pair al resultado si no vienen
    result['exchange'] ??= exchange;
    result['pair'] ??= pair;

    return MCPOrderBook.fromJson(result);
  }

  /// Obtiene estadísticas de 24 horas para un par
  ///
  /// Usa la herramienta MCP 'get_24h_stats'
  ///
  /// Parámetros:
  /// - [exchange]: Exchange a consultar
  /// - [pair]: Par de trading
  ///
  /// Retorna: Map con estadísticas como volume_24h, high_24h, low_24h, etc.
  Future<Map<String, dynamic>> get24hStats({
    required String exchange,
    required String pair,
  }) async {
    return await _mcpService.callTool(
      toolName: 'get_24h_stats',
      arguments: {
        'exchange': exchange,
        'pair': pair,
      },
    );
  }

  /// Obtiene múltiples tickers en paralelo
  ///
  /// Usa la herramienta MCP 'get_multiple_tickers'
  ///
  /// Parámetros:
  /// - [exchange]: Exchange a consultar
  /// - [pairs]: Lista de pares a consultar (ej: ['BTC-USDT', 'ETH-USDT'])
  ///
  /// Retorna: Lista de [MCPTicker] en el mismo orden que [pairs]
  Future<List<MCPTicker>> getMultipleTickers({
    required String exchange,
    required List<String> pairs,
  }) async {
    final result = await _mcpService.callTool(
      toolName: 'get_multiple_tickers',
      arguments: {
        'exchange': exchange,
        'pairs': pairs,
      },
    );

    // El resultado puede venir como {'tickers': [...]} o directamente [...]
    final tickersList = result['tickers'] ?? result;

    if (tickersList is! List) {
      throw FormatException(
          'Expected list of tickers, got ${tickersList.runtimeType}');
    }

    return tickersList.map((ticker) => MCPTicker.fromJson(ticker)).toList();
  }

  /// Obtiene precio de mark (precio de referencia para futures)
  ///
  /// Usa la herramienta MCP 'get_mark_price'
  ///
  /// Parámetros:
  /// - [exchange]: Exchange a consultar
  /// - [pair]: Par de trading
  ///
  /// Retorna: Map con mark_price, index_price, funding_rate, etc.
  Future<Map<String, dynamic>> getMarkPrice({
    required String exchange,
    required String pair,
  }) async {
    return await _mcpService.callTool(
      toolName: 'get_mark_price',
      arguments: {
        'exchange': exchange,
        'pair': pair,
      },
    );
  }

  /// Obtiene el spread actual (diferencia entre bid y ask)
  ///
  /// Método de conveniencia que usa getTicker()
  ///
  /// Retorna: Map con 'spread' (absoluto) y 'spreadPercent'
  Future<Map<String, double>> getSpread({
    required String exchange,
    required String pair,
  }) async {
    final ticker = await getTicker(exchange: exchange, pair: pair);
    return {
      'spread': ticker.spread,
      'spreadPercent': ticker.spreadPercent,
    };
  }

  /// Obtiene el precio medio (mid price) entre bid y ask
  ///
  /// Método de conveniencia que usa getTicker()
  Future<double> getMidPrice({
    required String exchange,
    required String pair,
  }) async {
    final ticker = await getTicker(exchange: exchange, pair: pair);
    return ticker.midPrice;
  }

  /// Verifica si un par está actualmente en tendencia alcista (rising)
  ///
  /// Basado en el cambio de 24h
  Future<bool> isRising({
    required String exchange,
    required String pair,
  }) async {
    final ticker = await getTicker(exchange: exchange, pair: pair);
    return ticker.isRising;
  }

  /// Obtiene velas más recientes para análisis rápido
  ///
  /// Método de conveniencia para obtener las últimas N velas
  ///
  /// Parámetros:
  /// - [exchange]: Exchange a consultar
  /// - [pair]: Par de trading
  /// - [interval]: Intervalo de tiempo
  /// - [count]: Número de velas a obtener (default: 20)
  Future<List<MCPCandle>> getRecentCandles({
    required String exchange,
    required String pair,
    required String interval,
    int count = 20,
  }) async {
    return await getCandles(
      exchange: exchange,
      pair: pair,
      interval: interval,
      limit: count,
    );
  }

  /// Obtiene análisis básico de liquidez del order book
  ///
  /// Retorna métricas útiles del order book como spread, ratio de volumen, etc.
  Future<Map<String, dynamic>> getLiquidityAnalysis({
    required String exchange,
    required String pair,
    int depth = 20,
  }) async {
    final orderBook = await getOrderBook(
      exchange: exchange,
      pair: pair,
      depth: depth,
    );

    return {
      'spread': orderBook.spread,
      'spreadPercent': orderBook.spreadPercent,
      'midPrice': orderBook.midPrice,
      'totalBidVolume': orderBook.totalBidVolume,
      'totalAskVolume': orderBook.totalAskVolume,
      'bidAskVolumeRatio': orderBook.bidAskVolumeRatio,
      'depth': orderBook.depth,
      'bestBid': orderBook.bestBid?.price,
      'bestAsk': orderBook.bestAsk?.price,
    };
  }

  /// Calcula el slippage esperado para una orden de compra
  ///
  /// Parámetros:
  /// - [exchange]: Exchange
  /// - [pair]: Par de trading
  /// - [amount]: Cantidad a comprar (en unidades base)
  /// - [depth]: Profundidad del order book a consultar
  ///
  /// Retorna: Slippage en porcentaje, o null si no hay suficiente liquidez
  Future<double?> estimateBuySlippage({
    required String exchange,
    required String pair,
    required double amount,
    int depth = 50,
  }) async {
    final orderBook = await getOrderBook(
      exchange: exchange,
      pair: pair,
      depth: depth,
    );

    return orderBook.calculateBuySlippage(amount);
  }

  /// Calcula el slippage esperado para una orden de venta
  ///
  /// Parámetros:
  /// - [exchange]: Exchange
  /// - [pair]: Par de trading
  /// - [amount]: Cantidad a vender (en unidades base)
  /// - [depth]: Profundidad del order book a consultar
  ///
  /// Retorna: Slippage en porcentaje, o null si no hay suficiente liquidez
  Future<double?> estimateSellSlippage({
    required String exchange,
    required String pair,
    required double amount,
    int depth = 50,
  }) async {
    final orderBook = await getOrderBook(
      exchange: exchange,
      pair: pair,
      depth: depth,
    );

    return orderBook.calculateSellSlippage(amount);
  }

  /// Verifica si hay suficiente liquidez para ejecutar una orden
  ///
  /// Parámetros:
  /// - [exchange]: Exchange
  /// - [pair]: Par de trading
  /// - [amount]: Cantidad a operar
  /// - [isBuy]: true para compra, false para venta
  ///
  /// Retorna: true si hay suficiente liquidez
  Future<bool> hasEnoughLiquidity({
    required String exchange,
    required String pair,
    required double amount,
    required bool isBuy,
  }) async {
    final orderBook = await getOrderBook(
      exchange: exchange,
      pair: pair,
      depth: 50,
    );

    return isBuy
        ? orderBook.hasEnoughLiquidityToBuy(amount)
        : orderBook.hasEnoughLiquidityToSell(amount);
  }
}
