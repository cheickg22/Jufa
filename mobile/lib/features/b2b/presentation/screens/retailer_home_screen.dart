import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../data/models/product_model.dart';
import '../providers/cart_provider.dart';

final retailerProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final response = await apiClient.get(ApiConstants.merchantWholesalers);
    if (response['success'] != true) return [];
    
    final List<dynamic> wholesalers = response['data'] ?? [];
    List<ProductModel> allProducts = [];
    
    for (final w in wholesalers.take(5)) {
      final wholesalerId = w['id'] ?? w['wholesalerId'] ?? '';
      if (wholesalerId.isEmpty) continue;
      
      try {
        final productsResponse = await apiClient.get(ApiConstants.b2bCatalogProducts(wholesalerId));
        if (productsResponse['success'] == true) {
          final List<dynamic> data = productsResponse['data']?['content'] ?? productsResponse['data'] ?? [];
          allProducts.addAll(data.map((json) => ProductModel.fromJson({
            ...json,
            'wholesalerId': wholesalerId,
            'wholesalerName': w['businessName'] ?? 'Grossiste',
          })));
        }
      } catch (_) {}
    }
    return allProducts;
  } catch (e) {
    return [];
  }
});

final retailerCategoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return [
    {'id': 'all', 'name': 'Tout', 'icon': Icons.apps},
    {'id': 'food', 'name': 'Alimentaire', 'icon': Icons.fastfood},
    {'id': 'drinks', 'name': 'Boissons', 'icon': Icons.local_drink},
    {'id': 'cosmetics', 'name': 'Cosmétiques', 'icon': Icons.face},
    {'id': 'household', 'name': 'Ménage', 'icon': Icons.cleaning_services},
    {'id': 'electronics', 'name': 'Électronique', 'icon': Icons.devices},
  ];
});

class RetailerHomeScreen extends ConsumerStatefulWidget {
  const RetailerHomeScreen({super.key});

  @override
  ConsumerState<RetailerHomeScreen> createState() => _RetailerHomeScreenState();
}

class _RetailerHomeScreenState extends ConsumerState<RetailerHomeScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(retailerProductsProvider);
    final cartState = ref.watch(cartNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, cartState),
            _buildSearchBar(),
            _buildCategoryTabs(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(retailerProductsProvider);
                },
                child: productsAsync.when(
                  data: (products) => _buildProductGrid(products),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _buildErrorState(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CartState cartState) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Catalogue B2B', style: AppTextStyles.h2),
                const SizedBox(height: 2),
                Text(
                  'Commandez auprès de vos grossistes',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, size: 28),
                onPressed: () => context.push('/b2b/cart'),
              ),
              if (cartState.totalItems > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartState.totalItems}',
                      style: AppTextStyles.caption.copyWith(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 28),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Rechercher un produit...',
            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categoriesAsync = ref.watch(retailerCategoriesProvider);
    
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: categoriesAsync.when(
        data: (categories) => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            final isSelected = _selectedCategory == cat['id'];
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: FilterChip(
                selected: isSelected,
                label: Text(cat['name']),
                onSelected: (_) => setState(() => _selectedCategory = cat['id']),
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
            );
          },
        ),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildProductGrid(List<ProductModel> products) {
    var filtered = products;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (p.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }
    
    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final product = filtered[index];
        return _ProductCard(
          product: product,
          onTap: () => context.push('/b2b/product/${product.id}'),
          onAddToCart: () => _addToCart(product),
        );
      },
    );
  }

  void _addToCart(ProductModel product) {
    ref.read(cartNotifierProvider.notifier).addToCart(product.toEntity());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ajouté au panier'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Voir',
          textColor: Colors.white,
          onPressed: () => context.push('/b2b/cart'),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.md),
          Text('Aucun produit trouvé', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Essayez une autre recherche',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text('Erreur de chargement', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(retailerProductsProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        ),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${product.unitPrice.toStringAsFixed(0)} XOF',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 40,
        color: AppColors.primary.withValues(alpha: 0.5),
      ),
    );
  }
}
