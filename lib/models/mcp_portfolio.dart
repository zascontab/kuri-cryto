import 'mcp_balance.dart';

/// Portafolio de activos obtenido desde MCP Tools
///
/// Representa la composición completa del portafolio con análisis
/// de distribución, valoración y diversificación.
///
/// Este modelo se usa con la herramienta MCP 'get_portfolio'.
///
/// Ejemplo de uso:
/// ```dart
/// final accountService = AccountPortfolioService(mcpService);
/// final portfolio = await accountService.getPortfolio(
///   exchange: 'kucoin',
/// );
///
/// print('Total Value: \$${portfolio.totalValueUsd}');
/// print('Assets: ${portfolio.assetCount}');
/// print('Largest Holding: ${portfolio.largestHolding?.asset}');
/// print('Diversification: ${portfolio.diversificationScore}%');
/// ```
class MCPPortfolio {
  /// Lista de balances
  final List<MCPBalance> balances;

  /// Valor total en USD
  final double totalValueUsd;

  /// Exchange
  final String exchange;

  /// Tipo de cuenta
  final String? accountType;

  /// Timestamp de actualización
  final DateTime timestamp;

  MCPPortfolio({
    required this.balances,
    required this.totalValueUsd,
    required this.exchange,
    this.accountType,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Crea un MCPPortfolio desde JSON
  factory MCPPortfolio.fromJson(Map<String, dynamic> json) {
    final balancesList = json['balances'] as List;
    final balances = balancesList
        .map((b) => MCPBalance.fromJson(b as Map<String, dynamic>))
        .toList();

    return MCPPortfolio(
      balances: balances,
      totalValueUsd: json['total_value_usd'] != null
          ? (json['total_value_usd'] as num).toDouble()
          : balances.fold(0.0, (sum, b) => sum + (b.valueUsd ?? 0)),
      exchange: json['exchange'] as String,
      accountType: json['account_type'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'balances': balances.map((b) => b.toJson()).toList(),
      'total_value_usd': totalValueUsd,
      'exchange': exchange,
      if (accountType != null) 'account_type': accountType,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Número de activos en el portafolio
  int get assetCount => balances.length;

  /// Número de activos con balance significativo
  int get significantAssetCount =>
      balances.where((b) => b.isSignificant()).length;

  /// Balances con cantidad disponible
  List<MCPBalance> get availableBalances => balances.withAvailable;

  /// Balances significativos
  List<MCPBalance> get significantBalances => balances.significant();

  /// Balance más grande por cantidad
  MCPBalance? get largestHolding {
    if (balances.isEmpty) return null;
    return balances.reduce((a, b) => a.total > b.total ? a : b);
  }

  /// Balance más grande por valor USD
  MCPBalance? get largestHoldingByValue {
    if (balances.isEmpty) return null;
    return balances.reduce((a, b) {
      final aValue = a.valueUsd ?? 0;
      final bValue = b.valueUsd ?? 0;
      return aValue > bValue ? a : b;
    });
  }

  /// Obtiene el porcentaje de un activo en el portafolio
  double getAssetPercentage(String asset) {
    if (totalValueUsd == 0) return 0;

    final balance = balances.getBalance(asset);
    if (balance == null || balance.valueUsd == null) return 0;

    return (balance.valueUsd! / totalValueUsd) * 100;
  }

  /// Calcula el score de diversificación (0-100)
  ///
  /// Basado en el índice de Herfindahl-Hirschman modificado:
  /// - 100: Máxima diversificación (muchos activos con pesos similares)
  /// - 0: Sin diversificación (un solo activo)
  double get diversificationScore {
    if (balances.isEmpty || totalValueUsd == 0) return 0;

    // Calcular HHI (suma de cuadrados de porcentajes)
    double hhi = 0;
    for (final balance in balances) {
      if (balance.valueUsd != null) {
        final percentage = balance.valueUsd! / totalValueUsd;
        hhi += percentage * percentage;
      }
    }

    // Convertir HHI a score de diversificación (0-100)
    // HHI = 1 (un solo activo) -> Score = 0
    // HHI = 1/n (n activos iguales) -> Score cercano a 100
    return (1 - hhi) * 100;
  }

  /// Obtiene la distribución de activos ordenada por valor
  List<Map<String, dynamic>> getAssetDistribution() {
    final sorted = balances.sortByValueUsd();

    return sorted.map((balance) {
      final percentage = totalValueUsd > 0 && balance.valueUsd != null
          ? (balance.valueUsd! / totalValueUsd) * 100
          : 0.0;

      return {
        'asset': balance.asset,
        'value_usd': balance.valueUsd ?? 0,
        'percentage': percentage,
        'amount': balance.total,
      };
    }).toList();
  }

  /// Indica si el portafolio está concentrado (>50% en un activo)
  bool get isConcentrated {
    if (balances.isEmpty || totalValueUsd == 0) return false;

    final largest = largestHoldingByValue;
    if (largest == null || largest.valueUsd == null) return false;

    final percentage = (largest.valueUsd! / totalValueUsd) * 100;
    return percentage > 50;
  }

  /// Indica si el portafolio está bien diversificado (score > 70)
  bool get isDiversified => diversificationScore > 70;

  /// Obtiene balances ordenados por valor
  List<MCPBalance> get balancesByValue => balances.sortByValueUsd();

  /// Obtiene balances ordenados por cantidad
  List<MCPBalance> get balancesByTotal => balances.sortByTotal();

  /// Crea una copia con campos modificados
  MCPPortfolio copyWith({
    List<MCPBalance>? balances,
    double? totalValueUsd,
    String? exchange,
    String? accountType,
    DateTime? timestamp,
  }) {
    return MCPPortfolio(
      balances: balances ?? this.balances,
      totalValueUsd: totalValueUsd ?? this.totalValueUsd,
      exchange: exchange ?? this.exchange,
      accountType: accountType ?? this.accountType,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'MCPPortfolio('
        'assets: $assetCount, '
        'totalValue: \$${totalValueUsd.toStringAsFixed(2)}, '
        'diversification: ${diversificationScore.toStringAsFixed(1)}%'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MCPPortfolio &&
        other.totalValueUsd == totalValueUsd &&
        other.exchange == exchange &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(totalValueUsd, exchange, timestamp);
  }
}
