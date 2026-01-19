import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'auth_service.dart';

class WalletService {
  final Dio _dio = Dio();

  /// Récupérer les informations du wallet de l'utilisateur connecté
  Future<Map<String, dynamic>> getWallet() async {
    try {
      final token = await AuthService.getToken();
      
      print('🔑 Token récupéré: ${token?.substring(0, 20) ?? "null"}...');
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/wallet',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true) {
        return response.data['data']['wallet'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération du wallet');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Récupérer le solde du wallet
  Future<double> getBalance() async {
    try {
      final wallet = await getWallet();
      final balance = wallet['balance'];
      
      if (balance is String) {
        return double.parse(balance);
      } else if (balance is num) {
        return balance.toDouble();
      }
      
      return 0.0;
    } catch (e) {
      print('❌ Erreur lors de la récupération du solde: $e');
      return 0.0;
    }
  }

  /// Récupérer les transactions du wallet
  Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/wallet/transactions',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']['transactions']);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération des transactions');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }
}
