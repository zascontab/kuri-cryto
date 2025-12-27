import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/ai_status.dart';
import '../models/ai_costs.dart';
import '../models/ai_notification.dart';
import 'api_exception.dart';

/// Servicio para interactuar con los endpoints de IA del backend
///
/// Maneja:
/// - Estado del sistema de IA (LLM, sentimiento, costos)
/// - Costos de uso de IA
/// - Notificaciones inteligentes generadas por IA
///
/// ✅ NO REQUIERE AUTENTICACIÓN
class AIService {
  final Dio _dio;

  AIService(this._dio);

  /// Obtiene el estado completo del sistema de IA
  ///
  /// Retorna información sobre:
  /// - Estado del LLM (provider, model, calls, limits)
  /// - Estado del análisis de sentimiento
  /// - Gestión de costos (budget, spent, remaining)
  Future<AIStatus> getAIStatus() async {
    try {
      final response = await _dio.get(
        ApiConfig.aiBotStatusUrl,
      );
      return AIStatus.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtiene los costos de uso de IA
  ///
  /// Retorna:
  /// - Costos del día actual (total, por provider, call count)
  /// - Costos del mes actual (total, proyección)
  Future<AICosts> getAICosts() async {
    try {
      final response = await _dio.get(
        '${ApiConfig.aiBotBaseUrl}/costs',
      );
      return AICosts.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtiene las notificaciones inteligentes generadas por IA
  ///
  /// Retorna lista de notificaciones con:
  /// - Explicaciones generadas por LLM
  /// - Análisis de mercado
  /// - Evaluación de riesgo
  Future<List<AINotification>> getAINotifications() async {
    try {
      final response = await _dio.get(
        '${ApiConfig.aiBotBaseUrl}/notifications',
      );
      final data = response.data as Map<String, dynamic>;
      final notifications = data['notifications'] as List;
      return notifications
          .map((n) => AINotification.fromJson(n as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Marca una notificación como leída
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _dio.post(
        '${ApiConfig.aiBotBaseUrl}/notifications/$notificationId/read',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Marca todas las notificaciones como leídas
  Future<void> markAllNotificationsAsRead() async {
    try {
      await _dio.post(
        '${ApiConfig.aiBotBaseUrl}/notifications/read-all',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  ApiException _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      return ApiException(
        message: data['error'] ?? data['message'] ?? 'Unknown error',
        details: data['details'],
        statusCode: e.response!.statusCode,
      );
    }
    return ApiException(
      message: 'Network error: ${e.message}',
      statusCode: null,
    );
  }
}
