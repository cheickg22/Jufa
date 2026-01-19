class CartItem {
  final int productId;
  final String productName;
  final String productImage;
  final double price;
  int quantity;
  final String? variant;
  final int? sellerId;

  CartItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    this.quantity = 1,
    this.variant,
    this.sellerId,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'product_name': productName,
        'product_image': productImage,
        'price': price,
        'quantity': quantity,
        'variant': variant,
        'seller_id': sellerId,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        productId: json['product_id'],
        productName: json['product_name'],
        productImage: json['product_image'],
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'],
        variant: json['variant'],
        sellerId: json['seller_id'],
      );

  CartItem copyWith({
    int? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    String? variant,
    int? sellerId,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      variant: variant ?? this.variant,
      sellerId: sellerId ?? this.sellerId,
    );
  }
}
