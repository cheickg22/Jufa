import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../providers/order_provider.dart';

final wholesalersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final response = await apiClient.get(ApiConstants.merchantWholesalers);
    if (response['success'] == true) {
      final List<dynamic> data = response['data'] ?? [];
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  } catch (e) {
    return [];
  }
});

class RetailerDashboardScreen extends ConsumerWidget {
  const RetailerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wholesalersAsync = ref.watch(wholesalersProvider);
    final ordersState = ref.watch(b2bOrderNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Espace Détaillant B2B'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push('/b2b/cart'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(wholesalersProvider);
          ref.read(b2bOrderNotifierProvider.notifier).loadRetailerOrders();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsCards(ordersState),
              const SizedBox(height: AppSpacing.xl),
              _buildQuickActions(context),
              const SizedBox(height: AppSpacing.xl),
              _buildWholesalersList(context, wholesalersAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(B2BOrderState ordersState) {
    final orders = ordersState.retailerOrders;
    final pendingOrders = orders.where((o) => o.status.name == 'pending').length;
    final confirmedOrders = orders.where((o) => o.status.name == 'confirmed').length;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          icon: Icons.shopping_bag_outlined,
          label: 'Commandes',
          value: '${orders.length}',
          color: AppColors.primary,
        ),
        _StatCard(
          icon: Icons.pending_actions,
          label: 'En attente',
          value: '$pendingOrders',
          color: pendingOrders > 0 ? AppColors.warning : AppColors.success,
        ),
        _StatCard(
          icon: Icons.check_circle_outline,
          label: 'Confirmées',
          value: '$confirmedOrders',
          color: AppColors.success,
        ),
        _StatCard(
          icon: Icons.store_outlined,
          label: 'Grossistes',
          value: '-',
          color: AppColors.info,
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
                icon: Icons.receipt_long_outlined,
                label: 'Mes commandes',
                color: AppColors.primary,
                onTap: () => context.push('/b2b/orders'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ActionCard(
                icon: Icons.shopping_cart_outlined,
                label: 'Mon panier',
                color: AppColors.secondary,
                onTap: () => context.push('/b2b/cart'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWholesalersList(BuildContext context, AsyncValue<List<Map<String, dynamic>>> wholesalersAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Grossistes disponibles', style: AppTextStyles.h3),
            TextButton(
              onPressed: () {},
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        wholesalersAsync.when(
          data: (wholesalers) {
            if (wholesalers.isEmpty) {
              return _buildEmptyWholesalers();
            }
            return Column(
              children: wholesalers.map((w) => _WholesalerCard(
                wholesaler: w,
                onTap: () {
                  final id = w['id'] ?? w['wholesalerId'] ?? '';
                  final name = w['businessName'] ?? w['name'] ?? 'Grossiste';
                  context.push('/b2b/catalog/$id?name=$name');
                },
              )).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => _buildErrorState(error),
        ),
      ],
    );
  }

  Widget _buildEmptyWholesalers() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.store_outlined, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Aucun grossiste disponible',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Les grossistes partenaires apparaîtront ici',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Erreur de chargement',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
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

class _WholesalerCard extends StatelessWidget {
  final Map<String, dynamic> wholesaler;
  final VoidCallback onTap;

  const _WholesalerCard({
    required this.wholesaler,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = wholesaler['businessName'] ?? wholesaler['name'] ?? 'Grossiste';
    final category = wholesaler['businessCategory'] ?? wholesaler['category'] ?? '';
    final productCount = wholesaler['productCount'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(Icons.store, color: AppColors.primary),
        ),
        title: Text(name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category.isNotEmpty)
              Text(category, style: AppTextStyles.caption),
            if (productCount > 0)
              Text('$productCount produits', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ),
    );
  }
}
