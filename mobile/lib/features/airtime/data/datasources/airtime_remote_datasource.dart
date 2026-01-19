import '../../../../core/network/api_client.dart';
import '../models/airtime_model.dart';

class AirtimeRemoteDatasource {
  final ApiClient _apiClient;

  AirtimeRemoteDatasource(this._apiClient);

  Future<List<AirtimeOperatorModel>> getOperators() async {
    try {
      final response = await _apiClient.get('/v1/airtime/operators');
      final data = response['data'] as List<dynamic>? ?? [];
      return data.map((json) => AirtimeOperatorModel.fromJson(json)).toList();
    } catch (e) {
      return _getDefaultOperators();
    }
  }

  Future<AirtimeTransactionModel> recharge({
    required String operatorCode,
    required String phoneNumber,
    required double amount,
  }) async {
    final response = await _apiClient.post(
      '/v1/airtime/recharge',
      data: {
        'operatorCode': operatorCode,
        'phoneNumber': phoneNumber,
        'amount': amount,
      },
    );
    return AirtimeTransactionModel.fromJson(response['data']);
  }

  Future<List<AirtimeTransactionModel>> getHistory({int page = 0, int size = 20}) async {
    final response = await _apiClient.get(
      '/v1/airtime/history',
      queryParams: {'page': page, 'size': size},
    );
    final content = response['data']?['content'] ?? response['data'] ?? [];
    return (content as List).map((json) => AirtimeTransactionModel.fromJson(json)).toList();
  }

  List<AirtimeOperatorModel> _getDefaultOperators() {
    return const [
      AirtimeOperatorModel(
        id: '1',
        name: 'Orange Mali',
        code: 'ORANGE',
        quickAmounts: [500, 1000, 2000, 5000, 10000],
      ),
      AirtimeOperatorModel(
        id: '2',
        name: 'Moov Africa',
        code: 'MOOV',
        quickAmounts: [500, 1000, 2000, 5000, 10000],
      ),
      AirtimeOperatorModel(
        id: '3',
        name: 'Telecel Mali',
        code: 'TELECEL',
        quickAmounts: [500, 1000, 2000, 5000, 10000],
      ),
    ];
  }
}
