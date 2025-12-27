/// Información de cuenta obtenida desde MCP Tools
///
/// Representa la información general de una cuenta en un exchange,
/// incluyendo tipo de cuenta, permisos, límites y estado.
///
/// Este modelo se usa con la herramienta MCP 'account_info'.
///
/// Ejemplo de uso:
/// ```dart
/// final accountService = AccountPortfolioService(mcpService);
/// final accountInfo = await accountService.getAccountInfo(
///   exchange: 'kucoin',
/// );
///
/// print('Account Type: ${accountInfo.accountType}');
/// print('Trading Enabled: ${accountInfo.canTrade}');
/// print('Maker Fee: ${accountInfo.makerFee}%');
/// print('Taker Fee: ${accountInfo.takerFee}%');
/// ```
class MCPAccountInfo {
  /// Tipo de cuenta (spot, margin, futures)
  final String accountType;

  /// Exchange
  final String exchange;

  /// Permisos de trading
  final bool canTrade;

  /// Permisos de retiro
  final bool canWithdraw;

  /// Permisos de depósito
  final bool canDeposit;

  /// Comisión maker (%)
  final double? makerFee;

  /// Comisión taker (%)
  final double? takerFee;

  /// Límites de trading (opcional)
  final Map<String, dynamic>? tradingLimits;

  /// Estado de la cuenta
  final String? status;

  /// Timestamp de actualización
  final DateTime? timestamp;

  MCPAccountInfo({
    required this.accountType,
    required this.exchange,
    required this.canTrade,
    required this.canWithdraw,
    required this.canDeposit,
    this.makerFee,
    this.takerFee,
    this.tradingLimits,
    this.status,
    this.timestamp,
  });

  /// Crea un MCPAccountInfo desde JSON
  factory MCPAccountInfo.fromJson(Map<String, dynamic> json) {
    return MCPAccountInfo(
      accountType: json['account_type'] ?? json['type'] ?? 'spot',
      exchange: json['exchange'] as String,
      canTrade: json['can_trade'] ?? json['trading_enabled'] ?? false,
      canWithdraw: json['can_withdraw'] ?? json['withdraw_enabled'] ?? false,
      canDeposit: json['can_deposit'] ?? json['deposit_enabled'] ?? false,
      makerFee: json['maker_fee'] != null
          ? (json['maker_fee'] as num).toDouble()
          : null,
      takerFee: json['taker_fee'] != null
          ? (json['taker_fee'] as num).toDouble()
          : null,
      tradingLimits: json['trading_limits'] as Map<String, dynamic>?,
      status: json['status'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'account_type': accountType,
      'exchange': exchange,
      'can_trade': canTrade,
      'can_withdraw': canWithdraw,
      'can_deposit': canDeposit,
      if (makerFee != null) 'maker_fee': makerFee,
      if (takerFee != null) 'taker_fee': takerFee,
      if (tradingLimits != null) 'trading_limits': tradingLimits,
      if (status != null) 'status': status,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }

  /// Indica si la cuenta está activa
  bool get isActive => status?.toLowerCase() == 'active' || status == null;

  /// Indica si tiene todos los permisos
  bool get hasFullPermissions => canTrade && canWithdraw && canDeposit;

  /// Obtiene la comisión promedio
  double? get averageFee {
    if (makerFee == null || takerFee == null) return null;
    return (makerFee! + takerFee!) / 2;
  }

  /// Crea una copia con campos modificados
  MCPAccountInfo copyWith({
    String? accountType,
    String? exchange,
    bool? canTrade,
    bool? canWithdraw,
    bool? canDeposit,
    double? makerFee,
    double? takerFee,
    Map<String, dynamic>? tradingLimits,
    String? status,
    DateTime? timestamp,
  }) {
    return MCPAccountInfo(
      accountType: accountType ?? this.accountType,
      exchange: exchange ?? this.exchange,
      canTrade: canTrade ?? this.canTrade,
      canWithdraw: canWithdraw ?? this.canWithdraw,
      canDeposit: canDeposit ?? this.canDeposit,
      makerFee: makerFee ?? this.makerFee,
      takerFee: takerFee ?? this.takerFee,
      tradingLimits: tradingLimits ?? this.tradingLimits,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'MCPAccountInfo('
        'exchange: $exchange, '
        'type: $accountType, '
        'canTrade: $canTrade, '
        'status: $status'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MCPAccountInfo &&
        other.accountType == accountType &&
        other.exchange == exchange &&
        other.canTrade == canTrade &&
        other.canWithdraw == canWithdraw &&
        other.canDeposit == canDeposit;
  }

  @override
  int get hashCode {
    return Object.hash(
      accountType,
      exchange,
      canTrade,
      canWithdraw,
      canDeposit,
    );
  }
}
