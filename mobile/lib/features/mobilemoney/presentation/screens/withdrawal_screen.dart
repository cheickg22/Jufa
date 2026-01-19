import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/mobile_money_entity.dart';
import '../providers/mobile_money_provider.dart';

class WithdrawalScreen extends ConsumerStatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  ConsumerState<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends ConsumerState<WithdrawalScreen> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(mobileMoneyNotifierProvider.notifier).loadProviders();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mobileMoneyNotifierProvider);
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'XOF', decimalDigits: 0);

    ref.listen<MobileMoneyState>(mobileMoneyNotifierProvider, (previous, next) {
      if (next.currentOperation != null && previous?.currentOperation == null) {
        if (next.currentOperation!.isCompleted) {
          _showSuccessDialog(next.currentOperation!, currencyFormat);
        } else if (next.currentOperation!.status == MobileMoneyOperationStatus.processing) {
          _showProcessingDialog(next.currentOperation!);
        }
      }
      if (next.error != null && previous?.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: AppColors.error),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Retrait Mobile Money'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWarningCard(),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Opérateur',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildProviderSelector(state),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Numéro de réception',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Ex: 76123456',
                  prefixIcon: const Icon(Icons.phone),
                  prefixText: '+223 ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le numéro de réception';
                  }
                  if (value.length < 8) {
                    return 'Numéro invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Montant',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppTextStyles.h2,
                decoration: InputDecoration(
                  hintText: '0',
                  prefixIcon: const Icon(Icons.money, size: 28),
                  suffixText: 'XOF',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 500) {
                    return 'Montant minimum: 500 XOF';
                  }
                  if (amount > 2000000) {
                    return 'Montant maximum: 2 000 000 XOF';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildFeeInfo(),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _initiateWithdrawal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Retirer', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: AppColors.warning),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Le montant sera débité immédiatement de votre compte JUFA.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderSelector(MobileMoneyState state) {
    return Row(
      children: [
        _buildProviderCard(
          MobileMoneyProvider.orangeMoney,
          'Orange Money',
          Colors.orange,
          state.selectedProvider == MobileMoneyProvider.orangeMoney,
        ),
        const SizedBox(width: AppSpacing.md),
        _buildProviderCard(
          MobileMoneyProvider.moovMoney,
          'Moov Money',
          Colors.blue,
          state.selectedProvider == MobileMoneyProvider.moovMoney,
        ),
      ],
    );
  }

  Widget _buildProviderCard(MobileMoneyProvider provider, String name, Color color, bool selected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(mobileMoneyNotifierProvider.notifier).selectProvider(provider),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.1) : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? color : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.account_balance_wallet, color: color),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                name,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeeInfo() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final fee = (amount * 0.015).ceil();
    final total = amount + fee;

    if (amount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Montant'),
              Text('${amount.toStringAsFixed(0)} XOF'),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Frais (1.5%)'),
              Text('$fee XOF'),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              Text('${total.toStringAsFixed(0)} XOF', 
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  void _initiateWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer le retrait'),
        content: Text(
          'Vous allez retirer ${_amountController.text} XOF vers le numéro ${_phoneController.text}. Continuer?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Confirmer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(mobileMoneyNotifierProvider.notifier).initiateWithdrawal(
          phoneNumber: _phoneController.text,
          amount: double.parse(_amountController.text),
        );
  }

  void _showProcessingDialog(MobileMoneyOperationEntity operation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(strokeWidth: 4),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Retrait en cours...', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            Text('Référence: ${operation.reference}', style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Vous recevrez une confirmation par SMS.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(mobileMoneyNotifierProvider.notifier).reset();
              context.go('/home');
            },
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(MobileMoneyOperationEntity operation, NumberFormat format) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Retrait réussi!', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.sm),
            Text(
              format.format(operation.amount),
              style: AppTextStyles.h1.copyWith(color: AppColors.success),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Envoyé vers ${operation.phoneNumber}',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Référence: ${operation.reference}', style: AppTextStyles.caption),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(mobileMoneyNotifierProvider.notifier).reset();
                context.go('/home');
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Terminé', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
