import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final Dio _dio = Dio();
  
  bool _isLoading = false;
  bool _accountVerified = false;
  String? _userName;
  String? _userPhone;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    // Pré-remplir avec +223
    _identifierController.text = '+223 ';
    _identifierController.selection = TextSelection.fromPosition(
      TextPosition(offset: _identifierController.text.length),
    );
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyAccount() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    setState(() => _isLoading = true);

    try {
      // Nettoyer le numéro de téléphone
      var identifier = _identifierController.text.trim().replaceAll(' ', '');
      
      // Ajouter +223 si ce n'est pas déjà présent
      if (!identifier.startsWith('+')) {
        identifier = '+223$identifier';
      }

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/auth/verify-account',
        data: {'identifier': identifier},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true) {
        setState(() {
          _accountVerified = true;
          _userName = response.data['data']['name'];
          _userPhone = response.data['data']['phone'];
          _userEmail = response.data['data']['email'];
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('account_found_success')),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        throw Exception(response.data['message'] ?? 'Erreur de vérification');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      String errorMessage = l10n.translate('no_account_found');
      if (e is DioException && e.response != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('passwords_not_match')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Nettoyer le numéro de téléphone
      var identifier = _identifierController.text.trim().replaceAll(' ', '');
      
      // Ajouter +223 si ce n'est pas déjà présent
      if (!identifier.startsWith('+')) {
        identifier = '+223$identifier';
      }

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/auth/reset-password',
        data: {
          'identifier': identifier,
          'new_password': _newPasswordController.text,
          'new_password_confirmation': _confirmPasswordController.text,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('password_reset_success')),
            backgroundColor: AppColors.success,
          ),
        );

        // Retourner à la page de connexion
        context.go('/login');
      } else {
        throw Exception(response.data['message'] ?? 'Erreur de réinitialisation');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      String errorMessage = l10n.translate('password_reset_error');
      if (e is DioException && e.response != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('forgot_password_title')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icône
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_reset,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Titre et description
                Text(
                  _accountVerified ? l10n.translate('new_password_title') : l10n.translate('account_verification'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  _accountVerified
                      ? l10n.translate('enter_new_password')
                      : l10n.translate('enter_phone_verify'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Champ identifiant (toujours visible)
                TextFormField(
                  controller: _identifierController,
                  keyboardType: TextInputType.phone,
                  enabled: !_accountVerified && !_isLoading,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
                    _PhoneNumberFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.translate('phone_number'),
                    hintText: l10n.translate('phone_hint'),
                    prefixIcon: Text('🇲🇱', style: TextStyle(fontSize: 24)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.translate('enter_phone_number');
                    }
                    if (value.replaceAll(' ', '').length < 12) {
                      return l10n.translate('invalid_phone');
                    }
                    return null;
                  },
                ),
                
                // Informations du compte trouvé
                if (_accountVerified) ...[
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: AppColors.success, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              l10n.translate('account_found'),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${l10n.translate('name')}: $_userName',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (_userPhone != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${l10n.translate('phone')}: $_userPhone',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                        if (_userEmail != null && _userEmail!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${l10n.translate('email')}: $_userEmail',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Nouveau mot de passe
                  CustomTextField(
                    controller: _newPasswordController,
                    label: l10n.translate('new_password'),
                    hint: l10n.translate('min_8_chars'),
                    prefixIcon: Icons.lock,
                    obscureText: true,
                    enabled: !_isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.translate('enter_password_field');
                      }
                      if (value.length < 8) {
                        return l10n.translate('password_min_8');
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Confirmer mot de passe
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: l10n.translate('confirm_password_label'),
                    hint: l10n.translate('retype_password'),
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    enabled: !_isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.translate('confirm_password_field');
                      }
                      if (value != _newPasswordController.text) {
                        return l10n.translate('passwords_not_match');
                      }
                      return null;
                    },
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Bouton
                CustomButton(
                  text: _accountVerified ? l10n.translate('reset_password') : l10n.translate('verify_account'),
                  onPressed: _accountVerified ? _resetPassword : _verifyAccount,
                  isLoading: _isLoading,
                ),
                
                const SizedBox(height: 16),
                
                // Retour à la connexion
                TextButton(
                  onPressed: _isLoading ? null : () => context.go('/login'),
                  child: Text(l10n.translate('back_to_login')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Formatter pour le numéro de téléphone
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Si l'utilisateur efface tout, remettre +223
    if (text.isEmpty) {
      return const TextEditingValue(
        text: '+223 ',
        selection: TextSelection.collapsed(offset: 5),
      );
    }
    
    // Empêcher de supprimer +223
    if (!text.startsWith('+223')) {
      return oldValue;
    }
    
    // Extraire uniquement les chiffres après +223
    final digitsOnly = text.substring(4).replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limiter à 8 chiffres
    final limitedDigits = digitsOnly.length > 8 ? digitsOnly.substring(0, 8) : digitsOnly;
    
    // Formater: +223 XX XX XX XX
    String formatted = '+223';
    if (limitedDigits.isNotEmpty) {
      formatted += ' ';
      for (int i = 0; i < limitedDigits.length; i++) {
        if (i > 0 && i % 2 == 0) {
          formatted += ' ';
        }
        formatted += limitedDigits[i];
      }
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
