enum CardType {
  visa,
  mastercard,
  other,
}

enum CardStatus {
  active,
  blocked,
  expired,
}

class VirtualCard {
  final String id;
  final String userId;
  final String cardNumber;
  final String cardHolder;
  final String expiryDate;
  final String cvv;
  final CardType cardType;
  final CardStatus status;
  final double balance;
  final String currency;

  VirtualCard({
    required this.id,
    required this.userId,
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryDate,
    required this.cvv,
    required this.cardType,
    required this.status,
    required this.balance,
    this.currency = 'FCFA',
  });

  String get cardBrand {
    switch (cardType) {
      case CardType.visa:
        return 'Visa';
      case CardType.mastercard:
        return 'Mastercard';
      default:
        return 'Card';
    }
  }

  bool get isActive => status == CardStatus.active;

  String get statusText {
    switch (status) {
      case CardStatus.active:
        return 'Active';
      case CardStatus.blocked:
        return 'Bloquée';
      case CardStatus.expired:
        return 'Expirée';
    }
  }

  String get displayCardNumber {
    if (cardNumber.length < 16) return cardNumber;
    return '${cardNumber.substring(0, 4)} **** **** ${cardNumber.substring(12)}';
  }

  String get cardholderName => cardHolder;
}
