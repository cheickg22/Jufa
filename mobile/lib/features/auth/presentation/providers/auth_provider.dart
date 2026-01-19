import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSourceImpl(apiClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(remoteDataSource, storage);
});

final currentUserProvider = StateProvider<UserEntity?>((ref) => null);

final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return repository.isLoggedIn();
});

enum AuthStatus { initial, loading, authenticated, unauthenticated, otpSent, error }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? userId;
  final String? error;
  
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.userId,
    this.error,
  });
  
  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? userId,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      userId: userId ?? this.userId,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final Ref _ref;
  
  AuthNotifier(this._repository, this._ref) : super(const AuthState());
  
  Future<void> register(String phone, String password, {String userType = 'INDIVIDUAL'}) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    final result = await _repository.register(phone, password, userType);
    
    result.fold(
      (failure) => state = state.copyWith(status: AuthStatus.error, error: failure.message),
      (registerResult) => state = state.copyWith(
        status: AuthStatus.otpSent,
        userId: registerResult.userId,
      ),
    );
  }
  
  Future<void> verifyOtp(String otp) async {
    if (state.userId == null) {
      state = state.copyWith(status: AuthStatus.error, error: 'No user ID found');
      return;
    }
    
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    final result = await _repository.verifyOtp(state.userId!, otp);
    
    result.fold(
      (failure) => state = state.copyWith(status: AuthStatus.error, error: failure.message),
      (user) {
        _ref.read(currentUserProvider.notifier).state = user;
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      },
    );
  }
  
  Future<void> login(String phone, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    final result = await _repository.login(phone, password);
    
    result.fold(
      (failure) => state = state.copyWith(status: AuthStatus.error, error: failure.message),
      (user) {
        _ref.read(currentUserProvider.notifier).state = user;
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      },
    );
  }
  
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    
    await _repository.logout();
    
    _ref.read(currentUserProvider.notifier).state = null;
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
  
  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository, ref);
});
