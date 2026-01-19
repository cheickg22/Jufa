import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../datasources/qr_payment_remote_datasource.dart';
import '../../domain/entities/qr_payment_entity.dart';

class QrPaymentRepository {
  final QrPaymentRemoteDataSource _remoteDataSource;

  QrPaymentRepository(this._remoteDataSource);

  Future<Either<Failure, QrCodeEntity>> generateQrCode({
    required QrCodeType qrType,
    double? amount,
    String? description,
    int? expiresInMinutes,
  }) async {
    try {
      final result = await _remoteDataSource.generateQrCode(
        qrType: qrType,
        amount: amount,
        description: description,
        expiresInMinutes: expiresInMinutes,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, QrCodeEntity>> scanQrCode(String qrToken) async {
    try {
      final result = await _remoteDataSource.scanQrCode(qrToken);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, QrPaymentEntity>> payWithQrCode({
    required String qrToken,
    double? amount,
    String? description,
  }) async {
    try {
      final result = await _remoteDataSource.payWithQrCode(
        qrToken: qrToken,
        amount: amount,
        description: description,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<QrCodeEntity>>> getMyQrCodes() async {
    try {
      final result = await _remoteDataSource.getMyQrCodes();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<QrPaymentEntity>>> getMyPayments({int page = 0, int size = 20}) async {
    try {
      final result = await _remoteDataSource.getMyPayments(page: page, size: size);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<QrPaymentEntity>>> getReceivedPayments({int page = 0, int size = 20}) async {
    try {
      final result = await _remoteDataSource.getReceivedPayments(page: page, size: size);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deactivateQrCode(String qrCodeId) async {
    try {
      await _remoteDataSource.deactivateQrCode(qrCodeId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
