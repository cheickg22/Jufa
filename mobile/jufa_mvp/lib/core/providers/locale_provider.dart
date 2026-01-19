import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  
  Locale _locale = const Locale('fr');
  
  Locale get locale => _locale;
  
  String get languageCode => _locale.languageCode;
  
  String get languageName {
    switch (_locale.languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      default:
        return 'Français';
    }
  }
  
  LocaleProvider() {
    _loadLocale();
  }
  
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey) ?? 'fr';
    
    _locale = Locale(savedLocale);
    notifyListeners();
  }
  
  Future<void> setLocale(String languageCode) async {
    if (languageCode == _locale.languageCode) return;
    
    _locale = Locale(languageCode);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
    
    notifyListeners();
  }
  
  bool isLanguageSupported(String languageCode) {
    return ['fr', 'en'].contains(languageCode);
  }
}
