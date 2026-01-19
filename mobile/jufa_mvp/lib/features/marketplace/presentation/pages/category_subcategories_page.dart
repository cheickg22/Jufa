import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/marketplace_service.dart';

class CategorySubcategoriesPage extends StatefulWidget {
  final Map<String, dynamic> category;

  const CategorySubcategoriesPage({
    super.key,
    required this.category,
  });

  @override
  State<CategorySubcategoriesPage> createState() => _CategorySubcategoriesPageState();
}

class _CategorySubcategoriesPageState extends State<CategorySubcategoriesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MarketplaceService _marketplaceService = MarketplaceService();
  
  List<Map<String, dynamic>> _subcategories = [];
  Map<int, List<Map<String, dynamic>>> _productsPerSubcategory = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubcategories();
  }

  Future<void> _loadSubcategories() async {
    setState(() => _isLoading = true);
    
    try {
      // Les sous-catégories sont déjà dans category['subcategories']
      final subcategories = widget.category['subcategories'] as List? ?? [];
      _subcategories = subcategories.map((s) => s as Map<String, dynamic>).toList();
      
      // Initialiser le TabController avec le nombre de sous-catégories
      _tabController = TabController(
        length: _subcategories.length,
        vsync: this,
      );
      
      // Charger les produits pour chaque sous-catégorie
      for (var subcategory in _subcategories) {
        final products = await _marketplaceService.getCategoryProducts(subcategory['id']);
        _productsPerSubcategory[subcategory['id']] = products;
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Erreur chargement sous-catégories: $e');
      setState(() => _isLoading = false);
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.category['name'] ?? 'Catégorie'),
        backgroundColor: _getColorFromHex(widget.category['colorHex'] ?? '#6366F1'),
        elevation: 0,
        bottom: _subcategories.isEmpty
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicator: const BoxDecoration(),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    tabs: _subcategories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final subcategory = entry.value;
                      return _buildCircularTab(subcategory, index);
                    }).toList(),
                  ),
                ),
              ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subcategories.isEmpty
              ? _buildNoSubcategories()
              : TabBarView(
                  controller: _tabController,
                  children: _subcategories.map((subcategory) {
                    return _buildSubcategoryProducts(subcategory);
                  }).toList(),
                ),
    );
  }

  Widget _buildCircularTab(Map<String, dynamic> subcategory, int index) {
    final isSelected = _tabController.index == index;
    
    return AnimatedBuilder(
      animation: _tabController.animation!,
      builder: (context, child) {
        final animationValue = (_tabController.animation!.value - index).abs();
        final isActive = animationValue < 0.5;
        
        return Tab(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
                width: isActive ? 2 : 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subcategory['icon'] != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      _getIconFromString(subcategory['icon']),
                      size: 18,
                      color: isActive
                          ? _getColorFromHex(widget.category['colorHex'] ?? '#6366F1')
                          : Colors.white,
                    ),
                  ),
                Text(
                  subcategory['name'],
                  style: TextStyle(
                    color: isActive
                        ? _getColorFromHex(widget.category['colorHex'] ?? '#6366F1')
                        : Colors.white,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: isActive ? 15 : 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoSubcategories() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune sous-catégorie',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cette catégorie n\'a pas encore de sous-catégories',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryProducts(Map<String, dynamic> subcategory) {
    final products = _productsPerSubcategory[subcategory['id']] ?? [];

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun produit',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aucun produit disponible dans cette sous-catégorie',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          context.push('/marketplace/product/${product['id']}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: product['image'] != null && product['image'].isNotEmpty
                    ? Image.network(
                        product['image'],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey.shade400,
                              size: 40,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.shopping_bag,
                          color: Colors.grey.shade400,
                          size: 40,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? 'Produit',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (product['description'] != null)
                      Text(
                        product['description'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${product['price']} FCFA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getColorFromHex(widget.category['colorHex'] ?? '#6366F1'),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getColorFromHex(widget.category['colorHex'] ?? '#6366F1')
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Voir',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getColorFromHex(widget.category['colorHex'] ?? '#6366F1'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconFromString(String iconName) {
    final iconMap = {
      'devices': Icons.devices,
      'checkroom': Icons.checkroom,
      'restaurant': Icons.restaurant,
      'home': Icons.home,
      'spa': Icons.spa,
      'sports_soccer': Icons.sports_soccer,
      'book': Icons.book,
      'directions_car': Icons.directions_car,
      'shopping_bag': Icons.shopping_bag,
      'category': Icons.category,
      'laptop': Icons.laptop,
      'phone_android': Icons.phone_android,
      'headphones': Icons.headphones,
      'man': Icons.man,
      'woman': Icons.woman,
      'child_care': Icons.child_care,
    };
    return iconMap[iconName] ?? Icons.category;
  }

  Color _getColorFromHex(String hexColor) {
    try {
      hexColor = hexColor.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.blue.shade600;
    }
  }
}
