import 'dart:developer' as developer;
import 'api_client.dart';
import 'api_exception.dart';
import '../models/websocket_event.dart';
import '../models/alert_config.dart';

/// Alert Service
///
/// Handles alert management operations:
/// - Configure alert rules
/// - Get alert history
/// - Acknowledge alerts
/// - Dismiss alerts
/// - Get active alerts
class AlertService {
  final ApiClient _apiClient;
  static const String _basePath = '/api/v1/alerts';

  AlertService(this._apiClient);

  /// Configure alerts
  ///
  /// Sends alert configuration to the backend.
  ///
  /// Parameters:
  /// - [config]: Alert configuration object
  ///
  /// Returns true if successful.
  ///
  /// Example:
  /// ```dart
  /// final config = AlertConfig(
  ///   enabled: true,
  ///   telegramToken: 'YOUR_BOT_TOKEN',
  ///   telegramChatId: 'YOUR_CHAT_ID',
  ///   rules: [
  ///     AlertRule(
  ///       name: 'Daily Drawdown Alert',
  ///       type: AlertType.dailyDrawdown,
  ///       threshold: -1000.0,
  ///       severity: AlertSeverity.critical,
  ///     ),
  ///   ],
  /// );
  /// await alertService.configureAlerts(config);
  /// ```
  Future<bool> configureAlerts(AlertConfig config) async {
    try {
      developer.log('Configuring alerts...', name: 'AlertService');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_basePath/configure',
        data: config.toJson(),
      );

      if (response['success'] == true) {
        developer.log('Alerts configured successfully', name: 'AlertService');
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to configure alerts',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error configuring alerts: $e', name: 'AlertService', error: e);
      rethrow;
    }
  }

  /// Get current alert configuration
  ///
  /// Returns the current alert configuration from the backend.
  ///
  /// Example:
  /// ```dart
  /// final config = await alertService.getAlertConfig();
  /// print('Alerts enabled: ${config.enabled}');
  /// ```
  Future<AlertConfig> getAlertConfig() async {
    try {
      developer.log('Fetching alert configuration...', name: 'AlertService');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_basePath/config',
      );

      if (response['success'] == true && response['data'] != null) {
        final config = AlertConfig.fromJson(response['data']);
        developer.log('Alert configuration retrieved', name: 'AlertService');
        return config;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log('Error getting alert config: $e', name: 'AlertService', error: e);
      rethrow;
    }
  }

  /// Get alert history
  ///
  /// Returns historical alerts with optional filtering.
  ///
  /// Parameters:
  /// - [limit]: Maximum number of alerts to return (default: 100)
  /// - [from]: Start date for filtering (ISO 8601 format)
  /// - [to]: End date for filtering (ISO 8601 format)
  /// - [severity]: Filter by severity (info, warning, critical)
  /// - [acknowledged]: Filter by acknowledgment status
  ///
  /// Example:
  /// ```dart
  /// final history = await alertService.getAlertHistory(
  ///   limit: 50,
  ///   severity: 'critical',
  ///   acknowledged: false,
  /// );
  /// ```
  Future<List<Alert>> getAlertHistory({
    int? limit,
    String? from,
    String? to,
    String? severity,
    bool? acknowledged,
  }) async {
    try {
      developer.log('Fetching alert history...', name: 'AlertService');

      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;
      if (severity != null) queryParams['severity'] = severity;
      if (acknowledged != null) queryParams['acknowledged'] = acknowledged;

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_basePath/history',
        queryParameters: queryParams,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        final alerts = data.map((json) => Alert.fromJson(json)).toList();
        developer.log('Retrieved ${alerts.length} alerts', name: 'AlertService');
        return alerts;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log('Error getting alert history: $e', name: 'AlertService', error: e);
      rethrow;
    }
  }

  /// Acknowledge an alert
  ///
  /// Marks an alert as acknowledged by the user.
  ///
  /// Parameters:
  /// - [id]: Alert ID to acknowledge
  ///
  /// Returns true if successful.
  ///
  /// Example:
  /// ```dart
  /// await alertService.acknowledgeAlert('alert_123');
  /// ```
  Future<bool> acknowledgeAlert(String id) async {
    try {
      developer.log('Acknowledging alert: $id', name: 'AlertService');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_basePath/$id/acknowledge',
      );

      if (response['success'] == true) {
        developer.log('Alert acknowledged successfully', name: 'AlertService');
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to acknowledge alert',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error acknowledging alert: $e', name: 'AlertService', error: e);
      rethrow;
    }
  }

  /// Dismiss an alert
  ///
  /// Dismisses an alert, removing it from active alerts.
  ///
  /// Parameters:
  /// - [id]: Alert ID to dismiss
  ///
  /// Returns true if successful.
  ///
  /// Example:
  /// ```dart
  /// await alertService.dismissAlert('alert_123');
  /// ```
  Future<bool> dismissAlert(String id) async {
    try {
      developer.log('Dismissing alert: $id', name: 'AlertService');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_basePath/$id/dismiss',
      );

      if (response['success'] == true) {
        developer.log('Alert dismissed successfully', name: 'AlertService');
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to dismiss alert',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error dismissing alert: $e', name: 'AlertService', error: e);
      rethrow;
    }
  }

  /// Get active alerts
  ///
  /// Returns all unacknowledged alerts.
  ///
  /// Example:
  /// ```dart
  /// final activeAlerts = await alertService.getActiveAlerts();
  /// print('Active alerts: ${activeAlerts.length}');
  /// ```
  Future<List<Alert>> getActiveAlerts() async {
    try {
      developer.log('Fetching active alerts...', name: 'AlertService');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_basePath/active',
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        final alerts = data.map((json) => Alert.fromJson(json)).toList();
        developer.log('Retrieved ${alerts.length} active alerts', name: 'AlertService');
        return alerts;
      }

      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
      );
    } catch (e) {
      developer.log('Error getting active alerts: $e', name: 'AlertService', error: e);
      rethrow;
    }
  }

  /// Add a new alert rule
  ///
  /// Adds a new rule to the alert configuration.
  ///
  /// Parameters:
  /// - [rule]: Alert rule to add
  ///
  /// Returns the created rule with its ID.
  ///
  /// Example:
  /// ```dart
  /// final rule = AlertRule(
  ///   name: 'Price Alert',
  ///   type: AlertType.price,
  ///   symbol: 'BTC-USDT',
  ///   threshold: 50000.0,
  ///   severity: AlertSeverity.warning,
  /// );
  /// final created = await alertService.addAlertRule(rule);
  /// ```
  Future<AlertRule> addAlertRule(AlertRule rule) async {
    try {
      developer.log('Adding alert rule: ${rule.name}', name: 'AlertService');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_basePath/rules',
        data: rule.toJson(),
      );

      if (response['success'] == true && response['data'] != null) {
        final createdRule = AlertRule.fromJson(response['data']);
        developer.log('Alert rule added successfully', name: 'AlertService');
        return createdRule;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to add alert rule',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error adding alert rule: $e', name: 'AlertService', error: e);
      rethrow;
    }
  }

  /// Update an alert rule
  ///
  /// Updates an existing alert rule.
  ///
  /// Parameters:
  /// - [id]: Rule ID to update
  /// - [rule]: Updated rule data
  ///
  /// Returns true if successful.
  ///
  /// Example:
  /// ```dart
  /// final updatedRule = rule.copyWith(threshold: 60000.0);
  /// await alertService.updateAlertRule(rule.id!, updatedRule);
  /// ```
  Future<bool> updateAlertRule(String id, AlertRule rule) async {
    try {
      developer.log('Updating alert rule: $id', name: 'AlertService');

      final response = await _apiClient.put<Map<String, dynamic>>(
        '$_basePath/rules/$id',
        data: rule.toJson(),
      );

      if (response['success'] == true) {
        developer.log('Alert rule updated successfully', name: 'AlertService');
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to update alert rule',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error updating alert rule: $e', name: 'AlertService', error: e);
      rethrow;
    }
  }

  /// Delete an alert rule
  ///
  /// Removes an alert rule from the configuration.
  ///
  /// Parameters:
  /// - [id]: Rule ID to delete
  ///
  /// Returns true if successful.
  ///
  /// Example:
  /// ```dart
  /// await alertService.deleteAlertRule('rule_123');
  /// ```
  Future<bool> deleteAlertRule(String id) async {
    try {
      developer.log('Deleting alert rule: $id', name: 'AlertService');

      final response = await _apiClient.delete<Map<String, dynamic>>(
        '$_basePath/rules/$id',
      );

      if (response['success'] == true) {
        developer.log('Alert rule deleted successfully', name: 'AlertService');
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to delete alert rule',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error deleting alert rule: $e', name: 'AlertService', error: e);
      rethrow;
    }
  }

  /// Test alert configuration
  ///
  /// Sends a test alert to verify Telegram configuration.
  ///
  /// Returns true if test alert was sent successfully.
  ///
  /// Example:
  /// ```dart
  /// final success = await alertService.testAlertConfig();
  /// if (success) {
  ///   print('Test alert sent successfully!');
  /// }
  /// ```
  Future<bool> testAlertConfig() async {
    try {
      developer.log('Testing alert configuration...', name: 'AlertService');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_basePath/test',
      );

      if (response['success'] == true) {
        developer.log('Test alert sent successfully', name: 'AlertService');
        return true;
      }

      throw ApiException(
        message: response['error'] ?? 'Failed to send test alert',
        code: response['code'],
      );
    } catch (e) {
      developer.log('Error testing alert config: $e', name: 'AlertService', error: e);
      rethrow;
    }
  }
}
