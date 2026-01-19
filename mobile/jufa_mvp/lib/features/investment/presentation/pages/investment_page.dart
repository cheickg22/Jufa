import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../navigation/presentation/widgets/bottom_navigation_widget.dart';
import '../../domain/models/crypto_asset_model.dart';

class InvestmentPage extends StatefulWidget {
  const InvestmentPage({super.key});

  @override
  State<InvestmentPage> createState() => _InvestmentPageState();
}

class _InvestmentPageState extends State<InvestmentPage> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Données de démonstration
  final double _totalPortfolioValue = 125000.0;
  final double _totalInvested = 100000.0;
  final double _totalPnl = 25000.0;
  final double _totalPnlPercentage = 25.0;

  final List<CryptoAsset> _cryptoAssets = [
    CryptoAsset(
      id: 'bitcoin',
      symbol: 'BTC',
      name: 'Bitcoin',
      iconUrl: '',
      currentPrice: 43250.0,
      priceChange24h: 1250.0,
      priceChangePercentage24h: 2.98,
      marketCap: 847000000000,
      volume24h: 15600000000,
      marketCapRank: 1,
      lastUpdated: DateTime.now(),
    ),
    CryptoAsset(
      id: 'ethereum',
      symbol: 'ETH',
      name: 'Ethereum',
      iconUrl: '',
      currentPrice: 2650.0,
      priceChange24h: -45.0,
      priceChangePercentage24h: -1.67,
      marketCap: 318000000000,
      volume24h: 8900000000,
      marketCapRank: 2,
      lastUpdated: DateTime.now(),
    ),
    CryptoAsset(
      id: 'tether',
      symbol: 'USDT',
      name: 'Tether',
      iconUrl: '',
      currentPrice: 1.0,
      priceChange24h: 0.001,
      priceChangePercentage24h: 0.1,
      marketCap: 91000000000,
      volume24h: 24000000000,
      marketCapRank: 3,
      lastUpdated: DateTime.now(),
    ),
  ];

  final List<CryptoPortfolio> _portfolio = [
    CryptoPortfolio(
      id: '1',
      userId: 'user1',
      assetId: 'bitcoin',
      symbol: 'BTC',
      quantity: 0.5,
      averageBuyPrice: 40000.0,
      currentPrice: 43250.0,
      totalValue: 21625.0,
      totalInvested: 20000.0,
      unrealizedPnl: 1625.0,
      unrealizedPnlPercentage: 8.125,
      firstPurchaseDate: DateTime.now().subtract(const Duration(days: 45)),
      lastUpdated: DateTime.now(),
    ),
    CryptoPortfolio(
      id: '2',
      userId: 'user1',
      assetId: 'ethereum',
      symbol: 'ETH',
      quantity: 2.0,
      averageBuyPrice: 2500.0,
      currentPrice: 2650.0,
      totalValue: 5300.0,
      totalInvested: 5000.0,
      unrealizedPnl: 300.0,
      unrealizedPnlPercentage: 6.0,
      firstPurchaseDate: DateTime.now().subtract(const Duration(days: 30)),
      lastUpdated: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Investissements'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Portfolio'),
            Tab(text: 'Marchés'),
            Tab(text: 'Épargne'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPortfolioTab(),
          _buildMarketsTab(),
          _buildSavingsTab(),
        ],
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 1),
    );
  }

  Widget _buildPortfolioTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Portfolio Summary
          _buildPortfolioSummary(),
          
          const SizedBox(height: 24),
          
          // Holdings
          _buildHoldingsSection(),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildPortfolioSummary() {
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
            'Valeur Totale du Portfolio',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.formatCurrency(_totalPortfolioValue),
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Investi',
                  Formatters.formatCurrency(_totalInvested),
                  Icons.trending_up,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'P&L',
                  '${_totalPnl > 0 ? '+' : ''}${Formatters.formatCurrency(_totalPnl)}',
                  _totalPnl > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Rendement',
                  '${_totalPnlPercentage > 0 ? '+' : ''}${_totalPnlPercentage.toStringAsFixed(2)}%',
                  _totalPnlPercentage > 0 ? Icons.trending_up : Icons.trending_down,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mes Positions',
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
          itemCount: _portfolio.length,
          itemBuilder: (context, index) {
            final holding = _portfolio[index];
            return _buildHoldingCard(holding);
          },
        ),
      ],
    );
  }

  Widget _buildHoldingCard(CryptoPortfolio holding) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                holding.symbol,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holding.symbol,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${holding.formattedQuantity} ${holding.symbol}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                holding.formattedTotalValue,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: holding.isProfit 
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  holding.formattedPnlPercentage,
                  style: TextStyle(
                    fontSize: 10,
                    color: holding.isProfit ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Marchés Crypto',
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
            itemCount: _cryptoAssets.length,
            itemBuilder: (context, index) {
              final asset = _cryptoAssets[index];
              return _buildAssetCard(asset);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCard(CryptoAsset asset) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                asset.symbol,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rang #${asset.marketCapRank}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                asset.formattedPrice,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: asset.isPriceUp 
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  asset.formattedPriceChange,
                  style: TextStyle(
                    fontSize: 10,
                    color: asset.isPriceUp ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _showBuySellDialog(asset),
            icon: Icon(Icons.add_circle_outline),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSavingsHeader(),
          const SizedBox(height: 24),
          _buildSavingsProducts(),
        ],
      ),
    );
  }

  Widget _buildSavingsHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.successGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Épargne Intelligente',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Faites fructifier votre argent automatiquement',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSavingsStatItem('Taux', '5.2%', Icons.trending_up),
              ),
              Expanded(
                child: _buildSavingsStatItem('Épargné', '50 000 FCFA', Icons.savings),
              ),
              Expanded(
                child: _buildSavingsStatItem('Gains', '2 600 FCFA', Icons.monetization_on),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsStatItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsProducts() {
    final products = [
      {
        'title': 'Épargne Flexible',
        'subtitle': 'Retirez quand vous voulez',
        'rate': '3.5%',
        'icon': Icons.account_balance_wallet,
        'color': AppColors.info,
      },
      {
        'title': 'Épargne 6 Mois',
        'subtitle': 'Blocage 6 mois minimum',
        'rate': '5.2%',
        'icon': Icons.lock_clock,
        'color': AppColors.warning,
      },
      {
        'title': 'Épargne 1 An',
        'subtitle': 'Blocage 12 mois minimum',
        'rate': '7.8%',
        'icon': Icons.trending_up,
        'color': AppColors.success,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Produits d\'Épargne',
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
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
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
                    color: (product['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    product['icon'] as IconData,
                    color: product['color'] as Color,
                    size: 24,
                  ),
                ),
                title: Text(
                  product['title'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  product['subtitle'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product['rate'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: product['color'] as Color,
                      ),
                    ),
                    Text(
                      'par an',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                onTap: () => _showComingSoonDialog(product['title'] as String),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions Rapides',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Acheter Crypto',
                Icons.add_circle,
                AppColors.success,
                () => _showComingSoonDialog('Achat Crypto'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Vendre Crypto',
                Icons.remove_circle,
                AppColors.error,
                () => _showComingSoonDialog('Vente Crypto'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Épargne Auto',
                Icons.autorenew,
                AppColors.info,
                () => _showComingSoonDialog('Épargne Automatique'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Staking',
                Icons.lock,
                AppColors.warning,
                () => _showComingSoonDialog('Staking'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showBuySellDialog(CryptoAsset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${asset.name} (${asset.symbol})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Prix actuel: ${asset.formattedPrice}'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showComingSoonDialog('Achat ${asset.symbol}');
                    },
                    icon: Icon(Icons.add),
                    label: Text('Acheter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showComingSoonDialog('Vente ${asset.symbol}');
                    },
                    icon: Icon(Icons.remove),
                    label: Text('Vendre'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
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
