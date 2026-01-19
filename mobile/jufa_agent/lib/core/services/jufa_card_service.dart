import 'package:dio/dio.dart';
import 'auth_service.dart';
import '../config/app_config.dart';

class JufaCardService {
  final Dio _dio = Dio();

  /// Récupérer toutes les cartes de l'utilisateur
  Future<List<dynamic>> getCards() async {
    try {
      final token = await AuthService.getToken();
      
      print('🔑 Token: ${token?.substring(0, 20)}...');
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      print('📡 Appel API: ${AppConfig.apiBaseUrl}/cards');

      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/cards',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('📥 Réponse: ${response.data}');

      if (response.data['success'] == true) {
        return response.data['data']['cards'] ?? [];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération des cartes');
      }
    } on DioException catch (e) {
      print('❌ Erreur Dio: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    } catch (e) {
      print('❌ Erreur: $e');
      rethrow;
    }
  }

  /// Récupérer les détails d'une carte
  Future<Map<String, dynamic>> getCardDetails(int cardId) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      print('📡 Appel API: ${AppConfig.apiBaseUrl}/cards/$cardId');

      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/cards/$cardId',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('📥 Réponse: ${response.data}');

      if (response.data['success'] == true) {
        return response.data['data']['card'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération des détails');
      }
    } on DioException catch (e) {
      print('❌ Erreur Dio: ${e.message}');
      
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Commander une nouvelle carte
  Future<Map<String, dynamic>> orderCard({
    required String cardType,
    String? deliveryAddress,
    String? deliveryCity,
    String? deliveryPhone,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      print('🔑 Token: ${token?.substring(0, 20)}...');
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      final data = {
        'card_type': cardType,
        if (deliveryAddress != null) 'delivery_address': deliveryAddress,
        if (deliveryCity != null) 'delivery_city': deliveryCity,
        if (deliveryPhone != null) 'delivery_phone': deliveryPhone,
      };

      print('📤 Envoi commande carte: $data');
      print('🌐 URL: ${AppConfig.apiBaseUrl}/cards/order');

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/cards/order',
        data: data,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('📥 Réponse API: ${response.data}');

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la commande');
      }
    } on DioException catch (e) {
      print('❌ Erreur Dio: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      print('❌ Status: ${e.response?.statusCode}');
      
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    } catch (e) {
      print('❌ Erreur générale: $e');
      rethrow;
    }
  }

  /// Bloquer une carte
  Future<void> blockCard({required int cardId, String? reason}) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      print('📡 Blocage carte: ${AppConfig.apiBaseUrl}/cards/$cardId/block');

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/cards/$cardId/block',
        data: {
          if (reason != null) 'reason': reason,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('📥 Réponse: ${response.data}');

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erreur lors du blocage');
      }
    } on DioException catch (e) {
      print('❌ Erreur: ${e.message}');
      
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Débloquer une carte
  Future<void> unblockCard(int cardId) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      print('📡 Déblocage carte: ${AppConfig.apiBaseUrl}/cards/$cardId/unblock');

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/cards/$cardId/unblock',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('📥 Réponse: ${response.data}');

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erreur lors du déblocage');
      }
    } on DioException catch (e) {
      print('❌ Erreur: ${e.message}');
      
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Définir le PIN de la carte
  Future<void> setCardPin({
    required int cardId,
    required String pin,
    required String confirmPin,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      print('📡 Définition PIN: ${AppConfig.apiBaseUrl}/cards/$cardId/set-pin');

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/cards/$cardId/set-pin',
        data: {
          'pin': pin,
          'confirm_pin': confirmPin,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('📥 Réponse: ${response.data}');

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erreur lors de la configuration du PIN');
      }
    } on DioException catch (e) {
      print('❌ Erreur: ${e.message}');
      
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Recharger une carte
  Future<Map<String, dynamic>> rechargeCard({
    required int cardId,
    required double amount,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      print('📡 Recharge carte: ${AppConfig.apiBaseUrl}/cards/$cardId/recharge');
      print('💰 Montant: $amount FCFA');

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/cards/$cardId/recharge',
        data: {
          'amount': amount,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('📥 Réponse: ${response.data}');

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la recharge');
      }
    } on DioException catch (e) {
      print('❌ Erreur: ${e.message}');
      
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Récupérer les transactions d'une carte
  Future<List<dynamic>> getCardTransactions(int cardId) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      print('📡 Transactions carte: ${AppConfig.apiBaseUrl}/cards/$cardId/transactions');

      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/cards/$cardId/transactions',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('📥 Réponse: ${response.data}');

      if (response.data['success'] == true) {
        return response.data['data']['transactions'] ?? [];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération des transactions');
      }
    } on DioException catch (e) {
      print('❌ Erreur: ${e.message}');
      
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Récupérer les commandes de cartes
  Future<List<dynamic>> getCardOrders() async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      print('📡 Commandes: ${AppConfig.apiBaseUrl}/card-orders');

      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/card-orders',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('📥 Réponse: ${response.data}');

      if (response.data['success'] == true) {
        return response.data['data']['orders'] ?? [];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération des commandes');
      }
    } on DioException catch (e) {
      print('❌ Erreur: ${e.message}');
      
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }
}
