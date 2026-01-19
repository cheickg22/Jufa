enum PaymentStatus {
  pending,
  partial,
  paid,
  credit,
  overdue;

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'En attente';
      case PaymentStatus.partial:
        return 'Partiel';
      case PaymentStatus.paid:
        return 'Payé';
      case PaymentStatus.credit:
        return 'À crédit';
      case PaymentStatus.overdue:
        return 'En retard';
    }
  }

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => PaymentStatus.pending,
    );
  }
}
