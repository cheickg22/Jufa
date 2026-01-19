import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/wallet_remote_datasource.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../domain/entities/wallet_entity.dart';

final walletRemoteDataSourceProvider = Provider<WalletRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WalletRemoteDataSource(apiClient);
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final remoteDataSource = ref.watch(walletRemoteDataSourceProvider);
  return WalletRepository(remoteDataSource);
});

final walletsProvider = FutureProvider<List<WalletEntity>>((ref) async {
  final repository = ref.watch(walletRepositoryProvider);
  final result = await repository.getWallets();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (wallets) => wallets,
  );
});

final totalBalanceProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(walletRepositoryProvider);
  final result = await repository.getTotalBalance();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (balance) => balance,
  );
});

final primaryWalletProvider = FutureProvider<WalletEntity?>((ref) async {
  final wallets = await ref.watch(walletsProvider.future);
  if (wallets.isEmpty) return null;
  return wallets.first;
});
