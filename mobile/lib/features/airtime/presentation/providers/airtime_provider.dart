import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/airtime_remote_datasource.dart';
import '../../data/repositories/airtime_repository.dart';
import '../../domain/entities/airtime_entity.dart';

final airtimeRemoteDatasourceProvider = Provider<AirtimeRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AirtimeRemoteDatasource(apiClient);
});

final airtimeRepositoryProvider = Provider<AirtimeRepository>((ref) {
  final datasource = ref.watch(airtimeRemoteDatasourceProvider);
  return AirtimeRepository(datasource);
});

final airtimeOperatorsProvider = FutureProvider<List<AirtimeOperator>>((ref) async {
  final repository = ref.watch(airtimeRepositoryProvider);
  final result = await repository.getOperators();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (operators) => operators,
  );
});

class AirtimeState {
  final bool isLoading;
  final String? error;
  final AirtimeOperator? selectedOperator;
  final AirtimeTransaction? lastTransaction;

  const AirtimeState({
    this.isLoading = false,
    this.error,
    this.selectedOperator,
    this.lastTransaction,
  });

  AirtimeState copyWith({
    bool? isLoading,
    String? error,
    AirtimeOperator? selectedOperator,
    AirtimeTransaction? lastTransaction,
    bool clearError = false,
  }) {
    return AirtimeState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedOperator: selectedOperator ?? this.selectedOperator,
      lastTransaction: lastTransaction ?? this.lastTransaction,
    );
  }
}

class AirtimeNotifier extends StateNotifier<AirtimeState> {
  final AirtimeRepository _repository;
  final Ref _ref;

  AirtimeNotifier(this._repository, this._ref) : super(const AirtimeState());

  void selectOperator(AirtimeOperator operator) {
    state = state.copyWith(selectedOperator: operator, clearError: true);
  }

  Future<bool> recharge({
    required String phoneNumber,
    required double amount,
  }) async {
    if (state.selectedOperator == null) {
      state = state.copyWith(error: 'Veuillez sélectionner un opérateur');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.recharge(
      operatorCode: state.selectedOperator!.code,
      phoneNumber: phoneNumber,
      amount: amount,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (transaction) {
        state = state.copyWith(isLoading: false, lastTransaction: transaction);
        return true;
      },
    );
  }

  void reset() {
    state = const AirtimeState();
  }
}

final airtimeNotifierProvider = StateNotifierProvider<AirtimeNotifier, AirtimeState>((ref) {
  final repository = ref.watch(airtimeRepositoryProvider);
  return AirtimeNotifier(repository, ref);
});
