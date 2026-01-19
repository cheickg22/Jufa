import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/kyc_document_model.dart';
import '../../domain/entities/kyc_document_entity.dart';

class KycRemoteDataSource {
  final ApiClient _apiClient;

  KycRemoteDataSource(this._apiClient);

  Future<KycStatusModel> getKycStatus() async {
    final response = await _apiClient.get(ApiConstants.kycStatus);
    return KycStatusModel.fromJson(response['data']);
  }

  Future<KycDocumentModel> uploadDocument({
    required String filePath,
    required String fileName,
    required DocumentType documentType,
  }) async {
    final response = await _apiClient.uploadMultipart(
      ApiConstants.kycDocuments,
      filePath: filePath,
      fileName: fileName,
      fieldName: 'file',
      fields: {
        'documentType': KycDocumentModel.documentTypeToString(documentType),
      },
    );
    return KycDocumentModel.fromJson(response['data']);
  }

  Future<List<KycDocumentModel>> getMyDocuments() async {
    final response = await _apiClient.get(ApiConstants.kycDocuments);
    final List<dynamic> data = response['data'] ?? [];
    return data.map((e) => KycDocumentModel.fromJson(e)).toList();
  }
}
