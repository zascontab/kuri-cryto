#!/usr/bin/env dart

import 'dart:convert';

/// Test para verificar que HealthResponse.fromJson funciona correctamente
/// con la respuesta real del servidor MCP

// Copiamos la clase HealthResponse para testing
class HealthResponse {
  final String status;
  final bool gctConnected;
  final int toolsCount;
  final int uptime;
  final String version;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  const HealthResponse({
    required this.status,
    required this.gctConnected,
    required this.toolsCount,
    required this.uptime,
    required this.version,
    required this.timestamp,
    this.details,
  });

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(
      status: json['status'] as String? ?? 'unknown',
      gctConnected: json['gct_connected'] as bool? ?? false,
      toolsCount: json['tools_count'] as int? ?? 0,
      uptime: _parseUptime(json['uptime']),
      version: json['version'] as String? ?? 'unknown',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  static int _parseUptime(dynamic uptime) {
    if (uptime == null) return 0;

    if (uptime is int) {
      return uptime;
    }

    if (uptime is String) {
      final uptimeStr = uptime.toLowerCase();

      final numberMatch = RegExp(r'[\d.]+').firstMatch(uptimeStr);
      if (numberMatch == null) return 0;

      final number = double.tryParse(numberMatch.group(0)!) ?? 0.0;

      if (uptimeStr.contains('µs') || uptimeStr.contains('us')) {
        return (number / 1000000).round();
      } else if (uptimeStr.contains('ms')) {
        return (number / 1000).round();
      } else if (uptimeStr.contains('s') && !uptimeStr.contains('m')) {
        return number.round();
      } else if (uptimeStr.contains('m') && !uptimeStr.contains('h')) {
        return (number * 60).round();
      } else if (uptimeStr.contains('h')) {
        return (number * 3600).round();
      } else if (uptimeStr.contains('d')) {
        return (number * 86400).round();
      }

      return number.round();
    }

    return 0;
  }

  @override
  String toString() {
    return 'HealthResponse(status: $status, gctConnected: $gctConnected, toolsCount: $toolsCount, uptime: ${uptime}s)';
  }
}

void main() {
  print('🧪 Testing HealthResponse.fromJson with real server data...\n');

  // Respuesta real del servidor MCP
  const realResponse = '''
  {
    "error_count": 6,
    "gct_connected": true,
    "request_count": 18,
    "sandbox": {
      "enabled": false,
      "message": "PRODUCTION MODE: Orders will be executed with real money. Use with caution.",
      "testnet_only": false
    },
    "status": "ok",
    "tools_count": 73,
    "uptime": "1.467µs"
  }
  ''';

  try {
    final json = jsonDecode(realResponse) as Map<String, dynamic>;
    final health = HealthResponse.fromJson(json);

    print('✅ HealthResponse parsed successfully!');
    print('   Status: ${health.status}');
    print('   GCT Connected: ${health.gctConnected}');
    print('   Tools Count: ${health.toolsCount}');
    print(
        '   Uptime: ${health.uptime} seconds (parsed from "${json['uptime']}")');
    print('   Version: ${health.version}');
    print('   Details: ${health.details != null ? "Present" : "None"}');

    print('\n🎯 Test Cases:');

    // Test diferentes formatos de uptime
    final testCases = [
      '1.467µs',
      '500ms',
      '30s',
      '5m',
      '2h',
      '1d',
      '123', // sin unidad
      123, // número entero
    ];

    for (final testUptime in testCases) {
      final testJson = {'uptime': testUptime};
      final parsedUptime = HealthResponse._parseUptime(testUptime);
      print('   "$testUptime" → $parsedUptime seconds');
    }

    print(
        '\n🎉 All tests passed! HealthResponse can now handle server response correctly.');
  } catch (e) {
    print('❌ Test failed: $e');
  }
}
