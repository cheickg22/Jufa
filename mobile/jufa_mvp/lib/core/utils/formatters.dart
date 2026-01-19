import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class Formatters {
  // Formater une somme d'argent
  static String formatCurrency(double amount, {bool showSymbol = true}) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    final formatted = formatter.format(amount);
    return showSymbol ? '$formatted ${AppConstants.currencySymbol}' : formatted;
  }
  
  // Formater un numéro de téléphone malien
  static String formatPhoneNumber(String phone) {
    // Retirer les espaces et caractères spéciaux
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Format: +223 XX XX XX XX ou XX XX XX XX
    if (cleaned.startsWith('+223')) {
      final number = cleaned.substring(4);
      if (number.length == 8) {
        return '+223 ${number.substring(0, 2)} ${number.substring(2, 4)} ${number.substring(4, 6)} ${number.substring(6)}';
      }
    } else if (cleaned.length == 8) {
      return '${cleaned.substring(0, 2)} ${cleaned.substring(2, 4)} ${cleaned.substring(4, 6)} ${cleaned.substring(6)}';
    }
    
    return phone;
  }
  
  // Formater une date
  static String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) {
    return DateFormat(format, 'fr_FR').format(date);
  }
  
  // Formater une date et heure
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(dateTime);
  }
  
  // Formater seulement l'heure
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm', 'fr_FR').format(dateTime);
  }
  
  // Formater une date relative (il y a X jours)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'À l\'instant';
        }
        return 'Il y a ${difference.inMinutes} min';
      }
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else if (difference.inDays < 30) {
      return 'Il y a ${(difference.inDays / 7).floor()} semaines';
    } else if (difference.inDays < 365) {
      return 'Il y a ${(difference.inDays / 30).floor()} mois';
    } else {
      return 'Il y a ${(difference.inDays / 365).floor()} ans';
    }
  }
  
  // Masquer partiellement un numéro de téléphone
  static String maskPhoneNumber(String phone) {
    if (phone.length < 4) return phone;
    final visible = phone.substring(phone.length - 4);
    return '****$visible';
  }
  
  // Masquer partiellement un email
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) return email;
    
    final visibleStart = username.substring(0, 2);
    final maskedUsername = '$visibleStart***';
    
    return '$maskedUsername@$domain';
  }
  
  // Formater un numéro de compte
  static String formatAccountNumber(String accountNumber) {
    if (accountNumber.length < 4) return accountNumber;
    
    // Format: XXXX XXXX XXXX XXXX
    final buffer = StringBuffer();
    for (var i = 0; i < accountNumber.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(accountNumber[i]);
    }
    
    return buffer.toString();
  }
  
  // Capitaliser la première lettre
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  // Formater un pourcentage
  static String formatPercentage(double value, {int decimals = 2}) {
    return '${value.toStringAsFixed(decimals)}%';
  }
  
  // Formater un poids (grammes -> format lisible)
  static String formatWeight(double grams) {
    if (grams < 1000) {
      return '${grams.toStringAsFixed(2)} g';
    } else {
      return '${(grams / 1000).toStringAsFixed(2)} kg';
    }
  }
}
