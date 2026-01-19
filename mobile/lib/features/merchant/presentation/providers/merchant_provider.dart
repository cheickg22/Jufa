import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/merchant_remote_datasource.dart';
import '../../data/repositories/merchant_repository.dart';
import '../../domain/entities/merchant_entity.dart';

final merchantRemoteDataSourceProvider = Provider<MerchantRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MerchantRemoteDataSource(apiClient);
});

final merchantRepositoryProvider = Provider<MerchantRepository>((ref) {
  final remoteDataSource = ref.watch(merchantRemoteDataSourceProvider);
  return MerchantRepository(remoteDataSource);
});

final merchantDashboardProvider = FutureProvider<MerchantDashboardEntity>((ref) async {
  final repository = ref.watch(merchantRepositoryProvider);
  final result = await repository.getDashboard();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (dashboard) => dashboard,
  );
});

final merchantProfileProvider = FutureProvider<MerchantProfileEntity>((ref) async {
  final repository = ref.watch(merchantRepositoryProvider);
  final result = await repository.getProfile();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (profile) => profile,
  );
});

final myRetailersProvider = FutureProvider<List<RetailerRelationEntity>>((ref) async {
  final repository = ref.watch(merchantRepositoryProvider);
  final result = await repository.getMyRetailers();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (retailers) => retailers,
  );
});

final myWholesalersProvider = FutureProvider<List<RetailerRelationEntity>>((ref) async {
  final repository = ref.watch(merchantRepositoryProvider);
  final result = await repository.getMyWholesalers();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (wholesalers) => wholesalers,
  );
});

final wholesalersProvider = FutureProvider.family<List<MerchantProfileEntity>, String?>((ref, city) async {
  final repository = ref.watch(merchantRepositoryProvider);
  final result = await repository.getWholesalers(city: city);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (wholesalers) => wholesalers,
  );
});

class MerchantActionState {
  final bool isLoading;
  final String? error;
  final bool success;

  const MerchantActionState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  MerchantActionState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return MerchantActionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class MerchantActionNotifier extends StateNotifier<MerchantActionState> {
  final MerchantRepository _repository;
  final Ref _ref;

  MerchantActionNotifier(this._repository, this._ref) : super(const MerchantActionState());

  Future<bool> createProfile({
    required MerchantType merchantType,
    required String businessName,
    String? businessCategory,
    String? rccmNumber,
    String? nifNumber,
    String? address,
    String? city,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.createProfile(
      merchantType: merchantType,
      businessName: businessName,
      businessCategory: businessCategory,
      rccmNumber: rccmNumber,
      nifNumber: nifNumber,
      address: address,
      city: city,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false, success: true);
        _ref.invalidate(merchantProfileProvider);
        _ref.invalidate(merchantDashboardProvider);
        return true;
      },
    );
  }

  Future<bool> addRetailer({
    required String retailerId,
    double? creditLimit,
    int? paymentTermsDays,
    double? discountRate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.addRetailer(
      retailerId: retailerId,
      creditLimit: creditLimit,
      paymentTermsDays: paymentTermsDays,
      discountRate: discountRate,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false, success: true);
        _ref.invalidate(myRetailersProvider);
        _ref.invalidate(merchantDashboardProvider);
        return true;
      },
    );
  }

  Future<bool> approveRelation(String relationId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.approveRelation(relationId);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false, success: true);
        _ref.invalidate(myWholesalersProvider);
        _ref.invalidate(merchantDashboardProvider);
        return true;
      },
    );
  }

  Future<bool> suspendRelation(String relationId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.suspendRelation(relationId);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false, success: true);
        _ref.invalidate(myRetailersProvider);
        _ref.invalidate(myWholesalersProvider);
        _ref.invalidate(merchantDashboardProvider);
        return true;
      },
    );
  }

  void reset() {
    state = const MerchantActionState();
  }
}

final merchantActionNotifierProvider =
    StateNotifierProvider<MerchantActionNotifier, MerchantActionState>((ref) {
  final repository = ref.watch(merchantRepositoryProvider);
  return MerchantActionNotifier(repository, ref);
});
