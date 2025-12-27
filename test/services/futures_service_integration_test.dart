import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:kuri_crypto/services/futures_service.dart';
import 'package:kuri_crypto/config/api_config.dart';
import 'package:kuri_crypto/models/futures_position.dart';

/// Pruebas de integración REALES para FuturesService
void main() {
  late FuturesService service;
  late Dio dio;

  setUpAll(() {
    dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ));

    service = FuturesService(dio);

    print('🚀 Iniciando pruebas de integración de FuturesService');
    print('📡 Backend: ${ApiConfig.mcpToolsUrl}');
  });

  group('FuturesService - Positions', () {
    test('getPositions() debe retornar lista de posiciones', () async {
      try {
        final response = await service.getPositions(exchange: 'kucoin');

        expect(response, isA<FuturesPositionsResponse>());
        expect(response.positions, isA<List<FuturesPosition>>());
        expect(response.count, equals(response.positions.length));

        print('✅ Posiciones obtenidas: ${response.count}');
        print(
            '   Total PnL: \$${response.totalUnrealizedPnl.toStringAsFixed(2)}');

        if (response.positions.isNotEmpty) {
          final pos = response.positions.first;
          print('   Primera posición:');
          print('     Symbol: ${pos.symbol}');
          print('     Side: ${pos.side}');
          print(
              '     PnL: \$${pos.unrealizedPnl} (${pos.pnlPercent.toStringAsFixed(2)}%)');
        }
      } catch (e) {
        print('❌ Error en getPositions: $e');
        rethrow;
      }
    });
  });

  group('FuturesService - Price Info', () {
    test('getMarkPrice() debe retornar precio mark válido', () async {
      try {
        final markPrice = await service.getMarkPrice(
          symbol: 'BTCUSDTM',
          exchange: 'kucoin',
        );

        expect(markPrice, isA<double>());
        expect(markPrice, greaterThan(0));

        print('✅ Mark price: \$${markPrice.toStringAsFixed(2)}');
      } catch (e) {
        print('❌ Error en getMarkPrice: $e');
        rethrow;
      }
    });

    test('getIndexPrice() debe retornar precio índice válido', () async {
      try {
        final indexPrice = await service.getIndexPrice(
          symbol: 'BTCUSDTM',
          exchange: 'kucoin',
        );

        expect(indexPrice, isA<double>());
        expect(indexPrice, greaterThan(0));

        print('✅ Index price: \$${indexPrice.toStringAsFixed(2)}');
      } catch (e) {
        print('❌ Error en getIndexPrice: $e');
        rethrow;
      }
    });
  });

  group('FuturesService - Symbol Conversion', () {
    test('convertToFuturesSymbol() debe convertir correctamente', () {
      expect(service.convertToFuturesSymbol('BTC-USDT'), equals('BTCUSDTM'));
      expect(service.convertToFuturesSymbol('DOGE-USDT'), equals('DOGEUSDTM'));
      print('✅ Conversión spot → futures funciona');
    });

    test('convertToSpotSymbol() debe convertir correctamente', () {
      expect(service.convertToSpotSymbol('BTCUSDTM'), equals('BTC-USDT'));
      expect(service.convertToSpotSymbol('DOGEUSDTM'), equals('DOGE-USDT'));
      print('✅ Conversión futures → spot funciona');
    });
  });

  tearDownAll(() {
    dio.close();
    print('🏁 Pruebas de FuturesService completadas');
  });
}
