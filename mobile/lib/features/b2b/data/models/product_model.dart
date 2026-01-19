import '../../domain/entities/product.dart';
import '../../domain/entities/product_unit.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    super.categoryId,
    super.categoryName,
    super.sku,
    required super.name,
    super.description,
    required super.unit,
    required super.unitName,
    required super.unitPrice,
    super.wholesalePrice,
    required super.effectivePrice,
    super.minOrderQuantity,
    super.stockQuantity,
    super.inStock,
    super.lowStock,
    super.imageUrl,
    super.active,
    super.featured,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      sku: json['sku'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      unit: ProductUnit.fromString(json['unit'] as String? ?? 'PIECE'),
      unitName: json['unitName'] as String? ?? 'Pièce',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      wholesalePrice: (json['wholesalePrice'] as num?)?.toDouble(),
      effectivePrice: (json['effectivePrice'] as num?)?.toDouble() ?? 0,
      minOrderQuantity: json['minOrderQuantity'] as int? ?? 1,
      stockQuantity: json['stockQuantity'] as int? ?? 0,
      inStock: json['inStock'] as bool? ?? true,
      lowStock: json['lowStock'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      active: json['active'] as bool? ?? true,
      featured: json['featured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'sku': sku,
      'name': name,
      'description': description,
      'unit': unit.name.toUpperCase(),
      'unitName': unitName,
      'unitPrice': unitPrice,
      'wholesalePrice': wholesalePrice,
      'effectivePrice': effectivePrice,
      'minOrderQuantity': minOrderQuantity,
      'stockQuantity': stockQuantity,
      'inStock': inStock,
      'lowStock': lowStock,
      'imageUrl': imageUrl,
      'active': active,
      'featured': featured,
    };
  }

  Product toEntity() => Product(
        id: id,
        categoryId: categoryId,
        categoryName: categoryName,
        sku: sku,
        name: name,
        description: description,
        unit: unit,
        unitName: unitName,
        unitPrice: unitPrice,
        wholesalePrice: wholesalePrice,
        effectivePrice: effectivePrice,
        minOrderQuantity: minOrderQuantity,
        stockQuantity: stockQuantity,
        inStock: inStock,
        lowStock: lowStock,
        imageUrl: imageUrl,
        active: active,
        featured: featured,
      );
}
