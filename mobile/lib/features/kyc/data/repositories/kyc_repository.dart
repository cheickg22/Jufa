import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../datasources/kyc_remote_datasource.dart';
import '../../domain/entities/kyc_document_entity.dart';

class KycRepository {
  final KycRemoteDataSource _remoteDataSource;

  KycRepository(this._remoteDataSource);

  Future<Either<Failure, KycStatusEntity>> getKycStatus() async {
    try {
      final result = await _remoteDataSource.getKycStatus();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, KycDocumentEntity>> uploadDocument({
    required String filePath,
    required String fileName,
    required DocumentType documentType,
  }) async {
    try {
      final result = await _remoteDataSource.uploadDocument(
        filePath: filePath,
        fileName: fileName,
        documentType: documentType,
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

  Future<Either<Failure, List<KycDocumentEntity>>> getMyDocuments() async {
    try {
      final result = await _remoteDataSource.getMyDocuments();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
