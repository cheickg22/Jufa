import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/config/app_config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Pré-remplir le champ téléphone avec l'indicatif malien
    _phoneController.text = '+223 ';
    // Positionner le curseur à la fin
    _phoneController.selection = TextSelection.fromPosition(
      TextPosition(offset: _phoneController.text.length),
    );
  }
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _formatMalianPhone(String value) {
    // Supprimer tous les caractères non numériques sauf le +
    String cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');
    
    // S'assurer qu'on commence par +223
    if (!cleaned.startsWith('+223')) {
      cleaned = '+223' + cleaned.replaceAll('+223', '');
    }
    
    // Extraire les chiffres après +223
    String digits = cleaned.substring(4);
    
    // Limiter à 8 chiffres maximum
    if (digits.length > 8) {
      digits = digits.substring(0, 8);
    }
    
    // Formater selon la longueur
    if (digits.isEmpty) {
      return '+223 ';
    } else if (digits.length <= 2) {
      return '+223 $digits';
    } else if (digits.length <= 4) {
      return '+223 ${digits.substring(0, 2)} ${digits.substring(2)}';
    } else if (digits.length <= 6) {
      return '+223 ${digits.substring(0, 2)} ${digits.substring(2, 4)} ${digits.substring(4)}';
    } else {
      return '+223 ${digits.substring(0, 2)} ${digits.substring(2, 4)} ${digits.substring(4, 6)} ${digits.substring(6)}';
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    final l10n = AppLocalizations.of(context);
    
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('accept_terms_error')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    // Le téléphone est l'identifiant principal
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final identifier = phone; // Toujours utiliser le téléphone comme identifiant
    
    print('📝 Inscription avec identifiant: $identifier');
    print('📝 Email: $email');
    print('📝 Nom: ${_firstNameController.text.trim()} ${_lastNameController.text.trim()}');
    
    try {
      // Appel API pour l'inscription
      final dio = Dio();
      final cleanPhone = phone.replaceAll(' ', ''); // Supprimer les espaces
      
      final response = await dio.post(
        '${AppConfig.apiBaseUrl}/auth/register',
        data: {
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'email': email.isEmpty ? null : email,
          'phone': cleanPhone,
          'password': _passwordController.text,
          'password_confirmation': _passwordController.text,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      
      print('✅ Réponse API inscription: ${response.data}');
      
      if (response.data['success'] == true) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        
        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('account_created')),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Rediriger vers la page de vérification OTP
        context.go('/verify-otp');
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de l\'inscription');
      }
    } catch (e) {
      print('❌ Erreur inscription: $e');
      
      String errorMessage = l10n.translate('registration_error');
      if (e is DioException && e.response != null) {
        print('📋 Détails erreur: ${e.response?.data}');
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }
    
    // Rediriger vers la page de connexion avec le téléphone
    context.go('/login', extra: {
      'phone': _phoneController.text,
      'password': _passwordController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                Text(
                  l10n.translate('create_account_title'),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.translate('register_subtitle'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                
                const SizedBox(height: 32),
                
                // Prénom
                TextFormField(
                  controller: _firstNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l10n.translate('first_name'),
                    hintText: l10n.translate('enter_first_name'),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) => Validators.validateName(
                    value,
                    fieldName: 'Le prénom',
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Nom
                TextFormField(
                  controller: _lastNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l10n.translate('last_name'),
                    hintText: l10n.translate('enter_last_name'),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) => Validators.validateName(
                    value,
                    fieldName: 'Le nom',
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.translate('email'),
                    hintText: l10n.translate('email_example'),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validators.validateEmail,
                ),
                
                const SizedBox(height: 16),
                
                // Téléphone (obligatoire)
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.translate('phone_required'),
                    hintText: l10n.translate('phone_hint'),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('🇲🇱', style: TextStyle(fontSize: 24)),
                    ),
                    helperText: l10n.translate('phone_required_login'),
                  ),
                  onChanged: (value) {
                    // Empêcher la suppression de l'indicatif +223
                    if (!value.startsWith('+223 ')) {
                      _phoneController.text = '+223 ';
                      _phoneController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _phoneController.text.length),
                      );
                    } else {
                      // Formater le numéro automatiquement
                      String formatted = _formatMalianPhone(value);
                      if (formatted != value) {
                        _phoneController.text = formatted;
                        _phoneController.selection = TextSelection.fromPosition(
                          TextPosition(offset: formatted.length),
                        );
                      }
                    }
                  },
                  validator: Validators.validateMalianPhone,
                ),
                
                const SizedBox(height: 16),
                
                // Mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: l10n.translate('password'),
                    hintText: l10n.translate('password_hint'),
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: Validators.validatePassword,
                ),
                
                const SizedBox(height: 16),
                
                // Confirmation du mot de passe
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: l10n.translate('confirm_password'),
                    hintText: l10n.translate('reenter_password'),
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                  ),
                  validator: (value) => Validators.validateMatch(
                    value,
                    _passwordController.text,
                    'Le mot de passe',
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Acceptation des conditions
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() => _acceptTerms = value ?? false);
                      },
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _acceptTerms = !_acceptTerms);
                        },
                        child: Text.rich(
                          TextSpan(
                            text: l10n.translate('accept_terms'),
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: l10n.translate('terms_of_use'),
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(text: l10n.translate('and')),
                              TextSpan(
                                text: l10n.translate('privacy_policy'),
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Bouton d'inscription
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(l10n.translate('create_my_account')),
                ),
                
                const SizedBox(height: 24),
                
                // Lien vers la connexion
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text.rich(
                      TextSpan(
                        text: l10n.translate('already_have_account'),
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: l10n.translate('sign_in'),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
