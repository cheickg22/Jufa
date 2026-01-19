import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/b2b_order.dart';
import '../../domain/entities/order_status.dart';
import '../providers/order_provider.dart';

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'XOF', decimalDigits: 0);
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Future.microtask(() {
      ref.read(b2bOrderNotifierProvider.notifier).loadRetailerOrders(refresh: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(b2bOrderNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes commandes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          onTap: (index) {
            final status = _getStatusForTab(index);
            ref.read(b2bOrderNotifierProvider.notifier).loadRetailerOrders(
                  status: status,
                  refresh: true,
                );
          },
          tabs: const [
            Tab(text: 'Toutes'),
            Tab(text: 'En cours'),
            Tab(text: 'Livrées'),
            Tab(text: 'Annulées'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(b2bOrderNotifierProvider.notifier).loadRetailerOrders(
                status: _getStatusForTab(_tabController.index),
                refresh: true,
              );
        },
        child: state.isLoading && state.retailerOrders.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.retailerOrders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: state.retailerOrders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(state.retailerOrders[index]);
                    },
                  ),
      ),
    );
  }

  String? _getStatusForTab(int index) {
    switch (index) {
      case 1:
        return 'PENDING,CONFIRMED,PROCESSING,READY,SHIPPED';
      case 2:
        return 'DELIVERED';
      case 3:
        return 'CANCELLED';
      default:
        return null;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: AppColors.textHint),
          const SizedBox(height: AppSpacing.lg),
          Text('Aucune commande', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Vos commandes apparaîtront ici',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(B2BOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () => _showOrderDetail(order),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${order.reference}',
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.store, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    order.wholesalerName,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              const Divider(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${order.itemCount} article(s)',
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          currencyFormat.format(order.totalAmount),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        dateFormat.format(order.createdAt),
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        order.paymentStatusName,
                        style: AppTextStyles.caption.copyWith(
                          color: _getPaymentStatusColor(order.paymentStatus.name),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (order.status.canCancel)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _showCancelDialog(order),
                      icon: Icon(Icons.cancel_outlined, size: 18, color: AppColors.error),
                      label: Text('Annuler', style: TextStyle(color: AppColors.error)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        status.displayName,
        style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.info;
      case OrderStatus.processing:
        return AppColors.info;
      case OrderStatus.ready:
        return AppColors.secondary;
      case OrderStatus.shipped:
        return AppColors.secondary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
      case OrderStatus.refunded:
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return AppColors.success;
      case 'PARTIAL':
        return AppColors.warning;
      case 'OVERDUE':
        return AppColors.error;
      case 'CREDIT':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showOrderDetail(B2BOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Commande #${order.reference}',
                        style: AppTextStyles.h3,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    _buildDetailSection('Statut', [
                      _buildDetailRow('Commande', order.statusName, _getStatusColor(order.status)),
                      _buildDetailRow('Paiement', order.paymentStatusName, _getPaymentStatusColor(order.paymentStatus.name)),
                    ]),
                    _buildDetailSection('Grossiste', [
                      _buildDetailRow('Nom', order.wholesalerName, null),
                    ]),
                    _buildDetailSection('Dates', [
                      _buildDetailRow('Créée', dateFormat.format(order.createdAt), null),
                      if (order.confirmedAt != null)
                        _buildDetailRow('Confirmée', dateFormat.format(order.confirmedAt!), null),
                      if (order.shippedAt != null)
                        _buildDetailRow('Expédiée', dateFormat.format(order.shippedAt!), null),
                      if (order.deliveredAt != null)
                        _buildDetailRow('Livrée', dateFormat.format(order.deliveredAt!), null),
                    ]),
                    _buildDetailSection('Articles', [
                      ...order.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.productName, style: AppTextStyles.bodyMedium),
                                      Text(
                                        '${item.quantity} x ${currencyFormat.format(item.unitPrice)}',
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(item.lineTotal),
                                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          )),
                    ]),
                    _buildDetailSection('Montants', [
                      _buildDetailRow('Sous-total', currencyFormat.format(order.subtotal), null),
                      if (order.discountAmount > 0)
                        _buildDetailRow('Remise', '-${currencyFormat.format(order.discountAmount)}', AppColors.success),
                      _buildDetailRow('Total', currencyFormat.format(order.totalAmount), AppColors.primary, bold: true),
                      if (order.amountPaid > 0)
                        _buildDetailRow('Payé', currencyFormat.format(order.amountPaid), AppColors.success),
                      if (order.amountDue > 0)
                        _buildDetailRow('Reste à payer', currencyFormat.format(order.amountDue), AppColors.warning),
                    ]),
                    if (order.notes != null)
                      _buildDetailSection('Notes', [
                        Text(order.notes!, style: AppTextStyles.bodyMedium),
                      ]),
                    if (order.deliveryAddress != null)
                      _buildDetailSection('Adresse de livraison', [
                        Text(order.deliveryAddress!, style: AppTextStyles.bodyMedium),
                      ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color? valueColor, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valueColor,
              fontWeight: bold ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(B2BOrder order) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la commande'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Êtes-vous sûr de vouloir annuler la commande #${order.reference} ?'),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Raison (optionnel)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(b2bOrderNotifierProvider.notifier).cancelOrder(
                    order.id,
                    reasonController.text.isEmpty ? 'Annulé par le client' : reasonController.text,
                  );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Commande annulée'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: Text('Oui, annuler', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
