# 📦 Modelos de Datos - Flutter

**Modelos Dart listos para usar**

---

## 🎯 Comprehensive Analysis

```dart
class ComprehensiveAnalysis {
  final String symbol;
  final String exchange;
  final CurrentPrice currentPrice;
  final Recommendation recommendation;
  final MultiTimeframe multiTimeframe;
  final KeyLevels keyLevels;
  final FuturesData? futuresData;
  final String marketType;
  final String message;
  final String timestamp;

  ComprehensiveAnalysis({
    required this.symbol,
    required this.exchange,
    required this.currentPrice,
    required this.recommendation,
    required this.multiTimeframe,
    required this.keyLevels,
    this.futuresData,
    required this.marketType,
    required this.message,
    required this.timestamp,
  });

  factory ComprehensiveAnalysis.fromJson(Map<String, dynamic> json) {
    return ComprehensiveAnalysis(
      symbol: json['symbol'],
      exchange: json['exchange'],
      currentPrice: CurrentPrice.fromJson(json['current_price']),
      recommendation: Recommendation.fromJson(json['recommendation']),
      multiTimeframe: MultiTimeframe.fromJson(json['multi_timeframe']),
      keyLevels: KeyLevels.fromJson(json['key_levels']),
      futuresData: json['futures_data'] != null 
          ? FuturesData.fromJson(json['futures_data']) 
          : null,
      marketType: json['market_type'],
      message: json['message'],
      timestamp: json['timestamp'],
    );
  }
}
```

---

## 💰 Current Price

```dart
class CurrentPrice {
  final double current;
  final double high24h;
  final double low24h;
  final double change24h;
  final double volume24h;

  CurrentPrice({
    required this.current,
    required this.high24h,
    required this.low24h,
    required this.change24h,
    required this.volume24h,
  });

  factory CurrentPrice.fromJson(Map<String, dynamic> json) {
    return CurrentPrice(
      current: (json['current'] as num).toDouble(),
      high24h: (json['high_24h'] as num).toDouble(),
      low24h: (json['low_24h'] as num).toDouble(),
      change24h: (json['change_24h'] as num).toDouble(),
      volume24h: (json['volume_24h'] as num).toDouble(),
    );
  }
}
```

---

## 🎯 Recommendation

```dart
class Recommendation {
  final String action; // "BUY", "SELL", "WAIT"
  final double confidence; // 0.0 - 1.0
  final List<String> reasoning;

  Recommendation({
    required this.action,
    required this.confidence,
    required this.reasoning,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      action: json['action'],
      confidence: (json['confidence'] as num).toDouble(),
      reasoning: List<String>.from(json['reasoning']),
    );
  }

  bool get isBuy => action == 'BUY';
  bool get isSell => action == 'SELL';
  bool get isWait => action == 'WAIT';
  
  bool get isHighConfidence => confidence >= 0.7;
  bool get isMediumConfidence => confidence >= 0.5 && confidence < 0.7;
  bool get isLowConfidence => confidence < 0.5;
}
```

---

## 📊 Multi Timeframe

```dart
class MultiTimeframe {
  final TimeframeData tf1m;
  final TimeframeData tf5m;
  final TimeframeData tf15m;
  final TimeframeData tf1h;
  final String alignment;

  MultiTimeframe({
    required this.tf1m,
    required this.tf5m,
    required this.tf15m,
    required this.tf1h,
    required this.alignment,
  });

  factory MultiTimeframe.fromJson(Map<String, dynamic> json) {
    return MultiTimeframe(
      tf1m: TimeframeData.fromJson(json['1m']),
      tf5m: TimeframeData.fromJson(json['5m']),
      tf15m: TimeframeData.fromJson(json['15m']),
      tf1h: TimeframeData.fromJson(json['1h']),
      alignment: json['alignment'],
    );
  }

  bool get isAligned => alignment == 'aligned';
}

class TimeframeData {
  final double rsi;
  final String signal; // "oversold", "overbought", "neutral"
  final String trend; // "bullish", "bearish", "neutral"

  TimeframeData({
    required this.rsi,
    required this.signal,
    required this.trend,
  });

  factory TimeframeData.fromJson(Map<String, dynamic> json) {
    return TimeframeData(
      rsi: (json['rsi'] as num).toDouble(),
      signal: json['signal'],
      trend: json['trend'],
    );
  }

  bool get isOversold => signal == 'oversold';
  bool get isOverbought => signal == 'overbought';
  bool get isBullish => trend == 'bullish';
  bool get isBearish => trend == 'bearish';
}
```

---

## 📈 Key Levels

```dart
class KeyLevels {
  final double support;
  final double resistance;
  final Distance distance;

  KeyLevels({
    required this.support,
    required this.resistance,
    required this.distance,
  });

  factory KeyLevels.fromJson(Map<String, dynamic> json) {
    return KeyLevels(
      support: (json['support'] as num).toDouble(),
      resistance: (json['resistance'] as num).toDouble(),
      distance: Distance.fromJson(json['distance']),
    );
  }
}

class Distance {
  final double toSupportPercent;
  final double toResistancePercent;

  Distance({
    required this.toSupportPercent,
    required this.toResistancePercent,
  });

  factory Distance.fromJson(Map<String, dynamic> json) {
    return Distance(
      toSupportPercent: (json['to_support_percent'] as num).toDouble(),
      toResistancePercent: (json['to_resistance_percent'] as num).toDouble(),
    );
  }
}
```

---

## 🔮 Futures Data

```dart
class FuturesData {
  final double markPrice;
  final double indexPrice;
  final double fundingRate;
  final String nextFundingTime;
  final double openInterest;
  final double liquidationPrice;

  FuturesData({
    required this.markPrice,
    required this.indexPrice,
    required this.fundingRate,
    required this.nextFundingTime,
    required this.openInterest,
    required this.liquidationPrice,
  });

  factory FuturesData.fromJson(Map<String, dynamic> json) {
    return FuturesData(
      markPrice: (json['mark_price'] as num).toDouble(),
      indexPrice: (json['index_price'] as num).toDouble(),
      fundingRate: (json['funding_rate'] as num).toDouble(),
      nextFundingTime: json['next_funding_time'],
      openInterest: (json['open_interest'] as num).toDouble(),
      liquidationPrice: (json['liquidation_price'] as num).toDouble(),
    );
  }
}
```

---

## 🏥 Health Response

```dart
class HealthResponse {
  final String status;
  final bool gctConnected;
  final int toolsCount;

  HealthResponse({
    required this.status,
    required this.gctConnected,
    required this.toolsCount,
  });

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(
      status: json['status'],
      gctConnected: json['gct_connected'] ?? false,
      toolsCount: json['tools_count'] ?? 0,
    );
  }

  bool get isHealthy => status == 'ok';
}
```

---

## 🤖 Bot Status

```dart
class BotStatus {
  final bool aiEnabled;
  final String status;

  BotStatus({
    required this.aiEnabled,
    required this.status,
  });

  factory BotStatus.fromJson(Map<String, dynamic> json) {
    return BotStatus(
      aiEnabled: json['ai_enabled'],
      status: json['status'],
    );
  }

  bool get isActive => aiEnabled && status == 'ok';
}
```

---

## 📍 Position

```dart
class Position {
  final String id;
  final String symbol;
  final String side; // "long" or "short"
  final double entryPrice;
  final double currentPrice;
  final double size;
  final int leverage;
  final double unrealizedPnl;
  final double unrealizedPnlPercent;
  final double? stopLoss;
  final double? takeProfit;

  Position({
    required this.id,
    required this.symbol,
    required this.side,
    required this.entryPrice,
    required this.currentPrice,
    required this.size,
    required this.leverage,
    required this.unrealizedPnl,
    required this.unrealizedPnlPercent,
    this.stopLoss,
    this.takeProfit,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'],
      symbol: json['symbol'],
      side: json['side'],
      entryPrice: (json['entry_price'] as num).toDouble(),
      currentPrice: (json['current_price'] as num).toDouble(),
      size: (json['size'] as num).toDouble(),
      leverage: json['leverage'],
      unrealizedPnl: (json['unrealized_pnl'] as num).toDouble(),
      unrealizedPnlPercent: (json['unrealized_pnl_percent'] as num).toDouble(),
      stopLoss: json['stop_loss'] != null 
          ? (json['stop_loss'] as num).toDouble() 
          : null,
      takeProfit: json['take_profit'] != null 
          ? (json['take_profit'] as num).toDouble() 
          : null,
    );
  }

  bool get isLong => side == 'long';
  bool get isShort => side == 'short';
  bool get isProfitable => unrealizedPnl > 0;
}
```

---

## 🎨 Uso en UI

```dart
// Ejemplo de uso
class MarketAnalysisScreen extends StatelessWidget {
  final ComprehensiveAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Precio
        Text('\$${analysis.currentPrice.current.toStringAsFixed(2)}'),
        
        // Recomendación
        Container(
          color: analysis.recommendation.isBuy ? Colors.green :
                 analysis.recommendation.isSell ? Colors.red : Colors.grey,
          child: Text(analysis.recommendation.action),
        ),
        
        // Confianza
        LinearProgressIndicator(
          value: analysis.recommendation.confidence,
        ),
        
        // RSI
        Text('RSI 15m: ${analysis.multiTimeframe.tf15m.rsi.toStringAsFixed(2)}'),
        
        // Niveles
        Text('Support: \$${analysis.keyLevels.support}'),
        Text('Resistance: \$${analysis.keyLevels.resistance}'),
      ],
    );
  }
}
```

---

**Todos los modelos están listos para copiar y usar en tu proyecto Flutter**
