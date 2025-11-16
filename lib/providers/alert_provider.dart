import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/websocket_event.dart';
import '../models/alert_config.dart';
import 'services_provider.dart';

part 'alert_provider.g.dart';

/// Provider for real-time alerts stream via WebSocket
///
/// Provides live updates of alerts as they occur.
/// Uses WebSocket connection for real-time updates with <1s latency.
///
/// Returns Stream<Alert> that emits whenever a new alert is triggered.
@riverpod
Stream<Alert> alerts(AlertsRef ref) {
  final wsService = ref.watch(websocketServiceProvider);

  // Ensure connection and subscription to alerts channel
  wsService.connect();
  wsService.subscribe(['alerts']);

  return wsService.alerts;
}

/// Provider for active (unacknowledged) alerts
///
/// Fetches all alerts that haven't been acknowledged by the user.
/// These are the alerts that need immediate attention.
///
/// Example usage:
/// ```dart
/// final activeAlerts = ref.watch(activeAlertsProvider);
/// ```
@riverpod
Future<List<Alert>> activeAlerts(ActiveAlertsRef ref) async {
  final service = ref.watch(alertServiceProvider);
  return await service.getActiveAlerts();
}

/// Provider for alert history with optional filtering
///
/// Fetches historical alerts with optional filtering:
/// - limit: Number of alerts to fetch (default: 100)
/// - severity: Filter by severity (info, warning, critical)
/// - acknowledged: Filter by acknowledgment status
///
/// Example usage:
/// ```dart
/// final history = ref.watch(alertHistoryProvider(
///   limit: 50,
///   severity: 'critical',
/// ));
/// ```
@riverpod
Future<List<Alert>> alertHistory(
  AlertHistoryRef ref, {
  int? limit,
  String? severity,
  bool? acknowledged,
}) async {
  final service = ref.watch(alertServiceProvider);

  return await service.getAlertHistory(
    limit: limit,
    severity: severity,
    acknowledged: acknowledged,
  );
}

/// Provider for current alert configuration
///
/// Fetches the current alert configuration from the backend.
///
/// Example usage:
/// ```dart
/// final config = ref.watch(alertConfigProvider);
/// ```
@riverpod
Future<AlertConfig> alertConfig(AlertConfigRef ref) async {
  final service = ref.watch(alertServiceProvider);
  return await service.getAlertConfig();
}

/// Provider for acknowledging an alert
///
/// Marks an alert as acknowledged and invalidates related providers
/// to trigger refresh.
@riverpod
class AlertAcknowledger extends _$AlertAcknowledger {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Acknowledge an alert by ID
  ///
  /// Returns true if successful, throws exception on error.
  Future<bool> acknowledgeAlert(String alertId) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(alertServiceProvider);
      final result = await service.acknowledgeAlert(alertId);

      state = const AsyncValue.data(null);

      // Invalidate active alerts to trigger refresh
      ref.invalidate(activeAlertsProvider);

      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for dismissing an alert
///
/// Dismisses an alert and invalidates related providers to trigger refresh.
@riverpod
class AlertDismisser extends _$AlertDismisser {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Dismiss an alert by ID
  ///
  /// Returns true if successful, throws exception on error.
  Future<bool> dismissAlert(String alertId) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(alertServiceProvider);
      final result = await service.dismissAlert(alertId);

      state = const AsyncValue.data(null);

      // Invalidate active alerts to trigger refresh
      ref.invalidate(activeAlertsProvider);

      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for configuring alerts
///
/// Updates the alert configuration and invalidates related providers.
@riverpod
class AlertConfigurator extends _$AlertConfigurator {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Configure alerts
  ///
  /// Updates the alert configuration in the backend.
  /// Returns true if successful, throws exception on error.
  Future<bool> configureAlerts(AlertConfig config) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(alertServiceProvider);
      final result = await service.configureAlerts(config);

      state = const AsyncValue.data(null);

      // Invalidate alert config to trigger refresh
      ref.invalidate(alertConfigProvider);

      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for managing alert rules
///
/// Handles adding, updating, and deleting alert rules.
@riverpod
class AlertRuleManager extends _$AlertRuleManager {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Add a new alert rule
  ///
  /// Returns the created rule with its ID.
  Future<AlertRule> addRule(AlertRule rule) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(alertServiceProvider);
      final result = await service.addAlertRule(rule);

      state = const AsyncValue.data(null);

      // Invalidate alert config to trigger refresh
      ref.invalidate(alertConfigProvider);

      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Update an existing alert rule
  ///
  /// Returns true if successful.
  Future<bool> updateRule(String ruleId, AlertRule rule) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(alertServiceProvider);
      final result = await service.updateAlertRule(ruleId, rule);

      state = const AsyncValue.data(null);

      // Invalidate alert config to trigger refresh
      ref.invalidate(alertConfigProvider);

      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Delete an alert rule
  ///
  /// Returns true if successful.
  Future<bool> deleteRule(String ruleId) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(alertServiceProvider);
      final result = await service.deleteAlertRule(ruleId);

      state = const AsyncValue.data(null);

      // Invalidate alert config to trigger refresh
      ref.invalidate(alertConfigProvider);

      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for testing alert configuration
///
/// Sends a test alert to verify Telegram configuration.
@riverpod
class AlertTester extends _$AlertTester {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Test alert configuration
  ///
  /// Sends a test alert. Returns true if successful.
  Future<bool> testConfig() async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(alertServiceProvider);
      final result = await service.testAlertConfig();

      state = const AsyncValue.data(null);

      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for tracking unacknowledged alert count
///
/// Provides a count of active (unacknowledged) alerts for badge display.
///
/// Example usage:
/// ```dart
/// final count = ref.watch(unacknowledgedAlertCountProvider);
/// ```
@riverpod
Future<int> unacknowledgedAlertCount(UnacknowledgedAlertCountRef ref) async {
  final activeAlerts = await ref.watch(activeAlertsProvider.future);
  return activeAlerts.where((alert) => !alert.acknowledged).length;
}

/// Provider for alerts grouped by severity
///
/// Groups active alerts by their severity level for organized display.
///
/// Returns a map of severity -> list of alerts.
@riverpod
Future<Map<String, List<Alert>>> alertsBySeverity(
  AlertsBySeverityRef ref,
) async {
  final activeAlerts = await ref.watch(activeAlertsProvider.future);

  final Map<String, List<Alert>> grouped = {
    'critical': [],
    'warning': [],
    'info': [],
  };

  for (final alert in activeAlerts) {
    grouped[alert.severity]?.add(alert);
  }

  return grouped;
}
