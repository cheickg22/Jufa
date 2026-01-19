// Modèle pour les produits e-commerce
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final String currency;
  final List<String> images;
  final String category;
  final String subcategory;
  final String brand;
  final String merchantId;
  final String merchantName;
  final ProductStatus status;
  final int stockQuantity;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final Map<String, dynamic> attributes;
  final ShippingInfo shippingInfo;
  final double cashbackPercentage;
  final int loyaltyPoints;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.currency,
    required this.images,
    required this.category,
    required this.subcategory,
    required this.brand,
    required this.merchantId,
    required this.merchantName,
    required this.status,
    required this.stockQuantity,
    required this.rating,
    required this.reviewCount,
    required this.tags,
    required this.attributes,
    required this.shippingInfo,
    required this.cashbackPercentage,
    required this.loyaltyPoints,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      originalPrice: (json['original_price'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'FCFA',
      images: List<String>.from(json['images'] ?? []),
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      brand: json['brand'] ?? '',
      merchantId: json['merchant_id'] ?? '',
      merchantName: json['merchant_name'] ?? '',
      status: ProductStatus.values.firstWhere(
        (status) => status.value == json['status'],
        orElse: () => ProductStatus.active,
      ),
      stockQuantity: json['stock_quantity'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      attributes: json['attributes'] ?? {},
      shippingInfo: ShippingInfo.fromJson(json['shipping_info'] ?? {}),
      cashbackPercentage: (json['cashback_percentage'] ?? 0.0).toDouble(),
      loyaltyPoints: json['loyalty_points'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  bool get isOnSale => originalPrice > price;
  double get discountPercentage => isOnSale ? ((originalPrice - price) / originalPrice) * 100 : 0;
  bool get isInStock => stockQuantity > 0;
  String get formattedPrice => '${price.toStringAsFixed(0)} $currency';
  String get formattedOriginalPrice => '${originalPrice.toStringAsFixed(0)} $currency';
}

enum ProductStatus {
  active('active', 'Actif'),
  inactive('inactive', 'Inactif'),
  outOfStock('out_of_stock', 'Rupture de stock'),
  discontinued('discontinued', 'Arrêté');

  const ProductStatus(this.value, this.displayName);
  final String value;
  final String displayName;
}

class ShippingInfo {
  final bool freeShipping;
  final double shippingCost;
  final int estimatedDays;
  final List<String> availableRegions;
  final String shippingMethod;

  const ShippingInfo({
    required this.freeShipping,
    required this.shippingCost,
    required this.estimatedDays,
    required this.availableRegions,
    required this.shippingMethod,
  });

  factory ShippingInfo.fromJson(Map<String, dynamic> json) {
    return ShippingInfo(
      freeShipping: json['free_shipping'] ?? false,
      shippingCost: (json['shipping_cost'] ?? 0.0).toDouble(),
      estimatedDays: json['estimated_days'] ?? 3,
      availableRegions: List<String>.from(json['available_regions'] ?? []),
      shippingMethod: json['shipping_method'] ?? 'Standard',
    );
  }
}

// Modèle pour les commandes e-commerce
class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double shippingCost;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String currency;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final ShippingAddress shippingAddress;
  final BillingAddress billingAddress;
  final DateTime orderDate;
  final DateTime? shippedDate;
  final DateTime? deliveredDate;
  final String trackingNumber;
  final double cashbackEarned;
  final int loyaltyPointsEarned;
  final List<OrderStatusHistory> statusHistory;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    required this.shippingAddress,
    required this.billingAddress,
    required this.orderDate,
    this.shippedDate,
    this.deliveredDate,
    required this.trackingNumber,
    required this.cashbackEarned,
    required this.loyaltyPointsEarned,
    required this.statusHistory,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      items: List<OrderItem>.from(
        json['items']?.map((x) => OrderItem.fromJson(x)) ?? [],
      ),
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      shippingCost: (json['shipping_cost'] ?? 0.0).toDouble(),
      taxAmount: (json['tax_amount'] ?? 0.0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0.0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'FCFA',
      status: OrderStatus.values.firstWhere(
        (status) => status.value == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentMethod: PaymentMethod.fromJson(json['payment_method'] ?? {}),
      shippingAddress: ShippingAddress.fromJson(json['shipping_address'] ?? {}),
      billingAddress: BillingAddress.fromJson(json['billing_address'] ?? {}),
      orderDate: DateTime.parse(json['order_date'] ?? DateTime.now().toIso8601String()),
      shippedDate: json['shipped_date'] != null ? DateTime.parse(json['shipped_date']) : null,
      deliveredDate: json['delivered_date'] != null ? DateTime.parse(json['delivered_date']) : null,
      trackingNumber: json['tracking_number'] ?? '',
      cashbackEarned: (json['cashback_earned'] ?? 0.0).toDouble(),
      loyaltyPointsEarned: json['loyalty_points_earned'] ?? 0,
      statusHistory: List<OrderStatusHistory>.from(
        json['status_history']?.map((x) => OrderStatusHistory.fromJson(x)) ?? [],
      ),
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String merchantId;
  final String merchantName;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.merchantId,
    required this.merchantName,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      productImage: json['product_image'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unit_price'] ?? 0.0).toDouble(),
      totalPrice: (json['total_price'] ?? 0.0).toDouble(),
      merchantId: json['merchant_id'] ?? '',
      merchantName: json['merchant_name'] ?? '',
    );
  }
}

enum OrderStatus {
  pending('pending', 'En attente', '🟡'),
  confirmed('confirmed', 'Confirmée', '🟢'),
  processing('processing', 'En traitement', '🔵'),
  shipped('shipped', 'Expédiée', '📦'),
  delivered('delivered', 'Livrée', '✅'),
  cancelled('cancelled', 'Annulée', '❌'),
  refunded('refunded', 'Remboursée', '💰');

  const OrderStatus(this.value, this.displayName, this.icon);
  final String value;
  final String displayName;
  final String icon;
}

class PaymentMethod {
  final String type;
  final String provider;
  final Map<String, dynamic> details;

  const PaymentMethod({
    required this.type,
    required this.provider,
    required this.details,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      type: json['type'] ?? 'jufa_wallet',
      provider: json['provider'] ?? 'Jufa',
      details: json['details'] ?? {},
    );
  }
}

class ShippingAddress {
  final String fullName;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String region;
  final String postalCode;
  final String country;
  final String phoneNumber;

  const ShippingAddress({
    required this.fullName,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.region,
    required this.postalCode,
    required this.country,
    required this.phoneNumber,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      fullName: json['full_name'] ?? '',
      addressLine1: json['address_line_1'] ?? '',
      addressLine2: json['address_line_2'] ?? '',
      city: json['city'] ?? '',
      region: json['region'] ?? '',
      postalCode: json['postal_code'] ?? '',
      country: json['country'] ?? 'Mali',
      phoneNumber: json['phone_number'] ?? '',
    );
  }
}

class BillingAddress {
  final String fullName;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String region;
  final String postalCode;
  final String country;

  const BillingAddress({
    required this.fullName,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.region,
    required this.postalCode,
    required this.country,
  });

  factory BillingAddress.fromJson(Map<String, dynamic> json) {
    return BillingAddress(
      fullName: json['full_name'] ?? '',
      addressLine1: json['address_line_1'] ?? '',
      addressLine2: json['address_line_2'] ?? '',
      city: json['city'] ?? '',
      region: json['region'] ?? '',
      postalCode: json['postal_code'] ?? '',
      country: json['country'] ?? 'Mali',
    );
  }
}

class OrderStatusHistory {
  final OrderStatus status;
  final DateTime timestamp;
  final String note;

  const OrderStatusHistory({
    required this.status,
    required this.timestamp,
    required this.note,
  });

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistory(
      status: OrderStatus.values.firstWhere(
        (status) => status.value == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      note: json['note'] ?? '',
    );
  }
}

// Modèle pour le système de fidélité
class LoyaltyProgram {
  final String id;
  final String userId;
  final int totalPoints;
  final int availablePoints;
  final int usedPoints;
  final LoyaltyTier currentTier;
  final int pointsToNextTier;
  final double totalCashbackEarned;
  final List<PointTransaction> recentTransactions;
  final List<Reward> availableRewards;
  final DateTime joinDate;
  final DateTime lastActivity;

  const LoyaltyProgram({
    required this.id,
    required this.userId,
    required this.totalPoints,
    required this.availablePoints,
    required this.usedPoints,
    required this.currentTier,
    required this.pointsToNextTier,
    required this.totalCashbackEarned,
    required this.recentTransactions,
    required this.availableRewards,
    required this.joinDate,
    required this.lastActivity,
  });

  factory LoyaltyProgram.fromJson(Map<String, dynamic> json) {
    return LoyaltyProgram(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      totalPoints: json['total_points'] ?? 0,
      availablePoints: json['available_points'] ?? 0,
      usedPoints: json['used_points'] ?? 0,
      currentTier: LoyaltyTier.values.firstWhere(
        (tier) => tier.value == json['current_tier'],
        orElse: () => LoyaltyTier.bronze,
      ),
      pointsToNextTier: json['points_to_next_tier'] ?? 0,
      totalCashbackEarned: (json['total_cashback_earned'] ?? 0.0).toDouble(),
      recentTransactions: List<PointTransaction>.from(
        json['recent_transactions']?.map((x) => PointTransaction.fromJson(x)) ?? [],
      ),
      availableRewards: List<Reward>.from(
        json['available_rewards']?.map((x) => Reward.fromJson(x)) ?? [],
      ),
      joinDate: DateTime.parse(json['join_date'] ?? DateTime.now().toIso8601String()),
      lastActivity: DateTime.parse(json['last_activity'] ?? DateTime.now().toIso8601String()),
    );
  }
}

enum LoyaltyTier {
  bronze('bronze', 'Bronze', '🥉', 0),
  silver('silver', 'Argent', '🥈', 1000),
  gold('gold', 'Or', '🥇', 5000),
  platinum('platinum', 'Platine', '💎', 15000);

  const LoyaltyTier(this.value, this.displayName, this.icon, this.requiredPoints);
  final String value;
  final String displayName;
  final String icon;
  final int requiredPoints;
}

class PointTransaction {
  final String id;
  final PointTransactionType type;
  final int points;
  final String description;
  final String source;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const PointTransaction({
    required this.id,
    required this.type,
    required this.points,
    required this.description,
    required this.source,
    required this.timestamp,
    required this.metadata,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'] ?? '',
      type: PointTransactionType.values.firstWhere(
        (type) => type.value == json['type'],
        orElse: () => PointTransactionType.earned,
      ),
      points: json['points'] ?? 0,
      description: json['description'] ?? '',
      source: json['source'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      metadata: json['metadata'] ?? {},
    );
  }
}

enum PointTransactionType {
  earned('earned', 'Gagné', '➕'),
  redeemed('redeemed', 'Utilisé', '➖'),
  expired('expired', 'Expiré', '⏰'),
  bonus('bonus', 'Bonus', '🎁');

  const PointTransactionType(this.value, this.displayName, this.icon);
  final String value;
  final String displayName;
  final String icon;
}

class Reward {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final RewardType type;
  final String imageUrl;
  final Map<String, dynamic> details;
  final DateTime expiryDate;
  final bool isAvailable;
  final int maxRedemptions;
  final int currentRedemptions;

  const Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.type,
    required this.imageUrl,
    required this.details,
    required this.expiryDate,
    required this.isAvailable,
    required this.maxRedemptions,
    required this.currentRedemptions,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      pointsCost: json['points_cost'] ?? 0,
      type: RewardType.values.firstWhere(
        (type) => type.value == json['type'],
        orElse: () => RewardType.discount,
      ),
      imageUrl: json['image_url'] ?? '',
      details: json['details'] ?? {},
      expiryDate: DateTime.parse(json['expiry_date'] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String()),
      isAvailable: json['is_available'] ?? true,
      maxRedemptions: json['max_redemptions'] ?? -1,
      currentRedemptions: json['current_redemptions'] ?? 0,
    );
  }

  bool get canRedeem => isAvailable && (maxRedemptions == -1 || currentRedemptions < maxRedemptions);
}

enum RewardType {
  discount('discount', 'Réduction', '💰'),
  freeShipping('free_shipping', 'Livraison gratuite', '📦'),
  cashback('cashback', 'Cashback', '💸'),
  product('product', 'Produit gratuit', '🎁'),
  experience('experience', 'Expérience', '🎪');

  const RewardType(this.value, this.displayName, this.icon);
  final String value;
  final String displayName;
  final String icon;
}

// Modèle pour les marchands/partenaires
class Merchant {
  final String id;
  final String name;
  final String description;
  final String logoUrl;
  final String bannerUrl;
  final MerchantCategory category;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final bool isPartner;
  final double cashbackRate;
  final int loyaltyPointsRate;
  final List<String> paymentMethods;
  final ContactInfo contactInfo;
  final BusinessHours businessHours;
  final List<String> certifications;
  final DateTime joinDate;

  const Merchant({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.bannerUrl,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.isPartner,
    required this.cashbackRate,
    required this.loyaltyPointsRate,
    required this.paymentMethods,
    required this.contactInfo,
    required this.businessHours,
    required this.certifications,
    required this.joinDate,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      logoUrl: json['logo_url'] ?? '',
      bannerUrl: json['banner_url'] ?? '',
      category: MerchantCategory.values.firstWhere(
        (category) => category.value == json['category'],
        orElse: () => MerchantCategory.general,
      ),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      isPartner: json['is_partner'] ?? false,
      cashbackRate: (json['cashback_rate'] ?? 0.0).toDouble(),
      loyaltyPointsRate: json['loyalty_points_rate'] ?? 0,
      paymentMethods: List<String>.from(json['payment_methods'] ?? []),
      contactInfo: ContactInfo.fromJson(json['contact_info'] ?? {}),
      businessHours: BusinessHours.fromJson(json['business_hours'] ?? {}),
      certifications: List<String>.from(json['certifications'] ?? []),
      joinDate: DateTime.parse(json['join_date'] ?? DateTime.now().toIso8601String()),
    );
  }
}

enum MerchantCategory {
  general('general', 'Général'),
  electronics('electronics', 'Électronique'),
  fashion('fashion', 'Mode'),
  food('food', 'Alimentation'),
  health('health', 'Santé'),
  services('services', 'Services'),
  telecom('telecom', 'Télécoms'),
  insurance('insurance', 'Assurance'),
  utilities('utilities', 'Utilities');

  const MerchantCategory(this.value, this.displayName);
  final String value;
  final String displayName;
}

class ContactInfo {
  final String email;
  final String phone;
  final String website;
  final String address;

  const ContactInfo({
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      website: json['website'] ?? '',
      address: json['address'] ?? '',
    );
  }
}

class BusinessHours {
  final Map<String, String> hours;
  final bool isOpen24x7;
  final List<String> holidays;

  const BusinessHours({
    required this.hours,
    required this.isOpen24x7,
    required this.holidays,
  });

  factory BusinessHours.fromJson(Map<String, dynamic> json) {
    return BusinessHours(
      hours: Map<String, String>.from(json['hours'] ?? {}),
      isOpen24x7: json['is_open_24x7'] ?? false,
      holidays: List<String>.from(json['holidays'] ?? []),
    );
  }
}
