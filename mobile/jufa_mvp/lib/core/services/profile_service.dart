import 'dart:io';
import 'package:dio/dio.dart';
import 'auth_service.dart';
import '../config/app_config.dart';

class ProfileService {
  final Dio _dio = Dio();

  /// Mettre à jour le profil utilisateur
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      final data = <String, dynamic>{};
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;

      final response = await _dio.put(
        '${AppConfig.apiBaseUrl}/auth/profile',
        data: data,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true) {
        return response.data['data']['user'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la mise à jour du profil');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Changer le mot de passe
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erreur lors du changement de mot de passe');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Erreur serveur';
        throw Exception(message);
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Configurer ou modifier le code PIN
  Future<void> setPin({
    required String pin,
    required String confirmPin,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/auth/set-pin',
        data: {
          'pin': pin,
          'pin_confirmation': confirmPin,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erreur lors de la configuration du PIN');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Erreur serveur';
        throw Exception(message);
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Vérifier le code PIN
  Future<bool> verifyPin(String pin) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      print('🔐 Vérification PIN via API: $pin');
      
      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/auth/verify-pin',
        data: {'pin': pin},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('🔐 Réponse API: ${response.data}');
      
      // La réponse peut avoir deux formats:
      // Format 1: {success: true, valid: true, message: "..."}
      // Format 2: {success: true, data: {valid: true}, message: "..."}
      bool isValid = false;
      
      if (response.data['data'] != null && response.data['data'] is Map) {
        // Format 2: valid est dans data
        isValid = response.data['success'] == true && response.data['data']['valid'] == true;
      } else {
        // Format 1: valid est au niveau racine
        isValid = response.data['success'] == true && response.data['valid'] == true;
      }
      
      print('🔐 PIN valide: $isValid');
      
      return isValid;
    } on DioException catch (e) {
      print('🔐 Erreur vérification PIN: ${e.response?.data}');
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Erreur serveur';
        throw Exception(message);
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Vérifier si un PIN est configuré
  Future<bool> hasPin() async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        return false;
      }

      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/auth/has-pin',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.data['success'] == true && response.data['has_pin'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Uploader une photo de profil
  Future<Map<String, dynamic>> uploadProfilePhoto(String imagePath) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      // Lire le fichier en bytes
      File imageFile = File(imagePath);
      List<int> imageBytes = await imageFile.readAsBytes();
      String fileName = imagePath.split('/').last;

      // Créer FormData avec MultipartFile depuis bytes
      FormData formData = FormData.fromMap({
        'photo': MultipartFile.fromBytes(
          imageBytes,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/auth/profile/photo',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de l\'upload de la photo');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Supprimer la photo de profil
  Future<void> deleteProfilePhoto() async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      final response = await _dio.delete(
        '${AppConfig.apiBaseUrl}/auth/profile/photo',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erreur lors de la suppression de la photo');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Envoyer un message à l'administrateur
  Future<void> sendMessageToAdmin({
    required String type,
    required String subject,
    required String message,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/messages/send-to-admin',
        data: {
          'type': type,
          'subject': subject,
          'message': message,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erreur lors de l\'envoi du message');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Erreur serveur';
        throw Exception(message);
      }
      throw Exception('Erreur de connexion');
    }
  }
}
