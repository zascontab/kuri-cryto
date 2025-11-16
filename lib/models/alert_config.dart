/// Alert Configuration Models for Trading MCP Client
///
/// This file contains models for alert configuration including:
/// - AlertConfig: Main configuration for alert system
/// - AlertRule: Individual alert rule definitions
/// - AlertType: Types of alerts that can be configured

import 'package:flutter/foundation.dart';

/// Alert configuration for the trading system
class AlertConfig {
  /// Whether alerts are enabled globally
  final bool enabled;

  /// Telegram bot token for sending alerts
  final String? telegramToken;

  /// Telegram chat ID for receiving alerts
  final String? telegramChatId;

  /// Whether to send alerts via push notifications
  final bool pushNotificationsEnabled;

  /// Whether to send alerts via email
  final bool emailEnabled;

  /// Email address for receiving alerts
  final String? emailAddress;

  /// List of configured alert rules
  final List<AlertRule> rules;

  /// When the configuration was created
  final DateTime createdAt;

  /// When the configuration was last updated
  final DateTime? updatedAt;

  AlertConfig({
    required this.enabled,
    this.telegramToken,
    this.telegramChatId,
    this.pushNotificationsEnabled = true,
    this.emailEnabled = false,
    this.emailAddress,
    this.rules = const [],
    required this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory AlertConfig.fromJson(Map<String, dynamic> json) {
    return AlertConfig(
      enabled: json['enabled'] as bool? ?? false,
      telegramToken: json['telegram_token'] as String?,
      telegramChatId: json['telegram_chat_id'] as String?,
      pushNotificationsEnabled: json['push_notifications_enabled'] as bool? ?? true,
      emailEnabled: json['email_enabled'] as bool? ?? false,
      emailAddress: json['email_address'] as String?,
      rules: json['rules'] != null
          ? (json['rules'] as List<dynamic>)
              .map((r) => AlertRule.fromJson(r as Map<String, dynamic>))
              .toList()
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'telegram_token': telegramToken,
      'telegram_chat_id': telegramChatId,
      'push_notifications_enabled': pushNotificationsEnabled,
      'email_enabled': emailEnabled,
      'email_address': emailAddress,
      'rules': rules.map((r) => r.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  AlertConfig copyWith({
    bool? enabled,
    String? telegramToken,
    String? telegramChatId,
    bool? pushNotificationsEnabled,
    bool? emailEnabled,
    String? emailAddress,
    List<AlertRule>? rules,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AlertConfig(
      enabled: enabled ?? this.enabled,
      telegramToken: telegramToken ?? this.telegramToken,
      telegramChatId: telegramChatId ?? this.telegramChatId,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      emailAddress: emailAddress ?? this.emailAddress,
      rules: rules ?? this.rules,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'AlertConfig(enabled: $enabled, rules: ${rules.length})';
}

/// Individual alert rule definition
class AlertRule {
  /// Unique identifier for the rule
  final String? id;

  /// Rule name
  final String name;

  /// Rule type (daily_drawdown, price, volume, pnl)
  final AlertType type;

  /// Whether this rule is enabled
  final bool enabled;

  /// Threshold value for triggering the alert
  final double threshold;

  /// Symbol to monitor (for price/volume alerts, null for global alerts)
  final String? symbol;

  /// Alert severity when triggered
  final AlertSeverity severity;

  /// Cooldown period in minutes to prevent spam
  final int cooldownMinutes;

  /// Custom message template (optional)
  final String? customMessage;

  /// When the rule was created
  final DateTime? createdAt;

  /// When the rule was last updated
  final DateTime? updatedAt;

  AlertRule({
    this.id,
    required this.name,
    required this.type,
    this.enabled = true,
    required this.threshold,
    this.symbol,
    this.severity = AlertSeverity.warning,
    this.cooldownMinutes = 60,
    this.customMessage,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory AlertRule.fromJson(Map<String, dynamic> json) {
    return AlertRule(
      id: json['id'] as String?,
      name: json['name'] as String,
      type: AlertType.fromString(json['type'] as String),
      enabled: json['enabled'] as bool? ?? true,
      threshold: (json['threshold'] as num).toDouble(),
      symbol: json['symbol'] as String?,
      severity: AlertSeverity.fromString(
        json['severity'] as String? ?? 'warning',
      ),
      cooldownMinutes: json['cooldown_minutes'] as int? ?? 60,
      customMessage: json['custom_message'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type.value,
      'enabled': enabled,
      'threshold': threshold,
      if (symbol != null) 'symbol': symbol,
      'severity': severity.value,
      'cooldown_minutes': cooldownMinutes,
      if (customMessage != null) 'custom_message': customMessage,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  AlertRule copyWith({
    String? id,
    String? name,
    AlertType? type,
    bool? enabled,
    double? threshold,
    String? symbol,
    AlertSeverity? severity,
    int? cooldownMinutes,
    String? customMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AlertRule(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      enabled: enabled ?? this.enabled,
      threshold: threshold ?? this.threshold,
      symbol: symbol ?? this.symbol,
      severity: severity ?? this.severity,
      cooldownMinutes: cooldownMinutes ?? this.cooldownMinutes,
      customMessage: customMessage ?? this.customMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'AlertRule(name: $name, type: ${type.value}, threshold: $threshold)';
}

/// Alert type enumeration
enum AlertType {
  /// Daily drawdown exceeded threshold
  dailyDrawdown('daily_drawdown'),

  /// Price reached threshold
  price('price'),

  /// Volume exceeded threshold
  volume('volume'),

  /// PnL reached threshold
  pnl('pnl'),

  /// Position count exceeded threshold
  positionCount('position_count'),

  /// Win rate below threshold
  winRate('win_rate'),

  /// Consecutive losses exceeded threshold
  consecutiveLosses('consecutive_losses');

  const AlertType(this.value);

  final String value;

  /// Create from string value
  static AlertType fromString(String value) {
    return AlertType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => AlertType.pnl,
    );
  }

  /// Get display name
  String get displayName {
    switch (this) {
      case AlertType.dailyDrawdown:
        return 'Daily Drawdown';
      case AlertType.price:
        return 'Price Alert';
      case AlertType.volume:
        return 'Volume Alert';
      case AlertType.pnl:
        return 'P&L Alert';
      case AlertType.positionCount:
        return 'Position Count';
      case AlertType.winRate:
        return 'Win Rate';
      case AlertType.consecutiveLosses:
        return 'Consecutive Losses';
    }
  }
}

/// Alert severity enumeration
enum AlertSeverity {
  /// Informational alert
  info('info'),

  /// Warning alert
  warning('warning'),

  /// Critical alert
  critical('critical');

  const AlertSeverity(this.value);

  final String value;

  /// Create from string value
  static AlertSeverity fromString(String value) {
    return AlertSeverity.values.firstWhere(
      (severity) => severity.value == value,
      orElse: () => AlertSeverity.info,
    );
  }

  /// Get display name
  String get displayName {
    switch (this) {
      case AlertSeverity.info:
        return 'Info';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }
}
