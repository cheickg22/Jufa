import 'package:dio/dio.dart';
import 'auth_service.dart';
import '../config/app_config.dart';

class ApiNotificationService {
  final Dio _dio = Dio();

  /// Récupérer toutes les notifications
  Future<List<dynamic>> getNotifications() async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/notifications',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true) {
        return response.data['data'] as List<dynamic>;
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération des notifications');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Récupérer le nombre de notifications non lues
  Future<int> getUnreadCount() async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        return 0;
      }

      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/notifications/unread-count',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // L'API retourne directement {'count': X}
      return response.data['count'] ?? 0;
    } catch (e) {
      print('Erreur lors de la récupération du nombre de notifications non lues: $e');
      return 0;
    }
  }

  /// Marquer une notification comme lue
  Future<void> markAsRead(int notificationId) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      await _dio.post(
        '${AppConfig.apiBaseUrl}/notifications/$notificationId/mark-as-read',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      print('Erreur lors du marquage comme lu: $e');
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      await _dio.post(
        '${AppConfig.apiBaseUrl}/notifications/mark-all-as-read',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      print('Erreur lors du marquage de toutes les notifications: $e');
    }
  }

  /// Supprimer une notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      await _dio.delete(
        '${AppConfig.apiBaseUrl}/notifications/$notificationId',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      print('Erreur lors de la suppression de la notification: $e');
    }
  }
}
