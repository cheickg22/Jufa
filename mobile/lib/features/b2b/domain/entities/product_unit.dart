enum ProductUnit {
  piece,
  carton,
  pack,
  kg,
  litre,
  sack,
  box;

  String get displayName {
    switch (this) {
      case ProductUnit.piece:
        return 'Pièce';
      case ProductUnit.carton:
        return 'Carton';
      case ProductUnit.pack:
        return 'Pack';
      case ProductUnit.kg:
        return 'Kilogramme';
      case ProductUnit.litre:
        return 'Litre';
      case ProductUnit.sack:
        return 'Sac';
      case ProductUnit.box:
        return 'Boîte';
    }
  }

  static ProductUnit fromString(String value) {
    return ProductUnit.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => ProductUnit.piece,
    );
  }
}
