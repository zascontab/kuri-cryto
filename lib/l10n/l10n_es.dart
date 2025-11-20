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
}
