import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../providers/agent_provider.dart';

class AgentDashboardScreen extends ConsumerStatefulWidget {
  const AgentDashboardScreen({super.key});

  @override
  ConsumerState<AgentDashboardScreen> createState() => _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends ConsumerState<AgentDashboardScreen> {
  final currencyFormat = NumberFormat('#,###', 'fr_FR');

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(agentNotifierProvider.notifier).loadDashboard();
    });
  }

  String _formatCurrency(double amount) {
    return '${currencyFormat.format(amount).replaceAll(',', ' ')} FCFA';
  }

  Future<void> _showSecretCodeDialog() async {
    final codeController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Code secret'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Entrez votre code secret pour voir le solde',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Code secret',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                counterText: '',
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (codeController.text.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Le code doit contenir 4 chiffres'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              final success = await ref.read(agentNotifierProvider.notifier).verifySecretCode(codeController.text);
              if (context.mounted) {
                Navigator.pop(context, success);
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Code secret incorrect'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Valider'),
          ),
        ],
      ),
    );

    if (result != true && mounted) {
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agentNotifierProvider);
    final dashboard = state.dashboard;

    if (state.isLoading && dashboard == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(agentNotifierProvider.notifier).loadDashboard(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(dashboard),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBalanceCard(dashboard, state.balanceVisible),
                      const SizedBox(height: AppSpacing.lg),
                      _buildTodayStats(dashboard),
                      const SizedBox(height: AppSpacing.lg),
                      _buildQuickActions(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildPeriodStats(dashboard),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(dashboard) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.walletGradientStart, AppColors.walletGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bienvenue',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  dashboard?.fullName ?? 'Agent JUFA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (dashboard?.agentCode != null)
                  Text(
                    'Code: ${dashboard!.agentCode}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => context.push('/agent/transactions'),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(dashboard, bool balanceVisible) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Solde UV',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                balanceVisible
                    ? _formatCurrency(dashboard?.walletBalance ?? 0)
                    : '***** FCFA',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: balanceVisible ? 28 : 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(
                  balanceVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.primary,
                ),
                onPressed: () async {
                  if (balanceVisible) {
                    ref.read(agentNotifierProvider.notifier).hideBalance();
                  } else {
                    if (dashboard?.hasSecretCode != true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Configurez votre code secret dans le profil'),
                          backgroundColor: AppColors.warning,
                          action: SnackBarAction(
                            label: 'Configurer',
                            textColor: Colors.white,
                            onPressed: () => context.push('/profile'),
                          ),
                        ),
                      );
                    } else {
                      _showSecretCodeDialog();
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(Icons.arrow_downward, color: AppColors.success, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${dashboard?.depositCommissionRate ?? 1.0}%',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  Icon(Icons.arrow_upward, color: AppColors.warning, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${dashboard?.withdrawalCommissionRate ?? 1.5}%',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStats(dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Transactions d'aujourd'hui", style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Dépôts',
                _formatCurrency(dashboard?.todayDeposits ?? 0),
                Icons.arrow_downward,
                AppColors.success,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Retraits',
                _formatCurrency(dashboard?.todayWithdrawals ?? 0),
                Icons.arrow_upward,
                AppColors.error,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Commission',
                _formatCurrency(dashboard?.todayCommission ?? 0),
                Icons.monetization_on,
                AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actions rapides', style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Dépôt',
                Icons.add_circle_outline,
                AppColors.success,
                () => context.push('/agent/cash-in'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Retrait',
                Icons.remove_circle_outline,
                AppColors.warning,
                () => context.push('/agent/cash-out'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildActionCardWide(
          'Historique des transactions',
          Icons.history,
          AppColors.primary,
          () => context.push('/agent/transactions'),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCardWide(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodStats(dashboard) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cette semaine', style: AppTextStyles.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${dashboard?.weekTransactions ?? 0} tx',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatCurrency(dashboard?.weekCommission ?? 0),
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ce mois', style: AppTextStyles.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${dashboard?.monthTransactions ?? 0} tx',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatCurrency(dashboard?.monthCommission ?? 0),
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
