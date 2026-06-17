import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../core/theme/app_theme.dart';
import '../models/zyvora_role.dart';
import '../widgets/mode_card.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  static const _roleColors = {
    ZyvoraRole.student: ZyvoraColors.blue,
    ZyvoraRole.employee: ZyvoraColors.purple,
    ZyvoraRole.teacher: ZyvoraColors.green,
    ZyvoraRole.freelancer: ZyvoraColors.orange,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 20),
            Text('What describes you?', style: theme.textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Your dashboard will be customized for your role.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            ...ZyvoraRole.values.map(
              (role) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: ModeCard(
                  icon: role.icon,
                  title: role.label,
                  subtitle: role.description,
                  color: _roleColors[role] ?? ZyvoraColors.primary,
                  onTap: () => _selectRole(context, ref, role),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectRole(
    BuildContext context,
    WidgetRef ref,
    ZyvoraRole role,
  ) async {
    await ref.read(userControllerProvider).setRole(role);
    if (!context.mounted) return;
    context.go('/app/dashboard');
  }
}
