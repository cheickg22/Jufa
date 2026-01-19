import 'package:equatable/equatable.dart';

class NegeEntity extends Equatable {
  final String id;
  final String metalType; // gold, silver
  final double grams;
  final double pricePerGram;
  final double totalAmount;
  final String transactionType; // buy, sell
  final String status;
  final DateTime createdAt;
  
  const NegeEntity({
    required this.id,
    required this.metalType,
    required this.grams,
    required this.pricePerGram,
    required this.totalAmount,
    required this.transactionType,
    required this.status,
    required this.createdAt,
  });
  
  bool get isGold => metalType == 'gold';
  bool get isSilver => metalType == 'silver';
  bool get isBuy => transactionType == 'buy';
  bool get isSell => transactionType == 'sell';
  
  @override
  List<Object?> get props => [
        id,
        metalType,
        grams,
        pricePerGram,
        totalAmount,
        transactionType,
        status,
        createdAt,
      ];
}

class NegePriceEntity extends Equatable {
  final double goldPricePerGram;
  final double silverPricePerGram;
  final DateTime updatedAt;
  
  const NegePriceEntity({
    required this.goldPricePerGram,
    required this.silverPricePerGram,
    required this.updatedAt,
  });
  
  @override
  List<Object?> get props => [goldPricePerGram, silverPricePerGram, updatedAt];
}
