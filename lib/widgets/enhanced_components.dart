import 'package:flutter/material.dart';

import '../utils/zyvora_design_system.dart';

/// Enhanced PremiumCard with subtle interaction polish and animations
class EnhancedPremiumCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enableHover;
  final Duration animationDuration;

  const EnhancedPremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.onLongPress,
    this.enableHover = true,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<EnhancedPremiumCard> createState() => _EnhancedPremiumCardState();
}

class _EnhancedPremiumCardState extends State<EnhancedPremiumCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _elevationAnimation = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (mounted && (widget.onTap != null || widget.onLongPress != null)) {
      _controller.forward();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!mounted) return;
    _controller.reverse();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!mounted) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _elevationAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Material(
                color: Colors.transparent,
                elevation: _elevationAnimation.value,
                borderRadius: BorderRadius.circular(
                  ZyvoraDesignSystem.radiusLarge,
                ),
                child: Container(
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    color: ZyvoraDesignSystem.surfaceCard,
                    borderRadius: BorderRadius.circular(
                      ZyvoraDesignSystem.radiusLarge,
                    ),
                    border: Border.all(
                      color: ZyvoraDesignSystem.surfaceAlt,
                      width: 1,
                    ),
                  ),
                  child: child,
                ),
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// Enhanced PremiumButton with ripple and scale feedback
class EnhancedPremiumButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final bool fullWidth;
  final bool isLoading;
  final IconData? icon;
  final Duration animationDuration;

  const EnhancedPremiumButton({
    super.key,
    required this.label,
    this.onPressed,
    this.outlined = false,
    this.fullWidth = false,
    this.isLoading = false,
    this.icon,
    this.animationDuration = const Duration(milliseconds: 250),
  });

  @override
  State<EnhancedPremiumButton> createState() => _EnhancedPremiumButtonState();
}

class _EnhancedPremiumButtonState extends State<EnhancedPremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (mounted && widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!mounted) return;
    _controller.reverse();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!mounted) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: isDisabled ? null : widget.onPressed,
          child: Container(
            height: 48,
            width: widget.fullWidth ? double.infinity : null,
            decoration: BoxDecoration(
              gradient: !widget.outlined
                  ? LinearGradient(
                      colors: [
                        ZyvoraDesignSystem.accentBlue.withValues(alpha: 0.9),
                        ZyvoraDesignSystem.accentBlue.withValues(alpha: 0.7),
                      ],
                    )
                  : null,
              color: widget.outlined
                  ? isDisabled
                        ? ZyvoraDesignSystem.surfaceAlt
                        : Colors.transparent
                  : null,
              borderRadius: BorderRadius.circular(
                ZyvoraDesignSystem.radiusLarge,
              ),
              border: widget.outlined
                  ? Border.all(
                      color: isDisabled
                          ? ZyvoraDesignSystem.textTertiary
                          : ZyvoraDesignSystem.textSecondary,
                      width: 1.5,
                    )
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isDisabled ? null : widget.onPressed,
                borderRadius: BorderRadius.circular(
                  ZyvoraDesignSystem.radiusLarge,
                ),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              widget.outlined
                                  ? ZyvoraDesignSystem.textSecondary
                                  : Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color: widget.outlined
                                    ? isDisabled
                                          ? ZyvoraDesignSystem.textTertiary
                                          : ZyvoraDesignSystem.textPrimary
                                    : Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.label,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: widget.outlined
                                        ? isDisabled
                                              ? ZyvoraDesignSystem.textTertiary
                                              : ZyvoraDesignSystem.textPrimary
                                        : Colors.white,
                                    fontWeight: ZyvoraDesignSystem.weightBold,
                                  ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Enhanced PremiumListTile with subtle hover and scale feedback
class EnhancedPremiumListTile extends StatefulWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  const EnhancedPremiumListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  @override
  State<EnhancedPremiumListTile> createState() =>
      _EnhancedPremiumListTileState();
}

class _EnhancedPremiumListTileState extends State<EnhancedPremiumListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _bgColorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _bgColorAnimation = ColorTween(
      begin: ZyvoraDesignSystem.surfaceCard,
      end: ZyvoraDesignSystem.surfaceAlt,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (mounted && widget.onTap != null && widget.enabled) {
      _controller.forward();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!mounted) return;
    _controller.reverse();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!mounted) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _bgColorAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(ZyvoraDesignSystem.spacing12),
                decoration: BoxDecoration(
                  color: _bgColorAnimation.value,
                  borderRadius: BorderRadius.circular(
                    ZyvoraDesignSystem.radiusLarge,
                  ),
                  border: Border.all(
                    color: ZyvoraDesignSystem.surfaceAlt,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    if (widget.leading != null) ...[
                      widget.leading!,
                      const SizedBox(width: ZyvoraDesignSystem.spacing12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (widget.subtitle != null)
                            Text(
                              widget.subtitle!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: ZyvoraDesignSystem.textSecondary,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    if (widget.trailing != null) ...[
                      const SizedBox(width: ZyvoraDesignSystem.spacing12),
                      widget.trailing!,
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Smooth page transition between screens
class SmoothPageTransition extends PageRouteBuilder {
  final Widget page;

  SmoothPageTransition({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 0.03),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.99, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      );
}
