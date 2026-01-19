class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String? productSku;
  final int quantity;
  final double unitPrice;
  final double? discountRate;
  final double lineTotal;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productSku,
    required this.quantity,
    required this.unitPrice,
    this.discountRate,
    required this.lineTotal,
  });

  OrderItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productSku,
    int? quantity,
    double? unitPrice,
    double? discountRate,
    double? lineTotal,
  }) {
    return OrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discountRate: discountRate ?? this.discountRate,
      lineTotal: lineTotal ?? this.lineTotal,
    );
  }
}
