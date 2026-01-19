import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/verify_otp_screen.dart';
import '../features/auth/domain/entities/user_entity.dart';
import '../features/wallet/presentation/screens/home_screen.dart';
import '../features/wallet/presentation/screens/wallet_screen.dart';
import '../features/transaction/presentation/screens/transfer_screen.dart';
import '../features/transaction/presentation/screens/transaction_history_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/kyc/presentation/screens/kyc_screen.dart';
import '../features/merchant/presentation/screens/merchant_dashboard_screen.dart';
import '../features/merchant/presentation/screens/merchant_setup_screen.dart';
import '../features/merchant/presentation/screens/relations_screen.dart';
import '../features/qrpayment/presentation/screens/generate_qr_screen.dart';
import '../features/qrpayment/presentation/screens/scan_qr_screen.dart';
import '../features/qrpayment/presentation/screens/qr_payment_confirm_screen.dart';
import '../features/qrpayment/domain/entities/qr_payment_entity.dart';
import '../features/notification/presentation/screens/notifications_screen.dart';
import '../features/mobilemoney/presentation/screens/deposit_screen.dart';
import '../features/mobilemoney/presentation/screens/withdrawal_screen.dart';
import '../features/mobilemoney/presentation/screens/mobile_money_history_screen.dart';
import '../features/b2b/presentation/screens/catalog_screen.dart';
import '../features/b2b/presentation/screens/product_detail_screen.dart';
import '../features/b2b/presentation/screens/cart_screen.dart';
import '../features/b2b/presentation/screens/order_list_screen.dart';
import '../features/b2b/presentation/screens/wholesaler_dashboard_screen.dart';
import '../features/b2b/presentation/screens/wholesaler_home_screen.dart';
import '../features/b2b/presentation/screens/retailer_home_screen.dart';
import '../features/b2b/presentation/screens/retailer_stock_screen.dart';
import '../features/b2b/presentation/screens/product_management_screen.dart';
import '../features/b2b/presentation/screens/product_form_screen.dart';
import '../features/b2b/presentation/screens/stock_management_screen.dart';
import '../features/b2b/presentation/screens/wholesaler_orders_screen.dart';
import '../features/b2b/presentation/screens/retailer_dashboard_screen.dart';
import '../features/agent/presentation/screens/agent_dashboard_screen.dart';
import '../features/agent/presentation/screens/cash_in_screen.dart';
import '../features/agent/presentation/screens/cash_out_screen.dart';
import '../features/agent/presentation/screens/agent_transactions_screen.dart';
import '../features/airtime/presentation/screens/airtime_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../core/constants/app_theme.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = ref.read(isLoggedInProvider).valueOrNull ?? false;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/verify-otp';
      
      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) => const VerifyOtpScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) => const NoTransitionPage(child: TransactionHistoryScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
          ),
          GoRoute(
            path: '/wallet',
            pageBuilder: (context, state) => const NoTransitionPage(child: WalletScreen()),
          ),
          GoRoute(
            path: '/retailer-home',
            pageBuilder: (context, state) => const NoTransitionPage(child: RetailerHomeScreen()),
          ),
          GoRoute(
            path: '/retailer-orders',
            pageBuilder: (context, state) => const NoTransitionPage(child: OrderListScreen()),
          ),
          GoRoute(
            path: '/retailer-stock',
            pageBuilder: (context, state) => const NoTransitionPage(child: RetailerStockScreen()),
          ),
          GoRoute(
            path: '/wholesaler-home',
            pageBuilder: (context, state) => const NoTransitionPage(child: WholesalerHomeScreen()),
          ),
          GoRoute(
            path: '/wholesaler-products',
            pageBuilder: (context, state) => const NoTransitionPage(child: ProductManagementScreen()),
          ),
          GoRoute(
            path: '/wholesaler-stock',
            pageBuilder: (context, state) => const NoTransitionPage(child: StockManagementScreen()),
          ),
          GoRoute(
            path: '/wholesaler-clients',
            pageBuilder: (context, state) => const NoTransitionPage(child: RelationsScreen()),
          ),
          GoRoute(
            path: '/agent-home',
            pageBuilder: (context, state) => const NoTransitionPage(child: AgentDashboardScreen()),
          ),
          GoRoute(
            path: '/agent/transactions',
            pageBuilder: (context, state) => const NoTransitionPage(child: AgentTransactionsScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/transfer',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TransferScreen(),
      ),
      GoRoute(
        path: '/kyc',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const KycScreen(),
      ),
      GoRoute(
        path: '/merchant',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MerchantDashboardScreen(),
      ),
      GoRoute(
        path: '/merchant/setup',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MerchantSetupScreen(),
      ),
      GoRoute(
        path: '/merchant/relations',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RelationsScreen(),
      ),
      GoRoute(
        path: '/qr/generate',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const GenerateQrScreen(),
      ),
      GoRoute(
        path: '/qr/scan',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ScanQrScreen(),
      ),
      GoRoute(
        path: '/qr/confirm',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final qrCode = state.extra as QrCodeEntity;
          return QrPaymentConfirmScreen(qrCode: qrCode);
        },
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/deposit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DepositScreen(),
      ),
      GoRoute(
        path: '/withdrawal',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WithdrawalScreen(),
      ),
      GoRoute(
        path: '/momo-history',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MobileMoneyHistoryScreen(),
      ),
      GoRoute(
        path: '/b2b/catalog/:wholesalerId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final wholesalerId = state.pathParameters['wholesalerId']!;
          final wholesalerName = state.uri.queryParameters['name'] ?? 'Catalogue';
          return CatalogScreen(
            wholesalerId: wholesalerId,
            wholesalerName: wholesalerName,
          );
        },
      ),
      GoRoute(
        path: '/b2b/product/new',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProductFormScreen(),
      ),
      GoRoute(
        path: '/b2b/product/edit/:productId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return ProductFormScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/b2b/product/:productId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/b2b/cart',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/b2b/orders',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OrderListScreen(),
      ),
      GoRoute(
        path: '/b2b/wholesaler',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WholesalerDashboardScreen(),
      ),
      GoRoute(
        path: '/b2b/products',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProductManagementScreen(),
      ),
      GoRoute(
        path: '/b2b/stock',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const StockManagementScreen(),
      ),
      GoRoute(
        path: '/b2b/wholesaler-orders',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WholesalerOrdersScreen(),
      ),
      GoRoute(
        path: '/b2b/retailer',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RetailerDashboardScreen(),
      ),
      GoRoute(
        path: '/agent/dashboard',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AgentDashboardScreen(),
      ),
      GoRoute(
        path: '/agent/cash-in',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CashInScreen(),
      ),
      GoRoute(
        path: '/agent/cash-out',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CashOutScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/airtime',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AirtimeScreen(),
      ),
      GoRoute(
        path: '/order-card',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const _OrderCardScreen(),
      ),
    ],
  );
});

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    return _buildScaffold(context, currentUser?.userType);
  }

  Widget _buildScaffold(BuildContext context, UserType? userType) {
    final navItems = _getNavItems(context, userType);
    
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: navItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _NavItem(
                  icon: item['icon'] as IconData,
                  label: item['label'] as String,
                  isSelected: _currentIndex == index,
                  onTap: () {
                    if (item['action'] != null) {
                      (item['action'] as VoidCallback)();
                    } else {
                      setState(() => _currentIndex = index);
                      context.go(item['route'] as String);
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getNavItems(BuildContext context, UserType? userType) {
    switch (userType) {
      case UserType.retailer:
        return [
          {'icon': Icons.storefront, 'label': 'Catalogue', 'route': '/retailer-home'},
          {'icon': Icons.shopping_cart_outlined, 'label': 'Panier', 'route': '/b2b/cart', 'action': () => context.push('/b2b/cart')},
          {'icon': Icons.receipt_long_outlined, 'label': 'Commandes', 'route': '/retailer-orders'},
          {'icon': Icons.inventory_2_outlined, 'label': 'Stock', 'route': '/retailer-stock'},
          {'icon': Icons.person_outline, 'label': 'Profil', 'route': '/profile'},
        ];
      case UserType.wholesaler:
        return [
          {'icon': Icons.dashboard_outlined, 'label': 'Accueil', 'route': '/wholesaler-home'},
          {'icon': Icons.receipt_long_outlined, 'label': 'Commandes', 'route': '/b2b/wholesaler-orders', 'action': () => context.push('/b2b/wholesaler-orders')},
          {'icon': Icons.inventory_outlined, 'label': 'Produits', 'route': '/wholesaler-products'},
          {'icon': Icons.warehouse_outlined, 'label': 'Stock', 'route': '/wholesaler-stock'},
          {'icon': Icons.person_outline, 'label': 'Profil', 'route': '/profile'},
        ];
      case UserType.agent:
        return [
          {'icon': Icons.dashboard_outlined, 'label': 'Accueil', 'route': '/agent-home'},
          {'icon': Icons.arrow_downward, 'label': 'Cash-In', 'route': '/agent/cash-in', 'action': () => context.push('/agent/cash-in')},
          {'icon': Icons.arrow_upward, 'label': 'Cash-Out', 'route': '/agent/cash-out', 'action': () => context.push('/agent/cash-out')},
          {'icon': Icons.history, 'label': 'Historique', 'route': '/agent/transactions'},
          {'icon': Icons.person_outline, 'label': 'Profil', 'route': '/profile'},
        ];
      case UserType.individual:
      default:
        return [
          {'icon': Icons.home_outlined, 'label': 'Accueil', 'route': '/home'},
          {'icon': Icons.history, 'label': 'Historique', 'route': '/history'},
          {'icon': Icons.qr_code, 'label': 'QR', 'action': () => _showQrMenu(context)},
          {'icon': Icons.account_balance_wallet_outlined, 'label': 'Wallet', 'route': '/wallet'},
          {'icon': Icons.person_outline, 'label': 'Profil', 'route': '/profile'},
        ];
    }
  }

  void _showQrMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('QR Code', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.qr_code_2, color: AppColors.primary),
                ),
                title: const Text('Générer un QR Code'),
                subtitle: const Text('Recevoir un paiement'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/qr/generate');
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.qr_code_scanner, color: AppColors.success),
                ),
                title: const Text('Scanner un QR Code'),
                subtitle: const Text('Effectuer un paiement'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/qr/scan');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCardScreen extends StatelessWidget {
  const _OrderCardScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Commander JUFA Card', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 280,
                height: 180,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.walletGradientStart, AppColors.walletGradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
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
                          Text('JUFA', style: AppTextStyles.h2.copyWith(color: Colors.white)),
                          const Icon(Icons.contactless, color: Colors.white, size: 32),
                        ],
                      ),
                      const Text('•••• •••• •••• ••••', style: TextStyle(color: Colors.white70, fontSize: 18, letterSpacing: 4)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('VOTRE NOM', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const Text('XX/XX', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text('JUFA Card', style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text(
                'Payez partout dans le monde avec votre carte JUFA',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité bientôt disponible')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Commander maintenant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
