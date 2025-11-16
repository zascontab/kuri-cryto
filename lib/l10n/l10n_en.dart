import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get scalpingEngine => 'Scalping Engine';

  @override
  String get running => 'Running';

  @override
  String get stopped => 'Stopped';

  @override
  String get healthy => 'Healthy';

  @override
  String get degraded => 'Degraded';

  @override
  String get down => 'Down';

  @override
  String get uptime => 'Uptime';

  @override
  String get activePositions => 'Active Positions';

  @override
  String get totalTrades => 'Total Trades';

  @override
  String get startEngine => 'Start Engine';

  @override
  String get stopEngine => 'Stop Engine';

  @override
  String get startEngineConfirmation =>
      'Are you sure you want to start the trading engine?';

  @override
  String get stopEngineConfirmation =>
      'Are you sure you want to stop the trading engine? All positions will be closed.';

  @override
  String get cancel => 'Cancel';

  @override
  String get start => 'Start';

  @override
  String get stop => 'Stop';

  @override
  String get tradingMetrics => 'Trading Metrics';

  @override
  String get totalPnl => 'Total P&L';

  @override
  String get dailyPnl => 'Daily P&L';

  @override
  String get winRate => 'Win Rate';

  @override
  String get avgLatency => 'Avg Latency';

  @override
  String get ms => 'ms';

  @override
  String get loading => 'Loading...';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get stopEngineMessage =>
      'This will stop the scalping engine. Open positions will remain active. Continue?';

  @override
  String get startEngineMessage =>
      'This will start the scalping engine and begin trading. Continue?';

  @override
  String get engineStartedSuccess => 'Engine started successfully';

  @override
  String get engineStoppedSuccess => 'Engine stopped successfully';

  @override
  String get keyMetrics => 'Key Metrics';

  @override
  String get today => 'today';

  @override
  String get aboveTarget => 'Above target';

  @override
  String get belowTarget => 'Below target';

  @override
  String get openTrades => 'Open trades';

  @override
  String get excellent => 'Excellent';

  @override
  String get good => 'Good';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get refreshData => 'Refresh Data';

  @override
  String get lastUpdatedNow => 'Last updated just now';

  @override
  String get viewAnalytics => 'View Analytics';

  @override
  String get detailedCharts => 'Detailed performance charts';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';
}
