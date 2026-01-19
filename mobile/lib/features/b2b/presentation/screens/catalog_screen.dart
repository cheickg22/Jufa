import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/product.dart';
import '../providers/catalog_provider.dart';
import '../providers/cart_provider.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  final String wholesalerId;
  final String wholesalerName;

  const CatalogScreen({
    super.key,
    required this.wholesalerId,
    required this.wholesalerName,
  });

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'XOF', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(catalogNotifierProvider.notifier).loadCatalog(widget.wholesalerId);
      ref.read(cartNotifierProvider.notifier).setWholesaler(widget.wholesalerId, widget.wholesalerName);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(catalogNotifierProvider.notifier).loadMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(catalogNotifierProvider);
    final cartState = ref.watch(cartNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.wholesalerName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => context.push('/b2b/cart'),
              ),
              if (cartState.totalItems > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '${cartState.totalItems}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(catalogNotifierProvider.notifier).loadCatalog(widget.wholesalerId);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildCategoryChips(catalogState)),
            if (catalogState.featuredProducts.isNotEmpty && catalogState.searchQuery.isEmpty && catalogState.selectedCategoryId == null)
              SliverToBoxAdapter(child: _buildFeaturedSection(catalogState)),
            if (catalogState.isLoading && catalogState.products.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (catalogState.products.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('Aucun produit trouvé')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= catalogState.products.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return _buildProductCard(catalogState.products[index], cartState);
                    },
                    childCount: catalogState.products.length + (catalogState.hasMore ? 1 : 0),
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un produit...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(catalogNotifierProvider.notifier).searchProducts('');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          filled: true,
          fillColor: AppColors.surface,
        ),
        onSubmitted: (value) {
          ref.read(catalogNotifierProvider.notifier).searchProducts(value);
        },
        onChanged: (value) {
          setState(() {});
          if (value.isEmpty) {
            ref.read(catalogNotifierProvider.notifier).searchProducts('');
          }
        },
      ),
    );
  }

  Widget _buildCategoryChips(CatalogState state) {
    if (state.categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: state.categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = state.selectedCategoryId == null;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: FilterChip(
                label: const Text('Tous'),
                selected: isSelected,
                onSelected: (_) {
                  ref.read(catalogNotifierProvider.notifier).selectCategory(null);
                },
                selectedColor: AppColors.primaryLight,
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            );
          }

          final category = state.categories[index - 1];
          final isSelected = state.selectedCategoryId == category.id;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(category.name),
              selected: isSelected,
              onSelected: (_) {
                ref.read(catalogNotifierProvider.notifier).selectCategory(category.id);
              },
              selectedColor: AppColors.primaryLight,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedSection(CatalogState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            'Produits en vedette',
            style: AppTextStyles.h3,
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: state.featuredProducts.length,
            itemBuilder: (context, index) {
              final product = state.featuredProducts[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: AppSpacing.md),
                child: _buildProductCard(product, ref.watch(cartNotifierProvider)),
              );
            },
          ),
        ),
        const Divider(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildProductCard(Product product, CartState cartState) {
    final quantity = cartState.getQuantity(product.id);

    return GestureDetector(
      onTap: () => context.push('/b2b/product/${product.id}'),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
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
                            currencyFormat.format(product.effectivePrice),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!product.inStock)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Rupture',
                              style: AppTextStyles.caption.copyWith(color: AppColors.error),
                            ),
                          )
                        else if (quantity > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              '$quantity',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () {
                              ref.read(cartNotifierProvider.notifier).addToCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.name} ajouté au panier'),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 16),
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
        size: 48,
        color: AppColors.textHint,
      ),
    );
  }
}
