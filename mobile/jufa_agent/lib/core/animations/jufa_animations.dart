import 'package:flutter/material.dart';

/// Animations et micro-interactions pour Jufa
class JufaAnimations {
  // Durées d'animation
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
  
  // Courbes d'animation
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
  
  /// Animation de fade in
  static Widget fadeIn({
    required Widget child,
    Duration duration = normal,
    Curve curve = easeOut,
    double delay = 0.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration + Duration(milliseconds: (delay * 1000).round()),
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: delay > 0 && value < delay ? 0.0 : (value - delay) / (1.0 - delay),
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// Animation de slide in
  static Widget slideIn({
    required Widget child,
    Duration duration = normal,
    Curve curve = easeOut,
    Offset begin = const Offset(0, 1),
    double delay = 0.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration + Duration(milliseconds: (delay * 1000).round()),
      curve: curve,
      builder: (context, value, child) {
        final adjustedValue = delay > 0 && value < delay ? 0.0 : (value - delay) / (1.0 - delay);
        return Transform.translate(
          offset: Offset(
            begin.dx * (1 - adjustedValue),
            begin.dy * (1 - adjustedValue),
          ),
          child: Opacity(
            opacity: adjustedValue,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Animation de scale in
  static Widget scaleIn({
    required Widget child,
    Duration duration = normal,
    Curve curve = elasticOut,
    double delay = 0.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration + Duration(milliseconds: (delay * 1000).round()),
      curve: curve,
      builder: (context, value, child) {
        final adjustedValue = delay > 0 && value < delay ? 0.0 : (value - delay) / (1.0 - delay);
        return Transform.scale(
          scale: adjustedValue,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Widget d'animation de liste
class AnimatedListView extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDelay;
  final Duration animationDuration;
  final Curve curve;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const AnimatedListView({
    super.key,
    required this.children,
    this.itemDelay = const Duration(milliseconds: 100),
    this.animationDuration = JufaAnimations.normal,
    this.curve = JufaAnimations.easeOut,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: physics,
      padding: padding,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return JufaAnimations.slideIn(
          duration: animationDuration,
          curve: curve,
          delay: index * itemDelay.inMilliseconds / 1000,
          child: children[index],
        );
      },
    );
  }
}

/// Bouton avec animation de press
class AnimatedPressButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration duration;
  final double scaleValue;

  const AnimatedPressButton({
    super.key,
    required this.child,
    this.onPressed,
    this.duration = JufaAnimations.fast,
    this.scaleValue = 0.95,
  });

  @override
  State<AnimatedPressButton> createState() => _AnimatedPressButtonState();
}

class _AnimatedPressButtonState extends State<AnimatedPressButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleValue,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Card avec animation de hover
class AnimatedHoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final double elevation;
  final double hoverElevation;

  const AnimatedHoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.duration = JufaAnimations.normal,
    this.elevation = 2.0,
    this.hoverElevation = 8.0,
  });

  @override
  State<AnimatedHoverCard> createState() => _AnimatedHoverCardState();
}

class _AnimatedHoverCardState extends State<AnimatedHoverCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.hoverElevation,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter(PointerEvent details) {
    setState(() => _isHovered = true);
    _controller.forward();
  }

  void _onExit(PointerEvent details) {
    setState(() => _isHovered = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _elevationAnimation,
          builder: (context, child) {
            return Card(
              elevation: _elevationAnimation.value,
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}

/// Loading avec animation
class AnimatedLoading extends StatefulWidget {
  final String? text;
  final Color? color;
  final double size;

  const AnimatedLoading({
    super.key,
    this.text,
    this.color,
    this.size = 40.0,
  });

  @override
  State<AnimatedLoading> createState() => _AnimatedLoadingState();
}

class _AnimatedLoadingState extends State<AnimatedLoading>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_rotationController, _scaleAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationController.value * 2 * 3.14159,
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.color ?? Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.text != null) ...[
          const SizedBox(height: 16),
          JufaAnimations.fadeIn(
            child: Text(
              widget.text!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}

/// Transition de page personnalisée
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Offset begin;
  final Offset end;
  final Duration duration;

  SlidePageRoute({
    required this.child,
    this.begin = const Offset(1.0, 0.0),
    this.end = Offset.zero,
    this.duration = JufaAnimations.normal,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: begin,
                end: end,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
        );
}

/// Transition de fade
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  FadePageRoute({
    required this.child,
    this.duration = JufaAnimations.normal,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

/// Mixin pour les animations de page
mixin PageAnimationMixin on State, TickerProviderStateMixin {
  late AnimationController pageAnimationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();
    pageAnimationController = AnimationController(
      duration: JufaAnimations.normal,
      vsync: this,
    );
    
    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: pageAnimationController,
      curve: Curves.easeOut,
    ));
    
    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: pageAnimationController,
      curve: Curves.easeOut,
    ));
    
    // Démarrer l'animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pageAnimationController.forward();
    });
  }

  @override
  void dispose() {
    pageAnimationController.dispose();
    super.dispose();
  }

  Widget buildAnimatedPage(Widget child) {
    return AnimatedBuilder(
      animation: pageAnimationController,
      builder: (context, _) {
        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
    );
  }
}

/// Classe de base pour les pages animées (alternative au mixin)
abstract class AnimatedPageState<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  late AnimationController pageAnimationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();
    pageAnimationController = AnimationController(
      duration: JufaAnimations.normal,
      vsync: this,
    );
    
    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: pageAnimationController,
      curve: Curves.easeOut,
    ));
    
    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: pageAnimationController,
      curve: Curves.easeOut,
    ));
    
    // Démarrer l'animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pageAnimationController.forward();
    });
  }

  @override
  void dispose() {
    pageAnimationController.dispose();
    super.dispose();
  }

  Widget buildAnimatedPage(Widget child) {
    return AnimatedBuilder(
      animation: pageAnimationController,
      builder: (context, _) {
        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
    );
  }
}
