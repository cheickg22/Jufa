class VirtualAccount {
  final String id;
  final String userId;
  final String accountNumber;
  final String iban;
  final String currency;
  final double balance;
  final String accountType;
  final DateTime createdAt;
  final bool isActive;
  final Map<String, dynamic> metadata;

  const VirtualAccount({
    required this.id,
    required this.userId,
    required this.accountNumber,
    required this.iban,
    required this.currency,
    required this.balance,
    required this.accountType,
    required this.createdAt,
    required this.isActive,
    this.metadata = const {},
  });

  factory VirtualAccount.fromJson(Map<String, dynamic> json) {
    return VirtualAccount(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      accountNumber: json['account_number'] ?? '',
      iban: json['iban'] ?? '',
      currency: json['currency'] ?? 'FCFA',
      balance: (json['balance'] ?? 0.0).toDouble(),
      accountType: json['account_type'] ?? 'standard',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      isActive: json['is_active'] ?? true,
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'account_number': accountNumber,
      'iban': iban,
      'currency': currency,
      'balance': balance,
      'account_type': accountType,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
      'metadata': metadata,
    };
  }

  VirtualAccount copyWith({
    String? id,
    String? userId,
    String? accountNumber,
    String? iban,
    String? currency,
    double? balance,
    String? accountType,
    DateTime? createdAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return VirtualAccount(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountNumber: accountNumber ?? this.accountNumber,
      iban: iban ?? this.iban,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      accountType: accountType ?? this.accountType,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  // Méthodes utilitaires
  String get formattedBalance => '${balance.toStringAsFixed(2)} $currency';
  
  String get maskedAccountNumber {
    if (accountNumber.length < 4) return accountNumber;
    return '****${accountNumber.substring(accountNumber.length - 4)}';
  }
  
  bool get isMultiCurrency => currency != 'FCFA';
  
  String get displayName {
    switch (accountType) {
      case 'savings':
        return 'Compte Épargne';
      case 'investment':
        return 'Compte Investissement';
      case 'multi_currency':
        return 'Compte Multi-Devises';
      default:
        return 'Compte Principal';
    }
  }
}

// Types de comptes
enum AccountType {
  standard('standard', 'Compte Standard'),
  savings('savings', 'Compte Épargne'),
  investment('investment', 'Compte Investissement'),
  multiCurrency('multi_currency', 'Compte Multi-Devises');

  const AccountType(this.value, this.displayName);
  final String value;
  final String displayName;
}

// Devises supportées
enum SupportedCurrency {
  fcfa('FCFA', 'Franc CFA', '🇲🇱'),
  eur('EUR', 'Euro', '🇪🇺'),
  usd('USD', 'Dollar US', '🇺🇸'),
  gbp('GBP', 'Livre Sterling', '🇬🇧');

  const SupportedCurrency(this.code, this.name, this.flag);
  final String code;
  final String name;
  final String flag;
}
