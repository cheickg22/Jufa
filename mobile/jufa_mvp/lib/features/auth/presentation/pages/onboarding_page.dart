import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;
  bool _isAutoScrollEnabled = true;
  
  List<OnboardingItem> _getItems(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      OnboardingItem(
        title: l10n.translate('onboarding_title_1'),
        description: l10n.translate('onboarding_desc_1'),
        icon: Icons.account_balance_wallet,
      ),
      OnboardingItem(
        title: l10n.translate('onboarding_title_2'),
        description: l10n.translate('onboarding_desc_2'),
        icon: Icons.send_rounded,
      ),
      OnboardingItem(
        title: l10n.translate('onboarding_title_3'),
        description: l10n.translate('onboarding_desc_3'),
        icon: Icons.receipt_long,
      ),
      OnboardingItem(
        title: l10n.translate('onboarding_title_4'),
        description: l10n.translate('onboarding_desc_4'),
        icon: Icons.diamond_rounded,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    
    if (_isAutoScrollEnabled) {
      // Timer principal pour le défilement toutes les 3 secondes
      _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (mounted) {
          _nextPage();
        }
      });
    }
  }


  void _nextPage() {
    final itemsCount = 4; // Nombre fixe d'items
    if (_currentPage < itemsCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      // Revenir au début
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = _getItems(context);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(l10n.translate('skip')),
                ),
              ),
            ),
            
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(items[index]);
                },
              ),
            ),
            
            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                items.length,
                (index) => _buildIndicator(index == _currentPage),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Navigation buttons - Affichés sur toutes les pages
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/register'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: Text(l10n.translate('create_account')),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.go('/login'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: Text(l10n.translate('already_have_account_btn')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOnboardingPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            item.title,
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  
  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}
