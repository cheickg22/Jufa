import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/wallet_entity.dart';
import '../datasources/wallet_remote_datasource.dart';

class WalletRepository {
  final WalletRemoteDataSource _remoteDataSource;

  WalletRepository(this._remoteDataSource);

  Future<Either<Failure, List<WalletEntity>>> getWallets() async {
    return await _remoteDataSource.getWallets();
  }

  Future<Either<Failure, WalletEntity>> getWallet(String walletId) async {
    return await _remoteDataSource.getWallet(walletId);
  }

  Future<Either<Failure, Map<String, dynamic>>> getTotalBalance() async {
    return await _remoteDataSource.getTotalBalance();
  }
}
