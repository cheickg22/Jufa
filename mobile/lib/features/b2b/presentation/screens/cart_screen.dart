import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'XOF', decimalDigits: 0);
  final _notesController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cart = ref.read(cartNotifierProvider);
    _notesController.text = cart.notes ?? '';
    _addressController.text = cart.deliveryAddress ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);
    final orderState = ref.watch(b2bOrderNotifierProvider);

    ref.listen<B2BOrderState>(b2bOrderNotifierProvider, (previous, next) {
      if (next.currentOrder != null && previous?.currentOrder == null) {
        _showOrderSuccessDialog(next.currentOrder!.reference);
      }
      if (next.error != null && previous?.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: AppColors.error),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Panier (${cartState.totalItems})'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (cartState.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showClearCartDialog(),
            ),
        ],
      ),
      body: cartState.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      if (cartState.wholesalerName != null)
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.store, color: AppColors.primary),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                cartState.wholesalerName!,
                                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ...cartState.items.values.map((item) => _buildCartItem(item)),
                      const SizedBox(height: AppSpacing.lg),
                      _buildNotesField(),
                      const SizedBox(height: AppSpacing.md),
                      _buildAddressField(),
                      const SizedBox(height: AppSpacing.md),
                      _buildCreditOption(cartState),
                      const SizedBox(height: AppSpacing.lg),
                      _buildOrderSummary(cartState),
                    ],
                  ),
                ),
                _buildBottomBar(cartState, orderState),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.textHint),
          const SizedBox(height: AppSpacing.lg),
          Text('Votre panier est vide', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Parcourez le catalogue pour ajouter des produits',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continuer les achats'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: item.product.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Image.network(
                        item.product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.textHint,
                        ),
                      ),
                    )
                  : Icon(Icons.inventory_2_outlined, color: AppColors.textHint),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    currencyFormat.format(item.product.effectivePrice),
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _buildQuantityControl(item),
                      const Spacer(),
                      Text(
                        currencyFormat.format(item.lineTotal),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 20, color: AppColors.error),
              onPressed: () {
                ref.read(cartNotifierProvider.notifier).removeFromCart(item.product.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControl(CartItem item) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: item.quantity > item.product.minOrderQuantity
                ? () => ref.read(cartNotifierProvider.notifier).updateQuantity(
                      item.product.id,
                      item.quantity - 1,
                    )
                : null,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.remove,
                size: 16,
                color: item.quantity > item.product.minOrderQuantity
                    ? AppColors.primary
                    : AppColors.textHint,
              ),
            ),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 40),
            alignment: Alignment.center,
            child: Text(
              '${item.quantity}',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          InkWell(
            onTap: item.quantity < item.product.stockQuantity
                ? () => ref.read(cartNotifierProvider.notifier).updateQuantity(
                      item.product.id,
                      item.quantity + 1,
                    )
                : null,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.add,
                size: 16,
                color: item.quantity < item.product.stockQuantity
                    ? AppColors.primary
                    : AppColors.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: 'Notes (optionnel)',
        hintText: 'Instructions spéciales...',
        prefixIcon: const Icon(Icons.note),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        filled: true,
        fillColor: AppColors.surface,
      ),
      onChanged: (value) {
        ref.read(cartNotifierProvider.notifier).setNotes(value.isEmpty ? null : value);
      },
    );
  }

  Widget _buildAddressField() {
    return TextField(
      controller: _addressController,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: 'Adresse de livraison (optionnel)',
        hintText: 'Adresse de livraison...',
        prefixIcon: const Icon(Icons.location_on),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        filled: true,
        fillColor: AppColors.surface,
      ),
      onChanged: (value) {
        ref.read(cartNotifierProvider.notifier).setDeliveryAddress(value.isEmpty ? null : value);
      },
    );
  }

  Widget _buildCreditOption(CartState cart) {
    return Card(
      child: SwitchListTile(
        value: cart.useCredit,
        onChanged: (value) {
          ref.read(cartNotifierProvider.notifier).setUseCredit(value);
        },
        title: const Text('Utiliser le crédit'),
        subtitle: const Text('Paiement à crédit selon votre limite'),
        secondary: Icon(Icons.credit_card, color: AppColors.primary),
      ),
    );
  }

  Widget _buildOrderSummary(CartState cart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Résumé', style: AppTextStyles.h3),
            const Divider(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Articles (${cart.totalItems})', style: AppTextStyles.bodyMedium),
                Text(currencyFormat.format(cart.subtotal), style: AppTextStyles.bodyMedium),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: AppTextStyles.h3),
                Text(
                  currencyFormat.format(cart.subtotal),
                  style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(CartState cart, B2BOrderState orderState) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total', style: AppTextStyles.bodySmall),
                  Text(
                    currencyFormat.format(cart.subtotal),
                    style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: orderState.isLoading
                    ? null
                    : () async {
                        final success = await ref.read(b2bOrderNotifierProvider.notifier).createOrder();
                        if (!success && mounted) {
                          // Error handled by listener
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: orderState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Passer commande'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vider le panier'),
        content: const Text('Voulez-vous vraiment vider votre panier ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartNotifierProvider.notifier).clearCart();
              Navigator.pop(context);
            },
            child: Text('Vider', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showOrderSuccessDialog(String reference) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, size: 48, color: AppColors.success),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Commande envoyée!', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Référence: $reference',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Votre commande a été envoyée au grossiste pour confirmation.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/b2b/orders');
            },
            child: const Text('Voir mes commandes'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }
}
