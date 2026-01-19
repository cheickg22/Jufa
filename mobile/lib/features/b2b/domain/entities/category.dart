class Category {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int displayOrder;
  final bool active;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.displayOrder = 0,
    this.active = true,
  });

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? displayOrder,
    bool? active,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      displayOrder: displayOrder ?? this.displayOrder,
      active: active ?? this.active,
    );
  }
}
