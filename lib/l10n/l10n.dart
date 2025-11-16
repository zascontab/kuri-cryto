import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
abstract class L10n {
  L10n(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Dashboard - Scalping Engine
  String get scalpingEngine;

  /// Engine status - Running
  String get running;

  /// Engine status - Stopped
  String get stopped;

  /// Health status - Healthy
  String get healthy;

  /// Health status - Degraded
  String get degraded;

  /// Health status - Down
  String get down;

  /// Uptime label
  String get uptime;

  /// Active Positions label
  String get activePositions;

  /// Total Trades label
  String get totalTrades;

  /// Start Engine button
  String get startEngine;

  /// Stop Engine button
  String get stopEngine;

  /// Start Engine confirmation message
  String get startEngineConfirmation;

  /// Stop Engine confirmation message
  String get stopEngineConfirmation;

  /// Cancel button
  String get cancel;

  /// Start button
  String get start;

  /// Stop button
  String get stop;

  /// Trading Metrics section
  String get tradingMetrics;

  /// Total P&L label
  String get totalPnl;

  /// Daily P&L label
  String get dailyPnl;

  /// Win Rate label
  String get winRate;

  /// Average Latency label
  String get avgLatency;

  /// Milliseconds abbreviation
  String get ms;

  /// Loading state
  String get loading;

  /// Error loading data
  String get errorLoadingData;

  /// Stop engine confirmation message
  String get stopEngineMessage;

  /// Start engine confirmation message
  String get startEngineMessage;

  /// Engine started success message
  String get engineStartedSuccess;

  /// Engine stopped success message
  String get engineStoppedSuccess;

  /// Key Metrics section title
  String get keyMetrics;

  /// Today label
  String get today;

  /// Above target label
  String get aboveTarget;

  /// Below target label
  String get belowTarget;

  /// Open trades label
  String get openTrades;

  /// Excellent rating
  String get excellent;

  /// Good rating
  String get good;

  /// Quick Actions section
  String get quickActions;

  /// Refresh Data action
  String get refreshData;

  /// Last updated now
  String get lastUpdatedNow;

  /// View Analytics action
  String get viewAnalytics;

  /// Detailed charts label
  String get detailedCharts;

  /// Settings
  String get settings;

  /// Language
  String get language;

  /// Select Language
  String get selectLanguage;

  /// English
  String get english;

  /// Spanish
  String get spanish;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
    case 'es':
      return L10nEs();
  }

  throw FlutterError(
      'L10n.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
