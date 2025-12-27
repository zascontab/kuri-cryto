#!/usr/bin/env dart

import 'dart:io';
import 'package:dio/dio.dart';

/// Script para probar la implementación JSON-RPC 2.0 del MCP Server
///
/// Este script verifica que podemos conectarnos correctamente al MCP Server
/// usando el protocolo JSON-RPC 2.0 en el endpoint raíz.

void main() async {
  print('🧪 Testing MCP Server JSON-RPC 2.0 Connection...\n');

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

  // Test 2: Probar llamada JSON-RPC básica
  print('2️⃣ Testing basic JSON-RPC call...');
  try {
    final response = await dio.post(
      baseUrl,
      data: {
        'jsonrpc': '2.0',
        'method': 'get_ticker',
        'params': {
          'exchange': 'kucoin',
          'pair': 'BTC-USDT',
          'market_type': 'spot',
        },
        'id': 1,
      },
    );
    print('✅ JSON-RPC call successful');
    print('   Response has result: ${response.data['result'] != null}');
    if (response.data['result'] != null) {
      final result = response.data['result'];
      print('   Ticker data keys: ${result.keys.join(', ')}\n');
    }
  } catch (e) {
    print('❌ JSON-RPC call failed: $e');
    if (e is DioException && e.response != null) {
      print('   Status: ${e.response!.statusCode}');
      print('   Response: ${e.response!.data}\n');
    }
  }

  // Test 3: Probar get_futures_positions
  print('3️⃣ Testing get_futures_positions...');
  try {
    final response = await dio.post(
      baseUrl,
      data: {
        'jsonrpc': '2.0',
        'method': 'get_futures_positions',
        'params': {
          'exchange': 'kucoin',
          'market_type': 'futures',
        },
        'id': 2,
      },
    );
    print('✅ get_futures_positions successful');
    print('   Response has result: ${response.data['result'] != null}');
    if (response.data['result'] != null) {
      final result = response.data['result'];
      print('   Result keys: ${result.keys.join(', ')}\n');
    }
  } catch (e) {
    print('❌ get_futures_positions failed: $e');
    if (e is DioException && e.response != null) {
      print('   Status: ${e.response!.statusCode}');
      print('   Response: ${e.response!.data}\n');
    }
  }

  // Test 4: Probar get_positions (más general)
  print('4️⃣ Testing get_positions...');
  try {
    final response = await dio.post(
      baseUrl,
      data: {
        'jsonrpc': '2.0',
        'method': 'get_positions',
        'params': {
          'exchange': 'kucoin',
        },
        'id': 3,
      },
    );
    print('✅ get_positions successful');
    print('   Response has result: ${response.data['result'] != null}');
    if (response.data['result'] != null) {
      final result = response.data['result'];
      print('   Result keys: ${result.keys.join(', ')}\n');
    }
  } catch (e) {
    print('❌ get_positions failed: $e');
    if (e is DioException && e.response != null) {
      print('   Status: ${e.response!.statusCode}');
      print('   Response: ${e.response!.data}\n');
    }
  }

  print('🎉 MCP Server JSON-RPC test completed!');
  print('📝 Summary: The MCP Server uses JSON-RPC 2.0 at root endpoint');
  print('   - Endpoint: POST /');
  print('   - Protocol: JSON-RPC 2.0');
  print('   - Method: tool name (e.g., "get_futures_positions")');
  print('   - Params: tool arguments');
}
