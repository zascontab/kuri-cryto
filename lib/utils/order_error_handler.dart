
/// Sistema de manejo de errores de órdenes según la documentación del backend.
///
/// Este handler es CRÍTICO para evitar duplicación de órdenes en caso de
/// errores de red. Cuando se recibe un NETWORK_ERROR, la orden puede estar:
/// - ✅ Ejecutada exitosamente (pero sin confirmación)
/// - ❌ Realmente fallada
/// - ⏳ Pendiente de ejecución
///
/// Reintentar ciegamente puede duplicar órdenes y perder dinero real.
class OrderErrorHandler {
  final dynamic _client;

  OrderErrorHandler(this._client);

  /// Maneja la sumisión de una orden con verificación de estado en caso de
  /// errores de red.
  ///
  /// [orderFn] es la función que ejecuta la orden (ej: client.executeOrder)
  /// [params] son los parámetros de la orden (pair, side, amount, etc.)
  ///
  /// Retorna un [OrderResult] con el estado de la orden.
  Future<OrderResult> handleOrderSubmission(
    Function orderFn,
    Map<String, dynamic> params,
  ) async {
    try {
      // Intentar ejecutar orden
      final result = await orderFn(params);
      return OrderResult.success(result);
    } catch (e) {
      final errorMsg = e.toString();

      // CRÍTICO: Network errors requieren verificación
      if (errorMsg.contains('NETWORK_ERROR') ||
          errorMsg.contains('timeout') ||
          errorMsg.contains('Connection')) {
        return await _verifyOrderState(params);
      }

      // Errores definitivos - NO reintentar
      if (errorMsg.contains('INSUFFICIENT_BALANCE')) {
        return OrderResult.error('Insufficient balance');
      }

      if (errorMsg.contains('INVALID_LEVERAGE')) {
        return OrderResult.error('Invalid leverage (1-100x)');
      }

      if (errorMsg.contains('MARGIN_MODE_MISMATCH')) {
        return OrderResult.error(
          'Margin mode mismatch. Close existing positions first.',
        );
      }

      // Error desconocido
      return OrderResult.error('Order failed: $errorMsg');
    }
  }

  /// Verifica el estado real de la orden después de un error de red.
  ///
  /// Espera 3 segundos para reconciliación automática del backend, luego
  /// verifica:
  /// 1. Si existe una posición que coincida con los parámetros
  /// 2. Si hay órdenes pendientes
  /// 3. Si es seguro reintentar
  Future<OrderResult> _verifyOrderState(Map<String, dynamic> params) async {
    // Mostrar estado de verificación (esto se debe manejar en la UI)
    // showStatus('Network error. Verifying order status...');

    // Esperar 3 segundos para reconciliación automática del backend
    await Future.delayed(const Duration(seconds: 3));

    // Verificar posiciones reales
    final positions = await _client.getPositions();

    // Buscar posición que coincida con los parámetros
    final matchingPosition = positions.firstWhereOrNull(
      (p) =>
          p.symbol == params['pair'] &&
          p.side == params['side'] &&
          p.openTime.isAfter(DateTime.now().subtract(const Duration(seconds: 10))),
    );

    if (matchingPosition != null) {
      // ⚠️ LA ORDEN SE EJECUTÓ PESE AL ERROR
      return OrderResult.executedDespiteError(matchingPosition);
    }

    // Verificar órdenes pendientes
    final orders = await _client.getOpenOrders();
    if (orders.isNotEmpty) {
      return OrderResult.pending('Order is pending confirmation');
    }

    // La orden NO se ejecutó - seguro reintentar
    return OrderResult.safeToRetry();
  }
}

/// Modelo de resultado de una orden.
///
/// Representa los diferentes estados posibles después de intentar ejecutar
/// una orden.
class OrderResult {
  final OrderStatus status;
  final dynamic data;
  final String? message;

  /// Orden ejecutada exitosamente.
  OrderResult.success(this.data)
      : status = OrderStatus.success,
        message = null;

  /// Orden falló con un error definitivo.
  OrderResult.error(this.message)
      : status = OrderStatus.error,
        data = null;

  /// Orden se ejecutó a pesar del error de red.
  OrderResult.executedDespiteError(this.data)
      : status = OrderStatus.executedDespiteError,
        message = 'Order was executed despite network error';

  /// Orden está pendiente de confirmación.
  OrderResult.pending(this.message)
      : status = OrderStatus.pending,
        data = null;

  /// Es seguro reintentar la orden.
  OrderResult.safeToRetry()
      : status = OrderStatus.safeToRetry,
        data = null,
        message = 'Order was not executed - safe to retry';
}

/// Estados posibles de una orden.
enum OrderStatus {
  /// Orden ejecutada exitosamente
  success,

  /// Error definitivo (no reintentar)
  error,

  /// Orden ejecutada a pesar del error de red
  executedDespiteError,

  /// Orden pendiente de confirmación
  pending,

  /// Seguro reintentar la orden
  safeToRetry,
}
