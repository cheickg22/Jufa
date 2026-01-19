import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../merchant/presentation/providers/merchant_provider.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart' as b2b;

final productManagementProvider = StateNotifierProvider<ProductManagementNotifier, ProductManagementState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductManagementNotifier(apiClient, ref);
});

class ProductManagementState {
  final bool isLoading;
  final List<Product> products;
  final List<Product> lowStockProducts;
  final List<b2b.Category> categories;
  final String? error;
  final String? successMessage;

  const ProductManagementState({
    this.isLoading = false,
    this.products = const [],
    this.lowStockProducts = const [],
    this.categories = const [],
    this.error,
    this.successMessage,
  });

  ProductManagementState copyWith({
    bool? isLoading,
    List<Product>? products,
    List<Product>? lowStockProducts,
    List<b2b.Category>? categories,
    String? error,
    String? successMessage,
  }) {
    return ProductManagementState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      lowStockProducts: lowStockProducts ?? this.lowStockProducts,
      categories: categories ?? this.categories,
      error: error,
      successMessage: successMessage,
    );
  }
}

class ProductManagementNotifier extends StateNotifier<ProductManagementState> {
  final ApiClient _apiClient;
  final Ref _ref;

  ProductManagementNotifier(this._apiClient, this._ref) : super(const ProductManagementState());

  String? get _merchantId => _ref.read(merchantProfileProvider).valueOrNull?.id;

  Future<void> loadMyProducts() async {
    final merchantId = _merchantId;
    if (merchantId == null) {
      state = state.copyWith(isLoading: false, error: 'Profil marchand non disponible');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.get(ApiConstants.b2bCatalogProducts(merchantId));
      if (response['success'] == true) {
        final List<dynamic> data = response['data']['content'] ?? response['data'] ?? [];
        final products = data.map((json) => ProductModel.fromJson(json).toEntity()).toList();
        state = state.copyWith(isLoading: false, products: products);
      } else {
        state = state.copyWith(isLoading: false, error: response['error']?['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadLowStockProducts() async {
    try {
      final response = await _apiClient.get(ApiConstants.b2bLowStockProducts);
      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        final products = data.map((json) => ProductModel.fromJson(json).toEntity()).toList();
        state = state.copyWith(lowStockProducts: products);
      }
    } catch (e) {
      // Silent fail for low stock
    }
  }

  Future<void> loadCategories() async {
    final merchantId = _merchantId;
    if (merchantId == null) return;
    try {
      final response = await _apiClient.get(ApiConstants.b2bCatalogCategories(merchantId));
      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        final categories = data.map((json) => CategoryModel.fromJson(json).toEntity()).toList();
        state = state.copyWith(categories: categories);
      }
    } catch (e) {
    }
  }

  String _generateSku(String productName) {
    final prefix = productName
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '')
        .substring(0, productName.length > 3 ? 3 : productName.length);
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    return 'SKU-$prefix-$timestamp';
  }

  Future<bool> createProduct({
    required String name,
    String? description,
    String? categoryId,
    required String unit,
    required double unitPrice,
    double? wholesalePrice,
    int? minOrderQuantity,
    int? stockQuantity,
    bool featured = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sku = _generateSku(name);
      final data = {
        'sku': sku,
        'name': name,
        if (description != null && description.isNotEmpty) 'description': description,
        if (categoryId != null) 'categoryId': categoryId,
        'unit': unit,
        'unitPrice': unitPrice,
        if (wholesalePrice != null) 'wholesalePrice': wholesalePrice,
        'minOrderQuantity': minOrderQuantity ?? 1,
        'stockQuantity': stockQuantity ?? 0,
        'featured': featured,
      };
      
      debugPrint('[ProductManagement] Creating product: $data');
      debugPrint('[ProductManagement] Endpoint: ${ApiConstants.b2bCreateProduct}');
      
      final response = await _apiClient.post(
        ApiConstants.b2bCreateProduct,
        data: data,
      );

      debugPrint('[ProductManagement] Response: $response');

      if (response['success'] == true) {
        state = state.copyWith(isLoading: false, successMessage: 'Produit créé avec succès');
        await loadMyProducts();
        return true;
      } else {
        final errorMsg = response['error']?['message'] ?? 'Erreur lors de la création';
        state = state.copyWith(isLoading: false, error: errorMsg);
        return false;
      }
    } on ServerException catch (e) {
      debugPrint('[ProductManagement] ServerException: ${e.message}');
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } on NetworkException catch (e) {
      debugPrint('[ProductManagement] NetworkException: ${e.message}');
      state = state.copyWith(isLoading: false, error: 'Erreur de connexion au serveur');
      return false;
    } catch (e) {
      debugPrint('[ProductManagement] Exception: $e');
      state = state.copyWith(isLoading: false, error: 'Erreur: $e');
      return false;
    }
  }

  Future<bool> updateProduct({
    required String productId,
    required String name,
    String? description,
    String? categoryId,
    required String unit,
    required double unitPrice,
    double? wholesalePrice,
    int? minOrderQuantity,
    int? stockQuantity,
    bool? active,
    bool? featured,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = {
        'name': name,
        if (description != null && description.isNotEmpty) 'description': description,
        if (categoryId != null) 'categoryId': categoryId,
        'unit': unit,
        'unitPrice': unitPrice,
        if (wholesalePrice != null) 'wholesalePrice': wholesalePrice,
        'minOrderQuantity': minOrderQuantity ?? 1,
        'stockQuantity': stockQuantity ?? 0,
        'active': active ?? true,
        'featured': featured ?? false,
      };
      
      debugPrint('[ProductManagement] Updating product $productId: $data');
      
      final response = await _apiClient.put(
        ApiConstants.b2bUpdateProduct(productId),
        data: data,
      );

      if (response['success'] == true) {
        state = state.copyWith(isLoading: false, successMessage: 'Produit modifié avec succès');
        await loadMyProducts();
        return true;
      } else {
        final errorMsg = response['error']?['message'] ?? 'Erreur lors de la modification';
        state = state.copyWith(isLoading: false, error: errorMsg);
        return false;
      }
    } on ServerException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } on NetworkException {
      state = state.copyWith(isLoading: false, error: 'Erreur de connexion au serveur');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erreur: $e');
      return false;
    }
  }

  Future<bool> updateStock(String productId, int quantity) async {
    try {
      debugPrint('[ProductManagement] Updating stock for $productId: $quantity');
      
      final response = await _apiClient.patch(
        '${ApiConstants.b2bUpdateStock(productId)}?quantity=$quantity',
      );

      if (response['success'] == true) {
        state = state.copyWith(successMessage: 'Stock mis à jour');
        await loadMyProducts();
        await loadLowStockProducts();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> createCategory(String name, String? description) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.post(
        ApiConstants.b2bCreateCategory,
        data: {'name': name, 'description': description},
      );

      if (response['success'] == true) {
        state = state.copyWith(isLoading: false, successMessage: 'Catégorie créée');
        await loadCategories();
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response['error']?['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}
