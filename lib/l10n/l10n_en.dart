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
  String get maxConsecutiveLosses => 'Max Consecutive Losses';

  @override
  String get activateKillSwitch => 'Activate Kill Switch';

  @override
  String get killSwitchWarning =>
      'This will immediately stop all trading and close positions:';

  @override
  String get allTradingWillStop => 'All trading will stop immediately';

  @override
  String get allPositionsWillClose => 'All open positions will be closed';

  @override
  String get requiresManualReactivation =>
      'Requires manual reactivation to resume';

  @override
  String get areYouSure => 'Are you absolutely sure?';

  @override
  String get activate => 'Activate';

  @override
  String get deactivateKillSwitch => 'Deactivate Kill Switch';

  @override
  String get thisWillResumeTrading => 'This will resume all trading operations.';

  @override
  String get continue_ => 'Continue';

  @override
  String get confirmDeactivation => 'Confirm Deactivation';

  @override
  String get confirmResumeTrading =>
      'Confirm that you want to resume trading. All strategies will be re-enabled.';

  @override
  String get resume => 'Resume';

  @override
  String errorOccurred({required String error}) => 'Error: $error';

  @override
  String get ok => 'OK';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get killSwitchActive => 'KILL SWITCH ACTIVE';

  @override
  String get tradingDisabled => 'All trading is disabled';

  @override
  String get retry => 'Retry';

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

  // Multi-Timeframe Analysis
  @override
  String get multiTimeframeAnalysis => 'Multi-Timeframe Analysis';

  @override
  String get technicalAnalysisMultipleTimeframes => 'Technical analysis across multiple timeframes';

  @override
  String get symbol => 'Symbol';

  @override
  String get consensusSignal => 'Consensus Signal';

  @override
  String get currentPrice => 'Current Price';

  @override
  String get signal => 'Signal';

  @override
  String get confidence => 'Confidence';

  @override
  String get tradingSignal => 'Trading Signal';

  @override
  String get technicalIndicators => 'Technical Indicators';

  @override
  String get recommendation => 'Recommendation';

  @override
  String get selectSymbolToAnalyze => 'Select a symbol to analyze';

  // Backtesting
  @override
  String get backtesting => 'Backtesting';

  @override
  String get testStrategiesWithHistoricalData => 'Test strategies with historical data';

  @override
  String get newBacktest => 'New Backtest';

  @override
  String get backtestConfiguration => 'Backtest Configuration';

  @override
  String get strategy => 'Strategy';

  @override
  String get dateRange => 'Date Range';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get initialCapital => 'Initial Capital';

  @override
  String get enterAmount => 'Enter amount';

  @override
  String get runBacktest => 'Run Backtest';

  @override
  String get backtestStarted => 'Backtest started successfully';

  @override
  String get error => 'Error';

  @override
  String get backtestRunning => 'Backtest is running...';

  @override
  String get backtestFailed => 'Backtest failed';

  @override
  String get backToForm => 'Back to Form';

  @override
  String get equityCurve => 'Equity Curve';

  @override
  String get tradeHistory => 'Trade History';

  @override
  String get entryTime => 'Entry Time';

  @override
  String get exitTime => 'Exit Time';

  @override
  String get side => 'Side';

  @override
  String get entryPrice => 'Entry Price';

  @override
  String get exitPrice => 'Exit Price';

  @override
  String get pnl => 'P&L';

  @override
  String get showing => 'Showing';

  @override
  String get ofLabel => 'of';

  @override
  String get trades => 'trades';

  @override
  String get noBacktestsYet => 'No backtests yet';

  @override
  String get profitFactor => 'Profit Factor';

  @override
  String get sharpeRatio => 'Sharpe Ratio';

  @override
  String get maxDrawdown => 'Max Drawdown';

  // Parameter Optimization
  @override
  String get parameterOptimization => 'Parameter Optimization';

  @override
  String get optimizeStrategyParameters => 'Optimize strategy parameters';

  @override
  String get newOptimization => 'New Optimization';

  @override
  String get optimizationConfiguration => 'Optimization Configuration';

  @override
  String get parameterRanges => 'Parameter Ranges';

  @override
  String get addParameter => 'Add Parameter';

  @override
  String get editParameter => 'Edit Parameter';

  @override
  String get parameterName => 'Parameter Name';

  @override
  String get minimumValue => 'Minimum Value';

  @override
  String get maximumValue => 'Maximum Value';

  @override
  String get stepSize => 'Step Size';

  @override
  String get noParametersConfigured => 'No parameters configured yet';

  @override
  String get optimizationMethod => 'Optimization Method';

  @override
  String get gridSearch => 'Grid Search';

  @override
  String get gridSearchDesc => 'Test all parameter combinations';

  @override
  String get randomSearch => 'Random Search';

  @override
  String get randomSearchDesc => 'Randomly sample parameter space';

  @override
  String get bayesianOptimization => 'Bayesian Optimization';

  @override
  String get bayesianOptimizationDesc => 'Smart search using probability';

  @override
  String get maxIterations => 'Max Iterations';

  @override
  String get objectiveToOptimize => 'Objective to Optimize';

  @override
  String get sharpeRatioDesc => 'Maximize risk-adjusted returns';

  @override
  String get totalPnlDesc => 'Maximize total profit';

  @override
  String get winRateDesc => 'Maximize winning trade percentage';

  @override
  String get optimizationSummary => 'Optimization Summary';

  @override
  String get estimatedCombinations => 'Estimated Combinations';

  @override
  String get pleaseFixConfigurationErrors => 'Please fix configuration errors';

  @override
  String get runOptimization => 'Run Optimization';

  @override
  String get optimizationStarted => 'Optimization started successfully';

  @override
  String get optimizationResults => 'Optimization Results';

  @override
  String get loadingResults => 'Loading results...';

  @override
  String get optimizationRunning => 'Optimization Running';

  @override
  String get combinations => 'combinations';

  @override
  String get estimatedTimeRemaining => 'Estimated Time Remaining';

  @override
  String get cancelOptimization => 'Cancel Optimization';

  @override
  String get optimizationFailed => 'Optimization Failed';

  @override
  String get optimizationCancelled => 'Optimization Cancelled';

  @override
  String get goBack => 'Go Back';

  @override
  String get bestParameters => 'Best Parameters';

  @override
  String get score => 'Score';

  @override
  String get applyTheseParameters => 'Apply These Parameters';

  @override
  String get scoreDistribution => 'Score Distribution';

  @override
  String get allResults => 'All Results';

  @override
  String get sortBy => 'Sort by';

  @override
  String get rank => 'Rank';

  @override
  String get parameters => 'Parameters';

  @override
  String get results => 'results';

  @override
  String get applyParameters => 'Apply Parameters';

  @override
  String get applyParametersConfirmation => 'Apply these parameters to the strategy configuration?';

  @override
  String get apply => 'Apply';

  @override
  String get parametersAppliedSuccessfully => 'Parameters applied successfully';

  @override
  String get cancelOptimizationConfirmation => 'Are you sure you want to cancel this optimization?';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get optimizationCancelledSuccessfully => 'Optimization cancelled successfully';

  @override
  String get noOptimizationsYet => 'No optimizations yet';

  @override
  String get started => 'Started';

  @override
  String get bestScore => 'Best Score';

  @override
  String get totalCombinations => 'Total Combinations';

  @override
  String get deleteOptimization => 'Delete Optimization';

  @override
  String get deleteOptimizationConfirmation => 'Are you sure you want to delete this optimization?';

  @override
  String get delete => 'Delete';

  @override
  String get optimizationDeletedSuccessfully => 'Optimization deleted successfully';

  @override
  String get completed => 'Completed';

  @override
  String get failed => 'Failed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get min => 'Min';

  @override
  String get max => 'Max';

  @override
  String get step => 'Step';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number';

  @override
  String get add => 'Add';

  @override
  String get duration => 'Duration';

  @override
  String get objective => 'Objective';

  // Execution Stats Screen
  @override
  String get latency => 'Latency';

  @override
  String get queue => 'Queue';

  @override
  String get performance => 'Performance';

  @override
  String get latencyStatistics => 'Latency Statistics';

  @override
  String get average => 'Average';

  @override
  String get median => 'Median';

  @override
  String get percentile95 => '95th Percentile';

  @override
  String get percentile99 => '99th Percentile';

  @override
  String get maximum => 'Maximum';

  @override
  String get minimum => 'Minimum';

  @override
  String get executionsTracked => 'Executions Tracked';

  @override
  String get executionHistory => 'Execution History';

  @override
  String get filled => 'Filled';

  @override
  String get partial => 'Partial';

  @override
  String get rejected => 'Rejected';

  @override
  String get all => 'All';

  @override
  String get filterByStatus => 'Filter by Status';

  @override
  String get noExecutionsYet => 'No executions yet';

  @override
  String get executionQueue => 'Execution Queue';

  @override
  String get queueEmpty => 'Queue is empty';

  @override
  String get queueLength => 'Queue Length';

  @override
  String get avgWaitTime => 'Avg Wait Time';

  @override
  String get queueStatus => 'Queue Status';

  @override
  String get orderId => 'Order ID';

  @override
  String get orderType => 'Order Type';

  @override
  String get queuePosition => 'Position';

  @override
  String get timeInQueue => 'Time in Queue';

  @override
  String get executionPerformance => 'Execution Performance';

  @override
  String get fillRate => 'Fill Rate';

  @override
  String get avgSlippage => 'Avg Slippage';

  @override
  String get successfulExecutions => 'Successful';

  @override
  String get failedExecutions => 'Failed';

  @override
  String get errorRate => 'Error Rate';

  @override
  String get avgExecutionTime => 'Avg Execution Time';

  @override
  String get slippageBySymbol => 'Slippage by Symbol';

  @override
  String get successRateBySymbol => 'Success Rate by Symbol';

  @override
  String get basisPoints => 'bps';

  @override
  String get refreshStats => 'Refresh Stats';

  @override
  String get exportMetrics => 'Export Metrics';

  @override
  String get selectPeriod => 'Select Period';

  @override
  String get selectFormat => 'Select Format';

  @override
  String get selectMetrics => 'Select Metrics';

  @override
  String get export => 'Export';

  @override
  String get exportSuccess => 'Metrics exported successfully';

  @override
  String get downloadFile => 'Download File';

  @override
  String get period7d => 'Last 7 Days';

  @override
  String get period30d => 'Last 30 Days';

  @override
  String get period90d => 'Last 90 Days';

  @override
  String get periodAll => 'All Time';

  // Performance Charts Screen
  @override
  String get performanceCharts => 'Performance Charts';

  @override
  String get pnlChart => 'P&L Chart';

  @override
  String get winRateChart => 'Win Rate Chart';

  @override
  String get drawdownChart => 'Drawdown Chart';

  @override
  String get latencyChart => 'Latency Chart';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get filterByStrategy => 'Filter by Strategy';

  @override
  String get filterBySymbol => 'Filter by Symbol';

  @override
  String get allStrategies => 'All Strategies';

  @override
  String get allSymbols => 'All Symbols';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get loadingCharts => 'Loading charts...';

  @override
  String get price => 'Price';

  @override
  String get size => 'Size';

  @override
  String get time => 'Time';

  @override
  String get status => 'Status';

  // Trading Pairs Screen
  @override
  String get addPair => 'Add Pair';

  @override
  String get noTradingPairs => 'No Trading Pairs';

  @override
  String get tapAddPairToStart => 'Tap the + button to add your first trading pair';

  @override
  String get removePair => 'Remove Pair';

  @override
  String removePairConfirmation({required String exchange, required String symbol}) =>
      'Are you sure you want to remove $symbol from $exchange?';

  @override
  String get remove => 'Remove';

  @override
  String get cannotRemovePair => 'Cannot Remove Pair';

  @override
  String cannotRemovePairWithPositions({required int count}) =>
      'This pair has $count open position(s). Please close all positions before removing the pair.';

  @override
  String pairRemovedSuccess({required String symbol}) =>
      'Pair $symbol removed successfully';

  @override
  String pairAddedSuccess({required String symbol}) =>
      'Pair $symbol added successfully';

  @override
  String get addNewPair => 'Add New Trading Pair';

  @override
  String get exchange => 'Exchange';

  @override
  String get pleaseSelectExchange => 'Please select an exchange';

  @override
  String get searchPairs => 'Search pairs';

  @override
  String get noPairsFound => 'No pairs found';

  @override
  String get selectedPair => 'Selected Pair';

  @override
  String get inactive => 'Inactive';

  @override
  String get notAvailable => 'N/A';

  @override
  String get lastPrice => 'Last Price';

  @override
  String get volume24h => '24h Volume';

  @override
  String get exposure => 'Exposure';

  // Alerts Screen
  @override
  String get activeAlerts => 'Active Alerts';

  @override
  String get alertConfiguration => 'Alert Configuration';

  @override
  String get noActiveAlerts => 'No Active Alerts';

  @override
  String get allClear => 'All clear - no alerts at the moment';

  @override
  String get noAlertsYet => 'No Alerts Yet';

  @override
  String get alertHistoryWillAppearHere => 'Your alert history will appear here';

  @override
  String get manageAlertRules => 'Manage Alert Rules';

  @override
  String get configureAlertConditions => 'Configure alert conditions and thresholds';

  @override
  String get testAlertSystem => 'Test Alert System';

  @override
  String get sendTestAlert => 'Send a test alert to verify configuration';

  @override
  String get alertAcknowledged => 'Alert acknowledged';

  @override
  String get alertDismissed => 'Alert dismissed';

  @override
  String get trigger => 'Trigger';

  @override
  String get value => 'Value';

  @override
  String get acknowledge => 'Acknowledge';

  @override
  String get errorLoadingAlerts => 'Error Loading Alerts';

  @override
  String get enableAlerts => 'Enable Alerts';

  @override
  String get toggleAlertSystem => 'Toggle alert system on/off';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get inAppNotifications => 'In-app notifications';

  @override
  String get telegramConfiguration => 'Telegram Configuration';

  @override
  String get telegramBotToken => 'Telegram Bot Token';

  @override
  String get telegramChatId => 'Telegram Chat ID';

  @override
  String get pleaseEnterTelegramToken => 'Please enter Telegram bot token';

  @override
  String get pleaseEnterTelegramChatId => 'Please enter Telegram chat ID';

  @override
  String get telegramSetupInstructions =>
      'Create a bot with @BotFather and get your chat ID from @userinfobot';

  @override
  String get alertRules => 'Alert Rules';

  @override
  String get addRule => 'Add Rule';

  @override
  String get noAlertRulesYet => 'No Alert Rules Yet';

  @override
  String get tapAddToCreateRule => 'Tap "Add Rule" to create your first alert rule';

  @override
  String get type => 'Type';

  @override
  String get threshold => 'Threshold';

  @override
  String get edit => 'Edit';

 

  @override
  String get errorLoadingConfiguration => 'Error Loading Configuration';

  @override
  String get alertConfigurationSaved => 'Alert configuration saved successfully';

  @override
  String get ruleAdded => 'Alert rule added successfully';

  @override
  String get ruleUpdated => 'Alert rule updated successfully';

  @override
  String get deleteRule => 'Delete Rule';

  @override
  String confirmDeleteRule({required String name}) =>
      'Are you sure you want to delete the rule "$name"?';

  @override
  String get ruleDeleted => 'Alert rule deleted successfully';

  @override
  String get addAlertRule => 'Add Alert Rule';

  @override
  String get editAlertRule => 'Edit Alert Rule';

  @override
  String get ruleName => 'Rule Name';

  @override
  String get pleaseEnterRuleName => 'Please enter rule name';

  @override
  String get alertType => 'Alert Type';


  @override
  String get severity => 'Severity';

  @override
  String get cooldownMinutes => 'Cooldown (minutes)';

  @override
  String get preventDuplicateAlerts => 'Prevent duplicate alerts for this period';

  @override
  String get testAlertSent => 'Test alert sent successfully';

  // AI Bot Screen
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

  // Analysis Screen
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

  // Futures
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

  // General
  @override
  String get confirm => 'Confirm';

  @override
  String get success => 'Success';

  @override
  String get refresh => 'Refresh';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  // Additional
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
  String get autoExecuteDescription => 'Automatically execute AI recommendations';

  @override
  String get tradingParameters => 'Trading Parameters';

  @override
  String get minimumConfidenceDescription => 'Minimum confidence required for trades';

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
