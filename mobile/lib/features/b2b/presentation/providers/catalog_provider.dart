import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/catalog_remote_datasource.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final datasource = CatalogRemoteDatasource(apiClient);
  return CatalogRepository(datasource);
});

class CatalogState {
  final bool isLoading;
  final String? error;
  final String? currentWholesalerId;
  final List<Category> categories;
  final String? selectedCategoryId;
  final List<Product> products;
  final List<Product> featuredProducts;
  final String searchQuery;
  final bool hasMore;
  final int currentPage;

  CatalogState({
    this.isLoading = false,
    this.error,
    this.currentWholesalerId,
    this.categories = const [],
    this.selectedCategoryId,
    this.products = const [],
    this.featuredProducts = const [],
    this.searchQuery = '',
    this.hasMore = true,
    this.currentPage = 0,
  });

  CatalogState copyWith({
    bool? isLoading,
    String? error,
    String? currentWholesalerId,
    List<Category>? categories,
    String? selectedCategoryId,
    List<Product>? products,
    List<Product>? featuredProducts,
    String? searchQuery,
    bool? hasMore,
    int? currentPage,
    bool clearError = false,
    bool clearCategory = false,
  }) {
    return CatalogState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentWholesalerId: currentWholesalerId ?? this.currentWholesalerId,
      categories: categories ?? this.categories,
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      products: products ?? this.products,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      searchQuery: searchQuery ?? this.searchQuery,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class CatalogNotifier extends StateNotifier<CatalogState> {
  final CatalogRepository _repository;

  CatalogNotifier(this._repository) : super(CatalogState());

  Future<void> loadCatalog(String wholesalerId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      currentWholesalerId: wholesalerId,
      products: [],
      currentPage: 0,
      hasMore: true,
    );

    final categoriesResult = await _repository.getCategories(wholesalerId);
    final featuredResult = await _repository.getFeaturedProducts(wholesalerId);
    final productsResult = await _repository.getProducts(wholesalerId, page: 0);

    categoriesResult.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (categories) => state = state.copyWith(categories: categories),
    );

    featuredResult.fold(
      (failure) {},
      (featured) => state = state.copyWith(featuredProducts: featured),
    );

    productsResult.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (products) => state = state.copyWith(
        isLoading: false,
        products: products,
        hasMore: products.length >= 20,
      ),
    );
  }

  Future<void> selectCategory(String? categoryId) async {
    if (state.currentWholesalerId == null) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      selectedCategoryId: categoryId,
      clearCategory: categoryId == null,
      products: [],
      currentPage: 0,
      hasMore: true,
      searchQuery: '',
    );

    final result = categoryId != null
        ? await _repository.getProductsByCategory(
            state.currentWholesalerId!,
            categoryId,
            page: 0,
          )
        : await _repository.getProducts(state.currentWholesalerId!, page: 0);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (products) => state = state.copyWith(
        isLoading: false,
        products: products,
        hasMore: products.length >= 20,
      ),
    );
  }

  Future<void> searchProducts(String query) async {
    if (state.currentWholesalerId == null) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      searchQuery: query,
      products: [],
      currentPage: 0,
      hasMore: true,
      clearCategory: true,
    );

    if (query.isEmpty) {
      final result = await _repository.getProducts(state.currentWholesalerId!, page: 0);
      result.fold(
        (failure) => state = state.copyWith(isLoading: false, error: failure.message),
        (products) => state = state.copyWith(
          isLoading: false,
          products: products,
          hasMore: products.length >= 20,
        ),
      );
      return;
    }

    final result = await _repository.searchProducts(
      state.currentWholesalerId!,
      query,
      page: 0,
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (products) => state = state.copyWith(
        isLoading: false,
        products: products,
        hasMore: products.length >= 20,
      ),
    );
  }

  Future<void> loadMoreProducts() async {
    if (state.isLoading || !state.hasMore || state.currentWholesalerId == null) return;

    state = state.copyWith(isLoading: true);
    final nextPage = state.currentPage + 1;

    final result = state.searchQuery.isNotEmpty
        ? await _repository.searchProducts(
            state.currentWholesalerId!,
            state.searchQuery,
            page: nextPage,
          )
        : state.selectedCategoryId != null
            ? await _repository.getProductsByCategory(
                state.currentWholesalerId!,
                state.selectedCategoryId!,
                page: nextPage,
              )
            : await _repository.getProducts(state.currentWholesalerId!, page: nextPage);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (newProducts) => state = state.copyWith(
        isLoading: false,
        products: [...state.products, ...newProducts],
        currentPage: nextPage,
        hasMore: newProducts.length >= 20,
      ),
    );
  }

  void reset() {
    state = CatalogState();
  }
}

final catalogNotifierProvider = StateNotifierProvider<CatalogNotifier, CatalogState>((ref) {
  final repository = ref.watch(catalogRepositoryProvider);
  return CatalogNotifier(repository);
});
