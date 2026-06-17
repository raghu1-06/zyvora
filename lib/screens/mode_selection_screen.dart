import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../core/theme/app_theme.dart';
import '../models/zyvora_role.dart';
import '../widgets/mode_card.dart';

class ModeSelectionScreen extends ConsumerWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 28),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ZyvoraColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(ZyvoraRadius.md),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: ZyvoraColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 24),
            Text('Welcome to Zyvora', style: theme.textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Choose how you want to organize your life.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 36),
            ModeCard(
              icon: Icons.favorite_outline,
              title: 'Personal',
              subtitle: 'Habits, routines, health & self-care',
              color: ZyvoraColors.coral,
              onTap: () => _selectMode(context, ref, LifeMode.personal),
            ),
            const SizedBox(height: 16),
            ModeCard(
              icon: Icons.work_outline,
              title: 'Professional',
              subtitle: 'Work, studies, meetings & career',
              color: ZyvoraColors.blue,
              onTap: () => _selectMode(context, ref, LifeMode.professional),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'You can switch anytime from settings',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectMode(
    BuildContext context,
    WidgetRef ref,
    LifeMode mode,
  ) async {
    final ctrl = ref.read(userControllerProvider);
    await ctrl.setLifeMode(mode);
    if (!context.mounted) return;
    if (mode == LifeMode.personal) {
      context.go('/app/dashboard');
    } else {
      context.go('/role');
    }
  }
}
