import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/providers.dart';
import '../core/theme/app_theme.dart';

/// Email + Google placeholder — production would wire `google_sign_in` / Firebase.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _completeAuth({String? message}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('zyvora.authCompleted', true);
    if (!mounted) return;
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    final user = ref.read(userControllerProvider);
    if (user.isFirstLaunch) {
      context.go('/mode');
    } else {
      context.go('/app/dashboard');
    }
  }

  Future<void> _emailSignIn() async {
    if (_busy) return;
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _busy = false);
    final email = _email.text.trim();
    if (email.isNotEmpty) {
      await ref.read(userControllerProvider).setUserName(email.split('@').first);
    }
    await _completeAuth(message: 'Signed in');
  }

  Future<void> _google() async {
    if (_busy) return;
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _busy = false);
    await ref.read(userControllerProvider).setUserName('Google user');
    await _completeAuth(
      message: 'Google sign-in will connect here in production.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: ZyvoraColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          children: [
            const SizedBox(height: 40),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    ZyvoraColors.accentBlue.withValues(alpha: 0.4),
                    ZyvoraColors.accentPurple.withValues(alpha: 0.28),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: ZyvoraColors.accentBlue.withValues(alpha: 0.35),
                    blurRadius: 24,
                    spreadRadius: -6,
                  ),
                ],
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Sign in to Zyvora',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: ZyvoraColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Minimal auth UI — your data stays on device.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 36),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _busy ? null : _emailSignIn,
              child: _busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Continue'),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _busy ? null : _google,
              icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
              label: const Text('Continue with Google'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _busy ? null : () => _completeAuth(),
              child: const Text('Continue without an account'),
            ),
          ],
        ),
      ),
    );
  }
}
