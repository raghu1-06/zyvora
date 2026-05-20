import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../features/profile/controllers/user_controller.dart';
import '../core/utils/error_handler.dart';
import '../utils/zyvora_animations.dart';
import '../utils/zyvora_design_system.dart';
import '../widgets/premium_components.dart';
import '../widgets/premium_navigation.dart';

class PremiumProfileScreen extends ConsumerWidget {
  const PremiumProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(userControllerProvider);

    return Scaffold(
      appBar: const PremiumAppBar(title: 'Profile'),
      body: ZyvoraAnimations.fadeSlideUp(
        duration: const Duration(milliseconds: 400),
        slideDistance: 24,
        child: ListView(
          padding: const EdgeInsets.all(ZyvoraDesignSystem.spacing16),
          children: [
            PremiumCard(
              child: Padding(
                padding: const EdgeInsets.all(ZyvoraDesignSystem.spacing16),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ZyvoraDesignSystem.accentBlue.withValues(alpha: 0.95),
                            ZyvoraDesignSystem.accentPurple.withValues(
                              alpha: 0.95,
                            ),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          ZyvoraDesignSystem.radiusLarge,
                        ),
                      ),
                      child: const Icon(
                        Icons.account_circle,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: ZyvoraDesignSystem.spacing16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ctrl.userName.isNotEmpty ? ctrl.userName : 'Guest',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: ZyvoraDesignSystem.spacing4),
                          Text(
                            ctrl.lifeMode?.label ?? 'No mode selected',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: ZyvoraDesignSystem.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showEditNameDialog(context, ctrl),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: ZyvoraDesignSystem.spacing24),

            Padding(
              padding: const EdgeInsets.only(left: ZyvoraDesignSystem.spacing4),
              child: Text(
                'Settings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: ZyvoraDesignSystem.weightSemiBold,
                ),
              ),
            ),
            const SizedBox(height: ZyvoraDesignSystem.spacing12),

            PremiumListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: 'Dark Mode',
              trailing: Switch(
                value: ctrl.isDarkMode,
                onChanged: (v) => ctrl.setDarkMode(v),
              ),
            ),

            const SizedBox(height: ZyvoraDesignSystem.spacing12),

            PremiumListTile(
              leading: const Icon(Icons.info_outlined),
              title: 'About',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),

            const SizedBox(height: ZyvoraDesignSystem.spacing32),

            PremiumButton(
              label: 'Log Out',
              outlined: true,
              onPressed: () {
                // TODO: implement logout
              },
            ),

            const SizedBox(height: 100.0),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, UserController ctrl) {
    final rootContext = context;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final controller = TextEditingController(text: ctrl.userName);
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: controller,
            maxLength: 40,
            decoration: const InputDecoration(hintText: 'Your name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isEmpty) return;
                Navigator.pop(dialogContext);
                try {
                  await ctrl.setUserName(newName);
                  if (rootContext.mounted) {
                    ScaffoldMessenger.of(rootContext).showSnackBar(
                      const SnackBar(content: Text('Name updated')),
                    );
                  }
                } catch (e) {
                  if (rootContext.mounted) {
                    ZyvoraErrorHandler.showError(
                      rootContext,
                      title: 'Error',
                      message: ZyvoraErrorHandler.formatErrorMessage(e),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
