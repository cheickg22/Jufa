import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/services/agent_api_service.dart';
import '../../../../../core/theme/agent_colors.dart';

class AgentTransactionsPage extends StatefulWidget {
  const AgentTransactionsPage({super.key});

  @override
  State<AgentTransactionsPage> createState() => _AgentTransactionsPageState();
}

class _AgentTransactionsPageState extends State<AgentTransactionsPage> with SingleTickerProviderStateMixin {
  final AgentApiService _apiService = AgentApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _deposits = [];
  List<Map<String, dynamic>> _withdrawals = [];
  List<Map<String, dynamic>> _commissions = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.getTransactions();
      
      if (response.isNotEmpty) {
        setState(() {
          _deposits = List<Map<String, dynamic>>.from(response['deposits'] ?? []);
          _withdrawals = List<Map<String, dynamic>>.from(response['withdrawals'] ?? []);
          _commissions = List<Map<String, dynamic>>.from(response['commissions'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AgentColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AgentColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Historique des transactions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: const Icon(Icons.arrow_downward),
              text: 'Dépôts (${_deposits.length})',
            ),
            Tab(
              icon: const Icon(Icons.arrow_upward),
              text: 'Retraits (${_withdrawals.length})',
            ),
            Tab(
              icon: const Icon(Icons.monetization_on),
              text: 'Commissions (${_commissions.length})',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(_deposits, 'Aucun dépôt'),
                _buildTransactionList(_withdrawals, 'Aucun retrait'),
                _buildCommissionList(_commissions, 'Aucune commission'),
              ],
            ),
    );
  }

  Widget _buildTransactionList(List<Map<String, dynamic>> transactions, String emptyMessage) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return _buildTransactionCard(transactions[index]);
        },
      ),
    );
  }

  Widget _buildCommissionList(List<Map<String, dynamic>> commissions, String emptyMessage) {
    if (commissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.monetization_on_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Calculer le total des commissions
    final totalCommissions = commissions.fold<double>(
      0.0,
      (sum, commission) => sum + ((commission['amount'] ?? 0) as num).toDouble(),
    );

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: Column(
        children: [
          // Carte du total des commissions
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AgentColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AgentColors.cardShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total des commissions',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${NumberFormat('#,###', 'fr_FR').format(totalCommissions)} FCFA',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.monetization_on,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
          // Liste des commissions
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: commissions.length,
              itemBuilder: (context, index) {
                return _buildCommissionCard(commissions[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final isDeposit = transaction['type'] == 'deposit';
    final amount = (transaction['amount'] ?? 0).toDouble();
    final commission = (transaction['commission'] ?? 0).toDouble();
    final createdAt = DateTime.parse(transaction['created_at']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDeposit 
                        ? AgentColors.success.withOpacity(0.1)
                        : AgentColors.warning.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isDeposit ? AgentColors.success : AgentColors.warning,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDeposit ? 'Dépôt' : 'Retrait',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction['client_name'] ?? 'N/A',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${NumberFormat('#,###', 'fr_FR').format(amount)} F',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Commission: ${NumberFormat('#,###', 'fr_FR').format(commission)} F',
                      style: TextStyle(
                        color: AgentColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      transaction['client_phone'] ?? 'N/A',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(createdAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (transaction['transaction_code'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'ID: ${transaction['transaction_code']}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionCard(Map<String, dynamic> commission) {
    final isDepositCommission = commission['type'] == 'commission_deposit';
    final amount = (commission['amount'] ?? 0).toDouble();
    final createdAt = DateTime.parse(commission['created_at']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AgentColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.monetization_on,
                    color: AgentColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDepositCommission ? 'Commission dépôt' : 'Commission retrait',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        commission['client_name'] ?? 'N/A',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${NumberFormat('#,###', 'fr_FR').format(amount)} F',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AgentColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      commission['client_phone'] ?? 'N/A',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(createdAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (commission['transaction_code'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'ID: ${commission['transaction_code']}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
