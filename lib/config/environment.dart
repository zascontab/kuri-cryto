import 'package:flutter/foundation.dart';
import 'dev_config.dart';

/// Environment configuration for the application
/// Handles environment variables and configuration based on build mode
class Environment {
  // Private constructor
  Environment._();

  /// Current environment mode
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  /// Server IP from environment or default
  static String get _serverIp {
    // Check if SERVER_IP is provided via environment
    const envServerIp = String.fromEnvironment('SERVER_IP');
    if (envServerIp.isNotEmpty) {
      return envServerIp;
    }

    // Default IPs based on platform
    if (kIsWeb) {
      return 'localhost';
    } else {
      // For physical devices, you need to set your development machine's IP
      // Common development IPs (change this to match your network):
      // - 192.168.1.xxx (most home networks)
      // - 192.168.0.xxx (some home networks)
      // - 10.0.2.2 (Android emulator host)
      // - 10.0.0.xxx (some corporate networks)

      // Use development configuration for physical devices
      return DevConfig.getBestServerIp();
    }
  }

  /// API Gateway port
  static const String _gatewayPort = String.fromEnvironment(
    'GATEWAY_PORT',
    defaultValue: '9090',
  );

  /// MATP Kong Gateway port
  static const String _matpKongPort = String.fromEnvironment(
    'MATP_KONG_PORT',
    defaultValue: '10000',
  );

  /// MATP Direct API port
  static const String _matpDirectPort = String.fromEnvironment(
    'MATP_DIRECT_PORT',
    defaultValue: '8200',
  );

  /// Scalping API port
  static const String _scalpingPort = String.fromEnvironment(
    'SCALPING_PORT',
    defaultValue: '8081',
  );

  /// MCP Server port
  static const String _mcpPort = String.fromEnvironment(
    'MCP_PORT',
    defaultValue: '10600',
  );

  /// WebSocket port
  static const String _wsPort = String.fromEnvironment(
    'WS_PORT',
    defaultValue: '9090',
  );

  // Getters for environment values
  static String get environment => _environment;
  static String get serverIp => _serverIp;
  static String get gatewayPort => _gatewayPort;
  static String get mcpPort => _mcpPort;
  static bool get isDevelopment => _environment == 'development';
  static bool get isProduction => _environment == 'production';
  static bool get isStaging => _environment == 'staging';

  // URL builders
  static String get gatewayBaseUrl {
    final protocol = isProduction ? 'https' : 'http';
    final host =
        isProduction ? _getProductionHost() : '$_serverIp:$_gatewayPort';
    return '$protocol://$host';
  }

  static String get matpKongGatewayUrl {
    final protocol = isProduction ? 'https' : 'http';
    final host =
        isProduction ? _getProductionHost() : '$_serverIp:$_matpKongPort';
    return '$protocol://$host';
  }

  static String get matpDirectUrl {
    final protocol = isProduction ? 'https' : 'http';
    final host =
        isProduction ? _getProductionHost() : '$_serverIp:$_matpDirectPort';
    return '$protocol://$host';
  }

  static String get scalpingDirectUrl {
    final protocol = isProduction ? 'https' : 'http';
    final host =
        isProduction ? _getProductionHost() : '$_serverIp:$_scalpingPort';
    return '$protocol://$host';
  }

  static String get mcpDirectUrl {
    final protocol = isProduction ? 'https' : 'http';
    final host = isProduction ? _getProductionHost() : '$_serverIp:$_mcpPort';
    return '$protocol://$host';
  }

  static String get wsBaseUrl {
    final protocol = isProduction ? 'wss' : 'ws';
    final host = isProduction ? _getProductionHost() : '$_serverIp:$_wsPort';
    return '$protocol://$host/ws';
  }

  // Production host configuration
  static String _getProductionHost() {
    return const String.fromEnvironment(
      'PRODUCTION_HOST',
      defaultValue: 'api.kuricrypto.com',
    );
  }

  // API endpoints
  static String get apiBaseUrl => '$gatewayBaseUrl/api/scalping/api/v1';
  static String get mcpApiUrl => '$gatewayBaseUrl/mcp';

  // Debug information
  static Map<String, dynamic> get debugInfo => {
        'environment': environment,
        'serverIp': serverIp,
        'isDevelopment': isDevelopment,
        'isProduction': isProduction,
        'isStaging': isStaging,
        'gatewayBaseUrl': gatewayBaseUrl,
        'matpKongGatewayUrl': matpKongGatewayUrl,
        'matpDirectUrl': matpDirectUrl,
        'scalpingDirectUrl': scalpingDirectUrl,
        'mcpDirectUrl': mcpDirectUrl,
        'wsBaseUrl': wsBaseUrl,
        'apiBaseUrl': apiBaseUrl,
        'mcpApiUrl': mcpApiUrl,
      };

  /// Print environment configuration for debugging
  static void printConfig() {
    if (isDevelopment) {
      // Using debugPrint for development logging
      debugPrint('🔧 Environment Configuration:');
      debugInfo.forEach((key, value) {
        debugPrint('  $key: $value');
      });
    }
  }
}
