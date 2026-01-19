import 'package:flutter/services.dart';

/// Formateur de numéro de téléphone pour le Mali (+223 XX XX XX XX)
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Si le texte est vide, retourner +223 
    if (text.isEmpty || text == '+' || text == '+2' || text == '+22' || text == '+223') {
      return const TextEditingValue(
        text: '+223 ',
        selection: TextSelection.collapsed(offset: 5),
      );
    }

    // Supprimer tous les espaces et le +
    String digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Si on commence à taper, enlever le 223 s'il est déjà là
    if (digitsOnly.startsWith('223')) {
      digitsOnly = digitsOnly.substring(3);
    }
    
    // Limiter à 8 chiffres (le numéro local)
    if (digitsOnly.length > 8) {
      digitsOnly = digitsOnly.substring(0, 8);
    }

    // Construire le numéro formaté avec +223 devant
    String formatted = '+223';
    
    if (digitsOnly.isNotEmpty) {
      formatted += ' ';
      
      // Ajouter les 2 premiers chiffres
      if (digitsOnly.length >= 2) {
        formatted += digitsOnly.substring(0, 2);
      } else {
        formatted += digitsOnly;
      }
      
      // Ajouter les 2 chiffres suivants
      if (digitsOnly.length > 2) {
        formatted += ' ${digitsOnly.substring(2, digitsOnly.length > 4 ? 4 : digitsOnly.length)}';
      }
      
      // Ajouter les 2 chiffres suivants
      if (digitsOnly.length > 4) {
        formatted += ' ${digitsOnly.substring(4, digitsOnly.length > 6 ? 6 : digitsOnly.length)}';
      }
      
      // Ajouter les 2 derniers chiffres
      if (digitsOnly.length > 6) {
        formatted += ' ${digitsOnly.substring(6, digitsOnly.length)}';
      }
    } else {
      formatted += ' ';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
