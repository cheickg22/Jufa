import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../datasources/airtime_remote_datasource.dart';
import '../../domain/entities/airtime_entity.dart';

class AirtimeRepository {
  final AirtimeRemoteDatasource _remoteDatasource;

  AirtimeRepository(this._remoteDatasource);

  Future<Either<Failure, List<AirtimeOperator>>> getOperators() async {
    try {
      final operators = await _remoteDatasource.getOperators();
      return Right(operators);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, AirtimeTransaction>> recharge({
    required String operatorCode,
    required String phoneNumber,
    required double amount,
  }) async {
    try {
      final transaction = await _remoteDatasource.recharge(
        operatorCode: operatorCode,
        phoneNumber: phoneNumber,
        amount: amount,
      );
      return Right(transaction);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<AirtimeTransaction>>> getHistory({int page = 0}) async {
    try {
      final history = await _remoteDatasource.getHistory(page: page);
      return Right(history);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
