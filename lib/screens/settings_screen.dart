import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/providers.dart';
import '../core/utils/error_handler.dart';
import '../features/profile/controllers/user_controller.dart';
import '../models/zyvora_role.dart';
import '../utils/zyvora_design_system.dart';
import '../widgets/premium_components.dart';
import '../widgets/premium_navigation.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(userControllerProvider);

    return Scaffold(
      appBar: const PremiumAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.all(ZyvoraDesignSystem.spacing16),
        children: [
          PremiumCard(
            padding: const EdgeInsets.all(ZyvoraDesignSystem.spacing16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: ZyvoraDesignSystem.accentBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(ZyvoraDesignSystem.radiusMedium),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: ZyvoraDesignSystem.accentBlue,
                    size: 26,
                  ),
                ),
                const SizedBox(width: ZyvoraDesignSystem.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ctrl.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        ctrl.lifeMode != null
                            ? '${ctrl.lifeMode!.label} mode'
                            : 'No mode selected',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ZyvoraDesignSystem.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit name',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _editName(context, ctrl),
                ),
              ],
            ),
          ),
          const SizedBox(height: ZyvoraDesignSystem.spacing24),
          const SettingsBody(),
        ],
      ),
    );
  }

  Future<void> _editName(BuildContext context, UserController ctrl) async {
    final tc = TextEditingController(text: ctrl.storedUserName);
    try {
      final name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Your Name'),
          content: TextField(
            controller: tc,
            autofocus: true,
            maxLength: 100,
            decoration: const InputDecoration(
              hintText: 'Enter your name',
              helperText: 'Max 100 characters',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, tc.text),
              child: const Text('Save'),
            ),
          ],
        ),
      );

      if (!context.mounted) return;

      final trimmed = name?.trim() ?? '';
      if (trimmed.isNotEmpty) {
        try {
          await ctrl.setUserName(trimmed);

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Name saved successfully')),
          );
        } catch (e) {
          if (!context.mounted) return;
          ZyvoraErrorHandler.showError(
            context,
            title: 'Failed to save name',
            message: ZyvoraErrorHandler.formatErrorMessage(e),
          );
        }
      }
    } finally {
      tc.dispose();
    }
  }
}

/// Core preference tiles.
class SettingsBody extends ConsumerWidget {
  const SettingsBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(userControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PremiumListTile(
          leading: const Icon(Icons.dark_mode_outlined),
          title: 'Dark Mode',
          trailing: Switch(
            value: ctrl.isDarkMode,
            onChanged: (v) => ctrl.setDarkMode(v),
          ),
        ),
        const SizedBox(height: ZyvoraDesignSystem.spacing12),
        const _PushNotificationsTile(),
        const SizedBox(height: ZyvoraDesignSystem.spacing12),
        PremiumListTile(
          leading: const Icon(Icons.cloud_sync_outlined),
          title: 'Backup & sync',
          subtitle: 'Coming soon — encrypted cloud backup',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Backup will connect to your account at launch.'),
              ),
            );
          },
        ),
        const SizedBox(height: ZyvoraDesignSystem.spacing12),
        PremiumListTile(
          leading: const Icon(Icons.swap_horiz),
          title: 'Switch Life Mode',
          subtitle: ctrl.lifeMode?.label ?? 'Not set',
          onTap: () {
            if (!context.mounted) return;
            context.go('/mode');
          },
        ),
        if (ctrl.role != null) ...[
          const SizedBox(height: ZyvoraDesignSystem.spacing12),
          PremiumListTile(
            leading: const Icon(Icons.badge_outlined),
            title: 'Role',
            subtitle: ctrl.role!.label,
            onTap: () => _changeRole(context, ref, ctrl),
          ),
        ],
        const SizedBox(height: ZyvoraDesignSystem.spacing32),
        PremiumCard(
          padding: const EdgeInsets.all(ZyvoraDesignSystem.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('About Zyvora', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: ZyvoraDesignSystem.spacing8),
              Text(
                'Dual Life Productivity System\nReminders · Attendance · Routines\nv1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ZyvoraDesignSystem.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _changeRole(
    BuildContext context,
    WidgetRef ref,
    UserController ctrl,
  ) async {
    final role = await showDialog<ZyvoraRole>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Role'),
        children: ZyvoraRole.values
            .map(
              (r) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, r),
                child: Text(r.label),
              ),
            )
            .toList(),
      ),
    );
    if (role != null) await ctrl.setRole(role);
  }
}

class _PushNotificationsTile extends StatefulWidget {
  const _PushNotificationsTile();

  @override
  State<_PushNotificationsTile> createState() => _PushNotificationsTileState();
}

class _PushNotificationsTileState extends State<_PushNotificationsTile> {
  bool _enabled = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _read();
  }

  Future<void> _read() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _enabled = p.getBool('zyvora.pushEnabled') ?? true;
      _loaded = true;
    });
  }

  Future<void> _write(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('zyvora.pushEnabled', v);
    if (mounted) setState(() => _enabled = v);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const PremiumListTile(
        leading: Icon(Icons.notifications_outlined),
        title: 'Notifications',
        subtitle: 'Loading…',
      );
    }
    return PremiumListTile(
      leading: const Icon(Icons.notifications_outlined),
      title: 'Notifications',
      subtitle: 'Task & attendance alerts',
      trailing: Switch(value: _enabled, onChanged: _write),
    );
  }
}
