import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/services/marketplace_service.dart';
import '../../../../core/services/cart_service.dart';
import '../../../navigation/presentation/widgets/bottom_navigation_widget.dart';
import 'cart_page.dart';
import 'category_subcategories_page.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _shimmerController;
  late Animation<double> _headerAnimation;
  late Animation<double> _shimmerAnimation;
  
  final MarketplaceService _marketplaceService = MarketplaceService();
  final CartService _cartService = CartService();
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _featuredProducts = [];
  bool _isLoadingCategories = true;
  bool _isLoadingProducts = true;
  
  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    
    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );
    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    
    _headerAnimationController.forward();
    _loadCategories();
    _loadFeaturedProducts();
    _loadCart();
  }
  
  Future<void> _loadCart() async {
    await _cartService.loadCart();
    if (mounted) {
      setState(() {});
    }
  }
  
  Future<void> _loadCategories() async {
    try {
      final categories = await _marketplaceService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories.map((cat) {
            return {
              'id': cat['id'],
              'title': cat['name'],
              'name': cat['name'],
              'icon': _getIconFromString(cat['icon'] ?? 'shopping_bag'),
              'color': _getColorFromHex(cat['color'] ?? '#6366F1'),
              'colorHex': cat['color'] ?? '#6366F1',
              'subcategories': cat['subcategories'] ?? [],
              'slug': cat['slug'],
              'description': cat['description'],
              'route': '/marketplace/category/${cat['id']}',
            };
          }).toList();
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement catégories: $e');
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
          // Catégories par défaut en cas d'erreur
          _categories = [
            {
              'title': 'Électronique',
              'icon': Icons.devices,
              'color': Colors.blue.shade600,
              'colorHex': '#2196F3',
              'route': '/electronics',
              'subcategories': [],
            },
            {
              'title': 'Mode & Vêtements',
              'icon': Icons.checkroom,
              'color': Colors.pink.shade400,
              'colorHex': '#EC407A',
              'route': '/fashion',
              'subcategories': [],
            },
          ];
        });
      }
    }
  }
  
  Future<void> _loadFeaturedProducts() async {
    try {
      final products = await _marketplaceService.getFeaturedProducts();
      print('📦 Produits reçus: $products');
      if (mounted) {
        setState(() {
          _featuredProducts = products.map((prod) {
            final imageUrl = prod['image'] ?? '';
            print('🖼️ Image URL pour ${prod['name']}: $imageUrl');
            return {
              'id': prod['id'],
              'title': prod['name'],
              'description': prod['description'] ?? '',
              'price': prod['price'],
              'image': imageUrl,
              'category': prod['category'] ?? '',
              'badge': prod['badge'] ?? '',
            };
          }).toList();
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement produits: $e');
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
          // Produits par défaut en cas d'erreur
          _featuredProducts = [];
        });
      }
    }
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
    };
    return iconMap[iconName] ?? Icons.shopping_bag;
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
  
  @override
  void dispose() {
    _headerAnimationController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Marketplace'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.receipt_long),
            onPressed: () {
              context.push('/marketplace/orders');
            },
            tooltip: 'Mes commandes',
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonction de recherche bientôt disponible'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Rechercher',
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartPage()),
                  );
                },
                tooltip: 'Panier',
              ),
              if (_cartService.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_cartService.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            
            const SizedBox(height: 24),
            
            // Categories
            _buildCategoriesSection(),
            
            const SizedBox(height: 32),
            
            // Featured Products
            _buildFeaturedSection(),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 3),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _headerAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(_headerAnimation),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.shade700,
                Colors.purple.shade500,
                Colors.pink.shade400,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.pink.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Transform.rotate(
                          angle: (1 - value) * 0.5,
                          child: Icon(Icons.shopping_bag, color: Colors.white, size: 32),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Marketplace JUFA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Achetez tout ce dont vous avez besoin en un seul endroit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildFeatureBadge(
                    icon: Icons.local_shipping,
                    text: 'Livraison rapide',
                    delay: 200,
                  ),
                  const SizedBox(width: 8),
                  _buildFeatureBadge(
                    icon: Icons.verified_user,
                    text: 'Paiement sécurisé',
                    delay: 400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureBadge({required IconData icon, required String text, required int delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return _buildCategoryCard(category);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: animValue,
          child: _AnimatedCategoryCard(category: category),
        );
      },
    );
  }

  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Produits en vedette',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _featuredProducts.length,
          itemBuilder: (context, index) {
            final product = _featuredProducts[index];
            return _buildProductCard(product);
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animValue)),
            child: _AnimatedProductCard(product: product),
          ),
        );
      },
    );
  }

  void _showVisaCardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.credit_card, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Carte Visa'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Obtenez votre carte Visa prépayée pour vos achats en ligne et dans le monde entier.'),
            SizedBox(height: 16),
            Text('Fonctionnalités:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Carte virtuelle instantanée'),
            Text('• Acceptée partout dans le monde'),
            Text('• Rechargeable à tout moment'),
            Text('• Sécurisée et protégée'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Commande de carte Visa - Bientôt disponible'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text('Commander'),
          ),
        ],
      ),
    );
  }

  void _showVisaServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.card_membership, color: AppColors.success),
            SizedBox(width: 8),
            Text('Service Visa'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Accédez aux services Visa premium pour une expérience bancaire exceptionnelle.'),
            SizedBox(height: 16),
            Text('Services inclus:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Assistance 24h/7j'),
            Text('• Assurance voyage'),
            Text('• Accès aux salons VIP'),
            Text('• Cashback sur les achats'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Souscription Service Visa - Bientôt disponible'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text('Souscrire'),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCategoryCard extends StatefulWidget {
  final Map<String, dynamic> category;
  
  const _AnimatedCategoryCard({required this.category});
  
  @override
  State<_AnimatedCategoryCard> createState() => _AnimatedCategoryCardState();
}

class _AnimatedCategoryCardState extends State<_AnimatedCategoryCard> {
  bool _isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        final subcategories = widget.category['subcategories'] as List? ?? [];
        
        // Si la catégorie a des sous-catégories, naviguer vers la page avec onglets
        if (subcategories.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategorySubcategoriesPage(
                category: widget.category,
              ),
            ),
          );
        } else {
          // Sinon, naviguer vers la page de produits de la catégorie
          final categoryId = widget.category['id'] as int;
          final categoryName = widget.category['title'] as String;
          context.push('/marketplace/category/$categoryId?name=$categoryName');
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              widget.category['color'].withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isPressed 
                ? widget.category['color'].withOpacity(0.5)
                : AppColors.border,
            width: _isPressed ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isPressed
                  ? widget.category['color'].withOpacity(0.3)
                  : AppColors.shadowLight,
              blurRadius: _isPressed ? 12 : 8,
              offset: Offset(0, _isPressed ? 4 : 2),
              spreadRadius: _isPressed ? 1 : 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (value * 0.2),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.category['color'].withOpacity(0.2),
                          widget.category['color'].withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: widget.category['color'].withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.category['icon'],
                      color: widget.category['color'],
                      size: 20,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 6),
            Text(
              widget.category['title'],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedProductCard extends StatefulWidget {
  final Map<String, dynamic> product;
  
  const _AnimatedProductCard({required this.product});
  
  @override
  State<_AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<_AnimatedProductCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  
  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      onTap: () {
        // Navigation vers la page de détails du produit
        final productId = widget.product['id'] as int;
        context.push('/marketplace/product/$productId');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        transform: Matrix4.identity()..scale(_isHovered ? 0.98 : 1.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              _isHovered ? AppColors.primary.withOpacity(0.03) : Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? AppColors.primary.withOpacity(0.3) : AppColors.border,
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered 
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.shadowLight,
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 6 : 2),
              spreadRadius: _isHovered ? 2 : 0,
            ),
          ],
        ),
        child: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.15),
                          AppColors.primary.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: widget.product['image'] != null && widget.product['image'].toString().isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              widget.product['image'],
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  print('✅ Image chargée: ${widget.product['image']}');
                                  return child;
                                }
                                print('⏳ Chargement image: ${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes}');
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print('❌ Erreur chargement image: $error');
                                print('❌ URL: ${widget.product['image']}');
                                return Icon(
                                  Icons.shopping_bag,
                                  color: AppColors.primary,
                                  size: 34,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.shopping_bag,
                            color: AppColors.primary,
                            size: 34,
                          ),
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.product['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      AnimatedBuilder(
                        animation: _shimmerAnimation,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.success.withOpacity(0.15),
                                  AppColors.success.withOpacity(0.25),
                                  AppColors.success.withOpacity(0.15),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                                begin: Alignment(_shimmerAnimation.value, 0),
                                end: Alignment(-_shimmerAnimation.value, 0),
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.success.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.product['badge'] ?? widget.product['category'],
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.8 + (value * 0.2),
                            child: ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    Colors.purple.shade600,
                                  ],
                                ).createShader(bounds);
                              },
                              child: Text(
                                Formatters.formatCurrency(widget.product['price']),
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
