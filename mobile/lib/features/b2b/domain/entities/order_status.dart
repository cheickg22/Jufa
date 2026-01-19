enum OrderStatus {
  draft,
  pending,
  confirmed,
  processing,
  ready,
  shipped,
  delivered,
  cancelled,
  refunded;

  String get displayName {
    switch (this) {
      case OrderStatus.draft:
        return 'Brouillon';
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.confirmed:
        return 'Confirmée';
      case OrderStatus.processing:
        return 'En préparation';
      case OrderStatus.ready:
        return 'Prête';
      case OrderStatus.shipped:
        return 'Expédiée';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
      case OrderStatus.refunded:
        return 'Remboursée';
    }
  }

  bool get canCancel {
    return this == OrderStatus.draft ||
        this == OrderStatus.pending ||
        this == OrderStatus.confirmed;
  }

  bool get canModify {
    return this == OrderStatus.draft || this == OrderStatus.pending;
  }

  bool get isTerminal {
    return this == OrderStatus.delivered ||
        this == OrderStatus.cancelled ||
        this == OrderStatus.refunded;
  }

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => OrderStatus.pending,
    );
  }
}
