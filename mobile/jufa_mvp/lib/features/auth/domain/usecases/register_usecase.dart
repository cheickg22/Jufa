import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  
  RegisterUseCase(this.repository);
  
  Future<Either<Failure, UserEntity>> call({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    return await repository.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      password: password,
    );
  }
}
