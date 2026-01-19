import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';

/// Service d'accessibilité pour Jufa
class AccessibilityService {
  static bool _isScreenReaderEnabled = false;
  static bool _isHighContrastEnabled = false;
  static double _textScaleFactor = 1.0;
  
  static bool get isScreenReaderEnabled => _isScreenReaderEnabled;
  static bool get isHighContrastEnabled => _isHighContrastEnabled;
  static double get textScaleFactor => _textScaleFactor;

  /// Initialiser le service d'accessibilité
  static Future<void> initialize() async {
    // Détecter si un lecteur d'écran est actif
    _updateAccessibilityStatus();
    
    // Écouter les changements d'accessibilité
    WidgetsBinding.instance.platformDispatcher.onAccessibilityFeaturesChanged = () {
      _updateAccessibilityStatus();
    };
  }

  /// Mettre à jour le statut d'accessibilité
  static void _updateAccessibilityStatus() {
    final window = WidgetsBinding.instance.platformDispatcher;
    final accessibilityFeatures = window.accessibilityFeatures;
    
    _isScreenReaderEnabled = accessibilityFeatures.accessibleNavigation;
    _isHighContrastEnabled = accessibilityFeatures.highContrast;
    _textScaleFactor = window.textScaleFactor;
  }

  /// Annoncer un message au lecteur d'écran
  static void announce(String message, {TextDirection? textDirection}) {
    if (_isScreenReaderEnabled) {
      SemanticsService.announce(
        message,
        textDirection ?? TextDirection.ltr,
      );
    }
  }

  /// Vibration haptique pour les interactions
  static void hapticFeedback(HapticFeedbackType type) {
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }

  /// Obtenir la taille de police adaptée
  static double getAdaptedFontSize(double baseFontSize) {
    return baseFontSize * _textScaleFactor.clamp(0.8, 2.0);
  }

  /// Obtenir les couleurs à contraste élevé
  static Color getHighContrastColor(Color baseColor, bool isDark) {
    if (!_isHighContrastEnabled) return baseColor;
    
    if (isDark) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }
}

/// Widget accessible personnalisé
class AccessibleWidget extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final String? semanticHint;
  final VoidCallback? onTap;
  final bool isButton;
  final bool isHeader;
  final bool excludeSemantics;

  const AccessibleWidget({
    super.key,
    required this.child,
    this.semanticLabel,
    this.semanticHint,
    this.onTap,
    this.isButton = false,
    this.isHeader = false,
    this.excludeSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    if (excludeSemantics) {
      return ExcludeSemantics(child: child);
    }

    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: isButton,
      header: isHeader,
      onTap: onTap,
      child: child,
    );
  }
}

/// Bouton accessible
class AccessibleButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? semanticLabel;
  final String? semanticHint;
  final ButtonStyle? style;

  const AccessibleButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.semanticLabel,
    this.semanticHint,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? text,
      hint: semanticHint ?? 'Bouton',
      button: true,
      enabled: onPressed != null,
      onTap: onPressed,
      child: ElevatedButton.icon(
        onPressed: () {
          AccessibilityService.hapticFeedback(HapticFeedbackType.light);
          onPressed?.call();
        },
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(text),
        style: style,
      ),
    );
  }
}

/// Champ de texte accessible
class AccessibleTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? semanticLabel;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const AccessibleTextField({
    super.key,
    this.label,
    this.hint,
    this.semanticLabel,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? label ?? hint,
      hint: 'Champ de saisie',
      textField: true,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
      ),
    );
  }
}

/// Navigation accessible
class AccessibleNavigation extends StatelessWidget {
  final List<AccessibleNavItem> items;
  final int currentIndex;
  final Function(int) onTap;

  const AccessibleNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        AccessibilityService.hapticFeedback(HapticFeedbackType.selection);
        AccessibilityService.announce('Navigation vers ${items[index].label}');
        onTap(index);
      },
      items: items.map((item) => BottomNavigationBarItem(
        icon: Semantics(
          label: item.semanticLabel ?? item.label,
          hint: 'Onglet de navigation',
          button: true,
          child: Icon(item.icon),
        ),
        label: item.label,
      )).toList(),
    );
  }
}

/// Élément de navigation accessible
class AccessibleNavItem {
  final String label;
  final IconData icon;
  final String? semanticLabel;

  const AccessibleNavItem({
    required this.label,
    required this.icon,
    this.semanticLabel,
  });
}

/// Card accessible avec focus
class AccessibleCard extends StatefulWidget {
  final Widget child;
  final String? semanticLabel;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const AccessibleCard({
    super.key,
    required this.child,
    this.semanticLabel,
    this.onTap,
    this.padding,
  });

  @override
  State<AccessibleCard> createState() => _AccessibleCardState();
}

class _AccessibleCardState extends State<AccessibleCard> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() => _isFocused = hasFocus);
        if (hasFocus) {
          AccessibilityService.hapticFeedback(HapticFeedbackType.light);
        }
      },
      child: Semantics(
        label: widget.semanticLabel,
        button: widget.onTap != null,
        focusable: true,
        onTap: widget.onTap,
        child: Card(
          elevation: _isFocused ? 8 : 2,
          child: InkWell(
            onTap: () {
              AccessibilityService.hapticFeedback(HapticFeedbackType.medium);
              widget.onTap?.call();
            },
            child: Container(
              padding: widget.padding ?? const EdgeInsets.all(16),
              decoration: _isFocused ? BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ) : null,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Liste accessible avec annonces
class AccessibleListView extends StatelessWidget {
  final List<Widget> children;
  final String? semanticLabel;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;

  const AccessibleListView({
    super.key,
    required this.children,
    this.semanticLabel,
    this.controller,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? 'Liste de ${children.length} éléments',
      child: ListView.builder(
        controller: controller,
        padding: padding,
        itemCount: children.length,
        itemBuilder: (context, index) {
          return Semantics(
            label: 'Élément ${index + 1} sur ${children.length}',
            child: children[index],
          );
        },
      ),
    );
  }
}

/// Mixin pour l'accessibilité des pages
mixin AccessibilityMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announcePageTitle();
    });
  }

  void _announcePageTitle() {
    final route = ModalRoute.of(context);
    if (route?.settings.name != null) {
      AccessibilityService.announce('Page ${route!.settings.name}');
    }
  }

  void announceAction(String action) {
    AccessibilityService.announce(action);
  }

  void hapticFeedback(HapticFeedbackType type) {
    AccessibilityService.hapticFeedback(type);
  }
}

/// Types de feedback haptique
enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
}

/// Utilitaires pour l'accessibilité
class AccessibilityUtils {
  /// Vérifier si le texte est lisible
  static bool isTextReadable(Color textColor, Color backgroundColor) {
    final textLuminance = textColor.computeLuminance();
    final backgroundLuminance = backgroundColor.computeLuminance();
    
    final contrast = (textLuminance + 0.05) / (backgroundLuminance + 0.05);
    return contrast >= 4.5; // WCAG AA standard
  }

  /// Obtenir une couleur de texte contrastée
  static Color getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Formater un montant pour l'accessibilité
  static String formatCurrencyForAccessibility(double amount, String currency) {
    final formattedAmount = amount.toStringAsFixed(0);
    return '$formattedAmount $currency';
  }

  /// Formater une date pour l'accessibilité
  static String formatDateForAccessibility(DateTime date) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
