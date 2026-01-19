import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/mobile_money_entity.dart';
import '../datasources/mobile_money_remote_datasource.dart';
import '../models/mobile_money_model.dart';

class MobileMoneyRepository {
  final MobileMoneyRemoteDataSource _remoteDataSource;

  MobileMoneyRepository(this._remoteDataSource);

  Future<Either<Failure, List<ProviderInfoEntity>>> getProviders() async {
    try {
      final providers = await _remoteDataSource.getProviders();
      return Right(providers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, MobileMoneyOperationEntity>> initiateDeposit({
    required MobileMoneyProvider provider,
    required String phoneNumber,
    required double amount,
  }) async {
    try {
      final request = DepositRequestModel(
        provider: provider.name.toUpperCase().replaceAll('MONEY', '_MONEY'),
        phoneNumber: phoneNumber,
        amount: amount,
      );
      final operation = await _remoteDataSource.initiateDeposit(request);
      return Right(operation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, MobileMoneyOperationEntity>> confirmDeposit({
    required String reference,
    String? otp,
  }) async {
    try {
      final request = ConfirmDepositRequestModel(reference: reference, otp: otp);
      final operation = await _remoteDataSource.confirmDeposit(request);
      return Right(operation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, MobileMoneyOperationEntity>> initiateWithdrawal({
    required MobileMoneyProvider provider,
    required String phoneNumber,
    required double amount,
  }) async {
    try {
      final request = WithdrawalRequestModel(
        provider: provider.name.toUpperCase().replaceAll('MONEY', '_MONEY'),
        phoneNumber: phoneNumber,
        amount: amount,
      );
      final operation = await _remoteDataSource.initiateWithdrawal(request);
      return Right(operation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, MobileMoneyOperationEntity>> cancelOperation(String reference) async {
    try {
      final operation = await _remoteDataSource.cancelOperation(reference);
      return Right(operation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, MobileMoneyOperationEntity>> getOperation(String reference) async {
    try {
      final operation = await _remoteDataSource.getOperation(reference);
      return Right(operation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<MobileMoneyOperationEntity>>> getOperations({int page = 0}) async {
    try {
      final operations = await _remoteDataSource.getOperations(page: page);
      return Right(operations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<MobileMoneyOperationEntity>>> getDeposits({int page = 0}) async {
    try {
      final deposits = await _remoteDataSource.getDeposits(page: page);
      return Right(deposits);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<MobileMoneyOperationEntity>>> getWithdrawals({int page = 0}) async {
    try {
      final withdrawals = await _remoteDataSource.getWithdrawals(page: page);
      return Right(withdrawals);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
