import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/config/app_config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pré-remplir le champ téléphone avec l'indicatif malien
    _identifierController.text = '+223 ';
    // Positionner le curseur à la fin
    _identifierController.selection = TextSelection.fromPosition(
      TextPosition(offset: _identifierController.text.length),
    );
    _loadLoginData();
  }

  Future<void> _loadLoginData() async {
    // Seulement pré-remplir si on vient de l'inscription (avec des données passées)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final extra = GoRouterState.of(context).extra;
      if (extra is Map<String, dynamic>) {
        // Pré-remplir UNIQUEMENT avec les données depuis l'inscription
        final phone = extra['phone'] as String?;
        final password = extra['password'] as String?;
        
        // Priorité au téléphone
        if (phone != null && phone.isNotEmpty) {
          _identifierController.text = phone;
        }
        
        if (password != null && password.isNotEmpty) {
          _passwordController.text = password;
        }
      }
      // Sinon, laisser les champs vides (pas de pré-remplissage automatique)
    });
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _reloadUserDataForIdentifier(String identifier) async {
    try {
      await UserService.restoreUserDataForIdentifier(identifier);
    } catch (e) {
      print('Erreur lors de la restauration des données utilisateur: $e');
    }
  }

  String _formatMalianPhone(String value) {
    // Supprimer tous les espaces
    String cleaned = value.replaceAll(' ', '');
    
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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    final l10n = AppLocalizations.of(context);
    setState(() => _isLoading = true);
    
    // Récupérer les identifiants saisis et nettoyer
    final rawIdentifier = _identifierController.text.trim();
    // Supprimer tous les espaces pour l'API
    final identifier = rawIdentifier.replaceAll(' ', '');
    final password = _passwordController.text;
    
    print('🔐 Tentative de connexion avec: $identifier (nettoyé depuis: $rawIdentifier)');
    
    try {
      // Appel API pour la connexion
      print('📡 Appel API login avec identifier: $identifier');
      
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      final response = await dio.post(
        '${AppConfig.apiBaseUrl}/auth/login',
        data: {
          'identifier': identifier,
          'password': password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      
      print('✅ Réponse API: ${response.data}');
      
      if (response.data['success'] == true) {
        // Sauvegarder le token d'authentification
        final token = response.data['data']['token'];
        await AuthService.saveToken(token);
        print('🔑 Token sauvegardé: ${token.substring(0, 20)}...');
        
        // Sauvegarder les données utilisateur
        final userData = response.data['data']['user'];
        
        // Sauvegarder l'ID utilisateur
        await UserService.saveUserId(userData['id'].toString());
        
        // Sauvegarder dans les clés globales (pour le dashboard)
        final balance = userData['balance'];
        final balanceDouble = balance is String ? double.parse(balance) : (balance ?? 0).toDouble();
        
        await UserService.saveUserInfo(
          firstName: userData['first_name'],
          lastName: userData['last_name'],
          email: userData['email'] ?? '',
          phone: userData['phone'],
          password: password,
          balance: balanceDouble,
        );
        
        // Sauvegarder l'ID utilisateur
        await UserService.saveUserId(userData['id'].toString());
        
        print('💾 Données utilisateur sauvegardées localement (ID: ${userData['id']})');
        
        if (!mounted) return;
        setState(() => _isLoading = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('login_success')),
            backgroundColor: AppColors.success,
          ),
        );
        
        context.go('/dashboard');
      } else {
        throw Exception(response.data['message'] ?? 'Erreur de connexion');
      }
      
    } catch (e) {
      print('❌ Erreur login: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('login_error')),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Logo
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        'JUFA',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Titre
                Text(
                  l10n.translate('welcome_back'),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.translate('login_subtitle'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                
                const SizedBox(height: 40),
                
                // Numéro de téléphone
                TextFormField(
                  controller: _identifierController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
                    _PhoneNumberFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.translate('phone_number'),
                    hintText: l10n.translate('phone_hint'),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('🇲🇱', style: TextStyle(fontSize: 24)),
                    ),
                    helperText: l10n.translate('use_phone_number'),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.translate('field_required');
                    }
                    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (digitsOnly.length < 11) {
                      return l10n.translate('incomplete_number');
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: l10n.translate('password'),
                    hintText: l10n.translate('enter_password'),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.translate('field_required');
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Mot de passe oublié
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: Text(l10n.translate('forgot_password')),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Bouton de connexion
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
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
                      : Text(l10n.translate('login')),
                ),
                
                const SizedBox(height: 24),
                
                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.translate('or'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Bouton de connexion biométrique
                OutlinedButton.icon(
                  onPressed: () => context.go('/biometric-login'),
                  icon: Icon(Icons.fingerprint),
                  label: Text(l10n.translate('biometric_login')),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Bouton d'inscription
                OutlinedButton(
                  onPressed: () => context.go('/register'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: Text(l10n.translate('create_account')),
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
