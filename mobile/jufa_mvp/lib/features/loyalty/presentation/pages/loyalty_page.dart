import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../navigation/presentation/widgets/bottom_navigation_widget.dart';
import '../../../marketplace/domain/models/marketplace_models.dart';

class LoyaltyPage extends StatefulWidget {
  const LoyaltyPage({super.key});

  @override
  State<LoyaltyPage> createState() => _LoyaltyPageState();
}

class _LoyaltyPageState extends State<LoyaltyPage> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Données simulées
  final LoyaltyProgram _loyaltyProgram = LoyaltyProgram(
    id: '1',
    userId: 'user1',
    totalPoints: 12450,
    availablePoints: 8200,
    usedPoints: 4250,
    currentTier: LoyaltyTier.gold,
    pointsToNextTier: 2550,
    totalCashbackEarned: 45000.0,
    recentTransactions: [],
    availableRewards: [],
    joinDate: DateTime.now().subtract(const Duration(days: 180)),
    lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
  );

  final List<Reward> _availableRewards = [
    Reward(
      id: '1',
      title: '10% de réduction',
      description: 'Sur votre prochain achat de 50 000 FCFA minimum',
      pointsCost: 1000,
      type: RewardType.discount,
      imageUrl: '',
      details: {'discount': 10, 'minimum': 50000},
      expiryDate: DateTime.now().add(const Duration(days: 30)),
      isAvailable: true,
      maxRedemptions: 100,
      currentRedemptions: 23,
    ),
    Reward(
      id: '2',
      title: 'Livraison gratuite',
      description: 'Livraison gratuite pour vos 3 prochaines commandes',
      pointsCost: 500,
      type: RewardType.freeShipping,
      imageUrl: '',
      details: {'count': 3},
      expiryDate: DateTime.now().add(const Duration(days: 15)),
      isAvailable: true,
      maxRedemptions: 50,
      currentRedemptions: 12,
    ),
    Reward(
      id: '3',
      title: 'Cashback 5000 FCFA',
      description: 'Cashback direct dans votre portefeuille Jufa',
      pointsCost: 2500,
      type: RewardType.cashback,
      imageUrl: '',
      details: {'amount': 5000},
      expiryDate: DateTime.now().add(const Duration(days: 60)),
      isAvailable: true,
      maxRedemptions: 20,
      currentRedemptions: 8,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Programme de Fidélité'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Aperçu'),
            Tab(text: 'Récompenses'),
            Tab(text: 'Historique'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildRewardsTab(),
          _buildHistoryTab(),
        ],
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 1),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte de statut
          _buildStatusCard(),
          
          const SizedBox(height: 24),
          
          // Progression vers le niveau suivant
          _buildTierProgress(),
          
          const SizedBox(height: 24),
          
          // Statistiques
          _buildStatsGrid(),
          
          const SizedBox(height: 24),
          
          // Actions rapides
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.blueGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                    'Statut ${_loyaltyProgram.currentTier.displayName}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Membre depuis ${_formatMembershipDuration()}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Text(
                _loyaltyProgram.currentTier.icon,
                style: TextStyle(fontSize: 40),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusItem(
                'Points disponibles',
                _loyaltyProgram.availablePoints.toString(),
                Icons.stars,
              ),
              _buildStatusItem(
                'Cashback total',
                Formatters.formatCurrency(_loyaltyProgram.totalCashbackEarned),
                Icons.account_balance_wallet,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTierProgress() {
    final nextTier = _getNextTier();
    if (nextTier == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            Icon(Icons.emoji_events, color: AppColors.warning, size: 32),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Niveau maximum atteint !',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Vous avez atteint le niveau Platine',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final progress = (_loyaltyProgram.totalPoints - _loyaltyProgram.currentTier.requiredPoints) / 
                    (nextTier.requiredPoints - _loyaltyProgram.currentTier.requiredPoints);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Text(
                'Progression vers ${nextTier.displayName}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                nextTier.icon,
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Plus que ${_loyaltyProgram.pointsToNextTier} points pour passer au niveau supérieur',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Points totaux',
          _loyaltyProgram.totalPoints.toString(),
          Icons.stars,
          AppColors.warning,
        ),
        _buildStatCard(
          'Points utilisés',
          _loyaltyProgram.usedPoints.toString(),
          Icons.redeem,
          AppColors.info,
        ),
        _buildStatCard(
          'Récompenses',
          _availableRewards.length.toString(),
          Icons.card_giftcard,
          AppColors.success,
        ),
        _buildStatCard(
          'Niveau',
          _loyaltyProgram.currentTier.displayName,
          Icons.military_tech,
          AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Gagner des points',
                Icons.shopping_cart,
                AppColors.primary,
                () => context.push('/marketplace'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Inviter un ami',
                Icons.person_add,
                AppColors.success,
                _showInviteDialog,
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
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _availableRewards.length,
      itemBuilder: (context, index) {
        final reward = _availableRewards[index];
        return _buildRewardCard(reward);
      },
    );
  }

  Widget _buildRewardCard(Reward reward) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  reward.type.icon,
                  style: TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      reward.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.stars, color: AppColors.warning, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${reward.pointsCost} points',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: reward.canRedeem && _loyaltyProgram.availablePoints >= reward.pointsCost
                    ? () => _redeemReward(reward)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Échanger',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Aucun historique',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            'Vos transactions de points apparaîtront ici',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  LoyaltyTier? _getNextTier() {
    final tiers = LoyaltyTier.values;
    final currentIndex = tiers.indexOf(_loyaltyProgram.currentTier);
    return currentIndex < tiers.length - 1 ? tiers[currentIndex + 1] : null;
  }

  String _formatMembershipDuration() {
    final duration = DateTime.now().difference(_loyaltyProgram.joinDate);
    if (duration.inDays < 30) {
      return '${duration.inDays} jours';
    } else if (duration.inDays < 365) {
      return '${(duration.inDays / 30).floor()} mois';
    } else {
      return '${(duration.inDays / 365).floor()} ans';
    }
  }

  void _redeemReward(Reward reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Échanger ${reward.title}'),
        content: Text(
          'Voulez-vous échanger ${reward.pointsCost} points contre cette récompense ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showRedemptionSuccess(reward);
            },
            child: Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _showRedemptionSuccess(Reward reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🎉 Récompense échangée !'),
        content: Text('Votre récompense "${reward.title}" a été ajoutée à votre compte.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Super !'),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Inviter un ami'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Partagez votre code de parrainage et gagnez 500 points pour chaque ami qui s\'inscrit !'),
            SizedBox(height: 16),
            SelectableText(
              'JUFA2024ABC',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
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
              // Logique de partage
            },
            child: Text('Partager'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
