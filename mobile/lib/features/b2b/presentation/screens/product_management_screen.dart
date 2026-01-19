import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../merchant/presentation/providers/merchant_provider.dart';
import '../providers/product_management_provider.dart';
import '../../domain/entities/product.dart';

class ProductManagementScreen extends ConsumerStatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  ConsumerState<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends ConsumerState<ProductManagementScreen> {
  String _searchQuery = '';
  String? _selectedCategoryId;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final merchantProfile = ref.watch(merchantProfileProvider);
    final state = ref.watch(productManagementProvider);

    if (merchantProfile.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Mes Produits'),
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (merchantProfile.hasError) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Mes Produits'),
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text('Erreur: ${merchantProfile.error}', style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => ref.invalidate(merchantProfileProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_initialized && merchantProfile.hasValue) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(productManagementProvider.notifier).loadMyProducts();
        ref.read(productManagementProvider.notifier).loadCategories();
      });
    }

    final filteredProducts = state.products.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategoryId == null || p.categoryId == _selectedCategoryId;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes Produits'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/b2b/product/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(state),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => ref.read(productManagementProvider.notifier).loadMyProducts(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) => _ProductCard(
                            product: filteredProducts[index],
                            onTap: () => context.push('/b2b/product/edit/${filteredProducts[index].id}'),
                            onStockUpdate: () => _showUpdateStockDialog(filteredProducts[index]),
                          ),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/b2b/product/new'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouveau produit', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildSearchAndFilter(ProductManagementState state) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.surface,
      child: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Rechercher un produit...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.background,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'Tous',
                  isSelected: _selectedCategoryId == null,
                  onTap: () => setState(() => _selectedCategoryId = null),
                ),
                ...state.categories.map((category) => _FilterChip(
                      label: category.name,
                      isSelected: _selectedCategoryId == category.id,
                      onTap: () => setState(() => _selectedCategoryId = category.id),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.lg),
          Text('Aucun produit', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Commencez par ajouter votre premier produit',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: () => context.push('/b2b/product/new'),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un produit'),
          ),
        ],
      ),
    );
  }

  void _showUpdateStockDialog(Product product) {
    final controller = TextEditingController(text: product.stockQuantity.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mettre à jour le stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantité en stock',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantity = int.tryParse(controller.text);
              if (quantity != null) {
                Navigator.pop(context);
                await ref.read(productManagementProvider.notifier).updateStock(product.id, quantity);
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onStockUpdate;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onStockUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: product.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Image.network(product.imageUrl!, fit: BoxFit.cover),
                    )
                  : const Icon(Icons.inventory_2, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (product.featured)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: const Icon(Icons.star, size: 12, color: AppColors.warning),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.categoryName ?? 'Sans catégorie',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${product.unitPrice.toStringAsFixed(0)} XOF',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _StockBadge(
                        stockQuantity: product.stockQuantity,
                        lowStock: product.lowStock,
                        onTap: onStockUpdate,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final int stockQuantity;
  final bool lowStock;
  final VoidCallback onTap;

  const _StockBadge({
    required this.stockQuantity,
    required this.lowStock,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = lowStock ? AppColors.warning : AppColors.success;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.xs),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              lowStock ? Icons.warning_amber : Icons.check_circle,
              size: 12,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              'Stock: $stockQuantity',
              style: AppTextStyles.caption.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
