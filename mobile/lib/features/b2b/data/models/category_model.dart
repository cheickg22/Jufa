import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    super.description,
    super.imageUrl,
    super.displayOrder,
    super.active,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      displayOrder: json['displayOrder'] as int? ?? 0,
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'displayOrder': displayOrder,
      'active': active,
    };
  }

  Category toEntity() => Category(
        id: id,
        name: name,
        description: description,
        imageUrl: imageUrl,
        displayOrder: displayOrder,
        active: active,
      );
}
