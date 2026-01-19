import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/qr_payment_entity.dart';
import '../providers/qr_payment_provider.dart';

class QrPaymentConfirmScreen extends ConsumerStatefulWidget {
  final QrCodeEntity qrCode;

  const QrPaymentConfirmScreen({super.key, required this.qrCode});

  @override
  ConsumerState<QrPaymentConfirmScreen> createState() => _QrPaymentConfirmScreenState();
}

class _QrPaymentConfirmScreenState extends ConsumerState<QrPaymentConfirmScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    if (widget.qrCode.amount != null) {
      _amountController.text = widget.qrCode.amount!.toStringAsFixed(0);
    }
    if (widget.qrCode.description != null) {
      _descriptionController.text = 'Paiement: ${widget.qrCode.description}';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final payState = ref.watch(qrPayNotifierProvider);
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'XOF', decimalDigits: 0);

    ref.listen<QrPayState>(qrPayNotifierProvider, (previous, next) {
      if (next.payment != null && previous?.payment == null) {
        setState(() => _showSuccess = true);
      }
    });

    if (_showSuccess && payState.payment != null) {
      return _buildSuccessScreen(payState.payment!, currencyFormat);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Confirmer le paiement'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMerchantCard(currencyFormat),
            const SizedBox(height: AppSpacing.xl),
            if (widget.qrCode.amount == null) ...[
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
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(
              'Description (optionnel)',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Raison du paiement',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            if (payState.error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        payState.error!,
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: payState.isLoading ? null : _confirmPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
                child: payState.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Payer ${widget.qrCode.amount != null ? currencyFormat.format(widget.qrCode.amount) : ''}',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => context.pop(),
                child: const Text('Annuler'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantCard(NumberFormat currencyFormat) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.store, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.qrCode.merchant.displayName,
                      style: AppTextStyles.h3,
                    ),
                    Text(
                      widget.qrCode.merchant.phone,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.qrCode.qrType == QrCodeType.dynamic
                      ? AppColors.warning.withValues(alpha: 0.1)
                      : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  widget.qrCode.qrTypeLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: widget.qrCode.qrType == QrCodeType.dynamic ? AppColors.warning : AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (widget.qrCode.amount != null) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Montant à payer', style: AppTextStyles.bodyMedium),
                Text(
                  currencyFormat.format(widget.qrCode.amount),
                  style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ],
          if (widget.qrCode.description != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              widget.qrCode.description!,
              style: AppTextStyles.caption,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuccessScreen(QrPaymentEntity payment, NumberFormat currencyFormat) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppColors.success, size: 80),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Paiement réussi!', style: AppTextStyles.h1),
              const SizedBox(height: AppSpacing.md),
              Text(
                currencyFormat.format(payment.amount),
                style: AppTextStyles.h1.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Envoyé à ${payment.merchant.displayName}',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl * 2),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Référence', payment.id.substring(0, 8).toUpperCase()),
                    const Divider(height: AppSpacing.lg),
                    _buildDetailRow('Date', DateFormat('dd/MM/yyyy HH:mm').format(payment.createdAt)),
                    const Divider(height: AppSpacing.lg),
                    _buildDetailRow('Status', 'Complété'),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(qrPayNotifierProvider.notifier).reset();
                    ref.read(qrScanNotifierProvider.notifier).reset();
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                  child: const Text('Retour à l\'accueil', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.caption),
        Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _confirmPayment() {
    double? amount;
    if (widget.qrCode.amount != null) {
      amount = widget.qrCode.amount;
    } else {
      if (_amountController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez saisir un montant'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Montant invalide'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    ref.read(qrPayNotifierProvider.notifier).pay(
          qrToken: widget.qrCode.qrToken,
          amount: widget.qrCode.amount == null ? amount : null,
          description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        );
  }
}
