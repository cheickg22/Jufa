import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../datasources/transaction_remote_datasource.dart';

class TransactionRepository {
  final TransactionRemoteDataSource _remoteDataSource;

  TransactionRepository(this._remoteDataSource);

  Future<Either<Failure, TransactionEntity>> transfer({
    required String receiverPhone,
    required double amount,
    String? description,
  }) async {
    return await _remoteDataSource.transfer(
      receiverPhone: receiverPhone,
      amount: amount,
      description: description,
    );
  }

  Future<Either<Failure, List<TransactionEntity>>> getTransactionHistory({
    int page = 0,
    int size = 20,
  }) async {
    return await _remoteDataSource.getTransactionHistory(page: page, size: size);
  }

  Future<Either<Failure, TransactionEntity>> getTransaction(String transactionId) async {
    return await _remoteDataSource.getTransaction(transactionId);
  }
}
