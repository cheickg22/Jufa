import 'package:equatable/equatable.dart';

class TransferEntity extends Equatable {
  final String id;
  final String fromAccount;
  final String toAccount;
  final double amount;
  final String? description;
  final String status;
  final DateTime createdAt;
  final String? recipientName;
  final String? recipientPhone;
  
  const TransferEntity({
    required this.id,
    required this.fromAccount,
    required this.toAccount,
    required this.amount,
    this.description,
    required this.status,
    required this.createdAt,
    this.recipientName,
    this.recipientPhone,
  });
  
  bool get isPending => status == 'pending';
  bool get isSuccess => status == 'success';
  bool get isFailed => status == 'failed';
  
  @override
  List<Object?> get props => [
        id,
        fromAccount,
        toAccount,
        amount,
        description,
        status,
        createdAt,
        recipientName,
        recipientPhone,
      ];
}
