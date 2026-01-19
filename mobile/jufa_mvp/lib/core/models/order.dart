class Order {
  final int? id;
  final String orderNumber;
  final int userId;
  final double totalAmount;
  final double shippingFee;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final String deliveryAddress;
  final String? deliveryCity;
  final String? deliveryPhone;
  final String? deliveryNotes;
  final List<OrderItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    this.id,
    required this.orderNumber,
    required this.userId,
    required this.totalAmount,
    this.shippingFee = 0,
    this.status = 'pending',
    required this.paymentMethod,
    this.paymentStatus = 'pending',
    required this.deliveryAddress,
    this.deliveryCity,
    this.deliveryPhone,
    this.deliveryNotes,
    required this.items,
    this.createdAt,
    this.updatedAt,
  });

  double get grandTotal => totalAmount + shippingFee;

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_number': orderNumber,
        'user_id': userId,
        'total_amount': totalAmount,
        'shipping_fee': shippingFee,
        'status': status,
        'payment_method': paymentMethod,
        'payment_status': paymentStatus,
        'delivery_address': deliveryAddress,
        'delivery_city': deliveryCity,
        'delivery_phone': deliveryPhone,
        'delivery_notes': deliveryNotes,
        'items': items.map((item) => item.toJson()).toList(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        orderNumber: json['order_number'],
        userId: json['user_id'],
        totalAmount: (json['total_amount'] as num).toDouble(),
        shippingFee: (json['shipping_fee'] as num?)?.toDouble() ?? 0,
        status: json['status'] ?? 'pending',
        paymentMethod: json['payment_method'],
        paymentStatus: json['payment_status'] ?? 'pending',
        deliveryAddress: json['delivery_address'],
        deliveryCity: json['delivery_city'],
        deliveryPhone: json['delivery_phone'],
        deliveryNotes: json['delivery_notes'],
        items: (json['items'] as List?)
                ?.map((item) => OrderItem.fromJson(item))
                .toList() ??
            [],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
      );
}

class OrderItem {
  final int? id;
  final int productId;
  final String productName;
  final String? productImage;
  final double price;
  final int quantity;
  final String? variant;

  OrderItem({
    this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
    this.variant,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'product_name': productName,
        'product_image': productImage,
        'price': price,
        'quantity': quantity,
        'variant': variant,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json['id'],
        productId: json['product_id'],
        productName: json['product_name'],
        productImage: json['product_image'],
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'],
        variant: json['variant'],
      );
}
