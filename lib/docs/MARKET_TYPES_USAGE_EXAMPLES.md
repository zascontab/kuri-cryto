# 📚 Market Types - Ejemplos de Uso

Ejemplos prácticos de cómo usar el soporte de Market Types en diferentes partes de la aplicación.

---

## 🎯 Ejemplo 1: Provider con Market Type

```dart
import 'package:flutter/foundation.dart';
import '../services/market_data_service.dart';
import '../services/market_service.dart';
import '../screens/trading_hub_screen.dart';

class MarketTypeProvider extends ChangeNotifier {
  final MarketDataService _marketDataService;
  final MarketService _marketService;
  
  MarketType _selectedMarketType = MarketType.futures;
  String _selectedPair = 'BTC-USDT';
  String _selectedExchange = 'kucoin';
  
  MarketFeatures? _currentFeatures;
  List<String> _availablePairs = [];
  bool _isLoading = false;
  String? _error;
  
  MarketTypeProvider(this._marketDataService, this._marketService);
  
  // Getters
  MarketType get selectedMarketType => _selectedMarketType;
  String get selectedPair => _selectedPair;
  String get selectedExchange => _selectedExchange;
  MarketFeatures? get currentFeatures => _currentFeatures;
  List<String> get availablePairs => _availablePairs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Computed properties
  bool get canUseLeverage => _currentFeatures?.hasLeverage ?? false;
  int get maxLeverage => _currentFeatures?.maxLeverage ?? 1;
  int get minLeverage => _currentFeatures?.minLeverage ?? 1;
  bool get hasFundingRate => _currentFeatures?.hasFundingRate ?? false;
  
  /// Cambiar tipo de mercado
  Future<void> setMarketType(MarketType type) async {
    if (_selectedMarketType == type) return;
    
    _selectedMarketType = type;
    _error = null;
    notifyListeners();
    
    // Cargar características y pares para el nuevo tipo
    await Future.wait([
      loadMarketFeatures(),
      loadAvailablePairs(),
    ]);
  }
  
  /// Cambiar par de trading
  void setPair(String pair) {
    if (_selectedPair == pair) return;
    _selectedPair = pair;
    notifyListeners();
  }
  
  /// Cargar características del mercado actual
  Future<void> loadMarketFeatures() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _currentFeatures = await _marketService.getMarketFeatures(
        marketType: _selectedMarketType,
        exchange: _selectedExchange,
      );
      
      _error = null;
    } catch (e) {
      _error = 'Error al cargar características: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Cargar pares disponibles para el tipo de mercado actual
  Future<void> loadAvailablePairs() async {
    try {
      _availablePairs = await _marketService.getAvailablePairs(
        marketType: _selectedMarketType,
        exchange: _selectedExchange,
      );
      
      // Si el par actual no está disponible, seleccionar el primero
      if (_availablePairs.isNotEmpty && !_availablePairs.contains(_selectedPair)) {
        _selectedPair = _availablePairs.first;
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar pares: $e';
      notifyListeners();
    }
  }
  
  /// Obtener ticker con el market type actual
  Future<MCPTicker> getTicker() async {
    return await _marketDataService.getTicker(
      exchange: _selectedExchange,
      pair: _selectedPair,
      marketType: _selectedMarketType.name,
    );
  }
  
  /// Obtener velas con el market type actual
  Future<List<MCPCandle>> getCandles({
    required String interval,
    int limit = 100,
  }) async {
    return await _marketDataService.getCandles(
      exchange: _selectedExchange,
      pair: _selectedPair,
      interval: interval,
      limit: limit,
      marketType: _selectedMarketType.name,
    );
  }
}
```

---

## 🎨 Ejemplo 2: UI con Selector de Market Type

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MarketTypeSelectorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MarketTypeProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Trading - ${provider.selectedMarketType.displayName}'),
          ),
          body: Column(
            children: [
              // Market Type Selector
              _buildMarketTypeSelector(provider),
              
              // Pair Selector
              _buildPairSelector(provider),
              
              // Features Info
              _buildFeaturesInfo(provider),
              
              // Leverage Slider (solo si aplica)
              if (provider.canUseLeverage)
                _buildLeverageSlider(provider),
              
              // Trading Form
              Expanded(
                child: _buildTradingForm(provider),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildMarketTypeSelector(MarketTypeProvider provider) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: SegmentedButton<MarketType>(
        segments: [
          ButtonSegment(
            value: MarketType.spot,
            label: Text('Spot'),
            icon: Icon(Icons.shopping_cart, color: Colors.green),
          ),
          ButtonSegment(
            value: MarketType.futures,
            label: Text('Futures'),
            icon: Icon(Icons.trending_up, color: Colors.blue),
          ),
          ButtonSegment(
            value: MarketType.margin,
            label: Text('Margin'),
            icon: Icon(Icons.account_balance, color: Colors.orange),
          ),
          ButtonSegment(
            value: MarketType.options,
            label: Text('Options'),
            icon: Icon(Icons.settings, color: Colors.purple),
          ),
        ],
        selected: {provider.selectedMarketType},
        onSelectionChanged: (Set<MarketType> newSelection) {
          provider.setMarketType(newSelection.first);
        },
      ),
    );
  }
  
  Widget _buildPairSelector(MarketTypeProvider provider) {
    if (provider.availablePairs.isEmpty) {
      return CircularProgressIndicator();
    }
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButton<String>(
        value: provider.selectedPair,
        isExpanded: true,
        items: provider.availablePairs.map((pair) {
          return DropdownMenuItem(
            value: pair,
            child: Text(pair),
          );
        }).toList(),
        onChanged: (pair) {
          if (pair != null) {
            provider.setPair(pair);
          }
        },
      ),
    );
  }
  
  Widget _buildFeaturesInfo(MarketTypeProvider provider) {
    final features = provider.currentFeatures;
    if (features == null) return SizedBox.shrink();
    
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Características del Mercado', 
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildFeatureRow('Leverage', 
                features.hasLeverage 
                    ? '${features.minLeverage}-${features.maxLeverage}x' 
                    : 'No disponible'),
            _buildFeatureRow('Funding Rate', 
                features.hasFundingRate ? 'Sí' : 'No'),
            _buildFeatureRow('Liquidación', 
                features.hasLiquidation ? 'Sí' : 'No'),
            _buildFeatureRow('Mark Price', 
                features.hasMarkPrice ? 'Sí' : 'No'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  Widget _buildLeverageSlider(MarketTypeProvider provider) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Leverage: ${_leverage.toInt()}x',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _leverage,
              min: provider.minLeverage.toDouble(),
              max: provider.maxLeverage.toDouble(),
              divisions: provider.maxLeverage - provider.minLeverage,
              label: '${_leverage.toInt()}x',
              onChanged: (value) {
                setState(() => _leverage = value);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTradingForm(MarketTypeProvider provider) {
    // Implementar formulario de trading aquí
    return Center(child: Text('Trading Form'));
  }
}

// Extension para nombres amigables
extension MarketTypeExtension on MarketType {
  String get displayName {
    switch (this) {
      case MarketType.spot:
        return 'Spot';
      case MarketType.futures:
        return 'Futuros';
      case MarketType.margin:
        return 'Margen';
      case MarketType.options:
        return 'Opciones';
    }
  }
  
  Color get color {
    switch (this) {
      case MarketType.spot:
        return Colors.green;
      case MarketType.futures:
        return Colors.blue;
      case MarketType.margin:
        return Colors.orange;
      case MarketType.options:
        return Colors.purple;
    }
  }
  
  IconData get icon {
    switch (this) {
      case MarketType.spot:
        return Icons.shopping_cart;
      case MarketType.futures:
        return Icons.trending_up;
      case MarketType.margin:
        return Icons.account_balance;
      case MarketType.options:
        return Icons.settings;
    }
  }
}
```

---

## 📊 Ejemplo 3: Análisis Técnico con Market Type

```dart
class TechnicalAnalysisService {
  final TechnicalIndicatorsService _indicatorsService;
  final MarketDataService _marketDataService;
  
  TechnicalAnalysisService(this._indicatorsService, this._marketDataService);
  
  /// Análisis completo para un par y market type específico
  Future<Map<String, dynamic>> analyzeMarket({
    required String exchange,
    required String pair,
    required String marketType,
    required String interval,
  }) async {
    // Obtener datos en paralelo
    final results = await Future.wait([
      _indicatorsService.calculateRSI(
        exchange: exchange,
        pair: pair,
        interval: interval,
        marketType: marketType,
      ),
      _indicatorsService.calculateMACD(
        exchange: exchange,
        pair: pair,
        interval: interval,
        marketType: marketType,
      ),
      _marketDataService.getTicker(
        exchange: exchange,
        pair: pair,
        marketType: marketType,
      ),
    ]);
    
    final rsi = results[0] as MCPRSIResult;
    final macd = results[1] as MCPMACDResult;
    final ticker = results[2] as MCPTicker;
    
    // Generar señales
    final signals = _generateSignals(rsi, macd, ticker);
    
    return {
      'rsi': rsi,
      'macd': macd,
      'ticker': ticker,
      'signals': signals,
      'marketType': marketType,
      'timestamp': DateTime.now(),
    };
  }
  
  Map<String, dynamic> _generateSignals(
    MCPRSIResult rsi,
    MCPMACDResult macd,
    MCPTicker ticker,
  ) {
    final signals = <String>[];
    var score = 0;
    
    // RSI signals
    if (rsi.isOversold) {
      signals.add('RSI Sobrevendido (${rsi.value.toStringAsFixed(2)})');
      score += 2;
    } else if (rsi.isOverbought) {
      signals.add('RSI Sobrecomprado (${rsi.value.toStringAsFixed(2)})');
      score -= 2;
    }
    
    // MACD signals
    if (macd.isBullish) {
      signals.add('MACD Alcista');
      score += 1;
    } else if (macd.isBearish) {
      signals.add('MACD Bajista');
      score -= 1;
    }
    
    // Price trend
    if (ticker.isRising) {
      signals.add('Precio en tendencia alcista (${ticker.changePercent24h.toStringAsFixed(2)}%)');
      score += 1;
    }
    
    // Overall recommendation
    String recommendation;
    if (score >= 3) {
      recommendation = 'COMPRA FUERTE';
    } else if (score >= 1) {
      recommendation = 'COMPRA';
    } else if (score <= -3) {
      recommendation = 'VENTA FUERTE';
    } else if (score <= -1) {
      recommendation = 'VENTA';
    } else {
      recommendation = 'NEUTRAL';
    }
    
    return {
      'signals': signals,
      'score': score,
      'recommendation': recommendation,
    };
  }
}
```

---

## 🔄 Ejemplo 4: Comparación entre Market Types

```dart
class MarketComparisonService {
  final MarketDataService _marketDataService;
  
  MarketComparisonService(this._marketDataService);
  
  /// Comparar precio del mismo par en diferentes market types
  Future<Map<String, dynamic>> comparePriceAcrossMarkets({
    required String exchange,
    required String pair,
  }) async {
    final marketTypes = ['spot', 'futures', 'margin'];
    
    final tickers = await Future.wait(
      marketTypes.map((type) => _marketDataService.getTicker(
        exchange: exchange,
        pair: pair,
        marketType: type,
      )),
    );
    
    final comparison = <String, dynamic>{};
    for (var i = 0; i < marketTypes.length; i++) {
      comparison[marketTypes[i]] = {
        'price': tickers[i].last,
        'volume': tickers[i].volume,
        'change24h': tickers[i].changePercent24h,
        'spread': tickers[i].spreadPercent,
      };
    }
    
    // Calcular diferencias
    final spotPrice = tickers[0].last;
    final futuresPrice = tickers[1].last;
    final premium = ((futuresPrice - spotPrice) / spotPrice) * 100;
    
    comparison['analysis'] = {
      'futures_premium': premium,
      'highest_volume': _getHighestVolume(tickers, marketTypes),
      'lowest_spread': _getLowestSpread(tickers, marketTypes),
    };
    
    return comparison;
  }
  
  String _getHighestVolume(List<MCPTicker> tickers, List<String> types) {
    var maxVolume = 0.0;
    var maxType = '';
    for (var i = 0; i < tickers.length; i++) {
      if (tickers[i].volume > maxVolume) {
        maxVolume = tickers[i].volume;
        maxType = types[i];
      }
    }
    return maxType;
  }
  
  String _getLowestSpread(List<MCPTicker> tickers, List<String> types) {
    var minSpread = double.infinity;
    var minType = '';
    for (var i = 0; i < tickers.length; i++) {
      if (tickers[i].spreadPercent < minSpread) {
        minSpread = tickers[i].spreadPercent;
        minType = types[i];
      }
    }
    return minType;
  }
}
```

---

## 🎯 Ejemplo 5: Validación de Órdenes según Market Type

```dart
class OrderValidator {
  final MarketService _marketService;
  
  OrderValidator(this._marketService);
  
  /// Validar orden antes de enviar
  Future<ValidationResult> validateOrder({
    required String exchange,
    required String pair,
    required MarketType marketType,
    required String side,
    required double amount,
    double? leverage,
  }) async {
    final errors = <String>[];
    final warnings = <String>[];
    
    // Obtener características del mercado
    final features = await _marketService.getMarketFeatures(
      marketType: marketType,
      exchange: exchange,
    );
    
    // Validar leverage
    if (leverage != null) {
      if (!features.hasLeverage) {
        errors.add('Leverage no está disponible para ${marketType.name}');
      } else if (leverage < features.minLeverage) {
        errors.add('Leverage mínimo es ${features.minLeverage}x');
      } else if (leverage > features.maxLeverage) {
        errors.add('Leverage máximo es ${features.maxLeverage}x');
      } else if (leverage > 10) {
        warnings.add('Leverage alto (${leverage}x) - Mayor riesgo de liquidación');
      }
    } else if (features.hasLeverage && marketType == MarketType.futures) {
      warnings.add('No se especificó leverage - se usará 1x por defecto');
    }
    
    // Validar amount
    if (amount <= 0) {
      errors.add('Cantidad debe ser mayor a 0');
    }
    
    // Validar side
    if (side != 'buy' && side != 'sell') {
      errors.add('Side debe ser "buy" o "sell"');
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  
  ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });
  
  bool get hasWarnings => warnings.isNotEmpty;
}
```

---

## 📱 Ejemplo 6: Widget de Indicador de Market Type

```dart
class MarketTypeIndicator extends StatelessWidget {
  final MarketType marketType;
  final bool showLabel;
  
  const MarketTypeIndicator({
    Key? key,
    required this.marketType,
    this.showLabel = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: marketType.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: marketType.color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(marketType.icon, size: 16, color: marketType.color),
          if (showLabel) ...[
            SizedBox(width: 4),
            Text(
              marketType.displayName,
              style: TextStyle(
                color: marketType.color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Uso:
// MarketTypeIndicator(marketType: MarketType.futures)
```

---

## 🎉 Resumen

Estos ejemplos muestran cómo:
- ✅ Crear providers que manejen market types
- ✅ Construir UI con selectores de market type
- ✅ Realizar análisis técnico por market type
- ✅ Comparar precios entre market types
- ✅ Validar órdenes según características del mercado
- ✅ Crear widgets reutilizables para market types

**Todos los ejemplos son compatibles con la implementación actual del backend v3.2**
