import '../../domain/entities/order_item.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    super.productSku,
    required super.quantity,
    required super.unitPrice,
    super.discountRate,
    required super.lineTotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productSku: json['productSku'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      discountRate: (json['discountRate'] as num?)?.toDouble(),
      lineTotal: (json['lineTotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productSku': productSku,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'discountRate': discountRate,
      'lineTotal': lineTotal,
    };
  }

  OrderItem toEntity() => OrderItem(
        id: id,
        productId: productId,
        productName: productName,
        productSku: productSku,
        quantity: quantity,
        unitPrice: unitPrice,
        discountRate: discountRate,
        lineTotal: lineTotal,
      );
}
