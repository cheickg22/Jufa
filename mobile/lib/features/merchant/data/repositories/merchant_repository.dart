import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../datasources/merchant_remote_datasource.dart';
import '../../domain/entities/merchant_entity.dart';

class MerchantRepository {
  final MerchantRemoteDataSource _remoteDataSource;

  MerchantRepository(this._remoteDataSource);

  Future<Either<Failure, MerchantProfileEntity>> createProfile({
    required MerchantType merchantType,
    required String businessName,
    String? businessCategory,
    String? rccmNumber,
    String? nifNumber,
    String? address,
    String? city,
    double? gpsLat,
    double? gpsLng,
  }) async {
    try {
      final result = await _remoteDataSource.createProfile(
        merchantType: merchantType,
        businessName: businessName,
        businessCategory: businessCategory,
        rccmNumber: rccmNumber,
        nifNumber: nifNumber,
        address: address,
        city: city,
        gpsLat: gpsLat,
        gpsLng: gpsLng,
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

  Future<Either<Failure, MerchantProfileEntity>> getProfile() async {
    try {
      final result = await _remoteDataSource.getProfile();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, MerchantDashboardEntity>> getDashboard() async {
    try {
      final result = await _remoteDataSource.getDashboard();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<MerchantProfileEntity>>> getWholesalers({String? city}) async {
    try {
      final result = await _remoteDataSource.getWholesalers(city: city);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<RetailerRelationEntity>>> getMyRetailers() async {
    try {
      final result = await _remoteDataSource.getMyRetailers();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<RetailerRelationEntity>>> getMyWholesalers() async {
    try {
      final result = await _remoteDataSource.getMyWholesalers();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, RetailerRelationEntity>> addRetailer({
    required String retailerId,
    double? creditLimit,
    int? paymentTermsDays,
    double? discountRate,
  }) async {
    try {
      final result = await _remoteDataSource.addRetailer(
        retailerId: retailerId,
        creditLimit: creditLimit,
        paymentTermsDays: paymentTermsDays,
        discountRate: discountRate,
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

  Future<Either<Failure, RetailerRelationEntity>> approveRelation(String relationId) async {
    try {
      final result = await _remoteDataSource.approveRelation(relationId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, RetailerRelationEntity>> updateRelation({
    required String relationId,
    double? creditLimit,
    int? paymentTermsDays,
    double? discountRate,
  }) async {
    try {
      final result = await _remoteDataSource.updateRelation(
        relationId: relationId,
        creditLimit: creditLimit,
        paymentTermsDays: paymentTermsDays,
        discountRate: discountRate,
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

  Future<Either<Failure, void>> suspendRelation(String relationId) async {
    try {
      await _remoteDataSource.suspendRelation(relationId);
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
