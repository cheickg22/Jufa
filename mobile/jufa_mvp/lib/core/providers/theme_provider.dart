import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeMode get themeMode => _themeMode;
  
  String get themeModeString {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'auto';
    }
  }
  
  ThemeProvider() {
    _loadTheme();
  }
  
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey) ?? 'light';
    
    switch (savedTheme) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'auto':
        _themeMode = ThemeMode.system;
        break;
      default:
        _themeMode = ThemeMode.light;
    }
    
    notifyListeners();
  }
  
  Future<void> setThemeMode(String mode) async {
    switch (mode) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'auto':
        _themeMode = ThemeMode.system;
        break;
      default:
        _themeMode = ThemeMode.light;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
    
    notifyListeners();
  }
}
