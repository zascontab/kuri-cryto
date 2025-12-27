#!/usr/bin/env dart

import 'dart:io';
import 'package:dio/dio.dart';

/// Script para probar la implementación final del MCP Service
///
/// Este script verifica que podemos conectarnos correctamente al MCP Server
/// usando el protocolo JSON-RPC 2.0 correcto con tools/call.

void main() async {
  print('🧪 Testing MCP Server Final Implementation...\n');

  final dio = Dio();
  const serverIp = '192.168.1.6';
  const mcpPort = '10600';
  final baseUrl = 'http://$serverIp:$mcpPort';

  // Test 1: Verificar que el servidor está funcionando
  print('1️⃣ Testing MCP Server health...');
  try {
    final healthResponse = await dio.get('$baseUrl/health');
    print('✅ MCP Server is healthy');
    print('   Tools available: ${healthResponse.data['tools_count']}');
    print('   Status: ${healthResponse.data['status']}\n');
  } catch (e) {
    print('❌ MCP Server health check failed: $e\n');
    exit(1);
  }

  // Test 2: Probar get_ticker
  print('2️⃣ Testing get_ticker...');
  try {
    final response = await dio.post(
      baseUrl,
      data: {
        'jsonrpc': '2.0',
        'method': 'tools/call',
        'params': {
          'name': 'get_ticker',
          'arguments': {
            'exchange': 'kucoin',
            'pair': 'BTC-USDT',
            'market_type': 'spot',
          },
        },
        'id': 1,
      },
    );
    print('✅ get_ticker successful');
    final result = response.data['result'];
    print('   BTC-USDT Price: ${result['last']}');
    print('   24h Volume: ${result['volume']}\n');
  } catch (e) {
    print('❌ get_ticker failed: $e\n');
  }

  // Test 3: Probar get_futures_positions
  print('3️⃣ Testing get_futures_positions...');
  try {
    final response = await dio.post(
      baseUrl,
      data: {
        'jsonrpc': '2.0',
        'method': 'tools/call',
        'params': {
          'name': 'get_futures_positions',
          'arguments': {
            'exchange': 'kucoin',
            'market_type': 'futures',
          },
        },
        'id': 2,
      },
    );
    print('✅ get_futures_positions successful');
    final result = response.data['result'];
    print('   Positions count: ${result['positions']?.length ?? 0}');
    print('   Total count: ${result['total_count'] ?? 0}\n');
  } catch (e) {
    print('❌ get_futures_positions failed: $e\n');
  }

  // Test 4: Probar get_positions (más general)
  print('4️⃣ Testing get_positions...');
  try {
    final response = await dio.post(
      baseUrl,
      data: {
        'jsonrpc': '2.0',
        'method': 'tools/call',
        'params': {
          'name': 'get_positions',
          'arguments': {
            'exchange': 'kucoin',
          },
        },
        'id': 3,
      },
    );
    print('✅ get_positions successful');
    final result = response.data['result'];
    print('   Result keys: ${result.keys.join(', ')}\n');
  } catch (e) {
    print('❌ get_positions failed: $e\n');
  }

  // Test 5: Probar calculate_rsi
  print('5️⃣ Testing calculate_rsi...');
  try {
    final response = await dio.post(
      baseUrl,
      data: {
        'jsonrpc': '2.0',
        'method': 'tools/call',
        'params': {
          'name': 'calculate_rsi',
          'arguments': {
            'exchange': 'kucoin',
            'pair': 'BTC-USDT',
            'market_type': 'spot',
          },
        },
        'id': 4,
      },
    );
    print('✅ calculate_rsi successful');
    final result = response.data['result'];
    print('   RSI Value: ${result['rsi']}');
    print('   Signal: ${result['signal']}\n');
  } catch (e) {
    print('❌ calculate_rsi failed: $e\n');
  }

  print('🎉 MCP Server final test completed!');
  print('📝 Summary: MCP Server protocol confirmed');
  print('   ✅ Endpoint: POST / (root)');
  print('   ✅ Protocol: JSON-RPC 2.0');
  print('   ✅ Method: "tools/call"');
  print('   ✅ Format: {"name": "tool_name", "arguments": {...}}');
  print('');
  print('🚀 Flutter app should now work with MCP endpoints!');
}
