import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/agent_remote_datasource.dart';
import '../../data/repositories/agent_repository.dart';
import '../../domain/entities/agent_dashboard.dart';
import '../../domain/entities/agent_transaction.dart';
import '../../domain/entities/agent_daily_report.dart';
import '../../domain/entities/fee_calculation.dart';
import '../../domain/entities/client_info.dart';

final agentRepositoryProvider = Provider<AgentRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final datasource = AgentRemoteDatasource(apiClient);
  return AgentRepository(datasource);
});

class AgentState {
  final bool isLoading;
  final String? error;
  final AgentDashboard? dashboard;
  final List<AgentTransaction> transactions;
  final List<AgentTransaction> cashInTransactions;
  final List<AgentTransaction> cashOutTransactions;
  final List<AgentDailyReport> reports;
  final AgentTransaction? lastTransaction;
  final FeeCalculation? currentFees;
  final bool hasMore;
  final int currentPage;
  final bool balanceVisible;
  final ClientInfo? currentClient;
  final bool isSearchingClient;

  AgentState({
    this.isLoading = false,
    this.error,
    this.dashboard,
    this.transactions = const [],
    this.cashInTransactions = const [],
    this.cashOutTransactions = const [],
    this.reports = const [],
    this.lastTransaction,
    this.currentFees,
    this.hasMore = true,
    this.currentPage = 0,
    this.balanceVisible = false,
    this.currentClient,
    this.isSearchingClient = false,
  });

  AgentState copyWith({
    bool? isLoading,
    String? error,
    AgentDashboard? dashboard,
    List<AgentTransaction>? transactions,
    List<AgentTransaction>? cashInTransactions,
    List<AgentTransaction>? cashOutTransactions,
    List<AgentDailyReport>? reports,
    AgentTransaction? lastTransaction,
    FeeCalculation? currentFees,
    bool? hasMore,
    int? currentPage,
    bool? balanceVisible,
    ClientInfo? currentClient,
    bool? isSearchingClient,
    bool clearError = false,
    bool clearTransaction = false,
    bool clearFees = false,
    bool clearClient = false,
  }) {
    return AgentState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      dashboard: dashboard ?? this.dashboard,
      transactions: transactions ?? this.transactions,
      cashInTransactions: cashInTransactions ?? this.cashInTransactions,
      cashOutTransactions: cashOutTransactions ?? this.cashOutTransactions,
      reports: reports ?? this.reports,
      lastTransaction: clearTransaction ? null : (lastTransaction ?? this.lastTransaction),
      currentFees: clearFees ? null : (currentFees ?? this.currentFees),
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      balanceVisible: balanceVisible ?? this.balanceVisible,
      currentClient: clearClient ? null : (currentClient ?? this.currentClient),
      isSearchingClient: isSearchingClient ?? this.isSearchingClient,
    );
  }
}

class AgentNotifier extends StateNotifier<AgentState> {
  final AgentRepository _repository;

  AgentNotifier(this._repository) : super(AgentState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getDashboard();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (dashboard) => state = state.copyWith(isLoading: false, dashboard: dashboard),
    );
  }

  Future<bool> processCashIn({
    required String customerPhone,
    required double amount,
    String? description,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.processCashIn(
      customerPhone: customerPhone,
      amount: amount,
      description: description,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (transaction) {
        state = state.copyWith(
          isLoading: false,
          lastTransaction: transaction,
          transactions: [transaction, ...state.transactions],
          cashInTransactions: [transaction, ...state.cashInTransactions],
          clearClient: true,
        );
        loadDashboard();
        return true;
      },
    );
  }

  Future<bool> processCashOut({
    required String customerPhone,
    required double amount,
    required String customerPin,
    String? description,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.processCashOut(
      customerPhone: customerPhone,
      amount: amount,
      customerPin: customerPin,
      description: description,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (transaction) {
        state = state.copyWith(
          isLoading: false,
          lastTransaction: transaction,
          transactions: [transaction, ...state.transactions],
          cashOutTransactions: [transaction, ...state.cashOutTransactions],
          clearClient: true,
        );
        loadDashboard();
        return true;
      },
    );
  }

  Future<void> calculateCashInFees(double amount) async {
    final result = await _repository.calculateCashInFees(amount);
    result.fold(
      (failure) {},
      (fees) => state = state.copyWith(currentFees: fees),
    );
  }

  Future<void> calculateCashOutFees(double amount) async {
    final result = await _repository.calculateCashOutFees(amount);
    result.fold(
      (failure) {},
      (fees) => state = state.copyWith(currentFees: fees),
    );
  }

  void clearFees() {
    state = state.copyWith(clearFees: true);
  }

  Future<void> loadTransactions({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        transactions: [],
        currentPage: 0,
        hasMore: true,
      );
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getTransactions(page: state.currentPage);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (transactions) => state = state.copyWith(
        isLoading: false,
        transactions: refresh ? transactions : [...state.transactions, ...transactions],
        hasMore: transactions.length >= 20,
      ),
    );
  }

  Future<void> loadCashInTransactions({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(cashInTransactions: []);
    }

    final result = await _repository.getCashInTransactions(page: 0);
    result.fold(
      (failure) {},
      (transactions) => state = state.copyWith(cashInTransactions: transactions),
    );
  }

  Future<void> loadCashOutTransactions({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(cashOutTransactions: []);
    }

    final result = await _repository.getCashOutTransactions(page: 0);
    result.fold(
      (failure) {},
      (transactions) => state = state.copyWith(cashOutTransactions: transactions),
    );
  }

  Future<void> loadMoreTransactions() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(currentPage: state.currentPage + 1);
    await loadTransactions();
  }

  Future<void> loadReports() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getLast30DaysReports();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (reports) => state = state.copyWith(isLoading: false, reports: reports),
    );
  }

  Future<bool> searchClient(String phone) async {
    state = state.copyWith(isSearchingClient: true, clearError: true, clearClient: true);

    final result = await _repository.searchClient(phone);
    return result.fold(
      (failure) {
        state = state.copyWith(isSearchingClient: false, error: failure.message);
        return false;
      },
      (client) {
        state = state.copyWith(isSearchingClient: false, currentClient: client);
        return true;
      },
    );
  }

  void clearClient() {
    state = state.copyWith(clearClient: true);
  }

  Future<bool> verifySecretCode(String code) async {
    final result = await _repository.verifySecretCode(code);
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (success) {
        if (success) {
          state = state.copyWith(balanceVisible: true);
        }
        return success;
      },
    );
  }

  void hideBalance() {
    state = state.copyWith(balanceVisible: false);
  }

  Future<bool> updateSecretCode(String newCode, {String? oldCode}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.updateSecretCode(newCode, oldCode: oldCode);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        loadDashboard();
        return true;
      },
    );
  }

  void clearLastTransaction() {
    state = state.copyWith(clearTransaction: true);
  }

  void reset() {
    state = AgentState();
  }
}

final agentNotifierProvider = StateNotifierProvider<AgentNotifier, AgentState>((ref) {
  final repository = ref.watch(agentRepositoryProvider);
  return AgentNotifier(repository);
});
