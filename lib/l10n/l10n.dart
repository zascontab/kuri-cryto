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

  // Navigation & Main Screen
  String get tradingDashboard;
  String get positions;
  String get strategies;
  String get riskMonitor;
  String get more;
  String get tradingMCP;
  String get home;
  String get risk;

  // More Screen
  String get executionStats;
  String get viewLatencyPerformance;
  String get tradingPairs;
  String get manageTradingPairs;
  String get alerts;
  String get configureNotifications;
  String get appPreferences;
  String get about;
  String get appInformation;
  String get appVersion;
  String get appDescription;
  String get backendVersion;

  // Positions Screen
  String get openPositions;
  String get history;
  String closingPosition({required String positionId});
  String get movingStopLossBreakeven;
  String get enablingTrailingStop;
  String get noOpenPositions;
  String get startEngineToTrade;
  String get closedPositionsHere;
  String get slTpUpdatedSuccess;
  String get editStopLossTakeProfit;
  String get stopLoss;
  String get priceCloseIfLosing;
  String get pleaseEnterStopLoss;
  String get pleaseEnterValidPrice;
  String get takeProfit;
  String get priceCloseIfWinning;
  String get pleaseEnterTakeProfit;
  String get save;

  // Risk Screen
  String get killSwitchActivated;
  String get killSwitchDeactivated;
  String get selectRiskMode;
  String get conservative;
  String get lowerRiskSmallerPositions;
  String get normal;
  String get balancedRiskReward;
  String get aggressive;
  String get higherRiskLargerPositions;
  String riskModeChanged({required String mode});
  String get riskLimitsUpdated;
  String get riskLimits;
  String get editLimits;
  String get maxPositionSize;
  String get maxTotalExposure;
  String get stopLossPercent;
  String get takeProfitPercent;
  String get maxDailyLoss;
  String get maxConsecutiveLosses;
  String get riskMode;
  String get tapToChangeMode;
  String get exposureBySymbol;
  String get editRiskLimits;
  String get pleaseEnterValue;
  String get pleaseEnterValidAmount;
  String get pleaseEnterValidPercentage;
  String get activateKillSwitch;
  String get killSwitchWarning;
  String get allTradingWillStop;
  String get allPositionsWillClose;
  String get requiresManualReactivation;
  String get areYouSure;
  String get activate;
  String get deactivateKillSwitch;
  String get thisWillResumeTrading;
  String get continue_;
  String get confirmDeactivation;
  String get confirmResumeTrading;
  String get resume;
  String errorOccurred({required String error});
  String get ok;
  String get dismiss;
  String get killSwitchActive;
  String get tradingDisabled;
  String get retry;

  // Strategies Screen
  String get strategiesOverview;
  String get active;
  String get avgWinRate;
  String get availableStrategies;
  String strategyActivated({required String name});
  String strategyDeactivated({required String name});
  String get performanceMetrics;
  String get weight;
  String get avgWin;
  String get avgLoss;
  String get configuration;
  String get strategyConfigUpdated;
  String configureStrategy({required String name});

  // Multi-Timeframe Analysis
  String get multiTimeframeAnalysis;
  String get technicalAnalysisMultipleTimeframes;
  String get symbol;
  String get consensusSignal;
  String get currentPrice;
  String get signal;
  String get confidence;
  String get tradingSignal;
  String get technicalIndicators;
  String get recommendation;
  String get selectSymbolToAnalyze;

  // Backtesting
  String get backtesting;
  String get testStrategiesWithHistoricalData;
  String get newBacktest;
  String get backtestConfiguration;
  String get strategy;
  String get dateRange;
  String get startDate;
  String get endDate;
  String get initialCapital;
  String get enterAmount;
  String get runBacktest;
  String get backtestStarted;
  String get error;
  String get backtestRunning;
  String get backtestFailed;
  String get backToForm;
  String get equityCurve;
  String get tradeHistory;
  String get entryTime;
  String get exitTime;
  String get side;
  String get entryPrice;
  String get exitPrice;
  String get pnl;
  String get showing;
  String get of;
  String get trades;
  String get noBacktestsYet;
  String get profitFactor;
  String get sharpeRatio;
  String get maxDrawdown;

  // Parameter Optimization
  String get parameterOptimization;
  String get optimizeStrategyParameters;
  String get newOptimization;
  String get optimizationConfiguration;
  String get parameterRanges;
  String get addParameter;
  String get editParameter;
  String get parameterName;
  String get minimumValue;
  String get maximumValue;
  String get stepSize;
  String get noParametersConfigured;
  String get optimizationMethod;
  String get gridSearch;
  String get gridSearchDesc;
  String get randomSearch;
  String get randomSearchDesc;
  String get bayesianOptimization;
  String get bayesianOptimizationDesc;
  String get maxIterations;
  String get objectiveToOptimize;
  String get sharpeRatioDesc;
  String get totalPnlDesc;
  String get winRateDesc;
  String get optimizationSummary;
  String get estimatedCombinations;
  String get pleaseFixConfigurationErrors;
  String get runOptimization;
  String get optimizationStarted;
  String get optimizationResults;
  String get loadingResults;
  String get optimizationRunning;
  String get combinations;
  String get estimatedTimeRemaining;
  String get cancelOptimization;
  String get optimizationFailed;
  String get optimizationCancelled;
  String get goBack;
  String get bestParameters;
  String get score;
  String get applyTheseParameters;
  String get scoreDistribution;
  String get allResults;
  String get sortBy;
  String get rank;
  String get parameters;
  String get results;
  String get applyParameters;
  String get applyParametersConfirmation;
  String get apply;
  String get parametersAppliedSuccessfully;
  String get cancelOptimizationConfirmation;
  String get no;
  String get yes;
  String get optimizationCancelledSuccessfully;
  String get noOptimizationsYet;
  String get started;
  String get bestScore;
  String get totalCombinations;
  String get deleteOptimization;
  String get deleteOptimizationConfirmation;
  String get delete;
  String get optimizationDeletedSuccessfully;
  String get completed;
  String get failed;
  String get cancelled;
  String get min;
  String get max;
  String get step;
  String get pleaseEnterValidNumber;
  String get add;
  String get duration;
  String get objective;

  // Execution Stats Screen
  String get latency;
  String get queue;
  String get performance;
  String get latencyStatistics;
  String get average;
  String get median;
  String get percentile95;
  String get percentile99;
  String get maximum;
  String get minimum;
  String get executionsTracked;
  String get executionHistory;
  String get filled;
  String get partial;
  String get rejected;
  String get all;
  String get filterByStatus;
  String get noExecutionsYet;
  String get executionQueue;
  String get queueEmpty;
  String get queueLength;
  String get avgWaitTime;
  String get queueStatus;
  String get orderId;
  String get orderType;
  String get queuePosition;
  String get timeInQueue;
  String get executionPerformance;
  String get fillRate;
  String get avgSlippage;
  String get successfulExecutions;
  String get failedExecutions;
  String get errorRate;
  String get avgExecutionTime;
  String get slippageBySymbol;
  String get successRateBySymbol;
  String get basisPoints;
  String get refreshStats;
  String get exportMetrics;
  String get selectPeriod;
  String get selectFormat;
  String get selectMetrics;
  String get export;
  String get exportSuccess;
  String get downloadFile;
  String get period7d;
  String get period30d;
  String get period90d;
  String get periodAll;

  // Performance Charts Screen
  String get performanceCharts;
  String get pnlChart;
  String get winRateChart;
  String get drawdownChart;
  String get latencyChart;
  String get daily;
  String get weekly;
  String get monthly;
  String get filterByStrategy;
  String get filterBySymbol;
  String get allStrategies;
  String get allSymbols;
  String get noDataAvailable;
  String get loadingCharts;
  String get price;
  String get size;
  String get time;
  String get status;

  // Trading Pairs Screen
  String get addPair;
  String get noTradingPairs;
  String get tapAddPairToStart;
  String get removePair;
  String removePairConfirmation({required String exchange, required String symbol});
  String get remove;
  String get cannotRemovePair;
  String cannotRemovePairWithPositions({required int count});
  String pairRemovedSuccess({required String symbol});
  String pairAddedSuccess({required String symbol});
  String get addNewPair;
  String get exchange;
  String get pleaseSelectExchange;
  String get searchPairs;
  String get noPairsFound;
  String get selectedPair;
  String get inactive;
  String get notAvailable;
  String get lastPrice;
  String get volume24h;
  String get exposure;

  // Alerts Screen
  String get activeAlerts;
  String get alertConfiguration;
  String get noActiveAlerts;
  String get allClear;
  String get noAlertsYet;
  String get alertHistoryWillAppearHere;
  String get manageAlertRules;
  String get configureAlertConditions;
  String get testAlertSystem;
  String get sendTestAlert;
  String get alertAcknowledged;
  String get alertDismissed;
  String get trigger;
  String get value;
  String get acknowledge;
  String get errorLoadingAlerts;
  String get enableAlerts;
  String get toggleAlertSystem;
  String get notificationSettings;
  String get pushNotifications;
  String get inAppNotifications;
  String get telegramConfiguration;
  String get telegramBotToken;
  String get telegramChatId;
  String get pleaseEnterTelegramToken;
  String get pleaseEnterTelegramChatId;
  String get telegramSetupInstructions;
  String get alertRules;
  String get addRule;
  String get noAlertRulesYet;
  String get tapAddToCreateRule;
  String get type;
  String get threshold;
  String get edit;
  String get delete;
  String get errorLoadingConfiguration;
  String get alertConfigurationSaved;
  String get ruleAdded;
  String get ruleUpdated;
  String get deleteRule;
  String confirmDeleteRule({required String name});
  String get ruleDeleted;
  String get addAlertRule;
  String get editAlertRule;
  String get ruleName;
  String get pleaseEnterRuleName;
  String get alertType;
  String get pleaseEnterValidNumber;
  String get severity;
  String get cooldownMinutes;
  String get preventDuplicateAlerts;
  String get testAlertSent;
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
