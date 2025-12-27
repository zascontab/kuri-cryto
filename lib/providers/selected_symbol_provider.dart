import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para manejar el símbolo seleccionado globalmente
class SelectedSymbolNotifier extends StateNotifier<String> {
  SelectedSymbolNotifier() : super('BTC-USDT');

  /// Cambiar el símbolo seleccionado
  void setSymbol(String symbol) {
    state = symbol;
  }

  /// Obtener información del símbolo actual
  SymbolInfo getSymbolInfo() {
    return SymbolInfo.fromSymbol(state);
  }
}

/// Provider para el exchange seleccionado
class SelectedExchangeNotifier extends StateNotifier<String> {
  SelectedExchangeNotifier() : super('kucoin');

  /// Cambiar el exchange seleccionado
  void setExchange(String exchange) {
    state = exchange;
  }
}

/// Provider instances
final selectedSymbolProvider =
    StateNotifierProvider<SelectedSymbolNotifier, String>(
  (ref) => SelectedSymbolNotifier(),
);

final selectedExchangeProvider =
    StateNotifierProvider<SelectedExchangeNotifier, String>(
  (ref) => SelectedExchangeNotifier(),
);

/// Información del símbolo
class SymbolInfo {
  final String symbol;
  final String baseAsset;
  final String quoteAsset;
  final String displayName;

  SymbolInfo({
    required this.symbol,
    required this.baseAsset,
    required this.quoteAsset,
    required this.displayName,
  });

  factory SymbolInfo.fromSymbol(String symbol) {
    final parts = symbol.split('-');
    if (parts.length == 2) {
      return SymbolInfo(
        symbol: symbol,
        baseAsset: parts[0],
        quoteAsset: parts[1],
        displayName: '${parts[0]}/${parts[1]}',
      );
    }

    // Fallback para símbolos con formato diferente
    return SymbolInfo(
      symbol: symbol,
      baseAsset: symbol,
      quoteAsset: 'USDT',
      displayName: symbol,
    );
  }

  /// Lista de símbolos populares
  static List<String> get popularSymbols => [
        'BTC-USDT',
        'ETH-USDT',
        'BNB-USDT',
        'ADA-USDT',
        'SOL-USDT',
        'XRP-USDT',
        'DOT-USDT',
        'DOGE-USDT',
        'AVAX-USDT',
        'MATIC-USDT',
        'LINK-USDT',
        'UNI-USDT',
        'LTC-USDT',
        'BCH-USDT',
        'ATOM-USDT',
      ];

  /// Lista de exchanges disponibles
  static List<String> get availableExchanges => [
        'kucoin',
        'binance',
        'okx',
        'bybit',
        'coinbase',
      ];
}
