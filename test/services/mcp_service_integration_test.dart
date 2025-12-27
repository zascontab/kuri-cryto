import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:kuri_crypto/services/mcp_service.dart';
import 'package:kuri_crypto/config/api_config.dart';
import 'package:kuri_crypto/services/api_exception.dart';

/// Pruebas de integración REALES para MCPService
void main() {
  late MCPService service;
  late Dio dio;

  setUpAll(() {
    dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ));

    service = MCPService(dio);

    print('🚀 Iniciando pruebas de integración de MCPService');
    print('📡 Backend: ${ApiConfig.mcpToolsUrl}');
  });

  group('MCPService - Basic Tool Calls', () {
    test('callTool() debe ejecutar get_ticker correctamente', () async {
      try {
        final result = await service.callTool(
          toolName: 'get_ticker',
          arguments: {'exchange': 'kucoin', 'pair': 'BTC-USDT'},
        );

        expect(result, isA<Map<String, dynamic>>());
        expect(result['last'], isNotNull);
        expect(result['last'], greaterThan(0));

        print('✅ get_ticker ejecutado');
        print('   Precio BTC-USDT: \$${result['last']}');
      } catch (e) {
        print('❌ Error en get_ticker: $e');
        rethrow;
      }
    });

    test('callTool() debe ejecutar calculate_rsi correctamente', () async {
      try {
        final result = await service.callTool(
          toolName: 'calculate_rsi',
          arguments: {
            'exchange': 'kucoin',
            'pair': 'BTC-USDT',
            'timeframe': '1h',
            'period': 14,
          },
        );

        expect(result, isA<Map<String, dynamic>>());
        expect(result['rsi'], isNotNull);
        expect(result['rsi'], greaterThanOrEqualTo(0));
        expect(result['rsi'], lessThanOrEqualTo(100));

        print('✅ calculate_rsi ejecutado');
        print('   RSI: ${result['rsi']}');
      } catch (e) {
        print('❌ Error en calculate_rsi: $e');
        rethrow;
      }
    });

    test('callTool() debe ejecutar get_mark_price correctamente', () async {
      try {
        final result = await service.callTool(
          toolName: 'get_mark_price',
          arguments: {'exchange': 'kucoin', 'symbol': 'BTCUSDTM'},
        );

        expect(result, isA<Map<String, dynamic>>());
        expect(result['mark_price'], isNotNull);
        expect(result['mark_price'], greaterThan(0));

        print('✅ get_mark_price ejecutado');
        print('   Mark price: \$${result['mark_price']}');
      } catch (e) {
        print('❌ Error en get_mark_price: $e');
        rethrow;
      }
    });
  });

  group('MCPService - Error Handling', () {
    test('debe manejar herramienta inexistente', () async {
      expect(
        () => service.callTool(toolName: 'non_existent_tool', arguments: {}),
        throwsA(isA<ApiException>()),
      );
      print('✅ Manejo de herramienta inexistente funciona');
    });

    test('debe manejar argumentos inválidos', () async {
      expect(
        () => service.callTool(
          toolName: 'get_ticker',
          arguments: {'exchange': 'invalid', 'pair': 'INVALID'},
        ),
        throwsA(isA<ApiException>()),
      );
      print('✅ Manejo de argumentos inválidos funciona');
    });

    test('debe extraer mensaje de error JSON-RPC', () async {
      try {
        await service.callTool(
          toolName: 'get_ticker',
          arguments: {'exchange': 'invalid', 'pair': 'INVALID'},
        );
        fail('Debería haber lanzado ApiException');
      } on ApiException catch (e) {
        expect(e.message, isNotEmpty);
        expect(e.code, isNotNull);
        print('✅ Extracción de error JSON-RPC funciona');
        print('   Mensaje: ${e.message}');
      }
    });
  });

  group('MCPService - Multiple Calls', () {
    test('callMultipleTools() debe ejecutar múltiples herramientas', () async {
      try {
        final results = await service.callMultipleTools([
          {
            'tool': 'get_ticker',
            'args': {'exchange': 'kucoin', 'pair': 'BTC-USDT'}
          },
          {
            'tool': 'get_ticker',
            'args': {'exchange': 'kucoin', 'pair': 'ETH-USDT'}
          },
        ]);

        expect(results, hasLength(2));
        expect(results[0]['last'], isNotNull);
        expect(results[1]['last'], isNotNull);

        print('✅ callMultipleTools ejecutado');
        print('   BTC: \$${results[0]['last']}');
        print('   ETH: \$${results[1]['last']}');
      } catch (e) {
        print('❌ Error en callMultipleTools: $e');
        rethrow;
      }
    });
  });

  tearDownAll(() {
    dio.close();
    print('🏁 Pruebas de MCPService completadas');
  });
}
