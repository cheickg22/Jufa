import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import '../config/app_config.dart';
import '../models/agent.dart';
import 'agent_auth_service.dart';

class AgentApiService {
  final Dio _dio;

  AgentApiService() : _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );


  // Inscription agent
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required String idCardType,
    required String idCardNumber,
    required String address,
    required String city,
    Uint8List? idCardFrontImageBytes,
    Uint8List? idCardBackImageBytes,
  }) async {
    try {
      final formData = FormData.fromMap({
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'email': email,
        'password': password,
        'id_card_type': idCardType,
        'id_card_number': idCardNumber,
        'address': address,
        'city': city,
      });

      // Ajouter les images si elles sont fournies
      if (idCardFrontImageBytes != null) {
        formData.files.add(MapEntry(
          'id_card_front_image',
          MultipartFile.fromBytes(idCardFrontImageBytes, filename: 'id_card_front.jpg'),
        ));
      }

      if (idCardBackImageBytes != null) {
        formData.files.add(MapEntry(
          'id_card_back_image',
          MultipartFile.fromBytes(idCardBackImageBytes, filename: 'id_card_back.jpg'),
        ));
      }

      final response = await _dio.post(
        '/agent/register',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return response.data;
    } catch (e) {
      print('❌ Erreur inscription agent: $e');
      rethrow;
    }
  }

  // Connexion agent
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    try {
      print('🔵 Tentative de connexion à: ${AppConfig.apiBaseUrl}/agent/login');
      print('🔵 Données: phone=$phone');
      
      final response = await _dio.post(
        '/agent/login',
        data: {
          'phone': phone,
          'password': password,
        },
      );

      print('✅ Réponse connexion: ${response.data}');
      
      // Sauvegarder le token et les données de l'agent
      if (response.data['success'] == true) {
        final token = response.data['data']['token'];
        final agentData = response.data['data']['agent'];
        final agent = Agent.fromJson(agentData);
        await AgentAuthService.saveAuth(token, agent);
      }
      
      return response.data;
    } on DioException catch (e) {
      print('🔴 DioException type: ${e.type}');
      print('🔴 DioException message: ${e.message}');
      print('🔴 DioException response: ${e.response?.data}');
      print('🔴 DioException error: ${e.error}');
      rethrow;
    } catch (e) {
      print('❌ Erreur connexion agent: $e');
      rethrow;
    }
  }

  // Récupérer le profil
  Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await _dio.get(
        '/agent/profile',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('🔍 getProfile - Réponse complète: ${response.data}');
      
      if (response.data != null && response.data['success'] == true) {
        final profileData = response.data['data'] ?? {};
        print('✅ getProfile - Data extraite: $profileData');
        return profileData;
      }
      return {};
    } catch (e) {
      print('❌ Erreur récupération profil: $e');
      rethrow;
    }
  }

  // Récupérer les statistiques
  Future<Map<String, dynamic>> getStats(String token) async {
    try {
      final response = await _dio.get(
        '/agent/stats',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data != null && response.data['success'] == true) {
        return response.data['data'] ?? {};
      }
      return {};
    } catch (e) {
      print('❌ Erreur récupération stats: $e');
      rethrow;
    }
  }

  // Rechercher un client par téléphone
  Future<Map<String, dynamic>> searchClient(String phone) async {
    try {
      final token = await AgentAuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      print('🔍 Recherche: $phone');
      print('🔑 Token: ${token.substring(0, 10)}...');
      print('🌐 URL: ${AppConfig.apiBaseUrl}/agent/search-client?phone=$phone');
      
      final response = await _dio.get(
        '/agent/search-client', 
        queryParameters: {'phone': phone}, 
        options: Options(headers: {'Authorization': 'Bearer $token'})
      );
      
      print('✅ Réponse: ${response.data}');
      
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null) {
          return {
            'user': data['user'] ?? {},
            'wallet': data['wallet'] ?? {},
          };
        }
      }
      throw Exception(response.data?['message'] ?? 'Client non trouvé');
    } on DioException catch (e) {
      print('❌ DioException: ${e.type}');
      print('❌ Status: ${e.response?.statusCode}');
      print('❌ Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ Erreur: $e');
      rethrow;
    }
  }

  // Vérifier le code secret
  Future<Map<String, dynamic>> verifySecretCode(String code) async {
    try {
      final token = await AgentAuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await _dio.post(
        '/agent/verify-secret-code',
        data: {'secret_code': code},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      return response.data;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        return {'success': false, 'message': 'Code incorrect'};
      }
      print('❌ Erreur vérification code secret: $e');
      return {'success': false, 'message': 'Erreur de vérification'};
    }
  }

  // Effectuer un dépôt
  Future<Map<String, dynamic>> processDeposit({required String clientQrCode, required double amount}) async {
    try {
      final token = await AgentAuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await _dio.post('/agent/deposit', data: {'client_phone': clientQrCode, 'amount': amount}, options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.data;
    } catch (e) {
      print('❌ Erreur dépôt: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> processWithdrawal({required String clientQrCode, required double amount}) async {
    try {
      final token = await AgentAuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await _dio.post('/agent/withdrawal', data: {'client_phone': clientQrCode, 'amount': amount}, options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.data;
    } catch (e) {
      print('❌ Erreur retrait: $e');
      rethrow;
    }
  }

  // Récupérer l'historique des opérations
  Future<Map<String, dynamic>> getTransactions() async {
    try {
      final token = await AgentAuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await _dio.get('/agent/history', options: Options(headers: {'Authorization': 'Bearer $token'}));
      
      if (response.data != null && response.data['success'] == true) {
        return response.data['data'] ?? {};
      }
      return {};
    } catch (e) {
      print('❌ Erreur récupération historique: $e');
      rethrow;
    }
  }

  // Mettre à jour le code secret
  Future<void> updateSecretCode(String secretCode) async {
    try {
      final token = await AgentAuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      await _dio.post(
        '/agent/update-secret-code',
        data: {'secret_code': secretCode},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      print('❌ Erreur mise à jour code secret: $e');
      rethrow;
    }
  }

  // Récupérer les frais configurés
  Future<Map<String, dynamic>> getFees() async {
    try {
      final response = await _dio.get('/fees/all');
      return response.data;
    } catch (e) {
      print('❌ Erreur récupération frais: $e');
      return {'success': false, 'data': {'user_withdrawal_fee': 0}};
    }
  }

  // Vérifier si un agent est rejeté par son numéro de téléphone (sans authentification)
  Future<Map<String, dynamic>> checkRejectionByPhone(String phone) async {
    try {
      final response = await _dio.post(
        '/agent/check-rejection',
        data: {'phone': phone},
      );
      
      return response.data;
    } catch (e) {
      print('❌ Erreur vérification rejet: $e');
      return {'success': false, 'is_rejected': false};
    }
  }

  // Récupérer le motif de rejet de l'agent
  Future<Map<String, dynamic>> getRejectionReason() async {
    try {
      final token = await AgentAuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await _dio.get(
        '/agent/rejection-reason',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      return response.data;
    } catch (e) {
      print('❌ Erreur récupération motif de rejet: $e');
      return {'success': false, 'has_rejection': false};
    }
  }
}
