import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
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
    Locale('es')
  ];

  /// No description provided for @scalpingEngine.
  ///
  /// In en, this message translates to:
  /// **'Scalping Engine'**
  String get scalpingEngine;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @stopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get stopped;

  /// No description provided for @healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthy;

  /// No description provided for @degraded.
  ///
  /// In en, this message translates to:
  /// **'Degraded'**
  String get degraded;

  /// No description provided for @down.
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get down;

  /// No description provided for @uptime.
  ///
  /// In en, this message translates to:
  /// **'Uptime'**
  String get uptime;

  /// No description provided for @activePositions.
  ///
  /// In en, this message translates to:
  /// **'Active Positions'**
  String get activePositions;

  /// No description provided for @totalTrades.
  ///
  /// In en, this message translates to:
  /// **'Total Trades'**
  String get totalTrades;

  /// No description provided for @startEngine.
  ///
  /// In en, this message translates to:
  /// **'Start Engine'**
  String get startEngine;

  /// No description provided for @stopEngine.
  ///
  /// In en, this message translates to:
  /// **'Stop Engine'**
  String get stopEngine;

  /// No description provided for @startEngineConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to start the trading engine?'**
  String get startEngineConfirmation;

  /// No description provided for @stopEngineConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to stop the trading engine? All positions will be closed.'**
  String get stopEngineConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @tradingMetrics.
  ///
  /// In en, this message translates to:
  /// **'Trading Metrics'**
  String get tradingMetrics;

  /// No description provided for @totalPnl.
  ///
  /// In en, this message translates to:
  /// **'Total P&L'**
  String get totalPnl;

  /// No description provided for @dailyPnl.
  ///
  /// In en, this message translates to:
  /// **'Daily P&L'**
  String get dailyPnl;

  /// No description provided for @winRate.
  ///
  /// In en, this message translates to:
  /// **'Win Rate'**
  String get winRate;

  /// No description provided for @avgLatency.
  ///
  /// In en, this message translates to:
  /// **'Avg Latency'**
  String get avgLatency;

  /// milliseconds abbreviation
  ///
  /// In en, this message translates to:
  /// **'ms'**
  String get ms;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @stopEngineMessage.
  ///
  /// In en, this message translates to:
  /// **'This will stop the scalping engine. Open positions will remain active. Continue?'**
  String get stopEngineMessage;

  /// No description provided for @startEngineMessage.
  ///
  /// In en, this message translates to:
  /// **'This will start the scalping engine and begin trading. Continue?'**
  String get startEngineMessage;

  /// No description provided for @engineStartedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Engine started successfully'**
  String get engineStartedSuccess;

  /// No description provided for @engineStoppedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Engine stopped successfully'**
  String get engineStoppedSuccess;

  /// No description provided for @keyMetrics.
  ///
  /// In en, this message translates to:
  /// **'Key Metrics'**
  String get keyMetrics;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get today;

  /// No description provided for @aboveTarget.
  ///
  /// In en, this message translates to:
  /// **'Above target'**
  String get aboveTarget;

  /// No description provided for @belowTarget.
  ///
  /// In en, this message translates to:
  /// **'Below target'**
  String get belowTarget;

  /// No description provided for @openTrades.
  ///
  /// In en, this message translates to:
  /// **'Open trades'**
  String get openTrades;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @refreshData.
  ///
  /// In en, this message translates to:
  /// **'Refresh Data'**
  String get refreshData;

  /// No description provided for @lastUpdatedNow.
  ///
  /// In en, this message translates to:
  /// **'Last updated just now'**
  String get lastUpdatedNow;

  /// No description provided for @viewAnalytics.
  ///
  /// In en, this message translates to:
  /// **'View Analytics'**
  String get viewAnalytics;

  /// No description provided for @detailedCharts.
  ///
  /// In en, this message translates to:
  /// **'Detailed performance charts'**
  String get detailedCharts;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @openPositions.
  ///
  /// In en, this message translates to:
  /// **'Open Positions'**
  String get openPositions;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @closingPosition.
  ///
  /// In en, this message translates to:
  /// **'Closing position {positionId}...'**
  String closingPosition(String positionId);

  /// No description provided for @movingStopLossBreakeven.
  ///
  /// In en, this message translates to:
  /// **'Moving stop loss to breakeven...'**
  String get movingStopLossBreakeven;

  /// No description provided for @enablingTrailingStop.
  ///
  /// In en, this message translates to:
  /// **'Enabling trailing stop...'**
  String get enablingTrailingStop;

  /// No description provided for @noOpenPositions.
  ///
  /// In en, this message translates to:
  /// **'No Open Positions'**
  String get noOpenPositions;

  /// No description provided for @startEngineToTrade.
  ///
  /// In en, this message translates to:
  /// **'Start the engine to begin trading'**
  String get startEngineToTrade;

  /// No description provided for @closedPositionsHere.
  ///
  /// In en, this message translates to:
  /// **'Your closed positions will appear here'**
  String get closedPositionsHere;

  /// No description provided for @slTpUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'SL/TP updated successfully'**
  String get slTpUpdatedSuccess;

  /// No description provided for @editStopLossTakeProfit.
  ///
  /// In en, this message translates to:
  /// **'Edit Stop Loss & Take Profit'**
  String get editStopLossTakeProfit;

  /// No description provided for @stopLoss.
  ///
  /// In en, this message translates to:
  /// **'Stop Loss'**
  String get stopLoss;

  /// No description provided for @priceCloseIfLosing.
  ///
  /// In en, this message translates to:
  /// **'Price to close position if losing'**
  String get priceCloseIfLosing;

  /// No description provided for @pleaseEnterStopLoss.
  ///
  /// In en, this message translates to:
  /// **'Please enter stop loss price'**
  String get pleaseEnterStopLoss;

  /// No description provided for @pleaseEnterValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get pleaseEnterValidPrice;

  /// No description provided for @takeProfit.
  ///
  /// In en, this message translates to:
  /// **'Take Profit'**
  String get takeProfit;

  /// No description provided for @priceCloseIfWinning.
  ///
  /// In en, this message translates to:
  /// **'Price to close position if winning'**
  String get priceCloseIfWinning;

  /// No description provided for @pleaseEnterTakeProfit.
  ///
  /// In en, this message translates to:
  /// **'Please enter take profit price'**
  String get pleaseEnterTakeProfit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @killSwitchActivated.
  ///
  /// In en, this message translates to:
  /// **'Kill Switch ACTIVATED - All trading stopped'**
  String get killSwitchActivated;

  /// No description provided for @killSwitchDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Kill Switch deactivated - Trading resumed'**
  String get killSwitchDeactivated;

  /// No description provided for @selectRiskMode.
  ///
  /// In en, this message translates to:
  /// **'Select Risk Mode'**
  String get selectRiskMode;

  /// No description provided for @conservative.
  ///
  /// In en, this message translates to:
  /// **'Conservative'**
  String get conservative;

  /// No description provided for @lowerRiskSmallerPositions.
  ///
  /// In en, this message translates to:
  /// **'Lower risk, smaller positions'**
  String get lowerRiskSmallerPositions;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @balancedRiskReward.
  ///
  /// In en, this message translates to:
  /// **'Balanced risk and reward'**
  String get balancedRiskReward;

  /// No description provided for @aggressive.
  ///
  /// In en, this message translates to:
  /// **'Aggressive'**
  String get aggressive;

  /// No description provided for @higherRiskLargerPositions.
  ///
  /// In en, this message translates to:
  /// **'Higher risk, larger positions'**
  String get higherRiskLargerPositions;

  /// No description provided for @riskModeChanged.
  ///
  /// In en, this message translates to:
  /// **'Risk mode changed to {mode}'**
  String riskModeChanged(String mode);

  /// No description provided for @riskLimitsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Risk limits updated successfully'**
  String get riskLimitsUpdated;

  /// No description provided for @riskLimits.
  ///
  /// In en, this message translates to:
  /// **'Risk Limits'**
  String get riskLimits;

  /// No description provided for @editLimits.
  ///
  /// In en, this message translates to:
  /// **'Edit limits'**
  String get editLimits;

  /// No description provided for @maxPositionSize.
  ///
  /// In en, this message translates to:
  /// **'Max Position Size'**
  String get maxPositionSize;

  /// No description provided for @maxTotalExposure.
  ///
  /// In en, this message translates to:
  /// **'Max Total Exposure'**
  String get maxTotalExposure;

  /// No description provided for @stopLossPercent.
  ///
  /// In en, this message translates to:
  /// **'Stop Loss %'**
  String get stopLossPercent;

  /// No description provided for @takeProfitPercent.
  ///
  /// In en, this message translates to:
  /// **'Take Profit %'**
  String get takeProfitPercent;

  /// No description provided for @maxDailyLoss.
  ///
  /// In en, this message translates to:
  /// **'Max Daily Loss'**
  String get maxDailyLoss;

  /// No description provided for @riskMode.
  ///
  /// In en, this message translates to:
  /// **'Risk Mode'**
  String get riskMode;

  /// No description provided for @tapToChangeMode.
  ///
  /// In en, this message translates to:
  /// **'Tap to change mode'**
  String get tapToChangeMode;

  /// No description provided for @exposureBySymbol.
  ///
  /// In en, this message translates to:
  /// **'Exposure by Symbol'**
  String get exposureBySymbol;

  /// No description provided for @editRiskLimits.
  ///
  /// In en, this message translates to:
  /// **'Edit Risk Limits'**
  String get editRiskLimits;

  /// No description provided for @pleaseEnterValue.
  ///
  /// In en, this message translates to:
  /// **'Please enter a value'**
  String get pleaseEnterValue;

  /// No description provided for @pleaseEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get pleaseEnterValidAmount;

  /// No description provided for @pleaseEnterValidPercentage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid percentage'**
  String get pleaseEnterValidPercentage;

  /// No description provided for @strategiesOverview.
  ///
  /// In en, this message translates to:
  /// **'Strategies Overview'**
  String get strategiesOverview;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @avgWinRate.
  ///
  /// In en, this message translates to:
  /// **'Avg Win Rate'**
  String get avgWinRate;

  /// No description provided for @availableStrategies.
  ///
  /// In en, this message translates to:
  /// **'Available Strategies'**
  String get availableStrategies;

  /// No description provided for @strategyActivated.
  ///
  /// In en, this message translates to:
  /// **'Strategy \"{name}\" activated'**
  String strategyActivated(String name);

  /// No description provided for @strategyDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Strategy \"{name}\" deactivated'**
  String strategyDeactivated(String name);

  /// No description provided for @performanceMetrics.
  ///
  /// In en, this message translates to:
  /// **'Performance Metrics'**
  String get performanceMetrics;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @avgWin.
  ///
  /// In en, this message translates to:
  /// **'Avg Win'**
  String get avgWin;

  /// No description provided for @avgLoss.
  ///
  /// In en, this message translates to:
  /// **'Avg Loss'**
  String get avgLoss;

  /// No description provided for @configuration.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get configuration;

  /// No description provided for @strategyConfigUpdated.
  ///
  /// In en, this message translates to:
  /// **'Strategy configuration updated'**
  String get strategyConfigUpdated;

  /// No description provided for @configureStrategy.
  ///
  /// In en, this message translates to:
  /// **'Configure {name}'**
  String configureStrategy(String name);

  /// No description provided for @tradingDashboard.
  ///
  /// In en, this message translates to:
  /// **'Trading Dashboard'**
  String get tradingDashboard;

  /// No description provided for @positions.
  ///
  /// In en, this message translates to:
  /// **'Positions'**
  String get positions;

  /// No description provided for @strategies.
  ///
  /// In en, this message translates to:
  /// **'Strategies'**
  String get strategies;

  /// No description provided for @riskMonitor.
  ///
  /// In en, this message translates to:
  /// **'Risk Monitor'**
  String get riskMonitor;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @tradingMCP.
  ///
  /// In en, this message translates to:
  /// **'Trading MCP'**
  String get tradingMCP;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @risk.
  ///
  /// In en, this message translates to:
  /// **'Risk'**
  String get risk;

  /// No description provided for @executionStats.
  ///
  /// In en, this message translates to:
  /// **'Execution Stats'**
  String get executionStats;

  /// No description provided for @viewLatencyPerformance.
  ///
  /// In en, this message translates to:
  /// **'View latency and performance'**
  String get viewLatencyPerformance;

  /// No description provided for @tradingPairs.
  ///
  /// In en, this message translates to:
  /// **'Trading Pairs'**
  String get tradingPairs;

  /// No description provided for @manageTradingPairs.
  ///
  /// In en, this message translates to:
  /// **'Manage trading pairs'**
  String get manageTradingPairs;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @configureNotifications.
  ///
  /// In en, this message translates to:
  /// **'Configure notifications'**
  String get configureNotifications;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App preferences'**
  String get appPreferences;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appInformation.
  ///
  /// In en, this message translates to:
  /// **'App information'**
  String get appInformation;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'1.0.0'**
  String get appVersion;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Advanced cryptocurrency trading automation platform'**
  String get appDescription;

  /// No description provided for @backendVersion.
  ///
  /// In en, this message translates to:
  /// **'Backend: Trading MCP Server v1.0.0'**
  String get backendVersion;

  /// Title for AI Bot control panel
  ///
  /// In en, this message translates to:
  /// **'AI Bot Control'**
  String get aiBotTitle;

  /// Label for AI Bot status
  ///
  /// In en, this message translates to:
  /// **'Bot Status'**
  String get aiBotStatus;

  /// AI Bot status: running
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get aiBotRunning;

  /// AI Bot status: paused
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get aiBotPaused;

  /// AI Bot status: stopped
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get aiBotStopped;

  /// Button to start AI Bot
  ///
  /// In en, this message translates to:
  /// **'Start Bot'**
  String get aiBotStart;

  /// Button to stop AI Bot
  ///
  /// In en, this message translates to:
  /// **'Stop Bot'**
  String get aiBotStop;

  /// Button to pause AI Bot
  ///
  /// In en, this message translates to:
  /// **'Pause Bot'**
  String get aiBotPause;

  /// Button to resume AI Bot
  ///
  /// In en, this message translates to:
  /// **'Resume Bot'**
  String get aiBotResume;

  /// Button for emergency stop of AI Bot
  ///
  /// In en, this message translates to:
  /// **'Emergency Stop'**
  String get aiBotEmergencyStop;

  /// Number of analyses performed by AI Bot
  ///
  /// In en, this message translates to:
  /// **'Analyses'**
  String get aiBotAnalysisCount;

  /// Number of executions performed by AI Bot
  ///
  /// In en, this message translates to:
  /// **'Executions'**
  String get aiBotExecutionCount;

  /// Number of errors encountered by AI Bot
  ///
  /// In en, this message translates to:
  /// **'Errors'**
  String get aiBotErrorCount;

  /// Number of open positions for AI Bot
  ///
  /// In en, this message translates to:
  /// **'Open Positions'**
  String get aiBotOpenPositions;

  /// Daily loss for AI Bot
  ///
  /// In en, this message translates to:
  /// **'Daily Loss'**
  String get aiBotDailyLoss;

  /// Number of daily trades for AI Bot
  ///
  /// In en, this message translates to:
  /// **'Daily Trades'**
  String get aiBotDailyTrades;

  /// Confirmation message before starting AI Bot
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to start the AI Bot?'**
  String get aiBotConfirmStart;

  /// Confirmation message before stopping AI Bot
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to stop the AI Bot?'**
  String get aiBotConfirmStop;

  /// Confirmation message before emergency stop
  ///
  /// In en, this message translates to:
  /// **'Emergency stop will immediately halt all AI Bot operations. Continue?'**
  String get aiBotConfirmEmergency;

  /// Success message when AI Bot starts
  ///
  /// In en, this message translates to:
  /// **'AI Bot started successfully'**
  String get aiBotStartedSuccess;

  /// Success message when AI Bot stops
  ///
  /// In en, this message translates to:
  /// **'AI Bot stopped successfully'**
  String get aiBotStoppedSuccess;

  /// AI Bot configuration section
  ///
  /// In en, this message translates to:
  /// **'Bot Configuration'**
  String get aiBotConfig;

  /// Title for AI Bot configuration screen
  ///
  /// In en, this message translates to:
  /// **'Configure AI Bot'**
  String get aiBotConfigTitle;

  /// Button to save AI Bot configuration
  ///
  /// In en, this message translates to:
  /// **'Save Configuration'**
  String get aiBotConfigSave;

  /// AI Bot dry run mode (simulation)
  ///
  /// In en, this message translates to:
  /// **'Dry Run Mode'**
  String get aiBotDryRun;

  /// AI Bot live trading mode
  ///
  /// In en, this message translates to:
  /// **'Live Trading Mode'**
  String get aiBotLiveMode;

  /// AI Bot auto execution toggle
  ///
  /// In en, this message translates to:
  /// **'Auto Execute'**
  String get aiBotAutoExecute;

  /// Minimum confidence threshold for AI Bot
  ///
  /// In en, this message translates to:
  /// **'Confidence Threshold'**
  String get aiBotConfidenceThreshold;

  /// Trade size for AI Bot
  ///
  /// In en, this message translates to:
  /// **'Trade Size'**
  String get aiBotTradeSize;

  /// Leverage for AI Bot
  ///
  /// In en, this message translates to:
  /// **'Leverage'**
  String get aiBotLeverage;

  /// Maximum daily loss limit for AI Bot
  ///
  /// In en, this message translates to:
  /// **'Max Daily Loss'**
  String get aiBotMaxDailyLoss;

  /// Maximum daily trades limit for AI Bot
  ///
  /// In en, this message translates to:
  /// **'Max Daily Trades'**
  String get aiBotMaxDailyTrades;

  /// Trading pair for AI Bot
  ///
  /// In en, this message translates to:
  /// **'Trading Pair'**
  String get aiBotTradingPair;

  /// Conservative preset for AI Bot configuration
  ///
  /// In en, this message translates to:
  /// **'Conservative'**
  String get aiBotPresetConservative;

  /// Intermediate preset for AI Bot configuration
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get aiBotPresetIntermediate;

  /// Aggressive preset for AI Bot configuration
  ///
  /// In en, this message translates to:
  /// **'Aggressive'**
  String get aiBotPresetAggressive;

  /// Warning message for live trading mode
  ///
  /// In en, this message translates to:
  /// **'Warning: Live trading mode will execute real trades with real funds'**
  String get aiBotWarningLiveMode;

  /// Success message when AI Bot config is updated
  ///
  /// In en, this message translates to:
  /// **'AI Bot configuration updated successfully'**
  String get aiBotConfigUpdated;

  /// Title for comprehensive analysis screen
  ///
  /// In en, this message translates to:
  /// **'Market Analysis'**
  String get analysisTitle;

  /// Button to refresh market analysis
  ///
  /// In en, this message translates to:
  /// **'Refresh Analysis'**
  String get analysisRefresh;

  /// Loading message for market analysis
  ///
  /// In en, this message translates to:
  /// **'Analyzing market data...'**
  String get analysisLoading;

  /// Technical analysis section
  ///
  /// In en, this message translates to:
  /// **'Technical Analysis'**
  String get analysisTechnical;

  /// Multi-timeframe analysis section
  ///
  /// In en, this message translates to:
  /// **'Multi-Timeframe Analysis'**
  String get analysisMultiTimeframe;

  /// Trading recommendation section
  ///
  /// In en, this message translates to:
  /// **'Trading Recommendation'**
  String get analysisRecommendation;

  /// Trading scenarios section
  ///
  /// In en, this message translates to:
  /// **'Scenarios'**
  String get analysisScenarios;

  /// Risk analysis section
  ///
  /// In en, this message translates to:
  /// **'Risk Analysis'**
  String get analysisRisk;

  /// Market condition: oversold
  ///
  /// In en, this message translates to:
  /// **'Oversold'**
  String get analysisOversold;

  /// Market condition: overbought
  ///
  /// In en, this message translates to:
  /// **'Overbought'**
  String get analysisOverbought;

  /// Market condition: neutral
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get analysisNeutral;

  /// Market sentiment: bullish
  ///
  /// In en, this message translates to:
  /// **'Bullish'**
  String get analysisBullish;

  /// Market sentiment: bearish
  ///
  /// In en, this message translates to:
  /// **'Bearish'**
  String get analysisBearish;

  /// Risk level: low
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get analysisLowRisk;

  /// Risk level: medium
  ///
  /// In en, this message translates to:
  /// **'Medium Risk'**
  String get analysisMediumRisk;

  /// Risk level: high
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get analysisHighRisk;

  /// Analysis confidence level
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get analysisConfidence;

  /// Recommended entry price
  ///
  /// In en, this message translates to:
  /// **'Entry Price'**
  String get analysisEntry;

  /// Recommended stop loss price
  ///
  /// In en, this message translates to:
  /// **'Stop Loss'**
  String get analysisStopLoss;

  /// Recommended take profit price
  ///
  /// In en, this message translates to:
  /// **'Take Profit'**
  String get analysisTakeProfit;

  /// Title for futures positions
  ///
  /// In en, this message translates to:
  /// **'Futures Positions'**
  String get futuresPositions;

  /// Button to close a futures position
  ///
  /// In en, this message translates to:
  /// **'Close Position'**
  String get futuresClose;

  /// Button to close all futures positions
  ///
  /// In en, this message translates to:
  /// **'Close All Positions'**
  String get futuresCloseAll;

  /// Confirmation message before closing futures position
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close this position?'**
  String get futuresCloseConfirm;

  /// Success message when futures position is closed
  ///
  /// In en, this message translates to:
  /// **'Position closed successfully'**
  String get futuresClosedSuccess;

  /// Size of futures position
  ///
  /// In en, this message translates to:
  /// **'Position Size'**
  String get futuresSize;

  /// Leverage for futures position
  ///
  /// In en, this message translates to:
  /// **'Leverage'**
  String get futuresLeverage;

  /// Margin for futures position
  ///
  /// In en, this message translates to:
  /// **'Margin'**
  String get futuresMargin;

  /// Liquidation price for futures position
  ///
  /// In en, this message translates to:
  /// **'Liquidation Price'**
  String get futuresLiquidation;

  /// Unrealized profit and loss
  ///
  /// In en, this message translates to:
  /// **'Unrealized P&L'**
  String get futuresUnrealizedPnl;

  /// Realized profit and loss
  ///
  /// In en, this message translates to:
  /// **'Realized P&L'**
  String get futuresRealizedPnl;

  /// Total profit and loss
  ///
  /// In en, this message translates to:
  /// **'Total P&L'**
  String get futuresTotalPnl;

  /// Generic confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Generic error label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Generic success label
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Generic refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Generic back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Generic close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Title for multi-timeframe analysis
  ///
  /// In en, this message translates to:
  /// **'Multi-Timeframe Analysis'**
  String get multiTimeframeAnalysis;

  /// Description for multi-timeframe analysis
  ///
  /// In en, this message translates to:
  /// **'Technical analysis across multiple timeframes'**
  String get technicalAnalysisMultipleTimeframes;

  /// Title for backtesting feature
  ///
  /// In en, this message translates to:
  /// **'Backtesting'**
  String get backtesting;

  /// Description for backtesting
  ///
  /// In en, this message translates to:
  /// **'Test strategies with historical data'**
  String get testStrategiesWithHistoricalData;

  /// Title for parameter optimization
  ///
  /// In en, this message translates to:
  /// **'Parameter Optimization'**
  String get parameterOptimization;

  /// Description for parameter optimization
  ///
  /// In en, this message translates to:
  /// **'Optimize strategy parameters'**
  String get optimizeStrategyParameters;

  /// Title for performance charts
  ///
  /// In en, this message translates to:
  /// **'Performance Charts'**
  String get performanceCharts;

  /// Message when emergency stop is activated
  ///
  /// In en, this message translates to:
  /// **'Emergency Stop Activated'**
  String get emergencyStopActivated;

  /// Success message when bot is resumed
  ///
  /// In en, this message translates to:
  /// **'Bot resumed successfully'**
  String get botResumedSuccess;

  /// Label for mode setting
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// Section title for bot metrics
  ///
  /// In en, this message translates to:
  /// **'Bot Metrics'**
  String get botMetrics;

  /// Label for total count
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Label for executed items
  ///
  /// In en, this message translates to:
  /// **'Executed'**
  String get executed;

  /// Label for percentage used
  ///
  /// In en, this message translates to:
  /// **'% used'**
  String get percentUsed;

  /// Section title for daily limits
  ///
  /// In en, this message translates to:
  /// **'Daily Limits'**
  String get dailyLimits;

  /// Label for consecutive count
  ///
  /// In en, this message translates to:
  /// **'consecutive'**
  String get consecutive;

  /// Section title for trading mode
  ///
  /// In en, this message translates to:
  /// **'Trading Mode'**
  String get tradingMode;

  /// Description for simulation/dry run mode
  ///
  /// In en, this message translates to:
  /// **'Simulation mode - no real trades'**
  String get simulationMode;

  /// Description for auto execute toggle
  ///
  /// In en, this message translates to:
  /// **'Automatically execute AI recommendations'**
  String get autoExecuteDescription;

  /// Section title for trading parameters
  ///
  /// In en, this message translates to:
  /// **'Trading Parameters'**
  String get tradingParameters;

  /// Description for confidence threshold
  ///
  /// In en, this message translates to:
  /// **'Minimum confidence required for trades'**
  String get minimumConfidenceDescription;

  /// Description for leverage setting
  ///
  /// In en, this message translates to:
  /// **'Trading leverage multiplier'**
  String get leverageDescription;

  /// Validation message for required field
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// Validation message for positive number
  ///
  /// In en, this message translates to:
  /// **'Must be positive'**
  String get mustBePositive;

  /// Section title for safety limits
  ///
  /// In en, this message translates to:
  /// **'Safety Limits'**
  String get safetyLimits;

  /// Section title for configuration presets
  ///
  /// In en, this message translates to:
  /// **'Configuration Presets'**
  String get configurationPresets;

  /// Label for 24-hour high price
  ///
  /// In en, this message translates to:
  /// **'High 24h'**
  String get high24h;

  /// Label for 24-hour low price
  ///
  /// In en, this message translates to:
  /// **'Low 24h'**
  String get low24h;

  /// Label for trading volume
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// Label for market trend
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trend;

  /// Label when timeframes are aligned
  ///
  /// In en, this message translates to:
  /// **'ALIGNED'**
  String get aligned;

  /// Label when timeframes are not aligned
  ///
  /// In en, this message translates to:
  /// **'NOT ALIGNED'**
  String get notAligned;

  /// Label for reasoning section
  ///
  /// In en, this message translates to:
  /// **'Reasoning:'**
  String get reasoning;

  /// Label for target price
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// Label for risk score
  ///
  /// In en, this message translates to:
  /// **'Risk Score:'**
  String get riskScore;

  /// Label for volatility
  ///
  /// In en, this message translates to:
  /// **'Volatility:'**
  String get volatility;

  /// Label for risk factors section
  ///
  /// In en, this message translates to:
  /// **'Risk Factors:'**
  String get riskFactors;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
