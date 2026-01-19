import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, UserEntity>> login({
    required String identifier,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    
    try {
      final response = await remoteDataSource.login(
        identifier: identifier,
        password: password,
      );
      
      // Sauvegarder les tokens
      final data = response['data'] as Map<String, dynamic>;
      await localDataSource.saveTokens(
        accessToken: data['token'],
        refreshToken: data['token'], // Laravel Sanctum uses same token
      );
      
      // Sauvegarder aussi dans AuthService pour compatibilité
      await AuthService.saveToken(data['token']);
      
      // Sauvegarder l'utilisateur
      final user = UserModel.fromJson(data['user']);
      await localDataSource.cacheUser(user);
      
      // Sauvegarder aussi dans UserService pour l'affichage dans le dashboard
      final userData = data['user'] as Map<String, dynamic>;
      await UserService.saveUserInfo(
        firstName: userData['first_name'] ?? '',
        lastName: userData['last_name'] ?? '',
        email: userData['email'] ?? '',
        phone: userData['phone'] ?? '',
        balance: (userData['balance'] ?? 0).toDouble(),
      );
      
      print('💾 Données utilisateur sauvegardées localement (ID: ${userData['id']})');
      
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthenticationFailure(message: e.message, code: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, UserEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    
    try {
      final response = await remoteDataSource.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
      );
      
      // Note: Register returns user data but requires OTP verification
      // Token will be provided after OTP verification
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> verifyOTP({
    required String identifier,
    required String otp,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    
    try {
      await remoteDataSource.verifyOTP(
        identifier: identifier,
        otp: otp,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> resendOTP({
    required String identifier,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    
    try {
      await remoteDataSource.resendOTP(identifier: identifier);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.logout();
      }
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      // Toujours nettoyer le cache local même en cas d'erreur
      await localDataSource.clearCache();
      return const Right(null);
    }
  }
  
  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isLoggedIn = await localDataSource.isLoggedIn();
      return Right(isLoggedIn);
    } catch (e) {
      return const Right(false);
    }
  }
  
  @override
  Future<Either<Failure, void>> requestPasswordReset({
    required String email,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    
    // TODO: Implémenter avec l'API
    return const Right(null);
  }
  
  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    
    // TODO: Implémenter avec l'API
    return const Right(null);
  }
}
