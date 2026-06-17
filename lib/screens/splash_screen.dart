import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.ready = false, this.onCompleted});

  final bool ready;
  final VoidCallback? onCompleted;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _progressCtrl;
  late final AnimationController _exitCtrl;
  late final CurvedAnimation _entranceCurve;
  late final CurvedAnimation _exitCurve;

  bool _baseProgressDone = false;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _entranceCurve = CurvedAnimation(
      parent: _entranceCtrl,
      curve: Curves.easeOutCubic,
    );
    _exitCurve = CurvedAnimation(
      parent: _exitCtrl,
      curve: Curves.easeInOutCubic,
    );

    _entranceCtrl.forward();
    _progressCtrl
        .animateTo(
          0.84,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
        )
        .whenComplete(() {
          if (!mounted) return;
          _baseProgressDone = true;
          _tryComplete();
        });
  }

  @override
  void didUpdateWidget(covariant SplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.ready && widget.ready) {
      _tryComplete();
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _progressCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  Future<void> _tryComplete() async {
    if (_finishing || !_baseProgressDone || !widget.ready) return;
    _finishing = true;

    try {
      await _progressCtrl
          .animateTo(
            1,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          )
          .orCancel;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;

      await _exitCtrl.forward().orCancel;
      if (!mounted) return;
      widget.onCompleted?.call();
    } on TickerCanceled {
      // Route was disposed during startup transition.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark
        ? ZyvoraColors.textDark
        : ZyvoraColors.textPrimary;

    return Scaffold(
      backgroundColor: ZyvoraColors.background,
      body: AnimatedBuilder(
        animation: Listenable.merge([_entranceCtrl, _progressCtrl, _exitCtrl]),
        builder: (context, _) {
          final entrance = _entranceCurve.value;
          final exit = _exitCurve.value;
          final visible = (1 - exit).clamp(0.0, 1.0);
          final slideOffset = (1 - entrance) * 18;
          final scale = 0.94 + (entrance * 0.06) - (exit * 0.02);

          return Opacity(
            opacity: visible,
            child: Transform.translate(
              offset: Offset(0, slideOffset),
              child: Transform.scale(
                scale: scale,
                child: Center(
                  child: RepaintBoundary(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _LogoMark(progress: entrance),
                          const SizedBox(height: 30),
                          Opacity(
                            opacity: _interval(entrance, 0.18, 0.82),
                            child: Column(
                              children: [
                                Text(
                                  'Zyvora',
                                  style: theme.textTheme.headlineLarge
                                      ?.copyWith(
                                        color: textColor,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _finishing
                                      ? 'Opening your workspace'
                                      : 'Organize your day intelligently',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: ZyvoraColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 42),
                          _ProgressLine(value: _progressCtrl.value),
                          const SizedBox(height: 16),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0,
                              end: widget.ready ? 1 : 0,
                            ),
                            duration: const Duration(milliseconds: 380),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: 0.62 + (value * 0.38),
                                child: Text(
                                  widget.ready
                                      ? 'Ready'
                                      : 'Preparing workspace',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: ZyvoraColors.textSecondary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  double _interval(double value, double start, double end) {
    if (value <= start) return 0;
    if (value >= end) return 1;
    return Curves.easeOutCubic.transform((value - start) / (end - start));
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final glow = 0.18 + (progress * 0.28);
    return Container(
      width: 98,
      height: 98,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ZyvoraColors.secondary.withValues(alpha: 0.95),
            ZyvoraColors.primary.withValues(alpha: 0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ZyvoraColors.primary.withValues(alpha: glow),
            blurRadius: 34,
            spreadRadius: -6,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.13),
            ),
          ),
          const Icon(Icons.bolt_rounded, color: Colors.white, size: 46),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return SizedBox(
      width: 184,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Container(
              height: 3,
              color: ZyvoraColors.borderLight.withValues(alpha: 0.75),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: clamped,
                alignment: Alignment.centerLeft,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    gradient: const LinearGradient(
                      colors: [ZyvoraColors.secondary, ZyvoraColors.primary],
                    ),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
