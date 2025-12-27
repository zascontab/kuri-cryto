import '../models/mcp_account_info.dart';
import '../models/mcp_balance.dart';
import '../models/mcp_portfolio.dart';
import 'mcp_service.dart';

/// Account & Portfolio Service - Wrapper para herramientas MCP de cuenta
///
/// Provee acceso tipo-seguro a las herramientas MCP de gestión de cuenta:
/// - account_info: Información de cuenta
/// - get_account_balances: Todos los balances
/// - get_balance: Balance de un activo específico
/// - get_portfolio: Composición del portafolio
/// - portfolio_analysis: Análisis de diversificación
///
/// Ejemplo de uso:
/// ```dart
/// final accountService = AccountPortfolioService(mcpService);
///
/// // Obtener información de cuenta
/// final accountInfo = await accountService.getAccountInfo(
///   exchange: 'kucoin',
/// );
/// print('Trading Enabled: ${accountInfo.canTrade}');
///
/// // Obtener todos los balances
/// final balances = await accountService.getBalances(
///   exchange: 'kucoin',
/// );
/// print('Total Assets: ${balances.length}');
///
/// // Obtener portafolio con análisis
/// final portfolio = await accountService.getPortfolio(
///   exchange: 'kucoin',
/// );
/// print('Total Value: \$${portfolio.totalValueUsd}');
/// print('Diversification: ${portfolio.diversificationScore}%');
/// ```
class AccountPortfolioService {
  final MCPService _mcpService;

  AccountPortfolioService(this._mcpService);

  /// Obtiene información de la cuenta
  ///
  /// Parámetros:
  /// - [exchange]: Exchange (ej: 'kucoin', 'binance')
  /// - [accountType]: Tipo de cuenta (opcional: 'spot', 'margin', 'futures')
  ///
  /// Retorna: [MCPAccountInfo] con permisos, comisiones y estado
  Future<MCPAccountInfo> getAccountInfo({
    required String exchange,
    String? accountType,
  }) async {
    final arguments = <String, dynamic>{
      'exchange': exchange,
    };

    if (accountType != null) {
      arguments['account_type'] = accountType;
    }

    final result = await _mcpService.callTool(
      toolName: 'account_info',
      arguments: arguments,
    );

    // Agregar exchange al resultado
    result['exchange'] = exchange;
    if (accountType != null) {
      result['account_type'] = accountType;
    }

    return MCPAccountInfo.fromJson(result);
  }

  /// Obtiene todos los balances de la cuenta
  ///
  /// Parámetros:
  /// - [exchange]: Exchange
  /// - [accountType]: Tipo de cuenta (opcional)
  /// - [includeZero]: Incluir balances en cero (default: false)
  ///
  /// Retorna: Lista de [MCPBalance]
  Future<List<MCPBalance>> getBalances({
    required String exchange,
    String? accountType,
    bool includeZero = false,
  }) async {
    final arguments = <String, dynamic>{
      'exchange': exchange,
      'include_zero': includeZero,
    };

    if (accountType != null) {
      arguments['account_type'] = accountType;
    }

    final result = await _mcpService.callTool(
      toolName: 'get_account_balances',
      arguments: arguments,
    );

    // El resultado puede venir como {'balances': [...]} o directamente [...]
    final balancesList = result['balances'] ?? result;

    if (balancesList is! List) {
      throw FormatException(
          'Expected list of balances, got ${balancesList.runtimeType}');
    }

    return balancesList.map((balance) {
      final balanceMap = balance as Map<String, dynamic>;
      // Agregar metadatos
      balanceMap['exchange'] = exchange;
      if (accountType != null) {
        balanceMap['account_type'] = accountType;
      }
      return MCPBalance.fromJson(balanceMap);
    }).toList();
  }

  /// Obtiene el balance de un activo específico
  ///
  /// Parámetros:
  /// - [exchange]: Exchange
  /// - [asset]: Símbolo del activo (ej: 'BTC', 'USDT')
  /// - [accountType]: Tipo de cuenta (opcional)
  ///
  /// Retorna: [MCPBalance] del activo solicitado
  Future<MCPBalance> getBalance({
    required String exchange,
    required String asset,
    String? accountType,
  }) async {
    final arguments = <String, dynamic>{
      'exchange': exchange,
      'asset': asset,
    };

    if (accountType != null) {
      arguments['account_type'] = accountType;
    }

    final result = await _mcpService.callTool(
      toolName: 'get_balance',
      arguments: arguments,
    );

    // Agregar metadatos
    result['exchange'] = exchange;
    result['asset'] = asset;
    if (accountType != null) {
      result['account_type'] = accountType;
    }

    return MCPBalance.fromJson(result);
  }

  /// Obtiene el portafolio completo con análisis
  ///
  /// Parámetros:
  /// - [exchange]: Exchange
  /// - [accountType]: Tipo de cuenta (opcional)
  /// - [includeZero]: Incluir balances en cero (default: false)
  ///
  /// Retorna: [MCPPortfolio] con balances y métricas de diversificación
  Future<MCPPortfolio> getPortfolio({
    required String exchange,
    String? accountType,
    bool includeZero = false,
  }) async {
    final arguments = <String, dynamic>{
      'exchange': exchange,
      'include_zero': includeZero,
    };

    if (accountType != null) {
      arguments['account_type'] = accountType;
    }

    final result = await _mcpService.callTool(
      toolName: 'get_portfolio',
      arguments: arguments,
    );

    // Agregar metadatos
    result['exchange'] = exchange;
    if (accountType != null) {
      result['account_type'] = accountType;
    }

    return MCPPortfolio.fromJson(result);
  }

  /// Obtiene análisis de portafolio
  ///
  /// Incluye análisis de:
  /// - Distribución de activos
  /// - Diversificación
  /// - Concentración de riesgo
  /// - Performance histórico (si disponible)
  ///
  /// Parámetros:
  /// - [exchange]: Exchange
  /// - [accountType]: Tipo de cuenta (opcional)
  ///
  /// Retorna: Map con análisis completo del portafolio
  Future<Map<String, dynamic>> getPortfolioAnalysis({
    required String exchange,
    String? accountType,
  }) async {
    final arguments = <String, dynamic>{
      'exchange': exchange,
    };

    if (accountType != null) {
      arguments['account_type'] = accountType;
    }

    return await _mcpService.callTool(
      toolName: 'portfolio_analysis',
      arguments: arguments,
    );
  }

  /// Obtiene balances significativos (filtra balances muy pequeños)
  ///
  /// Método de conveniencia que filtra balances con cantidad mínima
  ///
  /// Parámetros:
  /// - [exchange]: Exchange
  /// - [threshold]: Cantidad mínima para considerar significativo
  /// - [accountType]: Tipo de cuenta (opcional)
  ///
  /// Retorna: Lista de [MCPBalance] significativos
  Future<List<MCPBalance>> getSignificantBalances({
    required String exchange,
    double threshold = 0.0001,
    String? accountType,
  }) async {
    final balances = await getBalances(
      exchange: exchange,
      accountType: accountType,
      includeZero: false,
    );

    return balances.significant(threshold: threshold);
  }

  /// Obtiene el balance total en USD
  ///
  /// Suma todos los balances valorizados en USD
  ///
  /// Parámetros:
  /// - [exchange]: Exchange
  /// - [accountType]: Tipo de cuenta (opcional)
  ///
  /// Retorna: Valor total en USD
  Future<double> getTotalValueUsd({
    required String exchange,
    String? accountType,
  }) async {
    final balances = await getBalances(
      exchange: exchange,
      accountType: accountType,
    );

    return balances.totalValueUsd;
  }

  /// Verifica si tiene suficiente balance de un activo
  ///
  /// Útil antes de ejecutar una operación
  ///
  /// Parámetros:
  /// - [exchange]: Exchange
  /// - [asset]: Activo a verificar
  /// - [amount]: Cantidad requerida
  /// - [accountType]: Tipo de cuenta (opcional)
  ///
  /// Retorna: true si tiene suficiente balance disponible
  Future<bool> hasSufficientBalance({
    required String exchange,
    required String asset,
    required double amount,
    String? accountType,
  }) async {
    try {
      final balance = await getBalance(
        exchange: exchange,
        asset: asset,
        accountType: accountType,
      );

      return balance.available >= amount;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene la distribución de activos del portafolio
  ///
  /// Método de conveniencia que combina portafolio y análisis
  ///
  /// Parámetros:
  /// - [exchange]: Exchange
  /// - [accountType]: Tipo de cuenta (opcional)
  ///
  /// Retorna: Lista de activos con su porcentaje en el portafolio
  Future<List<Map<String, dynamic>>> getAssetDistribution({
    required String exchange,
    String? accountType,
  }) async {
    final portfolio = await getPortfolio(
      exchange: exchange,
      accountType: accountType,
    );

    return portfolio.getAssetDistribution();
  }

  /// Calcula el score de diversificación del portafolio
  ///
  /// Parámetros:
  /// - [exchange]: Exchange
  /// - [accountType]: Tipo de cuenta (opcional)
  ///
  /// Retorna: Score de 0-100 (100 = máxima diversificación)
  Future<double> getDiversificationScore({
    required String exchange,
    String? accountType,
  }) async {
    final portfolio = await getPortfolio(
      exchange: exchange,
      accountType: accountType,
    );

    return portfolio.diversificationScore;
  }
}
