// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

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
  String get openPositions => 'Posiciones Abiertas';

  @override
  String get history => 'Historial';

  @override
  String closingPosition(String positionId) {
    return 'Cerrando posición $positionId...';
  }

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
  String get killSwitchDeactivated =>
      'Kill Switch desactivado - Trading reanudado';

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
  String get higherRiskLargerPositions =>
      'Mayor riesgo, posiciones más grandes';

  @override
  String riskModeChanged(String mode) {
    return 'Modo de riesgo cambiado a $mode';
  }

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
  String get strategiesOverview => 'Resumen de Estrategias';

  @override
  String get active => 'Activo';

  @override
  String get avgWinRate => 'Tasa de Acierto Promedio';

  @override
  String get availableStrategies => 'Estrategias Disponibles';

  @override
  String strategyActivated(String name) {
    return 'Estrategia \"$name\" activada';
  }

  @override
  String strategyDeactivated(String name) {
    return 'Estrategia \"$name\" desactivada';
  }

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
  String configureStrategy(String name) {
    return 'Configurar $name';
  }

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
  String get aiBotTitle => 'Control de Bot IA';

  @override
  String get aiBotStatus => 'Estado del Bot';

  @override
  String get aiBotRunning => 'En ejecución';

  @override
  String get aiBotPaused => 'Pausado';

  @override
  String get aiBotStopped => 'Detenido';

  @override
  String get aiBotStart => 'Iniciar Bot';

  @override
  String get aiBotStop => 'Detener Bot';

  @override
  String get aiBotPause => 'Pausar Bot';

  @override
  String get aiBotResume => 'Reanudar Bot';

  @override
  String get aiBotEmergencyStop => 'Parada de Emergencia';

  @override
  String get aiBotAnalysisCount => 'Análisis';

  @override
  String get aiBotExecutionCount => 'Ejecuciones';

  @override
  String get aiBotErrorCount => 'Errores';

  @override
  String get aiBotOpenPositions => 'Posiciones Abiertas';

  @override
  String get aiBotDailyLoss => 'Pérdida Diaria';

  @override
  String get aiBotDailyTrades => 'Operaciones Diarias';

  @override
  String get aiBotConfirmStart =>
      '¿Estás seguro de que quieres iniciar el Bot IA?';

  @override
  String get aiBotConfirmStop =>
      '¿Estás seguro de que quieres detener el Bot IA?';

  @override
  String get aiBotConfirmEmergency =>
      'La parada de emergencia detendrá inmediatamente todas las operaciones del Bot IA. ¿Continuar?';

  @override
  String get aiBotStartedSuccess => 'Bot IA iniciado exitosamente';

  @override
  String get aiBotStoppedSuccess => 'Bot IA detenido exitosamente';

  @override
  String get aiBotConfig => 'Configuración del Bot';

  @override
  String get aiBotConfigTitle => 'Configurar Bot IA';

  @override
  String get aiBotConfigSave => 'Guardar Configuración';

  @override
  String get aiBotDryRun => 'Modo Simulación';

  @override
  String get aiBotLiveMode => 'Modo Trading en Vivo';

  @override
  String get aiBotAutoExecute => 'Ejecución Automática';

  @override
  String get aiBotConfidenceThreshold => 'Umbral de Confianza';

  @override
  String get aiBotTradeSize => 'Tamaño de Operación';

  @override
  String get aiBotLeverage => 'Apalancamiento';

  @override
  String get aiBotMaxDailyLoss => 'Pérdida Diaria Máxima';

  @override
  String get aiBotMaxDailyTrades => 'Operaciones Diarias Máximas';

  @override
  String get aiBotTradingPair => 'Par de Trading';

  @override
  String get aiBotPresetConservative => 'Conservador';

  @override
  String get aiBotPresetIntermediate => 'Intermedio';

  @override
  String get aiBotPresetAggressive => 'Agresivo';

  @override
  String get aiBotWarningLiveMode =>
      'Advertencia: El modo de trading en vivo ejecutará operaciones reales con fondos reales';

  @override
  String get aiBotConfigUpdated =>
      'Configuración del Bot IA actualizada exitosamente';

  @override
  String get analysisTitle => 'Análisis de Mercado';

  @override
  String get analysisRefresh => 'Actualizar Análisis';

  @override
  String get analysisLoading => 'Analizando datos del mercado...';

  @override
  String get analysisTechnical => 'Análisis Técnico';

  @override
  String get analysisMultiTimeframe => 'Análisis Multi-Temporalidad';

  @override
  String get analysisRecommendation => 'Recomendación de Trading';

  @override
  String get analysisScenarios => 'Escenarios';

  @override
  String get analysisRisk => 'Análisis de Riesgo';

  @override
  String get analysisOversold => 'Sobrevendido';

  @override
  String get analysisOverbought => 'Sobrecomprado';

  @override
  String get analysisNeutral => 'Neutral';

  @override
  String get analysisBullish => 'Alcista';

  @override
  String get analysisBearish => 'Bajista';

  @override
  String get analysisLowRisk => 'Riesgo Bajo';

  @override
  String get analysisMediumRisk => 'Riesgo Medio';

  @override
  String get analysisHighRisk => 'Riesgo Alto';

  @override
  String get analysisConfidence => 'Confianza';

  @override
  String get analysisEntry => 'Precio de Entrada';

  @override
  String get analysisStopLoss => 'Stop Loss';

  @override
  String get analysisTakeProfit => 'Take Profit';

  @override
  String get futuresPositions => 'Posiciones de Futuros';

  @override
  String get futuresClose => 'Cerrar Posición';

  @override
  String get futuresCloseAll => 'Cerrar Todas las Posiciones';

  @override
  String get futuresCloseConfirm =>
      '¿Estás seguro de que quieres cerrar esta posición?';

  @override
  String get futuresClosedSuccess => 'Posición cerrada exitosamente';

  @override
  String get futuresSize => 'Tamaño de Posición';

  @override
  String get futuresLeverage => 'Apalancamiento';

  @override
  String get futuresMargin => 'Margen';

  @override
  String get futuresLiquidation => 'Precio de Liquidación';

  @override
  String get futuresUnrealizedPnl => 'P&L No Realizado';

  @override
  String get futuresRealizedPnl => 'P&L Realizado';

  @override
  String get futuresTotalPnl => 'P&L Total';

  @override
  String get confirm => 'Confirmar';

  @override
  String get error => 'Error';

  @override
  String get success => 'Éxito';

  @override
  String get refresh => 'Actualizar';

  @override
  String get back => 'Atrás';

  @override
  String get close => 'Cerrar';

  @override
  String get multiTimeframeAnalysis => 'Análisis Multi-Temporalidad';

  @override
  String get technicalAnalysisMultipleTimeframes =>
      'Análisis técnico en múltiples temporalidades';

  @override
  String get backtesting => 'Backtesting';

  @override
  String get testStrategiesWithHistoricalData =>
      'Prueba estrategias con datos históricos';

  @override
  String get parameterOptimization => 'Optimización de Parámetros';

  @override
  String get optimizeStrategyParameters => 'Optimiza parámetros de estrategia';

  @override
  String get performanceCharts => 'Gráficas de Rendimiento';

  @override
  String get emergencyStopActivated => 'Parada de Emergencia Activada';

  @override
  String get botResumedSuccess => 'Bot reanudado exitosamente';

  @override
  String get mode => 'Modo';

  @override
  String get botMetrics => 'Métricas del Bot';

  @override
  String get total => 'Total';

  @override
  String get executed => 'Ejecutadas';

  @override
  String get percentUsed => '% usado';

  @override
  String get dailyLimits => 'Límites Diarios';

  @override
  String get consecutive => 'consecutivos';

  @override
  String get tradingMode => 'Modo de Trading';

  @override
  String get simulationMode => 'Modo de simulación - sin operaciones reales';

  @override
  String get autoExecuteDescription =>
      'Ejecutar automáticamente las recomendaciones de IA';

  @override
  String get tradingParameters => 'Parámetros de Trading';

  @override
  String get minimumConfidenceDescription =>
      'Confianza mínima requerida para operaciones';

  @override
  String get leverageDescription =>
      'Multiplicador de apalancamiento de trading';

  @override
  String get required => 'Requerido';

  @override
  String get mustBePositive => 'Debe ser positivo';

  @override
  String get safetyLimits => 'Límites de Seguridad';

  @override
  String get configurationPresets => 'Presets de Configuración';

  @override
  String get high24h => 'Máximo 24h';

  @override
  String get low24h => 'Mínimo 24h';

  @override
  String get volume => 'Volumen';

  @override
  String get trend => 'Tendencia';

  @override
  String get aligned => 'ALINEADO';

  @override
  String get notAligned => 'NO ALINEADO';

  @override
  String get reasoning => 'Razonamiento:';

  @override
  String get target => 'Objetivo';

  @override
  String get riskScore => 'Puntuación de Riesgo:';

  @override
  String get volatility => 'Volatilidad:';

  @override
  String get riskFactors => 'Factores de Riesgo:';

  @override
  String get appTitle => 'Kuri Crypto';

  @override
  String get startTrading => 'Iniciar Trading';

  @override
  String get activeStrategies => 'Estrategias Activas';

  @override
  String get recentAlerts => 'Alertas Recientes';

  @override
  String get entry => 'Entrada';

  @override
  String get current => 'Actual';

  @override
  String get long => 'LARGO';

  @override
  String get short => 'CORTO';

  @override
  String get rsiScalping => 'Scalping RSI';

  @override
  String get macdScalping => 'Scalping MACD';

  @override
  String get bollingerScalping => 'Scalping Bollinger';

  @override
  String get volumeScalping => 'Scalping por Volumen';

  @override
  String get paused => 'Pausado';

  @override
  String get warning => 'Advertencia';

  @override
  String get info => 'Información';

  @override
  String get change24h => 'Cambio 24h';

  @override
  String get riskLevel => 'Nivel de Riesgo';

  @override
  String get low => 'Bajo';

  @override
  String get medium => 'Medio';

  @override
  String get high => 'Alto';

  @override
  String get critical => 'Crítico';

  @override
  String get acknowledge => 'Reconocer';

  @override
  String get activate => 'Activar';

  @override
  String get activateKillSwitch => 'Activar Kill Switch';

  @override
  String get activeAlerts => 'Alertas Activas';

  @override
  String get add => 'Añadir';

  @override
  String get addAlertRule => 'Añadir Regla de Alerta';

  @override
  String get addNewPair => 'Añadir Nuevo Par';

  @override
  String get addPair => 'Añadir Par';

  @override
  String get addParameter => 'Añadir Parámetro';

  @override
  String get addRule => 'Añadir Regla';

  @override
  String get alertAcknowledged => 'Alerta Reconocida';

  @override
  String get alertConfiguration => 'Configuración de Alertas';

  @override
  String get alertConfigurationSaved => 'Configuración de Alertas Guardada';

  @override
  String get alertDismissed => 'Alerta Descartada';

  @override
  String get alertHistoryWillAppearHere =>
      'El historial de alertas aparecerá aquí';

  @override
  String get alertRules => 'Reglas de Alertas';

  @override
  String get alertType => 'Tipo de Alerta';

  @override
  String get all => 'Todos';

  @override
  String get allClear => 'Todo Despejado';

  @override
  String get allPositionsWillClose => 'Todas las posiciones se cerrarán';

  @override
  String get allResults => 'Todos los Resultados';

  @override
  String get allStrategies => 'Todas las Estrategias';

  @override
  String get allSymbols => 'Todos los Símbolos';

  @override
  String get allTradingWillStop => 'Todo el trading se detendrá';

  @override
  String get apply => 'Aplicar';

  @override
  String get applyParameters => 'Aplicar Parámetros';

  @override
  String get applyParametersConfirmation =>
      '¿Estás seguro de que quieres aplicar estos parámetros?';

  @override
  String get applyTheseParameters => 'Aplicar Estos Parámetros';

  @override
  String get areYouSure => '¿Estás seguro?';

  @override
  String get average => 'Promedio';

  @override
  String get avgExecutionTime => 'Tiempo de Ejecución Promedio';

  @override
  String get avgSlippage => 'Slippage Promedio';

  @override
  String get avgWaitTime => 'Tiempo de Espera Promedio';

  @override
  String get backToForm => 'Volver al Formulario';

  @override
  String get backtestConfiguration => 'Configuración de Backtest';

  @override
  String get backtestFailed => 'Backtest Falló';

  @override
  String get backtestRunning => 'Backtest en Ejecución';

  @override
  String get backtestStarted => 'Backtest Iniciado';

  @override
  String get basisPoints => 'Puntos Base';

  @override
  String get bayesianOptimization => 'Optimización Bayesiana';

  @override
  String get bayesianOptimizationDesc =>
      'Búsqueda inteligente usando métodos bayesianos';

  @override
  String get bestParameters => 'Mejores Parámetros';

  @override
  String get bestScore => 'Mejor Puntuación';

  @override
  String get cancelOptimization => 'Cancelar Optimización';

  @override
  String get cancelOptimizationConfirmation =>
      '¿Estás seguro de que quieres cancelar esta optimización?';

  @override
  String get cancelled => 'Cancelado';

  @override
  String get cannotRemovePair => 'No se puede eliminar el par';

  @override
  String get cannotRemovePairWithPositions =>
      'No se puede eliminar un par con posiciones abiertas';

  @override
  String get combinations => 'combinaciones';

  @override
  String get completed => 'Completado';

  @override
  String get confidence => 'Confianza';

  @override
  String get configureAlertConditions => 'Configurar Condiciones de Alertas';

  @override
  String get confirmDeactivation => 'Confirmar Desactivación';

  @override
  String get confirmDeleteRule => 'Eliminar Regla';

  @override
  String get confirmResumeTrading => 'Reanudar Trading';

  @override
  String get consensusSignal => 'Señal de Consenso';

  @override
  String get continue_ => 'Continuar';

  @override
  String get cooldownMinutes => 'Tiempo de Espera (minutos)';

  @override
  String get dateRange => 'Rango de Fechas';

  @override
  String get deactivateKillSwitch => 'Desactivar Kill Switch';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteOptimization => 'Eliminar Optimización';

  @override
  String get deleteOptimizationConfirmation =>
      '¿Estás seguro de que quieres eliminar esta optimización?';

  @override
  String get deleteRule => 'Eliminar Regla';

  @override
  String get dismiss => 'Descartar';

  @override
  String get drawdownChart => 'Gráfico de Reducciones';

  @override
  String get duration => 'Duración';

  @override
  String get edit => 'Editar';

  @override
  String get editAlertRule => 'Editar Regla de Alerta';

  @override
  String get editParameter => 'Editar Parámetro';

  @override
  String get enableAlerts => 'Habilitar Alertas';

  @override
  String get endDate => 'Fecha Final';

  @override
  String get enterAmount => 'Ingresa Monto';

  @override
  String get entryPrice => 'Precio de Entrada';

  @override
  String get entryTime => 'Hora de Entrada';

  @override
  String get equityCurve => 'Curva de Capital';

  @override
  String get errorLoadingAlerts => 'Error al cargar alertas';

  @override
  String get errorLoadingConfiguration => 'Error al cargar la configuración';

  @override
  String get errorOccurred => 'Ocurrió un error';

  @override
  String get errorRate => 'Tasa de Error';

  @override
  String get estimatedCombinations => 'Combinaciones Estimadas';

  @override
  String get estimatedTimeRemaining => 'Tiempo Estimado Restante';

  @override
  String get exchange => 'Intercambio';

  @override
  String get executionPerformance => 'Rendimiento de Ejecución';

  @override
  String get executionQueue => 'Cola de Ejecución';

  @override
  String get executionsTracked => 'Ejecuciones Rastreadas';

  @override
  String get exitPrice => 'Precio de Salida';

  @override
  String get exitTime => 'Hora de Salida';

  @override
  String get exposure => 'Exposición';

  @override
  String get failed => 'Fallido';

  @override
  String get failedExecutions => 'Ejecuciones Fallidas';

  @override
  String get fillRate => 'Tasa de Ejecución';

  @override
  String get filled => 'Ejecutado';

  @override
  String get filterByStatus => 'Filtrar por Estado';

  @override
  String get filterByStrategy => 'Filtrar por Estrategia';

  @override
  String get filterBySymbol => 'Filtrar por Símbolo';

  @override
  String get goBack => 'Volver';

  @override
  String get gridSearch => 'Búsqueda de Cuadrícula';

  @override
  String get gridSearchDesc =>
      'Búsqueda exhaustiva a través de la cuadrícula de parámetros';

  @override
  String get inAppNotifications => 'Notificaciones en la Aplicación';

  @override
  String get inactive => 'Inactivo';

  @override
  String get initialCapital => 'Capital Inicial';

  @override
  String get killSwitchActive => 'Kill Switch Activo';

  @override
  String get killSwitchWarning => 'Advertencia de Kill Switch';

  @override
  String get lastPrice => 'Último Precio';

  @override
  String get latency => 'Latencia';

  @override
  String get latencyChart => 'Gráfico de Latencia';

  @override
  String get latencyStatistics => 'Estadísticas de Latencia';

  @override
  String get loadingResults => 'Cargando resultados...';

  @override
  String get manageAlertRules => 'Administrar Reglas de Alertas';

  @override
  String get max => 'Máximo';

  @override
  String get maxConsecutiveLosses => 'Pérdidas Consecutivas Máximas';

  @override
  String get maxDrawdown => 'Reducciones Máximas';

  @override
  String get maxIterations => 'Iteraciones Máximas';

  @override
  String get maximum => 'Máximo';

  @override
  String get maximumValue => 'Valor Máximo';

  @override
  String get median => 'Mediana';

  @override
  String get min => 'Mínimo';

  @override
  String get minimum => 'Mínimo';

  @override
  String get minimumValue => 'Valor Mínimo';

  @override
  String get newBacktest => 'Nuevo Backtest';

  @override
  String get newOptimization => 'Nueva Optimización';

  @override
  String get no => 'No';

  @override
  String get noActiveAlerts => 'Sin Alertas Activas';

  @override
  String get noAlertRulesYet => 'Sin reglas de alertas aún';

  @override
  String get noAlertsYet => 'Sin alertas aún';

  @override
  String get noBacktestsYet => 'Sin backtests aún';

  @override
  String get noExecutionsYet => 'Sin ejecuciones aún';

  @override
  String get noOptimizationsYet => 'Sin optimizaciones aún';

  @override
  String get noPairsFound => 'No se encontraron pares';

  @override
  String get noParametersConfigured => 'Sin parámetros configurados';

  @override
  String get noTradingPairs => 'Sin Pares de Trading';

  @override
  String get notAvailable => 'No Disponible';

  @override
  String get notificationSettings => 'Configuración de Notificaciones';

  @override
  String get objective => 'Objetivo';

  @override
  String get objectiveToOptimize => 'Objetivo a Optimizar';

  @override
  String get ofLabel => 'de';

  @override
  String get ok => 'Aceptar';

  @override
  String get optimizationCancelled => 'Optimización Cancelada';

  @override
  String get optimizationCancelledSuccessfully =>
      'Optimización cancelada exitosamente';

  @override
  String get optimizationConfiguration => 'Configuración de Optimización';

  @override
  String get optimizationDeletedSuccessfully =>
      'Optimización eliminada exitosamente';

  @override
  String get optimizationFailed => 'Optimización Falló';

  @override
  String get optimizationMethod => 'Método de Optimización';

  @override
  String get optimizationResults => 'Resultados de Optimización';

  @override
  String get optimizationRunning => 'Optimización en Ejecución';

  @override
  String get optimizationStarted => 'Optimización Iniciada';

  @override
  String get optimizationSummary => 'Resumen de Optimización';

  @override
  String get orderId => 'ID de Orden';

  @override
  String get orderType => 'Tipo de Orden';

  @override
  String pairAddedSuccess(Object symbol) {
    return 'Par $symbol añadido exitosamente';
  }

  @override
  String pairRemovedSuccess(Object symbol) {
    return 'Par $symbol eliminado exitosamente';
  }

  @override
  String get parameterName => 'Nombre del Parámetro';

  @override
  String get parameterRanges => 'Rangos de Parámetros';

  @override
  String get parameters => 'Parámetros';

  @override
  String get parametersAppliedSuccessfully =>
      'Parámetros aplicados exitosamente';

  @override
  String get partial => 'Parcial';

  @override
  String get percentile95 => 'Percentil 95';

  @override
  String get percentile99 => 'Percentil 99';

  @override
  String get performance => 'Rendimiento';

  @override
  String get period30d => '30 Días';

  @override
  String get period7d => '7 Días';

  @override
  String get period90d => '90 Días';

  @override
  String get periodAll => 'Todo el Tiempo';

  @override
  String get pleaseEnterRuleName => 'Por favor ingresa el nombre de la regla';

  @override
  String get pleaseEnterTelegramChatId =>
      'Por favor ingresa el ID de Chat de Telegram';

  @override
  String get pleaseEnterTelegramToken =>
      'Por favor ingresa el Token del Bot de Telegram';

  @override
  String get pleaseEnterValidNumber => 'Por favor ingresa un número válido';

  @override
  String get pleaseFixConfigurationErrors =>
      'Por favor corrige los errores de configuración';

  @override
  String get pleaseSelectExchange => 'Por favor selecciona un intercambio';

  @override
  String get pnl => 'P&L';

  @override
  String get pnlChart => 'Gráfico de P&L';

  @override
  String get preventDuplicateAlerts => 'Prevenir Alertas Duplicadas';

  @override
  String get price => 'Precio';

  @override
  String get profitFactor => 'Factor de Ganancia';

  @override
  String get pushNotifications => 'Notificaciones Push';

  @override
  String get queue => 'Cola';

  @override
  String get queueEmpty => 'Cola Vacía';

  @override
  String get queueLength => 'Longitud de Cola';

  @override
  String get queueStatus => 'Estado de la Cola';

  @override
  String get randomSearch => 'Búsqueda Aleatoria';

  @override
  String get randomSearchDesc =>
      'Búsqueda aleatoria a través del espacio de parámetros';

  @override
  String get rank => 'Rango';

  @override
  String get refreshStats => 'Actualizar Estadísticas';

  @override
  String get rejected => 'Rechazado';

  @override
  String get remove => 'Eliminar';

  @override
  String get removePair => 'Eliminar Par';

  @override
  String get removePairConfirmation =>
      '¿Estás seguro de que quieres eliminar este par?';

  @override
  String get requiresManualReactivation => 'Requiere Reactivación Manual';

  @override
  String get results => 'Resultados';

  @override
  String get resume => 'Reanudar';

  @override
  String get retry => 'Reintentar';

  @override
  String get ruleAdded => 'Regla Añadida';

  @override
  String get ruleDeleted => 'Regla Eliminada';

  @override
  String get ruleName => 'Nombre de la Regla';

  @override
  String get ruleUpdated => 'Regla Actualizada';

  @override
  String get runBacktest => 'Ejecutar Backtest';

  @override
  String get runOptimization => 'Ejecutar Optimización';

  @override
  String get score => 'Puntuación';

  @override
  String get scoreDistribution => 'Distribución de Puntuación';

  @override
  String get searchPairs => 'Buscar Pares';

  @override
  String get selectSymbolToAnalyze => 'Seleccionar Símbolo para Analizar';

  @override
  String get selectedPair => 'Par Seleccionado';

  @override
  String get sendTestAlert => 'Enviar Alerta de Prueba';

  @override
  String get severity => 'Severidad';

  @override
  String get sharpeRatio => 'Razón de Sharpe';

  @override
  String get sharpeRatioDesc => 'Métrica de retorno ajustado al riesgo';

  @override
  String get showing => 'Mostrando';

  @override
  String get side => 'Lado';

  @override
  String get signal => 'Señal';

  @override
  String get size => 'Tamaño';

  @override
  String get slippageBySymbol => 'Slippage por Símbolo';

  @override
  String get sortBy => 'Ordenar Por';

  @override
  String get startDate => 'Fecha de Inicio';

  @override
  String get started => 'Iniciado';

  @override
  String get status => 'Estado';

  @override
  String get step => 'Paso';

  @override
  String get stepSize => 'Tamaño de Paso';

  @override
  String get strategy => 'Estrategia';

  @override
  String get successfulExecutions => 'Ejecuciones Exitosas';

  @override
  String get symbol => 'Símbolo';

  @override
  String get tapAddPairToStart => 'Toca \'+ Añadir Par\' para empezar';

  @override
  String get tapAddToCreateRule => 'Toca \'+ Añadir\' para crear una regla';

  @override
  String get technicalIndicators => 'Indicadores Técnicos';

  @override
  String get telegramBotToken => 'Token del Bot de Telegram';

  @override
  String get telegramChatId => 'ID de Chat de Telegram';

  @override
  String get telegramConfiguration => 'Configuración de Telegram';

  @override
  String get telegramSetupInstructions =>
      'Instrucciones de Configuración de Telegram';

  @override
  String get testAlertSent => 'Alerta de Prueba Enviada';

  @override
  String get testAlertSystem => 'Sistema de Alertas de Prueba';

  @override
  String get thisWillResumeTrading => 'Esto reanudará el trading. ¿Continuar?';

  @override
  String get threshold => 'Umbral';

  @override
  String get time => 'Tiempo';

  @override
  String get timeInQueue => 'Tiempo en Cola';

  @override
  String get toggleAlertSystem => 'Alternar Sistema de Alertas';

  @override
  String get totalCombinations => 'Combinaciones Totales';

  @override
  String get totalPnlDesc => 'Ganancia y Pérdida Total';

  @override
  String get tradeHistory => 'Historial de Operaciones';

  @override
  String get trades => 'Operaciones';

  @override
  String get tradingDisabled => 'Trading Deshabilitado';

  @override
  String get tradingSignal => 'Señal de Trading';

  @override
  String get trigger => 'Desencadenante';

  @override
  String get type => 'Tipo';

  @override
  String get value => 'Valor';

  @override
  String get volume24h => 'Volumen 24h';

  @override
  String get winRateChart => 'Gráfico de Tasa de Acierto';

  @override
  String get winRateDesc => 'Porcentaje de operaciones ganadoras';

  @override
  String get yes => 'Sí';
}
