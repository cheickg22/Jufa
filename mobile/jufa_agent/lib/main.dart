import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/agent_colors.dart';
import 'features/agent/auth/presentation/pages/agent_login_page.dart';
import 'features/agent/auth/presentation/pages/agent_register_page.dart';
import 'features/agent/dashboard/presentation/pages/agent_dashboard_page.dart';
import 'features/agent/deposit/presentation/pages/agent_deposit_page.dart';
import 'features/agent/withdrawal/presentation/pages/agent_withdrawal_page.dart';
import 'features/agent/profile/presentation/pages/agent_profile_page.dart';
import 'features/agent/transactions/presentation/pages/agent_transactions_page.dart';

void main() {
  runApp(const JufaAgentApp());
}

class JufaAgentApp extends StatelessWidget {
  const JufaAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'JUFA Agent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AgentColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AgentColors.primary,
          primary: AgentColors.primary,
          secondary: AgentColors.secondary,
        ),
        scaffoldBackgroundColor: AgentColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AgentColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AgentColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/agent/login',
  routes: [
    GoRoute(
      path: '/agent/login',
      builder: (context, state) => const AgentLoginPage(),
    ),
    GoRoute(
      path: '/agent/register',
      builder: (context, state) => const AgentRegisterPage(),
    ),
    GoRoute(
      path: '/agent/dashboard',
      builder: (context, state) => const AgentDashboardPage(),
    ),
    GoRoute(
      path: '/agent/deposit',
      builder: (context, state) => const AgentDepositPage(),
    ),
    GoRoute(
      path: '/agent/withdrawal',
      builder: (context, state) => const AgentWithdrawalPage(),
    ),
    GoRoute(
      path: '/agent/profile',
      builder: (context, state) => const AgentProfilePage(),
    ),
    GoRoute(
      path: '/agent/transactions',
      builder: (context, state) => const AgentTransactionsPage(),
    ),
  ],
);
