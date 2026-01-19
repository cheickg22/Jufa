import 'package:flutter/material.dart';

class AgentColors {
  // Couleurs principales
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color secondary = Color(0xFF26A69A);
  static const Color accent = Color(0xFFFF9800);
  
  // Couleurs de fond
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  
  // Couleurs de texte
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
  // Couleurs d'état
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Couleurs de bordure
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Shadows
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}
