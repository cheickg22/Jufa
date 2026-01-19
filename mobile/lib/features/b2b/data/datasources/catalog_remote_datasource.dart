import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class CatalogRemoteDatasource {
  final ApiClient _apiClient;

  CatalogRemoteDatasource(this._apiClient);

  Future<List<CategoryModel>> getCategories(String wholesalerId) async {
    final response = await _apiClient.get(
      ApiConstants.b2bCatalogCategories(wholesalerId),
    );
    final List<dynamic> data = response['data'] ?? [];
    return data.map((json) => CategoryModel.fromJson(json)).toList();
  }

  Future<List<ProductModel>> getProducts(
    String wholesalerId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.b2bCatalogProducts(wholesalerId),
      queryParams: {'page': page, 'size': size},
    );
    final content = response['data']?['content'] ?? response['data'] ?? [];
    return (content as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<List<ProductModel>> getProductsByCategory(
    String wholesalerId,
    String categoryId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.b2bCatalogProductsByCategory(wholesalerId, categoryId),
      queryParams: {'page': page, 'size': size},
    );
    final content = response['data']?['content'] ?? response['data'] ?? [];
    return (content as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<List<ProductModel>> getFeaturedProducts(String wholesalerId) async {
    final response = await _apiClient.get(
      ApiConstants.b2bCatalogFeatured(wholesalerId),
    );
    final List<dynamic> data = response['data'] ?? [];
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<List<ProductModel>> searchProducts(
    String wholesalerId,
    String query, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.b2bCatalogSearch(wholesalerId),
      queryParams: {'q': query, 'page': page, 'size': size},
    );
    final content = response['data']?['content'] ?? response['data'] ?? [];
    return (content as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<ProductModel> getProduct(String productId) async {
    final response = await _apiClient.get(
      ApiConstants.b2bProduct(productId),
    );
    return ProductModel.fromJson(response['data']);
  }
}
