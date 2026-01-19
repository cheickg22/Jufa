import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String identifier, // Email or phone
    required String password,
  });
  
  Future<Either<Failure, UserEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  });
  
  Future<Either<Failure, void>> verifyOTP({
    required String identifier,
    required String otp,
  });
  
  Future<Either<Failure, void>> resendOTP({
    required String identifier,
  });
  
  Future<Either<Failure, void>> logout();
  
  Future<Either<Failure, UserEntity>> getCurrentUser();
  
  Future<Either<Failure, bool>> isLoggedIn();
  
  Future<Either<Failure, void>> requestPasswordReset({
    required String email,
  });
  
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });
}
