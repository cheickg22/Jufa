import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../shared/widgets/jufa_widgets.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  
  @override
  void initState() {
    super.initState();
    _checkBiometricLogin();
  }
  
  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _checkBiometricLogin() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    
    final biometricState = ref.read(biometricNotifierProvider);
    if (biometricState.isAvailable && biometricState.isEnabled) {
      _handleBiometricLogin();
    }
  }
  
  Future<void> _handleBiometricLogin() async {
    final biometricNotifier = ref.read(biometricNotifierProvider.notifier);
    final authenticated = await biometricNotifier.authenticate();
    
    if (authenticated && mounted) {
      final credentials = await biometricNotifier.getCredentials();
      if (credentials != null) {
        ref.read(authNotifierProvider.notifier).login(
          credentials['phone']!,
          credentials['password']!,
        );
      }
    }
  }
  
  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authNotifierProvider.notifier).login(
        _phoneController.text.trim(),
        _passwordController.text,
      );
    }
  }
  
  Widget _buildBiometricButton() {
    final biometricState = ref.watch(biometricNotifierProvider);
    
    if (!biometricState.isAvailable || !biometricState.isEnabled) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: OutlinedButton.icon(
        onPressed: _handleBiometricLogin,
        icon: Icon(
          biometricState.biometricTypeName == 'Face ID'
              ? Icons.face
              : Icons.fingerprint,
          size: 24,
        ),
        label: Text('Connexion avec ${biometricState.biometricTypeName}'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          side: BorderSide(color: Theme.of(context).colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go('/home');
      } else if (next.status == AuthStatus.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: const Center(
                      child: Text(
                        'J',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                Text(
                  'Bienvenue',
                  style: AppTextStyles.h1,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Connectez-vous pour continuer',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                JufaTextField(
                  controller: _phoneController,
                  label: 'Numéro de téléphone',
                  hint: '+223 70 00 00 00',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d+]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre numéro';
                    }
                    if (!value.startsWith('+223') || value.length < 12) {
                      return 'Format invalide (+223XXXXXXXX)';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                JufaTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  hint: 'Entrez votre mot de passe',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: AppSpacing.sm),
                
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      context.push('/forgot-password');
                    },
                    child: Text(
                      'Mot de passe oublié ?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                JufaButton(
                  text: 'Se connecter',
                  isLoading: authState.status == AuthStatus.loading,
                  onPressed: _handleLogin,
                ),
                
                _buildBiometricButton(),
                
                const SizedBox(height: AppSpacing.xl),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Vous n'avez pas de compte ? ",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/register');
                      },
                      child: Text(
                        "S'inscrire",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
