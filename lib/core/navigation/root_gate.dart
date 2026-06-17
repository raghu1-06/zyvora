import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers.dart';
import '../theme/app_theme.dart';
import '../../screens/splash_screen.dart';

class ZyvoraRootGate extends ConsumerStatefulWidget {
  const ZyvoraRootGate({super.key});

  @override
  ConsumerState<ZyvoraRootGate> createState() => _ZyvoraRootGateState();
}

class _ZyvoraRootGateState extends ConsumerState<ZyvoraRootGate> {
  _LaunchTarget? _pendingTarget;
  _LaunchTarget? _activeTarget;
  Object? _error;
  bool _booting = false;
  bool _alarmInitStarted = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    if (_booting) return;
    _booting = true;

    try {
      final user = ref.read(userControllerProvider);
      final reminders = ref.read(reminderControllerProvider);

      final prefsFuture = SharedPreferences.getInstance();
      await user.initialize();
      await reminders.initialize();
      if (!mounted) return;

      final prefs = await prefsFuture;
      final onboardingSeen = prefs.getBool('zyvora.onboardingSeen') == true;
      final authCompleted = prefs.getBool('zyvora.authCompleted') == true;

      final next = !onboardingSeen
          ? _LaunchTarget.onboarding
          : !authCompleted
              ? _LaunchTarget.auth
              : user.isFirstLaunch
                  ? _LaunchTarget.modeSelection
                  : _LaunchTarget.main;

      if (!mounted) return;
      setState(() => _pendingTarget = next);
      _initializeAlarmsAfterLaunch();
      FlutterNativeSplash.remove();
    } catch (e, st) {
      debugPrint('Zyvora startup failed: $e\n$st');
      if (!mounted) return;
      setState(() {
        _error = e;
        _pendingTarget = _LaunchTarget.failed;
      });
      FlutterNativeSplash.remove();
    } finally {
      _booting = false;
    }
  }

  void _initializeAlarmsAfterLaunch() {
    if (_alarmInitStarted) return;
    _alarmInitStarted = true;
    if (!mounted) return;
    final alarms = ref.read(alarmControllerProvider);
    unawaited(
      Future<void>.delayed(
        const Duration(milliseconds: 300),
      ).then((_) async {
        if (!mounted) return;
        await alarms.initialize();
      }).catchError((Object e) {
        debugPrint('Alarm startup skipped: $e');
      }),
    );
  }

  void _commitLaunchTarget() {
    final target = _pendingTarget;
    if (!mounted || target == null || _activeTarget != null) return;
    setState(() => _activeTarget = target);

    final router = GoRouter.of(context);
    switch (target) {
      case _LaunchTarget.onboarding:
        router.go('/onboarding');
      case _LaunchTarget.auth:
        router.go('/auth');
      case _LaunchTarget.modeSelection:
        router.go('/mode');
      case _LaunchTarget.main:
        router.go('/app/dashboard');
      case _LaunchTarget.failed:
        break;
    }
  }

  void _retry() {
    if (!mounted) return;
    setState(() {
      _pendingTarget = null;
      _activeTarget = null;
      _error = null;
    });
    Future.microtask(_bootstrap);
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = switch (_activeTarget) {
      null => SplashScreen(
          ready: _pendingTarget != null,
          onCompleted: _commitLaunchTarget,
        ),
      _LaunchTarget.failed => _StartupErrorScreen(
          error: _error,
          onRetry: _retry,
        ),
      _ => const SizedBox.shrink(),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: ZyvoraMotion.curve,
      switchOutCurve: Curves.easeInCubic,
      child: KeyedSubtree(
        key: ValueKey(_activeTarget ?? 'animated-splash'),
        child: child,
      ),
    );
  }
}

enum _LaunchTarget { onboarding, auth, modeSelection, main, failed }

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: ZyvoraColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(ZyvoraRadius.lg),
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: ZyvoraColors.error,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Zyvora could not start',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your data is safe. Retry startup or reopen the app.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                if (error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    '$error',
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
