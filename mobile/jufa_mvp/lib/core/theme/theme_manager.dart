import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';
import 'design_system.dart';

/// Gestionnaire de thèmes avec support du mode sombre
class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color';
  
  ThemeMode _themeMode = ThemeMode.system;
  Color _accentColor = JufaDesignSystem.primaryBlue;
  
  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// Initialiser le gestionnaire de thèmes
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Charger le mode de thème
    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeIndex];
    
    // Charger la couleur d'accent
    final colorValue = prefs.getInt(_accentColorKey) ?? JufaDesignSystem.primaryBlue.value;
    _accentColor = Color(colorValue);
    
    notifyListeners();
  }

  /// Changer le mode de thème
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    // Sauvegarder la préférence
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    
    // Mettre à jour la barre de statut
    _updateSystemUI();
  }

  /// Changer la couleur d'accent
  Future<void> setAccentColor(Color color) async {
    if (_accentColor == color) return;
    
    _accentColor = color;
    notifyListeners();
    
    // Sauvegarder la préférence
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentColorKey, color.value);
  }

  /// Basculer entre clair et sombre
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Obtenir le thème clair
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _accentColor,
        brightness: Brightness.light,
      ),
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: JufaDesignSystem.headingSmall.copyWith(
          color: JufaDesignSystem.neutral900,
        ),
        iconTheme: const IconThemeData(
          color: JufaDesignSystem.neutral700,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: JufaDesignSystem.neutral50,
      
      // Card
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: JufaDesignSystem.elevation2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(JufaDesignSystem.radiusLarge),
        ),
      ),
      
      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
          elevation: JufaDesignSystem.elevation2,
          padding: const EdgeInsets.symmetric(
            horizontal: JufaDesignSystem.spacing24,
            vertical: JufaDesignSystem.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(JufaDesignSystem.radiusMedium),
          ),
          textStyle: JufaDesignSystem.labelLarge,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _accentColor,
          side: BorderSide(color: _accentColor),
          padding: const EdgeInsets.symmetric(
            horizontal: JufaDesignSystem.spacing24,
            vertical: JufaDesignSystem.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(JufaDesignSystem.radiusMedium),
          ),
          textStyle: JufaDesignSystem.labelLarge,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _accentColor,
          padding: const EdgeInsets.symmetric(
            horizontal: JufaDesignSystem.spacing16,
            vertical: JufaDesignSystem.spacing8,
          ),
          textStyle: JufaDesignSystem.labelLarge,
        ),
      ),
      
      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: JufaDesignSystem.neutral100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(JufaDesignSystem.radiusMedium),
          borderSide: const BorderSide(color: JufaDesignSystem.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(JufaDesignSystem.radiusMedium),
          borderSide: const BorderSide(color: JufaDesignSystem.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(JufaDesignSystem.radiusMedium),
          borderSide: BorderSide(color: _accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(JufaDesignSystem.radiusMedium),
          borderSide: const BorderSide(color: JufaDesignSystem.errorRed),
        ),
        contentPadding: const EdgeInsets.all(JufaDesignSystem.spacing16),
        hintStyle: JufaDesignSystem.bodyMedium.copyWith(
          color: JufaDesignSystem.neutral500,
        ),
      ),
      
      // Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _accentColor,
        unselectedItemColor: JufaDesignSystem.neutral500,
        type: BottomNavigationBarType.fixed,
        elevation: JufaDesignSystem.elevation8,
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: JufaDesignSystem.neutral200,
        thickness: 1,
      ),
      
      // Typographie
      textTheme: const TextTheme(
        displayLarge: JufaDesignSystem.headingXLarge,
        displayMedium: JufaDesignSystem.headingLarge,
        displaySmall: JufaDesignSystem.headingMedium,
        headlineLarge: JufaDesignSystem.headingLarge,
        headlineMedium: JufaDesignSystem.headingMedium,
        headlineSmall: JufaDesignSystem.headingSmall,
        titleLarge: JufaDesignSystem.headingSmall,
        titleMedium: JufaDesignSystem.bodyLarge,
        titleSmall: JufaDesignSystem.bodyMedium,
        bodyLarge: JufaDesignSystem.bodyLarge,
        bodyMedium: JufaDesignSystem.bodyMedium,
        bodySmall: JufaDesignSystem.bodySmall,
        labelLarge: JufaDesignSystem.labelLarge,
        labelMedium: JufaDesignSystem.labelMedium,
        labelSmall: JufaDesignSystem.labelSmall,
      ).apply(
        bodyColor: JufaDesignSystem.neutral900,
        displayColor: JufaDesignSystem.neutral900,
      ),
    );
  }

  /// Obtenir le thème sombre
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _accentColor,
        brightness: Brightness.dark,
      ),
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: JufaDesignSystem.headingSmall.copyWith(
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(
          color: JufaDesignSystem.neutral300,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: JufaDesignSystem.darkBackground,
      
      // Card
      cardTheme: CardThemeData(
        color: JufaDesignSystem.darkCard,
        elevation: JufaDesignSystem.elevation4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(JufaDesignSystem.radiusLarge),
        ),
      ),
      
      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
          elevation: JufaDesignSystem.elevation4,
          padding: const EdgeInsets.symmetric(
            horizontal: JufaDesignSystem.spacing24,
            vertical: JufaDesignSystem.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(JufaDesignSystem.radiusMedium),
          ),
          textStyle: JufaDesignSystem.labelLarge,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _accentColor,
          side: BorderSide(color: _accentColor),
          padding: const EdgeInsets.symmetric(
            horizontal: JufaDesignSystem.spacing24,
            vertical: JufaDesignSystem.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(JufaDesignSystem.radiusMedium),
          ),
          textStyle: JufaDesignSystem.labelLarge,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _accentColor,
          padding: const EdgeInsets.symmetric(
            horizontal: JufaDesignSystem.spacing16,
            vertical: JufaDesignSystem.spacing8,
          ),
          textStyle: JufaDesignSystem.labelLarge,
        ),
      ),
      
      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: JufaDesignSystem.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(JufaDesignSystem.radiusMedium),
          borderSide: const BorderSide(color: JufaDesignSystem.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(JufaDesignSystem.radiusMedium),
          borderSide: const BorderSide(color: JufaDesignSystem.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(JufaDesignSystem.radiusMedium),
          borderSide: BorderSide(color: _accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(JufaDesignSystem.radiusMedium),
          borderSide: const BorderSide(color: JufaDesignSystem.errorRed),
        ),
        contentPadding: const EdgeInsets.all(JufaDesignSystem.spacing16),
        hintStyle: JufaDesignSystem.bodyMedium.copyWith(
          color: JufaDesignSystem.neutral500,
        ),
      ),
      
      // Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: JufaDesignSystem.darkSurface,
        selectedItemColor: _accentColor,
        unselectedItemColor: JufaDesignSystem.neutral500,
        type: BottomNavigationBarType.fixed,
        elevation: JufaDesignSystem.elevation8,
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: JufaDesignSystem.darkBorder,
        thickness: 1,
      ),
      
      // Typographie
      textTheme: const TextTheme(
        displayLarge: JufaDesignSystem.headingXLarge,
        displayMedium: JufaDesignSystem.headingLarge,
        displaySmall: JufaDesignSystem.headingMedium,
        headlineLarge: JufaDesignSystem.headingLarge,
        headlineMedium: JufaDesignSystem.headingMedium,
        headlineSmall: JufaDesignSystem.headingSmall,
        titleLarge: JufaDesignSystem.headingSmall,
        titleMedium: JufaDesignSystem.bodyLarge,
        titleSmall: JufaDesignSystem.bodyMedium,
        bodyLarge: JufaDesignSystem.bodyLarge,
        bodyMedium: JufaDesignSystem.bodyMedium,
        bodySmall: JufaDesignSystem.bodySmall,
        labelLarge: JufaDesignSystem.labelLarge,
        labelMedium: JufaDesignSystem.labelMedium,
        labelSmall: JufaDesignSystem.labelSmall,
      ).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
  }

  /// Mettre à jour l'interface système
  void _updateSystemUI() {
    final brightness = _themeMode == ThemeMode.dark 
        ? Brightness.dark 
        : Brightness.light;
    
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness == Brightness.dark 
            ? Brightness.light 
            : Brightness.dark,
        systemNavigationBarColor: brightness == Brightness.dark 
            ? JufaDesignSystem.darkSurface 
            : Colors.white,
        systemNavigationBarIconBrightness: brightness == Brightness.dark 
            ? Brightness.light 
            : Brightness.dark,
      ),
    );
  }

  /// Couleurs d'accent prédéfinies
  static const List<Color> accentColors = [
    JufaDesignSystem.primaryBlue,
    JufaDesignSystem.secondaryGreen,
    JufaDesignSystem.secondaryOrange,
    JufaDesignSystem.secondaryPurple,
    Colors.red,
    Colors.pink,
    Colors.indigo,
    Colors.teal,
  ];

  /// Obtenir le nom du mode de thème
  String get themeModeDisplayName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
      case ThemeMode.system:
        return 'Système';
    }
  }
}
