import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_theme.dart';
import 'auth_screen.dart';

class _Slide {
  const _Slide({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  final String title;
  final String subtitle;
  final IconData icon;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _page = PageController();
  int _pageIndex = 0;

  static const _slides = [
    _Slide(
      title: 'Manage reminders smartly.',
      subtitle:
          'Weekly routines and one-tap completion — calm, clear, on your time.',
      icon: Icons.notifications_active_outlined,
    ),
    _Slide(
      title: 'Track attendance effortlessly.',
      subtitle:
          'Subjects, safe targets, and bunk math when you need professional mode.',
      icon: Icons.fact_check_outlined,
    ),
    _Slide(
      title: 'Build productive routines daily.',
      subtitle:
          'Streaks and insights stay text-based — no clutter, no voice assistant.',
      icon: Icons.auto_graph_outlined,
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('zyvora.onboardingSeen', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
    );
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: ZyvoraColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _page,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _pageIndex = i),
                itemBuilder: (context, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                ZyvoraColors.accentBlue.withValues(alpha: 0.35),
                                ZyvoraColors.accentPurple.withValues(
                                  alpha: 0.25,
                                ),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ZyvoraColors.accentBlue.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 28,
                                spreadRadius: -6,
                              ),
                            ],
                          ),
                          child: Icon(s.icon, size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          s.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: ZyvoraColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          s.subtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: ZyvoraColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: ZyvoraMotion.fast,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _pageIndex == i ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: _pageIndex == i
                        ? ZyvoraColors.accentBlue
                        : ZyvoraColors.textSecondary.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    if (_pageIndex < _slides.length - 1) {
                      _page.nextPage(
                        duration: ZyvoraMotion.regular,
                        curve: ZyvoraMotion.curve,
                      );
                    } else {
                      _finish();
                    }
                  },
                  child: Text(
                    _pageIndex < _slides.length - 1 ? 'Next' : 'Get started',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
