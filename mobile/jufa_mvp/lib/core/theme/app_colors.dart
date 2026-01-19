import 'package:flutter/material.dart';

class AppColors {
  // Couleurs par défaut
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);
  
  static const Color secondary = Color(0xFF0D47A1);
  static const Color secondaryDark = Color(0xFF0A3D91);
  static const Color secondaryLight = Color(0xFF1E88E5);
  
  static const Color accent = Color(0xFF2196F3);
  static const Color accentLight = Color(0xFF64B5F6);
  
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E0E0);
  
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  static const Color inputBackground = Color(0xFFF5F5F5);
  static const Color inputBorder = Color(0xFFE0E0E0);
  
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Transaction Colors
  static const Color income = Color(0xFF4CAF50);
  static const Color expense = Color(0xFFE53935);
  static const Color pending = Color(0xFFFF9800);
  
  // Feature Colors
  static const Color transfer = Color(0xFF1976D2);
  static const Color payment = Color(0xFF1565C0);
  static const Color airtime = Color(0xFF42A5F5);
  static const Color bills = Color(0xFF9C27B0); // Violet pour les factures
  static const Color nege = Color(0xFF2196F3); // Bleu
  
  // Operator Colors (Mali)
  static const Color orangeMali = Color(0xFFFF6600);
  static const Color malitel = Color(0xFF009FDA);
  static const Color moov = Color(0xFF00A9E0);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF1976D2), Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);
}
