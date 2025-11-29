# 💡 Ejemplos Completos de Implementación

**Código listo para copiar y usar**

---

## 📱 App Completa Mínima

### main.dart

```dart
import 'package:flutter/material.dart';
import 'trading_api_client.dart';
import 'models.dart';

void main() {
  runApp(TradingApp());
}

class TradingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trading App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MarketAnalysisScreen(),
    );
  }
}
```

---

## 🔌 Cliente API Completo

### trading_api_client.dart

```dart
import 'package:dio/dio.dart';
import 'models.dart';

class TradingApiClient {
  final Dio _dio;
  
  TradingApiClient({String? baseUrl}) 
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? 'http://192.168.100.145:10600',
          connectTimeout: Duration(seconds: 30),
          receiveTimeout: Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        )) {
    // Agregar interceptor para logging en debug
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('[API] $obj'),
    ));
  }

  // Health Check
  Future<HealthResponse> getHealth() async {
    try {
      final response = await _dio.get('/health');
      return HealthResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Bot Status
  Future<BotStatus> getBotStatus() async {
    try {
      final response = await _dio.get('/api/v1/ai-bot/status');
      return BotStatus.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Comprehensive Analysis
  Future<ComprehensiveAnalysis> getComprehensiveAnalysis({
    required String symbol,
    String exchange = 'kucoin',
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/ai-bot/comprehensive-analysis',
        data: {
          'symbol': symbol,
          'exchange': exchange,
        },
      );
      return ComprehensiveAnalysis.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get Positions
  Future<List<Position>> getPositions() async {
    try {
      final response = await _dio.get('/api/v1/ai-bot/positions');
      final positions = response.data['positions'] as List;
      return positions.map((p) => Position.fromJson(p)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Start Bot
  Future<Map<String, dynamic>> startBot() async {
    try {
      final response = await _dio.post('/api/v1/ai-bot/start');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Stop Bot
  Future<Map<String, dynamic>> stopBot() async {
    try {
      final response = await _dio.post('/api/v1/ai-bot/stop');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Error Handler
  String _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Timeout de conexión';
        case DioExceptionType.receiveTimeout:
          return 'Timeout recibiendo datos';
        case DioExceptionType.badResponse:
          return 'Error del servidor: ${error.response?.statusCode}';
        case DioExceptionType.connectionError:
          return 'Error de conexión';
        default:
          return 'Error desconocido: ${error.message}';
      }
    }
    return error.toString();
  }
}
```

---

## 📊 Pantalla de Análisis

### market_analysis_screen.dart

```dart
import 'package:flutter/material.dart';
import 'trading_api_client.dart';
import 'models.dart';

class MarketAnalysisScreen extends StatefulWidget {
  @override
  _MarketAnalysisScreenState createState() => _MarketAnalysisScreenState();
}

class _MarketAnalysisScreenState extends State<MarketAnalysisScreen> {
  final TradingApiClient _client = TradingApiClient();
  ComprehensiveAnalysis? _analysis;
  bool _loading = false;
  String? _error;
  String _selectedSymbol = 'BTC-USDT';

  final List<String> _symbols = [
    'BTC-USDT',
    'ETH-USDT',
    'DOGE-USDT',
    'SOL-USDT',
    'XRP-USDT',
  ];

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final analysis = await _client.getComprehensiveAnalysis(
        symbol: _selectedSymbol,
      );
      setState(() {
        _analysis = analysis;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Análisis de Mercado'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadAnalysis,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Error: $_error'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAnalysis,
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_analysis == null) {
      return Center(child: Text('No hay datos'));
    }

    return RefreshIndicator(
      onRefresh: _loadAnalysis,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSymbolSelector(),
          SizedBox(height: 16),
          _buildPriceCard(),
          SizedBox(height: 16),
          _buildRecommendationCard(),
          SizedBox(height: 16),
          _buildIndicatorsCard(),
          SizedBox(height: 16),
          _buildLevelsCard(),
        ],
      ),
    );
  }

  Widget _buildSymbolSelector() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: DropdownButton<String>(
          value: _selectedSymbol,
          isExpanded: true,
          items: _symbols.map((symbol) {
            return DropdownMenuItem(
              value: symbol,
              child: Text(symbol),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedSymbol = value);
              _loadAnalysis();
            }
          },
        ),
      ),
    );
  }

  Widget _buildPriceCard() {
    final price = _analysis!.currentPrice;
    final isPositive = price.change24h >= 0;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '\$${price.current.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                Text(
                  '${price.change24h.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 24,
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriceInfo('High', price.high24h),
                _buildPriceInfo('Low', price.low24h),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInfo(String label, double value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey)),
        Text('\$${value.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildRecommendationCard() {
    final rec = _analysis!.recommendation;
    Color color;
    IconData icon;

    switch (rec.action) {
      case 'BUY':
        color = Colors.green;
        icon = Icons.trending_up;
        break;
      case 'SELL':
        color = Colors.red;
        icon = Icons.trending_down;
        break;
      default:
        color = Colors.grey;
        icon = Icons.remove;
    }

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: color),
                SizedBox(width: 8),
                Text(
                  rec.action,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Confianza: ${(rec.confidence * 100).toInt()}%',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: rec.confidence,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            SizedBox(height: 16),
            ...rec.reasoning.map((reason) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: color),
                  SizedBox(width: 8),
                  Expanded(child: Text(reason)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorsCard() {
    final tf = _analysis!.multiTimeframe;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Indicadores Técnicos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildTimeframeRow('15m', tf.tf15m),
            Divider(),
            _buildTimeframeRow('5m', tf.tf5m),
            Divider(),
            _buildTimeframeRow('1h', tf.tf1h),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  tf.isAligned ? Icons.check_circle : Icons.warning,
                  color: tf.isAligned ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 8),
                Text(
                  tf.isAligned ? 'Tendencias alineadas' : 'Tendencias no alineadas',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeframeRow(String label, TimeframeData data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        Text('RSI: ${data.rsi.toStringAsFixed(2)}'),
        Chip(
          label: Text(data.trend),
          backgroundColor: data.isBullish ? Colors.green.withOpacity(0.2) :
                          data.isBearish ? Colors.red.withOpacity(0.2) :
                          Colors.grey.withOpacity(0.2),
        ),
      ],
    );
  }

  Widget _buildLevelsCard() {
    final levels = _analysis!.keyLevels;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Niveles Clave',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('Soporte', style: TextStyle(color: Colors.grey)),
                    Text(
                      '\$${levels.support.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      '${levels.distance.toSupportPercent.toStringAsFixed(2)}%',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text('Resistencia', style: TextStyle(color: Colors.grey)),
                    Text(
                      '\$${levels.resistance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      '${levels.distance.toResistancePercent.toStringAsFixed(2)}%',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🎯 Uso

1. Copiar todos los archivos a tu proyecto
2. Agregar `dio` en `pubspec.yaml`
3. Importar los modelos de `06-MODELOS-DATOS.md`
4. Ejecutar la app

---

**La app está lista para funcionar inmediatamente**
