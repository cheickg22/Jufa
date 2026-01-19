import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/offline_cache_service.dart';

final themeServiceProvider = Provider<ThemeService>((ref) {
  final cache = ref.watch(offlineCacheServiceProvider);
  return ThemeService(cache);
});

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final service = ref.watch(themeServiceProvider);
  return ThemeModeNotifier(service);
});

class ThemeService {
  static const String _themeKey = 'theme_mode';
  final OfflineCacheService _cache;
  
  ThemeService(this._cache);
  
  ThemeMode getThemeMode() {
    final value = _cache.getSetting<String>(_themeKey);
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    String value;
    switch (mode) {
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }
    await _cache.saveSetting(_themeKey, value);
  }
}

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final ThemeService _service;
  
  ThemeModeNotifier(this._service) : super(ThemeMode.system) {
    _init();
  }
  
  void _init() {
    state = _service.getThemeMode();
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    await _service.setThemeMode(mode);
    state = mode;
  }
  
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}
