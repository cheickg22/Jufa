import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/order.dart';
import 'auth_service.dart';

class MarketplaceService {
  final Dio _dio = Dio();

  /// Récupérer les catégories marketplace
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/marketplace/categories',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true) {
        final categories = response.data['data'] as List;
        return categories.map((c) => c as Map<String, dynamic>).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération des catégories');
      }
    } on DioException catch (e) {
      print('❌ Erreur API catégories: ${e.response?.data}');
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Récupérer les produits en vedette
  Future<List<Map<String, dynamic>>> getFeaturedProducts() async {
    try {
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/marketplace/featured-products',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true) {
        final products = response.data['data'] as List;
        return products.map((p) => p as Map<String, dynamic>).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération des produits');
      }
    } on DioException catch (e) {
      print('❌ Erreur API produits: ${e.response?.data}');
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Récupérer les produits d'une catégorie spécifique
  Future<List<Map<String, dynamic>>> getCategoryProducts(int categoryId) async {
    try {
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/marketplace/categories/$categoryId/products',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true) {
        final products = response.data['data'] as List;
        return products.map((p) => p as Map<String, dynamic>).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération des produits');
      }
    } on DioException catch (e) {
      print('❌ Erreur API produits catégorie: ${e.response?.data}');
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Créer une nouvelle commande
  Future<Map<String, dynamic>> createOrder(Order order) async {
    try {
      final token = await AuthService.getToken();
      
      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/marketplace/orders',
        data: order.toJson(),
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
        throw Exception(response.data['message'] ?? 'Erreur lors de la création de la commande');
      }
    } on DioException catch (e) {
      print('❌ Erreur API création commande: ${e.response?.data}');
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Récupérer les commandes de l'utilisateur
  Future<List<Order>> getMyOrders() async {
    try {
      final token = await AuthService.getToken();
      
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/marketplace/orders',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true) {
        final orders = response.data['data'] as List;
        return orders.map((o) => Order.fromJson(o)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération des commandes');
      }
    } on DioException catch (e) {
      print('❌ Erreur API commandes: ${e.response?.data}');
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Récupérer les détails d'une commande
  Future<Order> getOrderDetails(int orderId) async {
    try {
      final token = await AuthService.getToken();
      
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/marketplace/orders/$orderId',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true) {
        return Order.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération de la commande');
      }
    } on DioException catch (e) {
      print('❌ Erreur API détails commande: ${e.response?.data}');
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Annuler une commande
  Future<void> cancelOrder(int orderId) async {
    try {
      final token = await AuthService.getToken();
      
      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/marketplace/orders/$orderId/cancel',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erreur lors de l\'annulation de la commande');
      }
    } on DioException catch (e) {
      print('❌ Erreur API annulation commande: ${e.response?.data}');
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }

  /// Récupérer les détails d'un produit
  Future<Map<String, dynamic>> getProductDetails(int productId) async {
    try {
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/marketplace/products/$productId',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération du produit');
      }
    } on DioException catch (e) {
      print('❌ Erreur API détails produit: ${e.response?.data}');
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }
}
