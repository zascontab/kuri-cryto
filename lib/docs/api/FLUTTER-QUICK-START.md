# 🚀 Flutter Quick Start - Trading MCP Server

**For**: Flutter Development Team  
**Date**: 19 November 2025  
**Status**: Ready for Integration

---

## 📋 Prerequisites

1. Flutter app on same network as server
2. Server IP: `192.168.1.6`
3. Dio package installed: `dio: ^5.0.0`

---

## ⚡ 5-Minute Setup

### Step 1: Add Dependencies

```yaml
# pubspec.yaml
dependencies:
  dio: ^5.0.0
  json_annotation: ^4.8.0

dev_dependencies:
  json_serializable: ^6.6.0
  build_runner: ^2.4.0
```

### Step 2: Create API Config

```dart
// lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'http://192.168.1.6:9090';
  static const String mcpServerUrl = 'http://192.168.1.6:10600';
  static const String scalpingUrl = 'http://192.168.1.6:8081';
}
```

### Step 3: Test Connection

```dart
// lib/services/api_test.dart
import 'package:dio/dio.dart';
import '../config/api_config.dart';

Future<void> testConnection() async {
  final dio = Dio();
  
  try {
    // Test health
    final response = await dio.get('${ApiConfig.baseUrl}/health');
    print('✅ Server connected: ${response.data}');
    
    // Test AI Bot
    final aiStatus = await dio.get('${ApiConfig.mcpServerUrl}/api/v1/ai-bot/status');
    print('✅ AI Bot status: ${aiStatus.data}');
    
  } catch (e) {
    print('❌ Connection failed: $e');
  }
}
```

---

## 🎯 Essential Endpoints

### 1. Get Market Price

```dart
Future<double> getBTCPrice() async {
  final dio = Dio();
  final response = await dio.post(
    '${ApiConfig.baseUrl}/api/mcp/tools/execute',
    data: {
      'jsonrpc': '2.0',
      'method': 'tools/call',
      'params': {
        'name': 'get_ticker',
        'arguments': {
          'exchange': 'kucoin',
          'pair': 'BTC-USDT'
        }
      },
      'id': 1,
    },
  );
  
  return response.data['result']['last'];
}
```

**Usage**:
```dart
final price = await getBTCPrice();
print('BTC Price: \$$price'); // BTC Price: $90638.1
```

---

### 2. AI Market Analysis

```dart
Future<Map<String, dynamic>> analyzeMarket(String pair) async {
  final dio = Dio();
  final response = await dio.post(
    '${ApiConfig.mcpServerUrl}/api/v1/ai-bot/analyze',
    data: {
      'pair': pair,
      'exchange': 'kucoin',
    },
  );
  
  return response.data;
}
```

**Usage**:
```dart
final analysis = await analyzeMarket('DOGE-USDT');
print('Action: ${analysis['action']}');
print('Confidence: ${analysis['confidence']}');
```

---

### 3. Get AI Positions

```dart
Future<List<dynamic>> getAIPositions() async {
  final dio = Dio();
  final response = await dio.get(
    '${ApiConfig.mcpServerUrl}/api/v1/ai-bot/positions',
  );
  
  return response.data['positions'];
}
```

**Usage**:
```dart
final positions = await getAIPositions();
print('Open positions: ${positions.length}');
```

---

### 4. Calculate RSI

```dart
Future<double> calculateRSI(String pair) async {
  final dio = Dio();
  final response = await dio.post(
    '${ApiConfig.baseUrl}/api/mcp/tools/execute',
    data: {
      'jsonrpc': '2.0',
      'method': 'tools/call',
      'params': {
        'name': 'calculate_rsi',
        'arguments': {
          'exchange': 'kucoin',
          'pair': pair,
          'interval': '5m',
          'period': 14,
        }
      },
      'id': 1,
    },
  );
  
  return response.data['result']['rsi'];
}
```

**Usage**:
```dart
final rsi = await calculateRSI('BTC-USDT');
if (rsi > 70) {
  print('⚠️ Overbought');
} else if (rsi < 30) {
  print('✅ Oversold - Buy opportunity');
}
```

---

### 5. Execute Trade

```dart
Future<String> executeTrade({
  required String pair,
  required String side, // 'buy' or 'sell'
  required double amountUsd,
  int leverage = 1,
}) async {
  final dio = Dio();
  final response = await dio.post(
    '${ApiConfig.baseUrl}/api/mcp/tools/execute',
    data: {
      'jsonrpc': '2.0',
      'method': 'tools/call',
      'params': {
        'name': 'execute_scalping_trade',
        'arguments': {
          'exchange': 'kucoin',
          'pair': pair,
          'side': side,
          'amount_usd': amountUsd,
          'leverage': leverage,
        }
      },
      'id': 1,
    },
  );
  
  return response.data['result']['order_id'];
}
```

**Usage**:
```dart
final orderId = await executeTrade(
  pair: 'DOGE-USDT',
  side: 'buy',
  amountUsd: 10.0,
  leverage: 5,
);
print('Order placed: $orderId');
```

---

### 6. Get Futures Positions

```dart
Future<List<Map<String, dynamic>>> getFuturesPositions() async {
  final dio = Dio();
  final response = await dio.post(
    '${ApiConfig.baseUrl}/api/mcp/tools/execute',
    data: {
      'jsonrpc': '2.0',
      'method': 'tools/call',
      'params': {
        'name': 'get_futures_positions',
        'arguments': {
          'exchange': 'kucoin',
        }
      },
      'id': 1,
    },
  );
  
  return List<Map<String, dynamic>>.from(
    response.data['result']['positions']
  );
}
```

**Usage**:
```dart
final positions = await getFuturesPositions();
for (var pos in positions) {
  print('${pos['symbol']}: ${pos['side']} ${pos['size']} contracts');
  print('PnL: \$${pos['unrealized_pnl'].toStringAsFixed(2)}');
}
```

---

### 7. Close Futures Position

```dart
Future<Map<String, dynamic>> closeFuturesPosition(String symbol) async {
  final dio = Dio();
  final response = await dio.post(
    '${ApiConfig.baseUrl}/api/mcp/tools/execute',
    data: {
      'jsonrpc': '2.0',
      'method': 'tools/call',
      'params': {
        'name': 'close_futures_position',
        'arguments': {
          'exchange': 'kucoin',
          'symbol': symbol, // e.g., 'DOGEUSDTM', 'BTCUSDTM'
        }
      },
      'id': 1,
    },
  );
  
  return response.data['result'];
}
```

**Usage**:
```dart
// Close entire position in one call
final result = await closeFuturesPosition('DOGEUSDTM');
print('Position closed');
print('Total PnL: \$${result['total_pnl'].toStringAsFixed(2)}');
print('Exit price: \$${result['exit_price']}');
```

**Important Notes**:
- ✅ Closes the **entire position** in a single call
- ✅ Uses reduce-only market order (safe)
- ✅ Returns final PnL and execution details
- ⚠️ Symbol must be futures format: `DOGEUSDTM`, `BTCUSDTM` (not `DOGE-USDT`)

---

## 🎨 UI Examples

### Price Display Widget

```dart
class PriceWidget extends StatefulWidget {
  final String pair;
  
  const PriceWidget({required this.pair});
  
  @override
  State<PriceWidget> createState() => _PriceWidgetState();
}

class _PriceWidgetState extends State<PriceWidget> {
  double? price;
  bool loading = true;
  
  @override
  void initState() {
    super.initState();
    loadPrice();
  }
  
  Future<void> loadPrice() async {
    final dio = Dio();
    final response = await dio.post(
      '${ApiConfig.baseUrl}/api/mcp/tools/execute',
      data: {
        'jsonrpc': '2.0',
        'method': 'tools/call',
        'params': {
          'name': 'get_ticker',
          'arguments': {
            'exchange': 'kucoin',
            'pair': widget.pair,
          }
        },
        'id': 1,
      },
    );
    
    setState(() {
      price = response.data['result']['last'];
      loading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return CircularProgressIndicator();
    }
    
    return Text(
      '\$${price?.toStringAsFixed(2)}',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
```

---

### AI Analysis Card

```dart
class AIAnalysisCard extends StatelessWidget {
  final String pair;
  
  const AIAnalysisCard({required this.pair});
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: analyzeMarket(pair),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        
        final analysis = snapshot.data!;
        final action = analysis['action'];
        final confidence = analysis['confidence'];
        
        Color actionColor;
        IconData actionIcon;
        
        switch (action) {
          case 'BUY':
            actionColor = Colors.green;
            actionIcon = Icons.arrow_upward;
            break;
          case 'SELL':
            actionColor = Colors.red;
            actionIcon = Icons.arrow_downward;
            break;
          default:
            actionColor = Colors.orange;
            actionIcon = Icons.pause;
        }
        
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(actionIcon, size: 48, color: actionColor),
                SizedBox(height: 8),
                Text(
                  action,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: actionColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Confidence: ${(confidence * 100).toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

---

### RSI Indicator Widget

```dart
class RSIIndicator extends StatelessWidget {
  final String pair;
  
  const RSIIndicator({required this.pair});
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: calculateRSI(pair),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        
        final rsi = snapshot.data!;
        Color color;
        String status;
        
        if (rsi > 70) {
          color = Colors.red;
          status = 'Overbought';
        } else if (rsi < 30) {
          color = Colors.green;
          status = 'Oversold';
        } else {
          color = Colors.blue;
          status = 'Neutral';
        }
        
        return Column(
          children: [
            Text('RSI (14)', style: TextStyle(fontSize: 12)),
            SizedBox(height: 4),
            Text(
              rsi.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              status,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ],
        );
      },
    );
  }
}
```

---

## 🔄 Real-Time Updates

### Polling Example (Simple)

```dart
class PriceStream extends StatefulWidget {
  final String pair;
  
  const PriceStream({required this.pair});
  
  @override
  State<PriceStream> createState() => _PriceStreamState();
}

class _PriceStreamState extends State<PriceStream> {
  double? price;
  Timer? timer;
  
  @override
  void initState() {
    super.initState();
    updatePrice();
    timer = Timer.periodic(Duration(seconds: 5), (_) => updatePrice());
  }
  
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  
  Future<void> updatePrice() async {
    final dio = Dio();
    final response = await dio.post(
      '${ApiConfig.baseUrl}/api/mcp/tools/execute',
      data: {
        'jsonrpc': '2.0',
        'method': 'tools/call',
        'params': {
          'name': 'get_ticker',
          'arguments': {
            'exchange': 'kucoin',
            'pair': widget.pair,
          }
        },
        'id': 1,
      },
    );
    
    setState(() {
      price = response.data['result']['last'];
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Text(
      price != null ? '\$${price!.toStringAsFixed(2)}' : 'Loading...',
      style: TextStyle(fontSize: 24),
    );
  }
}
```

---

## 🛡️ Error Handling

```dart
class ApiService {
  final Dio _dio = Dio();
  
  Future<T> handleRequest<T>(Future<Response> Function() request) async {
    try {
      final response = await request();
      return response.data as T;
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          message: error['error'] ?? 'Unknown error',
          details: error['details'],
          statusCode: e.response!.statusCode,
        );
      } else {
        throw ApiException(
          message: 'Network error',
          details: e.message,
        );
      }
    }
  }
}

class ApiException implements Exception {
  final String message;
  final String? details;
  final int? statusCode;
  
  ApiException({
    required this.message,
    this.details,
    this.statusCode,
  });
  
  @override
  String toString() => 'ApiException: $message';
}
```

**Usage**:
```dart
try {
  final price = await getBTCPrice();
  print('Price: \$$price');
} on ApiException catch (e) {
  print('Error: ${e.message}');
  if (e.details != null) {
    print('Details: ${e.details}');
  }
}
```

---

## 📱 Complete Example App

```dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(TradingApp());
}

class TradingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trading App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TradingHomePage(),
    );
  }
}

class TradingHomePage extends StatefulWidget {
  @override
  State<TradingHomePage> createState() => _TradingHomePageState();
}

class _TradingHomePageState extends State<TradingHomePage> {
  final dio = Dio();
  String selectedPair = 'BTC-USDT';
  double? price;
  double? rsi;
  Map<String, dynamic>? aiAnalysis;
  bool loading = true;
  
  @override
  void initState() {
    super.initState();
    loadData();
  }
  
  Future<void> loadData() async {
    setState(() => loading = true);
    
    try {
      // Get price
      final priceResponse = await dio.post(
        'http://192.168.1.6:9090/api/mcp/tools/execute',
        data: {
          'jsonrpc': '2.0',
          'method': 'tools/call',
          'params': {
            'name': 'get_ticker',
            'arguments': {
              'exchange': 'kucoin',
              'pair': selectedPair,
            }
          },
          'id': 1,
        },
      );
      
      // Get RSI
      final rsiResponse = await dio.post(
        'http://192.168.1.6:9090/api/mcp/tools/execute',
        data: {
          'jsonrpc': '2.0',
          'method': 'tools/call',
          'params': {
            'name': 'calculate_rsi',
            'arguments': {
              'exchange': 'kucoin',
              'pair': selectedPair,
              'interval': '5m',
              'period': 14,
            }
          },
          'id': 2,
        },
      );
      
      // Get AI analysis
      final aiResponse = await dio.post(
        'http://192.168.1.6:10600/api/v1/ai-bot/analyze',
        data: {
          'pair': selectedPair,
          'exchange': 'kucoin',
        },
      );
      
      setState(() {
        price = priceResponse.data['result']['last'];
        rsi = rsiResponse.data['result']['rsi'];
        aiAnalysis = aiResponse.data;
        loading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => loading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trading Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadData,
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pair selector
                  DropdownButton<String>(
                    value: selectedPair,
                    items: ['BTC-USDT', 'ETH-USDT', 'DOGE-USDT']
                        .map((pair) => DropdownMenuItem(
                              value: pair,
                              child: Text(pair),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedPair = value!);
                      loadData();
                    },
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Price card
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('Current Price', style: TextStyle(fontSize: 16)),
                          SizedBox(height: 8),
                          Text(
                            '\$${price?.toStringAsFixed(2) ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // RSI card
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('RSI (14)', style: TextStyle(fontSize: 16)),
                          SizedBox(height: 8),
                          Text(
                            rsi?.toStringAsFixed(2) ?? 'N/A',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: rsi != null
                                  ? (rsi! > 70
                                      ? Colors.red
                                      : rsi! < 30
                                          ? Colors.green
                                          : Colors.blue)
                                  : Colors.grey,
                            ),
                          ),
                          Text(
                            rsi != null
                                ? (rsi! > 70
                                    ? 'Overbought'
                                    : rsi! < 30
                                        ? 'Oversold'
                                        : 'Neutral')
                                : '',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // AI Analysis card
                  if (aiAnalysis != null)
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text('AI Analysis', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text(
                              aiAnalysis!['action'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: aiAnalysis!['action'] == 'BUY'
                                    ? Colors.green
                                    : aiAnalysis!['action'] == 'SELL'
                                        ? Colors.red
                                        : Colors.orange,
                              ),
                            ),
                            if (aiAnalysis!['message'] != null)
                              Text(
                                aiAnalysis!['message'],
                                style: TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
```

---

## ✅ Testing Checklist

- [ ] Test connection to server
- [ ] Get BTC price successfully
- [ ] Calculate RSI for any pair
- [ ] Get AI analysis
- [ ] Display data in UI
- [ ] Handle errors gracefully
- [ ] Test on real device (not emulator)
- [ ] Verify network connectivity

---

## 📚 Next Steps

1. **Read**: `FLUTTER-API-INTEGRATION-GUIDE.md` for complete API reference
2. **Check**: `ENDPOINT-TEST-RESULTS.md` for test results
3. **Implement**: Basic price display
4. **Add**: AI analysis feature
5. **Test**: On real device

---

## 🆘 Troubleshooting

### Can't connect to server
```dart
// Test with curl first
// curl http://192.168.1.6:9090/health

// Check if device is on same network
// Ping: ping 192.168.1.6
```

### Timeout errors
```dart
final dio = Dio(BaseOptions(
  connectTimeout: Duration(seconds: 10),
  receiveTimeout: Duration(seconds: 30),
));
```

### CORS errors
Not applicable - server has CORS enabled

---

## 📞 Support

- **Full API Docs**: `docs/FLUTTER-API-INTEGRATION-GUIDE.md`
- **Test Results**: `docs/ENDPOINT-TEST-RESULTS.md`
- **Server Status**: http://192.168.1.6:9090/health

---

**Ready to start! 🚀**
