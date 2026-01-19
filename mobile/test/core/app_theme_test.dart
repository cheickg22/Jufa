import 'package:flutter_test/flutter_test.dart';
import 'package:jufa_mobile/core/constants/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  group('AppColors', () {
    test('primary color is correct', () {
      expect(AppColors.primary, const Color(0xFF4F46E5));
    });

    test('secondary color is correct', () {
      expect(AppColors.secondary, const Color(0xFF10B981));
    });

    test('error color is correct', () {
      expect(AppColors.error, const Color(0xFFEF4444));
    });

    test('background color is correct', () {
      expect(AppColors.background, const Color(0xFFF9FAFB));
    });

    test('surface color is correct', () {
      expect(AppColors.surface, const Color(0xFFFFFFFF));
    });
  });

  group('AppColorsDark', () {
    test('background is dark', () {
      expect(AppColorsDark.background, const Color(0xFF0F172A));
    });

    test('surface is dark', () {
      expect(AppColorsDark.surface, const Color(0xFF1E293B));
    });

    test('text primary is light', () {
      expect(AppColorsDark.textPrimary, const Color(0xFFF1F5F9));
    });
  });

  group('AppTextStyles', () {
    test('font family is Poppins', () {
      expect(AppTextStyles.fontFamily, 'Poppins');
    });

    test('h1 has correct size', () {
      expect(AppTextStyles.h1.fontSize, 32);
    });

    test('h2 has correct size', () {
      expect(AppTextStyles.h2.fontSize, 24);
    });

    test('bodyLarge has correct size', () {
      expect(AppTextStyles.bodyLarge.fontSize, 16);
    });

    test('bodyMedium has correct size', () {
      expect(AppTextStyles.bodyMedium.fontSize, 14);
    });

    test('button has correct weight', () {
      expect(AppTextStyles.button.fontWeight, FontWeight.w600);
    });
  });

  group('AppSpacing', () {
    test('spacing values are correct', () {
      expect(AppSpacing.xs, 4);
      expect(AppSpacing.sm, 8);
      expect(AppSpacing.md, 16);
      expect(AppSpacing.lg, 24);
      expect(AppSpacing.xl, 32);
      expect(AppSpacing.xxl, 48);
    });
  });

  group('AppRadius', () {
    test('radius values are correct', () {
      expect(AppRadius.sm, 8);
      expect(AppRadius.md, 12);
      expect(AppRadius.lg, 16);
      expect(AppRadius.xl, 24);
      expect(AppRadius.full, 100);
    });
  });

  group('AppTheme', () {
    test('lightTheme has correct brightness', () {
      final theme = AppTheme.lightTheme;
      expect(theme.brightness, Brightness.light);
    });

    test('darkTheme has correct brightness', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
    });

    test('lightTheme uses Material 3', () {
      final theme = AppTheme.lightTheme;
      expect(theme.useMaterial3, isTrue);
    });

    test('darkTheme uses Material 3', () {
      final theme = AppTheme.darkTheme;
      expect(theme.useMaterial3, isTrue);
    });

    test('lightTheme has correct primary color', () {
      final theme = AppTheme.lightTheme;
      expect(theme.colorScheme.primary, AppColors.primary);
    });

    test('darkTheme has correct scaffold background', () {
      final theme = AppTheme.darkTheme;
      expect(theme.scaffoldBackgroundColor, AppColorsDark.background);
    });
  });
}
