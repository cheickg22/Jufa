import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'auth_service.dart';

class TransactionService {
  final Dio _dio = Dio();

  /// Récupérer l'historique des transactions
  Future<List<Map<String, dynamic>>> getTransactions({int page = 1}) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/transactions',
        queryParameters: {'page': page},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true) {
        final transactions = response.data['data']['transactions']['data'] as List;
        return transactions.map((t) => t as Map<String, dynamic>).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération des transactions');
      }
    } on DioException catch (e) {
      print('❌ Erreur API transactions: ${e.response?.data}');
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Récupérer une transaction par ID
  Future<Map<String, dynamic>> getTransaction(int id) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/transactions/$id',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true) {
        return response.data['data']['transaction'];
      } else {
        throw Exception(response.data['message'] ?? 'Transaction non trouvée');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Créer un dépôt
  Future<Map<String, dynamic>> createDeposit({
    required double amount,
    String? description,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/transactions/deposit',
        data: {
          'amount': amount,
          'description': description,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true) {
        return response.data['data']['transaction'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors du dépôt');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Créer un retrait
  Future<Map<String, dynamic>> createWithdrawal({
    required double amount,
    String? description,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/transactions/withdrawal',
        data: {
          'amount': amount,
          'description': description,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true) {
        return response.data['data']['transaction'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors du retrait');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Rechercher un utilisateur par identifiant
  Future<Map<String, dynamic>?> searchUser(String identifier) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/transactions/search-user',
        data: {'identifier': identifier},
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
        return null;
      }
    } on DioException catch (e) {
      print('❌ Utilisateur non trouvé: ${e.response?.data}');
      return null;
    }
  }

  /// Créer un transfert
  Future<Map<String, dynamic>> createTransfer({
    required String receiverIdentifier,
    required double amount,
    String? description,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/transactions/transfer',
        data: {
          'receiver_identifier': receiverIdentifier,
          'amount': amount,
          'description': description,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true) {
        return response.data['data']['transaction'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors du transfert');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }
}
