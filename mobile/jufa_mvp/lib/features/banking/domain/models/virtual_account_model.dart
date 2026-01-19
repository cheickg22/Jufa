class VirtualAccount {
  final String id;
  final String userId;
  final String name;
  final String accountNumber;
  final double balance;
  final String currency;
  final String type;
  final bool isActive;
  final bool isMultiCurrency;
  final String? iban;

  VirtualAccount({
    required this.id,
    required this.userId,
    required this.name,
    required this.accountNumber,
    required this.balance,
    this.currency = 'FCFA',
    required this.type,
    this.isActive = true,
    this.isMultiCurrency = false,
    this.iban,
  });

  String get displayName => name;
  
  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    return '****${accountNumber.substring(accountNumber.length - 4)}';
  }
  
  String get formattedBalance {
    return '${balance.toStringAsFixed(0)} $currency';
  }
}
