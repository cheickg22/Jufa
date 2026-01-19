import '../constants/app_constants.dart';

class Validators {
  // Valider un email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    
    if (!AppConstants.emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }
    
    return null;
  }
  
  // Valider un numéro de téléphone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de téléphone est requis';
    }
    
    final cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (!AppConstants.phoneRegex.hasMatch(cleaned)) {
      return 'Numéro de téléphone invalide';
    }
    
    return null;
  }
  
  // Valider un numéro de téléphone malien
  static String? validateMalianPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro est requis';
    }
    
    final cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (!AppConstants.malianPhoneRegex.hasMatch(cleaned)) {
      return 'Numéro malien invalide (8 chiffres requis)';
    }
    
    return null;
  }
  
  // Valider un mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    
    // Vérifier qu'il contient au moins une lettre et un chiffre
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins une lettre';
    }
    
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }
    
    return null;
  }
  
  // Valider un code PIN
  static String? validatePin(String? value, {int length = 4}) {
    if (value == null || value.isEmpty) {
      return 'Le code PIN est requis';
    }
    
    if (value.length != length) {
      return 'Le code PIN doit contenir $length chiffres';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Le code PIN ne doit contenir que des chiffres';
    }
    
    return null;
  }
  
  // Valider un montant
  static String? validateAmount(String? value, {
    double? minAmount,
    double? maxAmount,
  }) {
    if (value == null || value.isEmpty) {
      return 'Le montant est requis';
    }
    
    final amount = double.tryParse(value.replaceAll(',', '.'));
    
    if (amount == null) {
      return 'Montant invalide';
    }
    
    if (amount <= 0) {
      return 'Le montant doit être supérieur à 0';
    }
    
    if (minAmount != null && amount < minAmount) {
      return 'Le montant minimum est de $minAmount ${AppConstants.currencySymbol}';
    }
    
    if (maxAmount != null && amount > maxAmount) {
      return 'Le montant maximum est de $maxAmount ${AppConstants.currencySymbol}';
    }
    
    return null;
  }
  
  // Valider un nom
  static String? validateName(String? value, {String fieldName = 'Ce champ'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }
    
    if (value.length < 2) {
      return '$fieldName doit contenir au moins 2 caractères';
    }
    
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s\-]+$').hasMatch(value)) {
      return '$fieldName ne doit contenir que des lettres';
    }
    
    return null;
  }
  
  // Valider une date de naissance
  static String? validateBirthDate(DateTime? date) {
    if (date == null) {
      return 'La date de naissance est requise';
    }
    
    final now = DateTime.now();
    final age = now.year - date.year;
    
    if (age < 18) {
      return 'Vous devez avoir au moins 18 ans';
    }
    
    if (age > 120) {
      return 'Date de naissance invalide';
    }
    
    return null;
  }
  
  // Valider que deux champs correspondent (confirmation)
  static String? validateMatch(String? value, String? compareValue, String fieldName) {
    if (value != compareValue) {
      return '$fieldName ne correspond pas';
    }
    return null;
  }
  
  // Valider un champ non vide
  static String? validateRequired(String? value, {String fieldName = 'Ce champ'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }
  
  // Valider une longueur minimale
  static String? validateMinLength(String? value, int minLength, {String fieldName = 'Ce champ'}) {
    if (value == null || value.length < minLength) {
      return '$fieldName doit contenir au moins $minLength caractères';
    }
    return null;
  }
  
  // Valider une longueur maximale
  static String? validateMaxLength(String? value, int maxLength, {String fieldName = 'Ce champ'}) {
    if (value != null && value.length > maxLength) {
      return '$fieldName ne peut pas dépasser $maxLength caractères';
    }
    return null;
  }
}
