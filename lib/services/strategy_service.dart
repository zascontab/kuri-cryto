import 'dart:developer' as developer;
import 'api_client.dart';
import 'api_exception.dart';

/// Strategy Performance Model
class StrategyPerformance {
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final double winRate;
  final double totalPnl;
  final double avgWin;
  final double avgLoss;
  final double sharpeRatio;
  final double maxDrawdown;
  final double profitFactor;

  StrategyPerformance({
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.winRate,
    required this.totalPnl,
    required this.avgWin,
    required this.avgLoss,
    required this.sharpeRatio,
    required this.maxDrawdown,
    required this.profitFactor,
  });

  factory StrategyPerformance.fromJson(Map<String, dynamic> json) {
    return StrategyPerformance(
      totalTrades: json['total_trades'] ?? 0,
      winningTrades: json['winning_trades'] ?? 0,
      losingTrades: json['losing_trades'] ?? 0,
      winRate: (json['win_rate'] ?? 0).toDouble(),
      totalPnl: (json['total_pnl'] ?? 0).toDouble(),
      avgWin: (json['avg_win'] ?? 0).toDouble(),
      avgLoss: (json['avg_loss'] ?? 0).toDouble(),
      sharpeRatio: (json['sharpe_ratio'] ?? 0).toDouble(),
      maxDrawdown: (json['max_drawdown'] ?? 0).toDouble(),
      profitFactor: (json['profit_factor'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_trades': totalTrades,
      'winning_trades': winningTrades,
      'losing_trades': losingTrades,
      'win_rate': winRate,
      'total_pnl': totalPnl,
      'avg_win': avgWin,
      'avg_loss': avgLoss,
      'sharpe_ratio': sharpeRatio,
      'max_drawdown': maxDrawdown,
      'profit_factor': profitFactor,
    };
  }
}

/// Strategy Model
class Strategy {
  final String name;
  final bool active;
  final double weight;
  final StrategyPerformance performance;
  final Map<String, dynamic>? config;

  Strategy({
    required this.name,
    required this.active,
    required this.weight,
    required this.performance,
    this.config,
  });

  factory Strategy.fromJson(Map<String, dynamic> json) {
    return Strategy(
      name: json['name'],
      active: json['active'] ?? false,
      weight: (json['weight'] ?? 0).toDouble(),
      performance: StrategyPerformance.fromJson(json['performance'] ?? {}),
      config: json['config'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'active': active,
      'weight': weight,
      'performance': performance.toJson(),
      'config': config,
    };
  }
}

/// Strategy Service
///
/// Handles strategy management operations:
/// - Get all strategies
/// - Get specific strategy details
/// - Start/stop strategies
/// - Update strategy configuration
/// - Get performance metrics
class StrategyService {
  final ApiClient _apiClient;
  static const String _basePath = '/scalping/strategies';

  StrategyService(this._apiClient);

  /// Get all strategies
  ///
  /// Returns a list of all available strategies with their
  /// current status and performance metrics.
  ///
  /// Example:
  /// ```dart
  /// final strategies = await strategyService.getStrategies();
  /// print('Total strategies: ${strategies.length}');
  /// ```
  Future<List<Strategy>> getStrategies() async {
    try {
      developer.log('Fetching all strategies...', name: 'StrategyService');

      final response = await _apiClient.get<Map<String, dynamic>>(_basePath);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        final strategies = data.map((json) => Strategy.fromJson(json)).toList();
        developer.log('Retrieved ${strategies.length} strategies', name: 'StrategyService');
        return strategies;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log('Error getting strategies: $e', name: 'StrategyService', error: e);
      rethrow;
    }
  }

  /// Get a specific strategy by name
  ///
  /// Returns detailed information about a specific strategy
  /// including configuration and performance metrics.
  ///
  /// Parameters:
  /// - [name]: Strategy name (e.g., 'rsi_scalping')
  ///
  /// Example:
  /// ```dart
  /// final strategy = await strategyService.getStrategy('rsi_scalping');
  /// print('Win Rate: ${strategy.performance.winRate}%');
  /// ```
  Future<Strategy> getStrategy(String name) async {
    try {
      developer.log('Fetching strategy: $name', name: 'StrategyService');

      final response = await _apiClient.get<Map<String, dynamic>>('$_basePath/$name');

      if (response['success'] == true && response['data'] != null) {
        final strategy = Strategy.fromJson(response['data']);
        developer.log('Strategy retrieved successfully', name: 'StrategyService');
        return strategy;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log('Error getting strategy: $e', name: 'StrategyService', error: e);
      rethrow;
    }
  }

  /// Start a strategy
  ///
  /// Activates a strategy to start generating trading signals.
  ///
  /// Parameters:
  /// - [name]: Strategy name to start
  ///
  /// Returns true if successful.
  ///
  /// Example:
  /// ```dart
  /// await strategyService.startStrategy('rsi_scalping');
  /// ```
  Future<bool> startStrategy(String name) async {
    try {
      developer.log('Starting strategy: $name', name: 'StrategyService');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_basePath/$name/start',
      );

      if (response['success'] == true) {
        developer.log('Strategy started successfully', name: 'StrategyService');
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to start strategy',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error starting strategy: $e', name: 'StrategyService', error: e);
      rethrow;
    }
  }

  /// Stop a strategy
  ///
  /// Deactivates a strategy to stop generating trading signals.
  ///
  /// Parameters:
  /// - [name]: Strategy name to stop
  ///
  /// Returns true if successful.
  ///
  /// Example:
  /// ```dart
  /// await strategyService.stopStrategy('rsi_scalping');
  /// ```
  Future<bool> stopStrategy(String name) async {
    try {
      developer.log('Stopping strategy: $name', name: 'StrategyService');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_basePath/$name/stop',
      );

      if (response['success'] == true) {
        developer.log('Strategy stopped successfully', name: 'StrategyService');
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to stop strategy',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error stopping strategy: $e', name: 'StrategyService', error: e);
      rethrow;
    }
  }

  /// Update strategy configuration
  ///
  /// Updates the configuration parameters for a strategy.
  ///
  /// Parameters:
  /// - [name]: Strategy name
  /// - [config]: Configuration map with strategy parameters
  ///
  /// Example:
  /// ```dart
  /// await strategyService.updateConfig('rsi_scalping', {
  ///   'rsi_period': 14,
  ///   'rsi_oversold': 30,
  ///   'rsi_overbought': 70,
  ///   'take_profit_pct': 0.8,
  ///   'stop_loss_pct': 0.4,
  /// });
  /// ```
  Future<bool> updateConfig(String name, Map<String, dynamic> config) async {
    try {
      developer.log('Updating config for strategy: $name', name: 'StrategyService');

      final response = await _apiClient.put<Map<String, dynamic>>(
        '$_basePath/$name/config',
        data: config,
      );

      if (response['success'] == true) {
        developer.log('Strategy config updated successfully', name: 'StrategyService');
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to update strategy config',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error updating strategy config: $e', name: 'StrategyService', error: e);
      rethrow;
    }
  }

  /// Get strategy performance metrics
  ///
  /// Returns detailed performance metrics for a specific strategy.
  ///
  /// Parameters:
  /// - [name]: Strategy name
  ///
  /// Example:
  /// ```dart
  /// final performance = await strategyService.getPerformance('rsi_scalping');
  /// print('Sharpe Ratio: ${performance.sharpeRatio}');
  /// ```
  Future<StrategyPerformance> getPerformance(String name) async {
    try {
      developer.log('Fetching performance for strategy: $name', name: 'StrategyService');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_basePath/$name/performance',
      );

      if (response['success'] == true && response['data'] != null) {
        final performance = StrategyPerformance.fromJson(response['data']);
        developer.log('Performance metrics retrieved successfully', name: 'StrategyService');
        return performance;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log('Error getting strategy performance: $e', name: 'StrategyService', error: e);
      rethrow;
    }
  }

  /// Update strategy weight
  ///
  /// Updates the allocation weight for a strategy in the ensemble.
  ///
  /// Parameters:
  /// - [name]: Strategy name
  /// - [weight]: New weight (0.0 to 1.0)
  ///
  /// Example:
  /// ```dart
  /// await strategyService.updateWeight('rsi_scalping', 0.3);
  /// ```
  Future<bool> updateWeight(String name, double weight) async {
    if (weight < 0.0 || weight > 1.0) {
      throw ArgumentError('Weight must be between 0.0 and 1.0');
    }

    try {
      developer.log('Updating weight for strategy: $name', name: 'StrategyService');

      final response = await _apiClient.put<Map<String, dynamic>>(
        '$_basePath/$name/weight',
        data: {
          'weight': weight,
        },
      );

      if (response['success'] == true) {
        developer.log('Strategy weight updated successfully', name: 'StrategyService');
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to update strategy weight',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error updating strategy weight: $e', name: 'StrategyService', error: e);
      rethrow;
    }
  }

  /// Reset strategy performance
  ///
  /// Resets all performance metrics for a strategy.
  ///
  /// Parameters:
  /// - [name]: Strategy name
  ///
  /// Example:
  /// ```dart
  /// await strategyService.resetPerformance('rsi_scalping');
  /// ```
  Future<bool> resetPerformance(String name) async {
    try {
      developer.log('Resetting performance for strategy: $name', name: 'StrategyService');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_basePath/$name/reset',
      );

      if (response['success'] == true) {
        developer.log('Strategy performance reset successfully', name: 'StrategyService');
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to reset strategy performance',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error resetting strategy performance: $e', name: 'StrategyService', error: e);
      rethrow;
    }
  }

  /// Get active strategies
  ///
  /// Returns only the strategies that are currently active.
  ///
  /// Example:
  /// ```dart
  /// final activeStrategies = await strategyService.getActiveStrategies();
  /// print('Active strategies: ${activeStrategies.length}');
  /// ```
  Future<List<Strategy>> getActiveStrategies() async {
    try {
      developer.log('Fetching active strategies...', name: 'StrategyService');

      final allStrategies = await getStrategies();
      final activeStrategies = allStrategies.where((s) => s.active).toList();

      developer.log('Retrieved ${activeStrategies.length} active strategies', name: 'StrategyService');
      return activeStrategies;
    } catch (e) {
      developer.log('Error getting active strategies: $e', name: 'StrategyService', error: e);
      rethrow;
    }
  }

  /// Get top performing strategies
  ///
  /// Returns strategies sorted by performance (Sharpe ratio).
  ///
  /// Parameters:
  /// - [limit]: Maximum number of strategies to return
  ///
  /// Example:
  /// ```dart
  /// final topStrategies = await strategyService.getTopPerformers(limit: 3);
  /// ```
  Future<List<Strategy>> getTopPerformers({int limit = 5}) async {
    try {
      developer.log('Fetching top performing strategies...', name: 'StrategyService');

      final allStrategies = await getStrategies();
      allStrategies.sort((a, b) =>
        b.performance.sharpeRatio.compareTo(a.performance.sharpeRatio)
      );

      final topStrategies = allStrategies.take(limit).toList();

      developer.log('Retrieved ${topStrategies.length} top performers', name: 'StrategyService');
      return topStrategies;
    } catch (e) {
      developer.log('Error getting top performers: $e', name: 'StrategyService', error: e);
      rethrow;
    }
  }
}
