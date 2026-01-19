import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';

class ElectronicsPage extends StatefulWidget {
  const ElectronicsPage({super.key});

  @override
  State<ElectronicsPage> createState() => _ElectronicsPageState();
}

class _ElectronicsPageState extends State<ElectronicsPage> {
  String _selectedCategory = 'Tous';
  
  final List<String> _subCategories = [
    'Tous',
    'Smartphones',
    'Ordinateurs',
    'Télévisions',
    'Audio',
    'Accessoires',
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'id': 1,
      'name': 'iPhone 15 Pro',
      'category': 'Smartphones',
      'price': 850000,
      'image': '📱',
      'description': 'Apple iPhone 15 Pro 256GB',
      'stock': 15,
      'rating': 4.8,
      'reviews': 234,
    },
    {
      'id': 2,
      'name': 'Samsung Galaxy S24',
      'category': 'Smartphones',
      'price': 650000,
      'image': '📱',
      'description': 'Samsung Galaxy S24 Ultra 512GB',
      'stock': 20,
      'rating': 4.7,
      'reviews': 189,
    },
    {
      'id': 3,
      'name': 'MacBook Pro M3',
      'category': 'Ordinateurs',
      'price': 1500000,
      'image': '💻',
      'description': 'MacBook Pro 14" M3 16GB RAM',
      'stock': 8,
      'rating': 4.9,
      'reviews': 156,
    },
    {
      'id': 4,
      'name': 'Dell XPS 15',
      'category': 'Ordinateurs',
      'price': 950000,
      'image': '💻',
      'description': 'Dell XPS 15 Intel i7 32GB RAM',
      'stock': 12,
      'rating': 4.6,
      'reviews': 98,
    },
    {
      'id': 5,
      'name': 'Samsung TV 55"',
      'category': 'Télévisions',
      'price': 450000,
      'image': '📺',
      'description': 'Samsung QLED 4K 55 pouces',
      'stock': 10,
      'rating': 4.5,
      'reviews': 145,
    },
    {
      'id': 6,
      'name': 'LG OLED 65"',
      'category': 'Télévisions',
      'price': 750000,
      'image': '📺',
      'description': 'LG OLED 4K 65 pouces',
      'stock': 6,
      'rating': 4.8,
      'reviews': 112,
    },
    {
      'id': 7,
      'name': 'AirPods Pro',
      'category': 'Audio',
      'price': 180000,
      'image': '🎧',
      'description': 'Apple AirPods Pro 2ème génération',
      'stock': 25,
      'rating': 4.7,
      'reviews': 567,
    },
    {
      'id': 8,
      'name': 'Sony WH-1000XM5',
      'category': 'Audio',
      'price': 220000,
      'image': '🎧',
      'description': 'Casque Sony à réduction de bruit',
      'stock': 18,
      'rating': 4.9,
      'reviews': 423,
    },
    {
      'id': 9,
      'name': 'iPad Air',
      'category': 'Accessoires',
      'price': 420000,
      'image': '📱',
      'description': 'iPad Air M2 128GB',
      'stock': 14,
      'rating': 4.6,
      'reviews': 201,
    },
    {
      'id': 10,
      'name': 'Apple Watch Series 9',
      'category': 'Accessoires',
      'price': 280000,
      'image': '⌚',
      'description': 'Apple Watch Series 9 GPS 45mm',
      'stock': 22,
      'rating': 4.7,
      'reviews': 334,
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedCategory == 'Tous') {
      return _products;
    }
    return _products.where((p) => p['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Électronique'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: Implémenter la recherche
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              // TODO: Implémenter le panier
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres de catégories
          _buildCategoryFilter(),
          
          // Liste des produits
          Expanded(
            child: _filteredProducts.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(_filteredProducts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _subCategories.length,
        itemBuilder: (context, index) {
          final category = _subCategories[index];
          final isSelected = category == _selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () => _showProductDetails(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du produit
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Text(
                  product['image'],
                  style: TextStyle(fontSize: 48),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom du produit
                  Text(
                    product['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Description
                  Text(
                    product['description'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Note et avis
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        '${product['rating']}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product['reviews']})',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Prix
                  Text(
                    Formatters.formatCurrency(product['price']),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Stock
                  Text(
                    'En stock: ${product['stock']}',
                    style: TextStyle(
                      color: product['stock'] > 10 ? AppColors.success : AppColors.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices_other, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucun produit trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez une autre catégorie',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(24),
            children: [
              // Barre de glissement
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Image du produit
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    product['image'],
                    style: TextStyle(fontSize: 80),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Nom et catégorie
              Text(
                product['name'],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product['category'],
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Note et avis
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${product['rating']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${product['reviews']} avis)',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Description
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                product['description'],
                style: TextStyle(
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Stock
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: product['stock'] > 10 ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'En stock: ${product['stock']} unités',
                    style: TextStyle(
                      color: product['stock'] > 10 ? AppColors.success : AppColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Prix
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Prix',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(product['price']),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Bouton d'achat
              CustomButton(
                text: 'Acheter avec carte Jufa',
                icon: Icons.credit_card,
                onPressed: () {
                  Navigator.pop(context);
                  _showPaymentOptions(product);
                },
              ),
              
              const SizedBox(height: 12),
              
              CustomButton(
                text: 'Ajouter au panier',
                icon: Icons.shopping_cart_outlined,
                isOutlined: true,
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product['name']} ajouté au panier'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentOptions(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choisir une carte Jufa',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Sélectionnez la carte que vous souhaitez utiliser pour cet achat',
              style: TextStyle(color: Colors.grey[600]),
            ),
            
            const SizedBox(height: 24),
            
            _buildCardOption(
              'Carte Virtuelle',
              'Solde: 250 000 FCFA',
              Icons.credit_card,
              Colors.blue,
              () {
                Navigator.pop(context);
                _confirmPurchase(product, 'Virtuelle');
              },
            ),
            
            const SizedBox(height: 12),
            
            _buildCardOption(
              'Carte Physique',
              'Solde: 500 000 FCFA',
              Icons.credit_card,
              Colors.purple,
              () {
                Navigator.pop(context);
                _confirmPurchase(product, 'Physique');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardOption(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  void _confirmPurchase(Map<String, dynamic> product, String cardType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer l\'achat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Produit: ${product['name']}'),
            const SizedBox(height: 8),
            Text('Prix: ${Formatters.formatCurrency(product['price'])}'),
            const SizedBox(height: 8),
            Text('Carte: $cardType'),
            const SizedBox(height: 16),
            Text(
              'Voulez-vous confirmer cet achat ?',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPurchase(product, cardType);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('Confirmer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _processPurchase(Map<String, dynamic> product, String cardType) {
    // TODO: Implémenter l'appel API pour l'achat
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 32),
            SizedBox(width: 12),
            Text('Achat réussi !'),
          ],
        ),
        content: Text(
          'Votre achat de ${product['name']} a été effectué avec succès via votre carte $cardType.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/dashboard');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('Retour à l\'accueil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
