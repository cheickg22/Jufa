import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/language_selection_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/jufa/presentation/pages/jufa_page.dart';
import '../../features/jufa/presentation/pages/order_card_page.dart';
import '../../features/marketplace/presentation/pages/marketplace_page.dart';
import '../../features/transfer/presentation/pages/transfer_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/payment/presentation/pages/recharge_page.dart';
import '../../features/payment/presentation/pages/bills_page.dart';
import '../../features/airtime/presentation/pages/airtime_page.dart';
import '../../features/nege/presentation/pages/nege_page.dart';
import '../../features/pispi/presentation/pages/pispi_page.dart';
import '../../features/scanner/presentation/pages/scanner_page.dart';
import '../../features/ai/presentation/pages/ai_assistant_page.dart';
import '../../features/legal/presentation/pages/legal_document_page.dart';
import '../../features/marketplace/presentation/pages/category_products_page.dart';
import '../../features/marketplace/presentation/pages/product_details_page.dart';
import '../../features/marketplace/presentation/pages/my_orders_page.dart';
import '../services/auth_service.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final languageSelected = prefs.getBool('language_selected') ?? false;
      final token = await AuthService.getToken();
      final isAuthenticated = token != null && token.isNotEmpty;
      
      final path = state.matchedLocation;
      
      // Pages publiques qui ne nécessitent pas de redirection
      final publicPages = ['/language-selection', '/onboarding', '/login', '/register', '/forgot-password'];
      
      // Si authentifié et sur une page d'auth, rediriger vers dashboard
      if (isAuthenticated && publicPages.contains(path)) {
        return '/dashboard';
      }
      
      // Si non authentifié
      if (!isAuthenticated) {
        // Si la langue n'a pas été sélectionnée, aller à la sélection de langue
        if (!languageSelected && path != '/language-selection') {
          return '/language-selection';
        }
        
        // Si la langue est sélectionnée mais pas sur une page publique, aller à l'onboarding
        if (languageSelected && !publicPages.contains(path)) {
          return '/onboarding';
        }
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/language-selection',
      ),
      GoRoute(
        path: '/language-selection',
        builder: (context, state) => const LanguageSelectionPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/jufa',
        builder: (context, state) => const JufaPage(),
      ),
      GoRoute(
        path: '/order-card',
        builder: (context, state) => const OrderCardPage(),
      ),
      GoRoute(
        path: '/marketplace',
        builder: (context, state) => const MarketplacePage(),
      ),
      GoRoute(
        path: '/marketplace/category/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final name = state.uri.queryParameters['name'] ?? 'Catégorie';
          return CategoryProductsPage(categoryId: id, categoryName: name);
        },
      ),
      GoRoute(
        path: '/marketplace/product/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ProductDetailsPage(productId: id);
        },
      ),
      GoRoute(
        path: '/marketplace/orders',
        builder: (context, state) => const MyOrdersPage(),
      ),
      GoRoute(
        path: '/transfer',
        builder: (context, state) => const TransferPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: '/recharge',
        builder: (context, state) => const RechargePage(),
      ),
      GoRoute(
        path: '/bills',
        builder: (context, state) => const BillsPage(),
      ),
      GoRoute(
        path: '/airtime',
        builder: (context, state) => const AirtimePage(),
      ),
      GoRoute(
        path: '/nege',
        builder: (context, state) => const NegePage(),
      ),
      GoRoute(
        path: '/pispi',
        builder: (context, state) => const PiSpiPage(),
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const ScannerPage(),
      ),
      GoRoute(
        path: '/ai-assistant',
        builder: (context, state) => const AIAssistantPage(),
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const LegalDocumentPage(
          type: 'privacy_policy',
          title: 'Politique de confidentialité',
        ),
      ),
      GoRoute(
        path: '/terms-of-service',
        builder: (context, state) => const LegalDocumentPage(
          type: 'terms_of_service',
          title: 'Conditions d\'utilisation',
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page non trouvée',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.matchedLocation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Retour au tableau de bord'),
            ),
          ],
        ),
      ),
    ),
  );
}
