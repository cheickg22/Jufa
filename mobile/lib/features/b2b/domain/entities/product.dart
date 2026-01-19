import 'product_unit.dart';

class Product {
  final String id;
  final String? categoryId;
  final String? categoryName;
  final String? sku;
  final String name;
  final String? description;
  final ProductUnit unit;
  final String unitName;
  final double unitPrice;
  final double? wholesalePrice;
  final double effectivePrice;
  final int minOrderQuantity;
  final int stockQuantity;
  final bool inStock;
  final bool lowStock;
  final String? imageUrl;
  final bool active;
  final bool featured;

  const Product({
    required this.id,
    this.categoryId,
    this.categoryName,
    this.sku,
    required this.name,
    this.description,
    required this.unit,
    required this.unitName,
    required this.unitPrice,
    this.wholesalePrice,
    required this.effectivePrice,
    this.minOrderQuantity = 1,
    this.stockQuantity = 0,
    this.inStock = true,
    this.lowStock = false,
    this.imageUrl,
    this.active = true,
    this.featured = false,
  });

  Product copyWith({
    String? id,
    String? categoryId,
    String? categoryName,
    String? sku,
    String? name,
    String? description,
    ProductUnit? unit,
    String? unitName,
    double? unitPrice,
    double? wholesalePrice,
    double? effectivePrice,
    int? minOrderQuantity,
    int? stockQuantity,
    bool? inStock,
    bool? lowStock,
    String? imageUrl,
    bool? active,
    bool? featured,
  }) {
    return Product(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      description: description ?? this.description,
      unit: unit ?? this.unit,
      unitName: unitName ?? this.unitName,
      unitPrice: unitPrice ?? this.unitPrice,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      effectivePrice: effectivePrice ?? this.effectivePrice,
      minOrderQuantity: minOrderQuantity ?? this.minOrderQuantity,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      inStock: inStock ?? this.inStock,
      lowStock: lowStock ?? this.lowStock,
      imageUrl: imageUrl ?? this.imageUrl,
      active: active ?? this.active,
      featured: featured ?? this.featured,
    );
  }
}
