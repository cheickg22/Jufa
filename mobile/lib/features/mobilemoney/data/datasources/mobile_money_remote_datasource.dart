import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/mobile_money_model.dart';

class MobileMoneyRemoteDataSource {
  final ApiClient _apiClient;

  MobileMoneyRemoteDataSource(this._apiClient);

  Future<List<ProviderInfoModel>> getProviders() async {
    final response = await _apiClient.get(ApiConstants.momoProviders);
    final List<dynamic> data = response['data'];
    return data.map((json) => ProviderInfoModel.fromJson(json)).toList();
  }

  Future<MobileMoneyOperationModel> initiateDeposit(DepositRequestModel request) async {
    final response = await _apiClient.post(
      ApiConstants.momoDeposit,
      data: request.toJson(),
    );
    return MobileMoneyOperationModel.fromJson(response['data']);
  }

  Future<MobileMoneyOperationModel> confirmDeposit(ConfirmDepositRequestModel request) async {
    final response = await _apiClient.post(
      ApiConstants.momoDepositConfirm,
      data: request.toJson(),
    );
    return MobileMoneyOperationModel.fromJson(response['data']);
  }

  Future<MobileMoneyOperationModel> initiateWithdrawal(WithdrawalRequestModel request) async {
    final response = await _apiClient.post(
      ApiConstants.momoWithdrawal,
      data: request.toJson(),
    );
    return MobileMoneyOperationModel.fromJson(response['data']);
  }

  Future<MobileMoneyOperationModel> cancelOperation(String reference) async {
    final response = await _apiClient.post(ApiConstants.momoCancelOperation(reference));
    return MobileMoneyOperationModel.fromJson(response['data']);
  }

  Future<MobileMoneyOperationModel> getOperation(String reference) async {
    final response = await _apiClient.get(ApiConstants.momoOperation(reference));
    return MobileMoneyOperationModel.fromJson(response['data']);
  }

  Future<List<MobileMoneyOperationModel>> getOperations({int page = 0, int size = 20}) async {
    final response = await _apiClient.get(
      ApiConstants.momoOperations,
      queryParams: {'page': page.toString(), 'size': size.toString()},
    );
    final List<dynamic> content = response['data']['content'] ?? [];
    return content.map((json) => MobileMoneyOperationModel.fromJson(json)).toList();
  }

  Future<List<MobileMoneyOperationModel>> getDeposits({int page = 0, int size = 20}) async {
    final response = await _apiClient.get(
      ApiConstants.momoDeposits,
      queryParams: {'page': page.toString(), 'size': size.toString()},
    );
    final List<dynamic> content = response['data']['content'] ?? [];
    return content.map((json) => MobileMoneyOperationModel.fromJson(json)).toList();
  }

  Future<List<MobileMoneyOperationModel>> getWithdrawals({int page = 0, int size = 20}) async {
    final response = await _apiClient.get(
      ApiConstants.momoWithdrawals,
      queryParams: {'page': page.toString(), 'size': size.toString()},
    );
    final List<dynamic> content = response['data']['content'] ?? [];
    return content.map((json) => MobileMoneyOperationModel.fromJson(json)).toList();
  }
}
