import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/transaction_remote_datasource.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../domain/entities/transaction_entity.dart';

final transactionRemoteDataSourceProvider = Provider<TransactionRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TransactionRemoteDataSource(apiClient);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final remoteDataSource = ref.watch(transactionRemoteDataSourceProvider);
  return TransactionRepository(remoteDataSource);
});

final transactionHistoryProvider = FutureProvider<List<TransactionEntity>>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final result = await repository.getTransactionHistory();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (transactions) => transactions,
  );
});

class TransferState {
  final bool isLoading;
  final String? error;
  final TransactionEntity? transaction;

  const TransferState({
    this.isLoading = false,
    this.error,
    this.transaction,
  });

  TransferState copyWith({
    bool? isLoading,
    String? error,
    TransactionEntity? transaction,
  }) {
    return TransferState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      transaction: transaction ?? this.transaction,
    );
  }
}

class TransferNotifier extends StateNotifier<TransferState> {
  final TransactionRepository _repository;
  final Ref _ref;

  TransferNotifier(this._repository, this._ref) : super(const TransferState());

  Future<bool> transfer({
    required String receiverPhone,
    required double amount,
    String? description,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.transfer(
      receiverPhone: receiverPhone,
      amount: amount,
      description: description,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (transaction) {
        state = state.copyWith(isLoading: false, transaction: transaction);
        _ref.invalidate(transactionHistoryProvider);
        return true;
      },
    );
  }

  void reset() {
    state = const TransferState();
  }
}

final transferNotifierProvider = StateNotifierProvider<TransferNotifier, TransferState>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return TransferNotifier(repository, ref);
});
