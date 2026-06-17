import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ZyvoraStartupOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const ZyvoraStartupOverlay({super.key, required this.onComplete});

  @override
  State<ZyvoraStartupOverlay> createState() => _ZyvoraStartupOverlayState();
}

class _ZyvoraStartupOverlayState extends State<ZyvoraStartupOverlay> with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _breathController;
  late final AnimationController _exitController;

  late final Animation<double> _bgFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textFade;
  late final Animation<double> _breathScale;
  late final Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();
    
    _bgController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _breathController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _exitController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _bgFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeOut));
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic));
    _logoFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic));
    
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _textFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _breathScale = Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(parent: _breathController, curve: Curves.easeInOut));
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _exitController, curve: Curves.easeOut));

    _playSequence();
  }

  Future<void> _playSequence() async {
    _bgController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400)); // 600ms total
    if (!mounted) return;
    _textController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300)); // 900ms total
    if (!mounted) return;
    _breathController.repeat(reverse: true);
    
    await Future.delayed(const Duration(milliseconds: 1400)); // 2300ms total
    if (!mounted) return;
    _breathController.stop();
    _exitController.forward();
    
    await Future.delayed(const Duration(milliseconds: 500)); // 2800ms total
    if (!mounted) return;
    widget.onComplete();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _breathController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _exitFade,
      child: Scaffold(
        backgroundColor: const Color(0xFF07060F),
        body: Stack(
          children: [
            // Ambient Glow
            Positioned.fill(
              child: Center(
                child: FadeTransition(
                  opacity: _bgFade,
                  child: ScaleTransition(
                    scale: _breathScale,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF7C3AED).withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                          radius: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: ScaleTransition(
                        scale: _breathScale,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeTransition(
                    opacity: _textFade,
                    child: SlideTransition(
                      position: _textSlide,
                      child: Column(
                        children: [
                          Text(
                            "Zyvora",
                            style: GoogleFonts.sora(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Focus. Track. Achieve.",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
