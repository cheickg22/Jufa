import 'package:flutter/material.dart';

/// Couleurs spécifiques pour l'application Agent JUFA
class AgentColors {
  // Couleurs principales - Orange/Amber pour différencier  // Couleurs principales
  static const Color primary = Color(0xFF2196F3); // Bleu
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);
  
  static const Color secondary = Color(0xFF1E88E5); // Bleu foncé
  static const Color secondaryDark = Color(0xFF1565C0);
  static const Color secondaryLight = Color(0xFF42A5F5);
  
  // Couleurs d'action
  static const Color success = Color(0xFF4CAF50); // Vert pour dépôts
  static const Color error = Color(0xFFF44336); // Rouge pour retraits
  static const Color warning = Color(0xFF2196F3);
  static const Color info = Color(0xFF2196F3);
  
  // Couleurs de fond
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;
  
  // Couleurs de texte
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Colors.white;
  
  // Bordures et dividers
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient depositGradient = LinearGradient(
    colors: [success, Color(0xFF66BB6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient withdrawalGradient = LinearGradient(
    colors: [error, Color(0xFFEF5350)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Ombres
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}
