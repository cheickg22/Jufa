import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../../notification/presentation/providers/notification_provider.dart';
import '../providers/wallet_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _balanceVisible = false;
  int _currentAdIndex = 0;
  Timer? _adTimer;
  final PageController _pageController = PageController();
  final currencyFormat = NumberFormat('#,###', 'fr_FR');

  @override
  void initState() {
    super.initState();
    _startAdCarousel();
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAdCarousel() {
    _adTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _pageController.hasClients) {
        setState(() {
          _currentAdIndex = (_currentAdIndex + 1) % 4;
        });
        _pageController.animateToPage(
          _currentAdIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  String _formatCurrency(double amount) {
    return '${currencyFormat.format(amount)} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final walletAsync = ref.watch(primaryWalletProvider);
    final transactionsAsync = ref.watch(transactionHistoryProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(walletsProvider);
            ref.invalidate(transactionHistoryProvider);
            ref.invalidate(unreadCountProvider);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(user?.phone ?? 'Utilisateur', unreadCount)),
              SliverToBoxAdapter(child: _buildBalanceCard(walletAsync, user?.phone ?? 'U')),
              SliverToBoxAdapter(child: _buildTodayTransactions(transactionsAsync)),
              SliverToBoxAdapter(child: _buildJufaCard()),
              SliverToBoxAdapter(child: _buildServicesSection()),
              SliverToBoxAdapter(child: _buildAdvertisements()),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name, AsyncValue<int> unreadCount) {
    final count = unreadCount.valueOrNull ?? 0;
    
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.message_outlined),
                onPressed: () => context.push('/notifications'),
              ),
              if (count > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Center(
              child: Text(
                'JUFA',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () {},
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/notifications'),
              ),
              if (count > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(AsyncValue walletAsync, String userName) {
    final initials = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.walletGradientStart, AppColors.walletGradientEnd],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                userName,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  walletAsync.when(
                    data: (wallet) => Text(
                      _balanceVisible
                          ? '${currencyFormat.format(wallet?.balance ?? 0)} CFA'
                          : '•••••• CFA',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    loading: () => const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                    error: (_, __) => const Text(
                      '-- CFA',
                      style: TextStyle(color: Colors.white70, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      _balanceVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => _authenticateToShowBalance(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: -20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayTransactions(AsyncValue<List> transactionsAsync) {
    double sentToday = 0;
    double receivedToday = 0;

    transactionsAsync.whenData((transactions) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (var tx in transactions) {
        if (tx.createdAt.isAfter(today)) {
          if (tx.senderPhone == null) {
            sentToday += tx.amount;
          } else {
            receivedToday += tx.amount;
          }
        }
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Transactions d'aujourd'hui",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 160,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade100, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_upward, color: Colors.red.shade700, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Envoyé',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.red.shade700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatCurrency(sentToday),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 160,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade100, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_downward, color: Colors.green.shade700, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Reçu',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.green.shade700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatCurrency(receivedToday),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJufaCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
        onTap: () => context.push('/order-card'),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 140,
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white.withValues(alpha: 0.3), Colors.white.withValues(alpha: 0.1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 35,
                            height: 20,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(color: Colors.blue.shade700, shape: BoxShape.circle),
                                  ),
                                ),
                                Positioned(
                                  left: 15,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'JUFA Card',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          for (int i = 0; i < 12; i++) ...[
                            _buildCardDot(),
                            if ((i + 1) % 4 == 0 && i < 11) const SizedBox(width: 3),
                          ],
                          const SizedBox(width: 3),
                          const Text(
                            '1234',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart, color: Colors.white, size: 28),
                    const SizedBox(width: 6),
                    const Flexible(
                      child: Text(
                        'Commandez maintenant',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, height: 1.3),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardDot() {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.only(right: 2),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text('Services', style: AppTextStyles.h3),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildServiceCard(icon: Icons.send, title: 'Transfert', color: AppColors.primary, onTap: () => context.push('/transfer'))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildServiceCard(icon: Icons.phone_android, title: 'Airtime', color: AppColors.secondary, onTap: () => context.push('/airtime'))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildServiceCard(icon: Icons.diamond, title: 'Nege', color: AppColors.warning, onTap: () {})),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildServiceCard(icon: Icons.account_balance, title: 'Pispi', color: AppColors.info, onTap: () {})),
                  const SizedBox(width: 8),
                  Expanded(child: _buildServiceCard(icon: Icons.receipt_long, title: 'Factures', color: Colors.purple, onTap: () {})),
                  const SizedBox(width: 8),
                  Expanded(child: _buildServiceCard(icon: Icons.history, title: 'Historique', color: AppColors.textSecondary, onTap: () => context.push('/history'))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard({required IconData icon, required String title, required Color color, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvertisements() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentAdIndex = index),
              children: [
                _buildAdCard(
                  title: 'JUFA Card',
                  subtitle: 'Payez partout dans le monde',
                  gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade400]),
                  icon: Icons.credit_card,
                  onTap: () => context.push('/order-card'),
                ),
                _buildAdCard(
                  title: 'Investir avec Nege',
                  subtitle: "L'or digital accessible à tous",
                  gradient: LinearGradient(colors: [Colors.amber.shade700, Colors.amber.shade400]),
                  icon: Icons.diamond,
                  onTap: () {},
                ),
                _buildAdCard(
                  title: 'Marketplace',
                  subtitle: 'Achetez et vendez facilement',
                  gradient: LinearGradient(colors: [Colors.purple.shade700, Colors.purple.shade400]),
                  icon: Icons.store,
                  onTap: () {},
                ),
                _buildAdCard(
                  title: 'Football',
                  subtitle: 'Pariez sur vos matchs favoris',
                  gradient: LinearGradient(colors: [Colors.green.shade700, Colors.green.shade400]),
                  icon: Icons.sports_soccer,
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentAdIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentAdIndex == index ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAdCard({
    required String title,
    required String subtitle,
    required Gradient gradient,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Découvrir',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(child: Icon(icon, size: 36, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _authenticateToShowBalance() async {
    if (_balanceVisible) {
      setState(() => _balanceVisible = false);
      return;
    }

    final pinController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Code de sécurité'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Entrez votre code PIN pour voir votre solde'),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Code PIN',
                hintText: '••••',
                border: OutlineInputBorder(),
                counterText: '',
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
            onPressed: () {
              if (pinController.text.length == 4) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      setState(() => _balanceVisible = true);
    }
  }
}
