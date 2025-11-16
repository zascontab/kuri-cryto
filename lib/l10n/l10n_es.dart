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
}
