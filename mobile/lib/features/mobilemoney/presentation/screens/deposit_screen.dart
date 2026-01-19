import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/mobile_money_entity.dart';
import '../providers/mobile_money_provider.dart';

class DepositScreen extends ConsumerStatefulWidget {
  const DepositScreen({super.key});

  @override
  ConsumerState<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends ConsumerState<DepositScreen> {
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
        if (next.currentOperation!.needsConfirmation) {
          _showConfirmationDialog(next.currentOperation!);
        } else if (next.currentOperation!.isCompleted) {
          _showSuccessDialog(next.currentOperation!, currencyFormat);
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
        title: const Text('Dépôt Mobile Money'),
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
              _buildInfoCard(),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Opérateur',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildProviderSelector(state),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Numéro Mobile Money',
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
                    return 'Veuillez entrer votre numéro';
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
                  if (amount == null || amount < 100) {
                    return 'Montant minimum: 100 XOF';
                  }
                  if (amount > 5000000) {
                    return 'Montant maximum: 5 000 000 XOF';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildQuickAmounts(),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _initiateDeposit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Continuer', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.info),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Vous recevrez une demande de paiement sur votre téléphone. Validez-la pour compléter le dépôt.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.info),
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

  Widget _buildQuickAmounts() {
    final amounts = [1000, 2000, 5000, 10000];
    return Wrap(
      spacing: AppSpacing.sm,
      children: amounts.map((amount) {
        return ActionChip(
          label: Text('$amount XOF'),
          onPressed: () => _amountController.text = amount.toString(),
        );
      }).toList(),
    );
  }

  void _initiateDeposit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(mobileMoneyNotifierProvider.notifier).initiateDeposit(
          phoneNumber: _phoneController.text,
          amount: double.parse(_amountController.text),
        );

    if (!success && mounted) {
    }
  }

  void _showConfirmationDialog(MobileMoneyOperationEntity operation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer le dépôt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone_android, size: 64, color: AppColors.primary),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Une demande de paiement a été envoyée à votre téléphone.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Validez le paiement de ${operation.amount.toStringAsFixed(0)} XOF',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Référence: ${operation.reference}',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(mobileMoneyNotifierProvider.notifier).cancelOperation(operation.reference);
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(mobileMoneyNotifierProvider.notifier).confirmDeposit();
              if (success && mounted) {
                final state = ref.read(mobileMoneyNotifierProvider);
                if (state.currentOperation != null) {
                  _showSuccessDialog(state.currentOperation!, 
                      NumberFormat.currency(locale: 'fr_FR', symbol: 'XOF', decimalDigits: 0));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("J'ai validé", style: TextStyle(color: Colors.white)),
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
            const Text('Dépôt réussi!', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.sm),
            Text(
              format.format(operation.amount),
              style: AppTextStyles.h1.copyWith(color: AppColors.primary),
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
