import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/merchant_model.dart';
import '../../domain/entities/merchant_entity.dart';

class MerchantRemoteDataSource {
  final ApiClient _apiClient;

  MerchantRemoteDataSource(this._apiClient);

  Future<MerchantProfileModel> createProfile({
    required MerchantType merchantType,
    required String businessName,
    String? businessCategory,
    String? rccmNumber,
    String? nifNumber,
    String? address,
    String? city,
    double? gpsLat,
    double? gpsLng,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.merchantProfile,
      data: {
        'merchantType': MerchantProfileModel.merchantTypeToString(merchantType),
        'businessName': businessName,
        'businessCategory': businessCategory,
        'rccmNumber': rccmNumber,
        'nifNumber': nifNumber,
        'address': address,
        'city': city,
        'gpsLat': gpsLat,
        'gpsLng': gpsLng,
      },
    );
    return MerchantProfileModel.fromJson(response['data']);
  }

  Future<MerchantProfileModel> getProfile() async {
    final response = await _apiClient.get(ApiConstants.merchantProfile);
    return MerchantProfileModel.fromJson(response['data']);
  }

  Future<MerchantDashboardModel> getDashboard() async {
    final response = await _apiClient.get(ApiConstants.merchantDashboard);
    return MerchantDashboardModel.fromJson(response['data']);
  }

  Future<List<MerchantProfileModel>> getWholesalers({String? city}) async {
    final queryParams = city != null ? {'city': city} : null;
    final response = await _apiClient.get(ApiConstants.merchantWholesalers, queryParams: queryParams);
    final List<dynamic> data = response['data'] ?? [];
    return data.map((e) => MerchantProfileModel.fromJson(e)).toList();
  }

  Future<List<RetailerRelationModel>> getMyRetailers() async {
    final response = await _apiClient.get(ApiConstants.merchantRetailers);
    final List<dynamic> data = response['data'] ?? [];
    return data.map((e) => RetailerRelationModel.fromJson(e)).toList();
  }

  Future<List<RetailerRelationModel>> getMyWholesalers() async {
    final response = await _apiClient.get(ApiConstants.merchantMyWholesalers);
    final List<dynamic> data = response['data'] ?? [];
    return data.map((e) => RetailerRelationModel.fromJson(e)).toList();
  }

  Future<RetailerRelationModel> addRetailer({
    required String retailerId,
    double? creditLimit,
    int? paymentTermsDays,
    double? discountRate,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.merchantRetailers,
      data: {
        'retailerId': retailerId,
        'creditLimit': creditLimit,
        'paymentTermsDays': paymentTermsDays,
        'discountRate': discountRate,
      },
    );
    return RetailerRelationModel.fromJson(response['data']);
  }

  Future<RetailerRelationModel> approveRelation(String relationId) async {
    final response = await _apiClient.post(ApiConstants.merchantRelationApprove(relationId));
    return RetailerRelationModel.fromJson(response['data']);
  }

  Future<RetailerRelationModel> updateRelation({
    required String relationId,
    double? creditLimit,
    int? paymentTermsDays,
    double? discountRate,
  }) async {
    final response = await _apiClient.put(
      ApiConstants.merchantRelation(relationId),
      data: {
        'creditLimit': creditLimit,
        'paymentTermsDays': paymentTermsDays,
        'discountRate': discountRate,
      },
    );
    return RetailerRelationModel.fromJson(response['data']);
  }

  Future<void> suspendRelation(String relationId) async {
    await _apiClient.post(ApiConstants.merchantRelationSuspend(relationId));
  }
}
