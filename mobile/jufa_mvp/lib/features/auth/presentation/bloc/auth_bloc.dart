import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String identifier;
  final String password;
  
  LoginRequested({required this.identifier, required this.password});
  
  @override
  List<Object?> get props => [identifier, password];
}

class RegisterRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  
  RegisterRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
  });
  
  @override
  List<Object?> get props => [firstName, lastName, email, phone, password];
}

class LogoutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserEntity user;
  
  AuthSuccess(this.user);
  
  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  
  AuthError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class AuthLoggedOut extends AuthState {}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  
  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }
  
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await loginUseCase(
      identifier: event.identifier,
      password: event.password,
    );
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }
  
  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await registerUseCase(
      firstName: event.firstName,
      lastName: event.lastName,
      email: event.email,
      phone: event.phone,
      password: event.password,
    );
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }
  
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoggedOut());
  }
}
