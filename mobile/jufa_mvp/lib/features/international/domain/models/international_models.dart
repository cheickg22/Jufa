// Modèle pour les transferts internationaux
class InternationalTransfer {
  final String id;
  final String userId;
  final String senderName;
  final String senderPhone;
  final String senderAddress;
  final String recipientName;
  final String recipientPhone;
  final String recipientAddress;
  final String recipientEmail;
  final Country sourceCountry;
  final Country destinationCountry;
  final double sendAmount;
  final String sendCurrency;
  final double receiveAmount;
  final String receiveCurrency;
  final double exchangeRate;
  final double fees;
  final double totalCost;
  final TransferMethod transferMethod;
  final PayoutMethod payoutMethod;
  final TransferStatus status;
  final String referenceNumber;
  final String trackingNumber;
  final TransferPurpose purpose;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int estimatedMinutes;
  final List<TransferStatusUpdate> statusUpdates;
  final Map<String, dynamic> metadata;

  const InternationalTransfer({
    required this.id,
    required this.userId,
    required this.senderName,
    required this.senderPhone,
    required this.senderAddress,
    required this.recipientName,
    required this.recipientPhone,
    required this.recipientAddress,
    required this.recipientEmail,
    required this.sourceCountry,
    required this.destinationCountry,
    required this.sendAmount,
    required this.sendCurrency,
    required this.receiveAmount,
    required this.receiveCurrency,
    required this.exchangeRate,
    required this.fees,
    required this.totalCost,
    required this.transferMethod,
    required this.payoutMethod,
    required this.status,
    required this.referenceNumber,
    required this.trackingNumber,
    required this.purpose,
    required this.createdAt,
    this.completedAt,
    required this.estimatedMinutes,
    required this.statusUpdates,
    required this.metadata,
  });

  factory InternationalTransfer.fromJson(Map<String, dynamic> json) {
    return InternationalTransfer(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      senderName: json['sender_name'] ?? '',
      senderPhone: json['sender_phone'] ?? '',
      senderAddress: json['sender_address'] ?? '',
      recipientName: json['recipient_name'] ?? '',
      recipientPhone: json['recipient_phone'] ?? '',
      recipientAddress: json['recipient_address'] ?? '',
      recipientEmail: json['recipient_email'] ?? '',
      sourceCountry: Country.fromJson(json['source_country'] ?? {}),
      destinationCountry: Country.fromJson(json['destination_country'] ?? {}),
      sendAmount: (json['send_amount'] ?? 0.0).toDouble(),
      sendCurrency: json['send_currency'] ?? '',
      receiveAmount: (json['receive_amount'] ?? 0.0).toDouble(),
      receiveCurrency: json['receive_currency'] ?? '',
      exchangeRate: (json['exchange_rate'] ?? 0.0).toDouble(),
      fees: (json['fees'] ?? 0.0).toDouble(),
      totalCost: (json['total_cost'] ?? 0.0).toDouble(),
      transferMethod: TransferMethod.values.firstWhere(
        (method) => method.value == json['transfer_method'],
        orElse: () => TransferMethod.bankTransfer,
      ),
      payoutMethod: PayoutMethod.values.firstWhere(
        (method) => method.value == json['payout_method'],
        orElse: () => PayoutMethod.bankAccount,
      ),
      status: TransferStatus.values.firstWhere(
        (status) => status.value == json['status'],
        orElse: () => TransferStatus.pending,
      ),
      referenceNumber: json['reference_number'] ?? '',
      trackingNumber: json['tracking_number'] ?? '',
      purpose: TransferPurpose.values.firstWhere(
        (purpose) => purpose.value == json['purpose'],
        orElse: () => TransferPurpose.familySupport,
      ),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      estimatedMinutes: json['estimated_minutes'] ?? 60,
      statusUpdates: List<TransferStatusUpdate>.from(
        json['status_updates']?.map((x) => TransferStatusUpdate.fromJson(x)) ?? [],
      ),
      metadata: json['metadata'] ?? {},
    );
  }

  String get formattedSendAmount => '${sendAmount.toStringAsFixed(2)} $sendCurrency';
  String get formattedReceiveAmount => '${receiveAmount.toStringAsFixed(2)} $receiveCurrency';
  String get formattedFees => '${fees.toStringAsFixed(2)} $sendCurrency';
  String get formattedTotalCost => '${totalCost.toStringAsFixed(2)} $sendCurrency';
  String get corridor => '${sourceCountry.code}-${destinationCountry.code}';
}

class Country {
  final String code;
  final String name;
  final String flag;
  final String currency;
  final String currencySymbol;
  final String dialCode;
  final bool isSupported;
  final List<String> supportedPayoutMethods;
  final Map<String, dynamic> regulations;

  const Country({
    required this.code,
    required this.name,
    required this.flag,
    required this.currency,
    required this.currencySymbol,
    required this.dialCode,
    required this.isSupported,
    required this.supportedPayoutMethods,
    required this.regulations,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      flag: json['flag'] ?? '',
      currency: json['currency'] ?? '',
      currencySymbol: json['currency_symbol'] ?? '',
      dialCode: json['dial_code'] ?? '',
      isSupported: json['is_supported'] ?? false,
      supportedPayoutMethods: List<String>.from(json['supported_payout_methods'] ?? []),
      regulations: json['regulations'] ?? {},
    );
  }

  // Pays supportés par défaut
  static const List<Country> supportedCountries = [
    Country(
      code: 'ML',
      name: 'Mali',
      flag: '🇲🇱',
      currency: 'XOF',
      currencySymbol: 'FCFA',
      dialCode: '+223',
      isSupported: true,
      supportedPayoutMethods: ['mobile_money', 'bank_account', 'cash_pickup'],
      regulations: {},
    ),
    Country(
      code: 'FR',
      name: 'France',
      flag: '🇫🇷',
      currency: 'EUR',
      currencySymbol: '€',
      dialCode: '+33',
      isSupported: true,
      supportedPayoutMethods: ['bank_account', 'card'],
      regulations: {},
    ),
    Country(
      code: 'US',
      name: 'États-Unis',
      flag: '🇺🇸',
      currency: 'USD',
      currencySymbol: r'$',
      dialCode: '+1',
      isSupported: true,
      supportedPayoutMethods: ['bank_account', 'card', 'cash_pickup'],
      regulations: {},
    ),
    Country(
      code: 'CA',
      name: 'Canada',
      flag: '🇨🇦',
      currency: 'CAD',
      currencySymbol: r'C$',
      dialCode: '+1',
      isSupported: true,
      supportedPayoutMethods: ['bank_account', 'card'],
      regulations: {},
    ),
  ];
}

enum TransferMethod {
  bankTransfer('bank_transfer', 'Virement bancaire'),
  mobileWallet('mobile_wallet', 'Portefeuille mobile'),
  card('card', 'Carte bancaire'),
  cash('cash', 'Espèces');

  const TransferMethod(this.value, this.displayName);
  final String value;
  final String displayName;
}

enum PayoutMethod {
  bankAccount('bank_account', 'Compte bancaire'),
  mobileWallet('mobile_wallet', 'Portefeuille mobile'),
  cashPickup('cash_pickup', 'Retrait espèces'),
  card('card', 'Carte bancaire');

  const PayoutMethod(this.value, this.displayName);
  final String value;
  final String displayName;
}

enum TransferStatus {
  pending('pending', 'En attente', '🟡'),
  processing('processing', 'En traitement', '🔵'),
  sent('sent', 'Envoyé', '📤'),
  received('received', 'Reçu', '📥'),
  completed('completed', 'Terminé', '✅'),
  cancelled('cancelled', 'Annulé', '❌'),
  failed('failed', 'Échoué', '🔴');

  const TransferStatus(this.value, this.displayName, this.icon);
  final String value;
  final String displayName;
  final String icon;
}

enum TransferPurpose {
  familySupport('family_support', 'Soutien familial'),
  education('education', 'Éducation'),
  medical('medical', 'Médical'),
  business('business', 'Affaires'),
  investment('investment', 'Investissement'),
  gift('gift', 'Cadeau'),
  other('other', 'Autre');

  const TransferPurpose(this.value, this.displayName);
  final String value;
  final String displayName;
}

class TransferStatusUpdate {
  final TransferStatus status;
  final DateTime timestamp;
  final String message;
  final String location;

  const TransferStatusUpdate({
    required this.status,
    required this.timestamp,
    required this.message,
    required this.location,
  });

  factory TransferStatusUpdate.fromJson(Map<String, dynamic> json) {
    return TransferStatusUpdate(
      status: TransferStatus.values.firstWhere(
        (status) => status.value == json['status'],
        orElse: () => TransferStatus.pending,
      ),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      message: json['message'] ?? '',
      location: json['location'] ?? '',
    );
  }
}

// Modèle pour les taux de change
class ExchangeRate {
  final String id;
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final double inverseRate;
  final double margin;
  final DateTime timestamp;
  final DateTime validUntil;
  final String provider;
  final Map<String, dynamic> metadata;

  const ExchangeRate({
    required this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.inverseRate,
    required this.margin,
    required this.timestamp,
    required this.validUntil,
    required this.provider,
    required this.metadata,
  });

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      id: json['id'] ?? '',
      fromCurrency: json['from_currency'] ?? '',
      toCurrency: json['to_currency'] ?? '',
      rate: (json['rate'] ?? 0.0).toDouble(),
      inverseRate: (json['inverse_rate'] ?? 0.0).toDouble(),
      margin: (json['margin'] ?? 0.0).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      validUntil: DateTime.parse(json['valid_until'] ?? DateTime.now().add(const Duration(minutes: 15)).toIso8601String()),
      provider: json['provider'] ?? '',
      metadata: json['metadata'] ?? {},
    );
  }

  bool get isValid => DateTime.now().isBefore(validUntil);
  String get pair => '$fromCurrency/$toCurrency';
  double convert(double amount) => amount * rate;
}

// Modèle pour les cartes de voyage
class TravelCard {
  final String id;
  final String userId;
  final String cardNumber;
  final String maskedCardNumber;
  final String cardholderName;
  final String expiryDate;
  final String cvv;
  final CardType cardType;
  final CardStatus status;
  final List<String> supportedCurrencies;
  final Map<String, double> balances;
  final String primaryCurrency;
  final double totalBalance;
  final Map<String, double> spendingLimits;
  final Map<String, double> withdrawalLimits;
  final bool isContactless;
  final bool isVirtual;
  final DateTime issuedDate;
  final DateTime expiryDateTime;
  final List<CardTransaction> recentTransactions;
  final CardSettings settings;

  const TravelCard({
    required this.id,
    required this.userId,
    required this.cardNumber,
    required this.maskedCardNumber,
    required this.cardholderName,
    required this.expiryDate,
    required this.cvv,
    required this.cardType,
    required this.status,
    required this.supportedCurrencies,
    required this.balances,
    required this.primaryCurrency,
    required this.totalBalance,
    required this.spendingLimits,
    required this.withdrawalLimits,
    required this.isContactless,
    required this.isVirtual,
    required this.issuedDate,
    required this.expiryDateTime,
    required this.recentTransactions,
    required this.settings,
  });

  factory TravelCard.fromJson(Map<String, dynamic> json) {
    return TravelCard(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      cardNumber: json['card_number'] ?? '',
      maskedCardNumber: json['masked_card_number'] ?? '',
      cardholderName: json['cardholder_name'] ?? '',
      expiryDate: json['expiry_date'] ?? '',
      cvv: json['cvv'] ?? '',
      cardType: CardType.values.firstWhere(
        (type) => type.value == json['card_type'],
        orElse: () => CardType.visa,
      ),
      status: CardStatus.values.firstWhere(
        (status) => status.value == json['status'],
        orElse: () => CardStatus.active,
      ),
      supportedCurrencies: List<String>.from(json['supported_currencies'] ?? []),
      balances: Map<String, double>.from(
        json['balances']?.map((k, v) => MapEntry(k, (v ?? 0.0).toDouble())) ?? {},
      ),
      primaryCurrency: json['primary_currency'] ?? 'XOF',
      totalBalance: (json['total_balance'] ?? 0.0).toDouble(),
      spendingLimits: Map<String, double>.from(
        json['spending_limits']?.map((k, v) => MapEntry(k, (v ?? 0.0).toDouble())) ?? {},
      ),
      withdrawalLimits: Map<String, double>.from(
        json['withdrawal_limits']?.map((k, v) => MapEntry(k, (v ?? 0.0).toDouble())) ?? {},
      ),
      isContactless: json['is_contactless'] ?? true,
      isVirtual: json['is_virtual'] ?? false,
      issuedDate: DateTime.parse(json['issued_date'] ?? DateTime.now().toIso8601String()),
      expiryDateTime: DateTime.parse(json['expiry_date_time'] ?? DateTime.now().add(const Duration(days: 1095)).toIso8601String()),
      recentTransactions: List<CardTransaction>.from(
        json['recent_transactions']?.map((x) => CardTransaction.fromJson(x)) ?? [],
      ),
      settings: CardSettings.fromJson(json['settings'] ?? {}),
    );
  }

  double getBalance(String currency) => balances[currency] ?? 0.0;
  bool isExpired() => DateTime.now().isAfter(expiryDateTime);
  bool isActive() => status == CardStatus.active && !isExpired();
}

enum CardType {
  visa('visa', 'Visa'),
  mastercard('mastercard', 'Mastercard');

  const CardType(this.value, this.displayName);
  final String value;
  final String displayName;
}

enum CardStatus {
  active('active', 'Active'),
  blocked('blocked', 'Bloquée'),
  expired('expired', 'Expirée'),
  cancelled('cancelled', 'Annulée');

  const CardStatus(this.value, this.displayName);
  final String value;
  final String displayName;
}

class CardTransaction {
  final String id;
  final String cardId;
  final double amount;
  final String currency;
  final String merchantName;
  final String merchantCategory;
  final String location;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const CardTransaction({
    required this.id,
    required this.cardId,
    required this.amount,
    required this.currency,
    required this.merchantName,
    required this.merchantCategory,
    required this.location,
    required this.type,
    required this.status,
    required this.timestamp,
    required this.metadata,
  });

  factory CardTransaction.fromJson(Map<String, dynamic> json) {
    return CardTransaction(
      id: json['id'] ?? '',
      cardId: json['card_id'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? '',
      merchantName: json['merchant_name'] ?? '',
      merchantCategory: json['merchant_category'] ?? '',
      location: json['location'] ?? '',
      type: TransactionType.values.firstWhere(
        (type) => type.value == json['type'],
        orElse: () => TransactionType.purchase,
      ),
      status: TransactionStatus.values.firstWhere(
        (status) => status.value == json['status'],
        orElse: () => TransactionStatus.completed,
      ),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      metadata: json['metadata'] ?? {},
    );
  }

  String get formattedAmount => '${amount.toStringAsFixed(2)} $currency';
}

enum TransactionType {
  purchase('purchase', 'Achat'),
  withdrawal('withdrawal', 'Retrait'),
  refund('refund', 'Remboursement'),
  fee('fee', 'Frais');

  const TransactionType(this.value, this.displayName);
  final String value;
  final String displayName;
}

enum TransactionStatus {
  pending('pending', 'En attente'),
  completed('completed', 'Terminé'),
  failed('failed', 'Échoué'),
  cancelled('cancelled', 'Annulé');

  const TransactionStatus(this.value, this.displayName);
  final String value;
  final String displayName;
}

class CardSettings {
  final bool isOnlinePaymentEnabled;
  final bool isContactlessEnabled;
  final bool isAtmWithdrawalEnabled;
  final bool isInternationalEnabled;
  final Map<String, bool> categoryRestrictions;
  final Map<String, double> dailyLimits;
  final Map<String, double> monthlyLimits;
  final bool notificationsEnabled;
  final String preferredCurrency;

  const CardSettings({
    required this.isOnlinePaymentEnabled,
    required this.isContactlessEnabled,
    required this.isAtmWithdrawalEnabled,
    required this.isInternationalEnabled,
    required this.categoryRestrictions,
    required this.dailyLimits,
    required this.monthlyLimits,
    required this.notificationsEnabled,
    required this.preferredCurrency,
  });

  factory CardSettings.fromJson(Map<String, dynamic> json) {
    return CardSettings(
      isOnlinePaymentEnabled: json['is_online_payment_enabled'] ?? true,
      isContactlessEnabled: json['is_contactless_enabled'] ?? true,
      isAtmWithdrawalEnabled: json['is_atm_withdrawal_enabled'] ?? true,
      isInternationalEnabled: json['is_international_enabled'] ?? true,
      categoryRestrictions: Map<String, bool>.from(json['category_restrictions'] ?? {}),
      dailyLimits: Map<String, double>.from(
        json['daily_limits']?.map((k, v) => MapEntry(k, (v ?? 0.0).toDouble())) ?? {},
      ),
      monthlyLimits: Map<String, double>.from(
        json['monthly_limits']?.map((k, v) => MapEntry(k, (v ?? 0.0).toDouble())) ?? {},
      ),
      notificationsEnabled: json['notifications_enabled'] ?? true,
      preferredCurrency: json['preferred_currency'] ?? 'XOF',
    );
  }
}

// Modèle pour les remittances (envois diaspora)
class RemittanceService {
  final String id;
  final String name;
  final String description;
  final List<String> supportedCorridors;
  final Map<String, double> fees;
  final Map<String, ExchangeRate> rates;
  final List<PayoutMethod> payoutMethods;
  final int averageDeliveryMinutes;
  final double rating;
  final bool isActive;
  final Map<String, dynamic> requirements;

  const RemittanceService({
    required this.id,
    required this.name,
    required this.description,
    required this.supportedCorridors,
    required this.fees,
    required this.rates,
    required this.payoutMethods,
    required this.averageDeliveryMinutes,
    required this.rating,
    required this.isActive,
    required this.requirements,
  });

  factory RemittanceService.fromJson(Map<String, dynamic> json) {
    return RemittanceService(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      supportedCorridors: List<String>.from(json['supported_corridors'] ?? []),
      fees: Map<String, double>.from(
        json['fees']?.map((k, v) => MapEntry(k, (v ?? 0.0).toDouble())) ?? {},
      ),
      rates: Map<String, ExchangeRate>.from(
        json['rates']?.map((k, v) => MapEntry(k, ExchangeRate.fromJson(v))) ?? {},
      ),
      payoutMethods: List<PayoutMethod>.from(
        json['payout_methods']?.map((x) => PayoutMethod.values.firstWhere(
          (method) => method.value == x,
          orElse: () => PayoutMethod.bankAccount,
        )) ?? [],
      ),
      averageDeliveryMinutes: json['average_delivery_minutes'] ?? 60,
      rating: (json['rating'] ?? 0.0).toDouble(),
      isActive: json['is_active'] ?? true,
      requirements: json['requirements'] ?? {},
    );
  }

  double getFee(String corridor) => fees[corridor] ?? 0.0;
  ExchangeRate? getRate(String pair) => rates[pair];
  bool supportsCorridor(String corridor) => supportedCorridors.contains(corridor);
}

// Modèle pour les corridors de transfert optimisés
class TransferCorridor {
  final String id;
  final Country sourceCountry;
  final Country destinationCountry;
  final List<String> supportedCurrencies;
  final Map<String, double> exchangeRates;
  final Map<String, double> fees;
  final List<PayoutMethod> availablePayoutMethods;
  final int averageDeliveryTime;
  final double volume24h;
  final bool isPopular;
  final List<String> regulations;
  final Map<String, dynamic> limits;

  const TransferCorridor({
    required this.id,
    required this.sourceCountry,
    required this.destinationCountry,
    required this.supportedCurrencies,
    required this.exchangeRates,
    required this.fees,
    required this.availablePayoutMethods,
    required this.averageDeliveryTime,
    required this.volume24h,
    required this.isPopular,
    required this.regulations,
    required this.limits,
  });

  factory TransferCorridor.fromJson(Map<String, dynamic> json) {
    return TransferCorridor(
      id: json['id'] ?? '',
      sourceCountry: Country.fromJson(json['source_country'] ?? {}),
      destinationCountry: Country.fromJson(json['destination_country'] ?? {}),
      supportedCurrencies: List<String>.from(json['supported_currencies'] ?? []),
      exchangeRates: Map<String, double>.from(
        json['exchange_rates']?.map((k, v) => MapEntry(k, (v ?? 0.0).toDouble())) ?? {},
      ),
      fees: Map<String, double>.from(
        json['fees']?.map((k, v) => MapEntry(k, (v ?? 0.0).toDouble())) ?? {},
      ),
      availablePayoutMethods: List<PayoutMethod>.from(
        json['available_payout_methods']?.map((x) => PayoutMethod.values.firstWhere(
          (method) => method.value == x,
          orElse: () => PayoutMethod.bankAccount,
        )) ?? [],
      ),
      averageDeliveryTime: json['average_delivery_time'] ?? 60,
      volume24h: (json['volume_24h'] ?? 0.0).toDouble(),
      isPopular: json['is_popular'] ?? false,
      regulations: List<String>.from(json['regulations'] ?? []),
      limits: json['limits'] ?? {},
    );
  }

  String get name => '${sourceCountry.name} → ${destinationCountry.name}';
  String get code => '${sourceCountry.code}-${destinationCountry.code}';
  double getExchangeRate(String currencyPair) => exchangeRates[currencyPair] ?? 0.0;
  double getFee(String method) => fees[method] ?? 0.0;
}
