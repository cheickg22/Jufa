import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../providers/locale_provider.dart';

class LegalService {
  final Dio _dio = Dio();
  final LocaleProvider? _localeProvider;

  LegalService({LocaleProvider? localeProvider}) : _localeProvider = localeProvider;

  Future<Map<String, dynamic>> getLegalDocument(String type, {String? language}) async {
    try {
      // Utiliser la langue fournie ou celle du provider, sinon 'fr' par défaut
      final lang = language ?? _localeProvider?.languageCode ?? 'fr';
      
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/legal/$type',
        queryParameters: {'lang': lang},
      );

      return response.data;
    } catch (e) {
      print('❌ Erreur récupération document légal: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPrivacyPolicy() async {
    return await getLegalDocument('privacy_policy');
  }

  Future<Map<String, dynamic>> getTermsOfService() async {
    return await getLegalDocument('terms_of_service');
  }

  Future<Map<String, dynamic>> getAbout() async {
    return await getLegalDocument('about');
  }
}
