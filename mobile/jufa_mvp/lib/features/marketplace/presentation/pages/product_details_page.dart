import 'package:flutter/material.dart';
import '../../../../core/models/cart_item.dart';
import '../../../../core/services/marketplace_service.dart';
import '../../../../core/services/cart_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import 'cart_page.dart';
import 'checkout_page.dart';

class ProductDetailsPage extends StatefulWidget {
  final int productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final MarketplaceService _marketplaceService = MarketplaceService();
  final CartService _cartService = CartService();
  
  Map<String, dynamic>? _product;
  bool _isLoading = true;
  String? _errorMessage;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
    _loadCart();
  }

  Future<void> _loadProductDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final product = await _marketplaceService.getProductDetails(widget.productId);
      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCart() async {
    await _cartService.loadCart();
    setState(() {});
  }

  Future<void> _addToCart() async {
    if (_product == null) return;

    final cartItem = CartItem(
      productId: _product!['id'],
      productName: _product!['name'],
      productImage: _product!['image'] ?? '',
      price: (_product!['price'] as num).toDouble(),
      quantity: _quantity,
    );

    await _cartService.addItem(cartItem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_product!['name']} ajouté au panier'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Voir',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
        ),
      );
    }
  }

  Future<void> _buyNow() async {
    if (_product == null) return;

    // Créer un item temporaire pour la commande directe
    final cartItem = CartItem(
      productId: _product!['id'],
      productName: _product!['name'],
      productImage: _product!['image'] ?? '',
      price: (_product!['price'] as num).toDouble(),
      quantity: _quantity,
    );

    // Calculer le total
    final totalAmount = cartItem.price * cartItem.quantity;

    // Naviguer vers la page de checkout avec cet item
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(
            cartItems: [cartItem],
            totalAmount: totalAmount,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du produit'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _buildProductDetails(),
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Une erreur est survenue',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadProductDetails,
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

  Widget _buildProductDetails() {
    if (_product == null) return const SizedBox();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductHeader(),
                const SizedBox(height: 16),
                _buildProductDescription(),
                const SizedBox(height: 24),
                _buildQuantitySelector(),
                const SizedBox(height: 24),
                _buildActionButtons(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    final imageUrl = _product!['image'] ?? '';
    
    return Container(
      width: double.infinity,
      height: 300,
      color: Colors.grey[100],
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.shopping_bag,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                );
              },
            )
          : Center(
              child: Icon(
                Icons.shopping_bag,
                size: 100,
                color: Colors.grey[400],
              ),
            ),
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _product!['name'],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          Formatters.formatCurrency((_product!['price'] as num).toDouble()),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        if (_product!['category'] != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _product!['category'],
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProductDescription() {
    final description = _product!['description'] ?? 'Aucune description disponible';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        const Text(
          'Quantité',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (_quantity > 1) {
                    setState(() => _quantity--);
                  }
                },
                icon: const Icon(Icons.remove),
                color: AppColors.primary,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() => _quantity++);
                },
                icon: const Icon(Icons.add),
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Bouton Commander
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _buyNow,
            icon: const Icon(Icons.shopping_bag),
            label: const Text(
              'Commander maintenant',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Bouton Ajouter au panier
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addToCart,
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text(
              'Ajouter au panier',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.primary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
