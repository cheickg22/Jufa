import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/transfer/presentation/pages/transfer_page.dart';
import '../../features/payment/presentation/pages/payment_page.dart';
import '../../features/payment/presentation/pages/bills_page.dart';
import '../../features/payment/presentation/pages/recharge_page.dart';
import '../../features/payment/presentation/pages/airtime_page.dart' as airtime;
import '../../features/nege/presentation/pages/nege_page.dart';
import '../../features/scanner/presentation/pages/scanner_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/more/presentation/pages/more_page.dart';
import '../../features/security/presentation/pages/biometric_setup_page.dart';
import '../../features/security/presentation/pages/biometric_login_page.dart';
import '../../features/marketplace/presentation/pages/marketplace_page.dart';
import '../../features/jufa/presentation/pages/jufa_page.dart';
import '../../features/jufa/presentation/pages/order_card_page.dart';
import '../../features/banking/presentation/pages/banking_services_page.dart';
import '../../features/investment/presentation/pages/investment_page.dart';
import '../../features/ai/presentation/pages/ai_assistant_page.dart';
import '../../features/international/presentation/pages/international_transfer_page.dart';
import '../../features/loyalty/presentation/pages/loyalty_page.dart';
import '../../features/pispi/presentation/pages/pispi_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash & Onboarding
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      
      // Main App Routes
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      
      // Profile Routes
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      
      // Notifications Routes
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      
      // Transfer Routes
      GoRoute(
        path: '/transfer',
        name: 'transfer',
        builder: (context, state) => const TransferPage(),
      ),
      
      // Payment Routes
      GoRoute(
        path: '/payment',
        name: 'payment',
        builder: (context, state) => const PaymentPage(),
      ),
      GoRoute(
        path: '/bills',
        name: 'bills',
        builder: (context, state) => const BillsPage(),
      ),
      GoRoute(
        path: '/recharge',
        name: 'recharge',
        builder: (context, state) => const RechargePage(),
      ),
      GoRoute(
        path: '/airtime',
        name: 'airtime',
        builder: (context, state) => const airtime.AirtimePage(),
      ),
      
      // Nege Routes
      GoRoute(
        path: '/nege',
        name: 'nege',
        builder: (context, state) => const NegePage(),
      ),
      
      // PI-SPI Routes
      GoRoute(
        path: '/pispi',
        name: 'pispi',
        builder: (context, state) => const PiSpiPage(),
      ),
      
      // Scanner Routes
      GoRoute(
        path: '/scanner',
        name: 'scanner',
        builder: (context, state) => const ScannerPage(),
      ),
      
      // History Routes
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryPage(),
      ),
      
      // More Routes
      GoRoute(
        path: '/more',
        name: 'more',
        builder: (context, state) => const MorePage(),
      ),
      
      // Marketplace Routes
      GoRoute(
        path: '/marketplace',
        name: 'marketplace',
        builder: (context, state) => const MarketplacePage(),
      ),
      
      // Jufa Routes
      GoRoute(
        path: '/jufa',
        name: 'jufa',
        builder: (context, state) => const JufaPage(),
      ),
      GoRoute(
        path: '/order-card',
        name: 'order-card',
        builder: (context, state) => const OrderCardPage(),
      ),
      
      // Banking Routes
      GoRoute(
        path: '/banking-services',
        name: 'banking-services',
        builder: (context, state) => const BankingServicesPage(),
      ),
      
      // Investment Routes
      GoRoute(
        path: '/investments',
        name: 'investments',
        builder: (context, state) => const InvestmentPage(),
      ),
      
      // AI Assistant Routes
      GoRoute(
        path: '/ai-assistant',
        name: 'ai-assistant',
        builder: (context, state) => const AIAssistantPage(),
      ),
      
      // International Transfer Routes
      GoRoute(
        path: '/international-transfer',
        name: 'international-transfer',
        builder: (context, state) => const InternationalTransferPage(),
      ),
      
      // Loyalty Program Routes
      GoRoute(
        path: '/loyalty',
        name: 'loyalty',
        builder: (context, state) => const LoyaltyPage(),
      ),
      
      // Security Routes
      GoRoute(
        path: '/biometric-setup',
        name: 'biometric-setup',
        builder: (context, state) => const BiometricSetupPage(),
      ),
      GoRoute(
        path: '/biometric-login',
        name: 'biometric-login',
        builder: (context, state) => const BiometricLoginPage(),
      ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
