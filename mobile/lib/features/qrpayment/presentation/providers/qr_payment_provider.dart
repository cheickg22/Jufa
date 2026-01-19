import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/qr_payment_remote_datasource.dart';
import '../../data/repositories/qr_payment_repository.dart';
import '../../domain/entities/qr_payment_entity.dart';

final qrPaymentRemoteDataSourceProvider = Provider<QrPaymentRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return QrPaymentRemoteDataSource(apiClient);
});

final qrPaymentRepositoryProvider = Provider<QrPaymentRepository>((ref) {
  final remoteDataSource = ref.watch(qrPaymentRemoteDataSourceProvider);
  return QrPaymentRepository(remoteDataSource);
});

final myQrCodesProvider = FutureProvider<List<QrCodeEntity>>((ref) async {
  final repository = ref.watch(qrPaymentRepositoryProvider);
  final result = await repository.getMyQrCodes();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (codes) => codes,
  );
});

final myQrPaymentsProvider = FutureProvider<List<QrPaymentEntity>>((ref) async {
  final repository = ref.watch(qrPaymentRepositoryProvider);
  final result = await repository.getMyPayments();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (payments) => payments,
  );
});

final receivedQrPaymentsProvider = FutureProvider<List<QrPaymentEntity>>((ref) async {
  final repository = ref.watch(qrPaymentRepositoryProvider);
  final result = await repository.getReceivedPayments();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (payments) => payments,
  );
});

class QrGenerateState {
  final bool isLoading;
  final String? error;
  final QrCodeEntity? generatedCode;

  const QrGenerateState({
    this.isLoading = false,
    this.error,
    this.generatedCode,
  });

  QrGenerateState copyWith({
    bool? isLoading,
    String? error,
    QrCodeEntity? generatedCode,
  }) {
    return QrGenerateState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      generatedCode: generatedCode ?? this.generatedCode,
    );
  }
}

class QrGenerateNotifier extends StateNotifier<QrGenerateState> {
  final QrPaymentRepository _repository;
  final Ref _ref;

  QrGenerateNotifier(this._repository, this._ref) : super(const QrGenerateState());

  Future<bool> generateQrCode({
    required QrCodeType qrType,
    double? amount,
    String? description,
    int? expiresInMinutes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.generateQrCode(
      qrType: qrType,
      amount: amount,
      description: description,
      expiresInMinutes: expiresInMinutes,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (code) {
        state = state.copyWith(isLoading: false, generatedCode: code);
        _ref.invalidate(myQrCodesProvider);
        return true;
      },
    );
  }

  void reset() {
    state = const QrGenerateState();
  }
}

final qrGenerateNotifierProvider =
    StateNotifierProvider<QrGenerateNotifier, QrGenerateState>((ref) {
  final repository = ref.watch(qrPaymentRepositoryProvider);
  return QrGenerateNotifier(repository, ref);
});

class QrScanState {
  final bool isLoading;
  final String? error;
  final QrCodeEntity? scannedCode;

  const QrScanState({
    this.isLoading = false,
    this.error,
    this.scannedCode,
  });

  QrScanState copyWith({
    bool? isLoading,
    String? error,
    QrCodeEntity? scannedCode,
  }) {
    return QrScanState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      scannedCode: scannedCode,
    );
  }
}

class QrScanNotifier extends StateNotifier<QrScanState> {
  final QrPaymentRepository _repository;

  QrScanNotifier(this._repository) : super(const QrScanState());

  Future<bool> scanQrCode(String qrToken) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.scanQrCode(qrToken);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (code) {
        state = state.copyWith(isLoading: false, scannedCode: code);
        return true;
      },
    );
  }

  void reset() {
    state = const QrScanState();
  }
}

final qrScanNotifierProvider =
    StateNotifierProvider<QrScanNotifier, QrScanState>((ref) {
  final repository = ref.watch(qrPaymentRepositoryProvider);
  return QrScanNotifier(repository);
});

class QrPayState {
  final bool isLoading;
  final String? error;
  final QrPaymentEntity? payment;

  const QrPayState({
    this.isLoading = false,
    this.error,
    this.payment,
  });

  QrPayState copyWith({
    bool? isLoading,
    String? error,
    QrPaymentEntity? payment,
  }) {
    return QrPayState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      payment: payment,
    );
  }
}

class QrPayNotifier extends StateNotifier<QrPayState> {
  final QrPaymentRepository _repository;
  final Ref _ref;

  QrPayNotifier(this._repository, this._ref) : super(const QrPayState());

  Future<bool> pay({
    required String qrToken,
    double? amount,
    String? description,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.payWithQrCode(
      qrToken: qrToken,
      amount: amount,
      description: description,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (payment) {
        state = state.copyWith(isLoading: false, payment: payment);
        _ref.invalidate(myQrPaymentsProvider);
        return true;
      },
    );
  }

  void reset() {
    state = const QrPayState();
  }
}

final qrPayNotifierProvider =
    StateNotifierProvider<QrPayNotifier, QrPayState>((ref) {
  final repository = ref.watch(qrPaymentRepositoryProvider);
  return QrPayNotifier(repository, ref);
});
