import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/services/transaction_service.dart';
import '../../../../core/l10n/app_localizations.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  DateTimeRange? _selectedDateRange;
  
  final TransactionService _transactionService = TransactionService();
  List<Transaction> _allTransactions = [];
  bool _isLoading = true;

  // Données de démonstration (fallback)
  final List<Transaction> _demoTransactions = [
    Transaction(
      id: '1',
      title: 'Orange Mali',
      subtitle: 'airtime_recharge_label',
      amount: -5000,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      type: TransactionType.airtime,
      status: TransactionStatus.completed,
    ),
    Transaction(
      id: '2',
      title: 'Mariam Traoré',
      subtitle: 'received_transfer',
      amount: 25000,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: TransactionType.transfer,
      status: TransactionStatus.completed,
    ),
    Transaction(
      id: '3',
      title: 'EDM Mali',
      subtitle: 'bill_payment',
      amount: -15000,
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: TransactionType.bill,
      status: TransactionStatus.completed,
    ),
    Transaction(
      id: '4',
      title: 'Bakary Koné',
      subtitle: 'sent_transfer',
      amount: -10000,
      date: DateTime.now().subtract(const Duration(days: 3)),
      type: TransactionType.transfer,
      status: TransactionStatus.pending,
    ),
    Transaction(
      id: '5',
      title: 'Malitel',
      subtitle: 'internet_recharge',
      amount: -3000,
      date: DateTime.now().subtract(const Duration(days: 5)),
      type: TransactionType.airtime,
      status: TransactionStatus.failed,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTransactions();
  }
  
  Future<void> _loadTransactions() async {
    try {
      setState(() => _isLoading = true);
      
      final apiTransactions = await _transactionService.getTransactions();
      
      // Convertir les transactions API en modèle Transaction local
      final transactions = apiTransactions.map((t) {
        return Transaction(
          id: t['id'].toString(),
          title: _getTransactionTitle(t),
          subtitle: t['description'] ?? '',
          amount: _getTransactionAmount(t),
          date: DateTime.parse(t['created_at']),
          type: _getTransactionType(t['type']),
          status: _getTransactionStatus(t['status']),
        );
      }).toList();
      
      setState(() {
        _allTransactions = transactions;
        _isLoading = false;
      });
      
      print('📊 ${transactions.length} transactions chargées depuis API');
    } catch (e) {
      print('❌ Erreur chargement transactions: $e');
      // Utiliser les données de démonstration en cas d'erreur
      setState(() {
        _allTransactions = _demoTransactions;
        _isLoading = false;
      });
    }
  }
  
  String _getTransactionTitle(Map<String, dynamic> t) {
    if (t['sender'] != null && t['sender']['id'] != null) {
      return '${t['sender']['first_name']} ${t['sender']['last_name']}';
    }
    if (t['receiver'] != null && t['receiver']['id'] != null) {
      return '${t['receiver']['first_name']} ${t['receiver']['last_name']}';
    }
    final type = t['type'].toString();
    return type;
  }
  
  double _getTransactionAmount(Map<String, dynamic> t) {
    final amount = double.parse(t['amount'].toString());
    // Négatif pour les retraits et paiements
    if (t['type'] == 'withdrawal' || t['type'] == 'payment') {
      return -amount;
    }
    return amount;
  }
  
  TransactionType _getTransactionType(String type) {
    switch (type) {
      case 'transfer':
        return TransactionType.transfer;
      case 'payment':
      case 'bill_payment':
        return TransactionType.bill;
      case 'airtime':
        return TransactionType.airtime;
      case 'deposit':
        return TransactionType.deposit;
      case 'withdrawal':
        return TransactionType.withdrawal;
      default:
        return TransactionType.transfer;
    }
  }
  
  TransactionStatus _getTransactionStatus(String status) {
    switch (status) {
      case 'completed':
        return TransactionStatus.completed;
      case 'pending':
        return TransactionStatus.pending;
      case 'failed':
        return TransactionStatus.failed;
      default:
        return TransactionStatus.pending;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Transaction> get _filteredTransactions {
    List<Transaction> filtered = _allTransactions;

    // Filtrer par type
    if (_selectedFilter != 'all') {
      switch (_selectedFilter) {
        case 'transfers':
          filtered = filtered.where((t) => t.type == TransactionType.transfer).toList();
          break;
        case 'payments':
          filtered = filtered.where((t) => t.type == TransactionType.bill).toList();
          break;
        case 'airtime_recharge_filter':
          filtered = filtered.where((t) => t.type == TransactionType.airtime).toList();
          break;
      }
    }

    // Filtrer par date
    if (_selectedDateRange != null) {
      filtered = filtered.where((t) {
        return t.date.isAfter(_selectedDateRange!.start) &&
               t.date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('history')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.translate('all')),
            Tab(text: l10n.translate('income')),
            Tab(text: l10n.translate('expenses')),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filtres rapides
          _buildQuickFilters(),
          
          // Liste des transactions
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(_filteredTransactions),
                _buildTransactionList(_filteredTransactions.where((t) => t.amount > 0).toList()),
                _buildTransactionList(_filteredTransactions.where((t) => t.amount < 0).toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('all', l10n.translate('all')),
          _buildFilterChip('transfers', l10n.translate('transfers')),
          _buildFilterChip('payments', l10n.translate('payments')),
          _buildFilterChip('airtime_recharge_filter', l10n.translate('airtime_recharge_filter')),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? key : 'all';
          });
        },
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).translate('no_transaction_found'),
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Actualiser les données
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return _buildTransactionCard(transaction);
        },
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isPositive = transaction.amount > 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getTransactionColor(transaction.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getTransactionIcon(transaction.type),
            color: _getTransactionColor(transaction.type),
          ),
        ),
        title: Text(
          transaction.title,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.subtitle),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(transaction.status),
                const SizedBox(width: 8),
                Text(
                  Formatters.formatRelativeDate(transaction.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          '${isPositive ? '+' : ''}${Formatters.formatCurrency(transaction.amount.abs())}',
          style: TextStyle(
            color: isPositive ? AppColors.success : AppColors.expense,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  Widget _buildStatusChip(TransactionStatus status) {
    final l10n = AppLocalizations.of(context);
    Color color;
    String label;
    
    switch (status) {
      case TransactionStatus.completed:
        color = AppColors.success;
        label = l10n.translate('completed');
        break;
      case TransactionStatus.pending:
        color = AppColors.warning;
        label = l10n.translate('pending');
        break;
      case TransactionStatus.failed:
        color = AppColors.error;
        label = l10n.translate('failed');
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.transfer:
        return Icons.swap_horiz;
      case TransactionType.bill:
        return Icons.receipt_long;
      case TransactionType.airtime:
        return Icons.phone_android;
      case TransactionType.deposit:
        return Icons.arrow_downward;
      case TransactionType.withdrawal:
        return Icons.arrow_upward;
    }
  }

  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.transfer:
        return AppColors.transfer;
      case TransactionType.bill:
        return AppColors.payment;
      case TransactionType.airtime:
        return AppColors.airtime;
      case TransactionType.deposit:
        return AppColors.success;
      case TransactionType.withdrawal:
        return AppColors.error;
    }
  }

  void _showFilterDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('filter_by_period')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.translate('select_period')),
              subtitle: Text(_selectedDateRange != null
                  ? '${Formatters.formatDate(_selectedDateRange!.start)} - ${Formatters.formatDate(_selectedDateRange!.end)}'
                  : l10n.translate('all_dates')),
              trailing: Icon(Icons.date_range),
              onTap: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                  initialDateRange: _selectedDateRange,
                );
                if (range != null) {
                  setState(() => _selectedDateRange = range);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _selectedDateRange = null);
              Navigator.of(context).pop();
            },
            child: Text(l10n.translate('clear')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.translate('close')),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('search')),
        content: TextField(
          decoration: InputDecoration(
            hintText: l10n.translate('search_transaction'),
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implémenter la recherche
              Navigator.of(context).pop();
            },
            child: Text(l10n.translate('search')),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.translate('transaction_details'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              _buildDetailRow('ID', transaction.id),
              _buildDetailRow(l10n.translate('title'), transaction.title),
              _buildDetailRow(l10n.translate('description'), transaction.subtitle),
              _buildDetailRow(l10n.translate('amount'), Formatters.formatCurrency(transaction.amount.abs())),
              _buildDetailRow(l10n.translate('date'), Formatters.formatDateTime(transaction.date)),
              _buildDetailRow(l10n.translate('status'), _getStatusText(transaction.status)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.translate('close')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(TransactionStatus status) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case TransactionStatus.completed:
        return l10n.translate('completed');
      case TransactionStatus.pending:
        return l10n.translate('pending');
      case TransactionStatus.failed:
        return l10n.translate('failed');
    }
  }
  
  String _getTypeText(TransactionType type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case TransactionType.transfer:
        return l10n.translate('transfer');
      case TransactionType.bill:
        return l10n.translate('payment');
      case TransactionType.airtime:
        return l10n.translate('airtime_recharge_label');
      case TransactionType.deposit:
        return l10n.translate('deposit');
      case TransactionType.withdrawal:
        return l10n.translate('withdrawal');
    }
  }
}

// Modèles de données
class Transaction {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final TransactionStatus status;

  Transaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
    required this.status,
  });
}

enum TransactionType { transfer, bill, airtime, deposit, withdrawal }
enum TransactionStatus { completed, pending, failed }
