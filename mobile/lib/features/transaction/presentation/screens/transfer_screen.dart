import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleTransfer() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    final amount = double.parse(_amountController.text.replaceAll(' ', ''));
    final description = _descriptionController.text.trim();

    final success = await ref.read(transferNotifierProvider.notifier).transfer(
      receiverPhone: phone,
      amount: amount,
      description: description.isEmpty ? null : description,
    );

    if (success && mounted) {
      ref.invalidate(walletsProvider);
      ref.invalidate(totalBalanceProvider);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    final transaction = ref.read(transferNotifierProvider).transaction;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppColors.success, size: 32),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Transfert réussi!', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            Text(
              transaction?.formattedAmount ?? '',
              style: AppTextStyles.h2.copyWith(color: AppColors.success),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Envoyé à ${transaction?.receiverPhone ?? ''}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Réf: ${transaction?.reference ?? ''}',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
              child: const Text('Retour à l\'accueil'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transferState = ref.watch(transferNotifierProvider);
    final walletAsync = ref.watch(primaryWalletProvider);

    ref.listen<TransferState>(transferNotifierProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
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
        title: const Text('Envoyer de l\'argent'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              walletAsync.when(
                data: (wallet) => wallet != null
                    ? Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.account_balance_wallet, color: AppColors.primary),
                            const SizedBox(width: AppSpacing.md),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Solde disponible', style: AppTextStyles.caption),
                                Text(wallet.formattedBalance, style: AppTextStyles.h3),
                              ],
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Numéro du bénéficiaire', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+223 XX XX XX XX',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le numéro du bénéficiaire';
                  }
                  if (!value.startsWith('+')) {
                    return 'Le numéro doit commencer par +';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Montant (XOF)', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: '10 000',
                  prefixIcon: const Icon(Icons.money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le montant';
                  }
                  final amount = double.tryParse(value.replaceAll(' ', ''));
                  if (amount == null || amount < 100) {
                    return 'Le montant minimum est de 100 XOF';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Description (optionnel)', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Ex: Remboursement déjeuner',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: transferState.isLoading ? null : _handleTransfer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                  child: transferState.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Envoyer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
