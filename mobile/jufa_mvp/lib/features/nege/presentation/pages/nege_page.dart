import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/services/nege_service.dart';

class NegePage extends StatefulWidget {
  const NegePage({super.key});

  @override
  State<NegePage> createState() => _NegePageState();
}

class _NegePageState extends State<NegePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late NegeService _negeService;
  
  bool _isLoading = true;
  Map<String, dynamic>? _goldAccount;
  Map<String, dynamic>? _silverAccount;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _negeService = NegeService();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _negeService.getAccounts();
      if (response['success'] == true) {
        setState(() {
          _goldAccount = response['data']['gold'];
          _silverAccount = response['data']['silver'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nege - Épargne en métaux'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Or',
              icon: Icon(Icons.diamond, color: _tabController.index == 0 ? const Color(0xFFFFD700) : Colors.grey),
            ),
            Tab(
              text: 'Argent',
              icon: Icon(Icons.star, color: _tabController.index == 1 ? const Color(0xFFC0C0C0) : Colors.grey),
            ),
          ],
          labelColor: AppColors.textPrimary,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMetalView(
                  metalType: 'Or',
                  metalKey: 'gold',
                  account: _goldAccount,
                  color: const Color(0xFFFFD700),
                  icon: Icons.diamond,
                ),
                _buildMetalView(
                  metalType: 'Argent',
                  metalKey: 'silver',
                  account: _silverAccount,
                  color: const Color(0xFFC0C0C0),
                  icon: Icons.star,
                ),
              ],
            ),
    );
  }
  
  Widget _buildMetalView({
    required String metalType,
    required String metalKey,
    required Map<String, dynamic>? account,
    required Color color,
    required IconData icon,
  }) {
    if (account == null) {
      return Center(child: Text('Aucune donnée'));
    }
    
    final balance = (account['balance_grams'] as num).toDouble();
    final pricePerGram = (account['current_price'] as num).toDouble();
    final totalValue = (account['current_value'] as num).toDouble();
    
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        // Carte de solde
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mon $metalType',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(icon, color: Colors.white, size: 32),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                Formatters.formatWeight(balance),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Valeur: ${Formatters.formatCurrency(totalValue)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Prix actuel
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prix du gramme',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.formatCurrency(pricePerGram),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.trending_up, color: AppColors.success, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '+2.5%',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Mis à jour il y a 5 minutes',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Actions
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Acheter',
                icon: Icons.add_shopping_cart,
                onPressed: () {
                  _showMarketplace(context, metalKey, 'buy');
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                text: 'Vendre',
                icon: Icons.sell,
                isOutlined: true,
                backgroundColor: color,
                onPressed: balance > 0
                    ? () {
                        _showCreateOfferDialog(context, metalKey, balance);
                      }
                    : null,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 32),
        
        // Avantages
        Text(
          'Pourquoi investir dans l\'$metalType ?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        _buildAdvantageCard(
          icon: Icons.trending_up,
          title: 'Valeur refuge',
          description: 'Protection contre l\'inflation et dévaluation',
        ),
        const SizedBox(height: 12),
        _buildAdvantageCard(
          icon: Icons.security,
          title: 'Sécurité',
          description: 'Stockage sécurisé par la Raffinerie Kankou Moussa',
        ),
        const SizedBox(height: 12),
        _buildAdvantageCard(
          icon: Icons.swap_horiz,
          title: 'Liquidité',
          description: 'Achat et vente instantanés',
        ),
      ],
    );
  }
  
  Widget _buildAdvantageCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MARKETPLACE ====================

  void _showMarketplace(BuildContext context, String metalType, String action) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: NegeMarketplacePage(
            metalType: metalType,
            negeService: _negeService,
            onTransactionComplete: () {
              _loadAccounts();
            },
          ),
        ),
      ),
    );
  }

  void _showCreateOfferDialog(BuildContext context, String metalType, double availableBalance) {
    final gramsController = TextEditingController();
    bool isLoading = false;
    
    // Prix fixes par gramme
    final pricePerGram = metalType == 'gold' ? 38500.0 : 520.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Créer une offre de vente - ${metalType == 'gold' ? 'Or' : 'Argent'}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Disponible: ${availableBalance.toStringAsFixed(2)}g',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Prix par gramme:'),
                      Text(
                        Formatters.formatCurrency(pricePerGram),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: gramsController,
                  keyboardType: TextInputType.number,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Quantité (grammes)',
                    hintText: 'Ex: 5.0',
                    suffixText: 'g',
                    border: const OutlineInputBorder(),
                    helperText: 'Maximum: ${availableBalance.toStringAsFixed(2)}g',
                  ),
                  onChanged: (value) => setDialogState(() {}),
                ),
                const SizedBox(height: 16),
                if (gramsController.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total:'),
                        Text(
                          Formatters.formatCurrency(
                            (double.tryParse(gramsController.text) ?? 0) * pricePerGram,
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final grams = double.tryParse(gramsController.text);

                      if (grams == null || grams <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Veuillez entrer une quantité valide'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      if (grams > availableBalance) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Quantité supérieure au solde disponible'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isLoading = true);

                      try {
                        await _negeService.createOffer(
                          metalType: metalType,
                          grams: grams,
                          pricePerGram: pricePerGram,
                        );

                        if (!context.mounted) return;
                        Navigator.pop(context);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Offre créée avec succès !'),
                            backgroundColor: AppColors.success,
                          ),
                        );

                        _loadAccounts();
                      } catch (e) {
                        if (!context.mounted) return;
                        setDialogState(() => isLoading = false);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString().replaceAll('Exception: ', '')),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Créer l\'offre'),
            ),
          ],
        ),
      ),
    );
  }
}

// Page de transaction Nege
class NegeTransactionPage extends StatefulWidget {
  final String metalType;
  final String transactionType;
  final double pricePerGram;
  final double? balance;
  final NegeService negeService;
  
  const NegeTransactionPage({
    super.key,
    required this.metalType,
    required this.transactionType,
    required this.pricePerGram,
    required this.negeService,
    this.balance,
  });

  @override
  State<NegeTransactionPage> createState() => _NegeTransactionPageState();
}

class _NegeTransactionPageState extends State<NegeTransactionPage> {
  final _gramsController = TextEditingController();
  bool _isLoading = false;
  
  double get totalAmount {
    final grams = double.tryParse(_gramsController.text) ?? 0;
    return grams * widget.pricePerGram;
  }

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  Future<void> _handleTransaction() async {
    print('🔵 _handleTransaction appelée - Type: ${widget.transactionType}');
    
    final grams = double.tryParse(_gramsController.text) ?? 0;
    print('🔵 Grammes saisis: $grams');
    
    if (grams <= 0) {
      print('❌ Grammes invalides: $grams');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez entrer une quantité valide'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      if (widget.transactionType == 'buy') {
        print('🔵 Appel buy...');
        final amountFcfa = grams * widget.pricePerGram;
        await widget.negeService.buy(
          metalType: widget.metalType,
          amountFcfa: amountFcfa,
        );
      } else {
        print('🔵 Appel sell avec: metal=${widget.metalType}, grams=$grams, price=${widget.pricePerGram}');
        await widget.negeService.sell(
          metalType: widget.metalType,
          grams: grams,
          pricePerGram: widget.pricePerGram,
        );
      }
      
      if (!mounted) return;
      
      final action = widget.transactionType == 'buy' ? 'Achat' : 'Vente';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$action effectué avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
      
      Navigator.pop(context, true); // Retourner true pour indiquer le succès
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = widget.transactionType == 'buy';
    final metalName = widget.metalType == 'gold' ? 'Or' : 'Argent';
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${isBuy ? 'Acheter' : 'Vendre'} de l\'$metalName'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Prix du gramme'),
                  Text(
                    Formatters.formatCurrency(widget.pricePerGram),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _gramsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantité (grammes)',
                hintText: 'Ex: 2.5',
                prefixIcon: Icon(Icons.scale),
              ),
              onChanged: (value) {
                setState(() {}); // Recalculer le total
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [0.5, 1.0, 2.5, 5.0, 10.0].map((grams) {
                return ActionChip(
                  label: Text('${grams}g'),
                  onPressed: () {
                    _gramsController.text = grams.toString();
                    setState(() {});
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Montant total',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    Formatters.formatCurrency(totalAmount),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            CustomButton(
              text: isBuy ? 'Acheter' : 'Vendre',
              onPressed: totalAmount > 0 ? _handleTransaction : null,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== PAGE MARKETPLACE ====================

class NegeMarketplacePage extends StatefulWidget {
  final String metalType;
  final NegeService negeService;
  final VoidCallback onTransactionComplete;

  const NegeMarketplacePage({
    super.key,
    required this.metalType,
    required this.negeService,
    required this.onTransactionComplete,
  });

  @override
  State<NegeMarketplacePage> createState() => _NegeMarketplacePageState();
}

class _NegeMarketplacePageState extends State<NegeMarketplacePage> {
  List<dynamic> _offers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() => _isLoading = true);

    try {
      final offers = await widget.negeService.getOffers(metalType: widget.metalType);
      if (mounted) {
        setState(() {
          _offers = offers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'Marketplace ${widget.metalType == 'gold' ? 'Or' : 'Argent'}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh, color: Colors.white),
                        onPressed: _loadOffers,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_offers.length} offre${_offers.length > 1 ? 's' : ''} disponible${_offers.length > 1 ? 's' : ''}',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          // Liste des offres
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _offers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.store_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune offre disponible',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Soyez le premier à créer une offre !',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOffers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _offers.length,
                          itemBuilder: (context, index) {
                            final offer = _offers[index];
                            return _buildOfferCard(offer);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    final grams = offer['grams'] as double;
    final pricePerGram = offer['price_per_gram'] as double;
    final totalPrice = offer['total_price'] as double;
    final sellerName = offer['seller_name'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showBuyDialog(offer),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.metalType == 'gold'
                          ? const Color(0xFFFFD700).withOpacity(0.2)
                          : const Color(0xFFC0C0C0).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.metalType == 'gold' ? Icons.diamond : Icons.star,
                      color: widget.metalType == 'gold'
                          ? const Color(0xFFFFD700)
                          : const Color(0xFFC0C0C0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sellerName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${grams.toStringAsFixed(2)}g disponible',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prix/gramme',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        Formatters.formatCurrency(pricePerGram),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Prix total',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        Formatters.formatCurrency(totalPrice),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showBuyDialog(offer),
                  icon: Icon(Icons.shopping_cart),
                  label: Text('Acheter'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBuyDialog(Map<String, dynamic> offer) {
    final offerId = offer['id'] as int;
    final availableGrams = offer['grams'] as double;
    final pricePerGram = offer['price_per_gram'] as double;
    final sellerName = offer['seller_name'] as String;
    
    final gramsController = TextEditingController(text: availableGrams.toStringAsFixed(2));
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final grams = double.tryParse(gramsController.text) ?? 0;
          final total = grams * pricePerGram;

          return AlertDialog(
            title: Text('Acheter à $sellerName'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: gramsController,
                    keyboardType: TextInputType.number,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      labelText: 'Quantité (grammes)',
                      suffixText: 'g',
                      border: const OutlineInputBorder(),
                      helperText: 'Maximum: ${availableGrams.toStringAsFixed(2)}g',
                    ),
                    onChanged: (value) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Prix/gramme:'),
                            Text(
                              Formatters.formatCurrency(pricePerGram),
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Quantité:'),
                            Text(
                              '${grams.toStringAsFixed(2)}g',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              Formatters.formatCurrency(total),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (grams <= 0 || grams > availableGrams) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Quantité invalide'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }

                        setDialogState(() => isLoading = true);

                        try {
                          await widget.negeService.buyOffer(
                            offerId: offerId,
                            grams: grams,
                          );

                          if (!context.mounted) return;
                          Navigator.pop(context);
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Achat effectué avec succès !'),
                              backgroundColor: AppColors.success,
                            ),
                          );

                          widget.onTransactionComplete();
                        } catch (e) {
                          if (!context.mounted) return;
                          setDialogState(() => isLoading = false);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString().replaceAll('Exception: ', '')),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Confirmer l\'achat'),
              ),
            ],
          );
        },
      ),
    );
  }
}
