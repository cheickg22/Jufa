import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, RegisterResult>> register(String phone, String password, String userType);
  Future<Either<Failure, UserEntity>> verifyOtp(String userId, String otp);
  Future<Either<Failure, UserEntity>> login(String phone, String password);
  Future<Either<Failure, void>> logout();
  Future<bool> isLoggedIn();
}
