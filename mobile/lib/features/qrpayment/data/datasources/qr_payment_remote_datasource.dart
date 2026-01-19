import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/qr_payment_model.dart';
import '../../domain/entities/qr_payment_entity.dart';

class QrPaymentRemoteDataSource {
  final ApiClient _apiClient;

  QrPaymentRemoteDataSource(this._apiClient);

  Future<QrCodeModel> generateQrCode({
    required QrCodeType qrType,
    double? amount,
    String? description,
    int? expiresInMinutes,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.qrGenerate,
      data: {
        'qrType': QrCodeModel.qrCodeTypeToString(qrType),
        'amount': amount,
        'description': description,
        'expiresInMinutes': expiresInMinutes,
      },
    );
    return QrCodeModel.fromJson(response['data']);
  }

  Future<QrCodeModel> scanQrCode(String qrToken) async {
    final response = await _apiClient.get(ApiConstants.qrScan(qrToken));
    return QrCodeModel.fromJson(response['data']);
  }

  Future<QrPaymentModel> payWithQrCode({
    required String qrToken,
    double? amount,
    String? description,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.qrPay,
      data: {
        'qrToken': qrToken,
        'amount': amount,
        'description': description,
      },
    );
    return QrPaymentModel.fromJson(response['data']);
  }

  Future<List<QrCodeModel>> getMyQrCodes() async {
    final response = await _apiClient.get(ApiConstants.qrMyCodes);
    final List<dynamic> data = response['data'] ?? [];
    return data.map((e) => QrCodeModel.fromJson(e)).toList();
  }

  Future<List<QrPaymentModel>> getMyPayments({int page = 0, int size = 20}) async {
    final response = await _apiClient.get(
      ApiConstants.qrPayments,
      queryParams: {'page': page, 'size': size},
    );
    final List<dynamic> data = response['data'] ?? [];
    return data.map((e) => QrPaymentModel.fromJson(e)).toList();
  }

  Future<List<QrPaymentModel>> getReceivedPayments({int page = 0, int size = 20}) async {
    final response = await _apiClient.get(
      ApiConstants.qrReceived,
      queryParams: {'page': page, 'size': size},
    );
    final List<dynamic> data = response['data'] ?? [];
    return data.map((e) => QrPaymentModel.fromJson(e)).toList();
  }

  Future<void> deactivateQrCode(String qrCodeId) async {
    await _apiClient.delete(ApiConstants.qrDeactivate(qrCodeId));
  }
}
