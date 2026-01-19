import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String id;
  final String type; // bill, airtime
  final String provider;
  final double amount;
  final String status;
  final DateTime createdAt;
  final String? reference;
  final String? phoneNumber;
  
  const PaymentEntity({
    required this.id,
    required this.type,
    required this.provider,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.reference,
    this.phoneNumber,
  });
  
  bool get isBillPayment => type == 'bill';
  bool get isAirtimePayment => type == 'airtime';
  
  @override
  List<Object?> get props => [
        id,
        type,
        provider,
        amount,
        status,
        createdAt,
        reference,
        phoneNumber,
      ];
}
