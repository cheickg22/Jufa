import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../providers/product_management_provider.dart';

class WholesalerDashboardScreen extends ConsumerStatefulWidget {
  const WholesalerDashboardScreen({super.key});

  @override
  ConsumerState<WholesalerDashboardScreen> createState() => _WholesalerDashboardScreenState();
}

class _WholesalerDashboardScreenState extends ConsumerState<WholesalerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final notifier = ref.read(productManagementProvider.notifier);
    await Future.wait([
      notifier.loadMyProducts(),
      notifier.loadLowStockProducts(),
      notifier.loadCategories(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productManagementProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Espace Grossiste'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsCards(productState),
              const SizedBox(height: AppSpacing.xl),
              _buildQuickActions(context),
              const SizedBox(height: AppSpacing.xl),
              _buildLowStockAlert(productState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(ProductManagementState productState) {
    final lowStockCount = productState.lowStockProducts.length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          icon: Icons.inventory_2_outlined,
          label: 'Produits',
          value: '${productState.products.length}',
          color: AppColors.primary,
        ),
        _StatCard(
          icon: Icons.category_outlined,
          label: 'Catégories',
          value: '${productState.categories.length}',
          color: AppColors.secondary,
        ),
        _StatCard(
          icon: Icons.warning_amber_outlined,
          label: 'Stock bas',
          value: '$lowStockCount',
          color: lowStockCount > 0 ? AppColors.error : AppColors.success,
        ),
        _StatCard(
          icon: Icons.shopping_cart_outlined,
          label: 'Commandes',
          value: '-',
          color: AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actions rapides', style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.add_box_outlined,
                label: 'Nouveau produit',
                color: AppColors.primary,
                onTap: () => context.push('/b2b/product/new'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ActionCard(
                icon: Icons.inventory_outlined,
                label: 'Gérer stock',
                color: AppColors.secondary,
                onTap: () => context.push('/b2b/stock'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.list_alt_outlined,
                label: 'Mes produits',
                color: AppColors.info,
                onTap: () => context.push('/b2b/products'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ActionCard(
                icon: Icons.receipt_long_outlined,
                label: 'Commandes',
                color: AppColors.warning,
                onTap: () => context.push('/b2b/wholesaler-orders'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLowStockAlert(ProductManagementState state) {
    if (state.lowStockProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                const SizedBox(width: AppSpacing.xs),
                Text('Alertes stock', style: AppTextStyles.h3),
              ],
            ),
            TextButton(
              onPressed: () => context.push('/b2b/stock'),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: state.lowStockProducts.take(3).map((product) {
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.inventory_2, color: AppColors.warning, size: 20),
                ),
                title: Text(product.name, style: AppTextStyles.bodyMedium),
                subtitle: Text('Stock: ${product.stockQuantity}', style: AppTextStyles.caption),
                trailing: TextButton(
                  onPressed: () => _showUpdateStockDialog(product),
                  child: const Text('Réapprovisionner'),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showUpdateStockDialog(product) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mettre à jour le stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            Text('Stock actuel: ${product.stockQuantity}', style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nouveau stock',
                hintText: 'Entrez la quantité',
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
            child: const Text('Mettre à jour'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(value, style: AppTextStyles.h2.copyWith(color: color)),
            ],
          ),
          const Spacer(),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(label, style: AppTextStyles.bodyMedium.copyWith(color: color), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
