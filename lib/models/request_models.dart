/// Request models for API calls
library;

/// Create position request model
class CreatePositionRequest {
  final String symbol;
  final String side;
  final double size;
  final double price;
  final double? stopLoss;
  final double? takeProfit;
  final double? leverage;

  const CreatePositionRequest({
    required this.symbol,
    required this.side,
    required this.size,
    required this.price,
    this.stopLoss,
    this.takeProfit,
    this.leverage,
  });

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'side': side,
      'size': size,
      'price': price,
      if (stopLoss != null) 'stopLoss': stopLoss,
      if (takeProfit != null) 'takeProfit': takeProfit,
      if (leverage != null) 'leverage': leverage,
    };
  }

  @override
  String toString() {
    return 'CreatePositionRequest(symbol: $symbol, side: $side, size: $size)';
  }
}

/// Analysis request model
class AnalysisRequest {
  final String symbol;
  final String exchange;
  final String timeframe;
  final Map<String, dynamic>? parameters;

  const AnalysisRequest({
    required this.symbol,
    required this.exchange,
    required this.timeframe,
    this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'exchange': exchange,
      'timeframe': timeframe,
      if (parameters != null) 'parameters': parameters,
    };
  }

  @override
  String toString() {
    return 'AnalysisRequest(symbol: $symbol, exchange: $exchange, timeframe: $timeframe)';
  }
}

/// Backtest request model
class BacktestRequest {
  final String strategy;
  final String symbol;
  final DateTime startDate;
  final DateTime endDate;
  final double initialCapital;
  final Map<String, dynamic>? parameters;

  const BacktestRequest({
    required this.strategy,
    required this.symbol,
    required this.startDate,
    required this.endDate,
    required this.initialCapital,
    this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'strategy': strategy,
      'symbol': symbol,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'initialCapital': initialCapital,
      if (parameters != null) 'parameters': parameters,
    };
  }

  @override
  String toString() {
    return 'BacktestRequest(strategy: $strategy, symbol: $symbol, capital: $initialCapital)';
  }
}

/// LLM analysis request model
class LLMAnalysisRequest {
  final String symbol;
  final String exchange;
  final String timeframe;
  final String? context;
  final List<String>? indicators;

  const LLMAnalysisRequest({
    required this.symbol,
    required this.exchange,
    required this.timeframe,
    this.context,
    this.indicators,
  });

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'exchange': exchange,
      'timeframe': timeframe,
      if (context != null) 'context': context,
      if (indicators != null) 'indicators': indicators,
    };
  }

  @override
  String toString() {
    return 'LLMAnalysisRequest(symbol: $symbol, exchange: $exchange, timeframe: $timeframe)';
  }
}

/// Risk assessment request model
class RiskAssessmentRequest {
  final String symbol;
  final double positionSize;
  final double entryPrice;
  final double? stopLoss;
  final double? accountBalance;

  const RiskAssessmentRequest({
    required this.symbol,
    required this.positionSize,
    required this.entryPrice,
    this.stopLoss,
    this.accountBalance,
  });

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'positionSize': positionSize,
      'entryPrice': entryPrice,
      if (stopLoss != null) 'stopLoss': stopLoss,
      if (accountBalance != null) 'accountBalance': accountBalance,
    };
  }

  @override
  String toString() {
    return 'RiskAssessmentRequest(symbol: $symbol, size: $positionSize, price: $entryPrice)';
  }
}

/// Position size request model
class PositionSizeRequest {
  final String symbol;
  final double accountBalance;
  final double riskPercent;
  final double entryPrice;
  final double stopLoss;

  const PositionSizeRequest({
    required this.symbol,
    required this.accountBalance,
    required this.riskPercent,
    required this.entryPrice,
    required this.stopLoss,
  });

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'accountBalance': accountBalance,
      'riskPercent': riskPercent,
      'entryPrice': entryPrice,
      'stopLoss': stopLoss,
    };
  }

  @override
  String toString() {
    return 'PositionSizeRequest(symbol: $symbol, risk: $riskPercent%, balance: $accountBalance)';
  }
}

/// Optimization request model
class OptimizationRequest {
  final String strategy;
  final String symbol;
  final DateTime startDate;
  final DateTime endDate;
  final double initialCapital;
  final Map<String, List<dynamic>> parameterRanges;

  const OptimizationRequest({
    required this.strategy,
    required this.symbol,
    required this.startDate,
    required this.endDate,
    required this.initialCapital,
    required this.parameterRanges,
  });

  Map<String, dynamic> toJson() {
    return {
      'strategy': strategy,
      'symbol': symbol,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'initialCapital': initialCapital,
      'parameterRanges': parameterRanges,
    };
  }

  @override
  String toString() {
    return 'OptimizationRequest(strategy: $strategy, symbol: $symbol, parameters: ${parameterRanges.length})';
  }
}
