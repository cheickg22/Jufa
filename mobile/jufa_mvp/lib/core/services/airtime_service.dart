import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'auth_service.dart';

class AirtimeService {
  final Dio _dio = Dio();

  /// Effectuer une recharge Airtime
  Future<Map<String, dynamic>> rechargeAirtime({
    required String phoneNumber,
    required double amount,
    required String operator,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Non authentifié');
      }

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/airtime/recharge',
        data: {
          'phone_number': phoneNumber,
          'amount': amount,
          'operator': operator,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la recharge');
      }
    } on DioException catch (e) {
      print('❌ Erreur API recharge airtime: ${e.response?.data}');
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion');
    }
  }
}
