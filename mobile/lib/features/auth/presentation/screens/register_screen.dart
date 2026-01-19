import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../shared/widgets/jufa_widgets.dart';
import '../providers/auth_provider.dart';

enum UserTypeOption {
  individual(
    'INDIVIDUAL',
    'Particulier',
    'Wallet personnel, transferts P2P, paiements',
    Icons.person_outline,
  ),
  retailer(
    'RETAILER',
    'Détaillant / Boutiquier',
    'Boutique de quartier, paiements B2B et B2C',
    Icons.storefront_outlined,
  ),
  wholesaler(
    'WHOLESALER',
    'Grossiste',
    'Importateur, distributeur, catalogue produits',
    Icons.warehouse_outlined,
  ),
  agent(
    'AGENT',
    'Agent JUFA',
    'Cash-in/out, services financiers de proximité',
    Icons.support_agent_outlined,
  );

  final String value;
  final String title;
  final String description;
  final IconData icon;

  const UserTypeOption(this.value, this.title, this.description, this.icon);
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserTypeOption _selectedUserType = UserTypeOption.individual;
  int _currentStep = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authNotifierProvider.notifier).register(
        _phoneController.text.trim(),
        _passwordController.text,
        userType: _selectedUserType.value,
      );
    }
  }

  void _nextStep() {
    setState(() {
      _currentStep = 1;
    });
  }

  void _previousStep() {
    setState(() {
      _currentStep = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.otpSent) {
        context.push('/verify-otp');
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (_currentStep == 1) {
              _previousStep();
            } else {
              context.pop();
            }
          },
        ),
        title: _currentStep == 0
            ? null
            : Text(
                _selectedUserType.title,
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
      ),
      body: SafeArea(
        child: _currentStep == 0 ? _buildUserTypeSelection() : _buildRegistrationForm(authState),
      ),
    );
  }

  Widget _buildUserTypeSelection() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bienvenue sur JUFA', style: AppTextStyles.h1),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Choisissez votre type de compte',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: ListView.separated(
              itemCount: UserTypeOption.values.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final option = UserTypeOption.values[index];
                return _UserTypeCard(
                  option: option,
                  isSelected: _selectedUserType == option,
                  onTap: () {
                    setState(() {
                      _selectedUserType = option;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          JufaButton(
            text: 'Continuer',
            onPressed: _nextStep,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Déjà un compte ? ',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Se connecter',
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
    );
  }

  Widget _buildRegistrationForm(AuthState authState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSelectedTypeHeader(),
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
              hint: 'Minimum 8 caractères',
              obscureText: _obscurePassword,
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un mot de passe';
                }
                if (value.length < 8) {
                  return 'Minimum 8 caractères requis';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            JufaTextField(
              controller: _confirmPasswordController,
              label: 'Confirmer le mot de passe',
              hint: 'Retapez votre mot de passe',
              obscureText: _obscureConfirmPassword,
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Les mots de passe ne correspondent pas';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildUserTypeInfo(),
            const SizedBox(height: AppSpacing.xl),
            JufaButton(
              text: "S'inscrire",
              isLoading: authState.status == AuthStatus.loading,
              onPressed: _handleRegister,
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton(
                onPressed: _previousStep,
                child: Text(
                  'Changer de type de compte',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTypeHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(_selectedUserType.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedUserType.title,
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  _selectedUserType.description,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeInfo() {
    final features = _getFeaturesForType(_selectedUserType);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fonctionnalités incluses',
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(feature, style: AppTextStyles.bodySmall),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<String> _getFeaturesForType(UserTypeOption type) {
    switch (type) {
      case UserTypeOption.individual:
        return [
          'Wallet JUFA personnel',
          'Transferts P2P',
          'Paiements marchands',
          'Factures & recharges',
          'Historique et notifications',
        ];
      case UserTypeOption.retailer:
        return [
          'Wallet JUFA commerçant',
          'Paiements B2B (achats grossistes)',
          'Paiements B2C (clients finaux)',
          'QR Code marchand',
          'Historique des ventes',
        ];
      case UserTypeOption.wholesaler:
        return [
          'Compte professionnel JUFA',
          'Catalogue de produits',
          'Réception paiements B2B',
          'Facturation digitale',
          'Suivi des règlements',
        ];
      case UserTypeOption.agent:
        return [
          'Cash-in / Cash-out',
          'Enrôlement clients',
          'Paiement de factures',
          'Recharges téléphoniques',
          'Commissions agents',
        ];
    }
  }
}

class _UserTypeCard extends StatelessWidget {
  final UserTypeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                option.icon,
                size: 28,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }
}
