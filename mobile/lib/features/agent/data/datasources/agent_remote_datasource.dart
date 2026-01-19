import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/agent_dashboard_model.dart';
import '../models/agent_transaction_model.dart';
import '../models/agent_daily_report_model.dart';
import '../models/fee_calculation_model.dart';
import '../models/client_info_model.dart';

class CashInRequestModel {
  final String customerPhone;
  final double amount;
  final String? description;

  CashInRequestModel({
    required this.customerPhone,
    required this.amount,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'customerPhone': customerPhone,
        'amount': amount,
        if (description != null) 'description': description,
      };
}

class CashOutRequestModel {
  final String customerPhone;
  final double amount;
  final String customerPin;
  final String? description;

  CashOutRequestModel({
    required this.customerPhone,
    required this.amount,
    required this.customerPin,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'customerPhone': customerPhone,
        'amount': amount,
        'customerPin': customerPin,
        if (description != null) 'description': description,
      };
}

class AgentRemoteDatasource {
  final ApiClient _apiClient;

  AgentRemoteDatasource(this._apiClient);

  Future<AgentDashboardModel> getDashboard() async {
    final response = await _apiClient.get(ApiConstants.agentDashboard);
    return AgentDashboardModel.fromJson(response['data']);
  }

  Future<AgentTransactionModel> processCashIn(CashInRequestModel request) async {
    final response = await _apiClient.post(
      ApiConstants.agentCashIn,
      data: request.toJson(),
    );
    return AgentTransactionModel.fromJson(response['data']);
  }

  Future<AgentTransactionModel> processCashOut(CashOutRequestModel request) async {
    final response = await _apiClient.post(
      ApiConstants.agentCashOut,
      data: request.toJson(),
    );
    return AgentTransactionModel.fromJson(response['data']);
  }

  Future<FeeCalculationModel> calculateCashInFees(double amount) async {
    final response = await _apiClient.get(ApiConstants.agentFeesCashIn(amount));
    return FeeCalculationModel.fromJson(response['data']);
  }

  Future<FeeCalculationModel> calculateCashOutFees(double amount) async {
    final response = await _apiClient.get(ApiConstants.agentFeesCashOut(amount));
    return FeeCalculationModel.fromJson(response['data']);
  }

  Future<List<AgentTransactionModel>> getTransactions({int page = 0, int size = 20}) async {
    final response = await _apiClient.get(
      ApiConstants.agentTransactions,
      queryParams: {'page': page, 'size': size},
    );
    final content = response['data']?['content'] ?? response['data'] ?? [];
    return (content as List).map((json) => AgentTransactionModel.fromJson(json)).toList();
  }

  Future<List<AgentTransactionModel>> getCashInTransactions({int page = 0, int size = 20}) async {
    final response = await _apiClient.get(
      ApiConstants.agentTransactionsCashIn,
      queryParams: {'page': page, 'size': size},
    );
    final content = response['data']?['content'] ?? response['data'] ?? [];
    return (content as List).map((json) => AgentTransactionModel.fromJson(json)).toList();
  }

  Future<List<AgentTransactionModel>> getCashOutTransactions({int page = 0, int size = 20}) async {
    final response = await _apiClient.get(
      ApiConstants.agentTransactionsCashOut,
      queryParams: {'page': page, 'size': size},
    );
    final content = response['data']?['content'] ?? response['data'] ?? [];
    return (content as List).map((json) => AgentTransactionModel.fromJson(json)).toList();
  }

  Future<List<AgentDailyReportModel>> getLast30DaysReports() async {
    final response = await _apiClient.get(ApiConstants.agentReportsLast30Days);
    final data = response['data'] ?? [];
    return (data as List).map((json) => AgentDailyReportModel.fromJson(json)).toList();
  }

  Future<List<AgentDailyReportModel>> getReports(String startDate, String endDate) async {
    final response = await _apiClient.get(ApiConstants.agentReports(startDate, endDate));
    final data = response['data'] ?? [];
    return (data as List).map((json) => AgentDailyReportModel.fromJson(json)).toList();
  }

  Future<ClientInfoModel> searchClient(String phone) async {
    final response = await _apiClient.get(ApiConstants.agentSearchClient(phone));
    return ClientInfoModel.fromJson(response['data']);
  }

  Future<bool> verifySecretCode(String code) async {
    final response = await _apiClient.post(
      ApiConstants.agentVerifySecretCode,
      data: {'secretCode': code},
    );
    return response['data']?['success'] == true || response['success'] == true;
  }

  Future<void> updateSecretCode(String newCode, {String? oldCode}) async {
    await _apiClient.post(
      ApiConstants.agentUpdateSecretCode,
      data: {
        'newSecretCode': newCode,
        if (oldCode != null) 'oldSecretCode': oldCode,
      },
    );
  }
}
