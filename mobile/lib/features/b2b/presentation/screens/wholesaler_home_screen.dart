import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../data/models/b2b_order_model.dart';
import '../../domain/entities/b2b_order.dart';
import '../../domain/entities/order_status.dart';
import '../providers/product_management_provider.dart';

final wholesalerHomeOrdersProvider = FutureProvider<List<B2BOrder>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final response = await apiClient.get(ApiConstants.b2bOrdersWholesaler);
    if (response['success'] == true) {
      final List<dynamic> data = response['data']?['content'] ?? response['data'] ?? [];
      return data.map((json) => B2BOrderModel.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    return [];
  }
});

class WholesalerHomeScreen extends ConsumerStatefulWidget {
  const WholesalerHomeScreen({super.key});

  @override
  ConsumerState<WholesalerHomeScreen> createState() => _WholesalerHomeScreenState();
}

class _WholesalerHomeScreenState extends ConsumerState<WholesalerHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await ref.read(productManagementProvider.notifier).loadMyProducts();
    await ref.read(productManagementProvider.notifier).loadLowStockProducts();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(wholesalerHomeOrdersProvider);
    final productState = ref.watch(productManagementProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(wholesalerHomeOrdersProvider);
            await _loadData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildQuickStats(ordersAsync, productState),
                _buildQuickActions(context),
                _buildPendingOrders(context, ordersAsync),
                _buildLowStockAlert(context, productState),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Espace Grossiste', style: AppTextStyles.h2),
                const SizedBox(height: 2),
                Text(
                  'Gérez vos commandes et produits',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 28),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(AsyncValue<List<B2BOrder>> ordersAsync, ProductManagementState productState) {
    return ordersAsync.when(
      data: (orders) {
        final pendingCount = orders.where((o) => o.status == OrderStatus.pending).length;
        final todayOrders = orders.where((o) => 
          o.createdAt.day == DateTime.now().day &&
          o.createdAt.month == DateTime.now().month &&
          o.createdAt.year == DateTime.now().year
        ).length;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.pending_actions,
                  label: 'En attente',
                  value: '$pendingCount',
                  color: pendingCount > 0 ? AppColors.warning : AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  icon: Icons.today,
                  label: 'Aujourd\'hui',
                  value: '$todayOrders',
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  icon: Icons.warning_amber,
                  label: 'Stock bas',
                  value: '${productState.lowStockProducts.length}',
                  color: productState.lowStockProducts.isNotEmpty ? AppColors.error : AppColors.success,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Actions rapides', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.add_box_outlined,
                  label: 'Ajouter\nproduit',
                  color: AppColors.primary,
                  onTap: () => context.push('/b2b/product/new'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ActionButton(
                  icon: Icons.inventory_outlined,
                  label: 'Gérer\nstock',
                  color: AppColors.secondary,
                  onTap: () => context.push('/b2b/stock'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ActionButton(
                  icon: Icons.list_alt_outlined,
                  label: 'Mes\nproduits',
                  color: AppColors.info,
                  onTap: () => context.push('/b2b/products'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ActionButton(
                  icon: Icons.people_outline,
                  label: 'Mes\nclients',
                  color: AppColors.success,
                  onTap: () => context.push('/merchant/relations'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingOrders(BuildContext context, AsyncValue<List<B2BOrder>> ordersAsync) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Commandes en attente', style: AppTextStyles.h3),
              TextButton(
                onPressed: () => context.push('/b2b/wholesaler-orders'),
                child: const Text('Voir tout'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ordersAsync.when(
            data: (orders) {
              final pendingOrders = orders.where((o) => o.status == OrderStatus.pending).take(5).toList();
              
              if (pendingOrders.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Aucune commande en attente',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success),
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return Column(
                children: pendingOrders.map((order) => _OrderCard(
                  order: order,
                  onTap: () => context.push('/b2b/wholesaler-orders'),
                  onConfirm: () => _confirmOrder(order),
                )).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: AppSpacing.md),
                  Text('Erreur de chargement', style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockAlert(BuildContext context, ProductManagementState state) {
    if (state.lowStockProducts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
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
                child: const Text('Gérer'),
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
              children: state.lowStockProducts.take(3).map((product) => ListTile(
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
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/b2b/stock'),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmOrder(B2BOrder order) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.post(ApiConstants.b2bOrderConfirm(order.reference));
      ref.invalidate(wholesalerHomeOrdersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Commande ${order.reference} confirmée'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
        );
      }
    }
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
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTextStyles.h2.copyWith(color: color)),
          Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
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
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final B2BOrder order;
  final VoidCallback onTap;
  final VoidCallback onConfirm;

  const _OrderCard({
    required this.order,
    required this.onTap,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(Icons.receipt_long, color: AppColors.warning),
        ),
        title: Text(
          order.reference,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${order.items.length} articles', style: AppTextStyles.caption),
            Text(
              '${order.totalAmount.toStringAsFixed(0)} XOF',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          ),
          child: const Text('Confirmer', style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ),
    );
  }
}
