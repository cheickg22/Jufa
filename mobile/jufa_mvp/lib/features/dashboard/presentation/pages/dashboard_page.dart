import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/services/wallet_service.dart';
import '../../../../core/services/transaction_service.dart';
import '../../../../core/services/profile_service.dart';
import '../../../../core/services/api_notification_service.dart';
import '../../../../core/security/biometric_service.dart';
import '../../../../core/security/biometric_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../navigation/presentation/widgets/bottom_navigation_widget.dart';
import 'search_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _balanceVisible = false; // Masqué par défaut
  bool _isAuthenticating = false;
  final WalletService _walletService = WalletService();
  final TransactionService _transactionService = TransactionService();
  final ProfileService _profileService = ProfileService();
  final ApiNotificationService _notificationService = ApiNotificationService();
  final BiometricService _biometricService = BiometricService(LocalAuthentication());
  
  // Données utilisateur dynamiques
  double _balance = 250000.0;
  String _userName = 'Utilisateur';
  String _userInitials = 'U';
  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();
  
  // Montants des transactions du jour
  double _sentToday = 0.0;
  double _receivedToday = 0.0;
  
  // Nombre de notifications non lues
  int _unreadNotificationsCount = 0;
  
  // Carrousel de publicités
  int _currentAdIndex = 0;
  Timer? _adTimer;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUnreadNotificationsCount();
    _startAdCarousel();
  }
  
  Future<void> _loadUnreadNotificationsCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      if (mounted) {
        setState(() {
          _unreadNotificationsCount = count;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement du compteur de notifications: $e');
    }
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

  Future<void> _loadUserData() async {
    try {
      // Charger les données utilisateur locales
      final userName = await UserService.getFullName();
      final userInitials = await UserService.getInitials();
      
      // Charger le solde depuis l'API
      final walletService = WalletService();
      final balance = await walletService.getBalance();
      
      print('💰 Solde chargé depuis API: $balance XOF');
      
      // Charger les transactions pour calculer envoyé/reçu du jour
      final transactionService = TransactionService();
      final transactions = await transactionService.getTransactions();
      
      // Récupérer l'ID de l'utilisateur connecté
      final userIdStr = await UserService.getUserId();
      final userId = userIdStr != null ? int.tryParse(userIdStr) : null;
      
      // Calculer les montants du jour
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      double sentToday = 0.0;
      double receivedToday = 0.0;
      
      for (var transaction in transactions) {
        final transactionDate = DateTime.parse(transaction['created_at']);
        final transactionDay = DateTime(transactionDate.year, transactionDate.month, transactionDate.day);
        
        if (transactionDay.isAtSameMomentAs(today)) {
          final amount = double.parse(transaction['amount'].toString());
          final type = transaction['type'];
          final senderId = transaction['sender_id'];
          final receiverId = transaction['receiver_id'];
          
          // Vérifier si on est sender ou receiver
          if (type == 'deposit') {
            receivedToday += amount;
          } else if (type == 'withdrawal' || type == 'payment') {
            sentToday += amount;
          } else if (type == 'transfer') {
            // Pour les transferts, vérifier qui est qui
            if (userId != null && senderId == userId) {
              sentToday += amount;
            } else if (userId != null && receiverId == userId) {
              receivedToday += amount;
            }
          }
        }
      }
      
      print('📊 Envoyé aujourd\'hui: $sentToday XOF');
      print('📊 Reçu aujourd\'hui: $receivedToday XOF');
      
      if (mounted) {
        setState(() {
          _userName = userName;
          _userInitials = userInitials;
          _balance = balance;
          _sentToday = sentToday;
          _receivedToday = receivedToday;
        });
      }
    } catch (e) {
      // En cas d'erreur, garder les valeurs par défaut
      print('❌ Erreur lors du chargement des données utilisateur: $e');
      
      // Fallback: charger le solde local
      try {
        final localBalance = await UserService.getBalance();
        if (mounted) {
          setState(() {
            _balance = localBalance;
          });
        }
      } catch (e2) {
        print('❌ Erreur lors du chargement du solde local: $e2');
      }
    }
  }
  
  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null && mounted) {
        setState(() {
          _profileImage = File(image.path);
        });
        // TODO: Sauvegarder l'image dans le stockage local ou cloud
      }
    } catch (e) {
      print('Erreur lors de la sélection de l\'image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible de sélectionner l\'image'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            
            // Balance Card
            SliverToBoxAdapter(
              child: _buildBalanceCard(),
            ),
            
            // Transactions d'aujourd'hui
            SliverToBoxAdapter(
              child: _buildTodayTransactions(),
            ),
            
            // JUFA Card
            SliverToBoxAdapter(
              child: _buildJufaCard(),
            ),
            
            // Services Section
            SliverToBoxAdapter(
              child: _buildServicesSection(),
            ),
            
            // Publicités
            SliverToBoxAdapter(
              child: _buildAdvertisements(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 0),
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          // Gauche: Profil + Message
          IconButton(
            icon: Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.message_outlined),
                onPressed: () {
                  context.push('/notifications');
                },
              ),
              if (_unreadNotificationsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _unreadNotificationsCount > 99 ? '99+' : '$_unreadNotificationsCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          
          // Centre: Logo JUFA
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
          
          // Droite: Recherche + Alerte
          IconButton(
            icon: Icon(Icons.search_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined),
                onPressed: null, // Désactivé - non cliquable
              ),
              if (_unreadNotificationsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _unreadNotificationsCount > 99 ? '99+' : '$_unreadNotificationsCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
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
  
  Widget _buildTodayTransactions() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('today_transactions'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Carte Envoyé
              Container(
                width: 160,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.shade100,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_upward,
                        color: Colors.red.shade700,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.translate('sent'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.formatCurrency(_sentToday),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Carte Reçu
              Container(
                width: 160,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.shade100,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_downward,
                        color: Colors.green.shade700,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.translate('received'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.formatCurrency(_receivedToday),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
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
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Design de carte Visa
            Container(
              width: 140,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo Mastercard et JUFA Card
                    Row(
                      children: [
                        SizedBox(
                          width: 35,
                          height: 20,
                          child: Stack(
                            children: [
                              // Cercle bleu
                              Positioned(
                                left: 0,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade700,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              // Cercle blanc qui chevauche
                              Positioned(
                                left: 15,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.translate('jufa_card'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Numéro de carte stylisé sur une seule ligne
                    Row(
                      children: [
                        _buildCardDot(),
                        _buildCardDot(),
                        _buildCardDot(),
                        _buildCardDot(),
                        const SizedBox(width: 3),
                        _buildCardDot(),
                        _buildCardDot(),
                        _buildCardDot(),
                        _buildCardDot(),
                        const SizedBox(width: 3),
                        _buildCardDot(),
                        _buildCardDot(),
                        _buildCardDot(),
                        _buildCardDot(),
                        const SizedBox(width: 3),
                        Text(
                          '1234',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Texte "Commandez maintenant"
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => context.push('/order-card'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l10n.translate('order_now'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDot() {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.only(right: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Carte principale
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
          decoration: BoxDecoration(
            gradient: AppColors.blueGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Nom de l'utilisateur au centre
              Text(
                _userName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Montant du solde avec CFA et icône œil
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _balanceVisible
                        ? '${Formatters.formatCurrency(_balance).replaceAll('FCFA', '').trim()} CFA'
                        : '•••••• CFA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      _balanceVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _balanceVisible ? _hideBalance : _authenticateToShowBalance,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Avatar superposé en haut
        Positioned(
          top: -20,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _pickProfileImage,
              child: Stack(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? Text(
                                _userInitials,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  // Icône de caméra
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickActionButton(
            icon: Icons.arrow_upward,
            label: 'Envoyer',
            color: AppColors.transfer,
            onTap: () => context.push('/transfer'),
          ),
          _buildQuickActionButton(
            icon: Icons.add,
            label: 'Recharger',
            color: AppColors.accent,
            onTap: () => context.push('/recharge'),
          ),
          _buildQuickActionButton(
            icon: Icons.qr_code_scanner,
            label: 'Scanner',
            color: AppColors.info,
            onTap: () => context.push('/scanner'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildServicesSection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            l10n.translate('services'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Première ligne - 3 cartes
              Row(
                children: [
                  Expanded(
                    child: _buildServiceCard(
                      icon: Icons.send,
                      title: l10n.translate('transfer'),
                      color: AppColors.transfer,
                      onTap: () => context.push('/transfer'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildServiceCard(
                      icon: Icons.phone_android,
                      title: l10n.translate('airtime'),
                      color: AppColors.airtime,
                      onTap: () => context.push('/airtime'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildServiceCard(
                      icon: Icons.diamond,
                      title: l10n.translate('nege'),
                      color: AppColors.nege,
                      onTap: () => context.push('/nege'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Deuxième ligne - 3 cartes
              Row(
                children: [
                  Expanded(
                    child: _buildServiceCard(
                      icon: Icons.account_balance,
                      title: l10n.translate('pispi'),
                      color: AppColors.secondary,
                      onTap: () => context.push('/pispi'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildServiceCard(
                      icon: Icons.receipt_long,
                      title: l10n.translate('bills'),
                      color: AppColors.payment,
                      onTap: () => context.push('/bills'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildServiceCard(
                      icon: Icons.swap_horiz,
                      title: l10n.translate('history'),
                      color: AppColors.info,
                      onTap: () => context.push('/history'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
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
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentAdIndex = index;
                });
              },
              children: [
                _buildAdCard(
                  title: l10n.translate('jufa_card_ad_title'),
                  subtitle: l10n.translate('jufa_card_ad_subtitle'),
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade400],
                  ),
                  icon: Icons.credit_card,
                  onTap: () => context.push('/jufa'),
                ),
                _buildAdCard(
                  title: l10n.translate('invest_ad_title'),
                  subtitle: l10n.translate('invest_ad_subtitle'),
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade700, Colors.amber.shade400],
                  ),
                  icon: Icons.diamond,
                  onTap: () => context.push('/nege'),
                ),
                _buildAdCard(
                  title: l10n.translate('marketplace_ad_title'),
                  subtitle: l10n.translate('marketplace_ad_subtitle'),
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade700, Colors.purple.shade400],
                  ),
                  icon: Icons.store,
                  onTap: () => context.push('/marketplace'),
                ),
                _buildFootballAdCard(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Indicateurs de page
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentAdIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentAdIndex == index
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFootballAdCard() {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () {
        // TODO: Naviguer vers football
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade700, Colors.green.shade400],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
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
                    l10n.translate('football_ad_title'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.translate('football_ad_subtitle'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.translate('discover'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Ballons de football empilés
            SizedBox(
              width: 68,
              height: 68,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(
                      Icons.sports_soccer,
                      size: 32,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Icon(
                      Icons.sports_soccer,
                      size: 32,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.sports_soccer,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.translate('discover'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
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
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 36,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTransactionItem({
    required String title,
    required String subtitle,
    required double amount,
    required DateTime date,
    required IconData icon,
    required Color iconColor,
  }) {
    final isPositive = amount > 0;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isPositive ? '+' : ''}${Formatters.formatCurrency(amount.abs())}',
            style: TextStyle(
              color: isPositive ? AppColors.success : AppColors.expense,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            Formatters.formatRelativeDate(date),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // Masquer le solde
  void _hideBalance() {
    setState(() {
      _balanceVisible = false;
    });
  }

  // Authentifier pour afficher le solde
  Future<void> _authenticateToShowBalance() async {
    if (_isAuthenticating) return;

    setState(() => _isAuthenticating = true);

    try {
      // Vérifier si la biométrie est activée
      final isBiometricEnabled = await BiometricPreferences.isBiometricEnabled();
      
      if (isBiometricEnabled) {
        // Essayer l'authentification biométrique
        try {
          final success = await _biometricService.authenticate(
            localizedReason: 'Authentifiez-vous pour voir votre solde',
          );
          
          if (success) {
            setState(() => _balanceVisible = true);
          }
        } on BiometricException catch (e) {
          // Si la biométrie échoue, proposer le code PIN
          _showPinDialog();
        }
      } else {
        // Pas de biométrie configurée, utiliser le code PIN
        _showPinDialog();
      }
    } catch (e) {
      // En cas d'erreur, utiliser le code PIN
      _showPinDialog();
    } finally {
      setState(() => _isAuthenticating = false);
    }
  }

  // Afficher le dialog de saisie du code PIN
  void _showPinDialog() {
    final pinController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Code de sécurité'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Entrez votre code PIN pour voir votre solde'),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'Code PIN',
                hintText: '••••',
                border: OutlineInputBorder(),
                counterText: '',
              ),
              onChanged: (value) {
                if (value.length == 4) {
                  // Auto-validation quand 4 chiffres sont saisis
                  _validatePin(value, context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              _validatePin(pinController.text, context);
            },
            child: Text('Valider'),
          ),
        ],
      ),
    );
  }

  // Valider le code PIN
  void _validatePin(String pin, BuildContext dialogContext) async {
    try {
      // Vérifier le PIN via l'API
      final isValid = await _profileService.verifyPin(pin);
      
      if (isValid) {
        Navigator.of(dialogContext).pop();
        setState(() {
          _balanceVisible = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentification réussie'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Code PIN incorrect'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      // Si l'erreur indique qu'aucun PIN n'est configuré
      if (e.toString().contains('configurer un code PIN') || 
          e.toString().contains('PIN_NOT_CONFIGURED')) {
        Navigator.of(dialogContext).pop();
        
        // Afficher un dialog pour rediriger vers la configuration du PIN
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Code PIN requis'),
            content: Text('Vous devez d\'abord configurer un code PIN pour consulter votre solde.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/profile');
                },
                child: Text('Configurer'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

}
