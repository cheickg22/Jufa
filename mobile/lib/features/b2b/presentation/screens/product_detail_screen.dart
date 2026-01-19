import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/product.dart';
import '../providers/catalog_provider.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'XOF', decimalDigits: 0);
  int _quantity = 1;
  Product? _product;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await ref.read(catalogRepositoryProvider).getProduct(widget.productId);

    result.fold(
      (failure) => setState(() {
        _error = failure.message;
        _isLoading = false;
      }),
      (product) => setState(() {
        _product = product;
        _quantity = product.minOrderQuantity;
        _isLoading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _product == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text(_error ?? 'Produit non trouvé'),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    final product = _product!;
    final cartQuantity = cartState.getQuantity(product.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Détail produit'),
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
                    child: Text(
                      '${cartState.totalItems}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              color: AppColors.divider,
              child: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.categoryName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.categoryName!,
                        style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(product.name, style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.sm),
                  if (product.sku != null)
                    Text(
                      'SKU: ${product.sku}',
                      style: AppTextStyles.caption,
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Text(
                        currencyFormat.format(product.effectivePrice),
                        style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '/ ${product.unitName}',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  if (product.wholesalePrice != null && product.wholesalePrice != product.effectivePrice)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        'Prix de base: ${currencyFormat.format(product.wholesalePrice)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildInfoRow(Icons.inventory_2, 'Stock disponible', '${product.stockQuantity} ${product.unitName}'),
                  _buildInfoRow(Icons.shopping_basket, 'Quantité minimum', '${product.minOrderQuantity} ${product.unitName}'),
                  if (product.lowStock)
                    Container(
                      margin: const EdgeInsets.only(top: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: AppColors.warning),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Stock faible',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.warning),
                          ),
                        ],
                      ),
                    ),
                  if (product.description != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Text('Description', style: AppTextStyles.h3),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      product.description!,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  if (cartQuantity > 0)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              '$cartQuantity ${product.unitName} dans le panier',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/b2b/cart'),
                            child: const Text('Voir'),
                          ),
                        ],
                      ),
                    )
                  else if (product.inStock) ...[
                    Text('Quantité', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppSpacing.sm),
                    _buildQuantitySelector(product),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(cartNotifierProvider.notifier).addToCart(product, quantity: _quantity);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$_quantity ${product.unitName} ajouté(s) au panier'),
                              backgroundColor: AppColors.success,
                              action: SnackBarAction(
                                label: 'Voir',
                                textColor: Colors.white,
                                onPressed: () => context.push('/b2b/cart'),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: Text(
                          'Ajouter au panier - ${currencyFormat.format(product.effectivePrice * _quantity)}',
                          style: AppTextStyles.button,
                        ),
                      ),
                    ),
                  ] else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: AppColors.error),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Produit en rupture de stock',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.textHint),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(Product product) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _quantity > product.minOrderQuantity
                ? () => setState(() => _quantity--)
                : null,
            icon: const Icon(Icons.remove),
            color: AppColors.primary,
          ),
          Expanded(
            child: Text(
              '$_quantity',
              textAlign: TextAlign.center,
              style: AppTextStyles.h3,
            ),
          ),
          IconButton(
            onPressed: _quantity < product.stockQuantity
                ? () => setState(() => _quantity++)
                : null,
            icon: const Icon(Icons.add),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
