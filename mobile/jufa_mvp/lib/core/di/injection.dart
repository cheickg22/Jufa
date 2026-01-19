import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../network/api_client.dart';
import '../network/network_info.dart';
import '../security/secure_storage_service.dart';
import '../security/encryption_service.dart';
import '../security/biometric_service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External Dependencies
  getIt.registerLazySingleton(() => Connectivity());
  getIt.registerLazySingleton(() => const FlutterSecureStorage());
  getIt.registerLazySingleton(() => LocalAuthentication());
  
  // Core Services
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt()),
  );
  
  getIt.registerLazySingleton(
    () => SecureStorageService(getIt()),
  );
  
  getIt.registerLazySingleton(
    () => EncryptionService(),
  );
  
  getIt.registerLazySingleton(
    () => BiometricService(getIt()),
  );
  
  getIt.registerLazySingleton(
    () => ApiClient(networkInfo: getIt()),
  );
  
  // Features will be registered here
  // Example:
  // _registerAuthDependencies();
  // _registerDashboardDependencies();
  // etc.
}

// Exemple de fonction d'enregistrement pour une feature
// void _registerAuthDependencies() {
//   // Data sources
//   getIt.registerLazySingleton<AuthRemoteDataSource>(
//     () => AuthRemoteDataSourceImpl(getIt()),
//   );
//   
//   // Repositories
//   getIt.registerLazySingleton<AuthRepository>(
//     () => AuthRepositoryImpl(
//       remoteDataSource: getIt(),
//       networkInfo: getIt(),
//     ),
//   );
//   
//   // Use cases
//   getIt.registerLazySingleton(() => LoginUseCase(getIt()));
//   getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
//   
//   // BLoCs
//   getIt.registerFactory(
//     () => AuthBloc(
//       loginUseCase: getIt(),
//       registerUseCase: getIt(),
//     ),
//   );
// }
