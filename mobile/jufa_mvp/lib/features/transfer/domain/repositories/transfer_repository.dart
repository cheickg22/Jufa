import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transfer_entity.dart';

abstract class TransferRepository {
  Future<Either<Failure, TransferEntity>> sendTransfer({
    required String toAccount,
    required double amount,
    String? description,
  });
  
  Future<Either<Failure, List<TransferEntity>>> getTransferHistory({
    int page = 1,
    int limit = 20,
  });
  
  Future<Either<Failure, Map<String, dynamic>>> verifyRecipient({
    required String identifier,
  });
}
