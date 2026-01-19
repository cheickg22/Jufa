import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transaction_provider.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historique'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(transactionHistoryProvider);
        },
        child: transactionsAsync.when(
          data: (transactions) => transactions.isEmpty
              ? _buildEmptyState()
              : _buildTransactionList(transactions),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _buildErrorState(e.toString(), ref),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: AppSpacing.lg),
          Text('Aucune transaction', style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Vos transactions apparaîtront ici',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.lg),
            Text('Erreur de chargement', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            Text(error, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(transactionHistoryProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<TransactionEntity> transactions) {
    final grouped = _groupByDate(transactions);

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(entry.key, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
            ),
            ...entry.value.map((tx) => _TransactionTile(transaction: tx)),
          ],
        );
      },
    );
  }

  Map<String, List<TransactionEntity>> _groupByDate(List<TransactionEntity> transactions) {
    final Map<String, List<TransactionEntity>> grouped = {};
    final now = DateTime.now();

    for (final tx in transactions) {
      String key;
      if (tx.createdAt.day == now.day && tx.createdAt.month == now.month && tx.createdAt.year == now.year) {
        key = "Aujourd'hui";
      } else if (tx.createdAt.day == now.day - 1 && tx.createdAt.month == now.month && tx.createdAt.year == now.year) {
        key = 'Hier';
      } else {
        key = '${tx.createdAt.day}/${tx.createdAt.month}/${tx.createdAt.year}';
      }
      grouped.putIfAbsent(key, () => []).add(tx);
    }
    return grouped;
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtrer par', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.lg),
            _FilterOption(icon: Icons.arrow_upward, label: 'Envoyés', onTap: () => Navigator.pop(context)),
            _FilterOption(icon: Icons.arrow_downward, label: 'Reçus', onTap: () => Navigator.pop(context)),
            _FilterOption(icon: Icons.calendar_today, label: 'Cette semaine', onTap: () => Navigator.pop(context)),
            _FilterOption(icon: Icons.calendar_month, label: 'Ce mois', onTap: () => Navigator.pop(context)),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionEntity transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isDebit = transaction.senderPhone == null;
    final color = isDebit ? AppColors.error : AppColors.success;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              isDebit ? Icons.arrow_upward : Icons.arrow_downward,
              color: color,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.displayName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _StatusBadge(status: transaction.status),
                    const SizedBox(width: AppSpacing.sm),
                    Text(_formatTime(transaction.createdAt), style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction.formattedAmount,
                style: AppTextStyles.bodyMedium.copyWith(color: color, fontWeight: FontWeight.w600),
              ),
              if (transaction.fee > 0)
                Text('Frais: ${transaction.fee.toStringAsFixed(0)} XOF', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'COMPLETED':
        color = AppColors.success;
        label = 'Terminé';
        break;
      case 'PENDING':
        color = AppColors.warning;
        label = 'En attente';
        break;
      case 'FAILED':
        color = AppColors.error;
        label = 'Échoué';
        break;
      default:
        color = AppColors.info;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(label, style: AppTextStyles.caption.copyWith(color: color, fontSize: 10)),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FilterOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: AppTextStyles.bodyMedium),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    );
  }
}
