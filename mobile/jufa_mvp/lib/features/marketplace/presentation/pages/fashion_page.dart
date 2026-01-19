import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';

class FashionPage extends StatefulWidget {
  const FashionPage({super.key});

  @override
  State<FashionPage> createState() => _FashionPageState();
}

class _FashionPageState extends State<FashionPage> {
  String _selectedCategory = 'Tous';
  
  final List<String> _subCategories = [
    'Tous',
    'Hommes',
    'Femmes',
    'Enfants',
    'Chaussures',
    'Accessoires',
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'id': 1,
      'name': 'Costume Hugo Boss',
      'category': 'Hommes',
      'price': 250000,
      'image': '🤵',
      'description': 'Costume 2 pièces noir élégant',
      'stock': 8,
      'rating': 4.8,
      'reviews': 145,
    },
    {
      'id': 2,
      'name': 'Chemise Ralph Lauren',
      'category': 'Hommes',
      'price': 45000,
      'image': '👔',
      'description': 'Chemise blanche coton premium',
      'stock': 25,
      'rating': 4.6,
      'reviews': 234,
    },
    {
      'id': 3,
      'name': 'Jean Levi\'s 501',
      'category': 'Hommes',
      'price': 35000,
      'image': '👖',
      'description': 'Jean classique bleu délavé',
      'stock': 30,
      'rating': 4.7,
      'reviews': 567,
    },
    {
      'id': 4,
      'name': 'Robe Zara',
      'category': 'Femmes',
      'price': 55000,
      'image': '👗',
      'description': 'Robe d\'été fleurie légère',
      'stock': 15,
      'rating': 4.5,
      'reviews': 189,
    },
    {
      'id': 5,
      'name': 'Sac à main Gucci',
      'category': 'Femmes',
      'price': 450000,
      'image': '👜',
      'description': 'Sac à main cuir véritable',
      'stock': 5,
      'rating': 4.9,
      'reviews': 98,
    },
    {
      'id': 6,
      'name': 'Talons Christian Louboutin',
      'category': 'Femmes',
      'price': 380000,
      'image': '👠',
      'description': 'Escarpins rouges iconiques',
      'stock': 6,
      'rating': 4.8,
      'reviews': 156,
    },
    {
      'id': 7,
      'name': 'T-shirt Nike Kids',
      'category': 'Enfants',
      'price': 15000,
      'image': '👕',
      'description': 'T-shirt sport confortable',
      'stock': 40,
      'rating': 4.4,
      'reviews': 312,
    },
    {
      'id': 8,
      'name': 'Baskets Adidas',
      'category': 'Chaussures',
      'price': 65000,
      'image': '👟',
      'description': 'Baskets Superstar blanches',
      'stock': 22,
      'rating': 4.7,
      'reviews': 445,
    },
    {
      'id': 9,
      'name': 'Nike Air Jordan',
      'category': 'Chaussures',
      'price': 120000,
      'image': '👟',
      'description': 'Baskets Air Jordan 1 Retro',
      'stock': 12,
      'rating': 4.9,
      'reviews': 678,
    },
    {
      'id': 10,
      'name': 'Montre Rolex',
      'category': 'Accessoires',
      'price': 2500000,
      'image': '⌚',
      'description': 'Montre Submariner automatique',
      'stock': 2,
      'rating': 5.0,
      'reviews': 89,
    },
    {
      'id': 11,
      'name': 'Lunettes Ray-Ban',
      'category': 'Accessoires',
      'price': 85000,
      'image': '🕶️',
      'description': 'Lunettes de soleil Wayfarer',
      'stock': 18,
      'rating': 4.6,
      'reviews': 267,
    },
    {
      'id': 12,
      'name': 'Écharpe Burberry',
      'category': 'Accessoires',
      'price': 180000,
      'image': '🧣',
      'description': 'Écharpe cachemire à carreaux',
      'stock': 10,
      'rating': 4.7,
      'reviews': 123,
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
        title: Text('Mode & Vêtements'),
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
              selectedColor: Colors.pink.shade50,
              labelStyle: TextStyle(
                color: isSelected ? Colors.pink.shade700 : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? Colors.pink.shade400 : AppColors.border,
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
                color: Colors.pink.shade50,
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
                      color: Colors.pink.shade700,
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
          Icon(Icons.checkroom, size: 64, color: Colors.grey[400]),
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
                  color: Colors.pink.shade50,
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
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product['category'],
                  style: TextStyle(
                    color: Colors.pink.shade700,
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
                  color: Colors.pink.shade50,
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
                        color: Colors.pink.shade700,
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
                backgroundColor: Colors.pink.shade400,
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
                backgroundColor: Colors.pink.shade400,
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
              backgroundColor: Colors.pink.shade400,
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
              backgroundColor: Colors.pink.shade400,
            ),
            child: Text('Retour à l\'accueil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
