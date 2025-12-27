#!/usr/bin/env dart

import 'dart:io';
import 'package:dio/dio.dart';

/// Script para probar la nueva implementación del MCP Service
///
/// Este script verifica que podemos conectarnos correctamente al MCP Server
/// usando el protocolo REST directo en lugar de JSON-RPC.

void main() async {
  print('🧪 Testing MCP Server Connection Fix...\n');

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

  // Test 2: Obtener lista de herramientas
  print('2️⃣ Testing tools list endpoint...');
  try {
    final toolsResponse = await dio.get('$baseUrl/tools');
    final tools = toolsResponse.data['tools'] as List;
    print('✅ Tools list retrieved successfully');
    print('   Total tools: ${tools.length}');
    print(
        '   Sample tools: ${tools.take(3).map((t) => t['name']).join(', ')}\n');
  } catch (e) {
    print('❌ Tools list failed: $e\n');
    exit(1);
  }

  // Test 3: Probar llamada a herramienta específica (get_futures_positions)
  print('3️⃣ Testing specific tool call (get_futures_positions)...');
  try {
    final response = await dio.post(
      '$baseUrl/get_futures_positions',
      data: {
        'exchange': 'kucoin',
        'market_type': 'futures',
      },
    );
    print('✅ Tool call successful');
    print('   Response keys: ${response.data.keys.join(', ')}\n');
  } catch (e) {
    print('❌ Tool call failed: $e');
    if (e is DioException && e.response != null) {
      print('   Status: ${e.response!.statusCode}');
      print('   Response: ${e.response!.data}\n');
    }
  }

  // Test 4: Probar otra herramienta (get_ticker)
  print('4️⃣ Testing another tool (get_ticker)...');
  try {
    final response = await dio.post(
      '$baseUrl/get_ticker',
      data: {
        'exchange': 'kucoin',
        'pair': 'BTC-USDT',
        'market_type': 'spot',
      },
    );
    print('✅ Ticker call successful');
    print('   Response keys: ${response.data.keys.join(', ')}\n');
  } catch (e) {
    print('❌ Ticker call failed: $e');
    if (e is DioException && e.response != null) {
      print('   Status: ${e.response!.statusCode}');
      print('   Response: ${e.response!.data}\n');
    }
  }

  print('🎉 MCP Server connection test completed!');
  print('📝 Summary: The MCP Server uses REST endpoints, not JSON-RPC');
  print('   - Health: GET /health');
  print('   - Tools list: GET /tools');
  print('   - Tool calls: POST /{tool_name} with arguments in body');
}
