import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/b2b_order.dart';
import '../../domain/entities/order_status.dart';
import '../../data/models/b2b_order_model.dart';

final wholesalerOrdersProvider = FutureProvider<List<B2BOrder>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final response = await apiClient.get(ApiConstants.b2bOrdersWholesaler);
    if (response['success'] == true) {
      final List<dynamic> data = response['data']['content'] ?? response['data'] ?? [];
      return data.map((json) => B2BOrderModel.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    return [];
  }
});

class WholesalerOrdersScreen extends ConsumerStatefulWidget {
  const WholesalerOrdersScreen({super.key});

  @override
  ConsumerState<WholesalerOrdersScreen> createState() => _WholesalerOrdersScreenState();
}

class _WholesalerOrdersScreenState extends ConsumerState<WholesalerOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<OrderStatus?> _tabs = [null, OrderStatus.pending, OrderStatus.confirmed, OrderStatus.shipped, OrderStatus.delivered];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(wholesalerOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Commandes reçues'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: ordersAsync.when(
            data: (orders) => [
              _buildTab('Toutes', orders.length),
              _buildTab('En attente', _countByStatus(orders, OrderStatus.pending)),
              _buildTab('Confirmées', _countByStatus(orders, OrderStatus.confirmed)),
              _buildTab('Expédiées', _countByStatus(orders, OrderStatus.shipped)),
              _buildTab('Livrées', _countByStatus(orders, OrderStatus.delivered)),
            ],
            loading: () => _tabs.map((s) => Tab(text: s?.displayName ?? 'Toutes')).toList(),
            error: (_, __) => _tabs.map((s) => Tab(text: s?.displayName ?? 'Toutes')).toList(),
          ),
        ),
      ),
      body: ordersAsync.when(
        data: (orders) => TabBarView(
          controller: _tabController,
          children: _tabs.map((status) => _buildOrderList(orders, status)).toList(),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }

  Widget _buildTab(String label, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  int _countByStatus(List<B2BOrder> orders, OrderStatus status) {
    return orders.where((o) => o.status == status).length;
  }

  Widget _buildOrderList(List<B2BOrder> orders, OrderStatus? filterStatus) {
    final filteredOrders = filterStatus == null
        ? orders
        : orders.where((o) => o.status == filterStatus).toList();

    if (filteredOrders.isEmpty) {
      return _buildEmptyState(filterStatus);
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(wholesalerOrdersProvider),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) => _OrderCard(
          order: filteredOrders[index],
          onConfirm: () => _confirmOrder(filteredOrders[index]),
          onUpdateStatus: (status) => _updateStatus(filteredOrders[index], status),
        ),
      ),
    );
  }

  Widget _buildEmptyState(OrderStatus? status) {
    String message;
    IconData icon;
    switch (status) {
      case OrderStatus.pending:
        message = 'Aucune commande en attente';
        icon = Icons.hourglass_empty;
        break;
      case OrderStatus.confirmed:
        message = 'Aucune commande confirmée';
        icon = Icons.check_circle_outline;
        break;
      case OrderStatus.shipped:
        message = 'Aucune commande en livraison';
        icon = Icons.local_shipping_outlined;
        break;
      case OrderStatus.delivered:
        message = 'Aucune commande livrée';
        icon = Icons.inventory_2_outlined;
        break;
      default:
        message = 'Aucune commande';
        icon = Icons.receipt_long_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.lg),
          Text(message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Future<void> _confirmOrder(B2BOrder order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la commande ?'),
        content: Text('Confirmez la commande ${order.reference} de ${order.retailerName} pour ${order.totalAmount.toStringAsFixed(0)} XOF ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Confirmer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final apiClient = ref.read(apiClientProvider);
        await apiClient.post(ApiConstants.b2bOrderConfirm(order.reference));
        ref.invalidate(wholesalerOrdersProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Commande confirmée'), backgroundColor: AppColors.success),
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

  Future<void> _updateStatus(B2BOrder order, OrderStatus newStatus) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.patch('${ApiConstants.b2bOrderStatus(order.reference)}?status=${newStatus.name.toUpperCase()}');
      ref.invalidate(wholesalerOrdersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Statut mis à jour: ${_getStatusLabel(newStatus)}'), backgroundColor: AppColors.success),
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

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return 'Brouillon';
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.confirmed:
        return 'Confirmée';
      case OrderStatus.processing:
        return 'En préparation';
      case OrderStatus.ready:
        return 'Prête';
      case OrderStatus.shipped:
        return 'Expédiée';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
      case OrderStatus.refunded:
        return 'Remboursée';
    }
  }
}

class _OrderCard extends StatelessWidget {
  final B2BOrder order;
  final VoidCallback onConfirm;
  final Function(OrderStatus) onUpdateStatus;

  const _OrderCard({
    required this.order,
    required this.onConfirm,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    _getStatusIcon(order.status),
                    color: _getStatusColor(order.status),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.reference,
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(order.retailerName, style: AppTextStyles.bodySmall),
                      Text(
                        _formatDate(order.createdAt),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${order.totalAmount.toStringAsFixed(0)} XOF',
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    _StatusBadge(status: order.status),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${order.itemCount} article(s)', style: AppTextStyles.caption),
                if (order.notes != null && order.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Note: ${order.notes}',
                      style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: _buildActions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    switch (order.status) {
      case OrderStatus.pending:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => _showCancelDialog(context),
              child: const Text('Refuser', style: TextStyle(color: AppColors.error)),
            ),
            const SizedBox(width: AppSpacing.sm),
            ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              child: const Text('Confirmer', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      case OrderStatus.confirmed:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () => onUpdateStatus(OrderStatus.shipped),
              icon: const Icon(Icons.local_shipping, size: 18, color: Colors.white),
              label: const Text('Marquer expédiée', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.info),
            ),
          ],
        );
      case OrderStatus.shipped:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () => onUpdateStatus(OrderStatus.delivered),
              icon: const Icon(Icons.check_circle, size: 18, color: Colors.white),
              label: const Text('Marquer livrée', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            ),
          ],
        );
      case OrderStatus.delivered:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 18),
            const SizedBox(width: 8),
            Text('Commande livrée', style: AppTextStyles.bodySmall.copyWith(color: AppColors.success)),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refuser la commande ?'),
        content: const Text('Cette action est irréversible. Le client sera notifié du refus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onUpdateStatus(OrderStatus.cancelled);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Refuser', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return AppColors.textSecondary;
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.info;
      case OrderStatus.processing:
        return AppColors.info;
      case OrderStatus.ready:
        return AppColors.secondary;
      case OrderStatus.shipped:
        return AppColors.primary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
      case OrderStatus.refunded:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return Icons.edit;
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.processing:
        return Icons.inventory_2;
      case OrderStatus.ready:
        return Icons.inventory;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
      case OrderStatus.refunded:
        return Icons.replay;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        _getLabel(),
        style: AppTextStyles.caption.copyWith(color: _getColor(), fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case OrderStatus.draft:
        return AppColors.textSecondary;
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.info;
      case OrderStatus.processing:
        return AppColors.info;
      case OrderStatus.ready:
        return AppColors.secondary;
      case OrderStatus.shipped:
        return AppColors.primary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
      case OrderStatus.refunded:
        return AppColors.error;
    }
  }

  String _getLabel() {
    switch (status) {
      case OrderStatus.draft:
        return 'Brouillon';
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.confirmed:
        return 'Confirmée';
      case OrderStatus.processing:
        return 'En préparation';
      case OrderStatus.ready:
        return 'Prête';
      case OrderStatus.shipped:
        return 'Expédiée';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
      case OrderStatus.refunded:
        return 'Remboursée';
    }
  }
}
