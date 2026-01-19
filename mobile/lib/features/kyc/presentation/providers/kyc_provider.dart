import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/kyc_remote_datasource.dart';
import '../../data/repositories/kyc_repository.dart';
import '../../domain/entities/kyc_document_entity.dart';

final kycRemoteDataSourceProvider = Provider<KycRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return KycRemoteDataSource(apiClient);
});

final kycRepositoryProvider = Provider<KycRepository>((ref) {
  final remoteDataSource = ref.watch(kycRemoteDataSourceProvider);
  return KycRepository(remoteDataSource);
});

final kycStatusProvider = FutureProvider<KycStatusEntity>((ref) async {
  final repository = ref.watch(kycRepositoryProvider);
  final result = await repository.getKycStatus();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (status) => status,
  );
});

final kycDocumentsProvider = FutureProvider<List<KycDocumentEntity>>((ref) async {
  final repository = ref.watch(kycRepositoryProvider);
  final result = await repository.getMyDocuments();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (docs) => docs,
  );
});

class KycUploadState {
  final bool isLoading;
  final String? error;
  final KycDocumentEntity? uploadedDocument;

  const KycUploadState({
    this.isLoading = false,
    this.error,
    this.uploadedDocument,
  });

  KycUploadState copyWith({
    bool? isLoading,
    String? error,
    KycDocumentEntity? uploadedDocument,
  }) {
    return KycUploadState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      uploadedDocument: uploadedDocument ?? this.uploadedDocument,
    );
  }
}

class KycUploadNotifier extends StateNotifier<KycUploadState> {
  final KycRepository _repository;
  final Ref _ref;

  KycUploadNotifier(this._repository, this._ref) : super(const KycUploadState());

  Future<bool> uploadDocument({
    required String filePath,
    required String fileName,
    required DocumentType documentType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.uploadDocument(
      filePath: filePath,
      fileName: fileName,
      documentType: documentType,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (document) {
        state = state.copyWith(isLoading: false, uploadedDocument: document);
        _ref.invalidate(kycStatusProvider);
        _ref.invalidate(kycDocumentsProvider);
        return true;
      },
    );
  }

  void reset() {
    state = const KycUploadState();
  }
}

final kycUploadNotifierProvider =
    StateNotifierProvider<KycUploadNotifier, KycUploadState>((ref) {
  final repository = ref.watch(kycRepositoryProvider);
  return KycUploadNotifier(repository, ref);
});
