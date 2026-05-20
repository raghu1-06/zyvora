import 'dart:async';

import 'package:flutter/material.dart';

/// Reusable animation utilities for premium polish
class ZyvoraAnimations {
  /// Fade + slide up entrance animation for content
  static Widget fadeSlideUp({
    required Widget child,
    required Duration duration,
    Curve curve = Curves.easeOutCubic,
    double slideDistance = 20,
  }) {
    return _FadeSlideUpWidget(
      duration: duration,
      curve: curve,
      slideDistance: slideDistance,
      child: child,
    );
  }

  /// Scale + fade entrance for cards/items
  static Widget scaleIn({
    required Widget child,
    required Duration duration,
    Curve curve = Curves.easeOutBack,
    double begin = 0.9,
  }) {
    return _ScaleInWidget(
      duration: duration,
      curve: curve,
      begin: begin,
      child: child,
    );
  }

  /// Staggered list animation - each item animates in sequence
  static Widget staggeredList({
    required List<Widget> children,
    Duration itemDuration = const Duration(milliseconds: 300),
    Duration staggerDuration = const Duration(milliseconds: 100),
    Curve curve = Curves.easeOutCubic,
  }) {
    return _StaggeredListWidget(
      itemDuration: itemDuration,
      staggerDuration: staggerDuration,
      curve: curve,
      children: children,
    );
  }

  /// Floating action button scale animation on appear
  static Widget fabScale({
    required FloatingActionButton fab,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return _FabScaleWidget(duration: duration, child: fab);
  }

  /// Smooth size transition (useful for expand/collapse)
  static Widget smoothResize({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return AnimatedSize(
      duration: duration,
      curve: Curves.easeOutCubic,
      child: child,
    );
  }

  /// Color transition animation
  static Widget colorTransition({
    required Color beginColor,
    required Color endColor,
    required Duration duration,
    required Widget Function(Color) builder,
  }) {
    return _ColorTransitionWidget(
      beginColor: beginColor,
      endColor: endColor,
      duration: duration,
      builder: builder,
    );
  }
}

/// Fade + Slide Up Widget
class _FadeSlideUpWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double slideDistance;

  const _FadeSlideUpWidget({
    required this.child,
    required this.duration,
    required this.curve,
    required this.slideDistance,
  });

  @override
  State<_FadeSlideUpWidget> createState() => _FadeSlideUpWidgetState();
}

class _FadeSlideUpWidgetState extends State<_FadeSlideUpWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.slideDistance / 100),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

/// Scale In Widget
class _ScaleInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double begin;

  const _ScaleInWidget({
    required this.child,
    required this.duration,
    required this.curve,
    required this.begin,
  });

  @override
  State<_ScaleInWidget> createState() => _ScaleInWidgetState();
}

class _ScaleInWidgetState extends State<_ScaleInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(
      begin: widget.begin,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

/// Staggered List Animation Widget
class _StaggeredListWidget extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDuration;
  final Duration staggerDuration;
  final Curve curve;

  const _StaggeredListWidget({
    required this.children,
    required this.itemDuration,
    required this.staggerDuration,
    required this.curve,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        children.length,
        (index) => _StaggeredItemWidget(
          delay: staggerDuration * index,
          duration: itemDuration,
          curve: curve,
          child: children[index],
        ),
      ),
    );
  }
}

class _StaggeredItemWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const _StaggeredItemWidget({
    required this.child,
    required this.delay,
    required this.duration,
    required this.curve,
  });

  @override
  State<_StaggeredItemWidget> createState() => _StaggeredItemWidgetState();
}

class _StaggeredItemWidgetState extends State<_StaggeredItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _delayTimer = Timer(widget.delay, () {
      if (mounted && !_controller.isAnimating && !_controller.isCompleted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _controller, curve: widget.curve)),
        child: widget.child,
      ),
    );
  }
}

/// FAB Scale Animation Widget
class _FabScaleWidget extends StatefulWidget {
  final FloatingActionButton child;
  final Duration duration;

  const _FabScaleWidget({required this.child, required this.duration});

  @override
  State<_FabScaleWidget> createState() => _FabScaleWidgetState();
}

class _FabScaleWidgetState extends State<_FabScaleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
      child: widget.child,
    );
  }
}

/// Color Transition Widget
class _ColorTransitionWidget extends StatefulWidget {
  final Color beginColor;
  final Color endColor;
  final Duration duration;
  final Widget Function(Color) builder;

  const _ColorTransitionWidget({
    required this.beginColor,
    required this.endColor,
    required this.duration,
    required this.builder,
  });

  @override
  State<_ColorTransitionWidget> createState() => _ColorTransitionWidgetState();
}

class _ColorTransitionWidgetState extends State<_ColorTransitionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _colorAnimation = ColorTween(
      begin: widget.beginColor,
      end: widget.endColor,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, _) =>
          widget.builder(_colorAnimation.value ?? widget.endColor),
    );
  }
}

/// Premium Entrance Transition for Screens
class PremiumScreenTransition extends PageRouteBuilder {
  final Widget child;

  PremiumScreenTransition({required this.child})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 0.02),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      );
}
