import 'package:dio/dio.dart';
import 'auth_service.dart';
import '../config/app_config.dart';

class NegeService {
  final Dio _dio = Dio();

  /// Récupérer les comptes Nege (or et argent)
  Future<Map<String, dynamic>> getAccounts() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/nege/accounts',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de la récupération des comptes');
    }
  }

  /// Acheter de l'or ou de l'argent
  Future<Map<String, dynamic>> buy({
    required String metalType,
    required double amountFcfa,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/nege/buy',
        data: {
          'metal_type': metalType,
          'amount_fcfa': amountFcfa,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de l\'achat');
    }
  }

  /// Vendre de l'or ou de l'argent
  Future<Map<String, dynamic>> sell({
    required String metalType,
    required double grams,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/nege/sell',
        data: {
          'metal_type': metalType,
          'grams': grams,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de la vente');
    }
  }

  /// Récupérer l'historique des transactions
  Future<List<dynamic>> getTransactions({String? metalType}) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      final queryParams = metalType != null ? {'metal_type': metalType} : null;
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/nege/transactions',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data['data'] as List<dynamic>;
    } on DioException catch (e) {
      print('❌ Erreur getTransactions: $e');
      throw Exception('Erreur lors de la récupération des transactions');
    }
  }

  // ==================== MARKETPLACE ====================

  /// Obtenir toutes les offres du marketplace
  Future<List<dynamic>> getOffers({String? metalType}) async {
    try {
      final token = await AuthService.getToken();
      
      final queryParams = metalType != null ? '?metal_type=$metalType' : '';
      
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/nege/offers$queryParams',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true) {
        return response.data['data'] as List<dynamic>;
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération des offres');
      }
    } catch (e) {
      print('❌ Erreur getOffers: $e');
      throw Exception('Erreur lors de la récupération des offres');
    }
  }

  /// Créer une offre de vente
  Future<Map<String, dynamic>> createOffer({
    required String metalType,
    required double grams,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/nege/offers',
        data: {
          'metal_type': metalType,
          'grams': grams,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la création de l\'offre');
      }
    } catch (e) {
      print('❌ Erreur createOffer: $e');
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur lors de la création de l\'offre');
      }
      throw Exception('Erreur lors de la création de l\'offre');
    }
  }

  /// Acheter une offre
  Future<Map<String, dynamic>> buyOffer({
    required int offerId,
    double? grams,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/nege/offers/$offerId/buy',
        data: grams != null ? {'grams': grams} : {},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de l\'achat');
      }
    } catch (e) {
      print('❌ Erreur buyOffer: $e');
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur lors de l\'achat');
      }
      throw Exception('Erreur lors de l\'achat');
    }
  }

  /// Annuler une offre
  Future<Map<String, dynamic>> cancelOffer(int offerId) async {
    try {
      final token = await AuthService.getToken();
      
      final response = await _dio.delete(
        '${AppConfig.apiBaseUrl}/nege/offers/$offerId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de l\'annulation');
      }
    } catch (e) {
      print('❌ Erreur cancelOffer: $e');
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur lors de l\'annulation');
      }
      throw Exception('Erreur lors de l\'annulation');
    }
  }

  /// Obtenir mes offres
  Future<List<dynamic>> getMyOffers() async {
    try {
      final token = await AuthService.getToken();
      
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/nege/my-offers',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true) {
        return response.data['data'] as List<dynamic>;
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération de vos offres');
      }
    } catch (e) {
      print('❌ Erreur getMyOffers: $e');
      throw Exception('Erreur lors de la récupération de vos offres');
    }
  }
}
