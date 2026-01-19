import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/agent_enums.dart';
import '../../domain/entities/agent_transaction.dart';
import '../providers/agent_provider.dart';

class AgentTransactionsScreen extends ConsumerStatefulWidget {
  const AgentTransactionsScreen({super.key});

  @override
  ConsumerState<AgentTransactionsScreen> createState() => _AgentTransactionsScreenState();
}

class _AgentTransactionsScreenState extends ConsumerState<AgentTransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormat = NumberFormat('#,###', 'fr_FR');
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      ref.read(agentNotifierProvider.notifier).loadTransactions(refresh: true);
      ref.read(agentNotifierProvider.notifier).loadCashInTransactions(refresh: true);
      ref.read(agentNotifierProvider.notifier).loadCashOutTransactions(refresh: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return '${currencyFormat.format(amount).replaceAll(',', ' ')} FCFA';
  }

  double _calculateTotalCommission(List<AgentTransaction> transactions) {
    return transactions.fold(0.0, (sum, tx) => sum + tx.agentCommission);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agentNotifierProvider);
    final cashInCount = state.cashInTransactions.length;
    final cashOutCount = state.cashOutTransactions.length;
    final allCount = state.transactions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historique'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Dépôts ($cashInCount)'),
            Tab(text: 'Retraits ($cashOutCount)'),
            Tab(text: 'Commissions ($allCount)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionsList(state.cashInTransactions, state.isLoading, true),
          _buildTransactionsList(state.cashOutTransactions, state.isLoading, false),
          _buildCommissionsTab(state.transactions, state.isLoading),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<AgentTransaction> transactions, bool isLoading, bool isCashIn) {
    final color = isCashIn ? AppColors.success : AppColors.warning;
    final emptyMessage = isCashIn ? 'Aucun dépôt effectué' : 'Aucun retrait effectué';

    return RefreshIndicator(
      onRefresh: () async {
        if (isCashIn) {
          await ref.read(agentNotifierProvider.notifier).loadCashInTransactions(refresh: true);
        } else {
          await ref.read(agentNotifierProvider.notifier).loadCashOutTransactions(refresh: true);
        }
      },
      child: isLoading && transactions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? _buildEmptyState(emptyMessage, isCashIn ? Icons.arrow_downward : Icons.arrow_upward, color)
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    return _buildTransactionCard(transactions[index], color, isCashIn);
                  },
                ),
    );
  }

  Widget _buildCommissionsTab(List<AgentTransaction> transactions, bool isLoading) {
    final totalCommission = _calculateTotalCommission(transactions);

    return RefreshIndicator(
      onRefresh: () => ref.read(agentNotifierProvider.notifier).loadTransactions(refresh: true),
      child: isLoading && transactions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? _buildEmptyState('Aucune commission', Icons.monetization_on, AppColors.success)
              : Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.walletGradientStart, AppColors.walletGradientEnd],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Total Commissions',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatCurrency(totalCommission),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${transactions.length} transactions',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          final isCashIn = tx.transactionType == AgentTransactionType.cashIn;
                          return _buildCommissionCard(tx, isCashIn);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: color.withValues(alpha: 0.3)),
          const SizedBox(height: AppSpacing.lg),
          Text(message, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Les transactions apparaîtront ici',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(AgentTransaction tx, Color color, bool isCashIn) {
    final icon = isCashIn ? Icons.arrow_downward : Icons.arrow_upward;
    final typeLabel = isCashIn ? 'Dépôt' : 'Retrait';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    typeLabel,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tx.customerPhone,
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    dateFormat.format(tx.createdAt),
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  if (tx.reference.isNotEmpty)
                    Text(
                      tx.reference,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCurrency(tx.amount),
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    '+${_formatCurrency(tx.agentCommission)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionCard(AgentTransaction tx, bool isCashIn) {
    final color = isCashIn ? AppColors.success : AppColors.warning;
    final icon = isCashIn ? Icons.arrow_downward : Icons.arrow_upward;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tx.customerPhone,
              style: AppTextStyles.bodySmall,
            ),
            Text(
              '+${_formatCurrency(tx.agentCommission)}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateFormat.format(tx.createdAt),
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              'sur ${_formatCurrency(tx.amount)}',
              style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
