import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../config/app_config.dart';

class ThemeService {
  final Dio _dio = Dio();

  /// Récupérer le thème de l'application depuis l'API
  Future<Map<String, dynamic>> getUserTheme() async {
    try {
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/theme/user',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération du thème');
      }
    } on DioException catch (e) {
      print('❌ Erreur API thème: ${e.response?.data}');
      // Retourner les valeurs par défaut en cas d'erreur
      return _getDefaultTheme();
    } catch (e) {
      print('❌ Erreur thème: $e');
      return _getDefaultTheme();
    }
  }

  /// Convertir une couleur hexadécimale en Color Flutter
  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Thème par défaut si l'API échoue
  Map<String, dynamic> _getDefaultTheme() {
    return {
      'primary_color': '#6366f1',
      'secondary_color': '#8b5cf6',
      'accent_color': '#ec4899',
      'background_color': '#ffffff',
      'text_color': '#1f2937',
      'error_color': '#ef4444',
      'success_color': '#10b981',
      'warning_color': '#f59e0b',
      'icon_color': '#6366f1',
      'icon_size': 24.0,
      'font_family': 'Roboto',
      'font_size_small': 12.0,
      'font_size_medium': 14.0,
      'font_size_large': 16.0,
      'font_size_xlarge': 20.0,
      'border_radius': 8.0,
      'button_height': 48.0,
      'spacing': 16.0,
    };
  }
}
