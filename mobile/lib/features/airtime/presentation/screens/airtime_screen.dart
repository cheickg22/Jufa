import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../providers/airtime_provider.dart';
import '../../domain/entities/airtime_entity.dart';

class AirtimeScreen extends ConsumerStatefulWidget {
  const AirtimeScreen({super.key});

  @override
  ConsumerState<AirtimeScreen> createState() => _AirtimeScreenState();
}

class _AirtimeScreenState extends ConsumerState<AirtimeScreen> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final currencyFormat = NumberFormat('#,###', 'fr_FR');
  int? _selectedQuickAmount;

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return '${currencyFormat.format(amount)} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    final operatorsAsync = ref.watch(airtimeOperatorsProvider);
    final airtimeState = ref.watch(airtimeNotifierProvider);
    final walletAsync = ref.watch(primaryWalletProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Recharge téléphone', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(walletAsync),
            const SizedBox(height: 24),
            Text('Choisir un opérateur', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildOperatorGrid(operatorsAsync, airtimeState.selectedOperator),
            const SizedBox(height: 24),
            Text('Numéro de téléphone', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildPhoneInput(),
            const SizedBox(height: 24),
            Text('Montant', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildQuickAmounts(airtimeState.selectedOperator),
            const SizedBox(height: 12),
            _buildAmountInput(),
            if (airtimeState.error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(airtimeState.error!, style: TextStyle(color: AppColors.error))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            _buildRechargeButton(airtimeState),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(AsyncValue walletAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.walletGradientStart, AppColors.walletGradientEnd],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_balance_wallet, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Solde disponible', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
              const SizedBox(height: 4),
              walletAsync.when(
                data: (wallet) => Text(
                  _formatCurrency(wallet?.balance ?? 0),
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                loading: () => const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                error: (_, __) => const Text('--', style: TextStyle(color: Colors.white70, fontSize: 20)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorGrid(AsyncValue<List<AirtimeOperator>> operatorsAsync, AirtimeOperator? selected) {
    return operatorsAsync.when(
      data: (operators) => Row(
        children: operators.map((op) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: op != operators.last ? 12 : 0),
            child: _buildOperatorCard(op, selected?.code == op.code),
          ),
        )).toList(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Erreur de chargement'),
    );
  }

  Widget _buildOperatorCard(AirtimeOperator operator, bool isSelected) {
    final color = _getOperatorColor(operator.code);
    
    return GestureDetector(
      onTap: () {
        ref.read(airtimeNotifierProvider.notifier).selectOperator(operator);
        _selectedQuickAmount = null;
        _amountController.clear();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getOperatorIcon(operator.code), color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              operator.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getOperatorColor(String code) {
    switch (code.toUpperCase()) {
      case 'ORANGE':
        return Colors.orange;
      case 'MOOV':
        return Colors.blue;
      case 'TELECEL':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  IconData _getOperatorIcon(String code) {
    return Icons.phone_android;
  }

  Widget _buildPhoneInput() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
      decoration: InputDecoration(
        hintText: '76 XX XX XX',
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('+223', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Container(width: 1, height: 24, color: AppColors.border),
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }

  Widget _buildQuickAmounts(AirtimeOperator? operator) {
    final amounts = operator?.quickAmounts ?? [500, 1000, 2000, 5000, 10000];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amounts.map((amount) {
        final isSelected = _selectedQuickAmount == amount;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedQuickAmount = amount;
              _amountController.text = amount.toString();
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
            ),
            child: Text(
              '${currencyFormat.format(amount)} F',
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmountInput() {
    return TextField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (value) {
        setState(() {
          _selectedQuickAmount = int.tryParse(value);
        });
      },
      decoration: InputDecoration(
        hintText: 'Montant personnalisé',
        suffixText: 'FCFA',
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }

  Widget _buildRechargeButton(AirtimeState state) {
    final isValid = state.selectedOperator != null &&
        _phoneController.text.length == 8 &&
        _amountController.text.isNotEmpty &&
        (double.tryParse(_amountController.text) ?? 0) >= 100;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isValid && !state.isLoading ? _processRecharge : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
        ),
        child: state.isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Recharger', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _processRecharge() async {
    final phone = '+223${_phoneController.text}';
    final amount = double.tryParse(_amountController.text) ?? 0;

    final success = await ref.read(airtimeNotifierProvider.notifier).recharge(
      phoneNumber: phone,
      amount: amount,
    );

    if (success && mounted) {
      final state = ref.read(airtimeNotifierProvider);
      _showSuccessDialog(state.lastTransaction!);
    }
  }

  void _showSuccessDialog(AirtimeTransaction transaction) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: AppColors.success, size: 48),
            ),
            const SizedBox(height: 16),
            Text('Recharge réussie !', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              _formatCurrency(transaction.amount),
              style: AppTextStyles.h2.copyWith(color: AppColors.success),
            ),
            const SizedBox(height: 8),
            Text(
              'Vers ${transaction.phoneNumber}',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            if (transaction.reference != null) ...[
              const SizedBox(height: 8),
              Text(
                'Réf: ${transaction.reference}',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Terminé', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
