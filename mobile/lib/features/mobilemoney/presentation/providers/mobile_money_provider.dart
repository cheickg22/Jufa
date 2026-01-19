import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/mobile_money_remote_datasource.dart';
import '../../data/repositories/mobile_money_repository.dart';
import '../../domain/entities/mobile_money_entity.dart';

final mobileMoneyRepositoryProvider = Provider<MobileMoneyRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final dataSource = MobileMoneyRemoteDataSource(apiClient);
  return MobileMoneyRepository(dataSource);
});

class MobileMoneyState {
  final bool isLoading;
  final String? error;
  final List<ProviderInfoEntity> providers;
  final MobileMoneyOperationEntity? currentOperation;
  final List<MobileMoneyOperationEntity> operations;
  final MobileMoneyProvider? selectedProvider;

  MobileMoneyState({
    this.isLoading = false,
    this.error,
    this.providers = const [],
    this.currentOperation,
    this.operations = const [],
    this.selectedProvider,
  });

  MobileMoneyState copyWith({
    bool? isLoading,
    String? error,
    List<ProviderInfoEntity>? providers,
    MobileMoneyOperationEntity? currentOperation,
    List<MobileMoneyOperationEntity>? operations,
    MobileMoneyProvider? selectedProvider,
    bool clearError = false,
    bool clearOperation = false,
  }) {
    return MobileMoneyState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      providers: providers ?? this.providers,
      currentOperation: clearOperation ? null : (currentOperation ?? this.currentOperation),
      operations: operations ?? this.operations,
      selectedProvider: selectedProvider ?? this.selectedProvider,
    );
  }
}

class MobileMoneyNotifier extends StateNotifier<MobileMoneyState> {
  final MobileMoneyRepository _repository;

  MobileMoneyNotifier(this._repository) : super(MobileMoneyState());

  Future<void> loadProviders() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getProviders();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (providers) => state = state.copyWith(
        isLoading: false,
        providers: providers,
        selectedProvider: providers.isNotEmpty ? providers.first.provider : null,
      ),
    );
  }

  void selectProvider(MobileMoneyProvider provider) {
    state = state.copyWith(selectedProvider: provider);
  }

  Future<bool> initiateDeposit({
    required String phoneNumber,
    required double amount,
  }) async {
    if (state.selectedProvider == null) {
      state = state.copyWith(error: 'Veuillez sélectionner un opérateur');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.initiateDeposit(
      provider: state.selectedProvider!,
      phoneNumber: phoneNumber,
      amount: amount,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (operation) {
        state = state.copyWith(isLoading: false, currentOperation: operation);
        return true;
      },
    );
  }

  Future<bool> confirmDeposit({String? otp}) async {
    if (state.currentOperation == null) {
      state = state.copyWith(error: 'Aucune opération en cours');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.confirmDeposit(
      reference: state.currentOperation!.reference,
      otp: otp,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (operation) {
        state = state.copyWith(isLoading: false, currentOperation: operation);
        return true;
      },
    );
  }

  Future<bool> initiateWithdrawal({
    required String phoneNumber,
    required double amount,
  }) async {
    if (state.selectedProvider == null) {
      state = state.copyWith(error: 'Veuillez sélectionner un opérateur');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.initiateWithdrawal(
      provider: state.selectedProvider!,
      phoneNumber: phoneNumber,
      amount: amount,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (operation) {
        state = state.copyWith(isLoading: false, currentOperation: operation);
        return true;
      },
    );
  }

  Future<void> loadOperations() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getOperations();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (operations) => state = state.copyWith(isLoading: false, operations: operations),
    );
  }

  Future<void> cancelOperation(String reference) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.cancelOperation(reference);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (operation) {
        state = state.copyWith(isLoading: false, currentOperation: operation);
        loadOperations();
      },
    );
  }

  void reset() {
    state = state.copyWith(
      clearError: true,
      clearOperation: true,
    );
  }
}

final mobileMoneyNotifierProvider =
    StateNotifierProvider<MobileMoneyNotifier, MobileMoneyState>((ref) {
  final repository = ref.watch(mobileMoneyRepositoryProvider);
  return MobileMoneyNotifier(repository);
});
