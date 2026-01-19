import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/services/jufa_card_service.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../navigation/presentation/widgets/bottom_navigation_widget.dart';

class JufaPage extends StatefulWidget {
  const JufaPage({super.key});

  @override
  State<JufaPage> createState() => _JufaPageState();
}

class _JufaPageState extends State<JufaPage> with SingleTickerProviderStateMixin {
  final JufaCardService _cardService = JufaCardService();
  final double _balance = 250000.0;
  final double _creditAmount = 50000.0;
  final Map<int, bool> _cardFlipped = {}; // Pour gérer l'état de retournement des cartes

  List<Map<String, dynamic>> _virtualCards = [];
  List<Map<String, dynamic>> _physicalCards = [];
  bool _isLoading = true;
  
  TabController? _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController!.index;
      });
    });
    _loadCards();
  }
  
  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);

    try {
      print('🔄 Chargement des cartes...');
      final cards = await _cardService.getCards();
      print('✅ Cartes chargées: ${cards.length}');

      if (!mounted) return;

      setState(() {
        _virtualCards = cards
            .where((card) => card['card_type'] == 'virtual')
            .map((card) => {
                  'id': card['id'],
                  'cardNumber': card['masked_card_number'],
                  'fullCardNumber': card['card_number'],
                  'cardHolder': card['card_holder_name'],
                  'expiryDate': card['expiry_date'],
                  'cvv': card['cvv'] ?? '***',
                  'type': 'virtual',
                  'status': card['card_status'] == 'active' ? 'active' : 'blocked',
                  'balance': double.parse(card['balance'].toString()),
                  'color': Colors.blue,
                  'hasPin': card['has_pin'],
                })
            .toList();

        _physicalCards = cards
            .where((card) => card['card_type'] == 'physical')
            .map((card) => {
                  'id': card['id'],
                  'cardNumber': card['masked_card_number'],
                  'fullCardNumber': card['card_number'],
                  'cardHolder': card['card_holder_name'],
                  'expiryDate': card['expiry_date'],
                  'cvv': card['cvv'] ?? '***',
                  'type': 'physical',
                  'status': card['card_status'] == 'active' ? 'active' : 
                           card['card_status'] == 'pending' ? 'in_progress' : 'blocked',
                  'balance': double.parse(card['balance'].toString()),
                  'color': Colors.indigo.shade800,
                  'hasPin': card['has_pin'],
                })
            .toList();

        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur chargement cartes: $e');
      
      if (!mounted) return;
      
      final l10n = AppLocalizations.of(context);
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.translate('error')}: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  final List<Map<String, dynamic>> _services = [
    {
      'title': 'Transfert d\'argent',
      'subtitle': 'Envoyez de l\'argent rapidement',
      'icon': Icons.send,
      'color': AppColors.transfer,
      'route': '/transfer',
    },
    {
      'title': 'Paiement de factures',
      'subtitle': 'Payez vos factures facilement',
      'icon': Icons.receipt_long,
      'color': AppColors.bills,
      'route': '/bills',
    },
    {
      'title': 'Recharge téléphonique',
      'subtitle': 'Rechargez votre crédit mobile',
      'icon': Icons.phone_android,
      'color': AppColors.airtime,
      'route': '/airtime',
    },
    {
      'title': 'Historique',
      'subtitle': 'Consultez vos transactions',
      'icon': Icons.history,
      'color': AppColors.info,
      'route': '/history',
    },
    {
      'title': 'Carte Visa',
      'subtitle': 'Gérez votre carte Visa',
      'icon': Icons.credit_card,
      'color': AppColors.primary,
      'route': '/visa-card',
    },
    {
      'title': 'Service Visa',
      'subtitle': 'Services Visa premium',
      'icon': Icons.card_membership,
      'color': AppColors.success,
      'route': '/visa-service',
    },
    {
      'title': 'Banking Services',
      'subtitle': 'Comptes et cartes virtuels',
      'icon': Icons.account_balance,
      'color': AppColors.info,
      'route': '/banking-services',
    },
    {
      'title': 'Investissements',
      'subtitle': 'Crypto et épargne intelligente',
      'icon': Icons.trending_up,
      'color': AppColors.warning,
      'route': '/investments',
    },
    {
      'title': 'Assistant IA',
      'subtitle': 'Conseils financiers intelligents',
      'icon': Icons.smart_toy,
      'color': AppColors.primary,
      'route': '/ai-assistant',
    },
  ];

  final List<Map<String, dynamic>> _quickActions = [
    {
      'title': 'Recevoir',
      'icon': Icons.arrow_downward,
      'color': AppColors.success,
      'route': '/receive',
    },
    {
      'title': 'Envoyer',
      'icon': Icons.arrow_upward,
      'color': AppColors.transfer,
      'route': '/transfer',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.translate('jufa_card_page')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.credit_card, size: 20),
                      SizedBox(width: 8),
                      Text(l10n.translate('virtual')),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.card_membership, size: 20),
                      SizedBox(width: 8),
                      Text(l10n.translate('physical')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVirtualCardsTab(),
          _buildPhysicalCardsTab(),
        ],
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 1),
    );
  }

  Widget _buildVirtualCardsTab() {
    return RefreshIndicator(
      onRefresh: _loadCards,
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _virtualCards.isEmpty
              ? _buildEmptyVirtualCards()
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildFullCardWidget(_virtualCards.first),
                      const SizedBox(height: 24),
                      _buildCardActions(_virtualCards.first),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPhysicalCardsTab() {
    return RefreshIndicator(
      onRefresh: _loadCards,
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _physicalCards.isEmpty
              ? _buildEmptyPhysicalCards()
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildFullCardWidget(_physicalCards.first),
                      const SizedBox(height: 24),
                      _buildCardActions(_physicalCards.first),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCardActions(Map<String, dynamic> card) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showRechargeDialog(card),
            icon: Icon(Icons.add_circle_outline),
            label: Text(l10n.translate('recharge_card')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _blockCard(card),
            icon: Icon(Icons.lock),
            label: Text(l10n.translate('block_card')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _blockCard(Map<String, dynamic> card) async {
    final l10n = AppLocalizations.of(context);
    final cardTypeName = card['type'];
    final cardBalance = card['balance'];
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            SizedBox(width: 8),
            Text(l10n.translate('block_card_title')),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('block_warning'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.translate('blocking_consequences')),
                const SizedBox(height: 8),
                Text(l10n.translate('card_deleted')),
                if (cardBalance > 0) ...[
                  const SizedBox(height: 4),
                  Text(l10n.translate('balance_returned').replaceAll('{amount}', Formatters.formatCurrency(cardBalance))),
                ],
                const SizedBox(height: 4),
                Text(l10n.translate('can_order_new')),
                const SizedBox(height: 20),
                Text(
                  l10n.translate('block_reason'),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: l10n.translate('explain_block'),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.translate('reason_required');
                    }
                    if (value.trim().length < 10) {
                      return l10n.translate('reason_min_length');
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, reasonController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(l10n.translate('block_card')),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) return;

    try {
      final cardId = card['id'];
      await _cardService.blockCard(cardId: cardId, reason: reason);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('card_blocked_success').replaceAll('{type}', l10n.translate(cardTypeName))),
          backgroundColor: AppColors.success,
        ),
      );

      _loadCards();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildFullCardWidget(Map<String, dynamic> card) {
    final l10n = AppLocalizations.of(context);
    final cardId = card.hashCode;
    final isFlipped = _cardFlipped[cardId] ?? false;
    final isVirtual = card['type'] == 'virtual';
    
    return GestureDetector(
      onTap: () {
        if (isVirtual) {
          _showCardDetailsDialog(card);
        } else {
          setState(() {
            _cardFlipped[cardId] = !isFlipped;
          });
        }
      },
      onLongPress: () => _showCardDetailsDialog(card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 400,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: card['type'] == 'Virtuelle'
                ? [Colors.blue.shade600, Colors.blue.shade900]
                : [Colors.indigo.shade700, Colors.indigo.shade900],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (card['color'] as Color).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Card content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Card number
                  if (!isFlipped)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'JUFA ${l10n.translate(card['type'])}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: card['status'] == 'active'
                                        ? Colors.green.withOpacity(0.3)
                                        : Colors.orange.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    l10n.translate(card['status']),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Logo sans contact
                            Icon(
                              Icons.contactless,
                              color: Colors.white.withOpacity(0.9),
                              size: 50,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Puce de carte (seulement pour les cartes physiques)
                        if (!isVirtual)
                          Container(
                            width: 50,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.amber.shade300,
                              borderRadius: BorderRadius.circular(8),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.amber.shade200,
                                  Colors.amber.shade400,
                                ],
                              ),
                            ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: 3,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade700,
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                  Container(
                                    width: 3,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade700,
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                  Container(
                                    width: 3,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade700,
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        Text(
                          card['cardNumber'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.translate('card_holder'),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 10,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  card['cardHolder'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.translate('expires'),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 10,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  card['expiryDate'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    // Back of card - Bande magnétique, signature et CVV
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Bande magnétique noire
                        Container(
                          height: 45,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 16),
                        
                        // Zone de signature et CVV
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Zone de signature
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: Text(
                                          card['cardHolder'],
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.translate('signature'),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // CVV à droite
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      card['cvv'],
                                      style: TextStyle(
                                        color: Colors.grey.shade900,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'CVV',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 50),
                        
                        // Note de sécurité
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.amber.shade300,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    l10n.translate('never_share_cvv'),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
    );
  }

  Widget _buildCardWidget(Map<String, dynamic> card) {
    // Utiliser le hashCode de la carte comme identifiant unique
    final cardId = card.hashCode;
    final isFlipped = _cardFlipped[cardId] ?? false;
    final isPhysical = card['type'] == 'Physique';
    
    return GestureDetector(
      onTap: () {
        if (isPhysical) {
          setState(() {
            _cardFlipped[cardId] = !isFlipped;
          });
        } else {
          _showCardDetailsDialog(card);
        }
      },
      onLongPress: () => _showCardDetailsDialog(card),
      child: Container(
        width: 320,
        height: 200,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              card['color'],
              card['color'].withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: card['color'].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Recto ou Verso
            if (!isPhysical || !isFlipped) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card['type'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: card['status'] == 'Active'
                              ? Colors.green.withOpacity(0.3)
                              : Colors.orange.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          card['status'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Puce de la carte (uniquement pour cartes physiques)
                      if (isPhysical) ...[
                        Container(
                          width: 35,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.amber.shade600,
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.amber.shade400,
                                Colors.amber.shade700,
                              ],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              3,
                              (index) => Container(
                                width: 2,
                                height: 14,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Icon(
                        Icons.contactless,
                        color: Colors.white,
                        size: 32,
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge VISA pour toutes les cartes
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'VISA',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    card['cardNumber'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TITULAIRE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 8,
                            ),
                          ),
                          Text(
                            card['cardHolder'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EXPIRE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 8,
                            ),
                          ),
                          Text(
                            card['expiryDate'],
                            style: TextStyle(
                              color: Colors.white,
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
            ] else ...[
              // Verso de la carte physique
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VERSO',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Bande magnétique
                        Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Zone de signature et CVV
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    'Signature',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 9,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'CVV',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 7,
                                    ),
                                  ),
                                  Text(
                                    card['cvv'],
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      'Ne partagez jamais votre CVV',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyVirtualCards() {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.credit_card_off,
            size: 40,
            color: Colors.blue.shade300,
          ),
          const SizedBox(height: 8),
          Text(
            'Aucune carte virtuelle',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Commandez votre première carte',
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue.shade600,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => context.push('/order-card'),
            icon: Icon(Icons.add, size: 16),
            label: Text('Commander', style: TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPhysicalCards() {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.credit_card_off,
            size: 40,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Aucune carte physique',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Commandez votre première carte',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => context.push('/order-card'),
            icon: Icon(Icons.add, size: 16),
            label: Text('Commander', style: TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBenefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Avantages Carte Jufa',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildBenefitCard(
          icon: Icons.security,
          title: 'Sécurité maximale',
          description: 'Vos transactions sont protégées par une technologie de pointe',
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildBenefitCard(
          icon: Icons.flash_on,
          title: 'Paiements instantanés',
          description: 'Payez en ligne et en magasin en quelques secondes',
          color: Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildBenefitCard(
          icon: Icons.account_balance_wallet,
          title: 'Gestion simplifiée',
          description: 'Contrôlez vos dépenses et rechargez facilement',
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTile(Map<String, dynamic> service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: service['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            service['icon'],
            color: service['color'],
            size: 24,
          ),
        ),
        title: Text(
          service['title'],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          service['subtitle'],
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textSecondary,
        ),
        onTap: () {
          if (service['route'] == '/visa-card' || service['route'] == '/visa-service') {
            _showVisaFeatureDialog(service['title']);
          } else if (service['route'] == '/banking-services' || service['route'] == '/investments') {
            context.push(service['route']);
          } else {
            context.push(service['route']);
          }
        },
      ),
    );
  }

  void _showReceiveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.arrow_downward, color: AppColors.success),
            SizedBox(width: 8),
            Text('Recevoir de l\'argent'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Partagez votre QR code ou votre numéro Jufa pour recevoir de l\'argent.'),
            SizedBox(height: 16),
            Icon(Icons.qr_code, size: 100, color: AppColors.primary),
            SizedBox(height: 8),
            Text('Votre code Jufa: #123456789'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Code partagé avec succès'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text('Partager'),
          ),
        ],
      ),
    );
  }

  void _showVisaFeatureDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text('$title sera bientôt disponible dans l\'application Jufa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAddCardDialog() {
    final formKey = GlobalKey<FormState>();
    final cardNameController = TextEditingController();
    final initialAmountController = TextEditingController();
    String selectedCardType = 'Standard';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.add_card, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Nouvelle carte virtuelle'),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Créez une nouvelle carte virtuelle pour vos achats en ligne.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  
                  // Nom de la carte
                  TextFormField(
                    controller: cardNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de la carte',
                      hintText: 'Ex: Carte Shopping',
                      prefixIcon: Icon(Icons.label),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un nom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Type de carte
                  DropdownButtonFormField<String>(
                    value: selectedCardType,
                    decoration: const InputDecoration(
                      labelText: 'Type de carte',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Standard', child: Text('Standard')),
                      DropdownMenuItem(value: 'Premium', child: Text('Premium')),
                      DropdownMenuItem(value: 'Business', child: Text('Business')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCardType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Montant initial
                  TextFormField(
                    controller: initialAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Montant initial (FCFA)',
                      hintText: '0',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final amount = double.tryParse(value);
                        if (amount == null || amount < 0) {
                          return 'Montant invalide';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Informations
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Caractéristiques:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('• Création instantanée', style: TextStyle(fontSize: 11)),
                        Text('• Utilisable immédiatement', style: TextStyle(fontSize: 11)),
                        Text('• Rechargeable à volonté', style: TextStyle(fontSize: 11)),
                        Text('• Blocage/déblocage facile', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                cardNameController.dispose();
                initialAmountController.dispose();
                Navigator.pop(context);
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final cardName = cardNameController.text;
                  final amount = initialAmountController.text.isEmpty 
                      ? 0.0 
                      : double.parse(initialAmountController.text);
                  
                  cardNameController.dispose();
                  initialAmountController.dispose();
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Carte "$cardName" créée avec succès !'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderPhysicalCardDialog() {
    final formKey = GlobalKey<FormState>();
    final fullNameController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedCardDesign = 'Classique';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.credit_card, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Commander une carte physique'),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Commandez votre carte Jufa physique et recevez-la chez vous.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  
                  // Nom complet
                  TextFormField(
                    controller: fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      hintText: 'Nom sur la carte',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre nom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Adresse de livraison
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Adresse de livraison',
                      hintText: 'Rue, quartier',
                      prefixIcon: Icon(Icons.home),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre adresse';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Ville
                  TextFormField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: 'Ville',
                      hintText: 'Ex: Bamako',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre ville';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Téléphone
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      hintText: '+223 XX XX XX XX',
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('🇲🇱', style: TextStyle(fontSize: 24)),
                      ),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre numéro';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Design de la carte
                  DropdownButtonFormField<String>(
                    value: selectedCardDesign,
                    decoration: const InputDecoration(
                      labelText: 'Design de la carte',
                      prefixIcon: Icon(Icons.palette),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Classique', child: Text('Classique (Bleu)')),
                      DropdownMenuItem(value: 'Premium', child: Text('Premium (Noir)')),
                      DropdownMenuItem(value: 'Gold', child: Text('Gold (Or)')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCardDesign = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Informations
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Avantages:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('• Livraison gratuite', style: TextStyle(fontSize: 11)),
                        Text('• Acceptée partout', style: TextStyle(fontSize: 11)),
                        Text('• Paiements sans contact', style: TextStyle(fontSize: 11)),
                        Text('• Retraits aux distributeurs', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Frais de commande: 5 000 FCFA\nLivraison sous 5-7 jours',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                fullNameController.dispose();
                addressController.dispose();
                cityController.dispose();
                phoneController.dispose();
                Navigator.pop(context);
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final name = fullNameController.text;
                  
                  fullNameController.dispose();
                  addressController.dispose();
                  cityController.dispose();
                  phoneController.dispose();
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Commande enregistrée pour $name ! Livraison sous 5-7 jours.'),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
              child: Text('Commander'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCardDetailsDialog(Map<String, dynamic> card) async {
    final l10n = AppLocalizations.of(context);
    // Afficher un dialogue de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Charger les détails complets de la carte depuis l'API
      print('🔍 Chargement détails carte ${card['id']}...');
      final cardDetails = await _cardService.getCardDetails(card['id']);
      print('✅ Détails chargés: $cardDetails');

      if (!mounted) return;

      // Fermer le dialogue de chargement
      Navigator.pop(context);

      // Afficher les détails
      final fullCardNumber = cardDetails['card_number'] ?? card['cardNumber'];
      final cvv = cardDetails['cvv'] ?? '***';
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.translate('card_details').replaceAll('{type}', l10n.translate(card['type']))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Numéro de carte en grand
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [card['color'], card['color'].withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate('card_number_label'),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            fullCardNumber,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy, color: Colors.white, size: 20),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.translate('number_copied')),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          tooltip: l10n.translate('copy'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(l10n.translate('card_holder_label'), card['cardHolder']),
              _buildDetailRow(l10n.translate('expiration'), card['expiryDate']),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CVV',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      cvv,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 18,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDetailRow(l10n.translate('status'), l10n.translate(card['status'])),
              _buildDetailRow(l10n.translate('balance_label'), Formatters.formatCurrency(card['balance'])),
            ],
          ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('close')),
          ),
        ],
      ),
    );
    } catch (e) {
      print('❌ Erreur chargement détails: $e');
      
      if (!mounted) return;
      
      // Fermer le dialogue de chargement
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.translate('error')}: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showRechargeDialog(Map<String, dynamic> card) {
    final l10n = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    double reloadFeePercentage = 1.0;
    bool isLoadingFees = true;

    // Récupérer les frais de recharge
    _cardService.getReloadFeePercentage().then((fee) {
      reloadFeePercentage = fee;
      if (mounted) {
        setState(() {
          isLoadingFees = false;
        });
      }
    }).catchError((e) {
      print('❌ Erreur récupération frais: $e');
      if (mounted) {
        setState(() {
          isLoadingFees = false;
        });
      }
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final amount = double.tryParse(amountController.text) ?? 0;
          final feeAmount = (amount * reloadFeePercentage) / 100;
          final totalAmount = amount + feeAmount;

          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.add_circle, color: AppColors.success),
                const SizedBox(width: 8),
                Text(l10n.translate('recharge_card_title').replaceAll('{type}', l10n.translate(card['type']))),
              ],
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.translate('current_balance').replaceAll('{balance}', Formatters.formatCurrency(card['balance'])),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: l10n.translate('amount_to_recharge'),
                      hintText: l10n.translate('example_amount'),
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setDialogState(() {});
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.translate('enter_amount');
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return l10n.translate('invalid_amount');
                      }
                      if (amount < 500) {
                        return l10n.translate('minimum_500');
                      }
                      return null;
                    },
                  ),
                  if (amount > 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.translate('amount_colon'), style: TextStyle(fontSize: 12)),
                              Text(
                                Formatters.formatCurrency(amount),
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.translate('fees_percent').replaceAll('{percent}', reloadFeePercentage.toString()), style: TextStyle(fontSize: 12)),
                              Text(
                                Formatters.formatCurrency(feeAmount),
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                            ],
                          ),
                          Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.translate('total_to_pay'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              Text(
                                Formatters.formatCurrency(totalAmount),
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.translate('debit_info'),
                            style: TextStyle(fontSize: 11),
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
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.translate('cancel')),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final amount = double.parse(amountController.text);
                    Navigator.pop(context);
                    
                    // Afficher un loader
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    try {
                      print('💳 Recharge carte ${card['id']} de $amount FCFA...');
                      final result = await _cardService.rechargeCard(
                        cardId: card['id'],
                        amount: amount,
                      );
                      print('✅ Recharge réussie: $result');

                      if (!mounted) return;

                      // Fermer le loader
                      Navigator.pop(context);

                      // Recharger les cartes
                      await _loadCards();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${l10n.translate('recharge_success')} ${Formatters.formatCurrency(amount)}'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } catch (e) {
                      print('❌ Erreur recharge: $e');
                      // Note: Le loader se ferme automatiquement car le dialogue se ferme
                    }
                  }
                },
                child: Text(l10n.translate('confirm_recharge')),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBlockCardConfirmation(Map<String, dynamic> card) {
    String? selectedReason;
    final TextEditingController otherReasonController = TextEditingController();
    
    final reasons = [
      'Carte perdue',
      'Carte volée',
      'Activité suspecte',
      'Carte endommagée',
      'Autre',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: AppColors.error),
              const SizedBox(width: 8),
              Text('Bloquer la carte'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avertissement
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'ATTENTION : Cette action est irréversible',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Sélection du motif
                Text(
                  'Motif du blocage *',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedReason,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Sélectionnez un motif',
                  ),
                  items: reasons.map((reason) {
                    return DropdownMenuItem(
                      value: reason,
                      child: Text(reason),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedReason = value;
                    });
                  },
                ),
                
                // Champ texte si "Autre"
                if (selectedReason == 'Autre') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: otherReasonController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Précisez le motif',
                      hintText: 'Entrez le motif du blocage',
                    ),
                    maxLines: 2,
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Conséquences
                Text(
                  'Conséquences :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildConsequenceItem(
                  Icons.block,
                  'La carte sera définitivement bloquée',
                ),
                _buildConsequenceItem(
                  Icons.credit_card_off,
                  'Aucune transaction ne sera possible',
                ),
                _buildConsequenceItem(
                  Icons.account_balance_wallet,
                  'Le solde sera transféré vers votre compte principal',
                ),
                _buildConsequenceItem(
                  Icons.info_outline,
                  'Vous devrez commander une nouvelle carte',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: selectedReason == null
                  ? null
                  : () async {
                      // Vérifier si "Autre" est sélectionné et le champ est vide
                      if (selectedReason == 'Autre' && 
                          otherReasonController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Veuillez préciser le motif'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      final reason = selectedReason == 'Autre'
                          ? otherReasonController.text.trim()
                          : selectedReason!;

                      Navigator.pop(context);

                      // Afficher un loader
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      try {
                        await _cardService.blockCard(
                          cardId: card['id'],
                          reason: reason,
                        );

                        if (!mounted) return;

                        // Fermer le loader
                        Navigator.pop(context);

                        // Recharger les cartes
                        await _loadCards();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Carte bloquée. Le solde a été transféré vers votre compte.',
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;

                        // Fermer le loader
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Erreur: ${e.toString().replaceAll('Exception: ', '')}',
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: Text('Confirmer le blocage'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsequenceItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUnblockCardConfirmation(Map<String, dynamic> card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock_open, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Débloquer la carte'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir débloquer cette carte ?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'La carte sera réactivée et pourra être utilisée à nouveau.',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Afficher un loader
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                await _cardService.unblockCard(card['id']);

                if (!mounted) return;

                // Fermer le loader
                Navigator.pop(context);

                // Recharger les cartes
                await _loadCards();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Carte débloquée avec succès !'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                if (!mounted) return;

                // Fermer le loader
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Erreur: ${e.toString().replaceAll('Exception: ', '')}',
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showAuthenticationDialog() async {
    final pinController = TextEditingController();
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Authentification'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Veuillez entrer votre code PIN pour confirmer',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                letterSpacing: 16,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: '••••',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Simuler l'authentification biométrique
                    Navigator.pop(context, true);
                  },
                  icon: Icon(Icons.fingerprint, size: 32),
                  label: Text('Biométrie'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Simuler la vérification du PIN (dans un vrai système, vérifier avec le serveur)
              if (pinController.text.length == 4) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Code PIN invalide'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: Text('Valider'),
          ),
        ],
      ),
    );
    
    pinController.dispose();
    return result ?? false;
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
