import 'package:flutter/material.dart';
import '../../../../core/models/order.dart';
import '../../../../core/services/marketplace_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

class OrderDetailsPage extends StatefulWidget {
  final int orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final MarketplaceService _marketplaceService = MarketplaceService();
  Order? _order;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final order = await _marketplaceService.getOrderDetails(widget.orderId);
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la commande'),
        content: const Text('Êtes-vous sûr de vouloir annuler cette commande ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui, annuler', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _marketplaceService.cancelOrder(widget.orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commande annulée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        _loadOrderDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la commande'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _buildOrderDetails(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[800]),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Une erreur est survenue',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadOrderDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails() {
    if (_order == null) return const SizedBox();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildOrderHeader(),
        const SizedBox(height: 16),
        _buildOrderStatus(),
        const SizedBox(height: 16),
        _buildDeliveryInfo(),
        const SizedBox(height: 16),
        _buildOrderItems(),
        const SizedBox(height: 16),
        _buildPaymentInfo(),
        const SizedBox(height: 16),
        if (_order!.status.toLowerCase() == 'pending') _buildCancelButton(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildOrderHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Numéro de commande',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              _order!.orderNumber,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Passée le ${_formatDateTime(_order!.createdAt)}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statut de la commande',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildStatusTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final statuses = ['pending', 'confirmed', 'processing', 'shipped', 'delivered'];
    final currentIndex = statuses.indexOf(_order!.status.toLowerCase());

    return Column(
      children: List.generate(statuses.length, (index) {
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;
        
        return Row(
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.primary : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : Icons.circle,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                if (index < statuses.length - 1)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted ? AppColors.primary : Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _getStatusLabel(statuses[index]),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDeliveryInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations de livraison',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, 'Adresse', _order!.deliveryAddress),
            if (_order!.deliveryCity != null)
              _buildInfoRow(Icons.location_city, 'Ville', _order!.deliveryCity!),
            if (_order!.deliveryPhone != null)
              _buildInfoRow(Icons.phone, 'Téléphone', _order!.deliveryPhone!),
            if (_order!.deliveryNotes != null) ...[
              const Divider(height: 24),
              _buildInfoRow(Icons.note, 'Instructions', _order!.deliveryNotes!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Articles commandés',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._order!.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.productImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.productImage!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (item.variant != null)
                          Text(
                            item.variant!,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          '${Formatters.formatCurrency(item.price)} x ${item.quantity}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(item.totalPrice),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Récapitulatif',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Sous-total', _order!.totalAmount),
            const SizedBox(height: 8),
            _buildSummaryRow('Frais de livraison', _order!.shippingFee),
            const Divider(height: 24),
            _buildSummaryRow('Total', _order!.grandTotal, isTotal: true),
            const Divider(height: 24),
            Row(
              children: [
                Icon(
                  _order!.paymentMethod == 'wallet' 
                      ? Icons.account_balance_wallet 
                      : Icons.money,
                  size: 20,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  _order!.paymentMethod == 'wallet'
                      ? 'Portefeuille JUFA'
                      : 'Paiement à la livraison',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? null : Colors.grey[700],
          ),
        ),
        Text(
          Formatters.formatCurrency(amount),
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? AppColors.primary : null,
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _cancelOrder,
        icon: const Icon(Icons.cancel),
        label: const Text('Annuler la commande'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmée';
      case 'processing':
        return 'En préparation';
      case 'shipped':
        return 'Expédiée';
      case 'delivered':
        return 'Livrée';
      default:
        return status;
    }
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
