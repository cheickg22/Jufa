class VirtualCard {
  final String id;
  final String userId;
  final String accountId;
  final String cardNumber;
  final String maskedCardNumber;
  final String expiryDate;
  final String cvv;
  final String cardholderName;
  final CardType cardType;
  final CardStatus status;
  final double spendingLimit;
  final double dailyLimit;
  final double monthlyLimit;
  final String currency;
  final DateTime createdAt;
  final DateTime? activatedAt;
  final Map<String, dynamic> settings;

  const VirtualCard({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.cardNumber,
    required this.maskedCardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.cardholderName,
    required this.cardType,
    required this.status,
    required this.spendingLimit,
    required this.dailyLimit,
    required this.monthlyLimit,
    required this.currency,
    required this.createdAt,
    this.activatedAt,
    this.settings = const {},
  });

  factory VirtualCard.fromJson(Map<String, dynamic> json) {
    return VirtualCard(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      accountId: json['account_id'] ?? '',
      cardNumber: json['card_number'] ?? '',
      maskedCardNumber: json['masked_card_number'] ?? '',
      expiryDate: json['expiry_date'] ?? '',
      cvv: json['cvv'] ?? '',
      cardholderName: json['cardholder_name'] ?? '',
      cardType: CardType.values.firstWhere(
        (type) => type.value == json['card_type'],
        orElse: () => CardType.visa,
      ),
      status: CardStatus.values.firstWhere(
        (status) => status.value == json['status'],
        orElse: () => CardStatus.pending,
      ),
      spendingLimit: (json['spending_limit'] ?? 0.0).toDouble(),
      dailyLimit: (json['daily_limit'] ?? 0.0).toDouble(),
      monthlyLimit: (json['monthly_limit'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'FCFA',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      activatedAt: json['activated_at'] != null ? DateTime.parse(json['activated_at']) : null,
      settings: json['settings'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'account_id': accountId,
      'card_number': cardNumber,
      'masked_card_number': maskedCardNumber,
      'expiry_date': expiryDate,
      'cvv': cvv,
      'cardholder_name': cardholderName,
      'card_type': cardType.value,
      'status': status.value,
      'spending_limit': spendingLimit,
      'daily_limit': dailyLimit,
      'monthly_limit': monthlyLimit,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
      'activated_at': activatedAt?.toIso8601String(),
      'settings': settings,
    };
  }

  // Méthodes utilitaires
  bool get isActive => status == CardStatus.active;
  bool get isBlocked => status == CardStatus.blocked;
  bool get isExpired => DateTime.now().isAfter(DateTime.parse('20${expiryDate.split('/')[1]}-${expiryDate.split('/')[0]}-01'));
  
  String get displayCardNumber => maskedCardNumber;
  String get cardBrand => cardType.displayName;
  String get statusText => status.displayName;
  
  VirtualCard copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? cardNumber,
    String? maskedCardNumber,
    String? expiryDate,
    String? cvv,
    String? cardholderName,
    CardType? cardType,
    CardStatus? status,
    double? spendingLimit,
    double? dailyLimit,
    double? monthlyLimit,
    String? currency,
    DateTime? createdAt,
    DateTime? activatedAt,
    Map<String, dynamic>? settings,
  }) {
    return VirtualCard(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      cardNumber: cardNumber ?? this.cardNumber,
      maskedCardNumber: maskedCardNumber ?? this.maskedCardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      cardholderName: cardholderName ?? this.cardholderName,
      cardType: cardType ?? this.cardType,
      status: status ?? this.status,
      spendingLimit: spendingLimit ?? this.spendingLimit,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      activatedAt: activatedAt ?? this.activatedAt,
      settings: settings ?? this.settings,
    );
  }
}

// Types de cartes
enum CardType {
  visa('visa', 'Visa', '💳'),
  mastercard('mastercard', 'Mastercard', '💳'),
  amex('amex', 'American Express', '💳');

  const CardType(this.value, this.displayName, this.icon);
  final String value;
  final String displayName;
  final String icon;
}

// Statuts de carte
enum CardStatus {
  pending('pending', 'En attente', '⏳'),
  active('active', 'Active', '✅'),
  blocked('blocked', 'Bloquée', '🚫'),
  expired('expired', 'Expirée', '⏰'),
  cancelled('cancelled', 'Annulée', '❌');

  const CardStatus(this.value, this.displayName, this.icon);
  final String value;
  final String displayName;
  final String icon;
}

// Paramètres de carte
class CardSettings {
  final bool onlinePayments;
  final bool contactlessPayments;
  final bool atmWithdrawals;
  final bool internationalPayments;
  final List<String> blockedMerchants;
  final List<String> allowedCountries;

  const CardSettings({
    this.onlinePayments = true,
    this.contactlessPayments = true,
    this.atmWithdrawals = true,
    this.internationalPayments = false,
    this.blockedMerchants = const [],
    this.allowedCountries = const [],
  });

  factory CardSettings.fromJson(Map<String, dynamic> json) {
    return CardSettings(
      onlinePayments: json['online_payments'] ?? true,
      contactlessPayments: json['contactless_payments'] ?? true,
      atmWithdrawals: json['atm_withdrawals'] ?? true,
      internationalPayments: json['international_payments'] ?? false,
      blockedMerchants: List<String>.from(json['blocked_merchants'] ?? []),
      allowedCountries: List<String>.from(json['allowed_countries'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'online_payments': onlinePayments,
      'contactless_payments': contactlessPayments,
      'atm_withdrawals': atmWithdrawals,
      'international_payments': internationalPayments,
      'blocked_merchants': blockedMerchants,
      'allowed_countries': allowedCountries,
    };
  }
}
