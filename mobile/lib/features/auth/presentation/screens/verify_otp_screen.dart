import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../shared/widgets/jufa_widgets.dart';
import '../providers/auth_provider.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({super.key});
  
  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final _otpController = TextEditingController();
  
  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
  
  void _handleVerify() {
    if (_otpController.text.length == 6) {
      ref.read(authNotifierProvider.notifier).verifyOtp(_otpController.text);
    }
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
    
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 56,
      textStyle: AppTextStyles.h2,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
    );
    
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: AppColors.primary, width: 2),
      ),
    );
    
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: AppColors.primary.withOpacity(0.1),
        border: Border.all(color: AppColors.primary),
      ),
    );
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vérification OTP',
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Entrez le code à 6 chiffres envoyé par SMS',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              
              Center(
                child: Pinput(
                  controller: _otpController,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  showCursor: true,
                  onCompleted: (pin) => _handleVerify(),
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              JufaButton(
                text: 'Vérifier',
                isLoading: authState.status == AuthStatus.loading,
                onPressed: _handleVerify,
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: Resend OTP
                  },
                  child: Text(
                    'Renvoyer le code',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.info),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Le code expire dans 5 minutes',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
