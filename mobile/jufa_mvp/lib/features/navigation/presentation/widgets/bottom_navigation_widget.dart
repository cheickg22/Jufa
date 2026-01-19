import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';

class BottomNavigationWidget extends StatelessWidget {
  final int currentIndex;
  
  const BottomNavigationWidget({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: l10n.translate('nav_home'),
                index: 0,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.credit_card_outlined,
                activeIcon: Icons.credit_card,
                label: l10n.translate('nav_jufa_card'),
                index: 1,
              ),
              // Scanner - Plus visible et animé
              _buildScannerButton(context),
              _buildNavItem(
                context: context,
                icon: Icons.store_outlined,
                activeIcon: Icons.store,
                label: l10n.translate('nav_marketplace'),
                index: 3,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.smart_toy_outlined,
                activeIcon: Icons.smart_toy,
                label: l10n.translate('nav_chat'),
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;
    
    return InkWell(
      onTap: () => _onItemTapped(context, index),
      borderRadius: BorderRadius.circular(12),
      splashColor: AppColors.primary.withOpacity(0.2),
      highlightColor: AppColors.primary.withOpacity(0.1),
      hoverColor: AppColors.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerButton(BuildContext context) {
    final isActive = currentIndex == 2;
    
    return InkWell(
      onTap: () => _onItemTapped(context, 2),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.qr_code_scanner,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/jufa');
        break;
      case 2:
        context.go('/scanner');
        break;
      case 3:
        context.go('/marketplace');
        break;
      case 4:
        context.go('/ai-assistant');
        break;
    }
  }
}
