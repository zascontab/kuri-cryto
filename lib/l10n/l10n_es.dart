import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Spanish (`es`).
class L10nEs extends L10n {
  L10nEs([String locale = 'es']) : super(locale);

  @override
  String get scalpingEngine => 'Motor de Scalping';

  @override
  String get running => 'En ejecución';

  @override
  String get stopped => 'Detenido';

  @override
  String get healthy => 'Saludable';

  @override
  String get degraded => 'Degradado';

  @override
  String get down => 'Caído';

  @override
  String get uptime => 'Tiempo activo';

  @override
  String get activePositions => 'Posiciones Activas';

  @override
  String get totalTrades => 'Operaciones Totales';

  @override
  String get startEngine => 'Iniciar Motor';

  @override
  String get stopEngine => 'Detener Motor';

  @override
  String get startEngineConfirmation =>
      '¿Estás seguro de que quieres iniciar el motor de trading?';

  @override
  String get stopEngineConfirmation =>
      '¿Estás seguro de que quieres detener el motor de trading? Todas las posiciones se cerrarán.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get start => 'Iniciar';

  @override
  String get stop => 'Detener';

  @override
  String get tradingMetrics => 'Métricas de Trading';

  @override
  String get totalPnl => 'P&L Total';

  @override
  String get dailyPnl => 'P&L Diario';

  @override
  String get winRate => 'Tasa de Acierto';

  @override
  String get avgLatency => 'Latencia Promedio';

  @override
  String get ms => 'ms';

  @override
  String get loading => 'Cargando...';

  @override
  String get errorLoadingData => 'Error al cargar datos';

  @override
  String get stopEngineMessage =>
      'Esto detendrá el motor de scalping. Las posiciones abiertas permanecerán activas. ¿Continuar?';

  @override
  String get startEngineMessage =>
      'Esto iniciará el motor de scalping y comenzará a operar. ¿Continuar?';

  @override
  String get engineStartedSuccess => 'Motor iniciado exitosamente';

  @override
  String get engineStoppedSuccess => 'Motor detenido exitosamente';

  @override
  String get keyMetrics => 'Métricas Clave';

  @override
  String get today => 'hoy';

  @override
  String get aboveTarget => 'Sobre objetivo';

  @override
  String get belowTarget => 'Bajo objetivo';

  @override
  String get openTrades => 'Operaciones abiertas';

  @override
  String get excellent => 'Excelente';

  @override
  String get good => 'Bueno';

  @override
  String get quickActions => 'Acciones Rápidas';

  @override
  String get refreshData => 'Actualizar Datos';

  @override
  String get lastUpdatedNow => 'Actualizado hace un momento';

  @override
  String get viewAnalytics => 'Ver Análisis';

  @override
  String get detailedCharts => 'Gráficos de rendimiento detallados';

  @override
  String get settings => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get tradingDashboard => 'Panel de Trading';

  @override
  String get positions => 'Posiciones';

  @override
  String get strategies => 'Estrategias';

  @override
  String get riskMonitor => 'Monitor de Riesgo';

  @override
  String get more => 'Más';

  @override
  String get tradingMCP => 'Trading MCP';

  @override
  String get home => 'Inicio';

  @override
  String get risk => 'Riesgo';

  @override
  String get executionStats => 'Estadísticas de Ejecución';

  @override
  String get viewLatencyPerformance => 'Ver latencia y rendimiento';

  @override
  String get tradingPairs => 'Pares de Trading';

  @override
  String get manageTradingPairs => 'Administrar pares de trading';

  @override
  String get alerts => 'Alertas';

  @override
  String get configureNotifications => 'Configurar notificaciones';

  @override
  String get appPreferences => 'Preferencias de la aplicación';

  @override
  String get about => 'Acerca de';

  @override
  String get appInformation => 'Información de la aplicación';

  @override
  String get appVersion => '1.0.0';

  @override
  String get appDescription =>
      'Plataforma avanzada de automatización de trading de criptomonedas';

  @override
  String get backendVersion => 'Backend: Trading MCP Server v1.0.0';

  @override
  String get openPositions => 'Posiciones Abiertas';

  @override
  String get history => 'Historial';

  @override
  String closingPosition({required String positionId}) =>
      'Cerrando posición $positionId...';

  @override
  String get movingStopLossBreakeven =>
      'Moviendo stop loss a punto de equilibrio...';

  @override
  String get enablingTrailingStop => 'Activando trailing stop...';

  @override
  String get noOpenPositions => 'Sin Posiciones Abiertas';

  @override
  String get startEngineToTrade => 'Inicia el motor para comenzar a operar';

  @override
  String get closedPositionsHere => 'Tus posiciones cerradas aparecerán aquí';

  @override
  String get slTpUpdatedSuccess => 'SL/TP actualizado exitosamente';

  @override
  String get editStopLossTakeProfit => 'Editar Stop Loss y Take Profit';

  @override
  String get stopLoss => 'Stop Loss';

  @override
  String get priceCloseIfLosing =>
      'Precio para cerrar posición si está perdiendo';

  @override
  String get pleaseEnterStopLoss => 'Por favor ingresa el precio de stop loss';

  @override
  String get pleaseEnterValidPrice => 'Por favor ingresa un precio válido';

  @override
  String get takeProfit => 'Take Profit';

  @override
  String get priceCloseIfWinning =>
      'Precio para cerrar posición si está ganando';

  @override
  String get pleaseEnterTakeProfit =>
      'Por favor ingresa el precio de take profit';

  @override
  String get save => 'Guardar';

  @override
  String get killSwitchActivated =>
      'Kill Switch ACTIVADO - Todo el trading detenido';

  @override
  String get killSwitchDeactivated => 'Kill Switch desactivado - Trading reanudado';

  @override
  String get selectRiskMode => 'Seleccionar Modo de Riesgo';

  @override
  String get conservative => 'Conservador';

  @override
  String get lowerRiskSmallerPositions =>
      'Menor riesgo, posiciones más pequeñas';

  @override
  String get normal => 'Normal';

  @override
  String get balancedRiskReward => 'Riesgo y recompensa equilibrados';

  @override
  String get aggressive => 'Agresivo';

  @override
  String get higherRiskLargerPositions => 'Mayor riesgo, posiciones más grandes';

  @override
  String riskModeChanged({required String mode}) =>
      'Modo de riesgo cambiado a $mode';

  @override
  String get riskLimitsUpdated => 'Límites de riesgo actualizados exitosamente';

  @override
  String get riskLimits => 'Límites de Riesgo';

  @override
  String get editLimits => 'Editar límites';

  @override
  String get maxPositionSize => 'Tamaño Máximo de Posición';

  @override
  String get maxTotalExposure => 'Exposición Total Máxima';

  @override
  String get stopLossPercent => 'Stop Loss %';

  @override
  String get takeProfitPercent => 'Take Profit %';

  @override
  String get maxDailyLoss => 'Pérdida Diaria Máxima';

  @override
  String get riskMode => 'Modo de Riesgo';

  @override
  String get tapToChangeMode => 'Toca para cambiar de modo';

  @override
  String get exposureBySymbol => 'Exposición por Símbolo';

  @override
  String get editRiskLimits => 'Editar Límites de Riesgo';

  @override
  String get pleaseEnterValue => 'Por favor ingresa un valor';

  @override
  String get pleaseEnterValidAmount => 'Por favor ingresa una cantidad válida';

  @override
  String get pleaseEnterValidPercentage =>
      'Por favor ingresa un porcentaje válido';

  @override
  String get maxConsecutiveLosses => 'Pérdidas Consecutivas Máximas';

  @override
  String get activateKillSwitch => 'Activar Kill Switch';

  @override
  String get killSwitchWarning =>
      'Esto detendrá inmediatamente todo el trading y cerrará posiciones:';

  @override
  String get allTradingWillStop => 'Todo el trading se detendrá inmediatamente';

  @override
  String get allPositionsWillClose => 'Todas las posiciones abiertas se cerrarán';

  @override
  String get requiresManualReactivation =>
      'Requiere reactivación manual para reanudar';

  @override
  String get areYouSure => '¿Estás completamente seguro?';

  @override
  String get activate => 'Activar';

  @override
  String get deactivateKillSwitch => 'Desactivar Kill Switch';

  @override
  String get thisWillResumeTrading =>
      'Esto reanudará todas las operaciones de trading.';

  @override
  String get continue_ => 'Continuar';

  @override
  String get confirmDeactivation => 'Confirmar Desactivación';

  @override
  String get confirmResumeTrading =>
      'Confirma que deseas reanudar el trading. Todas las estrategias serán reactivadas.';

  @override
  String get resume => 'Reanudar';

  @override
  String errorOccurred({required String error}) => 'Error: $error';

  @override
  String get ok => 'OK';

  @override
  String get dismiss => 'Descartar';

  @override
  String get killSwitchActive => 'KILL SWITCH ACTIVO';

  @override
  String get tradingDisabled => 'Todo el trading está deshabilitado';

  @override
  String get retry => 'Reintentar';

  @override
  String get strategiesOverview => 'Resumen de Estrategias';

  @override
  String get active => 'Activo';

  @override
  String get avgWinRate => 'Tasa de Acierto Promedio';

  @override
  String get availableStrategies => 'Estrategias Disponibles';

  @override
  String strategyActivated({required String name}) => 'Estrategia "$name" activada';

  @override
  String strategyDeactivated({required String name}) =>
      'Estrategia "$name" desactivada';

  @override
  String get performanceMetrics => 'Métricas de Rendimiento';

  @override
  String get weight => 'Peso';

  @override
  String get avgWin => 'Ganancia Promedio';

  @override
  String get avgLoss => 'Pérdida Promedio';

  @override
  String get configuration => 'Configuración';

  @override
  String get strategyConfigUpdated => 'Configuración de estrategia actualizada';

  @override
  String configureStrategy({required String name}) => 'Configurar $name';

  // Multi-Timeframe Analysis
  @override
  String get multiTimeframeAnalysis => 'Análisis Multi-Temporalidad';

  @override
  String get technicalAnalysisMultipleTimeframes => 'Análisis técnico en múltiples temporalidades';

  @override
  String get symbol => 'Símbolo';

  @override
  String get consensusSignal => 'Señal de Consenso';

  @override
  String get currentPrice => 'Precio Actual';

  @override
  String get signal => 'Señal';

  @override
  String get confidence => 'Confianza';

  @override
  String get tradingSignal => 'Señal de Trading';

  @override
  String get technicalIndicators => 'Indicadores Técnicos';

  @override
  String get recommendation => 'Recomendación';

  @override
  String get selectSymbolToAnalyze => 'Selecciona un símbolo para analizar';

  // Backtesting
  @override
  String get backtesting => 'Backtesting';

  @override
  String get testStrategiesWithHistoricalData => 'Prueba estrategias con datos históricos';

  @override
  String get newBacktest => 'Nuevo Backtest';

  @override
  String get backtestConfiguration => 'Configuración de Backtest';

  @override
  String get strategy => 'Estrategia';

  @override
  String get dateRange => 'Rango de Fechas';

  @override
  String get startDate => 'Fecha de Inicio';

  @override
  String get endDate => 'Fecha de Fin';

  @override
  String get initialCapital => 'Capital Inicial';

  @override
  String get enterAmount => 'Ingresa la cantidad';

  @override
  String get runBacktest => 'Ejecutar Backtest';

  @override
  String get backtestStarted => 'Backtest iniciado exitosamente';

  @override
  String get error => 'Error';

  @override
  String get backtestRunning => 'Backtest en ejecución...';

  @override
  String get backtestFailed => 'Backtest falló';

  @override
  String get backToForm => 'Volver al Formulario';

  @override
  String get equityCurve => 'Curva de Capital';

  @override
  String get tradeHistory => 'Historial de Operaciones';

  @override
  String get entryTime => 'Hora de Entrada';

  @override
  String get exitTime => 'Hora de Salida';

  @override
  String get side => 'Lado';

  @override
  String get entryPrice => 'Precio de Entrada';

  @override
  String get exitPrice => 'Precio de Salida';

  @override
  String get pnl => 'P&L';

  @override
  String get showing => 'Mostrando';

  @override
  String get of => 'de';

  @override
  String get trades => 'operaciones';

  @override
  String get noBacktestsYet => 'No hay backtests aún';

  @override
  String get profitFactor => 'Factor de Beneficio';

  @override
  String get sharpeRatio => 'Ratio de Sharpe';

  @override
  String get maxDrawdown => 'Drawdown Máximo';

  // Parameter Optimization
  @override
  String get parameterOptimization => 'Optimización de Parámetros';

  @override
  String get optimizeStrategyParameters => 'Optimizar parámetros de estrategia';

  @override
  String get newOptimization => 'Nueva Optimización';

  @override
  String get optimizationConfiguration => 'Configuración de Optimización';

  @override
  String get parameterRanges => 'Rangos de Parámetros';

  @override
  String get addParameter => 'Agregar Parámetro';

  @override
  String get editParameter => 'Editar Parámetro';

  @override
  String get parameterName => 'Nombre del Parámetro';

  @override
  String get minimumValue => 'Valor Mínimo';

  @override
  String get maximumValue => 'Valor Máximo';

  @override
  String get stepSize => 'Tamaño del Paso';

  @override
  String get noParametersConfigured => 'No hay parámetros configurados aún';

  @override
  String get optimizationMethod => 'Método de Optimización';

  @override
  String get gridSearch => 'Búsqueda en Cuadrícula';

  @override
  String get gridSearchDesc => 'Probar todas las combinaciones de parámetros';

  @override
  String get randomSearch => 'Búsqueda Aleatoria';

  @override
  String get randomSearchDesc => 'Muestreo aleatorio del espacio de parámetros';

  @override
  String get bayesianOptimization => 'Optimización Bayesiana';

  @override
  String get bayesianOptimizationDesc => 'Búsqueda inteligente usando probabilidad';

  @override
  String get maxIterations => 'Máximo de Iteraciones';

  @override
  String get objectiveToOptimize => 'Objetivo a Optimizar';

  @override
  String get sharpeRatioDesc => 'Maximizar retornos ajustados por riesgo';

  @override
  String get totalPnlDesc => 'Maximizar beneficio total';

  @override
  String get winRateDesc => 'Maximizar porcentaje de operaciones ganadoras';

  @override
  String get optimizationSummary => 'Resumen de Optimización';

  @override
  String get estimatedCombinations => 'Combinaciones Estimadas';

  @override
  String get pleaseFixConfigurationErrors => 'Por favor corrija los errores de configuración';

  @override
  String get runOptimization => 'Ejecutar Optimización';

  @override
  String get optimizationStarted => 'Optimización iniciada exitosamente';

  @override
  String get optimizationResults => 'Resultados de Optimización';

  @override
  String get loadingResults => 'Cargando resultados...';

  @override
  String get optimizationRunning => 'Optimización en Ejecución';

  @override
  String get combinations => 'combinaciones';

  @override
  String get estimatedTimeRemaining => 'Tiempo Estimado Restante';

  @override
  String get cancelOptimization => 'Cancelar Optimización';

  @override
  String get optimizationFailed => 'Optimización Fallida';

  @override
  String get optimizationCancelled => 'Optimización Cancelada';

  @override
  String get goBack => 'Volver';

  @override
  String get bestParameters => 'Mejores Parámetros';

  @override
  String get score => 'Puntuación';

  @override
  String get applyTheseParameters => 'Aplicar Estos Parámetros';

  @override
  String get scoreDistribution => 'Distribución de Puntuaciones';

  @override
  String get allResults => 'Todos los Resultados';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get rank => 'Rango';

  @override
  String get parameters => 'Parámetros';

  @override
  String get results => 'resultados';

  @override
  String get applyParameters => 'Aplicar Parámetros';

  @override
  String get applyParametersConfirmation => '¿Aplicar estos parámetros a la configuración de la estrategia?';

  @override
  String get apply => 'Aplicar';

  @override
  String get parametersAppliedSuccessfully => 'Parámetros aplicados exitosamente';

  @override
  String get cancelOptimizationConfirmation => '¿Estás seguro de que quieres cancelar esta optimización?';

  @override
  String get no => 'No';

  @override
  String get yes => 'Sí';

  @override
  String get optimizationCancelledSuccessfully => 'Optimización cancelada exitosamente';

  @override
  String get noOptimizationsYet => 'No hay optimizaciones aún';

  @override
  String get started => 'Iniciado';

  @override
  String get bestScore => 'Mejor Puntuación';

  @override
  String get totalCombinations => 'Total de Combinaciones';

  @override
  String get deleteOptimization => 'Eliminar Optimización';

  @override
  String get deleteOptimizationConfirmation => '¿Estás seguro de que quieres eliminar esta optimización?';

  @override
  String get delete => 'Eliminar';

  @override
  String get optimizationDeletedSuccessfully => 'Optimización eliminada exitosamente';

  @override
  String get completed => 'Completado';

  @override
  String get failed => 'Fallido';

  @override
  String get cancelled => 'Cancelado';

  @override
  String get min => 'Mín';

  @override
  String get max => 'Máx';

  @override
  String get step => 'Paso';

  @override
  String get pleaseEnterValidNumber => 'Por favor ingresa un número válido';

  @override
  String get add => 'Agregar';

  @override
  String get duration => 'Duración';

  @override
  String get objective => 'Objetivo';

  // Execution Stats Screen
  @override
  String get latency => 'Latencia';

  @override
  String get queue => 'Cola';

  @override
  String get performance => 'Rendimiento';

  @override
  String get latencyStatistics => 'Estadísticas de Latencia';

  @override
  String get average => 'Promedio';

  @override
  String get median => 'Mediana';

  @override
  String get percentile95 => 'Percentil 95';

  @override
  String get percentile99 => 'Percentil 99';

  @override
  String get maximum => 'Máximo';

  @override
  String get minimum => 'Mínimo';

  @override
  String get executionsTracked => 'Ejecuciones Rastreadas';

  @override
  String get executionHistory => 'Historial de Ejecuciones';

  @override
  String get filled => 'Completadas';

  @override
  String get partial => 'Parciales';

  @override
  String get rejected => 'Rechazadas';

  @override
  String get all => 'Todas';

  @override
  String get filterByStatus => 'Filtrar por Estado';

  @override
  String get noExecutionsYet => 'No hay ejecuciones aún';

  @override
  String get executionQueue => 'Cola de Ejecución';

  @override
  String get queueEmpty => 'La cola está vacía';

  @override
  String get queueLength => 'Longitud de Cola';

  @override
  String get avgWaitTime => 'Tiempo de Espera Promedio';

  @override
  String get queueStatus => 'Estado de Cola';

  @override
  String get orderId => 'ID de Orden';

  @override
  String get orderType => 'Tipo de Orden';

  @override
  String get queuePosition => 'Posición';

  @override
  String get timeInQueue => 'Tiempo en Cola';

  @override
  String get executionPerformance => 'Rendimiento de Ejecución';

  @override
  String get fillRate => 'Tasa de Llenado';

  @override
  String get avgSlippage => 'Slippage Promedio';

  @override
  String get successfulExecutions => 'Exitosas';

  @override
  String get failedExecutions => 'Fallidas';

  @override
  String get errorRate => 'Tasa de Error';

  @override
  String get avgExecutionTime => 'Tiempo de Ejecución Promedio';

  @override
  String get slippageBySymbol => 'Slippage por Símbolo';

  @override
  String get successRateBySymbol => 'Tasa de Éxito por Símbolo';

  @override
  String get basisPoints => 'pbs';

  @override
  String get refreshStats => 'Actualizar Estadísticas';

  @override
  String get exportMetrics => 'Exportar Métricas';

  @override
  String get selectPeriod => 'Seleccionar Período';

  @override
  String get selectFormat => 'Seleccionar Formato';

  @override
  String get selectMetrics => 'Seleccionar Métricas';

  @override
  String get export => 'Exportar';

  @override
  String get exportSuccess => 'Métricas exportadas exitosamente';

  @override
  String get downloadFile => 'Descargar Archivo';

  @override
  String get period7d => 'Últimos 7 Días';

  @override
  String get period30d => 'Últimos 30 Días';

  @override
  String get period90d => 'Últimos 90 Días';

  @override
  String get periodAll => 'Todo el Tiempo';

  // Performance Charts Screen
  @override
  String get performanceCharts => 'Gráficos de Rendimiento';

  @override
  String get pnlChart => 'Gráfico de P&L';

  @override
  String get winRateChart => 'Gráfico de Tasa de Acierto';

  @override
  String get drawdownChart => 'Gráfico de Drawdown';

  @override
  String get latencyChart => 'Gráfico de Latencia';

  @override
  String get daily => 'Diario';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensual';

  @override
  String get filterByStrategy => 'Filtrar por Estrategia';

  @override
  String get filterBySymbol => 'Filtrar por Símbolo';

  @override
  String get allStrategies => 'Todas las Estrategias';

  @override
  String get allSymbols => 'Todos los Símbolos';

  @override
  String get noDataAvailable => 'No hay datos disponibles';

  @override
  String get loadingCharts => 'Cargando gráficos...';

  @override
  String get price => 'Precio';

  @override
  String get size => 'Tamaño';

  @override
  String get time => 'Hora';

  @override
  String get status => 'Estado';

  // Trading Pairs Screen
  @override
  String get addPair => 'Agregar Par';

  @override
  String get noTradingPairs => 'Sin Pares de Trading';

  @override
  String get tapAddPairToStart => 'Toca el botón + para agregar tu primer par de trading';

  @override
  String get removePair => 'Remover Par';

  @override
  String removePairConfirmation({required String exchange, required String symbol}) =>
      '¿Estás seguro de que quieres remover $symbol de $exchange?';

  @override
  String get remove => 'Remover';

  @override
  String get cannotRemovePair => 'No se Puede Remover el Par';

  @override
  String cannotRemovePairWithPositions({required int count}) =>
      'Este par tiene $count posición(es) abierta(s). Por favor cierra todas las posiciones antes de remover el par.';

  @override
  String pairRemovedSuccess({required String symbol}) =>
      'Par $symbol removido exitosamente';

  @override
  String pairAddedSuccess({required String symbol}) =>
      'Par $symbol agregado exitosamente';

  @override
  String get addNewPair => 'Agregar Nuevo Par de Trading';

  @override
  String get exchange => 'Exchange';

  @override
  String get pleaseSelectExchange => 'Por favor selecciona un exchange';

  @override
  String get searchPairs => 'Buscar pares';

  @override
  String get noPairsFound => 'No se encontraron pares';

  @override
  String get selectedPair => 'Par Seleccionado';

  @override
  String get inactive => 'Inactivo';

  @override
  String get notAvailable => 'N/D';

  @override
  String get lastPrice => 'Último Precio';

  @override
  String get volume24h => 'Volumen 24h';

  @override
  String get exposure => 'Exposición';

  // Alerts Screen
  @override
  String get activeAlerts => 'Alertas Activas';

  @override
  String get alertConfiguration => 'Configuración de Alertas';

  @override
  String get noActiveAlerts => 'Sin Alertas Activas';

  @override
  String get allClear => 'Todo despejado - sin alertas en este momento';

  @override
  String get noAlertsYet => 'Sin Alertas Aún';

  @override
  String get alertHistoryWillAppearHere => 'Tu historial de alertas aparecerá aquí';

  @override
  String get manageAlertRules => 'Administrar Reglas de Alerta';

  @override
  String get configureAlertConditions => 'Configurar condiciones y umbrales de alerta';

  @override
  String get testAlertSystem => 'Probar Sistema de Alertas';

  @override
  String get sendTestAlert => 'Enviar una alerta de prueba para verificar la configuración';

  @override
  String get alertAcknowledged => 'Alerta reconocida';

  @override
  String get alertDismissed => 'Alerta descartada';

  @override
  String get trigger => 'Disparador';

  @override
  String get value => 'Valor';

  @override
  String get acknowledge => 'Reconocer';

  @override
  String get errorLoadingAlerts => 'Error al Cargar Alertas';

  @override
  String get enableAlerts => 'Habilitar Alertas';

  @override
  String get toggleAlertSystem => 'Activar/desactivar sistema de alertas';

  @override
  String get notificationSettings => 'Configuración de Notificaciones';

  @override
  String get pushNotifications => 'Notificaciones Push';

  @override
  String get inAppNotifications => 'Notificaciones en la aplicación';

  @override
  String get telegramConfiguration => 'Configuración de Telegram';

  @override
  String get telegramBotToken => 'Token del Bot de Telegram';

  @override
  String get telegramChatId => 'ID de Chat de Telegram';

  @override
  String get pleaseEnterTelegramToken => 'Por favor ingresa el token del bot de Telegram';

  @override
  String get pleaseEnterTelegramChatId => 'Por favor ingresa el ID de chat de Telegram';

  @override
  String get telegramSetupInstructions =>
      'Crea un bot con @BotFather y obtén tu ID de chat desde @userinfobot';

  @override
  String get alertRules => 'Reglas de Alerta';

  @override
  String get addRule => 'Agregar Regla';

  @override
  String get noAlertRulesYet => 'Sin Reglas de Alerta Aún';

  @override
  String get tapAddToCreateRule => 'Toca "Agregar Regla" para crear tu primera regla de alerta';

  @override
  String get type => 'Tipo';

  @override
  String get threshold => 'Umbral';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get errorLoadingConfiguration => 'Error al Cargar Configuración';

  @override
  String get alertConfigurationSaved => 'Configuración de alertas guardada exitosamente';

  @override
  String get ruleAdded => 'Regla de alerta agregada exitosamente';

  @override
  String get ruleUpdated => 'Regla de alerta actualizada exitosamente';

  @override
  String get deleteRule => 'Eliminar Regla';

  @override
  String confirmDeleteRule({required String name}) =>
      '¿Estás seguro de que quieres eliminar la regla "$name"?';

  @override
  String get ruleDeleted => 'Regla de alerta eliminada exitosamente';

  @override
  String get addAlertRule => 'Agregar Regla de Alerta';

  @override
  String get editAlertRule => 'Editar Regla de Alerta';

  @override
  String get ruleName => 'Nombre de Regla';

  @override
  String get pleaseEnterRuleName => 'Por favor ingresa el nombre de la regla';

  @override
  String get alertType => 'Tipo de Alerta';

  @override
  String get pleaseEnterValidNumber => 'Por favor ingresa un número válido';

  @override
  String get severity => 'Severidad';

  @override
  String get cooldownMinutes => 'Enfriamiento (minutos)';

  @override
  String get preventDuplicateAlerts => 'Prevenir alertas duplicadas durante este período';

  @override
  String get testAlertSent => 'Alerta de prueba enviada exitosamente';
}
