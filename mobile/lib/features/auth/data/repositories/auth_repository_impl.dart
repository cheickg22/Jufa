import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _storage;
  
  AuthRepositoryImpl(this._remoteDataSource, this._storage);
  
  @override
  Future<Either<Failure, RegisterResult>> register(String phone, String password, String userType) async {
    try {
      final response = await _remoteDataSource.register(phone, password, userType);
      return Right(RegisterResult(
        userId: response.userId,
        phone: response.phone,
        message: response.message,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
  
  @override
  Future<Either<Failure, UserEntity>> verifyOtp(String userId, String otp) async {
    try {
      final response = await _remoteDataSource.verifyOtp(userId, otp);
      
      await _storage.write(StorageKeys.accessToken, response.accessToken);
      if (response.refreshToken != null) {
        await _storage.write(StorageKeys.refreshToken, response.refreshToken!);
      }
      await _storage.write(StorageKeys.isLoggedIn, 'true');
      
      final user = response.user!;
      return Right(UserEntity(
        id: user.id,
        phone: user.phone,
        email: user.email,
        userType: _parseUserType(user.userType),
        status: _parseUserStatus(user.status),
        kycLevel: _parseKycLevel(user.kycLevel),
      ));
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
  
  @override
  Future<Either<Failure, UserEntity>> login(String phone, String password) async {
    try {
      final response = await _remoteDataSource.login(phone, password);
      
      await _storage.write(StorageKeys.accessToken, response.accessToken);
      if (response.refreshToken != null) {
        await _storage.write(StorageKeys.refreshToken, response.refreshToken!);
      }
      await _storage.write(StorageKeys.isLoggedIn, 'true');
      
      final user = response.user!;
      return Right(UserEntity(
        id: user.id,
        phone: user.phone,
        email: user.email,
        userType: _parseUserType(user.userType),
        status: _parseUserStatus(user.status),
        kycLevel: _parseKycLevel(user.kycLevel),
      ));
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
  
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _storage.deleteAll();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on NetworkException {
      await _storage.deleteAll();
      return const Right(null);
    }
  }
  
  @override
  Future<bool> isLoggedIn() async {
    final isLoggedIn = await _storage.read(StorageKeys.isLoggedIn);
    final accessToken = await _storage.read(StorageKeys.accessToken);
    return isLoggedIn == 'true' && accessToken != null;
  }
  
  UserType _parseUserType(String type) {
    return UserType.values.firstWhere(
      (e) => e.name.toUpperCase() == type.toUpperCase(),
      orElse: () => UserType.individual,
    );
  }
  
  UserStatus _parseUserStatus(String status) {
    return UserStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == status.toUpperCase(),
      orElse: () => UserStatus.pending,
    );
  }
  
  KycLevel _parseKycLevel(String level) {
    switch (level.toUpperCase()) {
      case 'LEVEL_0':
        return KycLevel.level0;
      case 'LEVEL_1':
        return KycLevel.level1;
      case 'LEVEL_2':
        return KycLevel.level2;
      case 'LEVEL_3':
        return KycLevel.level3;
      default:
        return KycLevel.level0;
    }
  }
}
