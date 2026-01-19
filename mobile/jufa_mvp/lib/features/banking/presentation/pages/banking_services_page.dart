import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../navigation/presentation/widgets/bottom_navigation_widget.dart';
import '../../domain/models/virtual_account_model.dart';
import '../../domain/models/virtual_card_model.dart';

class BankingServicesPage extends StatefulWidget {
  const BankingServicesPage({super.key});

  @override
  State<BankingServicesPage> createState() => _BankingServicesPageState();
}

class _BankingServicesPageState extends State<BankingServicesPage> {
  // Données de démonstration
  final List<VirtualAccount> _accounts = [
    VirtualAccount(
      id: '1',
      userId: 'user1',
      name: 'Compte Principal',
      accountNumber: 'ML1234567890123456',
      iban: 'ML76 1234 5678 9012 3456 7890 12',
      currency: 'FCFA',
      balance: 250000.0,
      type: 'standard',
      isActive: true,
      isMultiCurrency: false,
    ),
    VirtualAccount(
      id: '2',
      userId: 'user1',
      name: 'Compte Multi-devises',
      accountNumber: 'EU9876543210987654',
      iban: 'FR14 2004 1010 0505 0001 3M02 606',
      currency: 'EUR',
      balance: 1250.50,
      type: 'multi_currency',
      isActive: true,
      isMultiCurrency: true,
    ),
  ];

  final List<VirtualCard> _cards = [
    VirtualCard(
      id: '1',
      userId: 'user1',
      cardNumber: '4532123456789012',
      cardHolder: 'UTILISATEUR JUFA',
      expiryDate: '12/27',
      cvv: '123',
      cardType: CardType.visa,
      status: CardStatus.active,
      balance: 250000.0,
      currency: 'FCFA',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Services Bancaires'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showCreateAccountDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            
            const SizedBox(height: 24),
            
            // Comptes Virtuels
            _buildAccountsSection(),
            
            const SizedBox(height: 32),
            
            // Cartes Virtuelles
            _buildCardsSection(),
            
            const SizedBox(height: 32),
            
            // Services Rapides
            _buildQuickServicesSection(),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 1),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.blueGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Banking as a Service',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gérez vos comptes et cartes virtuels',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard('Comptes', _accounts.length.toString(), Icons.account_balance),
              const SizedBox(width: 16),
              _buildStatCard('Cartes', _cards.length.toString(), Icons.credit_card),
              const SizedBox(width: 16),
              _buildStatCard('Devises', '3', Icons.currency_exchange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Comptes Virtuels',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showCreateAccountDialog(),
              icon: Icon(Icons.add, size: 16),
              label: Text('Nouveau'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _accounts.length,
          itemBuilder: (context, index) {
            final account = _accounts[index];
            return _buildAccountCard(account);
          },
        ),
      ],
    );
  }

  Widget _buildAccountCard(VirtualAccount account) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                    account.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    account.maskedAccountNumber,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: account.isMultiCurrency ? AppColors.warning.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  account.currency,
                  style: TextStyle(
                    fontSize: 10,
                    color: account.isMultiCurrency ? AppColors.warning : AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            account.formattedBalance,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'IBAN: ${account.iban}',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cartes Virtuelles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showCreateCardDialog(),
              icon: Icon(Icons.add, size: 16),
              label: Text('Nouvelle'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _cards.length,
          itemBuilder: (context, index) {
            final card = _cards[index];
            return _buildCardWidget(card);
          },
        ),
      ],
    );
  }

  Widget _buildCardWidget(VirtualCard card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 200,
      decoration: BoxDecoration(
        gradient: card.cardType == CardType.visa 
          ? LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : LinearGradient(
              colors: [Color(0xFFBF360C), Color(0xFFFF5722)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card.cardBrand,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: card.isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    card.statusText,
                    style: TextStyle(
                      color: card.isActive ? Colors.lightGreenAccent : Colors.redAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              card.displayCardNumber,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                fontFamily: 'monospace',
              ),
            ),
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
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      card.cardholderName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'EXPIRE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      card.expiryDate,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickServicesSection() {
    final services = [
      {
        'title': 'Épargne Intelligente',
        'subtitle': 'Comptes avec intérêts automatiques',
        'icon': Icons.savings,
        'color': AppColors.success,
        'onTap': () => _showComingSoonDialog('Épargne Intelligente'),
      },
      {
        'title': 'Prêts Express',
        'subtitle': 'Micro-crédits instantanés',
        'icon': Icons.trending_up,
        'color': AppColors.warning,
        'onTap': () => _showComingSoonDialog('Prêts Express'),
      },
      {
        'title': 'Change Multi-Devises',
        'subtitle': 'Conversion temps réel',
        'icon': Icons.currency_exchange,
        'color': AppColors.info,
        'onTap': () => _showComingSoonDialog('Change Multi-Devises'),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services Avancés',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
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
                    color: (service['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    service['icon'] as IconData,
                    color: service['color'] as Color,
                    size: 24,
                  ),
                ),
                title: Text(
                  service['title'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  service['subtitle'] as String,
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
                onTap: service['onTap'] as VoidCallback,
              ),
            );
          },
        ),
      ],
    );
  }

  void _showCreateAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nouveau Compte Virtuel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choisissez le type de compte à créer :'),
            SizedBox(height: 16),
            // TODO: Ajouter sélecteur de type de compte
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoonDialog('Création de compte');
            },
            child: Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showCreateCardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nouvelle Carte Virtuelle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Générer une nouvelle carte virtuelle instantanément :'),
            SizedBox(height: 16),
            // TODO: Ajouter sélecteur de type de carte
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoonDialog('Génération de carte');
            },
            child: Text('Générer'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text('$feature sera bientôt disponible dans l\'application Jufa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
