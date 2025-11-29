/// Balance de un activo obtenido desde MCP Tools
///
/// Representa el balance de un activo específico en una cuenta,
/// incluyendo cantidad disponible, bloqueada y total.
///
/// Este modelo se usa con las herramientas MCP:
/// - 'get_account_balances': Obtiene todos los balances
/// - 'get_balance': Obtiene balance de un activo específico
///
/// Ejemplo de uso:
/// ```dart
/// final accountService = AccountPortfolioService(mcpService);
/// final balances = await accountService.getBalances(
///   exchange: 'kucoin',
/// );
///
/// for (var balance in balances) {
///   print('${balance.asset}: ${balance.total} (${balance.availablePercent}% available)');
/// }
/// ```
class MCPBalance {
  /// Símbolo del activo (ej: BTC, USDT, ETH)
  final String asset;

  /// Cantidad total
  final double total;

  /// Cantidad disponible (no bloqueada)
  final double available;

  /// Cantidad bloqueada (en órdenes)
  final double locked;

  /// Exchange
  final String? exchange;

  /// Tipo de cuenta (spot, margin, futures)
  final String? accountType;

  /// Valor en USD (opcional)
  final double? valueUsd;

  /// Timestamp de actualización
  final DateTime? timestamp;

  MCPBalance({
    required this.asset,
    required this.total,
    required this.available,
    required this.locked,
    this.exchange,
    this.accountType,
    this.valueUsd,
    this.timestamp,
  });

  /// Crea un MCPBalance desde JSON
  factory MCPBalance.fromJson(Map<String, dynamic> json) {
    // Calcular total si no viene en el JSON
    final available = (json['available'] ?? json['free'] ?? 0 as num).toDouble();
    final locked = (json['locked'] ?? json['frozen'] ?? 0 as num).toDouble();
    final total = json['total'] != null
        ? (json['total'] as num).toDouble()
        : available + locked;

    return MCPBalance(
      asset: json['asset'] ?? json['currency'] ?? json['coin'] as String,
      total: total,
      available: available,
      locked: locked,
      exchange: json['exchange'] as String?,
      accountType: json['account_type'] ?? json['type'] as String?,
      valueUsd: json['value_usd'] != null
          ? (json['value_usd'] as num).toDouble()
          : null,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'asset': asset,
      'total': total,
      'available': available,
      'locked': locked,
      if (exchange != null) 'exchange': exchange,
      if (accountType != null) 'account_type': accountType,
      if (valueUsd != null) 'value_usd': valueUsd,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }

  /// Porcentaje disponible (no bloqueado)
  double get availablePercent {
    if (total == 0) return 0;
    return (available / total) * 100;
  }

  /// Porcentaje bloqueado
  double get lockedPercent {
    if (total == 0) return 0;
    return (locked / total) * 100;
  }

  /// Indica si tiene balance disponible para operar
  bool get hasAvailable => available > 0;

  /// Indica si tiene balance bloqueado
  bool get hasLocked => locked > 0;

  /// Indica si el balance es cero
  bool get isEmpty => total == 0;

  /// Indica si el balance es significativo (> threshold)
  bool isSignificant({double threshold = 0.0001}) {
    return total > threshold;
  }

  /// Calcula el valor en USD con un precio dado
  double calculateValueUsd(double price) {
    return total * price;
  }

  /// Crea una copia con campos modificados
  MCPBalance copyWith({
    String? asset,
    double? total,
    double? available,
    double? locked,
    String? exchange,
    String? accountType,
    double? valueUsd,
    DateTime? timestamp,
  }) {
    return MCPBalance(
      asset: asset ?? this.asset,
      total: total ?? this.total,
      available: available ?? this.available,
      locked: locked ?? this.locked,
      exchange: exchange ?? this.exchange,
      accountType: accountType ?? this.accountType,
      valueUsd: valueUsd ?? this.valueUsd,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'MCPBalance('
        'asset: $asset, '
        'total: $total, '
        'available: $available, '
        'locked: $locked'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MCPBalance &&
        other.asset == asset &&
        other.total == total &&
        other.available == available &&
        other.locked == locked &&
        other.exchange == exchange;
  }

  @override
  int get hashCode {
    return Object.hash(asset, total, available, locked, exchange);
  }
}

/// Extensión para facilitar análisis de listas de balances
extension MCPBalanceListExtensions on List<MCPBalance> {
  /// Filtra balances con cantidad disponible
  List<MCPBalance> get withAvailable => where((b) => b.hasAvailable).toList();

  /// Filtra balances significativos (> threshold)
  List<MCPBalance> significant({double threshold = 0.0001}) {
    return where((b) => b.isSignificant(threshold: threshold)).toList();
  }

  /// Obtiene balance total en USD (si disponible)
  double get totalValueUsd {
    return fold(0.0, (sum, b) => sum + (b.valueUsd ?? 0));
  }

  /// Obtiene balance de un activo específico
  MCPBalance? getBalance(String asset) {
    try {
      return firstWhere((b) => b.asset.toLowerCase() == asset.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  /// Ordena por valor total descendente
  List<MCPBalance> sortByTotal() {
    final sorted = List<MCPBalance>.from(this);
    sorted.sort((a, b) => b.total.compareTo(a.total));
    return sorted;
  }

  /// Ordena por valor USD descendente
  List<MCPBalance> sortByValueUsd() {
    final sorted = List<MCPBalance>.from(this);
    sorted.sort((a, b) {
      final aValue = a.valueUsd ?? 0;
      final bValue = b.valueUsd ?? 0;
      return bValue.compareTo(aValue);
    });
    return sorted;
  }
}
