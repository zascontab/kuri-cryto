# Ejemplos de Uso - Modelos de Datos

Este documento proporciona ejemplos prácticos de cómo usar los modelos en escenarios reales.

---

## Escenario 1: Monitoreo de Posiciones Activas

```dart
import 'package:kuri_crypto/models/models.dart';

// Obtener posiciones desde la API
Future<List<Position>> getActivePositions() async {
  final response = await dio.get('/api/v1/scalping/positions');
  final data = response.data['data'] as List;

  return data.map((json) => Position.fromJson(json)).toList();
}

// Filtrar posiciones rentables
void analyzePositions() async {
  final positions = await getActivePositions();

  // Posiciones rentables
  final profitable = positions.where((p) => p.isProfitable).toList();
  print('Profitable positions: ${profitable.length}');

  // Calcular P&L total
  final totalPnl = positions.fold(0.0, (sum, p) => sum + p.unrealizedPnl);
  print('Total unrealized P&L: \$${totalPnl.toStringAsFixed(2)}');

  // Posiciones con mejor performance
  final bestPosition = positions.reduce(
    (a, b) => a.calculatePnlPercentage() > b.calculatePnlPercentage() ? a : b
  );
  print('Best position: ${bestPosition.symbol} (${bestPosition.calculatePnlPercentage()}%)');

  // Alertar sobre posiciones cercanas al stop loss
  for (final position in positions) {
    if (position.stopLoss != null) {
      final distanceToSL = ((position.currentPrice - position.stopLoss!) /
                            position.currentPrice * 100).abs();
      if (distanceToSL < 5.0) {
        print('⚠️ Position ${position.symbol} is ${distanceToSL.toStringAsFixed(2)}% from stop loss');
      }
    }
  }
}
```

---

## Escenario 2: Sistema de Gestión de Riesgo

```dart
import 'package:kuri_crypto/models/models.dart';

class RiskManager {
  RiskState? currentState;

  Future<void> updateRiskState() async {
    final response = await dio.get('/api/v1/risk/sentinel/state');
    currentState = RiskState.fromJson(response.data['data']);
  }

  bool canOpenNewPosition(double positionSize, String symbol) {
    if (currentState == null) return false;

    // Check if trading is allowed
    if (!currentState!.canTrade()) {
      print('❌ Trading disabled by risk controls');
      return false;
    }

    // Check if we have enough exposure available
    final availableExposure = currentState!.getAvailableExposure();
    if (positionSize > availableExposure) {
      print('❌ Insufficient exposure available: \$${availableExposure.toStringAsFixed(2)}');
      return false;
    }

    // Check risk level
    if (currentState!.isHighRisk()) {
      print('⚠️ System is in high risk state (${currentState!.getRiskLevel()}%)');
      // Podríamos permitir pero con tamaño reducido
      return positionSize <= (availableExposure * 0.5);
    }

    return true;
  }

  void displayRiskDashboard() {
    if (currentState == null) return;

    print('\n📊 RISK DASHBOARD');
    print('═' * 50);
    print('Risk Mode: ${currentState!.riskMode}');
    print('Risk Level: ${currentState!.getRiskLevel().toStringAsFixed(1)}%');
    print('Kill Switch: ${currentState!.killSwitchActive ? "🔴 ACTIVE" : "🟢 Inactive"}');
    print('\nDrawdowns:');
    print('  Daily: ${currentState!.currentDrawdownDaily.toStringAsFixed(2)}%');
    print('  Weekly: ${currentState!.currentDrawdownWeekly.toStringAsFixed(2)}%');
    print('  Monthly: ${currentState!.currentDrawdownMonthly.toStringAsFixed(2)}%');
    print('\nExposure:');
    print('  Total: \$${currentState!.totalExposure.toStringAsFixed(2)}');
    print('  Available: \$${currentState!.getAvailableExposure().toStringAsFixed(2)}');
    print('  Usage: ${currentState!.getExposurePercentage().toStringAsFixed(1)}%');
    print('\nBy Symbol:');
    currentState!.exposureBySymbol.forEach((symbol, exposure) {
      print('  $symbol: \$${exposure.toStringAsFixed(2)}');
    });
    print('═' * 50 + '\n');
  }
}
```

---

## Escenario 3: Análisis de Estrategias

```dart
import 'package:kuri_crypto/models/models.dart';

class StrategyAnalyzer {
  List<Strategy> strategies = [];

  Future<void> loadStrategies() async {
    final response = await dio.get('/api/v1/scalping/strategies');
    final data = response.data['data'] as List;
    strategies = data.map((json) => Strategy.fromJson(json)).toList();
  }

  void analyzeStrategies() {
    print('\n📈 STRATEGY ANALYSIS');
    print('═' * 70);

    // Filtrar estrategias activas
    final activeStrategies = strategies.where((s) => s.active).toList();
    print('Active strategies: ${activeStrategies.length}/${strategies.length}\n');

    // Ordenar por performance
    final sortedByPnl = [...strategies]
      ..sort((a, b) => b.performance.totalPnl.compareTo(a.performance.totalPnl));

    print('Top Performers:');
    for (var i = 0; i < sortedByPnl.take(5).length; i++) {
      final strategy = sortedByPnl[i];
      final perf = strategy.performance;

      print('${i + 1}. ${strategy.name}');
      print('   Active: ${strategy.active ? "✅" : "❌"} | '
            'Weight: ${(strategy.weight * 100).toStringAsFixed(1)}%');
      print('   Trades: ${perf.totalTrades} | '
            'Win Rate: ${perf.winRate.toStringAsFixed(1)}%');
      print('   Total P&L: \$${perf.totalPnl.toStringAsFixed(2)} | '
            'Sharpe: ${perf.sharpeRatio.toStringAsFixed(2)}');

      // Warnings
      if (!strategy.isPerformingWell) {
        print('   ⚠️ Poor performance detected');
      }
      if (!strategy.hasSufficientData) {
        print('   ⚠️ Insufficient data (<10 trades)');
      }
      print('');
    }

    // Calcular métricas agregadas
    final totalWeight = activeStrategies.fold(0.0, (sum, s) => sum + s.weight);
    final avgWinRate = activeStrategies.fold(0.0, (sum, s) =>
      sum + (s.performance.winRate * s.weight)) / totalWeight;
    final totalPnl = strategies.fold(0.0, (sum, s) => sum + s.performance.totalPnl);

    print('═' * 70);
    print('Portfolio Stats:');
    print('  Weighted Avg Win Rate: ${avgWinRate.toStringAsFixed(1)}%');
    print('  Total P&L: \$${totalPnl.toStringAsFixed(2)}');
    print('  Total Weight: ${(totalWeight * 100).toStringAsFixed(1)}%');
    print('═' * 70 + '\n');
  }

  Future<void> optimizeWeights() async {
    // Ajustar pesos basado en performance
    final performingWell = strategies
      .where((s) => s.isPerformingWell && s.hasSufficientData)
      .toList();

    if (performingWell.isEmpty) {
      print('No strategies performing well');
      return;
    }

    // Calcular nuevo peso basado en Sharpe ratio
    final totalSharpe = performingWell.fold(
      0.0,
      (sum, s) => sum + s.performance.sharpeRatio
    );

    for (final strategy in performingWell) {
      final newWeight = strategy.performance.sharpeRatio / totalSharpe;
      final updated = strategy.copyWith(weight: newWeight);

      // Actualizar en servidor
      await dio.put(
        '/api/v1/scalping/strategies/${strategy.name}/config',
        data: {'weight': newWeight},
      );

      print('Updated ${strategy.name}: ${(newWeight * 100).toStringAsFixed(1)}%');
    }
  }
}
```

---

## Escenario 4: Dashboard de Métricas en Tiempo Real

```dart
import 'package:kuri_crypto/models/models.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TradingDashboard {
  Metrics? currentMetrics;
  SystemStatus? systemStatus;
  WebSocketChannel? wsChannel;

  void connectWebSocket() {
    wsChannel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8081/ws'),
    );

    // Subscribe to updates
    wsChannel!.sink.add(jsonEncode({
      'action': 'subscribe',
      'channels': ['metrics', 'positions', 'trades'],
    }));

    // Listen to updates
    wsChannel!.stream.listen((message) {
      final data = jsonDecode(message);

      switch (data['type']) {
        case 'metrics_update':
          currentMetrics = Metrics.fromJson(data['data']);
          displayMetrics();
          break;
        case 'position_update':
          // Handle position update
          break;
        case 'trade_executed':
          final trade = Trade.fromJson(data['data']);
          handleTradeExecuted(trade);
          break;
      }
    });
  }

  Future<void> fetchInitialData() async {
    // Obtener métricas
    final metricsResponse = await dio.get('/api/v1/scalping/metrics');
    currentMetrics = Metrics.fromJson(metricsResponse.data['data']);

    // Obtener estado del sistema
    final statusResponse = await dio.get('/api/v1/scalping/status');
    systemStatus = SystemStatus.fromJson(statusResponse.data['data']);
  }

  void displayMetrics() {
    if (currentMetrics == null || systemStatus == null) return;

    print('\n' + '═' * 80);
    print('🚀 TRADING DASHBOARD'.padLeft(45));
    print('═' * 80);

    // System Status
    print('\nSYSTEM STATUS:');
    print('  Engine: ${systemStatus!.running ? "🟢 Running" : "🔴 Stopped"}');
    print('  Health: ${_getHealthEmoji(systemStatus!.healthStatus)} '
          '${systemStatus!.healthStatus.toUpperCase()}');
    print('  Uptime: ${systemStatus!.uptime}');
    print('  Pairs: ${systemStatus!.pairsCount} | '
          'Strategies: ${systemStatus!.activeStrategies}');

    if (systemStatus!.hasErrors) {
      print('  Errors:');
      for (final error in systemStatus!.errors) {
        print('    ⚠️ $error');
      }
    }

    // Performance Metrics
    print('\nPERFORMANCE:');
    final m = currentMetrics!;
    print('  Total Trades: ${m.totalTrades}');
    print('  Win Rate: ${m.winRate.toStringAsFixed(1)}% '
          '(${m.winningTrades}W / ${m.losingTrades}L)');
    print('  Win/Loss Ratio: ${m.winLossRatio.toStringAsFixed(2)}:1');

    // P&L
    print('\nPROFIT & LOSS:');
    print('  Total: ${_formatPnl(m.totalPnl)}');
    print('  Daily: ${_formatPnl(m.dailyPnl)}');
    print('  Weekly: ${_formatPnl(m.weeklyPnl)}');
    print('  Monthly: ${_formatPnl(m.monthlyPnl)}');

    // Risk Metrics
    print('\nRISK METRICS:');
    print('  Max Drawdown: ${m.maxDrawdown.toStringAsFixed(2)}%');
    print('  Sharpe Ratio: ${m.sharpeRatio.toStringAsFixed(2)}');
    print('  Profit Factor: ${m.profitFactor.toStringAsFixed(2)}');

    // Execution
    print('\nEXECUTION:');
    print('  Active Positions: ${m.activePositions}');
    print('  Avg Latency: ${m.avgLatencyMs.toStringAsFixed(0)}ms '
          '${m.hasFastExecution ? "⚡" : "🐌"}');
    print('  Avg Slippage: ${m.avgSlippagePct.toStringAsFixed(3)}%');

    // Status indicators
    print('\nSTATUS:');
    print('  Performance: ${m.isPerformingWell ? "✅ Good" : "⚠️ Poor"}');
    print('  Profitability: ${m.isProfitable ? "✅ Profitable" : "❌ Unprofitable"}');
    print('  Execution: ${m.hasFastExecution ? "✅ Fast" : "⚠️ Slow"}');

    print('═' * 80 + '\n');
  }

  void handleTradeExecuted(Trade trade) {
    final statusEmoji = trade.isFilled ? '✅' :
                       trade.isPending ? '⏳' : '❌';
    final sideEmoji = trade.isBuy ? '🟢' : '🔴';

    print('$statusEmoji $sideEmoji Trade: ${trade.symbol}');
    print('   ${trade.side.toUpperCase()} ${trade.size} @ \$${trade.price}');
    print('   Latency: ${trade.latencyMs.toStringAsFixed(0)}ms');

    if (trade.fee != null) {
      print('   Fee: \$${trade.fee!.toStringAsFixed(4)} ${trade.feeCurrency ?? ""}');
    }

    if (trade.slippagePct != null) {
      print('   Slippage: ${trade.slippagePct!.toStringAsFixed(3)}%');
    }
  }

  String _getHealthEmoji(String health) {
    switch (health.toLowerCase()) {
      case 'healthy': return '🟢';
      case 'degraded': return '🟡';
      case 'unhealthy': return '🔴';
      default: return '⚪';
    }
  }

  String _formatPnl(double pnl) {
    final sign = pnl >= 0 ? '+' : '';
    final emoji = pnl >= 0 ? '📈' : '📉';
    return '$emoji $sign\$${pnl.toStringAsFixed(2)}';
  }

  void dispose() {
    wsChannel?.sink.close();
  }
}
```

---

## Escenario 5: Historial y Análisis de Trades

```dart
import 'package:kuri_crypto/models/models.dart';

class TradeHistoryAnalyzer {
  Future<List<Trade>> fetchTradeHistory({
    int limit = 100,
    DateTime? from,
    DateTime? to,
  }) async {
    final params = {
      'limit': limit,
      if (from != null) 'from': from.toIso8601String(),
      if (to != null) 'to': to.toIso8601String(),
    };

    final response = await dio.get(
      '/api/v1/scalping/execution/history',
      queryParameters: params,
    );

    final data = response.data['data'] as List;
    return data.map((json) => Trade.fromJson(json)).toList();
  }

  Future<void> analyzeExecutionQuality() async {
    final trades = await fetchTradeHistory(limit: 500);
    final filledTrades = trades.where((t) => t.isFilled).toList();

    if (filledTrades.isEmpty) {
      print('No filled trades found');
      return;
    }

    print('\n📊 EXECUTION QUALITY ANALYSIS');
    print('═' * 70);
    print('Total trades analyzed: ${filledTrades.length}\n');

    // Latency analysis
    final latencies = filledTrades.map((t) => t.latencyMs).toList()..sort();
    final avgLatency = latencies.reduce((a, b) => a + b) / latencies.length;
    final medianLatency = latencies[latencies.length ~/ 2];
    final p95Latency = latencies[(latencies.length * 0.95).floor()];
    final p99Latency = latencies[(latencies.length * 0.99).floor()];

    print('LATENCY METRICS:');
    print('  Average: ${avgLatency.toStringAsFixed(2)}ms');
    print('  Median: ${medianLatency.toStringAsFixed(2)}ms');
    print('  P95: ${p95Latency.toStringAsFixed(2)}ms');
    print('  P99: ${p99Latency.toStringAsFixed(2)}ms');
    print('  Min: ${latencies.first.toStringAsFixed(2)}ms');
    print('  Max: ${latencies.last.toStringAsFixed(2)}ms');

    final fastTrades = filledTrades.where((t) => t.isFastExecution).length;
    print('  Fast trades (<100ms): ${fastTrades} '
          '(${(fastTrades / filledTrades.length * 100).toStringAsFixed(1)}%)\n');

    // Slippage analysis
    final tradesWithSlippage = filledTrades.where((t) => t.slippagePct != null).toList();
    if (tradesWithSlippage.isNotEmpty) {
      final slippages = tradesWithSlippage.map((t) => t.slippagePct!).toList();
      final avgSlippage = slippages.reduce((a, b) => a + b) / slippages.length;

      print('SLIPPAGE METRICS:');
      print('  Average: ${avgSlippage.toStringAsFixed(4)}%');
      print('  Max: ${slippages.reduce((a, b) => a > b ? a : b).toStringAsFixed(4)}%\n');
    }

    // Fee analysis
    final tradesWithFees = filledTrades.where((t) => t.fee != null).toList();
    if (tradesWithFees.isNotEmpty) {
      final totalFees = tradesWithFees.fold(0.0, (sum, t) => sum + t.fee!);
      final avgFee = totalFees / tradesWithFees.length;

      print('FEE METRICS:');
      print('  Total fees: \$${totalFees.toStringAsFixed(2)}');
      print('  Average fee: \$${avgFee.toStringAsFixed(4)}\n');
    }

    // Symbol breakdown
    final bySymbol = <String, List<Trade>>{};
    for (final trade in filledTrades) {
      bySymbol.putIfAbsent(trade.symbol, () => []).add(trade);
    }

    print('TRADES BY SYMBOL:');
    bySymbol.forEach((symbol, symbolTrades) {
      final avgSymbolLatency = symbolTrades
        .map((t) => t.latencyMs)
        .reduce((a, b) => a + b) / symbolTrades.length;

      print('  $symbol: ${symbolTrades.length} trades, '
            'avg latency: ${avgSymbolLatency.toStringAsFixed(0)}ms');
    });

    print('═' * 70 + '\n');
  }

  Future<void> findProblematicTrades() async {
    final trades = await fetchTradeHistory(limit: 200);

    print('\n⚠️ PROBLEMATIC TRADES ANALYSIS\n');

    // Failed trades
    final failed = trades.where((t) => t.isFailed).toList();
    if (failed.isNotEmpty) {
      print('FAILED/CANCELLED TRADES: ${failed.length}');
      for (final trade in failed.take(5)) {
        print('  ${trade.symbol} - ${trade.status} - '
              '${trade.timestamp.toIso8601String()}');
      }
      print('');
    }

    // Slow executions
    final slow = trades.where((t) => t.latencyMs > 200).toList();
    if (slow.isNotEmpty) {
      print('SLOW EXECUTIONS (>200ms): ${slow.length}');
      for (final trade in slow.take(5)) {
        print('  ${trade.symbol} - ${trade.latencyMs.toStringAsFixed(0)}ms - '
              '${trade.timestamp.toIso8601String()}');
      }
      print('');
    }

    // High slippage
    final highSlippage = trades
      .where((t) => t.slippagePct != null && t.slippagePct! > 0.1)
      .toList();
    if (highSlippage.isNotEmpty) {
      print('HIGH SLIPPAGE (>0.1%): ${highSlippage.length}');
      for (final trade in highSlippage.take(5)) {
        print('  ${trade.symbol} - ${trade.slippagePct!.toStringAsFixed(3)}% - '
              '${trade.timestamp.toIso8601String()}');
      }
    }
  }
}
```

---

## Uso en Flutter Widgets

```dart
import 'package:flutter/material.dart';
import 'package:kuri_crypto/models/models.dart';

class PositionCard extends StatelessWidget {
  final Position position;

  const PositionCard({required this.position});

  @override
  Widget build(BuildContext context) {
    final pnlPercent = position.calculatePnlPercentage();
    final isProfitable = position.isProfitable;

    return Card(
      child: ListTile(
        leading: Icon(
          position.side == 'long' ? Icons.arrow_upward : Icons.arrow_downward,
          color: position.side == 'long' ? Colors.green : Colors.red,
        ),
        title: Text(
          position.symbol,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Entry: \$${position.entryPrice.toStringAsFixed(4)}'),
            Text('Current: \$${position.currentPrice.toStringAsFixed(4)}'),
            Text('Size: ${position.size} (${position.leverage}x)'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${position.unrealizedPnl.toStringAsFixed(2)}',
              style: TextStyle(
                color: isProfitable ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${pnlPercent >= 0 ? "+" : ""}${pnlPercent.toStringAsFixed(2)}%',
              style: TextStyle(
                color: isProfitable ? Colors.green : Colors.red,
                fontSize: 12,
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

**Nota**: Estos ejemplos asumen que tienes configurados:
- Dio para HTTP requests
- WebSocket para actualizaciones en tiempo real
- Manejo de errores apropiado
- Manejo de estado (Riverpod, Provider, etc.)
