// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$alertsHash() => r'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0';

/// Provider for real-time alerts stream via WebSocket
///
/// Provides live updates of alerts as they occur.
/// Uses WebSocket connection for real-time updates with <1s latency.
///
/// Returns Stream<Alert> that emits whenever a new alert is triggered.
///
/// Copied from [alerts].
@ProviderFor(alerts)
final alertsProvider = AutoDisposeStreamProvider<Alert>.internal(
  alerts,
  name: r'alertsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$alertsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AlertsRef = AutoDisposeStreamProviderRef<Alert>;
String _$activeAlertsHash() => r'b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1';

/// Provider for active (unacknowledged) alerts
///
/// Fetches all alerts that haven't been acknowledged by the user.
/// These are the alerts that need immediate attention.
///
/// Example usage:
/// ```dart
/// final activeAlerts = ref.watch(activeAlertsProvider);
/// ```
///
/// Copied from [activeAlerts].
@ProviderFor(activeAlerts)
final activeAlertsProvider = AutoDisposeFutureProvider<List<Alert>>.internal(
  activeAlerts,
  name: r'activeAlertsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$activeAlertsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ActiveAlertsRef = AutoDisposeFutureProviderRef<List<Alert>>;
String _$alertHistoryHash() => r'c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
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
///
/// Copied from [alertHistory].
@ProviderFor(alertHistory)
const alertHistoryProvider = AlertHistoryFamily();

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
///
/// Copied from [alertHistory].
class AlertHistoryFamily extends Family<AsyncValue<List<Alert>>> {
  const AlertHistoryFamily();

  AlertHistoryProvider call({
    int? limit,
    String? severity,
    bool? acknowledged,
  }) {
    return AlertHistoryProvider(
      limit: limit,
      severity: severity,
      acknowledged: acknowledged,
    );
  }

  @override
  AlertHistoryProvider getProviderOverride(
    covariant AlertHistoryProvider provider,
  ) {
    return call(
      limit: provider.limit,
      severity: provider.severity,
      acknowledged: provider.acknowledged,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'alertHistoryProvider';
}

class AlertHistoryProvider
    extends AutoDisposeFutureProvider<List<Alert>> {
  AlertHistoryProvider({
    required int? limit,
    required String? severity,
    required bool? acknowledged,
  }) : this._internal(
          (ref) => alertHistory(
            ref as AlertHistoryRef,
            limit: limit,
            severity: severity,
            acknowledged: acknowledged,
          ),
          from: alertHistoryProvider,
          name: r'alertHistoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$alertHistoryHash,
          dependencies: AlertHistoryFamily._dependencies,
          allTransitiveDependencies:
              AlertHistoryFamily._allTransitiveDependencies,
          limit: limit,
          severity: severity,
          acknowledged: acknowledged,
        );

  AlertHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
    required this.severity,
    required this.acknowledged,
  }) : super.internal();

  final int? limit;
  final String? severity;
  final bool? acknowledged;

  @override
  Override overrideWith(
    FutureOr<List<Alert>> Function(AlertHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AlertHistoryProvider._internal(
        (ref) => create(ref as AlertHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
        severity: severity,
        acknowledged: acknowledged,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Alert>> createElement() {
    return _AlertHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AlertHistoryProvider &&
        other.limit == limit &&
        other.severity == severity &&
        other.acknowledged == acknowledged;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);
    hash = _SystemHash.combine(hash, severity.hashCode);
    hash = _SystemHash.combine(hash, acknowledged.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AlertHistoryRef on AutoDisposeFutureProviderRef<List<Alert>> {
  int? get limit;
  String? get severity;
  bool? get acknowledged;
}

class _AlertHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<Alert>>
    with AlertHistoryRef {
  _AlertHistoryProviderElement(super.provider);

  @override
  int? get limit => (origin as AlertHistoryProvider).limit;
  @override
  String? get severity => (origin as AlertHistoryProvider).severity;
  @override
  bool? get acknowledged => (origin as AlertHistoryProvider).acknowledged;
}

String _$alertConfigHash() => r'd4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3';

/// Provider for current alert configuration
///
/// Fetches the current alert configuration from the backend.
///
/// Example usage:
/// ```dart
/// final config = ref.watch(alertConfigProvider);
/// ```
///
/// Copied from [alertConfig].
@ProviderFor(alertConfig)
final alertConfigProvider = AutoDisposeFutureProvider<AlertConfig>.internal(
  alertConfig,
  name: r'alertConfigProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$alertConfigHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AlertConfigRef = AutoDisposeFutureProviderRef<AlertConfig>;
String _$unacknowledgedAlertCountHash() =>
    r'e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4';

/// Provider for tracking unacknowledged alert count
///
/// Provides a count of active (unacknowledged) alerts for badge display.
///
/// Example usage:
/// ```dart
/// final count = ref.watch(unacknowledgedAlertCountProvider);
/// ```
///
/// Copied from [unacknowledgedAlertCount].
@ProviderFor(unacknowledgedAlertCount)
final unacknowledgedAlertCountProvider =
    AutoDisposeFutureProvider<int>.internal(
  unacknowledgedAlertCount,
  name: r'unacknowledgedAlertCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unacknowledgedAlertCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UnacknowledgedAlertCountRef = AutoDisposeFutureProviderRef<int>;
String _$alertsBySeverityHash() => r'f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5';

/// Provider for alerts grouped by severity
///
/// Groups active alerts by their severity level for organized display.
///
/// Returns a map of severity -> list of alerts.
///
/// Copied from [alertsBySeverity].
@ProviderFor(alertsBySeverity)
final alertsBySeverityProvider =
    AutoDisposeFutureProvider<Map<String, List<Alert>>>.internal(
  alertsBySeverity,
  name: r'alertsBySeverityProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$alertsBySeverityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AlertsBySeverityRef
    = AutoDisposeFutureProviderRef<Map<String, List<Alert>>>;
String _$alertAcknowledgerHash() => r'g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6';

/// Provider for acknowledging an alert
///
/// Marks an alert as acknowledged and invalidates related providers
/// to trigger refresh.
///
/// Copied from [AlertAcknowledger].
@ProviderFor(AlertAcknowledger)
final alertAcknowledgerProvider =
    AutoDisposeAsyncNotifierProvider<AlertAcknowledger, void>.internal(
  AlertAcknowledger.new,
  name: r'alertAcknowledgerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$alertAcknowledgerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AlertAcknowledger = AutoDisposeAsyncNotifier<void>;
String _$alertDismisserHash() => r'h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7';

/// Provider for dismissing an alert
///
/// Dismisses an alert and invalidates related providers to trigger refresh.
///
/// Copied from [AlertDismisser].
@ProviderFor(AlertDismisser)
final alertDismisserProvider =
    AutoDisposeAsyncNotifierProvider<AlertDismisser, void>.internal(
  AlertDismisser.new,
  name: r'alertDismisserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$alertDismisserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AlertDismisser = AutoDisposeAsyncNotifier<void>;
String _$alertConfiguratorHash() => r'i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8';

/// Provider for configuring alerts
///
/// Updates the alert configuration and invalidates related providers.
///
/// Copied from [AlertConfigurator].
@ProviderFor(AlertConfigurator)
final alertConfiguratorProvider =
    AutoDisposeAsyncNotifierProvider<AlertConfigurator, void>.internal(
  AlertConfigurator.new,
  name: r'alertConfiguratorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$alertConfiguratorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AlertConfigurator = AutoDisposeAsyncNotifier<void>;
String _$alertRuleManagerHash() => r'j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9';

/// Provider for managing alert rules
///
/// Handles adding, updating, and deleting alert rules.
///
/// Copied from [AlertRuleManager].
@ProviderFor(AlertRuleManager)
final alertRuleManagerProvider =
    AutoDisposeAsyncNotifierProvider<AlertRuleManager, void>.internal(
  AlertRuleManager.new,
  name: r'alertRuleManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$alertRuleManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AlertRuleManager = AutoDisposeAsyncNotifier<void>;
String _$alertTesterHash() => r'k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0';

/// Provider for testing alert configuration
///
/// Sends a test alert to verify Telegram configuration.
///
/// Copied from [AlertTester].
@ProviderFor(AlertTester)
final alertTesterProvider =
    AutoDisposeAsyncNotifierProvider<AlertTester, void>.internal(
  AlertTester.new,
  name: r'alertTesterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$alertTesterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AlertTester = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
