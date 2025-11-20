// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get openPositions => 'Open Positions';

  @override
  String get history => 'History';

  @override
  String closingPosition(String positionId) {
    return 'Closing position $positionId...';
  }

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
  String get killSwitchActivated =>
      'Kill Switch ACTIVATED - All trading stopped';

  @override
  String get killSwitchDeactivated =>
      'Kill Switch deactivated - Trading resumed';

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
  String riskModeChanged(String mode) {
    return 'Risk mode changed to $mode';
  }

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
  String strategyActivated(String name) {
    return 'Strategy \"$name\" activated';
  }

  @override
  String strategyDeactivated(String name) {
    return 'Strategy \"$name\" deactivated';
  }

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
  String configureStrategy(String name) {
    return 'Configure $name';
  }

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
  String get appDescription =>
      'Advanced cryptocurrency trading automation platform';

  @override
  String get backendVersion => 'Backend: Trading MCP Server v1.0.0';

  @override
  String get aiBotTitle => 'AI Bot Control';

  @override
  String get aiBotStatus => 'Bot Status';

  @override
  String get aiBotRunning => 'Running';

  @override
  String get aiBotPaused => 'Paused';

  @override
  String get aiBotStopped => 'Stopped';

  @override
  String get aiBotStart => 'Start Bot';

  @override
  String get aiBotStop => 'Stop Bot';

  @override
  String get aiBotPause => 'Pause Bot';

  @override
  String get aiBotResume => 'Resume Bot';

  @override
  String get aiBotEmergencyStop => 'Emergency Stop';

  @override
  String get aiBotAnalysisCount => 'Analyses';

  @override
  String get aiBotExecutionCount => 'Executions';

  @override
  String get aiBotErrorCount => 'Errors';

  @override
  String get aiBotOpenPositions => 'Open Positions';

  @override
  String get aiBotDailyLoss => 'Daily Loss';

  @override
  String get aiBotDailyTrades => 'Daily Trades';

  @override
  String get aiBotConfirmStart => 'Are you sure you want to start the AI Bot?';

  @override
  String get aiBotConfirmStop => 'Are you sure you want to stop the AI Bot?';

  @override
  String get aiBotConfirmEmergency =>
      'Emergency stop will immediately halt all AI Bot operations. Continue?';

  @override
  String get aiBotStartedSuccess => 'AI Bot started successfully';

  @override
  String get aiBotStoppedSuccess => 'AI Bot stopped successfully';

  @override
  String get aiBotConfig => 'Bot Configuration';

  @override
  String get aiBotConfigTitle => 'Configure AI Bot';

  @override
  String get aiBotConfigSave => 'Save Configuration';

  @override
  String get aiBotDryRun => 'Dry Run Mode';

  @override
  String get aiBotLiveMode => 'Live Trading Mode';

  @override
  String get aiBotAutoExecute => 'Auto Execute';

  @override
  String get aiBotConfidenceThreshold => 'Confidence Threshold';

  @override
  String get aiBotTradeSize => 'Trade Size';

  @override
  String get aiBotLeverage => 'Leverage';

  @override
  String get aiBotMaxDailyLoss => 'Max Daily Loss';

  @override
  String get aiBotMaxDailyTrades => 'Max Daily Trades';

  @override
  String get aiBotTradingPair => 'Trading Pair';

  @override
  String get aiBotPresetConservative => 'Conservative';

  @override
  String get aiBotPresetIntermediate => 'Intermediate';

  @override
  String get aiBotPresetAggressive => 'Aggressive';

  @override
  String get aiBotWarningLiveMode =>
      'Warning: Live trading mode will execute real trades with real funds';

  @override
  String get aiBotConfigUpdated => 'AI Bot configuration updated successfully';

  @override
  String get analysisTitle => 'Market Analysis';

  @override
  String get analysisRefresh => 'Refresh Analysis';

  @override
  String get analysisLoading => 'Analyzing market data...';

  @override
  String get analysisTechnical => 'Technical Analysis';

  @override
  String get analysisMultiTimeframe => 'Multi-Timeframe Analysis';

  @override
  String get analysisRecommendation => 'Trading Recommendation';

  @override
  String get analysisScenarios => 'Scenarios';

  @override
  String get analysisRisk => 'Risk Analysis';

  @override
  String get analysisOversold => 'Oversold';

  @override
  String get analysisOverbought => 'Overbought';

  @override
  String get analysisNeutral => 'Neutral';

  @override
  String get analysisBullish => 'Bullish';

  @override
  String get analysisBearish => 'Bearish';

  @override
  String get analysisLowRisk => 'Low Risk';

  @override
  String get analysisMediumRisk => 'Medium Risk';

  @override
  String get analysisHighRisk => 'High Risk';

  @override
  String get analysisConfidence => 'Confidence';

  @override
  String get analysisEntry => 'Entry Price';

  @override
  String get analysisStopLoss => 'Stop Loss';

  @override
  String get analysisTakeProfit => 'Take Profit';

  @override
  String get futuresPositions => 'Futures Positions';

  @override
  String get futuresClose => 'Close Position';

  @override
  String get futuresCloseAll => 'Close All Positions';

  @override
  String get futuresCloseConfirm =>
      'Are you sure you want to close this position?';

  @override
  String get futuresClosedSuccess => 'Position closed successfully';

  @override
  String get futuresSize => 'Position Size';

  @override
  String get futuresLeverage => 'Leverage';

  @override
  String get futuresMargin => 'Margin';

  @override
  String get futuresLiquidation => 'Liquidation Price';

  @override
  String get futuresUnrealizedPnl => 'Unrealized P&L';

  @override
  String get futuresRealizedPnl => 'Realized P&L';

  @override
  String get futuresTotalPnl => 'Total P&L';

  @override
  String get confirm => 'Confirm';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get refresh => 'Refresh';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get multiTimeframeAnalysis => 'Multi-Timeframe Analysis';

  @override
  String get technicalAnalysisMultipleTimeframes =>
      'Technical analysis across multiple timeframes';

  @override
  String get backtesting => 'Backtesting';

  @override
  String get testStrategiesWithHistoricalData =>
      'Test strategies with historical data';

  @override
  String get parameterOptimization => 'Parameter Optimization';

  @override
  String get optimizeStrategyParameters => 'Optimize strategy parameters';

  @override
  String get performanceCharts => 'Performance Charts';

  @override
  String get emergencyStopActivated => 'Emergency Stop Activated';

  @override
  String get botResumedSuccess => 'Bot resumed successfully';

  @override
  String get mode => 'Mode';

  @override
  String get botMetrics => 'Bot Metrics';

  @override
  String get total => 'Total';

  @override
  String get executed => 'Executed';

  @override
  String get percentUsed => '% used';

  @override
  String get dailyLimits => 'Daily Limits';

  @override
  String get consecutive => 'consecutive';

  @override
  String get tradingMode => 'Trading Mode';

  @override
  String get simulationMode => 'Simulation mode - no real trades';

  @override
  String get autoExecuteDescription =>
      'Automatically execute AI recommendations';

  @override
  String get tradingParameters => 'Trading Parameters';

  @override
  String get minimumConfidenceDescription =>
      'Minimum confidence required for trades';

  @override
  String get leverageDescription => 'Trading leverage multiplier';

  @override
  String get required => 'Required';

  @override
  String get mustBePositive => 'Must be positive';

  @override
  String get safetyLimits => 'Safety Limits';

  @override
  String get configurationPresets => 'Configuration Presets';

  @override
  String get high24h => 'High 24h';

  @override
  String get low24h => 'Low 24h';

  @override
  String get volume => 'Volume';

  @override
  String get trend => 'Trend';

  @override
  String get aligned => 'ALIGNED';

  @override
  String get notAligned => 'NOT ALIGNED';

  @override
  String get reasoning => 'Reasoning:';

  @override
  String get target => 'Target';

  @override
  String get riskScore => 'Risk Score:';

  @override
  String get volatility => 'Volatility:';

  @override
  String get riskFactors => 'Risk Factors:';
}
