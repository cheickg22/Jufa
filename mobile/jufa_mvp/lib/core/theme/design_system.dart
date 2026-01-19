import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Design System Jufa - Composants réutilisables et cohérents
class JufaDesignSystem {
  // Couleurs étendues
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);
  
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color secondaryOrange = Color(0xFFFF9800);
  static const Color secondaryPurple = Color(0xFF9C27B0);
  
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);
  static const Color infoBlue = Color(0xFF2196F3);
  
  // Couleurs neutres
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);
  
  // Couleurs mode sombre
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkBorder = Color(0xFF2C2C2C);
  
  // Espacements
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;
  
  // Rayons de bordure
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusRound = 24.0;
  
  // Élévations
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation4 = 4.0;
  static const double elevation8 = 8.0;
  static const double elevation16 = 16.0;
  
  // Typographie
  static const TextStyle headingXLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: -0.25,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
  );
}

/// Composant Card personnalisé
class JufaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final double? borderRadius;
  final Border? border;
  final VoidCallback? onTap;
  final bool isInteractive;

  const JufaCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.border,
    this.onTap,
    this.isInteractive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Widget card = Container(
      margin: margin ?? const EdgeInsets.all(JufaDesignSystem.spacing8),
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? JufaDesignSystem.darkCard : Colors.white),
        borderRadius: BorderRadius.circular(borderRadius ?? JufaDesignSystem.radiusLarge),
        border: border,
        boxShadow: elevation != null ? [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: elevation!,
            offset: Offset(0, elevation! / 2),
          ),
        ] : null,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(JufaDesignSystem.spacing16),
        child: child,
      ),
    );

    if (onTap != null || isInteractive) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? JufaDesignSystem.radiusLarge),
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Bouton personnalisé Jufa
class JufaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final JufaButtonStyle style;
  final JufaButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const JufaButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = JufaButtonStyle.primary,
    this.size = JufaButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Configuration selon le style
    Color backgroundColor;
    Color textColor;
    Color? borderColor;
    
    switch (style) {
      case JufaButtonStyle.primary:
        backgroundColor = JufaDesignSystem.primaryBlue;
        textColor = Colors.white;
        break;
      case JufaButtonStyle.secondary:
        backgroundColor = isDark ? JufaDesignSystem.darkCard : JufaDesignSystem.neutral100;
        textColor = isDark ? Colors.white : JufaDesignSystem.neutral800;
        break;
      case JufaButtonStyle.outline:
        backgroundColor = Colors.transparent;
        textColor = JufaDesignSystem.primaryBlue;
        borderColor = JufaDesignSystem.primaryBlue;
        break;
      case JufaButtonStyle.ghost:
        backgroundColor = Colors.transparent;
        textColor = JufaDesignSystem.primaryBlue;
        break;
      case JufaButtonStyle.success:
        backgroundColor = JufaDesignSystem.successGreen;
        textColor = Colors.white;
        break;
      case JufaButtonStyle.warning:
        backgroundColor = JufaDesignSystem.warningOrange;
        textColor = Colors.white;
        break;
      case JufaButtonStyle.error:
        backgroundColor = JufaDesignSystem.errorRed;
        textColor = Colors.white;
        break;
    }
    
    // Configuration selon la taille
    double height;
    EdgeInsetsGeometry padding;
    TextStyle textStyle;
    
    switch (size) {
      case JufaButtonSize.small:
        height = 32;
        padding = const EdgeInsets.symmetric(horizontal: JufaDesignSystem.spacing12);
        textStyle = JufaDesignSystem.labelMedium;
        break;
      case JufaButtonSize.medium:
        height = 44;
        padding = const EdgeInsets.symmetric(horizontal: JufaDesignSystem.spacing16);
        textStyle = JufaDesignSystem.labelLarge;
        break;
      case JufaButtonSize.large:
        height = 52;
        padding = const EdgeInsets.symmetric(horizontal: JufaDesignSystem.spacing24);
        textStyle = JufaDesignSystem.bodyLarge;
        break;
    }

    Widget buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          const SizedBox(width: JufaDesignSystem.spacing8),
        ] else if (icon != null) ...[
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: JufaDesignSystem.spacing8),
        ],
        Text(
          text,
          style: textStyle.copyWith(color: textColor),
        ),
      ],
    );

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: style == JufaButtonStyle.primary ? JufaDesignSystem.elevation2 : 0,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(JufaDesignSystem.radiusMedium),
            side: borderColor != null ? BorderSide(color: borderColor) : BorderSide.none,
          ),
        ),
        child: buttonChild,
      ),
    );
  }
}

/// Input Field personnalisé
class JufaTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLines;

  const JufaTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: JufaDesignSystem.labelMedium.copyWith(
              color: isDark ? JufaDesignSystem.neutral300 : JufaDesignSystem.neutral700,
            ),
          ),
          const SizedBox(height: JufaDesignSystem.spacing4),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          validator: validator,
          enabled: enabled,
          maxLines: maxLines,
          style: JufaDesignSystem.bodyMedium.copyWith(
            color: isDark ? Colors.white : JufaDesignSystem.neutral900,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: JufaDesignSystem.bodyMedium.copyWith(
              color: isDark ? JufaDesignSystem.neutral500 : JufaDesignSystem.neutral400,
            ),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon != null 
                ? IconButton(
                    icon: Icon(suffixIcon),
                    onPressed: onSuffixIconTap,
                  )
                : null,
            filled: true,
            fillColor: isDark ? JufaDesignSystem.darkCard : JufaDesignSystem.neutral50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(JufaDesignSystem.radiusMedium),
              borderSide: BorderSide(
                color: isDark ? JufaDesignSystem.darkBorder : JufaDesignSystem.neutral300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(JufaDesignSystem.radiusMedium),
              borderSide: BorderSide(
                color: isDark ? JufaDesignSystem.darkBorder : JufaDesignSystem.neutral300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(JufaDesignSystem.radiusMedium),
              borderSide: const BorderSide(
                color: JufaDesignSystem.primaryBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(JufaDesignSystem.radiusMedium),
              borderSide: const BorderSide(
                color: JufaDesignSystem.errorRed,
              ),
            ),
            errorText: errorText,
            helperText: helperText,
            contentPadding: const EdgeInsets.all(JufaDesignSystem.spacing16),
          ),
        ),
      ],
    );
  }
}

/// Chip personnalisé
class JufaChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const JufaChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color bgColor = backgroundColor ?? (isSelected 
        ? JufaDesignSystem.primaryBlue 
        : (isDark ? JufaDesignSystem.darkCard : JufaDesignSystem.neutral100));
    
    Color txtColor = textColor ?? (isSelected 
        ? Colors.white 
        : (isDark ? Colors.white : JufaDesignSystem.neutral700));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: JufaDesignSystem.spacing12,
          vertical: JufaDesignSystem.spacing8,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(JufaDesignSystem.radiusRound),
          border: isSelected ? null : Border.all(
            color: isDark ? JufaDesignSystem.darkBorder : JufaDesignSystem.neutral300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: txtColor),
              const SizedBox(width: JufaDesignSystem.spacing4),
            ],
            Text(
              label,
              style: JufaDesignSystem.labelMedium.copyWith(color: txtColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// Enums pour les styles
enum JufaButtonStyle {
  primary,
  secondary,
  outline,
  ghost,
  success,
  warning,
  error,
}

enum JufaButtonSize {
  small,
  medium,
  large,
}

/// Utilitaires pour les haptics
class JufaHaptics {
  static void light() {
    HapticFeedback.lightImpact();
  }
  
  static void medium() {
    HapticFeedback.mediumImpact();
  }
  
  static void heavy() {
    HapticFeedback.heavyImpact();
  }
  
  static void selection() {
    HapticFeedback.selectionClick();
  }
}
