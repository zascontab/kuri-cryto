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

  @override
  String get tradingDashboard => 'Trading Dashboard';

  @override
  String get positions => 'Positions';

  @override
  String get strategies => 'Strategies';

  @override
  String get riskMonitor => 'Risk Monitor';

  @override
  String get more => 'More';

  @override
  String get tradingMCP => 'Trading MCP';

  @override
  String get home => 'Home';

  @override
  String get risk => 'Risk';

  @override
  String get executionStats => 'Execution Stats';

  @override
  String get viewLatencyPerformance => 'View latency and performance';

  @override
  String get tradingPairs => 'Trading Pairs';

  @override
  String get manageTradingPairs => 'Manage trading pairs';

  @override
  String get alerts => 'Alerts';

  @override
  String get configureNotifications => 'Configure notifications';

  @override
  String get appPreferences => 'App preferences';

  @override
  String get about => 'About';

  @override
  String get appInformation => 'App information';

  @override
  String get appVersion => '1.0.0';

  @override
  String get appDescription => 'Advanced cryptocurrency trading automation platform';

  @override
  String get backendVersion => 'Backend: Trading MCP Server v1.0.0';

  @override
  String get openPositions => 'Open Positions';

  @override
  String get history => 'History';

  @override
  String closingPosition({required String positionId}) =>
      'Closing position $positionId...';

  @override
  String get movingStopLossBreakeven => 'Moving stop loss to breakeven...';

  @override
  String get enablingTrailingStop => 'Enabling trailing stop...';

  @override
  String get noOpenPositions => 'No Open Positions';

  @override
  String get startEngineToTrade => 'Start the engine to begin trading';

  @override
  String get closedPositionsHere => 'Your closed positions will appear here';

  @override
  String get slTpUpdatedSuccess => 'SL/TP updated successfully';

  @override
  String get editStopLossTakeProfit => 'Edit Stop Loss & Take Profit';

  @override
  String get stopLoss => 'Stop Loss';

  @override
  String get priceCloseIfLosing => 'Price to close position if losing';

  @override
  String get pleaseEnterStopLoss => 'Please enter stop loss price';

  @override
  String get pleaseEnterValidPrice => 'Please enter a valid price';

  @override
  String get takeProfit => 'Take Profit';

  @override
  String get priceCloseIfWinning => 'Price to close position if winning';

  @override
  String get pleaseEnterTakeProfit => 'Please enter take profit price';

  @override
  String get save => 'Save';

  @override
  String get killSwitchActivated => 'Kill Switch ACTIVATED - All trading stopped';

  @override
  String get killSwitchDeactivated => 'Kill Switch deactivated - Trading resumed';

  @override
  String get selectRiskMode => 'Select Risk Mode';

  @override
  String get conservative => 'Conservative';

  @override
  String get lowerRiskSmallerPositions => 'Lower risk, smaller positions';

  @override
  String get normal => 'Normal';

  @override
  String get balancedRiskReward => 'Balanced risk and reward';

  @override
  String get aggressive => 'Aggressive';

  @override
  String get higherRiskLargerPositions => 'Higher risk, larger positions';

  @override
  String riskModeChanged({required String mode}) => 'Risk mode changed to $mode';

  @override
  String get riskLimitsUpdated => 'Risk limits updated successfully';

  @override
  String get riskLimits => 'Risk Limits';

  @override
  String get editLimits => 'Edit limits';

  @override
  String get maxPositionSize => 'Max Position Size';

  @override
  String get maxTotalExposure => 'Max Total Exposure';

  @override
  String get stopLossPercent => 'Stop Loss %';

  @override
  String get takeProfitPercent => 'Take Profit %';

  @override
  String get maxDailyLoss => 'Max Daily Loss';

  @override
  String get riskMode => 'Risk Mode';

  @override
  String get tapToChangeMode => 'Tap to change mode';

  @override
  String get exposureBySymbol => 'Exposure by Symbol';

  @override
  String get editRiskLimits => 'Edit Risk Limits';

  @override
  String get pleaseEnterValue => 'Please enter a value';

  @override
  String get pleaseEnterValidAmount => 'Please enter a valid amount';

  @override
  String get pleaseEnterValidPercentage => 'Please enter a valid percentage';

  @override
  String get strategiesOverview => 'Strategies Overview';

  @override
  String get active => 'Active';

  @override
  String get avgWinRate => 'Avg Win Rate';

  @override
  String get availableStrategies => 'Available Strategies';

  @override
  String strategyActivated({required String name}) => 'Strategy "$name" activated';

  @override
  String strategyDeactivated({required String name}) =>
      'Strategy "$name" deactivated';

  @override
  String get performanceMetrics => 'Performance Metrics';

  @override
  String get weight => 'Weight';

  @override
  String get avgWin => 'Avg Win';

  @override
  String get avgLoss => 'Avg Loss';

  @override
  String get configuration => 'Configuration';

  @override
  String get strategyConfigUpdated => 'Strategy configuration updated';

  @override
  String configureStrategy({required String name}) => 'Configure $name';
}
